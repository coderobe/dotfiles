if $(locate_package bauerbill); then
  function bb () {
    (
      cd ~
      bb-wrapper $@
    )
  }
fi
