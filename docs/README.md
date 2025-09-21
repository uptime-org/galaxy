# Galaxy

Production-ready Flask application with complete CI/CD pipeline, Helm deployment, and local development environment.

## Quick Start

**Prerequisites:** Docker Desktop with Kubernetes enabled

```bash
# Validate setup and deploy locally
./op validate

# Daily development
./op run local         # Build + deploy to local k8s
./op run local --clean # Clean build (no Docker cache)


## Architecture

**Application:** Flask with health checks and security hardening  
**Deployment:** Kubernetes via Helm with environment abstraction  
**CI/CD:** GitHub Actions with approval gates and comment deployment  
**Infrastructure:** GCP GKE with Istio/Ingress support  
**Development:** Docker-based testing with local k8s deployment  

## Key Design Decisions

**Environment-driven naming:** All resources named `{service}-{env}` with cluster isolation  
**Team ownership:** Extracted from CODEOWNERS and injected as labels  
**Secret conventions:** Expects `{service}-{env}-secrets` with `password` key  
**Abstract templates:** 100% values-driven, no hardcoded names  

## Project Structure

```
├── src/app.py          # Flask application
├── Dockerfile          # Production container
├── op                  # Operations script (build, test, deploy)
├── helm/               # Kubernetes manifests
│   ├── values.yaml     # Shared configuration
│   ├── env/            # Environment-specific values
│   └── templates/      # Kubernetes resource templates
├── ci-test/            # Docker-based testing framework
└── .github/workflows/  # CI/CD pipeline
```

## Commands

```bash
# Development
./op test               # Run CI tests
./op build local        # Build local image
./op deploy local       # Deploy to local k8s
./op run local          # Build + deploy
./op validate           # Full system validation

# Access
kubectl port-forward -n local svc/galaxy-local 8080:80
kubectl logs -n local -l app.kubernetes.io/name=galaxy -f
```

## CI/CD Pipeline

**Automated deployment:**
- Feature branches → `dev` environment
- Main branch → `dev` + `stage` + `prod` (with approvals)

**Comment-based deployment:**
```bash
.deploy dev     # Deploy to dev
.deploy stage   # Deploy to stage (requires approval)  
.deploy prod    # Deploy to prod (requires approval + creates release)
```

**Pipeline stages:**
1. CI tests (linting, security scanning, Helm validation)
2. Build and push container image
3. Deploy with environment-specific values
4. Create GitHub release (prod only)

## Configuration

**Environment URLs:** `https://{service}-{env}.{domain}`  
**Team labels:** Auto-extracted from `.github/CODEOWNERS`  

## Production Features

✅ **High Availability** - Multi-replica with anti-affinity  
✅ **Auto-scaling** - HPA based on CPU/memory  
✅ **Security** - Non-root containers, vulnerability scanning  
✅ **Monitoring** - Health checks, proper labeling  
✅ **Cost Optimization** - Environment-specific resource allocation  
✅ **GitOps** - Declarative configuration with approval gates