#!/bin/bash
# AUTHOR: Abhishek Tamrakar
# EMAIL: abhishek.tamrakar08@gmail.com
# LICENSE: Copyright (C) 2018 Abhishek Tamrakar
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
#define the variables
KUBE_LOC=~/.kube/config
#check base files
if [ -e ./base.sh -a -s ./base.sh ]
then
  . ./base.sh
else
  fatal "failed to initialize"
fi
#define usage for seprate run
usage()
{
cat << EOF

  USAGE: "${0##*/} </path/to/kube-config>(optional)"

  This program is a free software under the terms of Apache 2.0 License.
  COPYRIGHT (C) 2018 Abhishek Tamrakar

EOF
exit 0
}

#check if basic commands are found
for cmd in $KUBE $GET $AWK;
do
  checkcmd $cmd
done
#
#set the ground
if [ $# -lt 1 ]; then
  if [ ! -e ${KUBE_LOC} -a ! -s ${KUBE_LOC} ]
  then
    info "A readable kube config location is required!!"
    usage
  fi
elif [ $# -eq 1 ]
then
  export KUBECONFIG=$1
elif [ $# -gt 1 ]
then
  usage
fi
#play
get_namespaces
get_pod_errors
