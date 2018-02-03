#!/usr/bin/env bash

function setcolor {
	if [ -x "$(command -v setcolor)"  ]; then
		$(command -v setcolor) "$@"
  elif [ -x "${FRESH_LOCAL}/All/bin/setcolor" ]; then
		"${FRESH_LOCAL}"/All/bin/setcolor "$@"
  fi
}

################################################################################
# Clone/Pull Nerd Fonts Repo
################################################################################
NERD_FONT_REPO="${FRESH_PATH}/source/ryanoasis/nerd-fonts"
mkdir -p "${NERD_FONT_REPO}"
( \
	git -C "${NERD_FONT_REPO}" reset --hard HEAD \
	&& git -C "${NERD_FONT_REPO}" pull --depth 1 \
) \
|| git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git "${NERD_FONT_REPO}"

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
for font in /tmp/monoid/*.ttf; do
  # Generate Standard Nerd Font
	echo "$(setcolor -f blue)==>$(setcolor reset) Generating Monoid Nerd Font"
  ./font-patcher -l -c --careful --outputdir "./patched-fonts/Monoid/complete/" "${font}" &>/dev/null
  # Generate Mono Nerd Font
	echo "$(setcolor -f blue)==>$(setcolor reset) Generating Monoid Mono Nerd Font"
  ./font-patcher -l -c -s --careful --outputdir "./patched-fonts/Monoid/complete/" "${font}" &>/dev/null
  # Generate Windows Nerd Font
	echo "$(setcolor -f blue)==>$(setcolor reset) Generating Monoid Windows Nerd Font"
  ./font-patcher -l -c -w --careful --outputdir "./patched-fonts/Monoid/complete/" "${font}" &>/dev/null
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
