#!/bin/sh

set -euo pipefail

echo "\nš¦ Deploying Rendezvous UI..."

kubectl apply -f resources

echo "ā Waiting for Rendezvous UI to be deployed..."

while [ $(kubectl get pod -l app=rendezvous-ui | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\nā Waiting for Rendezvous UI to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=app=rendezvous-ui \
  --timeout=180s

echo "\nš¦ Rendezvous UI deployment completed.\n"