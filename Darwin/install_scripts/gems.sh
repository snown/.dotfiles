#!/usr/bin/env bash

if ! hash gem 2> /dev/null; then
	echo "Missing Gem installer"
	exit 1
fi

gems=(
xcode-install
xcpretty
)

echo "Installing gems..."
for package in "${gems[@]}"; do
  gem install "${package}"
done