#!/usr/bin/env bash
# shellcheck disable=SC1090

[[ -f "${HOME}/.bashrc" ]] && . "${HOME}/.bashrc"

xhost +local: > /dev/null 2>&1
