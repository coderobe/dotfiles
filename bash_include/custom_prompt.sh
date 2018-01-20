#!/bin/bash
# shellcheck disable=SC1117
# shellcheck disable=SC2155
# shellcheck disable=SC2034

# Filename:      custom_prompt.sh
# Original by:   Dave Vehrs
# Modified by:   Robin Broda (coderobe)

# Current Format: USER@HOST [dynamic section] CURRENT DIRECTORY $ 
# USER:      (also sets the base color for the prompt)
#   Red       == Root(UID 0) Login shell (i.e. sudo bash)
#   Light Red == Root(UID 0) Login shell (i.e. su -l or direct login)
#   Yellow    == Root(UID 0) priviledges in non-login shell (i.e. su)
#   Brown     == SU to user other than root(UID 0)
#   Green     == Normal user
# @:
#   Light Red == http_proxy environmental variable undefined.
#   Green     == http_proxy environmental variable configured.
# HOST:
#   Red       == Insecure remote connection (unknown type)
#   Yellow    == Insecure remote connection (Telnet)
#   Brown     == Insecure remote connection (RSH)
#   Cyan      == Secure remote connection (i.e. SSH)
#   Purple     == Local session
# DYNAMIC SECTION:
#     (If count is zero for any of the following, it will not appear)
#   [tmx:#] ==== Number of detached tmux sessions
#     Yellow    == 1-2
#     Red       == 3+
#   [bg:#]  ==== Number of backgrounded but still running jobs
#     Yellow    == 1-10
#     Red       == 11+
#   [stp:#] ==== Number of stopped (backgrounded) jobs
#     Yellow    == 1-2
#     Red       == 3+
# CURRENT DIRECTORY:     (truncated to 1/4 screen width)
#   Red       == Current user does not have write priviledges
#   Green     == Current user does have write priviledges
# NOTE:
#   1.  Displays message on day change at midnight on the line above the
#       prompt (Day changed to...).
#   2.  Command is added to the history file each time you hit enter so its
#       available to all shells.

# Configure Colors:
COLOR_WHITE='\033[1;37m'
COLOR_LIGHTGRAY='033[0;37m'
COLOR_GRAY='\033[1;30m'
COLOR_BLACK='\033[0;30m'
COLOR_RED='\033[0;31m'
COLOR_LIGHTRED='\033[1;31m'
COLOR_GREEN='\033[0;32m'
COLOR_LIGHTGREEN='\033[1;32m'
COLOR_BROWN='\033[0;33m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_LIGHTBLUE='\033[1;34m'
COLOR_PURPLE='\033[0;35m'
COLOR_PINK='\033[1;35m'
COLOR_CYAN='\033[0;36m'
COLOR_LIGHTCYAN='\033[1;36m'
COLOR_DEFAULT='\033[0m'

# Function to set prompt_command to.
function promptcmd () {
    [[ "${CDR_DEBUG}" ]] && cdr_log "" "promptcmd() enter"
    history -a
    local SSH_FLAG=0
    local TTY="$(tty | awk -F/dev/ '{print $2}')"
    if [[ "${TTY}" ]]; then
        local SESS_SRC=$(who | grep "$TTY " | awk '{print $6 }')
    fi

    [[ "${CDR_DEBUG}" ]] && cdr_log "" "promptcmd() titlebar"
    # Titlebar
    case "${TERM}" in
        xterm*)
            local TITLEBAR='\[\033]0;\u@\h: { \w }  \007\]'
            ;;
        *)
            local TITLEBAR=''
            ;;
    esac
    PS1="${TITLEBAR}"

    [[ "${CDR_DEBUG}" ]] && cdr_log "" "promptcmd() daychange"
    # Test for day change.
    if [[ "$DAY" ]]; then
        export DAY="$(date +%A)"
    else
        local today="$(date +%A)"
        if [ "${DAY}" != "${today}" ]; then
            PS1="${PS1}\n\[${COLOR_GREEN}\]Day changed to $(date '+%A, %d %B %Y').\n"
            export DAY="$today"
       fi
    fi

    [[ "${CDR_DEBUG}" ]] && cdr_log "" "promptcmd() user"
    # User
    if [ "${UID}" -eq 0 ] ; then
        if [ "${USER}" == "${LOGNAME}" ]; then
            if [[ "${SUDO_USER}" ]]; then
                PS1="${PS1}\[${COLOR_RED}\]\u"
            else
                PS1="${PS1}\[${COLOR_LIGHTRED}\]\u"
            fi
        else
            PS1="${PS1}\[${COLOR_YELLOW}\]\u"
        fi
    else
        if [ "${USER}" == "${LOGNAME}" ]; then
            PS1="${PS1}\[${COLOR_GREEN}\]\u"
        else
            PS1="${PS1}\[${COLOR_BROWN}\]\u"
        fi
    fi

    [[ "${CDR_DEBUG}" ]] && cdr_log "" "promptcmd() http_proxy"
    # HTTP Proxy var configured or not
    # shellcheck disable=SC2154
    if [ -n "$http_proxy" ] ; then
        PS1="${PS1}\[${COLOR_GREEN}\]@"
    else
        PS1="${PS1}\[${COLOR_LIGHTRED}\]@"
    fi

    [[ "${CDR_DEBUG}" ]] && cdr_log "" "promptcmd() host"
    # Host
    if [[ "${SSH_CLIENT}" ]] || [[ "${SSH2_CLIENT}" ]]; then
        SSH_FLAG=1
    fi
    if [ "${SSH_FLAG}" -eq 1 ]; then
       PS1="${PS1}\[${COLOR_CYAN}\]\h "
    elif [[ -n "${SESS_SRC}" ]]; then
        if [ "${SESS_SRC}" == "(:0.0)" ]; then
            PS1="${PS1}\[${COLOR_PURPLE}\]\h "
        else
            local parent_process="$(</proc/${PPID}/cmdline)"
            if [[ "$parent_process" == "in.rlogind*" ]]; then
                PS1="${PS1}\[${COLOR_BROWN}\]\h "
            elif [[ "$parent_process" == "in.telnetd*" ]]; then
                PS1="${PS1}\[${COLOR_YELLOW}\]\h "
            else
                PS1="${PS1}\[${COLOR_LIGHTRED}\]\h "
            fi
        fi
    elif [[ "${SESS_SRC}" == "" ]]; then
        PS1="${PS1}\[${COLOR_PURPLE}\]\h "
    else
        PS1="${PS1}\[${COLOR_RED}\]\h "
    fi

    [[ "${CDR_DEBUG}" ]] && cdr_log "" "promptcmd() tmux"
    # Detached tmux Sessions
    local DTCHSCRN="$(tmux ls 2>/dev/null | grep -c -E "^[0-9]+:")"
    if [ "${DTCHSCRN}" -gt 2 ]; then
        PS1="${PS1}\[${COLOR_RED}\][tmx:${DTCHSCRN}] "
    elif [ "${DTCHSCRN}" -gt 0 ]; then
        PS1="${PS1}\[${COLOR_YELLOW}\][tmx:${DTCHSCRN}] "
    fi

    [[ "${CDR_DEBUG}" ]] && cdr_log "" "promptcmd() machinectl"
    # Running Machinectl VMs
    local MCTLVM="No"
    if [ "${CDR_WSL}" -eq 0 ]; then
        MCTLVM=$(machinectl list | tail -n1 | cut -d' ' -f1)
    fi
    if [ "${MCTLVM}" == "No" ]; then
        MCTLVM=0
    fi
    if [ "${MCTLVM}" -gt 0 ]; then
        PS1="${PS1}\[${COLOR_PINK}\][mctl:${MCTLVM}] "
    fi

    [[ "${CDR_DEBUG}" ]] && cdr_log "" "promptcmd() bg"
    # Backgrounded running jobs
    local BKGJBS="$(jobs -r | wc -l)"
    if [ "${BKGJBS}" -gt 2 ]; then
        PS1="${PS1}\[${COLOR_RED}\][bg:${BKGJBS}]"
    elif [ "${BKGJBS}" -gt 0 ]; then
        PS1="${PS1}\[${COLOR_YELLOW}\][bg:${BKGJBS}] "
    fi

    [[ "${CDR_DEBUG}" ]] && cdr_log "" "promptcmd() stopped jobs"
    # Stopped Jobs
    local STPJBS="$(jobs -s | wc -l)"
    if [ "${STPJBS}" -gt 2 ]; then
        PS1="${PS1}\[${COLOR_RED}\][stp:${STPJBS}]"
    elif [ "${STPJBS}" -gt 0 ]; then
        PS1="${PS1}\[${COLOR_YELLOW}\][stp:${STPJBS}] "
    fi

    [[ "${CDR_DEBUG}" ]] && cdr_log "" "promptcmd() bracket open"
    # Bracket {
    if [ "${UID}" -eq 0 ]; then
        if [ "${USER}" == "${LOGNAME}" ]; then
            if [[ "${SUDO_USER}" ]]; then
                PS1="${PS1}\[${COLOR_RED}\]"
            else
                PS1="${PS1}\[${COLOR_LIGHTRED}\]"
            fi
        else
            PS1="${PS1}\[${COLOR_YELLOW}\]"
        fi
    else
        if [ "${USER}" == "${LOGNAME}" ]; then
            PS1="${PS1}\[${COLOR_GREEN}\]"
        else
            PS1="${PS1}\[${COLOR_BROWN}\]"
        fi
    fi

    [[ "${CDR_DEBUG}" ]] && cdr_log "" "promptcmd() wd"
    # Working directory
    if [ -w "${PWD}" ]; then
        PS1="${PS1}\[${COLOR_GREEN}\]$(prompt_workingdir)"
    else
        PS1="${PS1}\[${COLOR_RED}\]$(prompt_workingdir)"
    fi

    [[ "${CDR_DEBUG}" ]] && cdr_log "" "promptcmd() bracket close"
    # Closing bracket } and $\#
    if [ "${UID}" -eq 0 ]; then
        if [ "${USER}" == "${LOGNAME}" ]; then
            if [[ "${SUDO_USER}" ]]; then
                PS1="${PS1}\[${COLOR_RED}\]"
            else
                PS1="${PS1}\[${COLOR_LIGHTRED}\]"
            fi
        else
            PS1="${PS1}\[${COLOR_YELLOW}\]"
        fi
    else
        if [ "${USER}" == "${LOGNAME}" ]; then
            PS1="${PS1}\[${COLOR_GREEN}\]"
        else
            PS1="${PS1}\[${COLOR_BROWN}\]"
        fi
    fi
    PS1="${PS1} \$\[${COLOR_DEFAULT}\] "
    [[ "${CDR_DEBUG}" ]] && cdr_log "" "promptcmd() leave"
}

# Trim working dir to 1/4 the screen width
function prompt_workingdir () {
  # Bugfix for sudo su sessions where COLUMNS is unset before a command is ran
  if [[ "$COLUMNS" ]]; then
    echo -n
  else
    COLUMNS=80
  fi
  local pwdmaxlen="$((COLUMNS/4))"
  local trunc_symbol="..."
  if [[ "$PWD" == "$HOME*" ]]; then
    newPWD="~${PWD#$HOME}"
  else
    newPWD="${PWD}"
  fi
  if [ "${#newPWD}" -gt "$pwdmaxlen" ]; then
    local pwdoffset=$(("${#newPWD}" - "$pwdmaxlen" + 3))
    newPWD="${trunc_symbol}${newPWD:$pwdoffset:$pwdmaxlen}"
  fi
  echo "$newPWD"
}

# Determine what prompt to display:
# 1.  Display simple custom prompt for shell sessions started
#     by script.
# 2.  Display "bland" prompt for shell sessions within emacs or
#     xemacs.
# 3   Display promptcmd for all other cases.

function load_prompt () {
    # Get PIDs
    local parent_process="$(cut -d \. -f 1 < "/proc/$PPID/cmdline")"
    local my_process="$(cut -d \. -f 1 < "/proc/$$/cmdline")"

    if [[ "$parent_process" == script* ]]; then
        PROMPT_COMMAND=""
        PS1="\t - \# - \u@\H { \w }\$ "
    elif [[ "$parent_process" == emacs* || "$parent_process" == xemacs* ]]; then
        PROMPT_COMMAND=""
        PS1="\u@\h { \w }\$ "
    else
        export DAY="$(date +%A)"
        PROMPT_COMMAND=promptcmd
     fi
    export PS1 PROMPT_COMMAND
}

load_prompt
