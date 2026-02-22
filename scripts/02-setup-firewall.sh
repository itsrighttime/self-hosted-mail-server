#!/bin/bash

# ==========================================================
# Self-Hosted Mail Server - Firewall Setup Script
# ==========================================================
# Configures UFW for secure mail server operation.
#
# Opens only required ports:
# - 22   (SSH)
# - 25   (SMTP)
# - 465  (SMTPS)
# - 587  (Submission)
# - 143  (IMAP)
# - 993  (IMAPS)
# - 110  (POP3)
# - 995  (POP3S)
# ==========================================================

set -e

echo "Resetting UFW to default state..."
sudo ufw --force reset

echo "Setting default policies..."
sudo ufw default deny incoming
sudo ufw default allow outgoing

echo "Allowing SSH (Port 22)..."
sudo ufw allow 22/tcp

echo "Allowing SMTP (Port 25)..."
sudo ufw allow 25/tcp

echo "Allowing SMTPS (Port 465)..."
sudo ufw allow 465/tcp

echo "Allowing Submission (Port 587)..."
sudo ufw allow 587/tcp

echo "Allowing IMAP (Port 143)..."
sudo ufw allow 143/tcp

echo "Allowing IMAPS (Port 993)..."
sudo ufw allow 993/tcp

echo "Allowing POP3 (Port 110)..."
sudo ufw allow 110/tcp

echo "Allowing POP3S (Port 995)..."
sudo ufw allow 995/tcp

echo "Enabling UFW..."
sudo ufw --force enable

echo "Firewall status:"
sudo ufw status verbose

echo "Firewall configuration completed successfully!"