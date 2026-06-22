#!/usr/bin/env bash
set -eo pipefail

echo "Add $TAG parameter to BASH_ENV."
echo "CIRCLE_SHA1=$CIRCLE_SHA1"
echo "CIRCLE_TAG=$CIRCLE_TAG"

# set ENV var to the build commit tag provided by the job
echo "export TAG=$TAG" >> "$BASH_ENV"