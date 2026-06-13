from fastapi import FastAPI
from fastapi import Depends
from fastapi import HTTPException
from fastapi import Request
from .logger import logger
from prometheus_fastapi_instrumentator import Instrumentator
from .metrics import current_tasks   
from .models import Task
from sqlalchemy.orm import Session
from sqlalchemy import text
import time
from .metrics import api_requests_total
from .metrics import request_duration_seconds
from .metrics import failed_requests_total
from .database import Base
from .database import engine
from .database import SessionLocal
from . import crud
from . import schemas

Base.metadata.create_all(bind=engine)

app = FastAPI()
Instrumentator().instrument(app).expose(app)

@app.on_event("startup")
def initialize_metrics():
    db = SessionLocal()
    try:
        count = db.query(Task).count()
        current_tasks.set(count)
        logger.info(f"Initialized current_tasks={count}")
    except Exception as e:
        logger.error(f"Failed to initialize metrics: {str(e)}")
    finally:
        db.close()

@app.middleware("http")
async def log_requests(request: Request, call_next):  
       start_time = time.time()
       logger.info(
           f"Request Started | "
           f"method={request.method} "
           f"path={request.url.path}"
       )
       response = await call_next(request)
       if response.status_code >= 400:
           failed_requests_total.inc()

       duration = time.time() - start_time
       api_requests_total.labels(method=request.method, endpoint=request.url.path, status_code=response.status_code).inc()
       request_duration_seconds.labels(method=request.method, endpoint=request.url.path).observe(duration)
        
       logger.info(
           f"Request Completed | "
           f"method={request.method} "
           f"path={request.url.path} "
           f"status_code={response.status_code}"
       )
       return response

@app.get("/health")
def health():
    return {
        "status": "healthy"
    }

@app.get("/health/db")
def db_health():
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        logger.info("Database health check successful.")

        return {
            "status": "healthy",
            "database": "up"
        }

    except Exception as e:
        logger.error(f"Database health check failed: {str(e)}")
        raise HTTPException(
            status_code=503,
            detail=f"Database unavailable: {str(e)}"
        )


def get_db():
    db = SessionLocal()

    try:
        yield db

    finally:
        db.close()


@app.post("/tasks")
def create_task(
    task: schemas.TaskCreate,
    db: Session = Depends(get_db)
):
    return crud.create_task(
        db,
        task.title,
        task.description
    )


@app.get("/tasks")
def list_tasks(
    db: Session = Depends(get_db)
):
    return crud.get_tasks(db)


@app.get("/tasks/{task_id}")
def get_task(
    task_id: int,
    db: Session = Depends(get_db)
):
    task = crud.get_task(
        db,
        task_id
    )

    if not task:
        raise HTTPException(
            status_code=404,
            detail="Task not found"
        )

    return task


@app.delete("/tasks/{task_id}")
def delete_task(
    task_id: int,
    db: Session = Depends(get_db)
):
    task = crud.delete_task(
        db,
        task_id
    )

    if not task:
        raise HTTPException(
            status_code=404,
            detail="Task not found"
        )

    return {"message": "Deleted"}
