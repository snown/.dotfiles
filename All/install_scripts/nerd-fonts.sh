#!/usr/bin/env bash

source "${FRESH_LOCAL:-${HOME}/.dotfiles}/utilities"

################################################################################
# Clone/Pull Nerd Fonts Repo
################################################################################

NERD_FONT_REPO="${FRESH_PATH}/source/ryanoasis/nerd-fonts"
if _needs_git_pull "${NERD_FONT_REPO}"; then
	git -C "${NERD_FONT_REPO}" reset --hard origin/master \
	&& git -C "${NERD_FONT_REPO}" pull --depth 1
elif [[ ! -d "${NERD_FONT_REPO}" ]]; then
	mkdir -p "${NERD_FONT_REPO}"
	git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git "${NERD_FONT_REPO}"
fi

################################################################################
# Create Custom Monoid Nerd Font
################################################################################

BASE_MONOID="Monoid-XtraLarge-1-l"
mkdir -p /tmp/monoid/

pushd /tmp/monoid/ 1>/dev/null
wget -O "${BASE_MONOID}.zip" "https://github.com/larsenwork/monoid/blob/release/${BASE_MONOID}.zip?raw=true"
unzip -u "${BASE_MONOID}.zip"
popd 1>/dev/null

pushd "${NERD_FONT_REPO}" 1>/dev/null
local font_options=${BASE_MONOID#Monoid-}
for font in /tmp/monoid/*.ttf; do
	local font_weight=${font##*/Monoid-}
	font_weight=${font_weight%-${font_options}.ttf}
	
  # Generate Standard Nerd Font
	echo "$(setcolor -f blue)==>$(setcolor reset) Generating ${font_weight} Monoid Nerd Font"
  ./font-patcher -l -c --careful --outputdir "./patched-fonts/Monoid/complete/" "${font}"
  # Generate Mono Nerd Font
	echo "$(setcolor -f blue)==>$(setcolor reset) Generating ${font_weight} Monoid Mono Nerd Font"
  ./font-patcher -l -c -s --careful --outputdir "./patched-fonts/Monoid/complete/" "${font}"
  # Generate Windows Nerd Font
	echo "$(setcolor -f blue)==>$(setcolor reset) Generating ${font_weight} Monoid Windows Nerd Font"
  ./font-patcher -l -c -w --careful --outputdir "./patched-fonts/Monoid/complete/" "${font}"
done

################################################################################
# Install Nerd Fonts at System Level
################################################################################

NERD_FONTS=(
  DroidSansMono
  FantasqueSansMono
  FiraCode
  FiraMono
  Hack
  Hasklig
  Inconsolata
  Meslo
  Monoid # The custom one
  Mononoki
  SourceCodePro
)

for font in "${NERD_FONTS[@]}"; do
  echo "$(setcolor -f blue)==>$(setcolor reset) Installing ${font}..."
  ./install.sh -Sq "${font}"
done

popd 1>/dev/null
