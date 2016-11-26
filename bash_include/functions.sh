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
