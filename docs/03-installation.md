# 03 - Installation Guide

This document provides step-by-step instructions to install and configure the **self-hosted mail server** on a Linux (Ubuntu/Debian) VPS.  
The setup uses **Postfix**, **Dovecot**, **OpenDKIM**, and optional **MySQL** for virtual users.

## 1. System Preparation

### 1.1 Update System Packages

```bash
sudo apt update && sudo apt upgrade -y
```

### 1.2 Install Essential Packages

```bash
sudo apt install ufw mailutils curl wget nano -y
```

- **ufw** → firewall management
- **mailutils** → test emails
- **curl, wget, nano** → utilities

### 1.3 Set Hostname

```bash
sudo hostnamectl set-hostname mail.itsrighttime.group
```

- Update `/etc/hosts` if necessary.

## 2. Install Mail Server Packages

```bash
sudo apt install postfix dovecot-core dovecot-imapd dovecot-pop3d opendkim opendkim-tools postfix-mysql mysql-server -y
sudo mysql_secure_installation
```

### 2.1 Postfix Setup

- Choose **Internet Site** when prompted
- Set domain: `itsrighttime.group`

**Purpose:**

- Postfix → SMTP
- Dovecot → IMAP/POP3
- OpenDKIM → DKIM signing
- MySQL → Optional for virtual users

## 3. Postfix Configuration

Edit main configuration:

```bash
sudo nano /etc/postfix/main.cf
```

Key parameters:

```conf
myhostname = mail.itsrighttime.group
mydomain = itsrighttime.group
myorigin = /etc/mailname
inet_interfaces = all
inet_protocols = all
home_mailbox = Maildir/
smtpd_tls_cert_file=/etc/letsencrypt/live/mail.itsrighttime.group/fullchain.pem
smtpd_tls_key_file=/etc/letsencrypt/live/mail.itsrighttime.group/privkey.pem
smtpd_use_tls=yes
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_auth_enable = yes
smtpd_milters = inet:localhost:12345
non_smtpd_milters = inet:localhost:12345
```

Enable and restart:

```bash
sudo systemctl enable postfix
sudo systemctl restart postfix
```

Verify:

```bash
postconf | grep smtpd_sasl
postqueue -p
```

## 4. Dovecot Configuration

Edit the following files:

```bash
sudo nano /etc/dovecot/dovecot.conf
sudo nano /etc/dovecot/conf.d/10-mail.conf
sudo nano /etc/dovecot/conf.d/10-auth.conf
sudo nano /etc/dovecot/conf.d/10-master.conf
sudo nano /etc/dovecot/conf.d/10-ssl.conf
```

### Key Settings:

- Mail location: `Maildir/`
- Authentication: Dovecot SASL for Postfix
- SSL: Let's Encrypt certificates

Enable and restart:

```bash
sudo systemctl enable dovecot
sudo systemctl restart dovecot
sudo doveadm mailbox status INBOX
```

## 5. OpenDKIM Setup

### 5.1 Generate DKIM Keys

```bash
sudo mkdir -p /etc/opendkim/keys/itsrighttime.group
cd /etc/opendkim/keys/itsrighttime.group
sudo opendkim-genkey -t -s default -d itsrighttime.group
sudo chown opendkim:opendkim default.private
sudo chmod 600 default.private
```

### 5.2 Configure OpenDKIM

Edit configuration files:

```conf
/etc/opendkim.conf
/etc/opendkim/KeyTable
/etc/opendkim/SigningTable
/etc/opendkim/TrustedHosts
```

### 5.3 Integrate with Postfix

```bash
sudo postconf -e "smtpd_milters=inet:localhost:12345"
sudo postconf -e "non_smtpd_milters=inet:localhost:12345"
sudo systemctl enable opendkim
sudo systemctl restart opendkim
```

Verify DKIM:

```bash
dig TXT default._domainkey.itsrighttime.group +short
```

## 6. Create Mail Users

```bash
sudo adduser testuser
sudo mkdir -p /home/testuser/Maildir
sudo chown -R testuser:testuser /home/testuser/Maildir
sudo chmod -R 700 /home/testuser/Maildir
```

Test sending local mail:

```bash
echo "Test Email" | mail -s "Local Test" testuser
```

Delete a user:

```bash
sudo deluser --remove-home charlie
sudo rm -f /var/mail/charlie
```

## 7. SSL/TLS Certificates

### 7.1 Let’s Encrypt (Recommended)

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot certonly --standalone -d mail.itsrighttime.group
sudo systemctl restart dovecot postfix
```

### 7.2 Self-Signed (Optional)

```bash
sudo openssl req -new -x509 -days 365 -nodes -out /etc/ssl/certs/mail.itsrighttime.group.crt -keyout /etc/ssl/private/mail.itsrighttime.group.key
```

Verify:

```bash
openssl s_client -connect mail.itsrighttime.group:993
openssl s_client -connect mail.itsrighttime.group:587 -starttls smtp
```

## 8. Firewall Configuration (UFW)

```bash
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 25/tcp    # SMTP
sudo ufw allow 465/tcp   # SMTPS
sudo ufw allow 587/tcp   # SMTP Submission
sudo ufw allow 143/tcp   # IMAP
sudo ufw allow 993/tcp   # IMAPS
sudo ufw allow 110/tcp   # POP3
sudo ufw allow 995/tcp   # POP3S
sudo ufw reload
sudo ufw status
```

## 9. Testing & Verification

- Check Postfix & Dovecot status:

```bash
sudo systemctl status postfix
sudo systemctl status dovecot
```

- Send test emails (local & external):

```bash
echo "SMTP Test" | mail -s "Test Subject" your-email@gmail.com
```

- Check DKIM/SPF/DMARC with online validators or:

```bash
sendmail -v check-auth@verifier.port25.com
```

- Check ports & TLS:

```bash
openssl s_client -connect mail.itsrighttime.group:993
openssl s_client -connect mail.itsrighttime.group:465 -starttls smtp
```

## 10. Summary

- System prepared, packages installed
- Postfix configured for SMTP with TLS & DKIM
- Dovecot configured for IMAP/POP3
- OpenDKIM integrated and verified
- Users created and mail flow tested
- Firewall configured, SSL/TLS secured

This completes the **installation of a fully self-hosted mail server** ready for production use on a VPS.
