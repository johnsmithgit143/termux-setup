pkgs="git man zsh zsh-completions neofetch neovim openssh"
zplugins="https://github.com/zsh-users/zsh-autosuggestions https://github.com/zsh-users/zsh-syntax-highlighting"
dotfilesrepod="https://raw.githubusercontent.com/johnsmithgit143/termux-dotfiles/main/dotfiles"
dotfileschosen="neofetch/config.conf:$HOME/.config/neofetch/config.conf zsh/zshrc:$HOME/../usr/etc/zshrc"
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
	echo -e "$2... [ ${byellow}PENDING${nocolor} ]"
	
	if [ "$3" = "unhide" ]
	then
		$1 && returncode=0 || returncode=1
	elif [ "$3" = "unhiderr" ]
	then
		$1 >/dev/null && returncode=0 || returncode=1
	elif [ "$3" = "true" ]
	then
		$1 >/dev/null 2>&1
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

checkpkgs()
{
	for i in $pkgs
	do
		pkg list-installed | grep $i || return 1
	done
}

zpluginsdl()
{
	mkdir -p $HOME/../usr/etc/zplugins
	for i in $zplugins
	do 
		[ -d $HOME/../usr/etc/zplugins/${i##*/} ] || git clone $i $HOME/../usr/etc/zplugins/${i##*/} || return 1
	done
}

dotfilesinstall()
{
	for i in $dotfileschosen
	do
		output=${i##*:}
		mkdir -p ${output%/*}
		curl $dotfilesrepod/${i%%:*} -o $output || return 1
		sed -i -e "s/replaceusername/$username/g" ${i##*:} || return 1
		sed -i -e "s/replacehostname/$hostname/g" ${i##*:} || return 1
	done
	
	echo "color12=#0092ff" > $HOME/.termux/colors.properties || return 1
	
}

cmdmsg "ping -c 1 google.com" "Checking your net connection"

cmdmsg getuserandhost "Getting user information" unhide

cmdmsg termux-setup-storage "Setting up storage" unhide

read -p "Script will replace your dotfiles. Continue? [y/n]: " confirmation
[ "$confirmation" = "y" ] || exit 1

cmdmsg "pkg upgrade -y" "Updating existing packages" unhide

cmdmsg "pkg install -y $pkgs" "Installing required packages" unhide

cmdmsg checkpkgs "Checking if succesfully downloaded"

cmdmsg zpluginsdl "Downloading zsh plugins" unhide

cmdmsg "chsh -s zsh" "Changing shell to zsh"

cmdmsg "rm $HOME/../usr/etc/motd*" "Removing startup message" true

cmdmsg dotfilesinstall "Installing dotfiles" unhide

cmdmsg termux-reload-settings "Reloading settings"

echo "All done! No errors occured."
echo "Thank you for using my setup script."
echo "Open a new session to see the changes."