#!/bin/bash

set -e

echo "=== Bootstrap TodoApp Deployment ==="

echo "1. Creating Kind cluster..."
kind create cluster --config cluster.yml

echo "2. Waiting for cluster to be ready..."
kubectl wait --for=condition=ready node --all --timeout=300s

echo "3. Inspecting nodes..."
kubectl get nodes --show-labels
kubectl describe nodes | grep -E "(Name:|Taints:|Labels:)" -A 2

echo "4. Adding taint to MySQL nodes..."
kubectl taint nodes $(kubectl get nodes -l app=mysql -o jsonpath='{.items[0].metadata.name}') app=mysql:NoSchedule

echo "5. Verifying taints..."
kubectl describe nodes | grep -E "(Name:|Taints:)" -A 1

echo "6. Building helm dependencies..."
cd helm-chart/todoapp
helm dependency build
cd ../..

echo "7. Deploying TodoApp helm chart..."
helm install todoapp ./helm-chart/todoapp --create-namespace

echo "8. Waiting for deployments..."
kubectl wait --for=condition=available deployment -l app=todoapp -n todoapp-ns --timeout=300s

echo "9. Getting all resources..."
kubectl get all,cm,secret,ing -A > output.log

echo "=== Deployment Complete ==="
echo "Check output.log for all deployed resources"