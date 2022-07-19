. /data/data/com.termux/files/usr/etc/profile
command_not_found_handler() {
	/data/data/com.termux/files/usr/libexec/termux/command-not-found $1
}
#set nomatch so *.sh would not error if no file is available
setopt +o nomatch
. /data/data/com.termux/files/usr/etc/profile

autoload -U colors && colors
PS1="%B%{$fg[red]%}[%{$fg[cyan]%}jack%{$fg[yellow]%}@%{$fg[green]%}android %{$fg[magenta]%}%c%{$fg[red]%}]%{$reset_color%}$%b "

autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit -d ~/.cache/zcompdump
_comp_options+=(globdots)

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=/data/data/com.termux/files/home/.zhistory

export LESSHISTFILE=-

alias \
	cp="cp -iv" \
	mv="mv -iv" \
	rm="rm -vI" \
	ls="ls -A --color=auto --group-directories-first" \
	grep="grep --color=auto" \
	diff="diff --color=auto" \

cd() { builtin cd $@ && ls ; }
cx() { file1=$1 ; file2=${file1%%.*} ; cat ~/storage/shared/Acode/$file1 > $file1 && clang -o $file2 $file1 && chmod +x $file2 && shift && ./$file2 $@ ; }
sx() { file=$1 ; cat ~/storage/shared/Acode/$file > $file && chmod +x $file && shift && ./$file $@ ; }
lsc() { ls ~/storage/shared/Acode ; }

source /data/data/com.termux/files/usr/etc/zplugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /data/data/com.termux/files/usr/etc/zplugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

neofetch
