# Terminal
case $TERM in xterm|screen|tmux) export TERM=$TERM-256color; esac

# SSH
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

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
export PERL5LIB="$HOME/.perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
export PERL_LOCAL_LIB_ROOT="$HOME/.perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
export PERL_MB_OPT="--install_base \"$HOME/.perl5\""
export PERL_MM_OPT="INSTALL_BASE=$HOME/.perl5"
