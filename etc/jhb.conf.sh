# SPDX-FileCopyrightText: 2022 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# This is a convenience wrapper to source all individual configuration files
# from jhb.conf.d directory. It supports customizing that configuration in
# downstream projects by looking for pre.conf.d and post.conf.d directories
# on the same level where jhb has been cloned to as submodule.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### dependencies ###############################################################

# Nothing here.

### variables ##################################################################

# Nothing here.

### functions ##################################################################

# Nothing here.

### main #######################################################################

_SELF_DIR=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1
  pwd
)

_DIRS=$_SELF_DIR/jhb.conf.d
# shellcheck disable=SC1073 # this is more readable
# iterate through all conf.d directories
for _DIR in "$_SELF_DIR"{/.,/../../}*{pre,post}.conf.d; do
  # Check if _DIR is actually a valid/existing directory. Otherwise we
  # end up adding an unresolved wildcard expression to _DIRS.
  if [ -d "$_DIR" ]; then
    # Decide if the directory needs to prepended or appended to the list.
    if [[ $_DIR = *pre* ]]; then
      _DIRS="$_DIR $_DIRS"  # prepend
    else
      _DIRS="$_DIRS $_DIR"  # append
    fi
  fi
done

# source items from configuration directories
for _DIR in $_DIRS; do
  for _FILE in $("$_SELF_DIR"/../usr/bin/run-parts list "$_DIR"/'*.sh'); do
    # shellcheck disable=SC1090 # can't point to a single source here
    source "$_FILE"
  done
done

unset _FILE _DIR _DIRS
unset _SELF_DIR
