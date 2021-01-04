#!/usr/bin/env bash

function printsl() {
    echo "" # newline
    echo "$1"
    sleep 0.5
}

#####  Setup  #####
printsl "JFitzy's Pop!_OS setup script!!"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
SHARE="${XDG_DATA_HOME:-$HOME/.local/share}"
DOTFILES="$XDG_CONFIG_HOME/dotfiles"
TMP="$HOME/tmp"
# create tmp folder in case something goes wrong
mkdir "$TMP"


##### Download Git Repos #####
# If repo not in DOTFILES dir, reclone repo to that dir
if [ ! -d "$DOTFILES" ]; then
    printsl "Dotfiles repository not located at $DOTFILES, fixing that now"
    cd "$XDG_CONFIG_HOME" && git clone https://github.com/JFitzy1321/dotfiles.git
fi


SOURCE_DIR="$HOME/Source"
[ ! -d "$SOURCE_DIR" ] && mkdir "$SOURCE_DIR" 

#####  Moving Icons to appropriate folder
printsl "Setting up icons and themes folders."

# make icons and theme folders
[ ! -d "$SHARE/icons" ] && mkdir "$SHARE/icons/"
[ ! -d "$SHARE/themes" ] && mkdir "$SHARE/themes"

# extract icons
printsl "Extracting Icon themes to $SHARE/icons"
tar -xf "$DOTFILES/icons/Zafiro-Icons-Blue.tar.gz" -C "$SHARE/icons"

#####  Symlink to Git Config  #####
printsl "Creating symlink for git"
[ ! -d "$XDG_CONFIG_HOME/git" ] && mkdir "$XDG_CONFIG_HOME/git"
ln -s -f "$DOTFILES/config/git/config" "$XDG_CONFIG_HOME/git/."
# ln -s -f "$DOTFILES/config/git/aliasrc" "$XDG_CONFIG_HOME/git/." 

#####  Symlink From Scripts folder to bin  #####
printsl "Creating symlink for custom scripts"
[ -d "$HOME/bin" ] && mv "$HOME/bin/" "$HOME/tmp/"
ln -s -f "$DOTFILES/scripts" "$HOME/bin"

#####  Symlink for NeoVim  #####
printsl "Creating symlink for nvim init.vim"
[ ! -d "$XDG_CONFIG_HOME/nvim" ] && mkdir "$XDG_CONFIG_HOME/nvim"
ln -s -f "$DOTFILES/config/nvim/init.vim" "$XDG_CONFIG_HOME/nvim/."

#####  Profile setup  #####
# move .profile and create symlink
printsl "Moving .profile to $TMP"
mv "$HOME/.profile" "$TMP/"

printsl "Creating symlink for .profile"
ln -s -f "$DOTFILES/config/profile" "$HOME/.profile"

#####  Bash Setup  #####
# First, move original to tmp
printsl "Moving $HOME/.bashrc to $TMP"
[ -f "$HOME/.bashrc" ] && mv "$HOME/.bashrc" "$TMP/"

# Second, make symlink to new bashrc location
BASH_PATH="$XDG_CONFIG_HOME/bash"
printsl "Creating symlinks for bashrc to $XDG_CONFIG_HOME/bashrc"
[ ! -d "$BASH_PATH" ] && mkdir "$BASH_PATH"
ln -s -f "$DOTFILES/bash/bashrc" "$BASH_PATH/bashrc"
ln -s -f "$DOTFILES/aliasrc" "$XDG_CONFIG_HOME/aliasrc"

# Third, replace old /etc/bash.bashrc
printsl "Creating a copy of /etc/bash.bashrc in $TMP"
cp /etc/bash.bashrc "$TMP/etc.bash.bashrc"

printsl "Appending /etc/bash.bashrc"
sudo cp -f "$BASH_PATH/etc.bash.bashrc" /etc/bash.bashrc

# ##### Misc #####
# printsl "Symlink for tmux"
# ln -s "$DOTFILES/tmux.conf" "$HOME/.tmux.conf"

##### Fish and Starship Setup  #####
FISH_PATH="$XDG_CONFIG_HOME/fish"

# Move existing file to tmp folder
if [ -f "$FISH_PATH/config.fish" ]; then
    printsl "Moving $FISH_PATH/config.fish to $TMP"
    mv "$FISH_PATH/config.fish" "$TMP"
elif [ ! -d "$FISH_PATH" ]; then
    mkdir "$FISH_PATH"
fi

printsl "Creating symlink for config.fish"
ln -s -f "$DOTFILES/fish/config.fish" "$FISH_PATH/."
ln -s -f "$DOTFILES/fish/fish_variables" "$FISH_PATH/."

printsl "Creating symlinks for fish functions"
[ ! -d "$FISH_PATH/functions" ] && mkdir "$FISH_PATH/functions"
for file in "$DOTFILES/fish/functions"/*
do
    ln -sf "$file" "$FISH_PATH/functions/."
done


printsl "Installing 'Starship' for fish"
curl -fsSL https://starship.rs/install.sh | bash

# Creating symlink for starship.toml
printsl "Creating symlink for starship.toml"
ln -s "$DOTFILES/config/starship.toml" "$XDG_CONFIG_HOME/."

printsl "Setting fish as default shell"
chsh -s "$(which fish)"

#####  Setup Fish for use in other user's terminals
sudo chmod 775 ~/.config/fish
sudo chmod 666 ~/.config/fish/fish_variables

#####  Alacritty  #####
printsl "Creating symlink for alacritty.yaml"
ALACRITTY_PATH="$XDG_CONFIG_HOME/alacritty"
[ ! -d "$ALACRITTY_PATH" ] && mkdir "$ALACRITTY_PATH"
ln -s "$DOTFILES/config/alacritty.yml" "$ALACRITTY_PATH/.alacritty.yml"
