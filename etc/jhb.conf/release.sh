# SPDX-FileCopyrightText: 2022 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Release artifact.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # we only use exports if we really need them

### variables ##################################################################

RELEASE_ARCHIVE=${RELEASE_ARCHIVE:-$(basename "$VER_DIR")_$(uname -m).tar.xz}

# GitHub and GitLab
# shellcheck disable=2206 # we need expansion for the array to work
RELEASE_URLS=(${RELEASE_URLS[@]:-
  "https://github.com/dehesselle/jhb/releases/download/\
v$VERSION/$RELEASE_ARCHIVE"
  "https://gitlab.com/api/v4/projects/35965804/packages/generic/jhb/\
v$VERSION/$RELEASE_ARCHIVE"
})

### functions ##################################################################

function release_archive_get_name
{
  case "$RELEASE_ARCHIVE" in
    *.tar.xz)
      basename -s .tar.xz "$RELEASE_ARCHIVE"
      ;;
    *.dmg)
      basename -s .dmg "$RELEASE_ARCHIVE"
      ;;
    *)
      echo_e "unsupported RELEASE_ARCHIVE file type"
      echo "$RELEASE_ARCHIVE"
      ;;
  esac
}

### main #######################################################################

# Nothing here.
