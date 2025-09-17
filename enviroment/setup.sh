#!/bin/bash
mkdir -p .data .plugins .db .config .grafana-provisioning .ollama .openwebui
docker compose up -d
docker container exec influxdb3-core influxdb3 create token --admin > .tokens
