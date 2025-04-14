# SPDX-FileCopyrightText: 2025 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Download a file with curl and check its sha256.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### variables ##################################################################

# Nothing here.

### functions ##################################################################

function download
{
  local url_var=$1
  local target_file=$2

  local expected_sha256
  expected_sha256=$(eval echo \$"${url_var}"_SHA256)
  if [ -z "$expected_sha256" ]; then
    echo_e "cannot download $url_var without ${url_var}_SHA256"
  else
    local url
    url=$(eval echo \$"${url_var}")

    if [ -z "$target_file" ]; then
      target_file=$PKG_DIR/$(basename "$url")
    fi

    if curl -Lo "$target_file" "$url"; then
      local actual_sha256
      actual_sha256=$(shasum -a 256 "$target_file" | cut -c 1-64)

      if [ "$expected_sha256" != "$actual_sha256" ]; then
        echo_e "$url_var: got $actual_sha256, expected $expected_sha256"
        rm "$target_file"
      fi
    fi
  fi
}

### main #######################################################################

# Nothing here.
