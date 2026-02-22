# 05 - Dovecot Configuration

This document explains how to configure **Dovecot** for IMAP and POP3 mail delivery, secure authentication, and SSL/TLS support, integrated with Postfix for a full mail server setup.

## 1. Main Dovecot Configuration

Edit the main configuration file:

```bash
sudo nano /etc/dovecot/dovecot.conf
```

### Key Settings

```conf
!include_try /usr/share/dovecot/protocols.d/*.protocol
!include conf.d/*.conf

protocols = imap pop3 lmtp
log_path = /var/log/dovecot.log
```

**Explanation:**

- `protocols` – enables IMAP, POP3, and LMTP (used internally for mail delivery).
- Includes all `conf.d/*.conf` files for modular configuration.

## 2. Mail Location – `/etc/dovecot/conf.d/10-mail.conf`

```bash
sudo nano /etc/dovecot/conf.d/10-mail.conf
```

```conf
mail_location = maildir:~/Maildir

namespace inbox {
  inbox = yes
}
```

**Explanation:**

- `mail_location` – sets **Maildir** format for user mailboxes.
- Namespace ensures the INBOX is recognized correctly by mail clients.

## 3. Authentication – `/etc/dovecot/conf.d/10-auth.conf`

```bash
sudo nano /etc/dovecot/conf.d/10-auth.conf
```

```conf
disable_plaintext_auth = no   # Set to yes to enforce TLS-only authentication
auth_mechanisms = plain login
!include auth-system.conf.ext
```

**Explanation:**

- `disable_plaintext_auth=no` allows non-TLS authentication for testing; set to `yes` in production with TLS.
- `auth_mechanisms` – supports plain and login mechanisms.
- `auth-system.conf.ext` – uses system users for authentication.

## 4. Dovecot Master – `/etc/dovecot/conf.d/10-master.conf`

```bash
sudo nano /etc/dovecot/conf.d/10-master.conf
```

```conf
service auth {
  unix_listener /var/spool/postfix/private/auth {
    mode = 0660
    user = postfix
    group = postfix
  }
}
```

**Explanation:**

- Creates a **Postfix auth socket** so Postfix can authenticate users via Dovecot SASL.

## 5. SSL/TLS – `/etc/dovecot/conf.d/10-ssl.conf`

```bash
sudo nano /etc/dovecot/conf.d/10-ssl.conf
```

conftext
ssl = required
ssl_cert = </etc/letsencrypt/live/mail.itsrighttime.group/fullchain.pem
ssl_key = </etc/letsencrypt/live/mail.itsrighttime.group/privkey.pem
ssl_protocols = !SSLv2 !SSLv3
ssl_min_protocol = TLSv1.2
ssl_cipher_list = HIGH:!aNULL:!MD5

````

**Explanation:**

* Enforces TLS for secure IMAP/POP3 connections.
* Uses Let’s Encrypt certificates installed earlier.


## 6. Enable and Restart Dovecot

```bash
sudo systemctl enable dovecot
sudo systemctl restart dovecot
sudo systemctl status dovecot
````

Verify configuration:

```bash
doveadm config
doveadm -n
```

## 7. User Mailbox Setup

Create a test user with Maildir:

```bash
sudo adduser testuser
sudo mkdir -p /home/testuser/Maildir
sudo chown -R testuser:testuser /home/testuser/Maildir
sudo chmod -R 700 /home/testuser/Maildir
```

Test mailbox:

```bash
su - testuser
mail
doveadm mailbox status INBOX
```

## 8. Testing Dovecot

### 8.1 IMAP Test via OpenSSL

```bash
openssl s_client -connect mail.itsrighttime.group:993
```

**Expected Output:**
TLS handshake succeeds, Dovecot IMAP banner appears:

```
* OK [CAPABILITY ...] Dovecot ready.
```

### 8.2 POP3 Test

```bash
openssl s_client -connect mail.itsrighttime.group:995
```

### 8.3 Mail Client Test

- Configure any email client (Thunderbird, Outlook) using:
  - **IMAP**: mail.itsrighttime.group, port 993, SSL/TLS
  - **POP3**: mail.itsrighttime.group, port 995, SSL/TLS
  - **SMTP**: mail.itsrighttime.group, port 465/587, TLS

Use `testuser@itsrighttime.group` credentials.

## 9. Logs and Debugging

```bash
sudo tail -f /var/log/mail.log
sudo journalctl -xe | grep dovecot
sudo doveadm log find
```

- Check logs for TLS errors, login issues, or mailbox permission errors.

## 10. Summary

- Dovecot configured for IMAP, POP3, and LMTP
- Maildir format used for mail storage
- TLS/SSL enforced with Let’s Encrypt certificates
- SASL authentication enabled for Postfix integration
- Test users and mailboxes verified
- Compatible with standard email clients

This ensures **Dovecot is fully integrated with Postfix** and ready for secure production use.
