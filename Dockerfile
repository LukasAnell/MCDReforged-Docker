FROM python:3.12-slim

RUN apt-get update && apt-get install -y \
    curl \
    python3-venv \
    build-essential \
    unzip \
    jq \
 && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /tmp/jdk.tar.gz https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.1%2B8/OpenJDK25U-jdk_aarch64_linux_hotspot_25.0.1_8.tar.gz \
 && mkdir -p /opt/java \
 && tar -xzf /tmp/jdk.tar.gz -C /opt/java --strip-components=1 \
 && rm /tmp/jdk.tar.gz

ENV JAVA_HOME=/opt/java
ENV PATH=$JAVA_HOME/bin:$PATH

RUN pip install --no-cache-dir mcdreforged

RUN pip install --no-cache-dir \
  cryptography \
  APScheduler \
  hjson \
  requests \
  aiohttp \
  websockets \
  pydantic \
  PyYAML

COPY start_mcdr.sh /usr/local/bin/start_mcdr.sh
RUN chmod +x /usr/local/bin/start_mcdr.sh

WORKDIR /data
ENTRYPOINT ["start_mcdr.sh"]
