from prometheus_client import Counter, Gauge, Histogram

tasks_created_total = Counter(
    "tasks_created_total",
    "Total number of tasks created"
)

tasks_deleted_total = Counter(
    "tasks_deleted_total",
    "Total number of tasks deleted"
)

database_errors_total = Counter(
    "database_errors_total",
    "Total number of database errors"
)

current_tasks = Gauge(
    "current_tasks",
    "Current number of tasks in the system"
)

request_duration_seconds = Histogram(
    "request_duration_seconds",
    "Duration of HTTP requests in seconds",
    ["method", "endpoint"]
)

api_requests_total = Counter(
    "api_requests_total",
    "Total number of API requests",
    ["method", "endpoint", "status_code"]
)

failed_requests_total = Counter(
    "failed_requests_total",
    "Total number of failed API requests"
)