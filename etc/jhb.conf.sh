# SPDX-FileCopyrightText: 2022 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# This is a convenience wrapper to source all individual configuration files.
# It also takes care of placing a custom configuration file in the appropriate
# location.

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

_CALLER_DIR=$(
  cd "$(dirname "${BASH_SOURCE[${#BASH_SOURCE[@]}]}")" || exit 1
  pwd
)

# iterate through all .conf.d directories
for _DIR in "$_CALLER_DIR"/*.conf.d "$_SELF_DIR"/*.conf.d; do
  # First check if (at least one) directory exists (as there is a wildcard).
  # Otherwise we end up adding an unresolvable expression to the _DIRS which
  # would lead to errors later. This is specifically meant to catch cases
  # where _CALLER_DIR contains no configuration subdirectory.
  if [ -d "$_DIR" ]; then
    # make sure we're not creating duplicate entries
    if [[ "$_DIRS" != *"$(basename "$_DIR")"* ]]; then
      # make sure that job.conf.d is the last item in the list so other
      # configuration directories take precedence
      if [ "$(basename "$_DIR")" = "jhb.conf.d" ]; then
        _DIRS="$_DIRS $_DIR"
      else
        _DIRS="$_DIR $_DIRS"
      fi
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
unset _SELF_DIR _CALLER_DIR
