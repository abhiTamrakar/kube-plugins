# README.md

## QMUX

QMUX is a kubernetes plugin that follows the tail of all pods and containers in a kubernetes cluster.
* Pods are created as new windows
* CONTAINERS are created as splited panes inside the windows.

#### Pre-requisites
* kubectl installed.
* tmux >= 2.1
(Tmux is a terminal multiplexer that helps in creating multiple terminals.)

#### Usage
kubectl plugin qmux -h
