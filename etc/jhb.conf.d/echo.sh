# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Provide colorful convenience functions for echo.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### variables ##################################################################

ECHO_FG_BLACK_BRIGHT="\033[0;90m"
ECHO_FG_BLUE_BOLD="\033[1;34m"
ECHO_FG_BLUE_BRIGHT="\033[0;94m"
ECHO_FG_GREEN_BRIGHT="\033[0;92m"
ECHO_FG_RED_BRIGHT="\033[0;91m"
ECHO_FG_RESET="\033[0;0m"
ECHO_FG_YELLOW_BRIGHT="\033[0;93m"

### functions ##################################################################

function echo_message
{
  local funcname=$1   # empty if outside function
  local filename=$2
  local type=$3
  local color=$4
  local args=${*:5}

  if [ -z "$funcname" ] || [ "$funcname" = "source" ]; then
    funcname=$(basename "$filename")
  fi

  echo -e "${color}$type:$ECHO_FG_RESET $args ${ECHO_FG_BLACK_BRIGHT}[$funcname]$ECHO_FG_RESET"
  # non-color version
  # echo "$type: $args [$funcname]"
}

### aliases ####################################################################

alias echo_d='>&2 echo_message "$FUNCNAME" "${BASH_SOURCE[0]}" "debug" "$ECHO_FG_BLUE_BOLD"'
alias echo_e='>&2 echo_message "$FUNCNAME" "${BASH_SOURCE[0]}" "error" "$ECHO_FG_RED_BRIGHT"'
alias echo_i='>&2 echo_message "$FUNCNAME" "${BASH_SOURCE[0]}" "info" "$ECHO_FG_BLUE_BRIGHT"'
alias echo_o='>&2 echo_message "$FUNCNAME" "${BASH_SOURCE[0]}" "ok" "$ECHO_FG_GREEN_BRIGHT"'
alias echo_w='>&2 echo_message "$FUNCNAME" "${BASH_SOURCE[0]}" "warning" "$ECHO_FG_YELLOW_BRIGHT"'

### main #######################################################################

shopt -s expand_aliases
