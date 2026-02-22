# 01 - System Overview

## 1. Introduction

This document provides a high-level overview of the self-hosted mail server architecture deployed on a VPS provisioned from Hostinger.

The system is designed to handle:

- Secure email sending (SMTP)
- Secure email retrieval (IMAP / POP3)
- Domain-level email authentication (SPF, DKIM, DMARC)
- TLS encryption
- Firewall-level access control
- Production-style logging and monitoring

The goal of this project is to design and operate a fully functional mail server without relying on managed cloud email services.

---

## 2. High-Level Architecture

The system consists of the following major components:

Client (Email App / Webmail)
↓
SMTP Submission (Port 587 / 465)
↓
Postfix (Mail Transfer Agent)
↓
OpenDKIM (Message Signing)
↓
DNS Authentication (SPF / DKIM / DMARC)
↓
Recipient Mail Server

For mail retrieval:

Client → IMAPS (Port 993) → Dovecot → Maildir Storage

---

## 3. Core Components

### 3.1 Postfix – Mail Transfer Agent (MTA)

Responsible for:

- Sending outgoing emails
- Receiving incoming emails
- Routing emails to correct destination
- Enforcing SMTP authentication
- TLS encryption
- Preventing open relay abuse
- Integrating with DKIM signing

Postfix acts as the core email processing engine.

---

### 3.2 Dovecot – Mail Delivery Agent (MDA) & IMAP Server

Responsible for:

- Mailbox access via IMAP / POP3
- User authentication
- Maildir storage management
- Secure TLS communication
- SASL authentication backend for Postfix

Dovecot ensures secure and reliable mailbox retrieval.

---

### 3.3 OpenDKIM – Email Signing Service

Responsible for:

- Cryptographic signing of outgoing emails
- Validating message integrity
- Improving email deliverability
- Reducing spoofing and phishing risks

OpenDKIM integrates with Postfix via milter.

---

### 3.4 DNS Authentication Layer

The system implements:

- A / AAAA records → IP mapping
- MX record → Mail routing
- SPF → Sender authorization
- DKIM → Cryptographic message validation
- DMARC → Policy enforcement
- Reverse DNS (PTR) → Spam trust validation

This layer ensures external mail servers trust the domain.

---

## 4. Data Flow

### 4.1 Outgoing Mail Flow

1. User authenticates via SMTP submission (Port 587)
2. Postfix validates credentials via Dovecot (SASL)
3. Email is signed by OpenDKIM
4. Postfix performs DNS lookup for recipient MX
5. Mail is delivered to recipient server
6. Recipient verifies SPF, DKIM, DMARC

---

### 4.2 Incoming Mail Flow

1. External server resolves MX record
2. Email is delivered to Postfix
3. Postfix stores email in user Maildir
4. User retrieves email via IMAPS (Port 993) using Dovecot

---

## 5. Security Model

The system enforces:

- TLS encryption for SMTP and IMAP
- SASL authentication
- No open relay configuration
- Firewall restrictions (UFW)
- DKIM signing
- SPF authorization
- DMARC policy monitoring
- Reverse DNS mapping

Security is implemented at multiple layers:

- Network layer
- Application layer
- DNS layer
- Authentication layer

---

## 6. Deployment Environment

- VPS hosted on Hostinger
- Public IPv4 and IPv6 enabled
- Ubuntu/Debian-based Linux system
- UFW firewall enabled
- Let’s Encrypt certificates for TLS

The server is manually configured without managed mail providers.

---

## 7. Design Goals

This system was built with the following goals:

- End-to-end understanding of mail infrastructure
- Secure-by-default configuration
- Production-style service management
- Observability via logs
- Clear separation of responsibilities
- Scalability considerations for future expansion

---

## 8. Limitations (Current Version)

- Single VPS (single point of failure)
- No clustering
- No distributed storage
- No automated scaling
- Manual deployment process

These limitations are addressed in later design documents (see scaling and system design section).
