#!/usr/bin/env bash
set -euo pipefail
BUCKET_NAME="${BUCKET_NAME:-tp-iam-ichrak}"
AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-eu-west-3}"
AWS_PROFILE_CLAIRE="${AWS_PROFILE_CLAIRE:-claire}"
AWS_PROFILE_CLAIRE_ROLE="${AWS_PROFILE_CLAIRE_ROLE:-claire-role}"
export AWS_DEFAULT_REGION AWS_ENDPOINT_URL="${AWS_ENDPOINT_URL:-http://localhost:4566}"
ACCOUNT_ID="$(aws --profile "${AWS_PROFILE_ADMIN:-admin}" sts get-caller-identity --query Account --output text)"
read -r AK SK TK EXP < <(aws --profile "$AWS_PROFILE_CLAIRE" sts assume-role \
  --role-arn "arn:aws:iam::${ACCOUNT_ID}:role/lecteur-finance" \
  --role-session-name claire-session \
  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken,Expiration]' \
  --output text)
aws configure set aws_access_key_id "$AK" --profile "$AWS_PROFILE_CLAIRE_ROLE"
aws configure set aws_secret_access_key "$SK" --profile "$AWS_PROFILE_CLAIRE_ROLE"
aws configure set aws_session_token "$TK" --profile "$AWS_PROFILE_CLAIRE_ROLE"
aws configure set region "$AWS_DEFAULT_REGION" --profile "$AWS_PROFILE_CLAIRE_ROLE"
unset AK SK TK
printf 'Session temporaire expirant à : %s\n' "$EXP"
printf '\n== Lecture finance (autorisée) ==\n'
aws --profile "$AWS_PROFILE_CLAIRE_ROLE" s3 cp "s3://$BUCKET_NAME/finance/salaires.txt" -
printf '\n== Lecture rapports (refus attendu) ==\n'
if aws --profile "$AWS_PROFILE_CLAIRE_ROLE" s3 cp "s3://$BUCKET_NAME/rapports/q1.txt" -; then
  echo "ERREUR : le rôle a lu rapports/ alors que l’accès doit être refusé." >&2
else
  echo "Refus attendu : le rôle ne peut pas lire rapports/."
fi
aws --profile "$AWS_PROFILE_CLAIRE_ROLE" sts get-caller-identity
