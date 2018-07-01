#!/bin/bash
# AUTHOR: Abhishek Tamrakar
# EMAIL: abhishek.tamrakar08@gmail.com
#	LICENSE: Copyright (C) 2018 Abhishek Tamrakar
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
##
#define variables
GET=$(which egrep)
AWK=$(which awk)
KUBE_DIR="$HOME/.kube/plugins"
SCRIPT=${0##*/}
# define functions
info()
{
  printf '\n%s %s: %s' "[${SCRIPT%%.*}]" "INFO" "$@"
}

fatal()
{
  printf '\n%s %s: %s\n' "[${SCRIPT%%.*}]" "ERROR" "$@"
  exit 1
}

usage() {
  # define usage
  cat << EOF

  Copyright (C) 2018 Abhishek Tamrakar

  USAGE: $SCRIPT <PLUGIN_DIR1> <PLUGIN_DIR2> ..

  Example:
    $SCRIPT qmux
    $SCRIPT qmux qcheck

  Note: Default plugin directory = $HOME/.kube/plugins

EOF
}

get_permissions()
{
  local directory=$1
  local owner=$(stat -c %U $directory)
  local user=$(whoami)
  if [[ "$owner" != "$user" && "$user" != "root" ]]; then
    # if current user is not owner
    fatal "the plugin directory $directory, is owned by $owner, please consider using sudo"
  fi
}
#
if [[ ! -d $KUBE_DIR ]]; then
  # create directory
  mkdir -p $KUBE_DIR \
    && info "plugin directory created" \
    || fatal "cannot create $KUBE_DIR"
fi
if [[ $# -ne 0 ]]; then
  # check input
  for dir in "$@"
  do
    PLUGIN_DIR=$dir
    if [[ -d $PLUGIN_DIR ]]; then
      # perform operation
      get_permissions $PLUGIN_DIR
      info "installing $PLUGIN_DIR.."
      cp -rp $PLUGIN_DIR $KUBE_DIR/ \
        && echo -e " [DONE]" \
        || { echo -e " [FAILED]";fatal "Cannot complete request"; }
    else
      fatal "no such directory with name $PLUGIN_DIR"
    fi
  done
else
  usage
  fatal "this script need arguments."
fi
