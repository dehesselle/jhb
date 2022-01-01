# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# This file contains everything related to setup JHBuild.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### includes ###################################################################

# Nothing here.

### variables ##################################################################

#----------------------------------------------------------------------- JHBuild

export JHBUILDRC=$ETC_DIR/jhbuildrc
export JHBUILDRC_CUSTOM=$JHBUILDRC-custom

JHBUILD_REQUIREMENTS="\
  certifi==2021.10.8\
  meson==0.57.1\
  ninja==1.10.0.post2
"

# JHBuild build system 3.38.0+ (a896cbf404461cab979fa3cd1c83ddf158efe83b)
# from master branch because of specific patch
# https://gitlab.gnome.org/GNOME/jhbuild
# https://wiki.gnome.org/Projects/Jhbuild/Introduction
JHBUILD_VER=a896cbf
JHBUILD_URL=https://gitlab.gnome.org/GNOME/jhbuild/-/archive/$JHBUILD_VER/\
jhbuild-$JHBUILD_VER.tar.bz2

# This Python runtime powers JHBuild on system that do not provide Python 3.
JHBUILD_PYTHON_VER_MAJOR=3
JHBUILD_PYTHON_VER_MINOR=8
JHBUILD_PYTHON_VER=$JHBUILD_PYTHON_VER_MAJOR.$JHBUILD_PYTHON_VER_MINOR
JHBUILD_PYTHON_URL="https://gitlab.com/api/v4/projects/26780227/packages/\
generic/python_macos/5/python_${JHBUILD_PYTHON_VER/./}_$(uname -p).tar.xz"
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
  mkdir -p "$LIB_DIR"/pkgconfig
  cp "$JHBUILD_PYTHON_DIR"/lib/pkgconfig/python-$JHBUILD_PYTHON_VER*.pc \
    "$LIB_DIR"/pkgconfig
  sed -i "" "s/prefix=.*/prefix=$(sed_escape_str "$JHBUILD_PYTHON_DIR")/" \
    "$LIB_DIR"/pkgconfig/python-$JHBUILD_PYTHON_VER.pc
  sed -i "" "s/prefix=.*/prefix=$(sed_escape_str "$JHBUILD_PYTHON_DIR")/" \
    "$LIB_DIR"/pkgconfig/python-$JHBUILD_PYTHON_VER-embed.pc

  # Link binaries to our BIN_DIR.
  ln -sf "$JHBUILD_PYTHON_BIN" "$USR_DIR"/bin/python$JHBUILD_PYTHON_VER
  ln -sf "$JHBUILD_PYTHON_BIN" "$USR_DIR"/bin/python$JHBUILD_PYTHON_VER_MAJOR

  # Shadow the system's python binary as well.
  ln -sf python$JHBUILD_PYTHON_VER_MAJOR "$USR_DIR"/bin/python

  # add to PYTHONPATH
  echo "../../../../../../../usr/lib/python$JHBUILD_PYTHON_VER/site-packages"\
    > "$OPT_DIR"/Python.framework/Versions/Current/lib/\
python$JHBUILD_PYTHON_VER/site-packages/jhb.pth
}

function jhbuild_install
{
  export PATH=$USR_DIR/bin:$PATH
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
        echo_i "removing $pem: $(openssl x509 -enddate -noout -in "$pem")"
        cat "$pem"
        rm "$pem"
      fi
    done

    cat "$TMP_DIR"/pem-??? > "$pem_bundle"
  }

  pem_remove_expired \
    "$USR_DIR"/lib/python$JHBUILD_PYTHON_VER/site-packages/certifi/cacert.pem

  # Download JHBuild.
  local archive
  archive=$PKG_DIR/$(basename $JHBUILD_URL)
  curl -o "$archive" -L "$JHBUILD_URL"
  tar -C "$SRC_DIR" -xf "$archive"

  ( # Install JHBuild.
    cd "$SRC_DIR"/jhbuild-$JHBUILD_VER || exit 1
    ./autogen.sh \
      --prefix="$VER_DIR" \
      --with-python="$JHBUILD_PYTHON_BIN_DIR"/python$JHBUILD_PYTHON_VER
    make
    make install

    sed -i "" \
      "1 s/.*/#!$(sed_escape_str "$USR_DIR/bin/python$JHBUILD_PYTHON_VER")/" \
      "$BIN_DIR"/jhbuild
  )
}

function jhbuild_configure
{
  {
    echo "# -*- mode: python -*-"

    # set moduleset directory
    echo "modulesets_dir = '$SRC_DIR/modulesets/current'"

    # basic directory layout
    echo "buildroot = '$BLD_DIR'"
    echo "checkoutroot = '$SRC_DIR'"
    echo "prefix = '$VER_DIR'"
    echo "tarballdir = '$PKG_DIR'"
    echo "top_builddir = '$VAR_DIR/jhbuild'"

    # set macOS SDK
    echo "setup_sdk(sdkdir=\"$SDKROOT\")"

    # set release build
    echo "setup_release()"

    # enable ccache
    echo "os.environ[\"CC\"] = \"$BIN_DIR/gcc\""
    echo "os.environ[\"OBJC\"] = \"$BIN_DIR/gcc\""
    echo "os.environ[\"CXX\"] = \"$BIN_DIR/g++\""

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

  } > "$JHBUILDRC_CUSTOM"

}

### main #######################################################################

# Nothing here.