pkgs="git man zsh zsh-completions neofetch"
zplugins="https://github.com/zsh-users/zsh-autosuggestions https://github.com/zsh-users/zsh-syntax-highlighting"
scriptd=$(dirname $(readlink -f "$0"))

nocolor='\033[0m'
bred='\033[1;31m'
bgreen='\033[1;32m'
byellow='\033[1;33m'
bpurple='\033[1;35m'
bcyan='\033[1;36m'

getuserandhost()
{
	unset username hostname repeat
	while [ -z "$username" ] || [ -z "$hostname" ]
	do
		echo "Username and Hostname must not be empty."
		read -p "Enter Username: " username
		read -p "Enter Hostname: " hostname
		echo -e "Your prompt will look like this:"
		echo -e "${bred}[${bcyan}$username${byellow}@${bgreen}$hostname${bpurple} exampledirectory${bred}]${nocolor}$ examplecommand"
		read -p "Is this correct? [y/n]: " repeat
		[ "$repeat" = "y" ] || unset username hostname repeat
	done
}

cmdmsg()
{
	unset returncode
	echo -e "$2... [ ${byellow}PENDING${nocolor} ]"
	
	if [ "$3" = "unhide" ]
	then
		$1 && returncode=0 || returncode=1
	elif [ "$3" = "true" ]
	then
		$1
		returncode=0
	else
		$1 >/dev/null 2>&1 && returncode=0 || returncode=1
	fi
	
	if [ "$returncode" = "0" ]
	then
		echo -e "$2... [ ${bgreen}OK${nocolor} ]"
	else
		echo -e "$2... [ ${bred}ERROR${nocolor} ]"
		exit 1
	fi
}

zpluginsdl()
{
	[ -d $HOME/../usr/etc/zplugins ] || mkdir $HOME/../usr/etc/zplugins
	for i in $zplugins
	do 
		[ -d $HOME/../usr/etc/zplugins/${i##*/} ] || git clone $i $HOME/../usr/etc/zplugins/${i##*/} || return 1
	done
}

dotfilesinstall()
{
	echo "i am reworking this"
	exit 1
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

cmdmsg "ping -c 1 google.com" "Checking if you have an internet connection"

cmdmsg getuserandhost "Getting user information" unhide

cmdmsg termux-setup-storage "Setting up storage" unhide

read -p "Script will delete all your previous configs. The rest requires no user input. Do you proceed? [y/n]: " confirmation
[ "$confirmation" = "y" ] || exit 1

cmdmsg "pkg upgrade --yes" "Updating every package"

cmdmsg "pkg install --yes $pkgs" "Installing required packages"

cmdmsg "zpluginsdl" "Downloading zsh plugins"

cmdmsg "chsh -s zsh" "Changing shell to zsh"

[ -f $HOME/../usr/etc/motd ] && cmdmsg "rm $HOME/../usr/etc/motd" "Removing startup message" 

cmdmsg dotfilesinstall "Installing dotfiles" unhide

cmdmsg finalize "Finishing up"
echo "All Done! Please restart Termux by typing exit and opening Termux again."