#!/bin/sh

echo "\n🏴️ Destroying Kubernetes cluster...\n"

minikube stop --profile rendezvous

minikube delete --profile rendezvous

echo "\n🏴️ Cluster destroyed\n"