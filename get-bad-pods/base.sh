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
KUBE=$(which kubectl)
GET=$(which egrep)
AWK=$(which awk)

# define functions
info()
{
  printf '\n%s:%20s\n' "info" "$@"
}

fatal()
{
  printf '\n%s:%20s\n' "error" "$@"
  exit 1
}

checkcmd()
{
  #check if command exists
  local iscmd=$1
  if [ ! -e "$iscmd" -a ! -s "$iscmd" ]
  then
    fatal "$iscmd MISSING"
  fi
}

print_table()
{
  #prepare the ground
  sep='|'
  printf '\n%s\t%45s\t%18s\n' "POD NAME" "CONTAINER NAME" "NUMBER OF ERROR/EXCEPTION"
  printf '%s\n' "---------------------------------------------------------------------------"
  printf '%s\n' "$@"| column -s"$sep" -t
  printf '\n'
}

get_namespaces()
{
  #get namespaces
  namespaces=( \
          $($KUBE get namespaces --ignore-not-found=true | \
          $AWK '/Active/ {print $1}' \
          ORS=" ") \
          )
#exit if namespaces are not found
if [ ${#namespaces[@]} -eq 0 ]
then
  fatal "No namespaces found!!"
fi
}

#define the logic
get_pod_errors()
{
  for NAMESPACE in ${namespaces[@]}
  do
    info "Getting errored pods for Namespace: $NAMESPACE"
    while IFS=' ' read -r POD CONTAINERS
    do
      for CONTAINER in ${CONTAINERS//,/ }
      do
        STATE=("${STATE[@]}" \
        "$POD|$CONTAINER|$($KUBE logs --since=1h --tail=20 $POD -c $CONTAINER -n $NAMESPACE 2>/dev/null| \
        $GET -ci 'error|exception')" \
        )
      done
    done< <($KUBE get pods -n $NAMESPACE --ignore-not-found=true -o=custom-columns=NAME:.metadata.name,CONTAINERS:.spec.containers[*].name|sed '1d')
    print_table ${STATE[@]:-None}
    STATE=()
  done
}
