function addToPath () {
  export PATH=$PATH:$1
}

if $(locate_package ruby);then
  addToPath $(ruby -rubygems -e "puts Gem.user_dir")/bin
fi

if $(locate_package perl);then
  addToPath /usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl
  addToPath /home/coderobe/.perl5/bin
fi
