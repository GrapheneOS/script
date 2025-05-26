#!/bin/bash

# TODO: Write better bash.

set -o errexit -o nounset -o pipefail

if [[ "${REPO_REMOTE}" == "grapheneos" || "${REPO_REMOTE}" == "grapheneos-gitlab" ]]; then
  echo "\"${REPO_PATH}\","
fi