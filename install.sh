#!/bin/bash

# Set up development directory.
read -p "Enter absolute path to dev directory [~/dev]: " dev_dir
dev_dir=${dev_dir:-~/dev}
mkdir -p $dev_dir

# Clone dotfiles repository.
[ -d $dev_dir/dotfiles ] || git clone https://github.com/nshki/dotfiles.git $dev_dir/dotfiles

# Ensure CLT for Xcode are installed.
xcode-select --install

# Install Homebrew and bundle.
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew bundle --file=$dev_dir/dotfiles/config/Brewfile

# Bash config.
[ ! -f ~/.bash_local ] && touch ~/.bash_local
rm -f ~/.bash_aliases && ln -s $dev_dir/dotfiles/config/.bash_aliases ~/.bash_aliases
rm -f ~/.bash_profile && ln -s $dev_dir/dotfiles/config/.bash_profile ~/.bash_profile
source ~/.bash_profile

# Switch default shell to Homebrew Bash.
sudo bash -c 'echo "/opt/homebrew/bin/bash" >> /etc/shells'
chsh -s /opt/homebrew/bin/bash

# tmux and tpm config.
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
rm -f ~/.tmux.conf && ln -s $dev_dir/dotfiles/config/.tmux.conf ~/.tmux.conf
rm -f ~/.tmuxline && ln -s $dev_dir/dotfiles/config/.tmuxline ~/.tmuxline

# Programming languages.
curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh
nodenv install 16.14.0
nodenv global 16.14.0
pyenv install 3.10.5
pyenv global 3.10.5
CFLAGS="-Wno-error=implicit-function-declaration" rbenv install 3.1.2
rbenv global 3.1.2

# Install LunarVim.
bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)

# # Install kitty.
# curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
# git clone --depth 1 https://github.com/dexpota/kitty-themes.git ~/.config/kitty/kitty-themes
# rm -f ~/.config/kitty/theme.conf && ln -s ~/.config/kitty/kitty-themes/themes/OneDark.conf ~/.config/kitty/theme.conf
# rm -f ~/.config/kitty/kitty.conf && ln -s $dev_dir/dotfiles/config/kitty.conf ~/.config/kitty/kitty.conf

# Setup Git.
read -p "Enter Git name: " git_name
read -p "Enter Git email: " git_email
git config --global user.name "$git_name"
git config --global user.email $git_email
git config --global core.editor lvim

# Setup SSH key with GitHub.
#
# Ref: https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
if [ ! -f ~/.ssh/id_rsa ]; then
  read -p "Enter GitHub email address: " github_email
  ssh-keygen -t rsa -b 4096 -C $github_email
fi
eval "$(ssh-agent -s)"
cp $dev_dir/dotfiles/config/sshconfig ~/.ssh/config
ssh-add -K ~/.ssh/id_rsa
pbcopy < ~/.ssh/id_rsa.pub
read -p "SSH key copied to clipboard. Add to GitHub (https://github.com/settings/keys). Press enter when done."


echo "Setting some Mac settings..."

#"Setting screenshots location to ~/Pictures/Screenshots"
mkdir $HOME/Pictures/Screenshots
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"

#"Setting screenshot format to JPG"
defaults write com.apple.screencapture type -string "jpg"
#"Disable Google Chrome Guest User"
defaults write com.google.Chrome BrowserGuestModeEnabled -bool false 

#"Setting Dock to auto-hide and removing the auto-hiding delay"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0

#"Speeding up Mission Control animations and grouping windows by application"
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock "expose-group-by-app" -bool true

#"Setting the icon size of Dock items to 36 pixels for optimal size/screen-realestate"
defaults write com.apple.dock tilesize -int 30

#"Setting Dock to auto-hide and removing the auto-hiding delay"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0

#"Allow text selection in Quick Look"
defaults write com.apple.finder QLEnableTextSelection -bool TRUE

#"Expanding the save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

#"Automatically quit printer app once the print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

#"Enabling full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

#"Setting trackpad & mouse speed to a reasonable number"
defaults write -g com.apple.trackpad.scaling 6
defaults write -g com.apple.mouse.scaling 6

#"Showing all filename extensions in Finder by default"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

#"Don't prompt for confirmation before downloading"
defaults write org.m0k.transmission DownloadAsk -bool false


killall Finder


echo "Done!"