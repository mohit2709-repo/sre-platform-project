# SRE Platform Project

This project is a simple task management API built with FastAPI and PostgreSQL, designed to demonstrate containerized application deployment, health checks, observability, and Kubernetes manifests.

## Overview

The backend exposes REST endpoints for creating, listing, retrieving, and deleting tasks. It also includes:

- health endpoints for service and database checks
- Prometheus-style metrics instrumentation
- Docker Compose support for local development
- Kubernetes manifests for deployment

## Project Structure

- [backend/app/main.py](backend/app/main.py) - FastAPI application and API routes
- [backend/app/database.py](backend/app/database.py) - SQLAlchemy database configuration and connection handling
- [backend/app/models.py](backend/app/models.py) - Task model definition
- [backend/app/crud.py](backend/app/crud.py) - Database CRUD logic
- [backend/app/schemas.py](backend/app/schemas.py) - Pydantic request/response schemas
- [docker-compose.yml](docker-compose.yml) - Local Docker Compose setup for PostgreSQL and the backend
- [kubernetes](kubernetes) - Kubernetes deployment manifests

## Prerequisites

Before running the project, make sure you have:

- Docker and Docker Compose
- Python 3.11+ (optional for local non-container development)

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

## Kubernetes Deployment

The repository includes Kubernetes manifests under [kubernetes](kubernetes). To deploy them:

```bash
kubectl apply -f kubernetes/
```

## Notes

The application is intentionally lightweight and is suitable for learning and demonstrating:

- REST API development with FastAPI
- Database-backed services
- Observability and metrics exposure
- Basic DevOps and platform engineering workflows
