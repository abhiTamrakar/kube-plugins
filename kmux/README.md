# README.md

## KMUX

KMUX is a simple script that can slo be used as a kubernetes plugin. It follows the tail of all pods and containers in a kubernetes cluster and displays them in multiple terminals using tmux.
* Pods are created as new windows
* CONTAINERS are created as splited panes inside the windows.

![alt text](https://raw.githubusercontent.com/abhiTamrakar/kube-plugins/master/kmux/kmux.png)

#### Pre-requisites
* kubectl installed.
* tmux >= 2.1
(Tmux is a terminal multiplexer that helps in creating multiple terminals.)
