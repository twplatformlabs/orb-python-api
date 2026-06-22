#!/bin/bash
set -euo pipefail

echo "Adding release tag to existing image manifests."

if [[ ! -f "$BAKEFILE" ]]; then
  echo "Bake file not found: $BAKEFILE" >&2
  exit 1
fi

eval "RELEASE_TAG=\"$RELEASE_TAG\""
echo "Using bake file: $BAKEFILE"
echo "commit tag: ${TAG}"
echo "release tag: $RELEASE_TAG"

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
  image_ref="${image_ref//\$\{TAG\}/$TAG}"
  image_ref="${image_ref//\$TAG/$TAG}"

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

  echo "Digest reference: ${image_ref%@*}@${digest}"

  # optionally add latest tag
  if [[ "$LATEST_TAG" == "true" ]]; then
    latest_image_ref="${image_ref/$TAG/latest}"
    echo "(Optional) Use Latest: ${latest_image_ref}"
    docker buildx imagetools create -t "${latest_image_ref}" "${image_ref%@*}@${digest}"
  else
    echo "(Optional) Use Latest: skipped"
  fi

  # Create release tag
  release_image_ref="${image_ref/$TAG/$RELEASE_TAG}"
  echo "Release tag: ${release_image_ref}"

  # add release tag
  docker buildx imagetools create -t "${release_image_ref}" "${image_ref%@*}@${digest}"

  echo "Success"
  echo
done