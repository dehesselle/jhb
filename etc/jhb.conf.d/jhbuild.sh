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

JHBUILD_REQUIREMENTS="\
  meson==1.8.2\
  ninja==1.11.1.4\
"

# JHBuild build system (current master as of 18.07.2025)
# https://gitlab.gnome.org/GNOME/jhbuild
# https://gnome.pages.gitlab.gnome.org/jhbuild/
JHBUILD_VER=c2cc9918
JHBUILD_URL="https://gitlab.gnome.org/GNOME/jhbuild/-/archive/$JHBUILD_VER/\
jhbuild-$JHBUILD_VER.tar.bz2"

#---------------------------------------------- Python runtime for bootstrapping

# This is a dedicated Python runtime to bootstrap JHBuild. It will be removed
# after bootstrapping has been completed.

JHBUILD_PYTHON_VER_FULL=$(
  xmllint \
    --xpath "string(//moduleset/autotools[@id='python3']/branch/@version)" \
    "$(dirname "${BASH_SOURCE[0]}")"/../modulesets/jhb/gtk-osx-python.modules
)
JHBUILD_PYTHON_VER=${JHBUILD_PYTHON_VER_FULL%.*} # reduce to major.minor

JHBUILD_PYTHON_URL="https://gitlab.com/api/v4/projects/26780227/packages/\
generic/python_macos/v21.1/python_${JHBUILD_PYTHON_VER/./}_$(uname -m).tar.xz"

JHBUILD_PYTHON_DIR=$TMP_DIR/Python.framework
JHBUILD_PYTHON_VER_DIR=$JHBUILD_PYTHON_DIR/Versions/$JHBUILD_PYTHON_VER
JHBUILD_PYTHON_BIN_DIR=$JHBUILD_PYTHON_VER_DIR/bin

### functions ##################################################################

function jhbuild_install_python
{
  # Download and extract Python.framework to JHBUILD_PYTHON_DIR.
  curl -L "$JHBUILD_PYTHON_URL" | tar -C "$(dirname "$JHBUILD_PYTHON_DIR")" -x

  # Create a pkg-config configuration to match our installation location.
  # Note: sed changes the prefix and exec_prefix lines!
  find "$JHBUILD_PYTHON_VER_DIR"/lib/pkgconfig/*.pc \
    -type f \
    -exec sed -i "" "s|prefix=.*|prefix=$JHBUILD_PYTHON_VER_DIR|" {} \;

  jhbuild_set_python_interpreter

  # add to PYTHONPATH
  echo "../../../../../../../lib/python$JHBUILD_PYTHON_VER/site-packages" \
    >"$JHBUILD_PYTHON_VER_DIR/lib/python$JHBUILD_PYTHON_VER/site-packages/jhb.pth"
}

function jhbuild_set_python_interpreter
{
  # Symlink binaries to USR_DIR/bin.
  ln -sf "$JHBUILD_PYTHON_BIN_DIR/python$JHBUILD_PYTHON_VER" "$BIN_DIR"
  ln -sf "$JHBUILD_PYTHON_BIN_DIR/pip$JHBUILD_PYTHON_VER" "$BIN_DIR"

  # Set interpreter to the one in BIN_DIR.
  while IFS= read -r -d '' file; do
    local file_type
    file_type=$(file "$file")
    if [[ $file_type = *"Python script"* ]]; then
      sed -i "" "1 s|.*|#!$BIN_DIR/python$JHBUILD_PYTHON_VER|" "$file"
    fi
  done < <(find "$BIN_DIR"/ -maxdepth 1 -type f -print0)
}

function jhbuild_install
{
  # Install dependencies.
  # shellcheck disable=SC2086 # we need word splitting for requirements
  pip$JHBUILD_PYTHON_VER install --prefix=$VER_DIR $JHBUILD_REQUIREMENTS

  local archive
  archive=$PKG_DIR/$(basename $JHBUILD_URL)
  curl -o "$archive" -L "$JHBUILD_URL"
  tar -C "$SRC_DIR" -xf "$archive"

  ( # Install JHBuild.
    cd "$SRC_DIR"/jhbuild-$JHBUILD_VER || exit 1
    ./autogen.sh \
      --prefix="$VER_DIR" \
      --with-python="$BIN_DIR/python$JHBUILD_PYTHON_VER"
    make
    make install
  )

  # protect against removal during cleanup
  echo "jhbuild-$JHBUILD_VER" >> "$SRC_DIR"/.keep
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
