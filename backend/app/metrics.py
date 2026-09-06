from opentelemetry import metrics
from opentelemetry.exporter.prometheus import PrometheusMetricReader
from opentelemetry.metrics import Observation
from opentelemetry.sdk.metrics import MeterProvider

# OTel application metrics are exported through PrometheusMetricReader.
prometheus_reader = PrometheusMetricReader()
metrics.set_meter_provider(MeterProvider(metric_readers=[prometheus_reader]))
meter = metrics.get_meter("sre-project")

tasks_created_total = meter.create_counter(
    "tasks_created_total", description="Total number of tasks created"
)

tasks_deleted_total = meter.create_counter(
    "tasks_deleted_total", description="Total number of tasks deleted"
)

database_errors_total = meter.create_counter(
    "database_errors_total", description="Total number of database errors"
)

_current_tasks = 0


def set_current_tasks(value: int):
    global _current_tasks
    _current_tasks = value


def observe_current_tasks(options):
    yield Observation(_current_tasks, {})


current_tasks = meter.create_observable_gauge(
    "current_tasks",
    callbacks=[observe_current_tasks],
    description="Current number of tasks in the system",
)

request_duration_seconds = meter.create_histogram(
    "request_duration_seconds",
    description="Duration of HTTP requests in seconds",
)

api_requests_total = meter.create_counter(
    "api_requests_total", description="Total number of API requests"
)

failed_requests_total = meter.create_counter(
    "failed_requests_total", description="Total number of failed API requests"
)