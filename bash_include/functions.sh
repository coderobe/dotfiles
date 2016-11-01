function pacsearch () {
  pacman -Ss "$@"
  aursearch "$@"
}

function bb () {
  (
    cd ~
    bb-wrapper $@
  )
}
