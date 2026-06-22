#!/bin/bash
set -euo pipefail

echo "Signing released images."

if [[ ! -f "$BAKEFILE" ]]; then
  echo "Bake file not found: $BAKEFILE" >&2
  exit 1
fi

echo "Using bake file: $BAKEFILE"
echo "release tag: $RELEASE_TAG"
if [[ -z "${COSIGN_SIGN_KEY}" ]]; then
  echo "Signing key is provided"
fi
echo "COSIGN_VERIFY_KEY = ${COSIGN_VERIFY_KEY}"
if [[ -z "${COSIGN_VERIFY_KEY}" ]]; then
  echo "Verification key is provided"
fi
if [[ -z "${COSIGN_PASSWORD}" ]]; then
  echo "Key passphrase is provided"
fi
echo

# Extract all targets and their tags
jq -r '
  .target
  | to_entries[]
  | select(.value.tags != null)
  | .key as $name
  | .value.tags[]
  | [$name, .]
  | @tsv
' "$BAKEFILE" |
while IFS=$'\t' read -r target_name raw_tag; do
  image_ref="$raw_tag"

  # Replace bakefile var reference with actual VAR value.
  # We define it twice to support both ${TAG} and $TAG
  image_ref="${image_ref//\$\{TAG\}/$RELEASE_TAG}"
  image_ref="${image_ref//\$TAG/$RELEASE_TAG}"

  # pick up any other ENV should they exist in the defition (allow more customization)
  image_ref="$(eval echo "$image_ref")"

  echo "Target: ${target_name}"
  echo "Source image: ${image_ref}"

# Obtain manifest index digest
  digest=$(oras manifest fetch --descriptor "${image_ref}" | jq -r '.digest')

  if [[ -z "$digest" ]]; then
    echo "❌ Unable to resolve digest for ${image_ref}"
    exit 1
  fi

  export COSIGN_EXPERIMENTAL=1
  echo "Signing digest reference: ${image_ref%@*}@${digest}"
  # sign image
  cosign sign --registry-referrers-mode=oci-1-1 --key "${COSIGN_SIGN_KEY}" "${image_ref%@*}@${digest}" -y

  # verify signature
  cosign verify --key "${COSIGN_VERIFY_KEY}" "${image_ref}@${digest}"

  echo "Release version signed and verified"
  echo
done
