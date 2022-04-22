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

export JHBUILDRC=$ETC_DIR/jhbuildrc
export JHBUILDRC_CUSTOM=$JHBUILDRC-custom

JHBUILD_REQUIREMENTS="\
  certifi==2021.10.8\
  meson==0.59.2\
  ninja==1.10.2.2\
"

# JHBuild build system >3.38.0 (current master as of 08.03.2022)
# The last stable release (3.38.0) is missing a critical fix (commit
# a896cbf404461cab979fa3cd1c83ddf158efe83b) so we have to stay on master branch
# for the time being.
# https://gitlab.gnome.org/GNOME/jhbuild
# https://wiki.gnome.org/Projects/Jhbuild/Introduction
JHBUILD_VER=d1c5316
JHBUILD_URL=https://gitlab.gnome.org/GNOME/jhbuild/-/archive/$JHBUILD_VER/\
jhbuild-$JHBUILD_VER.tar.bz2

# A dedicated Python runtime (only) for JHBuild. It is installed and kept
# separately from the rest of the system. It won't interfere with a Python
# that might get installed as part of building modules with JHBuild.
JHBUILD_PYTHON_VER_MAJOR=3
JHBUILD_PYTHON_VER_MINOR=8
JHBUILD_PYTHON_VER=$JHBUILD_PYTHON_VER_MAJOR.$JHBUILD_PYTHON_VER_MINOR
JHBUILD_PYTHON_URL="https://gitlab.com/api/v4/projects/26780227/packages/\
generic/python_macos/12/python_${JHBUILD_PYTHON_VER/./}_$(uname -m).tar.xz"
JHBUILD_PYTHON_DIR=$OPT_DIR/Python.framework/Versions/$JHBUILD_PYTHON_VER
JHBUILD_PYTHON_BIN_DIR=$JHBUILD_PYTHON_DIR/bin

export JHBUILD_PYTHON_BIN=$JHBUILD_PYTHON_BIN_DIR/python$JHBUILD_PYTHON_VER
export JHBUILD_PYTHON_PIP=$JHBUILD_PYTHON_BIN_DIR/pip$JHBUILD_PYTHON_VER

### functions ##################################################################

function jhbuild_install_python
{
  # Download and extract Python.framework to OPT_DIR.
  curl -L "$JHBUILD_PYTHON_URL" | tar -C "$OPT_DIR" -x

  # Create a pkg-config configuration to match our installation location.
  # Note: sed changes the prefix and exec_prefix lines!
  find "$JHBUILD_PYTHON_DIR"/lib/pkgconfig/*.pc \
    -type f \
    -exec sed -i "" "s|prefix=.*|prefix=$JHBUILD_PYTHON_DIR|" {} \;

  jhbuild_set_python_interpreter

  # add to PYTHONPATH
  echo "../../../../../../../usr/lib/python$JHBUILD_PYTHON_VER/site-packages"\
    > "$OPT_DIR"/Python.framework/Versions/$JHBUILD_PYTHON_VER/lib/\
python$JHBUILD_PYTHON_VER/site-packages/jhb.pth
}

function jhbuild_set_python_interpreter
{
  # Symlink binaries to USR_DIR/bin.
  if command -v gln 1>/dev/null; then
    local gnu=g   # necessary for union mount
  fi
  ${gnu}ln -sf "$JHBUILD_PYTHON_BIN" "$USR_DIR"/bin
  ${gnu}ln -sf "$JHBUILD_PYTHON_PIP" "$USR_DIR"/bin

  # Set interpreter to the one in USR_DIR/bin.
  while IFS= read -r -d '' file; do
    local file_type
    file_type=$(file "$file")
    if [[ $file_type = *"Python script"* ]]; then
      sed -i "" "1 s|.*|#!$USR_DIR/bin/python$JHBUILD_PYTHON_VER|" "$file"
    fi
  done < <(find "$USR_DIR"/bin/ -maxdepth 1 -type f -print0)
}

function jhbuild_install
{
  # We use our own custom Python.
  jhbuild_install_python

  # Install dependencies.
  # shellcheck disable=SC2086 # we need word splitting for requirements
  $JHBUILD_PYTHON_PIP install --prefix=$USR_DIR $JHBUILD_REQUIREMENTS

  function pem_remove_expired
  {
    local pem_bundle=$1

    # BSD's csplit does not support '{*}' (it's a GNU extension)
    csplit -n 3 -k -f "$TMP_DIR"/pem- "$pem_bundle" \
     '/END CERTIFICATE/+1' '{999}' >/dev/null || true

    for pem in "$TMP_DIR"/pem-*; do
      if ! openssl x509 -checkend 0 -noout -in "$pem"; then
        echo_d "removing $pem: $(openssl x509 -enddate -noout -in "$pem")"
        cat "$pem"
        rm "$pem"
      fi
    done

    cat "$TMP_DIR"/pem-??? > "$pem_bundle"
  }

  local cacert="$USR_DIR"/lib/python$JHBUILD_PYTHON_VER/site-packages/certifi/\
cacert.pem

  pem_remove_expired "$cacert"

  # Download JHBuild. Setting CURL_CA_BUNDLE is required on older macOS, e.g.
  # High Sierra.
  local archive
  archive=$PKG_DIR/$(basename $JHBUILD_URL)
  CURL_CA_BUNDLE=$cacert curl -o "$archive" -L "$JHBUILD_URL"
  tar -C "$SRC_DIR" -xf "$archive"

  ( # Install JHBuild.
    cd "$SRC_DIR"/jhbuild-$JHBUILD_VER || exit 1
    ./autogen.sh \
      --prefix="$USR_DIR" \
      --with-python="$JHBUILD_PYTHON_BIN"
    make
    make install
  )
}

function jhbuild_configure
{
  local moduleset=$1

  moduleset=${moduleset:-jhb.modules}
  local suffix
  suffix=$(basename -s .modules "$moduleset")

  # install custom moduleset
  if [ "$suffix" != "jhb" ]; then
    local moduleset_dir
    moduleset_dir=$(dirname "$(greadlink -f "$moduleset")")
    rsync -a --delete "$moduleset_dir"/ "$ETC_DIR/modulesets/$suffix/"
  fi

  local target
  target=$(/usr/libexec/PlistBuddy -c "Print \
    :DefaultProperties:MACOSX_DEPLOYMENT_TARGET" "$SDKROOT"/SDKSettings.plist)

  # create custom jhbuildrc configuration
  {
    echo "# -*- mode: python -*-"

    # moduleset
    echo "modulesets_dir = '$ETC_DIR/modulesets/$suffix'"
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

    # certificates for https
    echo "os.environ[\"SSL_CERT_FILE\"] = \
      \"$USR_DIR/lib/python$JHBUILD_PYTHON_VER/site-packages/certifi/cacert.pem\""
    echo "os.environ[\"REQUESTS_CA_BUNDLE\"] = \
      \"$USR_DIR/lib/python$JHBUILD_PYTHON_VER/site-packages/certifi/cacert.pem\""

    # user home directory
    echo "os.environ[\"HOME\"] = \"$HOME\""

    # less noise on the terminal if not CI
    if ! $CI; then
      echo "quiet_mode = True"
      echo "progress_bar = True"
    fi

  } > "$JHBUILDRC-$suffix"

  if command -v gln 1>/dev/null; then
    local gnu=g   # necessary for union mount
  fi
  ${gnu}ln -sf "$(basename "$JHBUILDRC-$suffix")" "$JHBUILDRC_CUSTOM"

  # Update the paths to Python.
  jhbuild_set_python_interpreter
}

### main #######################################################################

# Nothing here.