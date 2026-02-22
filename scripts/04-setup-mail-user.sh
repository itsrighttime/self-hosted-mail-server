#!/bin/bash

# ==========================================================
# Self-Hosted Mail Server - Mail User Setup Script
# ==========================================================
# Adds a system user for email, creates Maildir, and sets
# correct permissions for Dovecot/Postfix usage.
# ==========================================================

set -e

# ====== CONFIGURATION ======
USERNAME="$1"
DOMAIN="${2:-itsrighttime.group}"   # Default domain
MAILDIR="/home/$USERNAME/Maildir"

if [ -z "$USERNAME" ]; then
    echo "Usage: $0 <username> [domain]"
    exit 1
fi

echo "Creating mail user: $USERNAME@$DOMAIN"

# Check if user exists
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists. Skipping creation."
else
    # Create Linux user without login shell
    sudo adduser --disabled-password --gecos "" "$USERNAME"
    echo "User $USERNAME created successfully!"
fi

# Create Maildir
if [ ! -d "$MAILDIR" ]; then
    sudo mkdir -p "$MAILDIR"/{cur,new,tmp}
    sudo chown -R "$USERNAME:$USERNAME" "$MAILDIR"
    sudo chmod -R 700 "$MAILDIR"
    echo "Maildir created at $MAILDIR"
else
    echo "Maildir already exists at $MAILDIR. Skipping."
fi

# Optional: send test email
TEST_EMAIL="$USERNAME@$DOMAIN"
echo "This is a test email for $TEST_EMAIL" | mail -s "Welcome to $DOMAIN" "$TEST_EMAIL"
echo "Test email sent to $TEST_EMAIL (check Maildir)."

echo "Mail user setup completed successfully!"