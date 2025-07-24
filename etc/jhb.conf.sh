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

function _get_self_dir
{
  echo "$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1
    pwd
  )"
}

function _get_jhb_conf_dirs
{
  local conf_dirs
  conf_dirs=$(_get_self_dir)/jhb.conf.d

  # iterate through all conf.d directories
  for dir in "$(_get_self_dir)"{/,/../../}*{pre,post}.conf.d; do
    # Check if dir is actually a valid/existing directory. Otherwise we
    # end up adding an unresolved wildcard expression to conf_dirs.
    if [ -d "$dir" ]; then
      # Decide if the directory needs to prepended or appended to the list.
      if [[ $dir = *pre* ]]; then
        conf_dirs="$dir $conf_dirs"  # prepend
      else
        conf_dirs="$conf_dirs $dir"  # append
      fi
    fi
  done

  echo "$conf_dirs"
}

### main #######################################################################

# source items from configuration directories
for DIR in $(_get_jhb_conf_dirs); do
  for FILE in $("$(_get_self_dir)"/../usr/bin/run-parts list "$DIR"/'*.sh'); do
    # shellcheck disable=SC1090 # can't point to a single source here
    source "$FILE"
  done
done

unset FILE DIR
