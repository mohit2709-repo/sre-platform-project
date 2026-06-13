from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, declarative_base
import os
import time

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://admin:password@postgres:5432/tasksdb"
)

MAX_RETRIES = 10
MAX_DELAY = 30

engine = None

for attempt in range(1, MAX_RETRIES + 1):
    try:
        print(
            f"[DATABASE] Connecting to PostgreSQL "
            f"(attempt {attempt}/{MAX_RETRIES})..."
        )

        engine = create_engine(
            DATABASE_URL,
            pool_pre_ping=True,
            pool_recycle=300
        )

        # Validate connection
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))

        print("[DATABASE] Connection successful.")
        break

    except Exception as e:
        print(f"[DATABASE] Connection failed: {e}")

        if attempt == MAX_RETRIES:
            print("[DATABASE] Maximum retry limit reached.")
            raise

        delay = min(2 ** attempt, MAX_DELAY)

        print(
            f"[DATABASE] Retrying in {delay} seconds..."
        )

        time.sleep(delay)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

Base = declarative_base()