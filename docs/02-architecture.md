# 02 - Architecture Overview

## 1. Introduction

This document explains the architecture of the self-hosted mail server in detail, emphasizing component separation, data flow, and design considerations for reliability, scalability, and maintainability.

The architecture is designed to demonstrate:

- Clear separation of responsibilities
- Security and authentication enforcement
- Observability and monitoring
- Potential for horizontal or vertical scaling

## 2. Component Diagram

```md
           +--------------------+
           |   Email Client     |
           | (Outlook/Gmail)    |
           +--------------------+
                    |
      SMTP Submission (Port 587 / 465)
                    |
                    v
           +--------------------+
           |      Postfix       |
           |  (Mail Transfer    |
           |      Agent)        |
           +--------------------+
                    |
             DKIM Signing
                    |
                    v
            +---------------+
            |   OpenDKIM    |
            +---------------+
                    |
                    v
    +-------------------------------+
    |        Mail Storage            |
    |        Dovecot (IMAP/POP3)    |
    +-------------------------------+
                    |
             Mail Retrieval
                    |
                    v
           +--------------------+
           |   Email Client     |
           +--------------------+
```

DNS Layer (SPF/DKIM/DMARC/Reverse DNS) integrates externally to improve trust and prevent spoofing.

## 3. Core Components & Responsibilities

### 3.1 Postfix – Mail Transfer Agent

- Handles **incoming and outgoing mail routing**
- Performs **SMTP authentication via Dovecot (SASL)**
- Integrates **OpenDKIM** for signing outbound emails
- Enforces **TLS encryption** on SMTP channels
- Prevents open relay abuse

**Scalability considerations:**

- Can be horizontally scaled via multiple MTAs with DNS MX priority
- Can separate inbound vs outbound traffic for load balancing

### 3.2 Dovecot – Mail Delivery & Retrieval

- Provides **IMAP/POP3 access** for clients
- Manages **Maildir storage** per user
- Authenticates users for Postfix via **SASL**
- Secures communication with **TLS certificates**

**Scalability considerations:**

- Supports multiple storage backends (local filesystem, NFS, cloud storage)
- Can be clustered for high availability
- Can integrate quotas and rate limiting per user

### 3.3 OpenDKIM – Signing Service

- Signs all outgoing emails with domain DKIM key
- Improves email deliverability
- Prevents spoofing or phishing attacks

**Scalability considerations:**

- Lightweight, can run as a separate service for multiple Postfix instances
- Can be containerized or load-balanced if multiple MTAs exist

### 3.4 DNS Authentication Layer

- **SPF:** authorizes sending IPs
- **DKIM:** validates signature of outgoing mail
- **DMARC:** instructs receiving servers how to handle SPF/DKIM failures
- **PTR / Reverse DNS:** improves trust for spam filters

**Scalability considerations:**

- DNS is inherently distributed
- MX records can provide failover to secondary mail servers

## 4. Security Architecture

1. **TLS Encryption:**
   - SMTP: Ports 465/587
   - IMAP: Port 993
2. **SASL Authentication:** Postfix uses Dovecot for secure user auth
3. **Firewall:** Only essential ports allowed (UFW)
4. **No open relay:** Only authenticated users can send emails
5. **DNS-based validation:** SPF/DKIM/DMARC checks
6. **Reverse DNS:** Reduces spam classification

## 5. Data Flow

### 5.1 Outbound

1. Client → SMTP (Postfix)
2. Postfix validates user credentials (Dovecot SASL)
3. Message signed via OpenDKIM
4. Postfix looks up recipient MX
5. Mail delivered → external server → external client
6. Recipient validates SPF/DKIM/DMARC

### 5.2 Inbound

1. External server resolves MX → sends mail to Postfix
2. Postfix stores mail in Maildir
3. User retrieves mail via IMAPS (Dovecot)

## 6. Observability & Monitoring

- **Log files:** `/var/log/mail.log`, `/var/log/dovecot.log`
- **Systemctl status** for Postfix, Dovecot, OpenDKIM
- **Mail queue inspection:** `postqueue -p`
- **DNS record validation:** `dig`, `nslookup`
- **Certificate verification:** `openssl s_client`

**Future enhancements:**

- Centralized logging (ELK stack, Prometheus)
- Alerting on delivery failures or authentication errors

## 7. Design for Scalability

- **Horizontal MTA scaling:** multiple Postfix instances with MX priority
- **Separate inbound/outbound routing:** for traffic isolation
- **Mailbox storage scaling:** network storage or cluster
- **DKIM signing service scaling:** separate microservice
- **Automated deployment:** Ansible, Docker, or Kubernetes for reproducibility

## 8. Reliability & High Availability

- Currently single VPS → single point of failure
- Future improvements:
  - Multiple MX records → failover
  - Load-balanced Postfix/Dovecot nodes
  - Redundant storage backend for Maildir
  - Scheduled backups of mail storage and configuration

## 9. Summary

This architecture demonstrates a production-like mail server design:

- Separation of concerns between MTA, MDA, and signing
- Security at multiple layers
- Clear data flow for inbound/outbound messages
- Observability for monitoring and debugging
- Scalability options for future expansion

It provides a strong foundation to discuss **system design** in interviews, particularly regarding availability, reliability, and security.
