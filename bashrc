# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Set up ssh keychain
eval $(keychain --noask --systemd --eval -q)

# Source all include scripts
SCRIPTPATH=$HOME/Documents/Dotfiles/bash_include/
for script in $(ls $SCRIPTPATH | egrep '.sh$')
  do source $SCRIPTPATH$script
done
