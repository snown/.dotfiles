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
kegs=(
	"thoughtbot/formulae"
	"homebrew/cask-versions"
	"homebrew/cask-fonts"
	"neovim/neovim"
)
for keg in ${kegs[@]}; do
	brew tap "$keg"
done

# Install essential homebrews
echo "Pouring brews..."
brews=(
	bash
  brew-cask-completion
	coreutils
  ddrescue
  docker-completion
  docker-compose-completion
	findutils
	fontforge
  gawk
  gem-completion
  git-lfs
	macosvpn
	mas
	multimarkdown
	neovim
  nmap
	objc-run
  pacapt
  rake-completion
	ruby
  ruby-completion
	spoof-mac
	ssh-copy-id
	the_silver_searcher
	tor
	unrar
  vagrant-completion
  webp
  wget
	xcproj
	hstr
	gibo
  gnu-sed

	# Commenting Node out right now because there is a better way to do it with version switching
	#node
)
for brewname in "${brews[@]}"; do
  brew install ${brewname}
done

# Add newly installed GNU `find` in PATH as `find`
ln -sf /usr/local/bin/gfind "${FRESH_BIN_PATH:-$HOME/.bin}/find"


# Install essential casks
echo "Filling casks..."
#brew install caskroom/cask/brew-cask

casks=(
	atom
	cakebrew
	colorpicker-developer
  colorpicker-skalacolor
  discord
	docker
	dropbox
	fastlane
	fontforge
	google-chrome
	gpg-suite
	hockey
  hermes
	inkscape
  intellij-idea-ce
	keka
  keybase
	lingon-x
	moom
	mplayerx
  postman
  provisionql
	resilio-sync
	sequel-pro
	slack
	sourcetree
	textmate
	the-unarchiver
	tor-browser
	tower
	trim-enabler
	unrarx
	virtualbox
	webstorm-eap
  wine-stable
	xquartz
)
for caskname in "${casks[@]}"; do
  brew cask install ${caskname}
done

# Remove outdated versions from the Cellar
echo "Performing brew cleanup..."
brew cleanup

# Link .app files into /Applications
#echo "Linking up Cask Apps..."
#brew linkapps