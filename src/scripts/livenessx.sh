#!/bin/bash
set -euo pipefail

if [[ ! -f "$BAKEFILE" ]]; then
  echo "Bake file not found: $BAKEFILE" >&2
  exit 1
fi

echo "Running liveness probe check of images based on docker bake file targets."
echo "Using bake file: $BAKEFILE"
echo "Using TAG=${TAG}"
echo "Using PORT_DEFINITION=${PORT_DEFINITION}"
echo "Using HEALTH_URL=${HEALTH_URL}"
echo "Using STARTUP_DELAY=${STARTUP_DELAY}"
echo "Using DOCKER_RUN_ARGUEMENTS=${DOCKER_RUN_ARGUEMENTS}"

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

  echo "Liveness: ${image_ref} from ${target_name}"
  if ! docker buildx imagetools inspect "$image_ref" >/dev/null 2>&1; then
      echo "❌ $image_ref not found in registry"
      exit 1
  fi

  # Run image and check port
  docker run -it -d -p "${PORT_DEFINITION}" "${DOCKER_RUN_ARGUEMENTS}" "$image_ref"
  sleep "${STARTUP_DELAY}"
  curl "${HEALTH_URL}"
done

echo "Success"
