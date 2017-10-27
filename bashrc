# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Set paths
CDR_LOCATION="$HOME/Documents/Dotfiles/"
CDR_SCRIPTPATH="$HOME/Documents/Dotfiles/bash_include/"
CDR_EXECPATH="$HOME/Documents/Dotfiles/bash_execute/"
export CDR_SYSTEMD_DIR="$HOME/Documents/Dotfiles/systemd"
export SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

# Respect sshrc paths
if [ -z "${BASH_SOURCE##*sshrc*}" ]; then
  CDR_SCRIPTPATH="$(dirname ${BASH_SOURCE})/bash_include/"
  CDR_EXECPATH="$(dirname ${BASH_SOURCE})/bash_execute/"
fi

# Source all include scripts
for script in $(ls ${CDR_SCRIPTPATH} | egrep '.sh$'); do
  CDR_SCRIPT=${script%%.*}
  if [ -z "${CDR_DEBUG}" ]
    then source "${CDR_SCRIPTPATH}${script}" 2>/dev/null
    else source "${CDR_SCRIPTPATH}${script}"
  fi
done

# Evaluate all execute scripts
for script in $(ls ${CDR_EXECPATH} | egrep '.sh$')
  do CDR_SCRIPT=${script%%.*}
  eval "${CDR_EXECPATH}${script}"
done

CDR_SCRIPT="bash"

CDR_VERSION="unk"
if $(locate_package git); then  
  CDR_VERSION="$(cd ${CDR_LOCATION} && git rev-parse --short HEAD)"
fi

cdr_log "this is a $(cdr_colorize ${COL_RED} $(basename ${SHELL})) shell, running $(cdr_colorize ${COL_CYAN} coderobe/dotfiles) [$(cdr_colorize ${COL_BROWN} ${CDR_VERSION})] on $(cdr_colorize ${COL_PINK} ${HOSTNAME})"

