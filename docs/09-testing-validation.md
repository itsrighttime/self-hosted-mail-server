# 09 - Testing & Validation

This document provides end-to-end testing and validation steps for the self-hosted mail server.

The objective is to verify:

- SMTP functionality (inbound & outbound)
- IMAP / POP3 access
- TLS encryption
- SPF, DKIM, DMARC validation
- Reverse DNS
- Queue handling
- Service health

## 1. Service Health Checks

### 1.1 Check Running Services

```bash
sudo systemctl status postfix
sudo systemctl status dovecot
sudo systemctl status opendkim
sudo systemctl status fail2ban
```

Expected:

- All services → `active (running)`

### 1.2 Check Listening Ports

```bash
sudo ss -tulnp
```

Expected open ports:

| Service    | Port |
| ---------- | ---- |
| SMTP       | 25   |
| SMTPS      | 465  |
| Submission | 587  |
| IMAP       | 143  |
| IMAPS      | 993  |
| POP3       | 110  |
| POP3S      | 995  |

## 2. SMTP Testing

### 2.1 Local Email Test

```bash
echo "Local Test Email" | mail -s "Test Subject" testuser@itsrighttime.group
```

Verify mailbox:

```bash
su - testuser
mail
```

### 2.2 External Email Test

```bash
echo "External Test" | mail -s "SMTP Test" your-email@gmail.com
```

Check:

- Delivered successfully
- Not marked as spam

### 2.3 SMTP Manual Test (Telnet)

```bash
telnet mail.itsrighttime.group 25
```

Expected:

```conf
220 mail.itsrighttime.group ESMTP Postfix
```

Test SMTP handshake:

```conf
EHLO example.com
MAIL FROM:<admin@itsrighttime.group>
RCPT TO:<recipient@gmail.com>
DATA
Subject: SMTP Manual Test

This is a manual SMTP test.
.
QUIT
```

## 3. IMAP / POP3 Testing

### 3.1 IMAPS Test

```bash
openssl s_client -connect mail.itsrighttime.group:993
```

Expected:

```conf
* OK [CAPABILITY ...] Dovecot ready.
```

### 3.2 POP3S Test

```bash
openssl s_client -connect mail.itsrighttime.group:995
```

### 3.3 Mail Client Configuration Test

Use a mail client (Thunderbird / Outlook):

| Setting     | Value                   |
| ----------- | ----------------------- |
| IMAP Server | mail.itsrighttime.group |
| Port        | 993                     |
| Encryption  | SSL/TLS                 |
| SMTP        | mail.itsrighttime.group |
| Port        | 587                     |
| Auth        | Normal password         |

Login using:

```conf
testuser@itsrighttime.group
```

Expected:

- Inbox loads
- Emails can be sent & received

## 4. SPF, DKIM & DMARC Validation

### 4.1 Verify DNS Records

```bash
dig MX itsrighttime.group
dig TXT itsrighttime.group
dig TXT default._domainkey.itsrighttime.group
dig TXT _dmarc.itsrighttime.group
```

### 4.2 DKIM Verification (Port25)

Send test email:

```bash
sendmail -v check-auth@verifier.port25.com
From: admin@itsrighttime.group
To: check-auth@verifier.port25.com
Subject: DKIM Test

Testing DKIM configuration.
.
```

Expected report:

- SPF → PASS
- DKIM → PASS
- DMARC → PASS

### 4.3 Gmail Header Inspection

Send email to Gmail → Open email → “Show Original”.

Expected:

```conf
SPF: PASS
DKIM: PASS
DMARC: PASS
```

## 5. Reverse DNS Validation

```bash
dig -x 72.60.201.63
dig -x 2a02:4780:12:8498::1
```

Expected:

```conf
mail.itsrighttime.group
```

Mismatch between HELO hostname and PTR can cause spam classification.

## 6. Mail Queue Monitoring

Check queue:

```bash
postqueue -p
```

Flush queue:

```bash
postqueue -f
```

Delete queued mail:

```bash
postsuper -d ALL
```

Expected:

- Queue empty under normal conditions.

## 7. Log Inspection & Debugging

### 7.1 Mail Logs

```bash
sudo tail -f /var/log/mail.log
```

### 7.2 Authentication Logs

```bash
sudo grep "authentication failure" /var/log/mail.log
```

### 7.3 DKIM Logs

```bash
sudo journalctl -xe | grep opendkim
```

## 8. TLS Certificate Validation

### 8.1 SMTP TLS

```bash
openssl s_client -connect mail.itsrighttime.group:587 -starttls smtp
```

### 8.2 IMAP TLS

```bash
openssl s_client -connect mail.itsrighttime.group:993
```

Verify:

- Valid certificate chain
- Not expired
- Correct CN / SAN

## 9. Fail2ban Validation

Trigger failed login attempts.

Check banned IP:

```bash
sudo fail2ban-client status postfix
```

Expected:

- Offending IP listed in banned list.

## 10. Final Validation Checklist

| Component        | Status |
| ---------------- | ------ |
| Postfix running  | ✅     |
| Dovecot running  | ✅     |
| OpenDKIM running | ✅     |
| Firewall active  | ✅     |
| SPF configured   | ✅     |
| DKIM signing     | ✅     |
| DMARC policy     | ✅     |
| Reverse DNS set  | ✅     |
| TLS enforced     | ✅     |
| No open relay    | ✅     |
| Mail queue clean | ✅     |

## Conclusion

The system has been tested across:

- Transport layer (SMTP)
- Retrieval layer (IMAP/POP3)
- Security layer (TLS)
- Authentication layer (SASL)
- Domain validation (SPF/DKIM/DMARC)
- Network layer (Firewall & PTR)

This confirms the mail server is fully functional, secure, and production-ready.
