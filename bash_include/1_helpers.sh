function locate_package () {
  #! [ -z "$(whereis $1 | cut -d':' -f2-)" ]
  ! [ $(type -p "$1" >/dev/null) ]
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
	echo -e "$(cdr_colorize $COL_RED [${exe%.*}]) ${@# *}"
}
export -f cdr_log
