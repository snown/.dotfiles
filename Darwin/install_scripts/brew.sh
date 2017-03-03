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
	"homebrew/versions"
	"caskroom/versions"
	"caskroom/fonts"
	"neovim/neovim"
)
for keg in ${kegs[@]}; do
	brew tap "$keg"
done

# Install essential homebrews
echo "Pouring brews..."
brews=(
	bash
	python
	python3
	"ruby --with-doc"
	ssh-copy-id
	the_silver_searcher
	tree
	"wget --with-pcre"
	pandoc
	rhash
	multimarkdown
	objc-run
	tmux
	xcproj
	unrar
	mas
	bash-completion
	"git --with-pcre"
	pacapt
	"coreutils --with-gmp"
	findutils
	spoof-mac
	macosvpn
	hh
	neovim
	fontforge
	rename
	tor
	wdiff
	editorconfig
	gibo

	# Commenting Node out right now because there is a better way to do it with version switching
	#node
)
brew install ${brews[@]}

# Add newly installed GNU `find` in PATH as `find`
ln -sf /usr/local/bin/gfind "${FRESH_BIN_PATH:-$HOME/.bin}/find"


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
	xquartz
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
	sqlitebrowser
	resilio-sync
	fontforge
	docker
	hockey
)
brew cask install ${casks[@]}

# Remove outdated versions from the Cellar
echo "Performing brew cleanup..."
brew cleanup

# Link .app files into /Applications
echo "Linking up Cask Apps..."
brew linkapps
