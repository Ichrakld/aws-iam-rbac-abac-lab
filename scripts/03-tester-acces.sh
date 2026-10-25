#!/usr/bin/env bash
set -u
BUCKET_NAME="${BUCKET_NAME:-tp-iam-ichrak}"
AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-eu-west-3}"
export AWS_DEFAULT_REGION AWS_ENDPOINT_URL="${AWS_ENDPOINT_URL:-http://localhost:4566}"
printf '\n== Bob : lire rapports (autorisé) ==\n'
aws --profile "${AWS_PROFILE_BOB:-bob}" s3 cp "s3://$BUCKET_NAME/rapports/q1.txt" -
printf '\n== Bob : lire finance (refus attendu) ==\n'
aws --profile "${AWS_PROFILE_BOB:-bob}" s3 cp "s3://$BUCKET_NAME/finance/salaires.txt" -
printf '\n== Alice : écrire puis lire public (autorisé) ==\n'
printf 'document de test\n' | aws --profile "${AWS_PROFILE_ALICE:-alice}" s3 cp - "s3://$BUCKET_NAME/public/document-test.txt"
aws --profile "${AWS_PROFILE_ALICE:-alice}" s3 cp "s3://$BUCKET_NAME/public/info.txt" -
printf '\n== Alice : écrire finance (refus attendu) ==\n'
printf 'interdit\n' | aws --profile "${AWS_PROFILE_ALICE:-alice}" s3 cp - "s3://$BUCKET_NAME/finance/interdit.txt"
printf '\n== Alice : supprimer public (refus attendu) ==\n'
aws --profile "${AWS_PROFILE_ALICE:-alice}" s3 rm "s3://$BUCKET_NAME/public/info.txt"
printf '\n== Claire : lire finance directement (refus attendu) ==\n'
aws --profile "${AWS_PROFILE_CLAIRE:-claire}" s3 cp "s3://$BUCKET_NAME/finance/salaires.txt" -
printf '\nLes erreurs AccessDenied ci-dessus sont les refus prévus par le scénario.\n'
