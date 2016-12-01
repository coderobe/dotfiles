function locate_package () {
  type -p "$1" >/dev/null
}

function cdr_exedir () {
	pushd `dirname $0` > /dev/null
	echo `pwd`
	popd > /dev/null
}
export -f cdr_exedir

function cdr_colorize () {
	echo "$1${@:2}$COL_NORM"
}
export -f cdr_colorize

function cdr_log () {
	exe="$(basename -- $0)"
	script="$(basename -- ${BASH_SOURCE})"
        output="${exe}"
        if [ -z "$script" ]; then output="${script}"; fi
	echo -e "$(cdr_colorize $COL_LIGHTRED [${output%.*}]) ${@# *}"
}
export -f cdr_log
