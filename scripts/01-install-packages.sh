#!/bin/bash

# ==========================================================
# Self-Hosted Mail Server - Package Installation Script
# ==========================================================
# This script installs all required packages for:
# - Postfix (MTA)
# - Dovecot (IMAP/POP3)
# - OpenDKIM (DKIM signing)
# - Certbot (TLS certificates)
# - Fail2ban (Security)
# - UFW (Firewall)
# ==========================================================

set -e

echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "Installing Postfix..."
sudo DEBIAN_FRONTEND=noninteractive apt install -y postfix postfix-mysql mailutils

echo "Installing Dovecot..."
sudo apt install -y dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd dovecot-mysql

echo "Installing OpenDKIM..."
sudo apt install -y opendkim opendkim-tools

echo "Installing Certbot (Let's Encrypt)..."
sudo apt install -y certbot

echo "Installing Fail2ban..."
sudo apt install -y fail2ban

echo "Installing Firewall (UFW)..."
sudo apt install -y ufw

echo "Installing DNS utilities..."
sudo apt install -y dnsutils

echo "Enabling services..."

sudo systemctl enable postfix
sudo systemctl enable dovecot
sudo systemctl enable opendkim
sudo systemctl enable fail2ban

echo "Package installation completed successfully!"