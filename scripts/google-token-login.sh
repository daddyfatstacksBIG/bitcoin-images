#!/bin/sh
# Exchange a GitLab ID token for a short-lived registry password.
set +x
set -eu
set -f

fail() { printf '%s\n' "$*" >&2; exit 1; }
[ "$#" -gt 0 ] || exit 0
for host do
    case "$host" in *-docker.pkg.dev) ;; *) fail 'Unsupported token registry host' ;; esac
done
: "${GCP_ID_TOKEN:?GCP_ID_TOKEN is required for token registry login}"
: "${GCP_WORKLOAD_IDENTITY_PROVIDER:?GCP_WORKLOAD_IDENTITY_PROVIDER is required}"
: "${GCP_SERVICE_ACCOUNT:?GCP_SERVICE_ACCOUNT is required}"
if ! command -v curl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
    apk add --no-cache curl jq
fi

# Endpoint overrides are for local mock tests only.
sts_url=${GCP_STS_URL:-https://sts.googleapis.com/v1/token}
iam_url=${GCP_IAMCREDENTIALS_URL:-https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/$GCP_SERVICE_ACCOUNT:generateAccessToken}
response=$(printf '%s' "$GCP_ID_TOKEN" | curl --fail --silent --show-error \
    --request POST "$sts_url" \
    --data-urlencode 'grant_type=urn:ietf:params:oauth:grant-type:token-exchange' \
    --data-urlencode "audience=//iam.googleapis.com/$GCP_WORKLOAD_IDENTITY_PROVIDER" \
    --data-urlencode 'scope=https://www.googleapis.com/auth/cloud-platform' \
    --data-urlencode 'requested_token_type=urn:ietf:params:oauth:token-type:access_token' \
    --data-urlencode 'subject_token_type=urn:ietf:params:oauth:token-type:jwt' \
    --data-urlencode 'subject_token@-') || fail 'Token exchange request failed'
federated_token=$(printf '%s' "$response" | jq -er '.access_token | select(type == "string" and length > 0)' 2>/dev/null) ||
    fail 'Token exchange returned no access token'
response=$(printf 'header = "Authorization: Bearer %s"\n' "$federated_token" |
    curl --config - --fail --silent --show-error --request POST "$iam_url" \
        --header 'Content-Type: application/json' \
        --data '{"scope":["https://www.googleapis.com/auth/cloud-platform"]}') ||
    fail 'Access token request failed'
access_token=$(printf '%s' "$response" | jq -er '.accessToken | select(type == "string" and length > 0)' 2>/dev/null) ||
    fail 'Access token response contained no access token'
for host do
    printf '%s\n' "$access_token" |
        docker login -u oauth2accesstoken --password-stdin "https://$host"
done
unset response federated_token access_token
