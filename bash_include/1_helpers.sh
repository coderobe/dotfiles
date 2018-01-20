#!/usr/bin/env bash

function locate_package () {
  type -p "$1" >/dev/null
}

function cdr_exedir () {
  # shellcheck disable=SC2164
  pushd "$(dirname "$0")" > /dev/null &&
  pwd &&
  popd > /dev/null
}
export -f cdr_exedir

function cdr_colorize () {
  echo "$1${*:2}$COL_NORM"
}
export -f cdr_colorize

function cdr_log () {
  exe="$(basename -- "$0")"
  output="${exe}"
  if ! [ -z "${CDR_SCRIPT}" ]; then output="${CDR_SCRIPT}"; fi
  echo -e "$(cdr_colorize "$COL_LIGHTRED" "[${output%.*}]") ${*# *}"
}
export -f cdr_log

function cdr_debug_log () {
  if ! [ -z "${CDR_DEBUG}" ]; then cdr_log "${*# *}"; fi
}
export -f cdr_debug_log
