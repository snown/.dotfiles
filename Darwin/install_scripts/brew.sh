#!/bin/sh

# Install homebrew if it isn't already installed
if ! hash brew 2> /dev/null; then
  echo "Installing Homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Use latest package definitions
echo "Performing brew update..."
brew update

# Upgrade old packages (if any)
echo "Performing \`brew upgrade --all\`..."
brew upgrade

# Install Custom Taps
echo "Tapping kegs..."
brew tap thoughtbot/formulae
brew tap homebrew/versions
brew tap caskroom/versions
brew tap caskroom/fonts

# Install essential homebrews
echo "Pouring brews..."
brews=(
	python
	ruby
	ssh-copy-id
	the_silver_searcher
	tree
	wget
	pandoc
	rhash
	multimarkdown
	objc-run
	tmux
	xcproj
	unrar
	mas
	bash-completion
	git
	pacapt
	coreutils
  spoof-mac
  macosvpn
  hh
	
	# Commenting Node out right now because there is a better way to do it with version switching
	#node
)
brew install ${brews[@]}


# Install essential casks
echo "Filling casks..."
brew install caskroom/cask/brew-cask

casks=(
	dropbox
	google-chrome
	mplayerx
	the-unarchiver
	torbrowser
	trim-enabler
	atom
	gpgtools
	inkscape
	keka
	lingon-x
	macid
	sequel-pro
	slack
	textmate
	tower
	virtualbox
	unrarx
	colorpicker-developer
	colorpicker-hex
	moom
	sourcetree
	webstorm-eap
  fastlane
)
brew cask install ${casks[@]}

echo "Installing from Mac App Store"
brew install mas
macapps=(
	443987910 # 1Password
	413965349 # Soulver
	412797403 # CocoaColor
	403388562 # Transmit
	409201541 # Pages
	409183694 # Keynote
	409203825 # Numbers
	411643860 # DaisyDisk
	497799835 # Xcode
)
mas signin --dialog snown27@gmail.com
screen -S mas -dm mas install ${macapps[@]}

# FONTS
echo "Installing fonts..."
fonts=(
  source-sans-pro
  input
  roboto
	fira-code
	fontawesome
	consolas-for-powerline
	droid-sans
	droid-sans-mono
	menlo-for-powerline
)
brew cask install ${fonts[@] /#/font-} # Prefix each font wit "font-" ## http://stackoverflow.com/a/13216833

# Remove outdated versions from the Cellar
echo "Performing brew cleanup..."
brew cleanup

# Link .app files into /Applications
echo "Linking up Cask Apps..."
brew linkapps