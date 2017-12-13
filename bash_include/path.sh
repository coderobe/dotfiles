function addToPath () {
  cdr_debug_log "Appending '$(cdr_colorize ${COL_LIGHTBLUE} $1)' to the PATH"
  case ":${PATH}:" in
    *":$1:"*) cdr_debug_log "Duplicate path '$(cdr_colorize ${COL_LIGHTBLUE} $1)'";;
    *) export PATH="${PATH}:$1";;
  esac
}

function addToPathStart () {
  cdr_debug_log "Prepending '$(cdr_colorize ${COL_LIGHTBLUE} $1)' to the PATH"
  case ":${PATH}:" in
    *":$1:"*) cdr_debug_log "Duplicate path '$(cdr_colorize ${COL_LIGHTBLUE} $1)'";;
    *) export PATH="$1:${PATH}";;
  esac
}

if $(locate_package ruby);then
  addToPath $(ruby -rubygems -e "puts Gem.user_dir")/bin
fi

if $(locate_package perl);then
  addToPath "/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl"
  addToPath "${HOME}/.perl5/bin"
fi

CDR_BINDIR="$HOME/Documents/Scripts/bin"
if [ -d "${CDR_BINDIR}" ]; then
  addToPathStart "${CDR_BINDIR}"
fi

if $(locate_package ccache) && $(locate_package colorgcc); then
  addToPathStart "/usr/lib/colorgcc/bin/"
fi

if [ -d "/usr/local/vitasdk" ]; then
  addToPathStart "${VITASDK}/bin"
fi

if [ -d "${EMSCRIPTEN}" ]; then
  addToPathStart "$EMSCRIPTEN"
fi

cdr_debug_log "Path now '$(cdr_colorize ${COL_LIGHTBLUE} ${PATH})'"
cdr_debug_log "Cleaning up..."
if [ -n "${PATH}" ]; then
  old_PATH=$PATH:; PATH=
  while [ -n "${old_PATH}" ]; do
    x=${old_PATH%%:*}
    case ${PATH}: in
      *:"$x":*) ;;
      *) PATH=$PATH:$x;;
    esac
    old_PATH=${old_PATH#*:}
  done
  PATH=${PATH#:}
  unset old_PATH x
fi
cdr_debug_log "Path now '$(cdr_colorize ${COL_LIGHTBLUE} ${PATH})'"
