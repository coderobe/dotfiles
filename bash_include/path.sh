function addToPath () {
  export PATH=$PATH:$1
}

function addToPathStart () {
  export PATH=$1:$PATH
}

if $(locate_package ruby);then
  addToPath $(ruby -rubygems -e "puts Gem.user_dir")/bin
fi

if $(locate_package perl);then
  addToPath /usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl
  addToPath $HOME/.perl5/bin
fi

CDR_BINDIR="$HOME/Documents/Scripts/bin"
if [ -d "${CDR_BINDIR}" ]; then
  addToPathStart "${CDR_BINDIR}"
fi
