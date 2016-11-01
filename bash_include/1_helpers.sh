function locate_package () {
  ! [ -z "$(whereis $1 | cut -d':' -f2-)" ]
}
