# Personal .bashrc file

# If not running interactively, do nothing:
case $- in *i*) ;; *) return;; esac

# Detect if inside a detectable chroot environment:
if [ -n "$chroot" ]; then
	echo > /dev/null
elif [ -r /etc/chroot ]; then
	chroot=$(cat /etc/chroot)
elif [ -n "$debian_chroot" ]; then
	chroot=$debian_chroot
elif [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
	chroot=$debian_chroot
fi

# Determine whether or not color is supported:
if [ -n "$(type tput 2> /dev/null)" ] && tput setaf 1 > /dev/null; then
	color_available=yes
fi

if [ -n "$(type dircolors 2> /dev/null)" ] && [ -r ~/.dircolors ]; then
	eval "$(dircolors -b ~/.dircolors)"
elif [ -n "$(type dircolors 2> /dev/null)" ]; then
	eval "$(dircolors -b)"
fi

# Add relevent local directories to the PATH:
if [ -d ~/.local ] && [ -d ~/.local/bin ] && [ -z $(echo $PATH | grep $HOME/.local/bin) ]; then
	export PATH=$HOME/.local/bin:$PATH
fi
if [ -d  ~/bin ] && [ -z $(echo $PATH | grep $HOME/bin) ]; then
	export PATH=$HOME/bin:$PATH
fi

# Load external aliases file, if applicable:
if [ -f ~/.bash_aliases ]; then
	source ~/.bash_aliases
fi

# Load external bash functions:
if [ -f ~/.bash_methods ]; then
	source ~/.bash_methods
fi

# Set shell options:
if [ -n "$(shopt | grep '^checkjobs\s')" ]; then shopt -s checkjobs; fi
if [ -n "$(shopt | grep '^checkwinsize\s')" ]; then shopt -s checkwinsize; fi
if [ -n "$(shopt | grep '^extglob\s')" ]; then shopt -s extglob; fi
if [ -n "$(shopt | grep '^cdspell\s')" ]; then shopt -s cdspell; fi
if [ -n "$(shopt | grep '^dirspell\s')" ]; then shopt -s dirspell; fi
if [ -n "$(shopt | grep '^dotglob\s')" ]; then shopt -s dotglob; fi
if [ -n "$(shopt | grep '^globasciiranges\s')" ]; then shopt -s globasciiranges; fi
if [ -n "$(shopt | grep '^globstar\s')" ]; then shopt -s globstar; fi
if [ -n "$(shopt | grep '^mailwarn\s')" ]; then shopt -s mailwarn; fi
if [ -n "$(shopt | grep '^shift_verbose\s')" ]; then shopt -s shift_verbose; fi
if [ -n "$(shopt | grep '^xpg_echo\s')" ]; then shopt -s xpg_echo; fi

# Configure env-modules:
if [ -f /etc/modules/init/sh ] && [ -z "$(type module 2> /dev/null)" ]; then
	source /etc/modules/init/sh
fi

# Configure NVM:
if [ -n "$(type nvm 2>/dev/null)" ]; then
	echo > /dev/null
elif [ -f /usr/share/nvm/init-nvm.sh ]; then
	source /usr/share/nvm/init-nvm.sh
elif [ -f ~/.nvm/init-nvm.sh ]; then
	source ~/.nvm/init-nvm.sh
fi

# Make less more firendly for non-text input files:
if [ "$color_available" != yes ] || [ -z "$(type less 2> /dev/null)" ]; then
	echo > /dev/null
elif [ -n "$(type pygmentize 2> /dev/null)" ]; then
	export LESSOPEN="|pygmentize -g %s"
elif [ -n  "$(type lesspipe 2> /dev/null)" ]; then
	export LESSOPEN="|lesspipe %s"
fi

# Define personal exports:
export EDITOR='vim'
export PAGER='less'

# Set some control values for bash history:
HISTCONTROL=ignoredups:ignorespace
HISTSIZE=20
HISTFILESIZE=20

# Set the default prompt:
if [ "$color_available" = yes ]; then
	export PS1="\[\e[2m\](\d \t)\[\e[22m\] [\[\e[1;32m\]\u@\h${chroot:+ (\[\e[5m\]$chroot\[\e[25m\])} \[\e[0m\]\w]$: "
else
	export PS1="(\d \t) [\u@\h${chroot:+ ($chroot)} \w]$: "
fi

# Set the umask value:
umask 077

# Define the user greeting:
if [ -n "$(type screenfetch 2> /dev/null)" ]; then screenfetch; fi
if [ -n "$(type fortune 2> /dev/null)" ]; then echo && fortune -ae; fi
if [ -n "$(type todo 2> /dev/null)" ]; then echo && todo list; fi
if [ -n "$(type figlet 2> /dev/null)" ]; then figlet -w $COLUMNS "<< $(hostname | tr a-z A-Z) >>"; fi
echo "Illegitimi Non Carborundum"; echo

# Unset internal variables:
unset color_available

# vim: set ts=4 sw=4 tw=0 noet :

