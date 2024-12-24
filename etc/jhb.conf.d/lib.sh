# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Provide convenience wrappers for install_name_tool.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### variables ##################################################################

LIB_RESET_ID=keep   # options: basename, canonical, keep

### functions ##################################################################

function lib_change_path
{
  # Compared to install_name_tool, this function
  #   - requires less arguments as 'source' can be deducted from 'target'
  #   - can apply the requested changes to multiple binaries at once

  local target=$1         # new path to dynamically linked library
  local binaries=${*:2}   # binaries to modify

  local source_lib=${target##*/}   # get library filename from target location

  for binary in $binaries; do   # won't work if spaces in paths
    if [[ $binary == *.so ]] ||
       [[ $binary == *.dylib ]] ||
       [ $(file $binary | grep "shared library" | wc -l) -eq 1 ]; then
      lib_reset_id $binary
    fi

    local source=$(otool -L $binary | grep "$source_lib " | awk '{ print $1 }')
    if [ -z $source ]; then
      echo_w "no $source_lib in $binary"
    else
      # Reconstructing 'target' as it might have been specified as regex.
      target=$(dirname $target)/$(basename $source)

      install_name_tool -change $source $target $binary
    fi
  done
}

function lib_change_paths
{
  # This is a wrapper ontop lib_change_path: given a directory 'lib_dir' that
  # contains the libraries, all (matching) libraries linked in 'binary' can be
  # changed at once to a specified 'target' path.

  local target=$1         # new path to dynamically linked library
  local lib_dir=$2
  local binaries=${*:3}

  for binary in $binaries; do
    for linked_lib in $(otool -L $binary | tail -n +2 | awk '{ print $1 }'); do
      if [ "$(basename $binary)" != "$(basename $linked_lib)" ] &&
         [ -f $lib_dir/$(basename $linked_lib) ]; then
        lib_change_path $target/$(basename $linked_lib) $binary
      fi
    done
  done
}

function lib_change_siblings
{
  # This is a wrapper ontop lib_change_path: all libraries inside a given
  # 'lib_dir' that are linked to libraries located in that same 'lib_dir' can
  # be automatically adjusted.

  local lib_dir=$1

  for lib in $lib_dir/*.dylib; do
    lib_reset_id $lib
    for linked_lib in $(otool -L $lib | tail -n +2 | awk '{ print $1 }'); do
      if [ "$(basename $lib)" != "$(basename $linked_lib)" ] &&
         [ -f $lib_dir/$(basename $linked_lib) ]; then
        lib_change_path @loader_path/$(basename $linked_lib) $lib
      fi
    done
  done
}

function lib_reset_id
{
  local lib=$1

  case "$LIB_RESET_ID" in
    basename)
      install_name_tool -id $(basename $lib) $lib
      ;;
    canonical)
      install_name_tool -id $(greadlink -f $lib) $lib
      ;;
    keep)
      : # don't do anything
      ;;
    *)
      echo_e "invalid value for LIB_RESET_ID: $LIB_RESET_ID"
      ;;
  esac
}

function lib_add_rpath
{
  local rpath=$1
  local binary=$2

  install_name_tool -add_rpath "$rpath" "$binary"
}

function lib_clear_rpath
{
  local binary=$1

  for rpath in $(otool -l $binary | grep -A2 LC_RPATH | grep -E "^[ ]+path" | awk '{ print $2 }'); do
    install_name_tool -delete_rpath $rpath $binary
  done
}

function lib_replace_path
{
  local source=$1
  local target=$2
  local binary=$3

  for lib in $(lib_get_linked $binary); do
    if [[ $lib =~ $source ]]; then
      lib_change_path @rpath/$(basename $lib) $binary
    fi
  done
}

function lib_get_linked
{
  local binary=$1   # can be executable or library

  #echo_d "binary: $binary"

  local filter   # we need to distinguish between executable and library

  local file_type
  file_type=$(file "$binary")
  if   [[ $file_type = *"shared library"* ]]; then
    filter="-v $(otool -D "$binary" | tail -n 1)"  # exclude library id
  elif [[ $file_type = *"executable"* ]]; then
    filter="-E [.]+"                               # include everything
  else
    echo_w "neither shared library nor executable: $binary"
    return 1
  fi

  # since we're not echoing this, output will be newline-separated
  # shellcheck disable=SC2086 # need word splitting for arguments
  otool -L "$binary" | grep " " | grep $filter | awk '{ print $1 }'
}

### main #######################################################################

# Nothing here.
