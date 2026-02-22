# Mail Server Monitoring & Dashboard

## **1. Purpose**

The purpose of this dashboard is to provide **real-time monitoring, alerting, and health insights** for a self-hosted mail server. It ensures that services are **available, reliable, and secure**, and allows for **proactive maintenance**.

Key monitoring goals:

- Detect service outages (Postfix, Dovecot, OpenDKIM)
- Monitor mail queues for bottlenecks
- Verify SSL/TLS certificate validity
- Track disk usage and storage trends
- Monitor DNS/Email deliverability (SPF/DKIM/DMARC)
- Enable alerting for critical events

## **2. Metrics & Monitoring Components**

### **A. Service Status**

| Service  | Metric          | Threshold / Alert | Tool / Method         |
| -------- | --------------- | ----------------- | --------------------- |
| Postfix  | Active/Inactive | Alert if inactive | `systemctl is-active` |
| Dovecot  | Active/Inactive | Alert if inactive | `systemctl is-active` |
| OpenDKIM | Active/Inactive | Alert if inactive | `systemctl is-active` |

### **B. Mail Queue**

| Metric                | Threshold / Alert      | Tool / Method     |
| --------------------- | ---------------------- | ----------------- |
| Mail queue size       | > 50 pending emails ⚠️ | `postqueue -p`    |
| Average delivery time | > 2 min per email ⚠️   | Logs / `mail.log` |

### **C. Disk Usage**

| Metric                | Threshold / Alert | Tool / Method            |
| --------------------- | ----------------- | ------------------------ |
| Maildir disk usage    | > 80% capacity ⚠️ | `du -sh /home/*/Maildir` |
| Root filesystem usage | > 85% capacity ⚠️ | `df -h`                  |

### **D. SSL/TLS Certificate**

| Metric               | Threshold / Alert      | Tool / Method             |
| -------------------- | ---------------------- | ------------------------- |
| Expiry date          | < 30 days remaining ⚠️ | `openssl x509 -enddate`   |
| Certificate validity | Invalid or missing ❌  | File check & OpenSSL test |

### **E. Network / Ports**

| Metric                 | Threshold / Alert | Tool / Method             |
| ---------------------- | ----------------- | ------------------------- |
| SMTP / SMTPS / IMAP(S) | Port closed ❌    | `nc -zv localhost <port>` |

### **F. DNS & Email Authentication**

| Metric                     | Threshold / Alert          | Tool / Method      |
| -------------------------- | -------------------------- | ------------------ |
| SPF / DKIM / DMARC records | Missing / misconfigured ❌ | `dig TXT <domain>` |
| Reverse DNS (PTR)          | Not matching ❌            | `dig -x <IP>`      |

## **3. Dashboard Design**

### **A. Local CLI Dashboard**

- Lightweight, suitable for VPS without GUI
- Combines health checks in one script (`health-check.sh`)
- Example summary:

```
SERVICES:
- Postfix: active ✅
- Dovecot: active ✅
- OpenDKIM: active ✅

MAIL QUEUE: 0 messages ✅

DISK USAGE:
- /home/user/Maildir: 25% ✅
- /: 40% ✅

CERTIFICATE: Valid, expires in 45 days ✅

PORTS:
- 25: open ✅
- 465: open ✅
- 587: open ✅
- 143: open ✅
- 993: open ✅

DNS / EMAIL AUTH:
- SPF: valid ✅
- DKIM: valid ✅
- DMARC: valid ✅
```

### **B. Web / GUI Dashboard (Optional Advanced)**

- **Prometheus**: Collect metrics from custom exporters or system stats
- **Grafana**: Visualize metrics (mail queue size, service uptime, disk usage, certificate expiry)
- **Alertmanager**: Trigger email/SMS alerts for failures
- **Optional**: Integrate logs (Postfix/Dovecot) using ELK stack (Elasticsearch, Logstash, Kibana) for historical trends

**Example Panels**:

- Service uptime (Postfix, Dovecot, OpenDKIM)
- Mail queue trends over time
- Disk usage / Maildir growth
- Certificate expiry countdown
- Port availability heatmap
- DNS/email authentication health

## **4. Alerting Strategy**

- **Critical alerts**: Service down, mail queue > threshold, SSL expired
- **Warning alerts**: Disk usage > 80%, mail delivery delays
- **Delivery method**: Email notifications, optional Slack or SMS
- **Tools**: Cron + `health-check.sh`, or Prometheus + Alertmanager

## **5. System Design Considerations**

- **Scalability**: For multiple domains, monitor each mail server independently
- **High Availability**: Consider backup MX server or containerized mail services
- **Observability**: All metrics, logs, and alerts are centralized for easy troubleshooting
- **Security**: Monitor failed login attempts and unusual mail traffic
- **Extensibility**: Can integrate spam/virus scanning metrics (SpamAssassin/ClamAV)

## **6. Next Steps / Improvements**

- Add automatic certificate renewal monitoring
- Integrate mail delivery success/failure rates
- Add historical trend graphs for queue size and disk usage
- Implement role-based dashboard for multiple admins
- Integrate with Hostinger VPS monitoring APIs if needed
