#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AWS_PROFILE_ADMIN="${AWS_PROFILE_ADMIN:-admin}"
AWS_PROFILE_ALICE="${AWS_PROFILE_ALICE:-alice}"
AWS_PROFILE_BOB="${AWS_PROFILE_BOB:-bob}"
AWS_PROFILE_CLAIRE="${AWS_PROFILE_CLAIRE:-claire}"
BUCKET_NAME="${BUCKET_NAME:-tp-iam-ichrak}"
AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-eu-west-3}"
export AWS_DEFAULT_REGION

command -v aws >/dev/null || { echo "AWS CLI introuvable." >&2; exit 1; }
: "${AWS_ENDPOINT_URL:=http://localhost:4566}"
export AWS_ENDPOINT_URL
ACCOUNT_ID="$(aws --profile "$AWS_PROFILE_ADMIN" sts get-caller-identity --query Account --output text)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

render() {
  sed -e "s|\${ACCOUNT_ID}|$ACCOUNT_ID|g" -e "s|\${BUCKET_NAME}|$BUCKET_NAME|g" "$1" > "$2"
}

ensure_managed_policy() {
  local name="$1" file="$2" arn="arn:aws:iam::${ACCOUNT_ID}:policy/${name}"
  render "$ROOT/policies/$file" "$tmp/$file"
  if aws --profile "$AWS_PROFILE_ADMIN" iam get-policy --policy-arn "$arn" >/dev/null 2>&1; then
    echo "Politique déjà créée : $name (le document existant est conservé)." >&2
  else
    aws --profile "$AWS_PROFILE_ADMIN" iam create-policy --policy-name "$name" --policy-document "file://$tmp/$file" >/dev/null
    echo "Politique créée : $name" >&2
  fi
  printf '%s' "$arn"
}

reports_arn="$(ensure_managed_policy lecture-rapports lecture-rapports.json)"
aws --profile "$AWS_PROFILE_ADMIN" iam attach-group-policy --group-name auditeurs --policy-arn "$reports_arn"
public_arn="$(ensure_managed_policy ecriture-public ecriture-public.json)"
aws --profile "$AWS_PROFILE_ADMIN" iam attach-group-policy --group-name developpeurs --policy-arn "$public_arn"

render "$ROOT/policies/confiance-lecteur-finance.json" "$tmp/confiance.json"
render "$ROOT/policies/lecture-finance.json" "$tmp/lecture-finance.json"
render "$ROOT/policies/assume-lecteur-finance.json" "$tmp/assume.json"
if ! aws --profile "$AWS_PROFILE_ADMIN" iam get-role --role-name lecteur-finance >/dev/null 2>&1; then
  aws --profile "$AWS_PROFILE_ADMIN" iam create-role --role-name lecteur-finance --assume-role-policy-document "file://$tmp/confiance.json" >/dev/null
  echo "Rôle créé : lecteur-finance"
else
  echo "Rôle déjà créé : lecteur-finance (la confiance existante est conservée)."
fi
aws --profile "$AWS_PROFILE_ADMIN" iam put-role-policy --role-name lecteur-finance --policy-name lecture-finance --policy-document "file://$tmp/lecture-finance.json"
aws --profile "$AWS_PROFILE_ADMIN" iam put-user-policy --user-name claire --policy-name assume-lecteur-finance --policy-document "file://$tmp/assume.json"
render "$ROOT/policies/abac-files.json" "$tmp/abac-files.json"
aws --profile "$AWS_PROFILE_ADMIN" iam put-user-policy --user-name alice --policy-name abac-files --policy-document "file://$tmp/abac-files.json"
echo "Politiques attachées. Bucket=$BUCKET_NAME ; compte=$ACCOUNT_ID"
