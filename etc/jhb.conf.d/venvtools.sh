# SPDX-FileCopyrightText: 2026 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Install Python tools in dedicated virtual environments.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### dependencies ###############################################################

# Nothing here.

### variables ##################################################################

# Nothing here.

### functions ##################################################################

function venvtools_install
{
  for requirements in "$SHR_DIR"/venv/*.txt; do
    local tool_name
    tool_name=$(basename -s .txt "$requirements")
    local venv_dir=$SHR_DIR/venv/$tool_name
    # setup venv named after the tool
    jhb run python3 -m venv "$venv_dir"
    # install the tool into the venv
    jhb run "$venv_dir"/bin/pip install -r "$requirements"
    # link the tool to usr/bin
    ln -s "../../share/venv/$tool_name/bin/$tool_name" "$USR_DIR"/bin
  done
}

function venvtools_dmgbuild
{
  local config=$1
  local plist=$2
  local dmg=$3 # optional; default is <name>_<version>_<build>_<arch>.dmg

  local app_dir
  app_dir=$(echo "$ART_DIR"/*.app)

  if [ -z "$dmg" ]; then
    local version
    version=$(/usr/libexec/PlistBuddy \
      -c "Print :CFBundleShortVersionString" "$plist")
    local build
    build=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$plist")

    dmg=$(basename -s .app "$app_dir")-${version}+${build}_$(uname -m).dmg
  fi

  # Copy templated version of the file (it contains placeholders) to source
  # directory. They copy will be modified to contain the actual values.
  cp "$config" "$SRC_DIR"
  config=$SRC_DIR/$(basename "$config")

  # set application
  gsed -i "s|PLACEHOLDERAPPLICATION|$app_dir|" "$config"

  # set disk image icon (if it exists)
  local icon
  icon=$SRC_DIR/$(basename -s .py "$config").icns
  if [ -f "$icon" ]; then
    gsed -i "s|PLACEHOLDERICON|$icon|" "$config"
  fi

  # set background image (if it exists)
  local background
  background=$SRC_DIR/$(basename -s .py "$config").png
  if [ -f "$background" ]; then
    gsed -i "s|PLACEHOLDERBACKGROUND|$background|" "$config"
  fi

  # Create disk image in temporary location and move to target location
  # afterwards. This way we can run multiple times without requiring cleanup.
  dmgbuild -s "$config" "$(basename -s .app "$app_dir")" \
    "$TMP_DIR"/"$(basename "$dmg")"
  mv "$TMP_DIR"/"$(basename "$dmg")" "$dmg"
}

### main #######################################################################

# Nothing here.
