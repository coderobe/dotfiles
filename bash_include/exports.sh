# Terminal
case $TERM in xterm|screen|tmux) export TERM=$TERM-256color; esac

# Defaults
export EDITOR=nano
if $(locate_package subl3); then
  export VISUAL=subl3
else
  export VISUAL=$EDITOR
fi

# Wine
export WINEDLLOVERRIDES="winemenubuilder.exe=d"

# Perl
export PERL5LIB="/home/coderobe/.perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
export PERL_LOCAL_LIB_ROOT="/home/coderobe/.perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
export PERL_MB_OPT="--install_base \"/home/coderobe/.perl5\""
export PERL_MM_OPT="INSTALL_BASE=/home/coderobe/.perl5"
