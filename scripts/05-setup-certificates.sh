#!/bin/bash

# ==========================================================
# Self-Hosted Mail Server - TLS Certificate Setup Script
# ==========================================================
# Automates installation of Let's Encrypt certificates for
# Postfix and Dovecot and reloads services.
# ==========================================================

set -e

# ====== CONFIGURATION ======
DOMAIN="${1:-mail.itsrighttime.group}"   # Default mail server domain
WEBROOT="${2:-/opt/www}"                 # Webroot path for certbot validation

echo "Setting up TLS certificates for $DOMAIN"
echo "Webroot path: $WEBROOT"

# Install certbot and required plugin if not installed
if ! command -v certbot &> /dev/null; then
    echo "Certbot not found, installing..."
    sudo apt update
    sudo apt install -y certbot python3-certbot-nginx
else
    echo "Certbot already installed."
fi

# Create webroot if missing
if [ ! -d "$WEBROOT" ]; then
    sudo mkdir -p "$WEBROOT"
    sudo chown www-data:www-data "$WEBROOT"
fi

# Request or renew certificate
sudo certbot certonly --non-interactive --agree-tos --email admin@$DOMAIN \
    --webroot -w "$WEBROOT" -d "$DOMAIN"

# Verify certificate paths
CERT_PATH="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
KEY_PATH="/etc/letsencrypt/live/$DOMAIN/privkey.pem"

if [ ! -f "$CERT_PATH" ] || [ ! -f "$KEY_PATH" ]; then
    echo "Certificate generation failed!"
    exit 1
fi

echo "Certificates generated successfully!"
echo "Certificate path: $CERT_PATH"
echo "Key path: $KEY_PATH"

# Set proper permissions
sudo chmod 644 "$CERT_PATH"
sudo chmod 600 "$KEY_PATH"
sudo chown root:root "$CERT_PATH" "$KEY_PATH"

# Reload services to pick up new certs
echo "Restarting Postfix and Dovecot..."
sudo systemctl restart postfix dovecot

echo "TLS setup completed successfully!"