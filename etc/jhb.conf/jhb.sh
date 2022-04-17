# SPDX-FileCopyrightText: 2022 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# JHB variables.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # we only use exports if we really need them

### variables ##################################################################

JHB_ARCHIVE=$(basename "$VER_DIR")_$(uname -m).tar.xz

# https://github.com/dehesselle/jhb
JHB_URL[1]=https://github.com/dehesselle/jhb/releases/download/\
v$VERSION/$JHB_ARCHIVE

# TODO: this will be added later
# https://gitlab.com/dehesselle/jhb
#JHB_URL[2]=https://gitlab.com/api/v4/projects/????/packages/generic/jhb/\
#$VERSION/$JHB_ARCHIVE

### functions ##################################################################

function jhb_get_archive_url
{
  local archive="$TMP_DIR/${FUNCNAME[0]}".tar.xz

  for url in "${JHB_URL[@]}"; do
    # download at least 100 kb of data
    curl -L "$url" 2>/dev/null | head -c 100000 > "$archive"
    if [ "$(stat -f%z "$archive")" -ge 100000 ]; then  # download successful?
      # check if we can use archive: it has to match our VER_DIR
      local dir
      dir=$(basename "$(tar -tvJf "$archive" 2>/dev/null |
        head -n 1 | awk '{ print $NF }')")
      if [ "$dir" = "$(basename "$VER_DIR")" ]; then
        echo "$url"
        break
      fi
    fi
  done

  echo "none"
}

### main #######################################################################

# Nothing here.
