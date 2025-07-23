# SPDX-FileCopyrightText: 2024 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Cach errors and print message.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### variables ##################################################################

# Nothing here.

### functions ##################################################################

function error_catch
{
  local rc=$1

  local index=0
  local output
  local fg_yellow_bright="\033[0;93m"
  local fg_reset="\033[0;0m"

  while output=$(caller $index); do
    if [ $index -eq 0 ]; then
      echo_e "rc=$rc $fg_yellow_bright$BASH_COMMAND$fg_reset"
    fi

    echo_e "$output"
    ((index+=1))
  done

  exit "$rc"
}

### aliases ####################################################################

alias error_trace_enable='set -o errtrace; trap '\''error_catch ${?}'\'' ERR'
alias error_trace_disable='trap - ERR'

### main #######################################################################

shopt -s expand_aliases
