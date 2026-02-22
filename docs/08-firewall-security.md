# 08 - Firewall & Security Hardening

This document describes the firewall configuration and additional security measures implemented to protect the self-hosted mail server in a production environment.

The goal is to:

- Minimize exposed attack surface
- Prevent brute-force attacks
- Secure mail protocols with TLS
- Enforce least-privilege access
- Improve deliverability and trust

## 1. Firewall Configuration (UFW)

UFW (Uncomplicated Firewall) is used to control inbound traffic.

### 1.1 Enable UFW

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
```

### 1.2 Open Required Ports

Only required services are exposed:

```bash
# SSH
sudo ufw allow 22/tcp

# Web (for Let's Encrypt)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# SMTP
sudo ufw allow 25/tcp        # Mail transfer
sudo ufw allow 465/tcp       # SMTPS
sudo ufw allow 587/tcp       # Submission

# IMAP / POP3
sudo ufw allow 143/tcp       # IMAP
sudo ufw allow 993/tcp       # IMAPS
sudo ufw allow 110/tcp       # POP3
sudo ufw allow 995/tcp       # POP3S

sudo ufw reload
sudo ufw status verbose
```

### Security Principle:

Only open ports that are absolutely necessary.

## 2. Fail2ban – Brute Force Protection

Fail2ban monitors logs and blocks IPs with repeated failed login attempts.

### 2.1 Install Fail2ban

```bash
sudo apt install fail2ban -y
```

### 2.2 Configure Jail for Postfix & Dovecot

Create local jail file:

```bash
sudo nano /etc/fail2ban/jail.local
```

```conf
[postfix]
enabled = true
port    = smtp,ssmtp,submission
filter  = postfix
logpath = /var/log/mail.log
maxretry = 5

[dovecot]
enabled = true
port    = imap,imaps,pop3,pop3s
filter  = dovecot
logpath = /var/log/mail.log
maxretry = 5
```

Restart Fail2ban:

```bash
sudo systemctl restart fail2ban
sudo systemctl status fail2ban
```

Check banned IPs:

```bash
sudo fail2ban-client status
sudo fail2ban-client status postfix
```

## 3. TLS Hardening

### 3.1 Enforce TLS in Postfix

Ensure in `/etc/postfix/main.cf`:

```conf
smtpd_tls_security_level = may
smtpd_tls_auth_only = yes
smtp_tls_security_level = may
```

### 3.2 Enforce TLS in Dovecot

In `/etc/dovecot/conf.d/10-ssl.conf`:

```conf
ssl = required
ssl_min_protocol = TLSv1.2
ssl_protocols = !SSLv2 !SSLv3
ssl_cipher_list = HIGH:!aNULL:!MD5
```

### 3.3 Certificate Auto Renewal

```bash
sudo certbot renew --dry-run
```

Add cron job:

```bash
sudo crontab -e
```

```conf
0 3 * * * certbot renew --quiet && systemctl reload postfix dovecot
```

## 4. Disable Open Relay

Ensure Postfix is not an open relay.

In `/etc/postfix/main.cf`:

```conf
smtpd_recipient_restrictions =
    permit_sasl_authenticated,
    permit_mynetworks,
    reject_unauth_destination
```

Verify:

```bash
postconf -n | grep reject_unauth_destination
```

## 5. SSH Hardening

Edit:

```bash
sudo nano /etc/ssh/sshd_config
```

Recommended changes:

```conf
PermitRootLogin no
PasswordAuthentication no
Port 22
```

Restart SSH:

```bash
sudo systemctl restart ssh
```

Optional:

- Use SSH key-based authentication only
- Change SSH port (security by obscurity, optional)

## 6. System Updates & Patch Management

Regularly update system:

```bash
sudo apt update && sudo apt upgrade -y
```

Enable unattended upgrades:

```bash
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure unattended-upgrades
```

## 7. Log Monitoring

Important logs:

```bash
/var/log/mail.log
/var/log/dovecot.log
/var/log/auth.log
```

Monitor in real time:

```bash
sudo tail -f /var/log/mail.log
```

Useful checks:

```bash
postqueue -p
sudo netstat -tulnp
sudo ss -tulnp
```

## 8. Security Best Practices Implemented

- Firewall default deny policy
- Only required ports exposed
- Fail2ban for brute-force mitigation
- TLS enforced for mail protocols
- DKIM/SPF/DMARC configured
- Reverse DNS configured
- No open relay
- SSH hardened
- Automatic certificate renewal
- Automatic security updates

## 9. Future Security Enhancements

- Rate limiting per IP/user
- Spam filtering (SpamAssassin, Rspamd)
- Intrusion detection system (OSSEC)
- Centralized logging (ELK stack)
- SIEM integration
- Docker/container isolation
- IP reputation monitoring

This completes the security hardening of the self-hosted mail server.

The system is now:

- Secure
- Production-ready
- Hardened against common attacks
- Configured with industry-standard email authentication mechanisms
