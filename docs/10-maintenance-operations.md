# 10 - Maintenance & Operations

This document describes operational practices for maintaining the self-hosted mail server in a production environment.

The focus is on:

- Monitoring
- Backups
- Upgrades
- Incident handling
- Performance management
- Capacity planning

## 1. Service Monitoring

### 1.1 Systemd Health Checks

```bash
sudo systemctl status postfix
sudo systemctl status dovecot
sudo systemctl status opendkim
sudo systemctl status fail2ban
```

Automated health check script (optional):

```bash id="w4j9rx"
#!/bin/bash
services=("postfix" "dovecot" "opendkim")

for service in "${services[@]}"; do
    systemctl is-active --quiet $service
    if [ $? -ne 0 ]; then
        echo "$service is NOT running"
    else
        echo "$service is running"
    fi
done
```

## 2. Log Monitoring

### 2.1 Important Logs

```text id="2r8zqe"
/var/log/mail.log
/var/log/dovecot.log
/var/log/auth.log
```

### 2.2 Real-time Monitoring

```bash id="x7n9lk"
sudo tail -f /var/log/mail.log
```

### 2.3 Common Error Patterns

- `authentication failure`
- `relay access denied`
- `connect to ... refused`
- `warning: TLS library problem`
- `opendkim: signing table references unknown key`

## 3. Backup Strategy

### 3.1 What to Backup

- `/etc/postfix/`
- `/etc/dovecot/`
- `/etc/opendkim/`
- `/home/*/Maildir/`
- MySQL database (if virtual users used)

### 3.2 Manual Backup

```bash id="4ypt73"
sudo tar -czvf mail-backup-$(date +%F).tar.gz \
/etc/postfix \
/etc/dovecot \
/etc/opendkim \
/home/*/Maildir
```

### 3.3 MySQL Backup

```bash id="6zq3mt"
mysqldump -u root -p mailserver > mailserver_backup.sql
```

### 3.4 Automated Daily Backup (Cron)

```bash id="mv8n01"
sudo crontab -e
```

```text id="ok1p3a"
0 2 * * * tar -czf /root/mail-backup-$(date +\%F).tar.gz /etc/postfix /etc/dovecot /etc/opendkim /home/*/Maildir
```

## 4. Update & Patch Management

### 4.1 Manual Update

```bash id="v4rlzo"
sudo apt update
sudo apt upgrade -y
```

### 4.2 Enable Automatic Security Updates

```bash id="1lgqzn"
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure unattended-upgrades
```

## 5. TLS Certificate Management

### 5.1 Check Expiry

```bash id="xq7du9"
sudo certbot certificates
```

### 5.2 Test Renewal

```bash id="u9pe48"
sudo certbot renew --dry-run
```

### 5.3 Reload Services After Renewal

```bash id="t8o2dz"
sudo systemctl reload postfix
sudo systemctl reload dovecot
```

## 6. Mail Queue Management

### 6.1 Inspect Queue

```bash id="o5p91r"
postqueue -p
```

### 6.2 Flush Queue

```bash id="v92h3e"
postqueue -f
```

### 6.3 Delete Stuck Emails

```bash id="ql8v7s"
postsuper -d ALL
```

## 7. Capacity Planning

### 7.1 Monitor Disk Usage

```bash id="i7ps2k"
df -h
du -sh /home/*/Maildir
```

### 7.2 Monitor Memory & CPU

```bash id="w7dr4n"
top
htop
```

Key bottlenecks:

- High TLS usage → CPU bound
- Large mailboxes → disk I/O bound
- High concurrent connections → memory bound

## 8. Performance Optimization

- Enable connection limits in Postfix
- Configure Dovecot mail cache
- Rotate logs to prevent disk overflow
- Archive old mail periodically
- Enforce mailbox quotas

Example (Postfix limits):

```text id="e5y8qs"
default_process_limit = 100
smtpd_client_connection_count_limit = 20
```

## 9. Incident Handling

### Scenario 1: Emails Going to Spam

Check:

- SPF record
- DKIM signing
- DMARC policy
- Reverse DNS
- Blacklist status

### Scenario 2: Mail Not Sending

Check:

```bash id="kp4s0d"
postqueue -p
sudo tail -f /var/log/mail.log
```

Common causes:

- DNS misconfiguration
- TLS failure
- Open relay restriction
- Port 25 blocked by ISP

### Scenario 3: Authentication Failures

Check:

```bash id="z6lm5q"
sudo grep "authentication failure" /var/log/mail.log
```

Possible causes:

- Incorrect password
- Maildir permission issue
- SASL socket misconfiguration

## 10. Scaling Operations

When traffic increases:

- Add additional Postfix nodes (MX failover)
- Move mail storage to network storage
- Separate DKIM as dedicated service
- Add monitoring stack (Prometheus + Grafana)
- Implement centralized logging (ELK)

## 11. Disaster Recovery Plan

1. Provision new VPS
2. Restore backups
3. Reconfigure DNS if IP changes
4. Restore MySQL database
5. Restart services
6. Validate SPF/DKIM/DMARC
7. Run full test suite

Recovery Time Objective (RTO):

- ~1–2 hours depending on backup availability

## 12. Operational Best Practices Implemented

- Regular backups
- Automated certificate renewal
- Automatic security updates
- Fail2ban protection
- Firewall enforcement
- Monitoring critical services
- Controlled mail queue management
- Scalable architecture design

## Conclusion

This mail server is not only configured and secured, but also:

- Maintained with operational discipline
- Backed up for disaster recovery
- Monitored for failures
- Scalable for future growth

This demonstrates production-grade backend infrastructure ownership.
