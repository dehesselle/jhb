# SPDX-FileCopyrightText: 2025 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Settings and functions to setup Rust.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### variables ##################################################################

# https://forge.rust-lang.org/infra/other-installation-methods.html#standalone
RUST_VER=1.86.0
RUST_URL=https://static.rust-lang.org/dist/rust-$RUST_VER-aarch64-apple-darwin.tar.xz
# shellcheck disable=SC2034 # used by 'download'
RUST_URL_SHA256=b176bf7381e2fd22b5815e68780440f618780ed3f7a34b87bb58585afa923755

### functions ##################################################################

function rust_install
{
  download RUST_URL
  tar -C "$TMP_DIR" -xJf "$PKG_DIR"/"$(basename $RUST_URL)"
  local extract_dir
  extract_dir=$TMP_DIR/$(basename -s .tar.xz $RUST_URL)
  "$extract_dir"/install.sh --prefix="$USR_DIR"
  rm -rf "${extract_dir:?}"
}

### main #######################################################################

# Nothing here.
