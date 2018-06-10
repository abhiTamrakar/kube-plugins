#!/bin/bash
# AUTHOR: Abhishek Tamrakar
# EMAIL: abhishek.tamrakar08@gmail.com
# VERSION: 0.0.1
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
TMUX=$(which tmux)
DOCKER=$(which docker)
COMMAND=''
readonly KUBE_DEFAULT=~/.kube/config
SCRIPT=${0##*/}
NEWSESSION="${SCRIPT%%.*}$RANDOM"
VERBOSE=0
# define functions
info()
{
  if [ $VERBOSE -eq 1 ]; then
    #statements
    printf '\n%s:%20s\n' "info" "$@"
  fi
}

warn()
{
  if [ $VERBOSE -eq 1 ]; then
    #statements
    printf '\n%s:%20s\n' "warn" "$@"
  fi
}

fatal()
{
  printf '\n%s:%20s\n' "error" "$@"
  exit 1
}

usage()
{
  cat <<EOF
  USAGE: $SCRIPT [options]

  [options]
  help|h      Display this usage and exit.

  verbose|v   Enable verbose output.

  session|s   Sets Session name, otherwise defaultis set.

  kube|k      Tails pod log on kubernetes cluster.
              NOTE:Can also be used as kubernetes plugin.

  logs|l      Tails all logfiles inside a directory.

  docker|d    Tails all docker running container logs.
EOF
  exit 0
}

check_commands()
{
  local EXT=$1
  CMDS=(GET AWK TMUX $EXT)
  for cmd in ${CMDS[@]}
  do
     if [ x${!cmd} = x ]; then
       fatal "${!cmd} not found"
     fi
  done
}

destroy()
{
  $TMUX kill-server \
    && info "All sessions killed" \
    || fatal "KILL failed! Was the server even running?"
}

check_arguments()
{
  if [[  x$1 = x || $1 =~ ^-[A-Za-z0-9]+ ]]; then
    #statements
    usage
    fatal "Argument is required!"
  fi
}

start_server()
{
  $TMUX start-server \
    || fatal "Failed to start tmux server"
}

check_session()
{
  if $TMUX has-session -t $NEWSESSION 2>/dev/null;
  then
    is_session=0
  else
    is_session=1
  fi
}

create_session()
{
  $TMUX new-session -d -s $NEWSESSION \
    || fatal "Cannot create session"
  $TMUX set-window-option -g automatic-rename on
}

start_split()
{
  check_session
  if [ $is_session -eq 1 ]; then
    # create session
    start_server
    create_session
  fi
  $TMUX selectp -t $n
  if [ $n -eq 0 ]; then
    # start new window
    $TMUX neww $COMMAND
  else
    $TMUX splitw $COMMAND
    $TMUX select-layout tiled
  fi
}

run_kube_command()
{
  if [ x$NAMESPACE = x ]; then
    # cant go ahead without namespace, a cluster could have numerous pods.
    fatal "NAMESPACE is not defined, see usage."
  fi
  n=0
  while IFS=' ' read -r POD CONTAINERS
  do
    for CONTAINER in ${CONTAINERS//,/ }
    do
      if [ x$POD = x -o x$CONTAINER = x ]; then
        # if any of the values is null, exit.
        warn "Looks like there is a problem getting pods data."
        break
      fi
      COMMAND="$KUBE logs --since=1h --tail=20 $POD -c $CONTAINER -n $NAMESPACE"
      start_split
    done
    ((n+=1))
  done< <($KUBE get pods -n $NAMESPACE --ignore-not-found=true -o=custom-columns=NAME:.metadata.name,CONTAINERS:.spec.containers[*].name|sed '1d')
}

run_docker_command()
{
  n=0
  CONTAINERS=($(sudo $DOCKER ps| awk '/Up/ {print $1}' ORS=' '))
  for CONTAINER in ${CONTAINERS[@]}
  do
    COMMAND="sudo $DOCKER logs -f $CONTAINER"
    start_split
    ((n+=1))
  done
}

run_tail_command()
{
  n=0
  LOGFILES=($(sudo find ${LOGLOCATION}/ -type f -iname "*.log"| xargs echo))
  for LOG in ${LOGFILES[@]}
  do
    COMMAND="sudo tailf $LOG"
    start_split
    ((n+=1))
  done
}

attach_sessions()
{
  if [ x$NEWSESSION = x ]
  then
    usage
  fi
  $TMUX selectw -t $NEWSESSION:1 \; \
  attach-session -t $NEWSESSION\; \
  setw -g monitor-activity on \; \
  set -g visual-activity on \; \
  set-window-option -g window-status-current-bg yellow \; \
  set-option -g mouse-select-pane on \;
}
#
# interrupt or quit
trap destroy 2 3 15
#
while [ $# -ne 0 ]
do
  option=${1//-/}
  case $option in
    help|h ) usage
      ;;
    verbose|v ) VERBOSE=1
      ;;
    session|s ) shift;
      check_arguments $1;
      NEWSESSION=$1
      ;;
    kube|k ) check_commands $KUBE
      shift;
      ARGS=$1
      # extract the information
      CONFIG=${ARGS%%,*}
      PART=${ARGS##*,}
      export $CONFIG
      export $PART
      if [[ ! -e $KUBE_CONFIG || ! -s $KUBE_CONFIG ]]; then
        # provided config doesnt match
        if [[ -e $KUBE_DEFAULT && -s $KUBE_DEFAULT ]]; then
          # use default
          KUBE_CONFIG=$KUBE_DEFAULT
          export KUBECONFIG=$KUBE_CONFIG
        else
          fatal "Cannot find kube-config!"
        fi
      fi
      run_kube_command
      ;;
    logs|l ) shift;
      check_arguments $1;
      LOGLOCATION=$1
      [ -d $LOGLOCATION -a -s $LOGLOCATION ] || fatal "Log location cannot be found!"
      run_tail_command
      ;;
    docker|d ) check_commands DOCKER
      run_docker_command
      ;;
  esac
  shift
done
#
attach_sessions
