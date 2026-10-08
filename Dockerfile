# syntax=docker/dockerfile:1

FROM python:3.13-slim-bookworm AS builder

WORKDIR /build

COPY requirements.txt .

RUN python -m pip install --no-cache-dir --prefix=/install -r requirements.txt


FROM python:3.13-slim-bookworm AS runtime

WORKDIR /app

RUN useradd --create-home --uid 10001 --shell /usr/sbin/nologin appuser

COPY --from=builder /install /usr/local
COPY prestamos ./prestamos

RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 9000

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=5 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:9000/salud', timeout=2)"

CMD ["uvicorn", "prestamos.servidor:app", "--host", "0.0.0.0", "--port", "9000"]
