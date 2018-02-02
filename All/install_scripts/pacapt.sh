#!/usr/bin/env bash

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install bash if it isn't already installed, and we're on Alpine Linux
if [ ! -x "$(command -v bash)" ]; then
  if [ -x "$(command -v apk)" ]; then
    apk update
    apk upgrade
    apk add man man-pages mdocml-apropos less less-doc bash bash-doc
    
    # Not sure this will work here, may need to go in an rc file
    export PAGER=less
  else
    echo "We need bash to run Pacapt"
    exit 1
  fi
fi

# Install universal package manager Pacapt, with either wget or curl
if [ ! -x "$(command -v pacapt)" ]; then
  if [ -x "$(command -v wget)" ]; then
    sudo wget -O /usr/local/bin/pacapt https://github.com/icy/pacapt/raw/ng/pacapt
  elif [ -x "$(command -v curl)" ]; then
    sudo curl -o /usr/local/bin/pacapt https://github.com/icy/pacapt/raw/ng/pacapt
  else
    echo "We need either wget or curl to install Pacapt"
    exit 1
  fi
  
  # Make sure Pacapt is executable
  sudo chmod 755 /usr/local/bin/pacapt
fi

# Update and upgrade package database
pacapt -Suy --noconfirm

# Install wget and curl if missing
if [ ! -x "$(command -v wget)" ]; then
	pacapt --noconfirm -S wget
fi
if [ ! -x "$(command -v curl)" ]; then
  pacapt --noconfirm -S curl
fi

# Install essential software
echo "Installing with pacapt..."
packages=(
  python
  python3
  tree
  pandoc
  rhash
  tmux
  bash-completion
  rename
  wdiff
  editorconfig
)
pacapt --noconfirm -S ${packages[@]}

# Install documentation on Linux if needed
if [[ "$(uname)" == "Linux" ]]; then {
  echo "Installing package documentation"
  docs=(
    python-doc
    python3-doc
    wdiff-doc
    editorconfig-doc
  )
  pacapt --noconfirm -S ${docs[@]}
}