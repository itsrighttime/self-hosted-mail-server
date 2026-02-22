# Self Hosted Mail Server (Production-Style Setup)

## Project Overview

This project demonstrates the end-to-end design and deployment of a secure, self-hosted mail server running on a VPS provisioned from Hostinger.

The entire infrastructure is manually configured without using any managed email services (no Gmail, AWS SES, Mailgun, etc.). All components — SMTP, IMAP, authentication, DNS authentication, TLS encryption, and firewall security — are implemented from scratch.

This project was built to:

- Understand real-world email infrastructure
- Strengthen backend networking fundamentals
- Demonstrate production-grade system configuration
- Apply system design thinking to infrastructure


### High-Level Architecture

The mail system consists of:

Client (Thunderbird / Gmail / Outlook)
↓
SMTP (Port 587 / 465)
↓
Postfix (MTA)
↓
OpenDKIM (Email Signing)
↓
DNS Validation (SPF / DKIM / DMARC)
↓
Recipient Mail Server

For mail retrieval:

Client → IMAPS (993) → Dovecot → Maildir Storage


### Core Components

#### 1 Postfix – Mail Transfer Agent

Handles:

- SMTP
- Outbound & inbound routing
- TLS encryption
- SASL authentication (via Dovecot)
- DKIM integration

#### 2 Dovecot – Mail Delivery & Access

Handles:

- IMAP / POP3
- User authentication
- Maildir storage
- Secure TLS communication

#### 3 OpenDKIM – Email Signing

Handles:

- Outgoing email signing
- Domain key validation
- Spam prevention support

#### 4 DNS Authentication

Configured:

- A / AAAA records
- MX record
- SPF
- DKIM
- DMARC
- Reverse DNS (PTR)


###  Security Considerations

- TLS enforced for SMTP authentication
- IMAPS required for mailbox access
- Firewall restricted to required ports only
- DKIM signing enabled
- SPF policy defined
- DMARC reporting enabled
- Reverse DNS configured
- SASL authentication enabled
- No open relay configuration


###  Documentation

Detailed step-by-step implementation is available in the `/docs` directory:

- System Overview
- Installation Guide
- Configuration Files
- DNS Setup
- Testing & Debugging
- Maintenance
- Scaling & System Design


###  Testing Strategy

The setup includes validation for:

- SMTP handshake
- IMAP connection
- TLS certificate verification
- DKIM key lookup
- SPF validation
- DMARC validation
- Mail queue inspection
- Log monitoring
- External delivery testing


###  System Design Perspective (SDE2 Focus)

This mail server was designed with the following distributed system principles in mind:

#### 1 Reliability

- Service auto-start on boot
- Log-based monitoring
- Mail queue handling
- TLS certificate verification

#### 2 Security

- Enforced encryption
- Domain-level authentication
- Restricted firewall rules
- No open relay configuration

#### 3 Scalability Considerations

Though deployed on a single VPS, the architecture supports horizontal scaling by:

- Separating MTA and mailbox servers
- Introducing load balancer in front of SMTP
- Using shared storage (NFS/S3-compatible)
- Moving users to virtual database-based authentication
- Adding replica MX servers
- Implementing rate limiting and queue tuning

#### 4 Observability

- Mail logs analysis
- Postfix queue inspection
- Dovecot mailbox metrics
- DNS verification testing


### Future Improvements

- High Availability (Multi-MX setup)
- Database-backed virtual users
- Rate limiting per user/IP
- Spam filtering (SpamAssassin)
- Antivirus (ClamAV)
- Monitoring (Prometheus + Grafana)
- Automated deployment (Ansible / Terraform)
- Containerized deployment


### Why This Project Matters for Backend Engineering

This project demonstrates:

- Deep understanding of networking protocols (SMTP, IMAP)
- DNS architecture and email authentication
- Linux system administration
- Secure infrastructure configuration
- Debugging distributed communication systems
- Production-style system thinking


