# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# This file contains functions to download, install and configure JHBuild.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### dependencies ###############################################################

# Nothing here.

### variables ##################################################################

export JHBUILDRC=${JHBUILDRC:-$ETC_DIR/jhbuildrc}
export JHBUILDRC_CUSTOM=${JHBUILDRC_CUSTOM:-$JHBUILDRC-custom}

JHBUILD_REQUIREMENTS_PIP=(
  "meson==1.8.2"
  "ninja==1.11.1.4"
  "setuptools==80.9.0"
)

# JHBuild build system (current master as of 10.05.2026)
# https://gitlab.gnome.org/GNOME/jhbuild
# https://gnome.pages.gitlab.gnome.org/jhbuild/
JHBUILD_VER=643b97b2
JHBUILD_URL="https://gitlab.gnome.org/GNOME/jhbuild/-/archive/$JHBUILD_VER/\
jhbuild-$JHBUILD_VER.tar.bz2"

### functions ##################################################################

function jhbuild_install
{
  python3 -m venv "$SHR_DIR"/venv/jhbuild

  local venv_dir=$SHR_DIR/venv/jhbuild
  local pip=$venv_dir/bin/pip3

  # Install dependencies.
  $pip install "${JHBUILD_REQUIREMENTS_PIP[@]}"

  local archive
  archive=$PKG_DIR/$(basename $JHBUILD_URL)
  curl -o "$archive" -L "$JHBUILD_URL"
  tar -C "$venv_dir" -xf "$archive"

  ( # Install JHBuild.
    cd "$venv_dir"/jhbuild-$JHBUILD_VER || exit 1
    patch -p1 < "$ETC_DIR"/modulesets/jhb/patches/jhbuild-distutils.patch
    ./autogen.sh \
      --prefix="$venv_dir" \
      --with-python="$venv_dir"/bin/python3
    make install
  )

  for file in jhbuild meson ninja; do
    ln -s ../../share/venv/jhbuild/bin/$file "$USR_DIR"/bin
  done
}

function jhbuild_configure
{
  local moduleset=$1

  moduleset=${moduleset:-jhb.modules}
  local name
  name=$(basename -s .modules "$moduleset")

  # install custom moduleset
  if [ "$name" != "jhb" ]; then
    local moduleset_dir
    moduleset_dir=$(dirname "$(greadlink -f "$moduleset")")
    rsync -a --delete "$moduleset_dir"/ "$ETC_DIR/modulesets/$name/"
  fi

  if [ -z "$MACOSX_DEPLOYMENT_TARGET" ]; then
    local target=$SYS_SDK_VER
  else
    local target=$MACOSX_DEPLOYMENT_TARGET
  fi

  # create custom jhbuildrc configuration
  {
    echo "# -*- mode: python -*-"

    # moduleset
    echo "modulesets_dir = '$ETC_DIR/modulesets/$name'"
    echo "moduleset = '$(basename "$moduleset")'"
    echo "use_local_modulesets = True"

    # basic directory layout
    echo "buildroot = '$BLD_DIR'"
    echo "checkoutroot = '$SRC_DIR'"
    echo "prefix = '$VER_DIR'"
    echo "tarballdir = '$PKG_DIR'"
    echo "top_builddir = '$VAR_DIR/jhbuild'"

    # setup macOS SDK
    echo "setup_sdk(target=\"$target\")"

    # set release build
    echo "setup_release()"

    # Use compiler binaries from our own USR_DIR/bin if present, the intention
    # being that these are symlinks pointing to ccache if that has been
    # installed (see ccache.sh for details).
    if [ -x "$USR_DIR/bin/gcc" ]; then
      echo "os.environ[\"CC\"] = \"$USR_DIR/bin/gcc\""
      echo "os.environ[\"OBJC\"] = \"$USR_DIR/bin/gcc\""
    fi
    if [ -x "$USR_DIR/bin/g++" ]; then
      echo "os.environ[\"CXX\"] = \"$USR_DIR/bin/g++\""
    fi

    # user home directory
    echo "os.environ[\"HOME\"] = \"$HOME\""

    # less noise on the terminal if not CI
    if ! $CI; then
      echo "quiet_mode = True"
      echo "progress_bar = True"
    fi

    # add moduleset-specific settings if exist
    local moduleset_rc=$ETC_DIR/modulesets/$name/jhbuildrc
    if [ -f "$moduleset_rc" ]; then
      cat "$moduleset_rc"
    fi

  } >"$JHBUILDRC-$name"

  ln -sf "$(basename "$JHBUILDRC-$name")" "$JHBUILDRC_CUSTOM"
}

### main #######################################################################

# Nothing here.
