#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AWS_PROFILE_ADMIN="${AWS_PROFILE_ADMIN:-admin}"
BUCKET_NAME="${BUCKET_NAME:-tp-iam-ichrak}"
AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-eu-west-3}"
export AWS_DEFAULT_REGION AWS_ENDPOINT_URL="${AWS_ENDPOINT_URL:-http://localhost:4566}"
if ! aws --profile "$AWS_PROFILE_ADMIN" s3api head-bucket --bucket "$BUCKET_NAME" >/dev/null 2>&1; then
  aws --profile "$AWS_PROFILE_ADMIN" s3 mb "s3://$BUCKET_NAME"
fi
aws --profile "$AWS_PROFILE_ADMIN" s3 cp "$ROOT/data/rapports/q1.txt" "s3://$BUCKET_NAME/rapports/q1.txt"
aws --profile "$AWS_PROFILE_ADMIN" s3 cp "$ROOT/data/finance/salaires.txt" "s3://$BUCKET_NAME/finance/salaires.txt"
aws --profile "$AWS_PROFILE_ADMIN" s3 cp "$ROOT/data/public/info.txt" "s3://$BUCKET_NAME/public/info.txt"
aws --profile "$AWS_PROFILE_ADMIN" s3 ls "s3://$BUCKET_NAME/" --recursive
