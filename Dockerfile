FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .

RUN apt-get update \
	&& apt-get upgrade -y --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

RUN python -m pip install --no-cache-dir --upgrade pip

RUN python -m pip install --no-cache-dir --upgrade -r requirements.txt

RUN python -m pip install --no-cache-dir --upgrade \
	"setuptools>=78.1.1" \
	"wheel>=0.46.2"

RUN python -m pip install --no-cache-dir --upgrade -r requirements.txt \
	&& python -c "import importlib.metadata as m; assert m.version('msgpack') >= '1.2.1', m.version('msgpack'); assert m.version('setuptools') >= '78.1.1', m.version('setuptools')" \
	&& python -m pip uninstall -y pip setuptools wheel \
	&& rm -rf /usr/local/lib/python3.11/ensurepip

COPY . .

WORKDIR /app/backend

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
