# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

#############################
## BASH CONFIG AND ALIASES ##
#############################

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

shopt -s checkwinsize globstar extglob
# shopt -s histappend

HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=1000000

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


##################
## $PATH CONFIG ##
##################

HOSTNAME="$(hostname)";
export EDITOR="/bin/nano"
export PATH="$PATH:/home/$USER/.local/bin:/usr/bin/go/bin"

# Add rust to path if installed
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

# Add rust to path if installed.
# Rust wants to manage uv, but don't let it.
if [ -d "/$HOME/.cargo/bin" ]; then
  export PATH="$PATH:$HOME/.cargo/bin"
fi

# Add nvim to path if installed
if [ -d "$HOME/.neovim/bin" ]; then
  export PATH="$HOME/.neovim/bin:$PATH"
fi

# Add spicetify if installed. No idea why they decided to do it like this.
if [ -f "$HOME/.spicetify" ]; then
  export PATH=$PATH:/home/apaz/.spicetify
fi

# Add conda to path if installed
# TODO: Reinstall conda on hyperplane and clean up.
if [ -d "$HOME/.miniconda.d/bin" ]; then
  export PATH="$PATH:$HOME/.miniconda.d/bin"
elif [ -d "$HOME/.miniconda/bin" ]; then
  export PATH="$PATH:$HOME/.miniconda/bin"
elif [ -d "$HOME/miniconda/bin" ]; then
  export PATH="$PATH:$HOME/miniconda/bin"
fi

# Add CUDA to path if installed
if [ -d "/usr/local/cuda" ]; then
  export PATH="/usr/local/cuda/bin:$PATH"
  if [ "$LD_LIBRARY_PATH" = "" ]; then
    export LD_LIBRARY_PATH="/usr/local/cuda/lib64:/usr/local/cuda/lib"
  else
    export LD_LIBRARY_PATH="/usr/local/cuda/lib64:/usr/local/cuda/lib:$LD_LIBRARY_PATH"
  fi
fi

# Add Scripts repo to path if installed
if [ -d "$HOME/git/Scripts" ]; then
  export SCRIPTS_DIR="$HOME/git/Scripts"
  export PATH="$SCRIPTS_DIR:$PATH"
elif [ -d "$HOME/Scripts" ]; then
  export SCRIPTS_DIR="$HOME/Scripts"
  export PATH="$SCRIPTS_DIR:$PATH"
fi

# Add Secrets repo in the same manner
if [ -d "$HOME/git/Secrets" ]; then
  export SECRETS_DIR="$HOME/git/Secrets"
  export PATH="$SECRETS_DIR:$PATH"
elif [ -d "$HOME/Secrets" ]; then
  export SECRETS_DIR="$HOME/Secrets"
  export PATH="$SECRETS_DIR:$PATH"
fi

# Find git folder.
if [ ! "$SCRIPTS_DIR" = "" ]; then
  export REPOS_DIR="$(dirname "$SCRIPTS_DIR")"
fi

# Find secrets repo. Source all the API keys.
if [ ! "$SECRETS_DIR" = "" ]; then
  for __env_file in "$REPOS_DIR"/Secrets/env_vars/*; do
    if [ -f "$__env_file" ]; then
      . "$__env_file"
    fi
  done
  unset __env_file
fi

# Add function to source thunder script
function thunder() {
  if [ -f "$SCRIPTS_DIR/thunder" ]; then
    source "$SCRIPTS_DIR/thunder"
  else
    echo "thunder script not found."
  fi
}

# Fix ssh into machines without xterm-kitty termcap.
if [ "$TERM" = "xterm" ]; then
  export TERM="xterm-256color"
elif [ "$TERM" = "xterm-kitty" ]; then
  if [ ! "$HOSTNAME" = "$USER-laptop" ] && [ ! "$HOSTNAME" = "$USER-desktop" ]; then
    export TERM="xterm-256color"
  fi
fi

# Automatically activate my conda environment on hyperplane.
# Don't do so on laptop/desktop.

if [ "$HOSTNAME" = "hyperplane1" ]; then
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

################
## PS1 CONFIG ##
################

# Print @hostname if on a different machine. Otherwise, don't.
__host_name() {
  local status="$?"
  if [ "$HOSTNAME" != "$USER-laptop" ] && [ "$HOSTNAME" != "$USER-desktop" ]; then printf "@$HOSTNAME"; fi
  return $status
}

# Print the red color escape code if there working directory
# is a git repo and there aer unstaged changes, green otherwise.
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

# Print the name of the current git branch if the working directory is a git repo.
# Otherwise, if the working directory contains git repos, print the repo count.
# Otherwise, print "-".
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

# If there's less than 5GB of space remaining on disk, print
# the color escape code for red. Otherwise, print the code for green.
__disk_color() {
  # TODO: There is a bug here. If the mount dir has a space in
  # it, then awk will return only the first part of the path.
  local mnt="$(findmnt -T"$HOME" | tail -n 1 | awk '{print $1}')"
  local freegb="$(df -PBG $mnt | awk 'NR==2 {print $4}' | sed 's/G//')"
  if test $freegb -ge 5; then
    printf "\033[32m"
  else
    printf "\033[31m"
  fi
}

# Combine all of the above into a prompt.
# It looks like:
#
# username@__host_name[x][__git_print][~/$PWD]$ echo "Hello World!"
#
# Where the x in the first box is green if the previous command succeeded, and red if it failed.
# See the comments above to understand how the other box contents are colored.

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

