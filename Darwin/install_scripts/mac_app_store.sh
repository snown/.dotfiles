#!/usr/bin/env bash

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