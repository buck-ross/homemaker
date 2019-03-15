# Personal .bash_aliases file

# Define some personal aliases:
if [ "$color_available" = yes ]; then
	alias dir='dir --color'
	alias vdir='vdir --color'
	alias grep='grep --color'
	alias egrep='egrep --color'
	alias fgrep='fgrep --color'
	alias ls='ls -CF -h --color'
	alias less='less -R'
else
	alias ls='ls -CF -h'
fi

alias home='cd $HOME'
alias cls='clear'
alias dd='dd status=progress'
alias dog='cat -n'
alias l='ls -la'
alias ll='ls -l'
alias la='ls -a'
alias path='echo -e ${PATH//:/\\n}'

# Define aliases for common programs:
if [ -n "$(type less 2> /dev/null)" ]; then alias more='less'; fi
if [ -n "$(type  vim 2> /dev/null)" ]; then alias vi='vim'; fi
if [ -n "$(type xterm-colorized 2> /dev/null)" ]; then alias xterm='xterm-colorized'; fi
if [ -n "$(type uxterm-colorized 2> /dev/null)" ]; then alias uxterm='uxterm-colorized'; fi
if [ -n "$(type todo.sh 2> /dev/null)" ]; then alias todo='todo.sh' && alias ltd='todo -c .todo/config'; 
elif [ -n "$(type todo-txt 2> /dev/null)" ]; then alias todo='todo-txt' && alias ltd='todo -c .todo/config'; fi
if [ -n "$(type hub 2> /dev/null)" ]; then alias git='hub'; fi
