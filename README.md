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
- [kubernetes](kubernetes) - Kubernetes deployment manifests for the app, PostgreSQL, and backup workflow
- [terraform](terraform) - Terraform files for provisioning AWS EKS infrastructure

## Prerequisites

Before running or deploying the project, make sure you have:

- Docker and Docker Compose
- Python 3.11+ (optional for local non-container development)
- Terraform
- AWS CLI configured with credentials
- kubectl

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

## Deploying to Kubernetes

The repository includes Kubernetes manifests under [kubernetes](kubernetes). To deploy them:

```bash
kubectl apply -f kubernetes/
```

## Notes

The application is intended as a practical example for learning and demonstrating:

- REST API development with FastAPI
- Database-backed services
- Container orchestration with Kubernetes
- Infrastructure provisioning with Terraform
- Basic observability and platform engineering workflows
