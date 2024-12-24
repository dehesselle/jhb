# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# check if running in CI (GitHub or GitLab)

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # we only use exports if we really need them

### variables ##################################################################

if [ -z "$CI" ]; then # both GitHub and GitLab set this
  CI=false
else
  CI=true

  if [ -z "$CI_PROJECT_DIR" ]; then # Is this GitHub?
    # It is, so we need to set this (GitLab-only) variable ourselves.
    CI_PROJECT_DIR=$GITHUB_WORKSPACE
  fi
fi

### functions ##################################################################

function ci_gitlab_add_metadata
{
  local plist=$1

  # add some metadata to make CI identifiable
  for var in PROJECT_NAME PROJECT_URL COMMIT_BRANCH COMMIT_SHA \
    COMMIT_SHORT_SHA JOB_ID JOB_URL JOB_NAME PIPELINE_ID PIPELINE_URL; do
    # use awk to create camel case strings (e.g. PROJECT_NAME to ProjectName)
    /usr/libexec/PlistBuddy -c "Add CI$(
      echo $var | awk -F _ '{
        for (i=1; i<=NF; i++)
        printf "%s", toupper(substr($i,1,1)) tolower(substr($i,2))
      }'
    ) string $(eval echo \$CI_$var)" "$plist"
  done
}

### main #######################################################################

# Nothing here.
