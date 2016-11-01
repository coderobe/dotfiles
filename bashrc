# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source all include scripts
SCRIPTPATH=$HOME/Documents/Dotfiles/bash_include/
for script in $(ls $SCRIPTPATH | egrep '.sh$')
  do source $SCRIPTPATH$script
done

# Evaluate all execute scripts
CDR_EXECPATH=$HOME/Documents/Dotfiles/bash_execute/
for script in $(ls $CDR_EXECPATH | egrep '.sh$')
  do eval $CDR_EXECPATH$script
done
