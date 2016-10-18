# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
EDITOR=nano
VISUAL=$EDITOR

# Source all include scripts
SCRIPTPATH=$HOME/.bash_include/
for script in $(ls $SCRIPTPATH | egrep '.sh$')
  do source $SCRIPTPATH$script
done
