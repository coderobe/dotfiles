#!/bin/bash
# shellcheck disable=SC1117
# shellcheck disable=SC2155
# shellcheck disable=SC2034

# Filename:      custom_prompt.sh
# Original by:   Dave Vehrs
# Modified by:   Robin Broda (coderobe)

# Function to set PROMPT_COMMAND to.
function promptcmd () {
    cdr_debug_log "promptcmd()" "enter"

    if [[ "${CDR_SYSTEM}" == "" ]]; then
        CDR_SYSTEM="$(uname)"
        cdr_debug_log "promptcmd()" "set CDR_SYSTEM to ${CDR_SYSTEM}"
    else
        cdr_debug_log "promptcmd()" "CDR_SYSTEM is ${CDR_SYSTEM}"
    fi

    cdr_debug_log "promptcmd()" "flush history"
    history -a

    local SSH_FLAG=0
    local TTY="$(tty | awk -F/dev/ '{print $2}')"
    if [[ "${TTY}" ]]; then
        local SESS_SRC=$(who | grep "$TTY " | awk '{print $6 }')
    fi

    cdr_debug_log "promptcmd()" "titlebar"
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

    cdr_debug_log "promptcmd()" "daychange"
    # Test for day change.
    if [[ "$DAY" ]]; then
        export DAY="$(date +%A)"
    else
        local today="$(date +%A)"
        if [ "${DAY}" != "${today}" ]; then
            PS1="${PS1}\n\[${COL_GREEN}\]Day changed to $(date '+%A, %d %B %Y').\n"
            export DAY="$today"
       fi
    fi

    cdr_debug_log "promptcmd()" "user"
    # User
    if [ "${UID}" -eq 0 ] ; then
        if [ "${USER}" == "${LOGNAME}" ]; then
            if [[ "${SUDO_USER}" ]]; then
                PS1="${PS1}\[${COL_RED}\]\u"
            else
                PS1="${PS1}\[${COL_LIGHTRED}\]\u"
            fi
        else
            PS1="${PS1}\[${COL_YELLOW}\]\u"
        fi
    else
        if [ "${USER}" == "${LOGNAME}" ]; then
            PS1="${PS1}\[${COL_GREEN}\]\u"
        else
            PS1="${PS1}\[${COL_BROWN}\]\u"
        fi
    fi

    cdr_debug_log "promptcmd()" "http_proxy"
    # HTTP Proxy var configured or not
    # shellcheck disable=SC2154
    if [ -n "$http_proxy" ] ; then
        PS1="${PS1}\[${COL_GREEN}\]@"
    else
        PS1="${PS1}\[${COL_LIGHTRED}\]@"
    fi

    cdr_debug_log "promptcmd()" "host"
    # Host
    if [[ "${SSH_CLIENT}" ]] || [[ "${SSH2_CLIENT}" ]]; then
        SSH_FLAG=1
    fi
    if [ "${SSH_FLAG}" -eq 1 ]; then
       PS1="${PS1}\[${COL_CYAN}\]\h "
    elif [[ -n "${SESS_SRC}" ]]; then
        if [ "${SESS_SRC}" == "(:0.0)" ]; then
            PS1="${PS1}\[${COL_PURPLE}\]\h "
        else
            local parent_process="$(</proc/${PPID}/cmdline)"
            if [[ "$parent_process" == "in.rlogind*" ]]; then
                PS1="${PS1}\[${COL_BROWN}\]\h "
            elif [[ "$parent_process" == "in.telnetd*" ]]; then
                PS1="${PS1}\[${COL_YELLOW}\]\h "
            else
                PS1="${PS1}\[${COL_LIGHTRED}\]\h "
            fi
        fi
    elif [[ "${SESS_SRC}" == "" ]]; then
        PS1="${PS1}\[${COL_PURPLE}\]\h "
    else
        PS1="${PS1}\[${COL_RED}\]\h "
    fi

    cdr_debug_log "promptcmd()" "darling"
    # Inside a darling session
    if [[ "${CDR_FIRSTRUN}" != 1 ]]; then
        cdr_debug_log "promptcmd()" "-> looking for darling hints"
        [ -e /etc/darling/version.conf ] && CDR_DARLING="true"
    fi
    if [[ "${CDR_DARLING}" != "" ]]; then
        cdr_debug_log "promptcmd()" "-> is darling"
        PS1="${PS1}\[${COL_CYAN}\][darling] "
    fi

    cdr_debug_log "promptcmd()" "tmux"
    # Detached tmux Sessions
    local DTCHSCRN="$(tmux ls 2>/dev/null | grep -c -E "^[0-9]+:")"
    if [ "${DTCHSCRN}" -gt 2 ]; then
        PS1="${PS1}\[${COL_RED}\][tmx:${DTCHSCRN}] "
    elif [ "${DTCHSCRN}" -gt 0 ]; then
        PS1="${PS1}\[${COL_YELLOW}\][tmx:${DTCHSCRN}] "
    fi

    cdr_debug_log "promptcmd()" "machinectl"
    # Running Machinectl VMs
    local MCTLVM="No"
    if [ "${CDR_WSL}" -eq 0 ] && [ "${CDR_SYSTEM}" == "Linux" ] && command -v machinectl 2>&1 >/dev/null; then
        MCTLVM=$(machinectl list | tail -n1 | cut -d' ' -f1)
    fi
    if [ "${MCTLVM}" == "No" ]; then
        MCTLVM=0
    fi
    if [ "${MCTLVM}" -gt 0 ]; then
        PS1="${PS1}\[${COL_PINK}\][mctl:${MCTLVM}] "
    fi

    cdr_debug_log "promptcmd()" "bg"
    # Backgrounded running jobs
    local BKGJBS="$(jobs -r | wc -l)"
    if [ "${BKGJBS}" -gt 2 ]; then
        PS1="${PS1}\[${COL_RED}\][bg:${BKGJBS}]"
    elif [ "${BKGJBS}" -gt 0 ]; then
        PS1="${PS1}\[${COL_YELLOW}\][bg:${BKGJBS}] "
    fi

    cdr_debug_log "promptcmd()" "stopped jobs"
    # Stopped Jobs
    local STPJBS="$(jobs -s | wc -l)"
    if [ "${STPJBS}" -gt 2 ]; then
        PS1="${PS1}\[${COL_RED}\][stp:${STPJBS}]"
    elif [ "${STPJBS}" -gt 0 ]; then
        PS1="${PS1}\[${COL_YELLOW}\][stp:${STPJBS}] "
    fi

    cdr_debug_log "promptcmd()" "bracket open"
    # Bracket {
    if [ "${UID}" -eq 0 ]; then
        if [ "${USER}" == "${LOGNAME}" ]; then
            if [[ "${SUDO_USER}" ]]; then
                PS1="${PS1}\[${COL_RED}\]"
            else
                PS1="${PS1}\[${COL_LIGHTRED}\]"
            fi
        else
            PS1="${PS1}\[${COL_YELLOW}\]"
        fi
    else
        if [ "${USER}" == "${LOGNAME}" ]; then
            PS1="${PS1}\[${COL_GREEN}\]"
        else
            PS1="${PS1}\[${COL_BROWN}\]"
        fi
    fi

    cdr_debug_log "promptcmd()" "wd"
    # Working directory
    if [ -w "${PWD}" ]; then
        PS1="${PS1}\[${COL_GREEN}\]$(prompt_workingdir)"
    else
        PS1="${PS1}\[${COL_RED}\]$(prompt_workingdir)"
    fi

    cdr_debug_log "promptcmd()" "bracket close"
    # Closing bracket } and $\#
    if [ "${UID}" -eq 0 ]; then
        if [ "${USER}" == "${LOGNAME}" ]; then
            if [[ "${SUDO_USER}" ]]; then
                PS1="${PS1}\[${COL_RED}\]"
            else
                PS1="${PS1}\[${COL_LIGHTRED}\]"
            fi
        else
            PS1="${PS1}\[${COL_YELLOW}\]"
        fi
    else
        if [ "${USER}" == "${LOGNAME}" ]; then
            PS1="${PS1}\[${COL_GREEN}\]"
        else
            PS1="${PS1}\[${COL_BROWN}\]"
        fi
    fi
    PS1="${PS1} \$\[${COL_NORM}\] "

    CDR_FIRSTRUN=1
    cdr_debug_log "promptcmd()" "leave"
}
export -f promptcmd

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
  if [[ "${PWD}" == "${HOME}"* ]]; then
    newPWD="~${PWD#${HOME}}"
  else
    newPWD="${PWD}"
  fi
  if [ "${#newPWD}" -gt "$pwdmaxlen" ]; then
    local pwdoffset=$((${#newPWD} - ${pwdmaxlen} + 3))
    newPWD="${trunc_symbol}${newPWD:$pwdoffset:$pwdmaxlen}"
  fi
  echo "$newPWD"
}
export -f prompt_workingdir

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
    export PS1
    export PROMPT_COMMAND
}

load_prompt
