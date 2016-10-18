#!/usr/bin/bash

CDROOT_JAILS=()
CDROOT_BASEPATH="$HOME/Documents/Jails/contexts"
export CDROOT_OLDPATH=$(pwd)

function addJailPath () {
  CDROOT_JAILS[${#CDROOT_JAILS[@]}]="$1"
}

function cdroot () {
  for elem in "${CDROOT_JAILS[@]}"; do
    if [ "$(basename $elem)" == "$1" ]; then
      (
        cd $elem
        PROOT_NO_SECCOMP=1 ./launch
      )
      return 0
    fi
  done
  echo "Jail $1 not found!" >&2
  return 1
}

addJailPath "$CDROOT_BASEPATH/vitasdk"
