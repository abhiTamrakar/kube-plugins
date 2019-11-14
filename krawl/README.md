# README.md

## KRAWL

KRAWL is a simple script that scans pods and containers under the namespaces on k8s clusters and displays the output with events, if found. It can also be used as kubernetes plugin for the same usage.

#### Pre-requisites
* kubectl installed.
* Your clusters kubeconfig either in its default location ($HOME/.kube/config) or exported (KUBECONFIG=/path/to/kubeconfig)

#### Usage
$ bash krawl
$ ./krawl
