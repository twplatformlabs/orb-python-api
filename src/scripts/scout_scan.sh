#!/bin/bash
set -euo pipefail

if [[ ! -f "$BAKEFILE" ]]; then
  echo "Bake file not found: $BAKEFILE" >&2
  exit 1
fi

OUTFILE="workspace/$OUTFILE"
echo "Running Docker Scout CVE scan against images based on docker bake file targets."
echo "Using bake file: $BAKEFILE"
echo "Using TAG=${TAG}"
echo "Output file: $OUTFILE"

# confirm dockerhub credentials. redundant when also using Dockerhub as registry but required otherwise.
echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_LOGIN}" --password-stdin docker.io

{
  echo "=== Docker Scout CVE Scan Results ==="
  echo "Bake file: $BAKEFILE"
  echo "TAG: $TAG"
  echo
} > "${OUTFILE}"

# Extract all targets and their tags, append scan results to OUTFILE
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

  # Replace bake file var reference with actual VAR value.
  # We define it twice to support both ${TAG} and $TAG
  image_ref="${image_ref//\$\{TAG\}/$TAG}"
  image_ref="${image_ref//\$TAG/$TAG}"

  # pick up any other ENV should they exist in the defition (allows more customization)
  image_ref="$(eval echo "$image_ref")"

  echo "Scanning Target: ${target_name}  Image: ${image_ref}" | tee -a "$OUTFILE"
  if ! docker buildx imagetools inspect "$image_ref" >/dev/null 2>&1; then
      echo "❌ $image_ref not found in registry"
      exit 1
  fi

  # Run Docker Scout CVE scan and append to OUTFILE
  {
    echo "===== Target: ${target_name}  Image: ${image_ref} ====="
    docker scout cves "$image_ref" --details
    docker scout recommendations "$image_ref"
    echo
    echo "view scout output in pipeline artifacts for details"
    echo "--- End of ${target_name} scan ---"
    echo
  } >> "${OUTFILE}"
done

echo "Success"