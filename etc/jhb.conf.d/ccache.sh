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
# https://gitlab.com/dehesselle/ccache_macos
# 4.6.3 is the last version to support High Sierra
CCACHE_VER=${CCACHE_VER:-4.6.3r1}
CCACHE_URL="https://gitlab.com/api/v4/projects/29039216/packages/generic/\
ccache_macos/$CCACHE_VER/ccache_$(uname -m).tar.xz"

### functions ##################################################################

function ccache_configure
{
  # Create directory and configuration if it doesn't exist.
  if [ ! -d "$CCACHE_DIR" ]; then
    mkdir -p "$CCACHE_DIR"

    cat <<EOF >"$CCACHE_DIR/ccache.conf"
base_dir = $WRK_DIR
hash_dir = false
max_size = 3.0G
temporary_dir = $CCACHE_DIR/tmp
EOF
  fi

  # If GNU's ln is available (gln), use that. Necessary when working
  # with union-mounts.
  if command -v gln 1>/dev/null; then
    local gnu=g
  fi

  for compiler in clang clang++ gcc g++; do
    "$gnu"ln -sf "$CCACHE_BIN" "$USR_DIR"/bin/$compiler
  done
}

function ccache_install
{
  curl -L "$CCACHE_URL" | tar -C "$USR_DIR"/bin --exclude="ccache.sha256" -xJ
}

### main #######################################################################

# Nothing here.
