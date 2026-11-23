#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage : bash scripts/analyse.sh <fichier.log> [--top N]" >&2
}

if [[ $# -lt 1 || $# -gt 3 ]]; then
    usage
    exit 1
fi

FICHIER="$1"
TOP=3

if [[ $# -eq 2 ]]; then
    usage
    exit 1
elif [[ $# -eq 3 ]]; then
    if [[ "$2" != "--top" || ! "$3" =~ ^[1-9][0-9]*$ ]]; then
        usage
        exit 1
    fi
    TOP="$3"
fi

if [[ -z "${MATRICULE:-}" ]]; then
    echo "Erreur : MATRICULE non définie" >&2
    exit 1
fi

if [[ ! -f "$FICHIER" ]]; then
    echo "Erreur : fichier absent" >&2
    exit 2
fi

if [[ ! -s "$FICHIER" ]]; then
    echo "Erreur : fichier vide" >&2
    exit 3
fi

entete() {
    echo "Rapport d'analyse"
    echo "Date : $(date)"
    echo "Utilisateur : $(whoami)@$(hostname)"
    echo "Matricule : $MATRICULE"
    echo "SHA256 : $(sha256sum "$FICHIER")"
}

familles() {
    for code in 2 3 4 5; do
        nombre=$(awk -v c="$code" '$9 ~ "^" c {n++} END {print n+0}' "$FICHIER")
        echo "${code}xx : $nombre"
    done
}

top_endpoints() {
    echo "Top $TOP endpoints :"
    awk '{gsub(/"/,"",$7); sub(/\?page=.*/,"",$7); print $7}' "$FICHIER" |
    sort | uniq -c | sort -rn | head -n "$TOP"
}

ip_suspecte() {
    echo "IP suspecte :"
    awk '$9 == 401 && $7 == "/api/auth/login" {print $1}' "$FICHIER" |
    sort | uniq -c | sort -rn | head -n 1
}

moyenne_200() {
    echo "Temps moyen des réponses 200 :"
    awk '$9 == 200 {gsub(/ms/,"",$12); somme+=$12; n++}
    END {if(n>0) printf "%.1f ms\n", somme/n; else print "Aucune requête 200"}' "$FICHIER"
}

mkdir -p rapports
DATE=$(date +%Y%m%d_%H%M)
RAPPORT="rapports/rapport_${MATRICULE}_${DATE}.txt"

{
    entete
    echo
    familles
    echo
    top_endpoints
    echo
    ip_suspecte
    echo
    moyenne_200
} > "$RAPPORT"

echo "Rapport créé : $RAPPORT"
