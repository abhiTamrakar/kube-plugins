# kube-plugins
a repository for plugins and scripts for kubernetes

# Pre-requisites
* kubectl >= 1.12.x
* tmux >= 2.1
(Tmux is a terminal multiplexer that helps in creating multiple terminals.)

# Installation
* git clone https://github.com/abhiTamrakar/kube-plugins.git
* cd kube-plugins

## USAGE
* TO use as K8S Plugin, name convention is kubectl-<plugin name>-<argument>
* Copy the plugin script to /usr/local/bin/
* Run below command to see available plugins
```
$ kubectl plugin -h
```

* Execute
```
kubectl <plugin-name> <arguments>
```

* To use as utility script, use as is.
