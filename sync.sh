#!/bin/bash
LOCK=".lock"
pwd
remote_sha() {
  (git ls-remote --quiet $1 refs/heads/$2 | awk '{ print $1 }') || return 1
}

if [ ! -f "$LOCK" ]; then
  touch "$LOCK"
  echo "Getting heads"
  HEAD=${1}
  TARGET_HEAD=${2}
  if [ -z "${TARGET_HEAD}" ]; then
    TARGET_HEAD=${HEAD}
  fi
  echo "${HEAD}:${TARGET_HEAD}"
  echo "Checking Branch ${HEAD}"
  ORIGIN="$(remote_sha origin ${HEAD})"
  echo "... origin ${HEAD}: ${ORIGIN}"
  SYNC="$(remote_sha sync $TARGET_HEAD)"
  echo "... sync ${TARGET_HEAD}: ${SYNC}"
  if [ "${SYNC}" != "${ORIGIN}" ]; then
    echo "... synching"
    git reset --hard origin/$HEAD            || (rm "$LOCK"; exit 1) || exit 1
    git push --force sync $HEAD:$TARGET_HEAD || (rm "$LOCK"; exit 1) || exit 1
    echo "... done."
  else
    echo "... in sync."
  fi
  echo ""
  rm "$LOCK"
else
  echo "System locked." >&2
  exit 1
fi
