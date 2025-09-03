# TodoApp Helm Chart Deployment Instructions

## Prerequisites
- Docker installed and running
- kubectl installed
- helm installed
- kind installed

## Validation Steps

### 1. Execute Bootstrap Script
```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

### 2. Verify Cluster Creation
```bash
kubectl cluster-info
kubectl get nodes --show-labels
```

### 3. Check Node Taints
```bash
kubectl describe nodes | grep -E "(Name:|Taints:)" -A 1
```
Verify that nodes labeled with `app=mysql` have `app=mysql:NoSchedule` taint.

### 4. Verify Helm Chart Deployment
```bash
helm list -A
kubectl get all -n todoapp-ns
```

### 5. Check Dependencies
```bash
helm dependency list ./helm-chart/todoapp
```

### 6. Verify MySQL StatefulSet
```bash
kubectl get statefulset -n todoapp-ns
kubectl get pvc -n todoapp-ns
```

### 7. Verify TodoApp Deployment
```bash
kubectl get deployment -n todoapp-ns
kubectl get hpa -n todoapp-ns
```

### 8. Check Secrets
```bash
kubectl get secrets -n todoapp-ns
kubectl describe secret todoapp-secret -n todoapp-ns
kubectl describe secret mysql-secret -n todoapp-ns
```

### 9. Verify RBAC
```bash
kubectl get serviceaccount -n todoapp-ns
kubectl get role -n todoapp-ns
kubectl get rolebinding -n todoapp-ns
```

### 10. Check Pod Scheduling
```bash
kubectl get pods -n todoapp-ns -o wide
```
Verify that MySQL pods are scheduled on nodes with `app=mysql` label and TodoApp pods respect node affinity.

### 11. View Complete Resource List
```bash
cat output.log
```

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
```bash
helm uninstall todoapp -n todoapp-ns
kubectl delete namespace todoapp-ns
kind delete cluster --name todoapp-cluster
```

## Troubleshooting
- If pods are pending, check node affinity and taints
- If MySQL fails to start, check PVC binding
- If secrets are missing, verify values.yaml configuration
- Check pod logs: `kubectl logs <pod-name> -n todoapp-ns`