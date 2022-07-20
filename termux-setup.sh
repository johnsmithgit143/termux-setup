pkgs="git man zsh zsh-completions neofetch"
zplugins="https://github.com/zsh-users/zsh-autosuggestions https://github.com/zsh-users/zsh-syntax-highlighting"
setuprepo="https://github.com/johnsmithgit143/termux-setup"
scriptd=$(dirname $(readlink -f "$0"))

nocolor='\033[0m'
whitebg='\033[47m'
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'

getuserandhost()
{
	unset username hostname repeat
	while [ -z "$username" ] || [ -z "$hostname" ]
	do
		echo "Username and Hostname must not be empty."
		read -p "Enter Username: " username
		read -p "Enter Hostname: " hostname
		read -p "Is this correct? $username@$hostname [y/n]: " repeat
		[ "$repeat" = "y" ] || unset username hostname repeat
	done
}

cmdmsg()
{
	echo "$2... [ PENDING ]"
	if $1 >/dev/null 2>&1
	then
		echo "$2... [ OK ]"
	else
		echo "$2... [ ERROR ]"
		exit 1
	fi
}

zpluginsdl()
{
	[ -d $HOME/../usr/etc/zplugins ] || mkdir $HOME/../usr/etc/zplugins
	for i in $zplugins
	do 
		[ -d $HOME/../usr/etc/zplugins/${i##*/} ] || git clone $i $HOME/../usr/etc/zplugins/${i##*/}
	done
}

dotfilesdl()
{
	[ -f $HOME/../usr/etc/zshrc ] && rm $HOME/../usr/etc/zshrc
	cp $scriptd/dotfiles/zsh/zshrc $HOME/../usr/etc/ || return 1
	sed -i -e "s/jack/$username/g" $HOME/../usr/etc/zshrc || return 1
	sed -i -e "s/android/$hostname/g" $HOME/../usr/etc/zshrc || return 1
	mkdir -p $HOME/.config/neofetch/
	[ -f $HOME/.config/neofetch/config.conf ] && rm $HOME/.config/neofetch/config.conf
	cp $scriptd/dotfiles/neofetch/config.conf $HOME/.config/neofetch/ || return 1
	sed -i -e "s/jack/$username/g" $HOME/.config/neofetch/config.conf || return 1
	sed -i -e "s/android/$hostname/g" $HOME/.config/neofetch/config.conf || return 1
	echo "color12=#6495ed" > $HOME/.termux/colors.properties
}

finalize()
{
	termux-reload-settings
}

echo "Setting up storage... [ PENDING ]"
if termux-setup-storage
then
	echo "Setting up storage... [ OK ]"
else
	echo "Setting up storage... [ ERROR ]"
	exit 1
fi

cmdmsg "ping -c 1 google.com" "Checking if you have an internet connection"

getuserandhost

read -p "Script will delete all your previous configs. The rest requires no user input [y/n]: " confirmation
[ "$confirmation" = "y" ] || exit 1

cmdmsg "pkg upgrade --yes" "Updating every package"

cmdmsg "pkg install --yes $pkgs" "Installing required packages"

cmdmsg "zpluginsdl" "Downloading zsh plugins"

cmdmsg "chsh -s zsh" "Changing shell to zsh"

echo "Removing start up message... [ PENDING ]"
[ -f $HOME/../usr/etc/motd ] && rm $HOME/../usr/etc/motd
echo "Removing start up message... [ OK ]"

cmdmsg dotfilesdl "Installing dotfiles"

cmdmsg finalize "Finishing up"
echo "All Done! Please restart Termux by typing exit and opening Termux again."