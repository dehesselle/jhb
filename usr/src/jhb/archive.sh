# SPDX-FileCopyrightText: 2022 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Provide functions to create and download JHB archives.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### dependencies ###############################################################

# Nothing here.

### variables ##################################################################

ARCHIVE_NAME=$(basename "$VER_DIR")_$(uname -m).tar.xz

# https://github.com/dehesselle/jhb
ARCHIVE_URL[1]=https://github.com/dehesselle/jhb/releases/download/\
v$VERSION/$ARCHIVE_NAME

# TODO: this will be added later
# https://gitlab.com/dehesselle/jhb
#ARCHIVE_URL[2]=https://gitlab.com/api/v4/projects/????/packages/generic/jhb/\
#$VERSION/$ARCHIVE_NAME

### functions ##################################################################

function archive_get_url
{
  local partial_download="$TMP_DIR/${FUNCNAME[0]}".tar.xz

  for url in "${ARCHIVE_URL[@]}"; do
    # download at least 100 kb of data
    curl -L "$url" 2>/dev/null | head -c 100000 > "$partial_download"
    # if we got at least 100 kb, it's not a "404 file not found"
    if [ "$(stat -f%z "$partial_download")" -ge 100000 ]; then
      # look inside: dir needs to match our VER_DIR to be usable
      local dir
      dir=$(basename "$(tar -tvJf "$partial_download" 2>/dev/null |
        head -n 1 | awk '{ print $NF }')")
      if [ "$dir" = "$(basename "$VER_DIR")" ]; then
        echo "$url"
        break
      fi
    fi
  done

  echo "none"
}

function archive_create
{
  local file=${file:-$ARCHIVE_NAME}

  # remove all non-essential files to reduce size
  find "$SRC_DIR" -mindepth 1 -maxdepth 1 -type d \
    ! -name bash_d ! -name "jhb*" \
    -exec rm -rf {} \;
  rm -rf "$VAR_DIR"/build/*
  rm -rf "$VAR_DIR"/cache/pip/*
  rm -rf "$VAR_DIR"/cache/pycache/*
  rm -rf "${TMP_DIR:?}"/*

  tar -C "$WRK_DIR" -cp "$(basename "$VER_DIR")" |
    XZ_OPT=-T0 "$BIN_DIR"/xz > "$file"
  shasum -a 256 "$file" > "$file".sha256
}

### main #######################################################################

# Nothing here.
