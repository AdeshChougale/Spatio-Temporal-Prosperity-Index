FROM jupyter/pyspark-notebook:spark-3.5.0

USER root

RUN apt-get update && apt-get install -y \
    libspatialindex-dev \
    libgdal-dev \
    && rm -rf /var/lib/apt/lists/*

USER $NB_UID

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt