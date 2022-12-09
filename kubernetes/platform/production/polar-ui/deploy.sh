#!/bin/sh

set -euo pipefail

echo "\n📦 Deploying Rendezvous UI..."

kubectl apply -f resources

echo "⌛ Waiting for Rendezvous UI to be deployed..."

while [ $(kubectl get pod -l app=rendezvous-ui | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for Rendezvous UI to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=app=rendezvous-ui \
  --timeout=180s

echo "\n📦 Rendezvous UI deployment completed.\n"