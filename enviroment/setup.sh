#!/bin/bash
sudo rm -rf .influxdb3-data .influxdb3-plugins .explorer-db .explorer-config .grafana-provisioning .ollama .openwebui
docker compose down
mkdir -p .influxdb3-data .influxdb3-plugins .explorer-db .explorer-config .grafana-provisioning .ollama .openwebui
docker compose up -d
docker container exec influxdb3-core influxdb3 create token --admin > .tokens
