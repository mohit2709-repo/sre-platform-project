# SRE Platform Project

This repository contains a containerized FastAPI task management service along with infrastructure-as-code and Kubernetes assets for deploying it in a modern platform environment.

## Overview

The project demonstrates a full path from local development to cloud deployment, including:

- a FastAPI backend with PostgreSQL persistence
- Docker Compose for local development
- Kubernetes manifests for application deployment and supporting services
- Terraform configuration for provisioning an AWS EKS cluster and node group
- health checks, metrics, and basic observability

## Project Structure

- [backend/app/main.py](backend/app/main.py) - FastAPI application and API routes
- [backend/app/database.py](backend/app/database.py) - SQLAlchemy database configuration and connection handling
- [backend/app/models.py](backend/app/models.py) - Task model definitions
- [backend/app/crud.py](backend/app/crud.py) - Database CRUD logic
- [backend/app/schemas.py](backend/app/schemas.py) - Pydantic request and response schemas
- [docker-compose.yml](docker-compose.yml) - Local Docker Compose setup for PostgreSQL and the backend
- [helm/sre-project](helm/sre-project) - Helm chart for deploying the application, PostgreSQL StatefulSet, headless services, and backup resources
- [kubernetes](kubernetes) - Kubernetes deployment manifests for the app, PostgreSQL, and backup workflow
- [terraform](terraform) - Terraform files for provisioning AWS EKS infrastructure
- [.github/workflows/ci.yaml](.github/workflows/ci.yaml) - GitHub Actions CI/CD workflow

## Prerequisites

Before running or deploying the project, make sure you have:

- Docker and Docker Compose
- Python 3.11+ (optional for local non-container development)
- Terraform
- AWS CLI configured with credentials
- kubectl

## CI/CD Pipeline

This project uses GitHub Actions for automated testing, building, security scanning, and publishing Docker images. Argo CD watches the Helm chart and deploys changes from Git. The pipeline is defined in [.github/workflows/ci.yaml](.github/workflows/ci.yaml).

### Pipeline Stages

1. **Python Test** - Runs on every push and pull request
   - Checks out code
   - Sets up Python 3.11
   - Installs dependencies from `requirements.txt`
   - Validates Python syntax with `compileall`
    - A pytest step is available but currently commented out in the workflow

2. **Docker Build** - Runs after Python tests pass
   - Builds Docker image and tags it with commit SHA: `task-api:<commit-sha>`
    - Pulls the latest base image before building

3. **Security Scan** - Runs after Docker build completes
   - Scans Docker image with Trivy for vulnerabilities
   - Checks for CRITICAL and HIGH severity issues
   - Fails the pipeline if vulnerabilities are found

4. **Docker Push** - Runs only on main branch pushes (after security scan passes)
   - Authenticates with Docker Hub
   - Reads and validates the application tag from `helm/sre-project/values.yaml`
   - Pushes image to Docker Hub with tags:
     - `mohit2709/task-api:latest`
     - `mohit2709/task-api:<commit-sha>`
     - `mohit2709/task-api:<helm-image-tag>` (for example, `v2`)

After the image is published and the Helm change is pushed to `main`, Argo CD automatically syncs the release and deploys the image tag declared in `values.yaml`.

### Required GitHub Secrets

For the CI/CD pipeline to work, configure these secrets in your GitHub repository settings:

- `DOCKERHUB_USERNAME` - Your Docker Hub username
- `DOCKERHUB_TOKEN` - Your Docker Hub access token

### Pipeline Flow

```
Push/PR to main
    ↓
Python Validation (syntax check)
    ↓
  Docker Build and Scan (create and inspect image)
    ↓
  Docker Push (to Docker Hub) [main branch only]
    ↓
  Argo CD Sync (Helm deployment)
```

## Running with Docker Compose

From the project root, start the services:

```bash
docker compose up --build
```

This will start:

- PostgreSQL on port 5432
- The FastAPI backend on port 8000

### Useful URLs

- API docs: http://localhost:8000/docs
- Health check: http://localhost:8000/health
- Database health check: http://localhost:8000/health/db
- Metrics: http://localhost:8000/metrics

## Example API Requests

### Create a task

```bash
curl -X POST "http://localhost:8000/tasks" \
  -H "Content-Type: application/json" \
  -d '{"title":"Deploy app","description":"Ship the service to production"}'
```

### List tasks

```bash
curl "http://localhost:8000/tasks"
```

### Get a task

```bash
curl "http://localhost:8000/tasks/1"
```

### Delete a task

```bash
curl -X DELETE "http://localhost:8000/tasks/1"
```

## Running Locally Without Docker

If you prefer to run the backend directly on your machine:

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
export DATABASE_URL=postgresql://admin:password@localhost:5432/tasksdb
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

You will still need a PostgreSQL instance available at the configured URL.

## Provisioning EKS with Terraform

The Terraform configuration in [terraform](terraform) provisions an EKS cluster and node group for the application.

```bash
cd terraform
terraform init
terraform validate
terraform plan
terraform apply
```

Make sure your AWS credentials are configured before applying the changes.

## Deploying with Helm

The project includes a Helm chart in [helm/sre-project](helm/sre-project). It manages the application deployment, PostgreSQL StatefulSet, headless services, config maps, and backup CronJob.

### Render the chart locally

```bash
cd helm/sre-project
helm template sre-project .
```

### Install or upgrade the release

```bash
cd helm/sre-project
helm upgrade --install sre-project . \
  --namespace sre-project \
  --create-namespace
```

### Current Helm values

The chart is configured with values in [helm/sre-project/values.yaml](helm/sre-project/values.yaml), including:

- app deployment settings such as `replicaCount`, `image.repository`, `image.tag`, and `service`
- PostgreSQL settings such as `postgres.image`, `postgres.database`, `postgres.storage`, and `postgres.replicas`
- secret references such as `postgres.existingSecret`
- replica configuration under `replica:` for PostgreSQL replication setup
- backup configuration under `backup:`

The Helm chart's backup CronJob expects the `postgres-backup-pvc` claim to exist in the `sre-project` namespace. Create it before enabling backup Jobs:

```bash
kubectl apply -f kubernetes/backup-pvc.yaml
kubectl get pvc -n sre-project
```

### PostgreSQL configuration notes

The PostgreSQL manifests use a headless Service pattern (`clusterIP: None`) so StatefulSet pods can be addressed individually. The primary PostgreSQL StatefulSet and the replica StatefulSet rely on existing Kubernetes Secret objects, notably:

- `sre-project-db-credentials`
- `postgres-replication-secret`

These are expected to exist in the target namespace before the workload is scheduled.

## Deploying to Kubernetes directly

The repository also includes static Kubernetes manifests under [kubernetes](kubernetes). To deploy them:

```bash
kubectl apply -f kubernetes/
```

## Notes

The application is intended as a practical example for learning and demonstrating:

- REST API development with FastAPI
- Database-backed services
- Stateful PostgreSQL deployment patterns with headless Services
- Container orchestration with Kubernetes and Helm
- Infrastructure provisioning with Terraform
- Automated CI/CD with GitHub Actions
- Container security scanning and vulnerability management
- Basic observability and platform engineering workflows
