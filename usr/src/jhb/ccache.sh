# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# This file contains the functions to setup ccache.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### dependencies ###############################################################

# Nothing here.

### variables ##################################################################

export CCACHE_DIR=${CCACHE_DIR:-$WRK_DIR/ccache}

# https://ccache.dev
# https://github.com/ccache/ccache
# https://gitlab.com/dehesselle/ccache_macos
CCACHE_VER=4.6.1r1
CCACHE_URL=https://gitlab.com/api/v4/projects/29039216/packages/generic/\
ccache_macos/$CCACHE_VER/ccache_$(uname -m).tar.xz

### functions ##################################################################

function ccache_configure
{
    mkdir -p "$CCACHE_DIR"

  cat <<EOF > "$CCACHE_DIR/ccache.conf"
base_dir = $WRK_DIR
hash_dir = false
max_size = 3.0G
temporary_dir = $CCACHE_DIR/tmp
EOF
}

function ccache_install
{
  curl -L "$CCACHE_URL" | tar -C "$USR_DIR"/bin --exclude="ccache.sha256" -xJ

  for compiler in clang clang++ gcc g++; do
    ln -sf ccache "$USR_DIR"/bin/$compiler
  done
}

### main #######################################################################

# Nothing here.