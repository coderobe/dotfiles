#!/usr/bin/env bash
# shellcheck disable=SC1090
# shellcheck disable=SC2128
# shellcheck disable=SC2155

# Set paths
CDR_LOCATION="$HOME/Documents/Dotfiles/"
CDR_SCRIPTPATH="$HOME/Documents/Dotfiles/bash_include/"
CDR_EXECPATH="$HOME/Documents/Dotfiles/bash_execute/"
export CDR_SYSTEMD_DIR="$HOME/Documents/Dotfiles/systemd"
export SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

# Respect sshrc paths
if [ -z "${BASH_SOURCE##*sshrc*}" ]; then
  CDR_SCRIPTPATH="$(dirname "${BASH_SOURCE}")/bash_include/"
  CDR_EXECPATH="$(dirname "${BASH_SOURCE}")/bash_execute/"
fi

# Source all include scripts
for script in "${CDR_SCRIPTPATH}"*.sh; do
  CDR_SCRIPT="${script%%.*}"
  if [ -z "${CDR_DEBUG}" ]
    then source "${script}" 2>/dev/null
    else source "${script}"
  fi
done

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Fix WSL (fuck microsoft for half-assing their implementations)
# TODO: fix this half-assed fix
dbus_env="$HOME/.dbus-wsl"
ssh_env="$HOME/.ssh-wsl"
function wsl_fix_daemon {
  echo "Windows is garbage. Launching daemons manually"
  echo "Summoning DBUS"
  dbus-launch --sh-syntax > "${dbus_env}"
  echo "Summoning SSH Agent"
  ssh-agent > "${ssh_env}"
  echo "Setting up environment"
  chmod 600 "${dbus_env}"
  chmod 600 "${ssh_env}"
  . "${dbus_env}" > /dev/null
  . "${ssh_env}" > /dev/null
}
export CDR_WSL=0
if uname -a | grep 'Microsoft'; then
  export CDR_WSL=1
  export DISPLAY="$(hostname):0.0"
  if [ -f "${ssh_env}" ]; then
    . "${dbus_env}" > /dev/null
    . "${ssh_env}" > /dev/null
    pgrep "ssh-agent" | grep "${SSH_AGENT_PID}" > /dev/null || {
      wsl_fix_daemon
    }
  else
    wsl_fix_daemon
  fi
  export DBUS_SESSION_BUS_ADDRESS
  export DBUS_SESSION_BUS_PID
  export DBUS_SESSION_BUS_WINDOWID
  export SSH_AUTH_SOCK
  export SSH_AGENT_PID
  export NO_AT_BRIDGE=1
fi

CDR_FIRSTRUN=0
CDR_SYSTEM="$(uname)"
CDR_DARLING=""

# Evaluate all execute scripts
for script in "${CDR_EXECPATH}"*.sh
  do CDR_SCRIPT=${script%%.*}
  eval "${script}"
done

# shellcheck disable=SC2034
CDR_SCRIPT="bash"

CDR_VERSION="unknown version"
if locate_package git; then  
  CDR_VERSION="updated $(cd "${CDR_LOCATION}" && git log -1 --format=%ar)"
fi

cdr_log "using $(cdr_colorize "${COL_CYAN}" "coderobe/dotfiles") [$(cdr_colorize "${COL_BROWN}" "${CDR_VERSION}")] on $(cdr_colorize "${COL_PINK}" "${HOSTNAME}")"
