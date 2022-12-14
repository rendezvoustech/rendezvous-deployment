#!/bin/sh

set -euo pipefail

echo "\nšļø  Keycloak deployment started.\n"

echo "š¦ Installing Keycloak..."

clientSecret=$(echo $ random | openssl md5 | Head -c 20)

kubectl apply -f resources/namespace.yml
sed "s/rendezvous-keycloak-secret/$clientSecret/" resources/keycloak-config.yml | kubectl apply -f -

echo "\nš¦ Configuring Helm chart..."

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm upgrade --install rendezvous-keycloak bitnami/keycloak \
  --values values.yml \
  --namespace keycloak-system

echo "\nā Waiting for Keycloak to be deployed..."

sleep 15

while [ $(kubectl get pod -l app.kubernetes.io/component=keycloak -n keycloak-system | wc -l) -eq 0 ] ; do
  sleep 15
done

echo "\nā Waiting for Keycloak to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=keycloak \
  --timeout=600s \
  --namespace=keycloak-system

echo "\nā  Keycloak cluster has been successfully deployed."

echo "\nš Your Keycloak Admin credentials...\n"

echo "Admin Username: user"
echo "Admin Password: $(kubectl get secret --namespace keycloak-system rendezvous-keycloak -o jsonpath="{.data.admin-password}" | base64 --decode)"

echo "\nš Generating Secret with Keycloak client secret."

kubectl delete secret rendezvous-keycloak-client-credentials || true

kubectl create secret generic rendezvous-keycloak-client-credentials \
    --from-literal=spring.security.oauth2.client.registration.keycloak.client-secret="$clientSecret"

echo "\nš A 'rendezvous-keycloak-client-credentials' has been created for Spring Boot applications to interact with Keycloak."

echo "\nšļø  Keycloak deployment completed.\n"