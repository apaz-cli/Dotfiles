# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# sh Options
shopt -s histappend
shopt -s checkwinsize
shopt -s globstar
shopt -s checkwinsize

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias grep='grep --color=auto'
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

HOSTNAME="$(cat /etc/hostname)";
export EDITOR="/bin/nano"
export PATH="/home/$USER/git/system/Scripts:$PATH:/home/$USER/.local/bin"

# Add rust to path if installed
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

# Fix ssh into machines without xterm-kitty termcap.
if [ "$TERM" = "xterm" ]; then
  TERM="xterm-256color"
elif [ "$TERM" = "xterm-kitty" ]; then
  if [ ! "$HOSTNAME" = "$USER-laptop" ]; then
    TERM="xterm-256color"
  fi
fi

case "$TERM" in
xterm*|rxvt*|screen)
    GREENISH="\[\033[32m\]"
    BLUISH="\[\033[94m\]"
    CYANISH="\[\033[96m\]"
    RESET="\[\033[00m\]"
    ;;
*)
    ;;
esac

__host_name() {
  local status="$?"
  if [ ! "$HOSTNAME" = "$USER-laptop" ]; then printf "@$HOSTNAME"; fi
  return $status
}

__git_color() {
  local gb="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)";
  if [ -n "$gb" ]; then
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
      printf "\033[31m"
    else
      printf "\033[32m"
    fi
  else
    printf "\033[32m"
  fi
}

__git_print() {
  local gb="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)";
  if [ -n "$gb" ]; then
      printf "$gb"
  else
    local nrepos="$(find . -maxdepth 2 -name .git -type d | wc -l)";
    if [ $nrepos -eq '0' ]; then
      printf "-"
    else
      printf "$nrepos"
    fi
  fi
}

__disk_color() {
  local freegb="$(df -PBG / | awk 'NR==2 {print $4}' | sed 's/G//')"
  if test $freegb -ge 5; then
    printf "\033[32m"
  else
    printf "\033[31m"
  fi
}

PS1="\
$GREENISH\u\$(__host_name)\
$BLUISH[\
\[\$(if test \$? -eq 0; then echo '\033[32m'; else echo '\033[31m'; fi)\]x\
$BLUISH][\
\[\$(__git_color)\]\
\$(__git_print)\
$BLUISH][\
\$(__disk_color)\]\w\
$BLUISH]\$\
$RESET \
"

