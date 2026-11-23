#!/bin/bash
FICHIER="logs/access.log"
trap 'echo "$(date) Arrêt propre" >> logs/surveillance.log; exit 0' SIGTERM

while true; do
    echo "$(date) - $(wc -l < "$FICHIER") lignes" >> logs/surveillance.log
    sleep 5
done
