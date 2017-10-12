if $(locate_package bauerbill); then
  function bb () {
    (
      cd ~
      bb-wrapper $@
    )
  }
fi

if $(locate_package git); then
  function git-cross-pick () {
    git --git-dir="$1/.git" format-patch -k -1 --stdout "$2" | git am -3 -k
  }
fi

if $(locate_package nano); then
  function nano () {
    local WRITABLE=1
    for file in "$@"; do
      if [ ! -w "${file}" ]
        then WRITABLE=0
      fi
    done
    if [ ${WRITABLE} -eq 0 ]; then
      local OWNER=$(stat -c '%U' $file)
      cdr_log "no write permission, accessing file(s) as root..."
      sleep 1
      sudo -u "${OWNER}" nano $@
    else
      command nano $@
    fi
  }
fi
