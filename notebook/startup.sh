#!/bin/bash
# The repository is already cloned and filtered by the repo-setup init
# container; these scripts only prepare the checkout and are optional.

set -u

for script in /usr/local/bin/setup-git.sh /usr/local/bin/register-git-repos.sh; do
  if [ -x "$script" ]; then
    "$script" || echo "Warning: $script failed, continuing"
  fi
done

exec jupyterhub-singleuser "$@"
