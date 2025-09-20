# Local Kubernetes Setup Guide

## Prerequisites Setup

### 1. Start Docker Desktop
```bash
# Open Docker Desktop app or start Docker daemon
# Verify Docker is running:
docker ps
```

### 2. Enable Kubernetes in Docker Desktop
1. Open Docker Desktop
2. Go to Settings → Kubernetes
3. Check "Enable Kubernetes"
4. Apply & Restart

### 3. Verify k8s is running
```bash
kubectl cluster-info
kubectl get nodes
```

## Install Nginx Ingress Controller (Optional)

**Option 1: Docker Desktop (Recommended)**
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

# Wait for it to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

**Option 2: Kind/Minikube**
```bash
# For minikube
minikube addons enable ingress

# For kind
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/kind/deploy.yaml
```

## Test the Galaxy App

### 1. Run Tests
```bash
./dev test
```

### 2. Build and Deploy
```bash
./dev run
```

### 3. Access the App

**With Ingress (Recommended):**
```bash
# Add to /etc/hosts (one-time setup)
echo "127.0.0.1 galaxy-local.localhost" | sudo tee -a /etc/hosts

# Access directly
curl http://galaxy-local.localhost
open http://galaxy-local.localhost
```

**With Port Forward (Fallback):**
```bash
kubectl port-forward -n local svc/galaxy-local 8080:80
curl http://localhost:8080
```

### 4. View Deployment Status
```bash
kubectl get all -n local
kubectl logs -n local -l app.kubernetes.io/name=galaxy
```

## Quick Test Commands

```bash
# Full clean build and deploy
./dev run --clean

# Check if app is responding
curl -i http://galaxy-local.localhost

# View logs
kubectl logs -n local -l app.kubernetes.io/name=galaxy -f

# Clean up
helm uninstall galaxy-local -n local
kubectl delete namespace local
```

## Troubleshooting

### Docker Issues
```bash
# Check Docker
docker version
docker ps

# Restart Docker Desktop if needed
```

### Kubernetes Issues
```bash
# Check cluster
kubectl cluster-info
kubectl get nodes

# Check context
kubectl config current-context
kubectl config get-contexts
```

### Ingress Issues
```bash
# Check ingress controller
kubectl get pods -n ingress-nginx

# Check ingress resource
kubectl get ingress -n local

# Check service
kubectl get svc -n local
```

### App Issues
```bash
# Check deployment
kubectl get deployment -n local
kubectl describe deployment galaxy-local -n local

# Check pods
kubectl get pods -n local
kubectl describe pod -l app.kubernetes.io/name=galaxy -n local

# Check logs
kubectl logs -l app.kubernetes.io/name=galaxy -n local
```