#!/bin/bash
pwd
origin_branches() {
  git branch -r | grep origin/ | awk -F/ '{print $2}' || exit 1
}

if [ ! -f "${LOCK}" ]; then
  echo data >${LOCK}
  echo "$ git fetch --tags --verbose origin"
  git fetch --tags --verbose origin
  for branch in $(origin_branches) ; do
    # https://stackoverflow.com/questions/1628088/reset-local-repository-branch-to-be-just-like-remote-repository-head
    echo "$ git checkout ${branch}"
    git checkout ${branch}
    echo "$ git clean -d --force"
    git clean -d --force
    echo "$ git reset --hard origin/${branch}"
    git reset --hard origin/${branch}
  done
  echo "$ git push sync --all --force"
  git push sync --all --force
  rm "$LOCK"
else
  echo "System locked." >&2
  exit 1
fi
