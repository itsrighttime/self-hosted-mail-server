#!/bin/bash

# ==========================================================
# Self-Hosted Mail Server - Health Check Script
# ==========================================================
# Checks status of mail services, mail queue, SSL certs, and disk space
# ==========================================================

set -e

echo "===================================="
echo "MAIL SERVER HEALTH CHECK - $(date)"
echo "===================================="

# ====== 1. Check service statuses ======
echo -e "\n[1] Service Status:"
services=("postfix" "dovecot" "opendkim")
for svc in "${services[@]}"; do
    status=$(systemctl is-active "$svc")
    echo "- $svc: $status"
done

# ====== 2. Check Postfix mail queue ======
echo -e "\n[2] Postfix Mail Queue:"
mail_queue=$(postqueue -p | tail -n 1)
if [[ $mail_queue == "Mail queue is empty" ]]; then
    echo "Mail queue is empty"
else
    echo "Mail queue not empty"
    postqueue -p | head -n 10
fi

# ====== 3. Check SSL/TLS certificates ======
echo -e "\n[3] SSL/TLS Certificates:"
CERT_PATHS=(
"/etc/letsencrypt/live/mail.itsrighttime.group/fullchain.pem"
)
for cert in "${CERT_PATHS[@]}"; do
    if [ -f "$cert" ]; then
        expiry=$(openssl x509 -enddate -noout -in "$cert" | cut -d= -f2)
        echo "- $cert expires on: $expiry"
    else
        echo "- $cert not found"
    fi
done

# ====== 4. Check disk usage ======
echo -e "\n[4] Disk Usage for Mail Directories:"
MAIL_ROOT="/home"
du -sh $MAIL_ROOT/*/Maildir 2>/dev/null || echo "No Maildir directories found"

# ====== 5. Check open ports ======
echo -e "\n[5] Open Mail Ports:"
ports=(25 465 587 110 995 143 993)
for p in "${ports[@]}"; do
    nc -zv 127.0.0.1 $p >/dev/null 2>&1 && echo "- Port $p: open" || echo "- Port $p: closed"
done

echo -e "\nHealth check completed!"