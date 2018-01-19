if $(locate_package wine); then
  function wine-isolated () {
    WINEPREFIX="$1" WINEARCH=win32 winetricks sandbox
    cp "$2" "$1/drive_c/exec.exe"
    WINEPREFIX="$1" WINEARCH=win32 wine "C:/exec.exe"
  }
fi

if $(locate_package cpp); then
  function defines () {
    cpp -dM /dev/null | sort | cut -d" " -f2- | sed 's/^_*//' | sed 's/__* / /' | sort | uniq
  }
fi

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
      if [ -f "${file}" ] && [ ! -w "${file}" ]
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
