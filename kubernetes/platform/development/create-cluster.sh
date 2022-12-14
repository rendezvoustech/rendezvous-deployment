#!/bin/sh

echo "\nš¦ Initializing Kubernetes cluster...\n"

minikube start --cpus 2 --memory 4g --driver docker --profile rendezvous

echo "\nš Enabling NGINX Ingress Controller...\n"

minikube addons enable ingress --profile rendezvous

sleep 30

echo "\nš¦ Deploying Keycloak..."

kubectl apply -f services/keycloak-config.yml
kubectl apply -f services/keycloak.yml

sleep 5

echo "\nā Waiting for Keycloak to be deployed..."

while [ $(kubectl get pod -l app=rendezvous-keycloak | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\nā Waiting for Keycloak to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=app=rendezvous-keycloak \
  --timeout=300s

echo "\nš¦ Deploying PostgreSQL..."

kubectl apply -f services/postgresql.yml

sleep 5

echo "\nā Waiting for PostgreSQL to be deployed..."

while [ $(kubectl get pod -l db=rendezvous-postgres | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\nā Waiting for PostgreSQL to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=db=rendezvous-postgres \
  --timeout=180s

echo "\nš¦ Deploying Redis..."

kubectl apply -f services/redis.yml

sleep 5

echo "\nā Waiting for Redis to be deployed..."

while [ $(kubectl get pod -l db=rendezvous-redis | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\nā Waiting for Redis to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=db=rendezvous-redis \
  --timeout=180s

echo "\nš¦ Deploying RabbitMQ..."

kubectl apply -f services/rabbitmq.yml

sleep 5

echo "\nā Waiting for RabbitMQ to be deployed..."

while [ $(kubectl get pod -l db=rendezvous-rabbitmq | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\nā Waiting for RabbitMQ to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=db=rendezvous-rabbitmq \
  --timeout=180s

echo "\nš¦ Deploying Rendezvous UI..."

kubectl apply -f services/rendezvous-ui.yml

sleep 5

echo "\nā Waiting for Rendezvous UI to be deployed..."

while [ $(kubectl get pod -l app=rendezvous-ui | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\nā Waiting for Rendezvous UI to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=app=rendezvous-ui \
  --timeout=180s

echo "\nāµ Happy Sailing!\n"