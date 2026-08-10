#!/usr/bin/env bash

SERVICES=(
  "docker-evolution-api.service"
  "n8n.service"
  "postgresql.service"
  "redis-berillo-clean.service"
  "ngrok.service"
)

STATUS=$(systemctl is-active n8n.service)

if [ "$STATUS" = "active" ]; then
    notify-send "Berillo Clean" "Desativando ecossistema de workflows..." -i system-shutdown
    sudo systemctl stop "${SERVICES[@]}"
    notify-send "Berillo Clean" "Todos os serviços foram parados. RAM liberada!" -i dialog-information
else
    notify-send "Berillo Clean" "Iniciando ecossistema de workflows..." -i system-run
    sudo systemctl start "${SERVICES[@]}"
    
    sleep 2
    notify-send "Berillo Clean" "Tudo pronto! Evolution API, n8n e Postgres online." -i dialog-ok
fi
