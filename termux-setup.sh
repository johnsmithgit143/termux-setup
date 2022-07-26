pkgs="git man manpages zsh zsh-completions neofetch neovim openssh clang binutils golang tmux openssl-tool"
zplugins="https://github.com/zsh-users/zsh-autosuggestions https://github.com/zsh-users/zsh-syntax-highlighting"
dotfilesrepodir="https://raw.githubusercontent.com/johnsmithgit143/termux-dotfiles/main/dotfiles"
dotfileschosen="neofetch/config.conf:$HOME/.config/neofetch/config.conf zsh/zshrc:$PREFIX/etc/zshrc"
termuxloginrepo="https://raw.githubusercontent.com/johnsmithgit143/termux-login/main/termux-login.c"

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
	mkdir -p $PREFIX/etc/zplugins
	for i in $zplugins
	do 
		[ -d $PREFIX/etc/zplugins/${i##*/} ] && cd $PREFIX/etc/zplugins/${i##*/} && git pull || git clone $i $PREFIX/etc/zplugins/${i##*/} || return 1
	done
}

dotfilesinstall()
{
	for i in $dotfileschosen
	do
		output=${i##*:}
		mkdir -p ${output%/*}
		curl $dotfilesrepodir/${i%%:*} -o $output || return 1
		sed -i -e "s/replaceusername/$username/g" ${i##*:} || return 1
		sed -i -e "s/replacehostname/$hostname/g" ${i##*:} || return 1
	done
	
	echo "color12=#0092ff" > $HOME/.termux/colors.properties || return 1
	
}

termuxlogininstall()
{
	file1=${termuxloginrepo##*/}
	file2=${file1%%.*}
	curl $termuxloginrepo -o $HOME/$file1 || return 1
	clang -Weverything -o $HOME/$file2 $HOME/$file1 && rm $HOME/$file1 && chmod +x $HOME/$file2 && mv $HOME/$file2 $PREFIX/bin/ || return 1;
}

echo -e "termux-setup.sh by johnsmithgit143\n"

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

cmdmsg "rm $PREFIX/etc/motd*" "Removing startup message" true

cmdmsg dotfilesinstall "Installing dotfiles" unhide

cmdmsg termuxlogininstall "Installing termux-login" unhide

cmdmsg termux-reload-settings "Reloading settings"

echo "All done! No errors occured."
echo "Thank you for using my setup script."
echo "Open a new session to see the changes."
