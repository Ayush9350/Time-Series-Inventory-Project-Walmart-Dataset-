# DemandSense forecast API container
# Build:  docker build -t demandsense-api .
# Run:    docker run -p 8000:8000 demandsense-api   ->  http://localhost:8000/docs
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Only the serving dependencies: the API reads precomputed forecasts, it does not train.
RUN pip install fastapi==0.165.0 "uvicorn[standard]==0.54.0" pandas==2.3.3 pyarrow==26.0.1

COPY api/ api/
# Bundled demo forecasts; mount real ones with -v $(pwd)/artifacts:/app/artifacts
COPY app/demo_artifacts/ app/demo_artifacts/

RUN useradd --create-home appuser
USER appuser

EXPOSE 8000
HEALTHCHECK CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000"]
