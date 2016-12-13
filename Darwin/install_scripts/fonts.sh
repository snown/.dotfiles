#!/usr/bin/env bash

urlencode() {
    local data
    if [[ $# != 1 ]]; then
        echo "Usage: $0 string-to-urlencode"
        return 1
    fi
    data="$(curl -s -o /dev/null -w %{url_effective} --get --data-urlencode "$1" "")"
    if [[ $? != 3 ]]; then
        echo "Unexpected error" 1>&2
        return 2
    fi
    echo "${data##/?}"
    return 0
}

################################################################################
# Brew Fonts
################################################################################
echo "Installing fonts..."
fonts=(
  source-code-pro-for-powerline
  hasklig
  input
  roboto
	fira-code
  fira-mono-for-powerline
  firacode-nerd-font-mono
  firacode-nerd-font
	fontawesome
	consolas-for-powerline
	droid-sans
	droid-sans-mono
	menlo-for-powerline
  meslo-lg-for-powerline
  hack
  hack-nerd-font
  fantasque-sans-mono
  mononoki
  # monoid-halftight-l
  monoisome
  inconsolata-for-powerline
  inconsolata-dz-for-powerline
  inconsolata-g-for-powerline
)
brew cask install ${fonts[@]/#/font-} # Prefix each font wit "font-" ## http://stackoverflow.com/a/13216833

################################################################################
# Install Nerd Fonts
################################################################################

MONOID_NERD_FONTS=(
  "Monoid Bold Nerd Font Complete.ttf"
  "Monoid Italic Nerd Font Complete.ttf"
  "Monoid Regular Nerd Font Complete.ttf"
  "Monoid Retina Nerd Font Complete.ttf"
)

pushd $HOME/Library/Fonts 1>/dev/null

for font in "${MONOID_NERD_FONTS[@]}"; do
  if ! [ -f ./"$font" ]; then
    echo "Monoid $(cut -d ' ' -f 2 <<< "$font"):"
    curl -#fLo "${font}" "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/Monoid/complete/$(urlencode "${font}")"
  fi
done

popd 1>/dev/null

