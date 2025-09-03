# TodoApp Helm Chart Deployment Instructions


## Prerequisites
- Docker installed and running
- kubectl installed
- helm installed
- kind installed


## Validation Steps

# Считать namespace из values.yaml
NS=$(yq eval '.namespace.name' ./helm-chart/todoapp/values.yaml)


### 1. Execute Bootstrap Script
chmod +x bootstrap.sh
./bootstrap.sh


### 2. Verify Cluster Creation
kubectl cluster-info
kubectl get nodes --show-labels


### 3. Check Node Taints
kubectl describe nodes | grep -E "(Name:|Taints:)" -A 1

Verify that nodes labeled with `app=mysql` have `app=mysql:NoSchedule` taint.

### 4. Verify Helm Chart Deployment
helm list -A
kubectl get all -n $NS


### 5. Check Dependencies
helm dependency list ./helm-chart/todoapp


### 6. Verify MySQL StatefulSet
kubectl get statefulset -n $NS
kubectl get pvc -n $NS


### 7. Verify TodoApp Deployment
kubectl get deployment -n $NS
kubectl get hpa -n $NS


### 8. Check Secrets
kubectl get secrets -n $NS
kubectl describe secret todoapp-secret -n $NS
kubectl describe secret mysql-secret -n $NS


### 9. Verify RBAC
kubectl get serviceaccount -n $NS
kubectl get role -n $NS
kubectl get rolebinding -n $NS


### 10. Check Pod Scheduling
kubectl get pods -n $NS -o wide

Verify that MySQL pods are scheduled on nodes with `app=mysql` label and TodoApp pods respect node affinity.

### 11. View Complete Resource List
cat output.log


## Expected Results
- Kind cluster with 1 control-plane and 2 worker nodes
- One worker node labeled with `app=mysql` and tainted with `app=mysql:NoSchedule`
- TodoApp namespace created
- MySQL StatefulSet with 1 replica running on tainted node
- TodoApp Deployment with HPA configured
- All secrets created using range function
- Service accounts and RBAC configured
- PV and PVC created and bound
- All resources use Chart.Name as prefix


## Cleanup
helm uninstall todoapp -n $NS
kubectl delete namespace $NS
kind delete cluster --name todoapp-cluster


## Troubleshooting
- If pods are pending, check node affinity and taints
- If MySQL fails to start, check PVC binding
- If secrets are missing, verify values.yaml configuration
- Check pod logs: `kubectl logs <pod-name> -n $NS`