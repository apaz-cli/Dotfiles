# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Ignore duplicates in the history, and also lines starting with space.
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=1000000

shopt -s histappend checkwinsize globstar extglob

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias grep='grep --color=auto'
    alias venv='source _venv'
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
export PATH="/home/$USER/git/Scripts:/home/$USER/Scripts:$PATH:/home/$USER/.local/bin"
export PATH="$PATH:/usr/bin/go/bin"

# Add rust to path if installed
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

# Add local nvim to path if installed
if [ -d "$HOME/.neovim/bin" ]; then
  PATH="$HOME/.neovim/bin:$PATH"
fi

# Add conda to path if installed
if [ -d "$HOME/.miniconda.d/bin" ]; then
  PATH="$PATH:$HOME/.miniconda.d/bin"
elif [ -d "$HOME/.miniconda/bin" ]; then
  PATH="$PATH:$HOME/.miniconda/bin"
elif [ -d "$HOME/miniconda/bin" ]; then
  PATH="$PATH:$HOME/miniconda/bin"
fi

# Add CUDA to path if installed
if [ -d "/usr/local/cuda" ]; then
  PATH="/usr/local/cuda/bin:$PATH"
  LD_LIBRARY_PATH="/usr/local/cuda/lib64:/usr/local/cuda/lib:$LD_LIBRARY_PATH"
fi


# Add function to source thunder script
function thunder() {
  if [ -f "$HOME/Scripts/thunder" ]; then
    source "$HOME/Scripts/thunder"
  elif [ -f "$HOME/git/Scripts/thunder" ]; then
    source "$HOME/git/Scripts/thunder"
  fi
}

# Fix ssh into machines without xterm-kitty termcap.
if [ "$TERM" = "xterm" ]; then
  TERM="xterm-256color"
elif [ "$TERM" = "xterm-kitty" ]; then
  if [ ! "$HOSTNAME" = "$USER-laptop" ] && [ ! "$HOSTNAME" = "$USER-desktop" ]; then
    TERM="xterm-256color"
  fi
fi

# Automatically activate my conda environment on hyperplane.
# Don't do so on laptop/desktop.
HOST="$(hostname)"
if [ "$HOST" = "hyperplane1" ]; then
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/apaz/.miniconda.d/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/apaz/.miniconda.d/etc/profile.d/conda.sh" ]; then
        . "/home/apaz/.miniconda.d/etc/profile.d/conda.sh"
    else
        export PATH="/home/apaz/.miniconda.d/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
fi

__host_name() {
  local status="$?"
  if [ "$HOSTNAME" != "$USER-laptop" ] && [ "$HOSTNAME" != "$USER-desktop" ]; then printf "@$HOSTNAME"; fi
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
  local mnt="$(findmnt -T. | tail -n 1 | awk '{print $1}')"
  local freegb="$(df -PBG $mnt | awk 'NR==2 {print $4}' | sed 's/G//')"
  if test $freegb -ge 5; then
    printf "\033[32m"
  else
    printf "\033[31m"
  fi
}

PS1="\
\[\033[32m\]\u\$(__host_name)\
\[\033[94m\][\
\[\$(if test \$? -eq 0; then printf '\033[32m'; else printf '\033[31m'; fi)\]x\
\[\033[94m\]][\
\[\$(__git_color)\]\
\$(__git_print)\
\[\033[94m\]][\
\[\$(__disk_color)\]\w\
\[\033[94m\]]\$\
\[\033[00m\] \
"

