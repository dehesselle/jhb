# SPDX-FileCopyrightText: 2022 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# dmgbuild is a Python package that simplifies the process of creating a
# disk image (dmg) for distribution.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### dependencies ###############################################################

# Nothing here.

### variables ##################################################################

# https://dmgbuild.readthedocs.io/en/latest/
# https://github.com/al45tair/dmgbuild
# including optional dependencies:
# - biplist: binary plist parser/generator
# - pyobjc-*: framework wrappers
DMGBUILD_PIP="\
  biplist==1.0.3\
  dmgbuild==1.5.2\
  ds-store==1.3.0\
  mac-alias==2.2.0\
  pyobjc-core==8.5.1\
  pyobjc-framework-Cocoa==8.5.1\
  pyobjc-framework-Quartz==8.5.1\
"

### functions ##################################################################

function dmgbuild_install
{
  # shellcheck disable=SC2086 # we need word splitting here
  jhb run $JHBUILD_PYTHON_PIP install --prefix=$USR_DIR wheel $DMGBUILD_PIP

  # dmgbuild has issues with detaching, workaround is to increase max retries
  gsed -i '$ s/HiDPI)/HiDPI, detach_retries=15)/g' "$USR_DIR"/bin/dmgbuild
}

function dmgbuild_run
{
  local config=$1
  local plist=$2
  local dmg=$3   # optional; default is <name>_<version>_<build>_<arch>.dmg

  local app_dir
  app_dir=$(echo "$ARTIFACT_DIR"/*.app)

  if [ -z "$dmg" ]; then
    local version
    version=$(/usr/libexec/PlistBuddy \
       -c "Print :CFBundleShortVersionString" "$plist")
    local build
    build=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$plist")

    dmg=$(basename -s .app "$app_dir")_${version}+${build}_$(uname -m).dmg
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
