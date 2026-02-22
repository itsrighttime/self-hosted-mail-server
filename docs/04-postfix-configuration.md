# 04 - Postfix Configuration

This document explains how to configure **Postfix** for sending and receiving emails securely, with SASL authentication, TLS, DKIM integration, and virtual users.

## 1. Main Configuration File

Edit the main Postfix configuration:

```bash
sudo nano /etc/postfix/main.cf
```

### Key Parameters

```conf
# General Settings
myhostname = mail.itsrighttime.group
mydomain = itsrighttime.group
myorigin = /etc/mailname
inet_interfaces = all
inet_protocols = all
mydestination = $myhostname, localhost.$mydomain, localhost
home_mailbox = Maildir/

# TLS Settings
smtpd_tls_cert_file=/etc/letsencrypt/live/mail.itsrighttime.group/fullchain.pem
smtpd_tls_key_file=/etc/letsencrypt/live/mail.itsrighttime.group/privkey.pem
smtpd_use_tls=yes
smtp_tls_security_level = may
smtpd_tls_auth_only = yes

# SASL Authentication (Dovecot)
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_auth_enable = yes
smtpd_sasl_security_options = noanonymous
smtpd_sasl_local_domain = $mydomain

# DKIM / Milter
smtpd_milters = inet:localhost:12345
non_smtpd_milters = inet:localhost:12345

# Restrictions
smtpd_recipient_restrictions =
    permit_sasl_authenticated,
    permit_mynetworks,
    reject_unauth_destination
```

## 2. Enable Postfix Services

```bash
sudo systemctl enable postfix
sudo systemctl restart postfix
sudo systemctl status postfix
```

Verify configuration:

```bash
postconf | grep smtpd_sasl
postqueue -p
```

## 3. SASL Authentication via Dovecot

Edit `/etc/dovecot/conf.d/10-master.conf` to configure the Postfix auth socket:

```conf
service auth {
  unix_listener /var/spool/postfix/private/auth {
    mode = 0660
    user = postfix
    group = postfix
  }
}
```

Restart Dovecot:

```bash
sudo systemctl restart dovecot
```

## 4. DKIM Integration (OpenDKIM)

1. Edit `/etc/opendkim.conf`:

```conf
AutoRestart             Yes
AutoRestartRate         10/1h
Canonicalization        relaxed/simple
Mode                    sv
SubDomains              no
Socket                  inet:12345@localhost
KeyTable                /etc/opendkim/KeyTable
SigningTable            /etc/opendkim/SigningTable
TrustedHosts            /etc/opendkim/TrustedHosts
```

2. Add domain keys in `/etc/opendkim/KeyTable`:

```conf
default._domainkey.itsrighttime.group itsrighttime.group:default:/etc/opendkim/keys/itsrighttime.group/default.private
```

3. Add signing table `/etc/opendkim/SigningTable`:

```conf
*@itsrighttime.group default._domainkey.itsrighttime.group
```

4. Add trusted hosts `/etc/opendkim/TrustedHosts`:

```conf
127.0.0.1
localhost
itsrighttime.group
```

Restart OpenDKIM and Postfix:

```bash
sudo systemctl enable opendkim
sudo systemctl restart opendkim
sudo systemctl restart postfix
```

Test DKIM record:

```bash
dig TXT default._domainkey.itsrighttime.group +short
```

## 5. Virtual Users with MySQL (Optional)

1. Create MySQL database for virtual users:

```sql
CREATE DATABASE mailserver;
CREATE USER 'mailuser'@'localhost' IDENTIFIED BY 'StrongPassword';
GRANT ALL PRIVILEGES ON mailserver.* TO 'mailuser'@'localhost';
FLUSH PRIVILEGES;
```

2. Tables:

```sql
CREATE TABLE virtual_users (
  id int NOT NULL AUTO_INCREMENT,
  email varchar(255) NOT NULL,
  password varchar(255) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE virtual_domains (
  id int NOT NULL AUTO_INCREMENT,
  name varchar(50) NOT NULL,
  PRIMARY KEY (id)
);
```

3. Configure Postfix to use MySQL maps:

```text
virtual_mailbox_domains = mysql:/etc/postfix/mysql-virtual-domains-maps.cf
virtual_mailbox_maps = mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf
virtual_alias_maps = mysql:/etc/postfix/mysql-virtual-alias-maps.cf
```

## 6. Testing Postfix

1. Send a test email locally:

```bash
echo "Test Email" | mail -s "Postfix Test" testuser@itsrighttime.group
```

2. Send to an external email:

```bash
echo "External Test" | mail -s "SMTP Test" your-email@gmail.com
```

3. Check logs for errors:

```bash
sudo tail -f /var/log/mail.log
```

## 7. Firewall & Ports

Ensure these ports are open:

| Service    | Port | Protocol |
| ---------- | ---- | -------- |
| SMTP       | 25   | TCP      |
| SMTPS      | 465  | TCP      |
| Submission | 587  | TCP      |
| IMAP       | 143  | TCP      |
| IMAPS      | 993  | TCP      |
| POP3       | 110  | TCP      |
| POP3S      | 995  | TCP      |

```bash
sudo ufw allow 25,465,587,143,993,110,995/tcp
sudo ufw reload
```

## 8. Summary

- Postfix configured for secure mail delivery
- TLS and SASL authentication enabled
- DKIM integrated for outbound emails
- Optional MySQL-based virtual users ready
- Ports and firewall verified

This configuration ensures **Postfix is production-ready** and compatible with standard mail clients.
