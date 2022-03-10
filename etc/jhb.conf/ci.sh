# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# check if running in CI (GitHub or GitLab)

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # we only use exports if we really need them

### variables ##################################################################

if [ -z "$CI" ]; then   # both GitHub and GitLab set this
  CI=false
  CI_GITHUB=false
  CI_GITLAB=false
else
  CI=true

  if [ -z "$CI_PROJECT_NAME" ]; then  # this is a GitLab-only variable
    CI_GITHUB=true
    CI_GITLAB=false
  else
    CI_GITHUB=false
    CI_GITLAB=true

    # Since GitLab uses colors in their CI there's no need to disable ours.
    # shellcheck disable=SC2034 # this is a bash_d setting
    ANSI_TERM_ONLY=false   # use ANSI control characters even if not in terminal
  fi
fi

### functions ##################################################################

# Nothing here.

### main #######################################################################

# Nothing here.