#!/usr/bin/env bash

###############################################################################
# JFitzy1321's Linux Install script
# 
# First section:    Install packages via apt and flatpak
#
# Second Section:   Add config files to xdg locations
#
# I'm currently using Pop!_OS and apt to install packages.
# This should be compatiable with any Ubuntu Based Distro.
#
###############################################################################

# "e" will make script exit if something fails
# "x" will print out every command and its result
# set -x #e

function printsl {
    echo "" # newline
    echo "$1"
    sleep 0.5
}

#####  Check if flatpak is installed
if ! flatpak --version; then
    printsl "Flatpak is not installed, installing now"
    apt install flatpak

    printsl "Adding flathub"
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    printsl "Do you want to reboot now? y / n: "

    read answer
    if [ "$answer" == "y" ]; then sudo shutdown -r now ; fi
fi

# Need these to install ppas and setup scripts
sudo apt install apt-transport-https curl software-properties-common

######  Adding ppas  #####

## there's a problem with this ppa
#printsl "Adding deadsnakes ppa"
#sudo add-apt-repository ppa:deadsnakes/ppa -y

printsl "Add Git Core PPA for latest stable upstream of Git"
add-apt-repository ppa:git-core/ppa

printsl "Adding brave ppa"
curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

printsl "Adding nodesource ppa"
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -

#####  Update system && Install Packages  #####
printsl "Updating System"
sudo apt update && sudo apt upgrade -y

printsl "Installing apt packages"
sudo apt install -y \
    alacritty bridge-utils brave-browser build-essential \
    cheese cmake code deepin-icon-theme easytag fish \
    gdb gnome-tweaks gir1.2-gtkclutter-1.0 google-chrome-stable \
    gparted gufw lollypop make neofetch neovim nodejs preload \
    python3.8 python3.9 python3-pip python3-dev qemu-kvm \
    shellcheck sqlite3 sqlitebrowser symlinks tensorman \
    tree ttf-mscorefonts-installer ubuntu-restricted-extras ufw virt-manager

sudo adduser "$(whoami)" libvirtd

####   Enable firewall  #####
printsl "Enabling firewall"
sudo ufw enable

#####  Installing Flatpaks #####
printsl "Installing flatpaks"
flatpak install flathub \
    com.discordapp.Discord \
    com.axosoft.GitKraken \
    com.getpostman.Postman \
    com.slack.Slack \
    com.spotify.Client \
    org.processing.processingide \
    us.zoom.Zoom

#####  Remove unneed apps  ######
printsl "Apt cleanup"
sudo apt purge --auto-remove -y geary

#####  Python setup  #####
printsl "Setting up pip and pipenv"
python3.8 -m pip install -U pip
python3.8 -m pip install -U pipenv
python3.9 -m pip install -U pip
python3.9 -m pip install -U pipenv

##### Install "Diff So Fancy" #####
printsl "Installing 'diff-so-fancy' via npm"
sudo npm install -g diff-so-fancy

#####  Install Rust  #####
printsl "Installing Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

#####  Install Starship Prompt  #####
printsl "Installing 'Starship' for fish"
curl -fsSL https://starship.rs/install.sh | bash

###############################################################################
#                                                                             #
#####################################  Section 2  #############################
#                                                                             #
###############################################################################

#####  Setup  #####
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
SHARE="${XDG_DATA_HOME:-$HOME/.local/share}"
SOURCE_DIR="$HOME/Source"
NVIM_DIR="$XDG_CONFIG_HOME/nvim"
DOTFILES="$SOURCE_DIR/dotfiles"
FISH_PATH="$XDG_CONFIG_HOME/fish"
TMP="$HOME/tmp"

# create tmp folder in case something goes wrong
mkdir "$TMP"

function link {
    ln -sf $1 $2
}

# make folders
mkdir -p "$SOURCE_DIR"
mkdir -p "$SHARE/icons/"
mkdir -p "$SHARE/themes"
mkdir -p "$NVIM_DIR"

##### Download Git Repos #####
# If repo not in DOTFILES dir, reclone repo to that dir
if [ ! -d "$DOTFILES" ]; then
    printsl "Dotfiles repository not located at $DOTFILES, fixing that now"
    git clone https://github.com/JFitzy1321/dotfiles.git "$DOTFILES"
fi

# extract icons
printsl "Extracting Icon themes to $SHARE/icons"
tar -xf "$DOTFILES/icons/Zafiro-Icons-Blue.tar.gz" -C "$SHARE/icons"

#####  Creating symlinks to various file  #####
printsl "Creating symlink for alacritty.yaml"
link "$DOTFILES/alacritty.yml" "$XDG_CONFIG_HOME/."

printsl "Creating symlink for git"
link "$DOTFILES/git" "$XDG_CONFIG_HOME"

#####  Symlink From Scripts folder to bin  #####
printsl "Creating symlink for custom scripts"
[ -d "$HOME/bin" ] && mv "$HOME/bin/" "$HOME/tmp/"
link "$DOTFILES/bin" "$HOME/bin"

printsl "Creating symlink for nvim init.vim"
link "$DOTFILES/nvim/init.vim" "$NVIM_DIR/."

#####  Profile setup  #####
# move .profile and create symlink
printsl "Moving .profile to $TMP"
mv "$HOME/.profile" "$TMP/"

printsl "Creating symlink for .profile"
link "$DOTFILES/.profile" "$HOME/.profile"

#####  Bash Setup  #####
# First, move original to tmp
printsl "Moving $HOME/.bashrc to $TMP"
[ -f "$HOME/.bashrc" ] && mv "$HOME/.bashrc" "$TMP/"
[ -f "$HOME/.bash_profile" ] && mv "$HOME/.bash_profile" "$TMP"

# Second, make symlink to new bashrc location
printsl "Creating symlinks for .bashrc"
link "$DOTFILES/.bashrc" "$HOME/.bashrc"

# Move existing file to tmp folder
if [ -f "$FISH_PATH/config.fish" ]; then
    printsl "Moving $FISH_PATH/config.fish to $TMP"
    mv "$FISH_PATH/config.fish" "$TMP/."
elif [ ! -d "$FISH_PATH" ]; then
    mkdir "$FISH_PATH"
fi

printsl "Creating symlink for config.fish"
link "$DOTFILES/fish/config.fish" "$FISH_PATH/."

# Creating symlink for starship.toml
printsl "Creating symlink for starship.toml"
ln -s "$DOTFILES/starship.toml" "$XDG_CONFIG_HOME/."

#####  Make fish the default shell  #####
printsl "Setting fish as default shell"
chsh -s "$(which fish)"

