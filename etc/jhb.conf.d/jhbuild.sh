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
  certifi==2023.11.17\
  meson==1.2.3\
  ninja==1.11.1\
"

# JHBuild build system (current master as of 25.03.2024)
# The last stable release (3.38.0) is missing at least one critical fix
# (a896cbf404461cab979fa3cd1c83ddf158efe83b) and other enhancements
# (e.g. acb52b03594989cfb45173841b318fccf557fefb).
# https://gitlab.gnome.org/GNOME/jhbuild
# https://wiki.gnome.org/Projects/Jhbuild/Introduction
JHBUILD_VER=4c78b56a
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
generic/python_macos/v19/python_${JHBUILD_PYTHON_VER/./}_$(uname -m).tar.xz"

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
  # If GNU's ln is available (gln), use that. Necessary when working
  # with union-mounts.
  if command -v gln 1>/dev/null; then
    local gnu=g
  fi

  # Symlink binaries to USR_DIR/bin.
  "$gnu"ln -sf "$JHBUILD_PYTHON_BIN_DIR/python$JHBUILD_PYTHON_VER" "$BIN_DIR"
  "$gnu"ln -sf "$JHBUILD_PYTHON_BIN_DIR/pip$JHBUILD_PYTHON_VER" "$BIN_DIR"

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

  function pem_remove_expired
  {
    local pem_bundle=$1

    # BSD's csplit does not support '{*}' (it's a GNU extension)
    csplit -n 3 -k -f "$TMP_DIR"/pem- "$pem_bundle" \
      '/END CERTIFICATE/+1' '{999}' >/dev/null 2>&1 || true

    for pem in "$TMP_DIR"/pem-*; do
      if [ "$(stat -f%z "$pem")" -eq 0 ]; then
        rm "$pem" # the csplit command above created one superfluous empty file
      elif ! openssl x509 -checkend 0 -noout -in "$pem"; then
        echo_d "removing $pem: $(openssl x509 -enddate -noout -in "$pem")"
        rm "$pem"
      fi
    done

    cat "$TMP_DIR"/pem-??? >"$pem_bundle"
  }

  local cacert="$LIB_DIR/python$JHBUILD_PYTHON_VER/site-packages/\
certifi/cacert.pem"
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
      --prefix="$VER_DIR" \
      --with-python="$BIN_DIR/python$JHBUILD_PYTHON_VER"
    make
    make install
  )
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
    # Syncing links throws errors on the overlay ("cannot update timestamps")
    # and since this only affects the dtd and xsl files, we skip them.
    rsync -a --no-links --delete "$moduleset_dir"/ "$ETC_DIR/modulesets/$name/"
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

    # certificates for https
    echo "os.environ[\"SSL_CERT_FILE\"] = \
\"$LIB_DIR/python$JHBUILD_PYTHON_VER/site-packages/certifi/cacert.pem\""
    echo "os.environ[\"REQUESTS_CA_BUNDLE\"] = \
\"$LIB_DIR/python$JHBUILD_PYTHON_VER/site-packages/certifi/cacert.pem\""

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

  # If GNU's ln is available (gln), use that. Necessary when working
  # with union-mounts.
  if command -v gln 1>/dev/null; then
    local gnu=g
  fi

  "$gnu"ln -sf "$(basename "$JHBUILDRC-$name")" "$JHBUILDRC_CUSTOM"
}

### main #######################################################################

# Nothing here.
