# Terminal
case $TERM in xterm|screen|tmux) export TERM=$TERM-256color; esac

# SSH
if [ -e "$XDG_RUNTIME_DIR/ssh-agent.socket" ]; then
  export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
fi

# Defaults
if $(locate_package nano); then
  export EDITOR=nano
else
  if $(locate_package vim); then
    export EDITOR=vim
  else
    export EDITOR=vi
  fi
fi

if $(locate_package subl3); then
  export VISUAL="subl3 -w"
else
  export VISUAL=$EDITOR
fi

# Wine
if $(locate_package wine); then
  export WINEDLLOVERRIDES="winemenubuilder.exe=d"
fi

# Perl
if $(locate_package perl); then
  export PERL5LIB="$HOME/.perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
  export PERL_LOCAL_LIB_ROOT="$HOME/.perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
  export PERL_MB_OPT="--install_base \"$HOME/.perl5\""
  export PERL_MM_OPT="INSTALL_BASE=$HOME/.perl5"
fi

# GCC
if $(locate_package ccache) && $(locate_package colorgcc); then
  export CCACHE_PATH="/usr/bin"
fi

# VITA sdk
if [ -d "/usr/local/vitasdk" ]; then
  export VITASDK=/usr/local/vitasdk
fi

# Emscripten
if [ -d "/usr/lib/emscripten" ]; then
  export EMSCRIPTEN="/usr/lib/emscripten"
  export EMSCRIPTEN_FASTCOMP="/usr/lib/emscripten-fastcomp"
fi
