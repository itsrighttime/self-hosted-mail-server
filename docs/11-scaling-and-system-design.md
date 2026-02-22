# 11 - Scaling & System Design

This document describes how the self-hosted mail server can evolve from a single-node deployment to a scalable, highly available, production-grade distributed system.

The focus is on:

- Horizontal scaling
- High availability (HA)
- Performance bottlenecks
- Trade-offs
- Failure handling
- Capacity planning

## 1. Current Architecture (Baseline)

Current setup:

- Single VPS
- Postfix (SMTP)
- Dovecot (IMAP/POP3)
- OpenDKIM (Signing)
- Local Maildir storage
- UFW + Fail2ban
- DNS with SPF, DKIM, DMARC

### Limitations:

- Single point of failure
- Limited vertical scalability
- Storage tied to single machine
- No automatic failover

## 2. Scaling Strategy

Scaling can be achieved in two ways:

1. Vertical Scaling
2. Horizontal Scaling

## 3. Vertical Scaling

Upgrade VPS resources:

- Increase CPU (TLS + DKIM are CPU intensive)
- Increase RAM (concurrent IMAP sessions)
- Increase Disk IOPS (Maildir heavy usage)
- NVMe preferred over HDD

### When to Use:

- < 50,000 emails/day
- < 10,000 active users
- Low to moderate concurrency

### Limitations:

- Still single point of failure
- Scaling ceiling exists
- Expensive at high tiers

## 4. Horizontal Scaling (Recommended for Growth)

### 4.1 Multiple Postfix Nodes

Deploy multiple Postfix servers.

DNS configuration:

| Record | Purpose                  |
| ------ | ------------------------ |
| MX 10  | mail1.itsrighttime.group |
| MX 20  | mail2.itsrighttime.group |

Benefits:

- Automatic failover
- Load distribution
- Improved availability

Postfix nodes can:

- Share DKIM signing service
- Share backend storage
- Be placed behind load balancer

### 4.2 Stateless DKIM Service

OpenDKIM is stateless.

Scaling approach:

- Run dedicated DKIM service nodes
- Use TCP socket connection
- Multiple Postfix instances connect to DKIM cluster

Benefits:

- Independent scaling
- Reduced CPU load on MTA nodes

### 4.3 Distributed Mail Storage

Replace local Maildir with:

- NFS
- GlusterFS
- Ceph
- Object storage gateway

Benefits:

- Multiple Dovecot nodes
- Shared mailbox access
- Redundancy

Trade-off:

- Network latency
- Storage cluster complexity

### 4.4 Dovecot Clustering

Deploy multiple Dovecot instances:

- Connect to shared storage
- Load-balanced via HAProxy
- Session-aware routing

Benefits:

- High IMAP availability
- Reduced user impact during maintenance

## 5. High Availability Architecture (Target State)


```md

                 +--------------------+
                 |      Clients       |
                 +--------------------+
                          |
                  DNS / Load Balancer
                          |
         +----------------+----------------+
         |                                 |
         |                                 |
         |                                 |
    +-------------+                   +-------------+
    | Postfix 1   |                   | Postfix 2   |
    +-------------+                   +-------------+
          |                                 |
          +---------------+-----------------+
                          |
                      DKIM Cluster
                          |
                      Shared Mail Storage
                          |
          +---------------+-----------------+
          |                                 |
    +-------------+                   +-------------+
    | Dovecot 1   |                   | Dovecot 2   |
    +-------------+                   +-------------+

```

## 6. Bottleneck Analysis

| Component        | Potential Bottleneck | Mitigation            |
| ---------------- | -------------------- | --------------------- |
| TLS              | CPU usage            | Add cores / offload   |
| Maildir          | Disk I/O             | NVMe / distributed FS |
| Postfix queue    | High traffic         | Add more MTAs         |
| Dovecot sessions | Memory               | Horizontal scaling    |
| DKIM signing     | CPU bound            | Separate service      |

## 7. Queue & Throughput Optimization

Postfix tuning example:

```conf
default_process_limit = 200
smtpd_client_connection_limit = 50
smtp_destination_concurrency_limit = 20
```

Throughput factors:

- Network bandwidth
- TLS handshake cost
- DNS lookup latency
- Spam filtering overhead

## 8. Reliability Engineering

### Failure Scenarios

#### 1. Postfix Node Failure

- MX failover routes traffic to secondary node
- Zero manual intervention required

#### 2. Dovecot Node Failure

- Load balancer removes unhealthy node
- Other nodes serve clients

#### 3. Storage Failure

- Use replicated storage
- RAID or distributed FS replication

#### 4. DNS Failure

- Use secondary DNS provider
- TTL optimization

## 9. Observability & Metrics

Metrics to collect:

- Mail queue size
- SMTP response time
- IMAP active sessions
- TLS handshake time
- CPU & memory usage
- Disk latency
- DKIM signing errors

Monitoring stack (future):

- Prometheus
- Grafana
- ELK stack
- Alertmanager

## 10. Security at Scale

As system scales:

- Rate limiting per IP
- Outbound throttling
- IP reputation scoring
- Spam filtering (Rspamd)
- Greylisting
- Geo-based restrictions

## 11. Capacity Planning

Estimate:

- Emails per user per day
- Average email size
- Peak concurrency window
- Storage growth per month

Example:

If:

- 5,000 users
- 20 emails/day
- 150KB avg size

Daily traffic:
= 5,000 × 20 × 150KB
= ~15GB/day inbound + outbound processing load

## 12. Trade-offs

| Design Choice       | Advantage         | Trade-off               |
| ------------------- | ----------------- | ----------------------- |
| Single node         | Simpler           | SPOF                    |
| Distributed storage | High availability | Complexity              |
| Multiple MTAs       | Load distribution | DNS tuning required     |
| Strict DMARC reject | Strong security   | Risk of false positives |

## 13. Production-Grade Target

A fully mature architecture would include:

- Multi-region deployment
- Geo-DNS routing
- Containerized services
- CI/CD configuration management
- Automated infrastructure provisioning
- Centralized logging
- Alert-based scaling

## Conclusion

This mail server can evolve from:

Single VPS → Multi-node distributed architecture → Highly available, horizontally scalable mail platform.

The system design demonstrates:

- Clear separation of concerns
- Stateless vs stateful component awareness
- Bottleneck identification
- High availability strategy
- Trade-off analysis
- Production operations mindset

This reflects backend system design competency beyond simple configuration.
