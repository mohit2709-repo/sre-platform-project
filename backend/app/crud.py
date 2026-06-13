from sqlalchemy.orm import Session
from .metrics import tasks_created_total
from .metrics import tasks_deleted_total
from .metrics import database_errors_total
from .metrics import current_tasks
from .models import Task


def create_task(
    db: Session,
    title: str,
    description: str
):
    try:
        task = Task(
            title=title,
            description=description
        )


        db.add(task)
        db.commit()
        db.refresh(task)
        tasks_created_total.inc()
        current_tasks.set(db.query(Task).count())

        return task
    
    except Exception as e:
        database_errors_total.inc()
        db.rollback()
        raise



def get_tasks(db: Session):
    return db.query(Task).all()


def get_task(db: Session, task_id: int):
    return db.query(Task).filter(
        Task.id == task_id
    ).first()


def delete_task(
    db: Session,
    task_id: int
):
    try:
        task = get_task(db, task_id)

        if task:
            db.delete(task)
            db.commit()
            tasks_deleted_total.inc()
            current_tasks.set(db.query(Task).count())
        return task
    
    except Exception as e:
        database_errors_total.inc()
        db.rollback()
        raise