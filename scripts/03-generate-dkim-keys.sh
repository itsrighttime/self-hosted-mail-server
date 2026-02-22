#!/bin/bash

# ==========================================================
# Self-Hosted Mail Server - DKIM Key Generation Script
# ==========================================================
# This script generates DKIM keys for a domain, sets permissions,
# and prepares OpenDKIM configuration files.
# ==========================================================

set -e

# ====== CONFIGURATION ======
DOMAIN="${1:-itsrighttime.group}"   # Default domain if not passed
SELECTOR="${2:-default}"            # Default DKIM selector
KEY_DIR="/etc/opendkim/keys/$DOMAIN"

echo "Generating DKIM keys for domain: $DOMAIN"
echo "Selector: $SELECTOR"
echo "Key directory: $KEY_DIR"

# Create key directory if not exists
sudo mkdir -p "$KEY_DIR"
sudo chown opendkim:opendkim "$KEY_DIR"
sudo chmod 750 "$KEY_DIR"

# Generate DKIM keys
sudo opendkim-genkey -s "$SELECTOR" -d "$DOMAIN" -D "$KEY_DIR"
sudo chown opendkim:opendkim "$KEY_DIR/$SELECTOR.private"
sudo chmod 600 "$KEY_DIR/$SELECTOR.private"

echo "DKIM keys generated successfully!"

# Display DNS TXT record for DKIM
DNS_TXT=$(sudo cat "$KEY_DIR/$SELECTOR.txt")
echo ""
echo "============================="
echo "Add the following DKIM TXT record to your DNS:"
echo ""
echo "$DNS_TXT"
echo "============================="
echo ""
echo "Key directory: $KEY_DIR"
echo "Private key permissions: $(ls -l $KEY_DIR/$SELECTOR.private)"
