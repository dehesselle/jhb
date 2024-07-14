# SPDX-FileCopyrightText: 2022 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Settings and functions to setup ccache.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### variables ##################################################################

export CCACHE_DIR=${CCACHE_DIR:-$WRK_DIR/ccache}

CCACHE_BIN=${CCACHE_BIN:-ccache}

# https://ccache.dev
# https://github.com/ccache/ccache
CCACHE_VER=${CCACHE_VER:-4.10.1}
CCACHE_URL="https://github.com/ccache/ccache/releases/download/v$CCACHE_VER/\
ccache-$CCACHE_VER-darwin.tar.gz"

### functions ##################################################################

function ccache_configure
{
  # Create directory and configuration if it doesn't exist.
  if [ ! -d "$CCACHE_DIR" ]; then
    mkdir -p "$CCACHE_DIR"

    cat <<EOF >"$CCACHE_DIR/ccache.conf"
base_dir = $WRK_DIR
hash_dir = false
max_size = 1Gi
temporary_dir = $CCACHE_DIR/tmp
EOF
  fi

  for compiler in clang clang++ gcc g++; do
    ln -sf "$CCACHE_BIN" "$USR_DIR"/bin/$compiler
  done
}

function ccache_install
{
  curl -L "$CCACHE_URL" |
    tar -C "$USR_DIR"/bin -xz --strip-components 1 \
    ccache-"$CCACHE_VER"-darwin/ccache
}

### main #######################################################################

# Nothing here.
