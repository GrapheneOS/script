#!/bin/bash

# TODO: Write better bash.
# TODO: `gh repo fork` will silently ignore `--remote-name` if an existing remote exists. We should handle this,
# otherwise it shows up as an error when repo-rebase-all-graphene.sh looks for my-fork remote.

set -o errexit -o nounset -o pipefail
source "$(dirname ${BASH_SOURCE[0]})/../common.sh"

if [[ "${REPO_REMOTE}" == "grapheneos" ]]; then
  if [[ -z "${GH_TOKEN:-}" ]]; then
    echo_red "fail, expected GH_TOKEN environment variable to be set"
    exit 1
  fi

  # Without this, `repo fork` will complain about GrapheneOS repos that are GitHub forks themselves.
  # Example: platform_development.
  if ! gh repo set-default GrapheneOS/"${REPO_PROJECT}" &>/dev/null
  then
    # This will happen if repository doesn't exist in GrapheneOS GitHub. Unlikely to occur unless using an old tag, in
    # which case temporarily update this branch to exit 0. The reason `repo sync` still works is because Graphene
    # redirects the URL to an archive.
    echo_red "fail, probably because the remote repository does not exist"
    exit 2
  fi

  # This will add my-fork remote and exit with 0 even if the fork already exists.
  if ! gh repo fork --remote --remote-name my-fork &>/dev/null
  then
    echo_red "fail"
    exit 3
  fi

  echo "success"
  exit 0
fi