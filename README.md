# Self Hosted Mail Server (Hostinger VPS)

## Overview

This project demonstrates a complete end-to-end setup of a self-hosted mail server deployed on a Hostinger VPS.

The entire mail infrastructure is configured manually without using any managed email services or third-party mail providers. All components — including mail transfer, mailbox access, DNS records, and security layers — are configured from scratch.

The goal of this project is to understand how real-world email systems operate at the protocol and infrastructure level.

---

## Deployment Environment

- VPS Provider: Hostinger
- Operating System: Linux
- Public IP-based deployment
- Manual server provisioning and configuration

---

## Core Features

- SMTP configuration for sending emails
- IMAP/POP3 setup for mail retrieval
- Secure authentication for users
- SSL/TLS encryption for secure communication
- DNS configuration (MX, SPF, DKIM, DMARC)
- Firewall configuration and port management
- Anti-spam and mail security hardening
- Log monitoring and troubleshooting

---

## Architecture Components

### 1. Mail Transfer (SMTP)
Handles outbound and inbound email routing between servers.

### 2. Mail Access (IMAP/POP3)
Allows users to securely access their mailboxes.

### 3. DNS Records
Configured and validated:
- MX Record
- SPF Record
- DKIM
- DMARC

### 4. Security Layer
- SSL/TLS certificates
- Secure login authentication
- Firewall rules
- Restricted open ports
- Spam protection mechanisms

---

## What This Project Demonstrates

- Backend infrastructure management
- Networking protocol understanding
- Linux server administration
- Production-style mail server deployment
- Debugging and mail delivery troubleshooting
- Security-first configuration approach

---

## Challenges Solved

- Email delivery issues due to incorrect DNS setup
- SPF/DKIM alignment failures
- Port blocking and firewall conflicts
- TLS certificate configuration errors
- Spam classification handling

---

## Future Improvements

- High availability setup
- Mail server clustering
- Automated deployment scripts
- Monitoring and alerting system
- Backup and disaster recovery configuration

---

## Conclusion

This project provides hands-on experience with real-world email server infrastructure deployed on a VPS environment without relying on managed mail services.

It demonstrates strong backend fundamentals, networking knowledge, and practical DevOps exposure.
