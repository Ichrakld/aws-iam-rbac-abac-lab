#!/usr/bin/env bash
set -euo pipefail
AWS_PROFILE_ADMIN="${AWS_PROFILE_ADMIN:-admin}"
AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-eu-west-3}"
export AWS_DEFAULT_REGION AWS_ENDPOINT_URL="${AWS_ENDPOINT_URL:-http://localhost:4566}"
ACCOUNT_ID="$(aws --profile "$AWS_PROFILE_ADMIN" sts get-caller-identity --query Account --output text)"
simuler() {
  aws --profile "$AWS_PROFILE_ADMIN" iam simulate-principal-policy \
    --policy-source-arn "arn:aws:iam::${ACCOUNT_ID}:user/alice" \
    --action-names sqs:SendMessage \
    --resource-arns "arn:aws:sqs:${AWS_DEFAULT_REGION}:${ACCOUNT_ID}:analyses" \
    --context-entries \
      "ContextKeyName=aws:PrincipalTag/team,ContextKeyValues=$1,ContextKeyType=string" \
      "ContextKeyName=aws:ResourceTag/team,ContextKeyValues=$2,ContextKeyType=string" \
    --query 'EvaluationResults[].EvalDecision' --output text
}
printf 'data/data : '; simuler data data
printf 'data/finance : '; simuler data finance
printf 'finance/data : '; simuler finance data
