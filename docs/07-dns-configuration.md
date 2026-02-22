# 07 - DNS Configuration

This document details all the **DNS records** required for `mail.itsrighttime.group` to operate as a secure, production-ready mail server.

## 1. Domain and Mail Server Overview

| Item                 | Value                      |
| -------------------- | -------------------------- |
| Domain               | `itsrighttime.group`       |
| Mail server hostname | `mail.itsrighttime.group`  |
| VPS IPv4             | `72.60.201.63`             |
| VPS IPv6             | `2a02:4780:12:8498::1`     |
| Admin email          | `admin@itsrighttime.group` |
| DKIM selector        | `default`                  |

## 2. A / AAAA Records

**Purpose:** Maps the mail server hostname to the VPS IP addresses.

| Type | Name | Points to            | TTL     |
| ---- | ---- | -------------------- | ------- |
| A    | mail | 72.60.201.63         | Default |
| AAAA | mail | 2a02:4780:12:8498::1 | Default |

**Verification:**

```bash
dig A mail.itsrighttime.group
dig AAAA mail.itsrighttime.group
ping mail.itsrighttime.group
```

## 3. MX Record

**Purpose:** Routes incoming emails to the mail server.

| Type | Name | Mail Server              | Priority | TTL     |
| ---- | ---- | ------------------------ | -------- | ------- |
| MX   | @    | mail.itsrighttime.group. | 10       | Default |

> Note: Some DNS panels require a trailing dot `.` after the mail server hostname.

**Verification:**

```bash
dig MX itsrighttime.group
```

## 4. SPF Record (TXT)

**Purpose:** Defines authorized senders for the domain to prevent spoofing.

| Type | Name | TXT Value                                                  |
| ---- | ---- | ---------------------------------------------------------- |
| TXT  | @    | v=spf1 a mx ip4:72.60.201.63 ip6:2a02:4780:12:8498::1 ~all |

**Explanation of mechanisms:**

- `a` → allows your domain’s A/AAAA IP addresses
- `mx` → allows your MX server IP
- `ip4:` → explicitly authorizes IPv4
- `ip6:` → explicitly authorizes IPv6
- `~all` → soft fail for unauthorized senders

**Verification:**

```bash
dig TXT itsrighttime.group
```

## 5. DKIM Record (TXT)

**Purpose:** Signs outgoing emails to verify authenticity.

- **Selector:** `default`
- **Public Key:** Copy from `/etc/opendkim/keys/itsrighttime.group/default.txt` (single-line)

| Type | Name                | TXT Value                                                        |
| ---- | ------------------- | ---------------------------------------------------------------- |
| TXT  | default.\_domainkey | v=DKIM1; h=sha256; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAO...IDAQAB |

**Verification:**

```bash
dig TXT default._domainkey.itsrighttime.group
```

## 6. DMARC Record (TXT)

**Purpose:** Instructs recipient servers how to handle messages failing SPF/DKIM and where to send reports.

| Type | Name    | TXT Value                                                                                                            |
| ---- | ------- | -------------------------------------------------------------------------------------------------------------------- |
| TXT  | \_dmarc | v=DMARC1; p=none; rua=mailto:admin@itsrighttime.group; ruf=mailto:admin@itsrighttime.group; sp=none; aspf=s; adkim=s |

> Once verified, `p=none` can be changed to `p=quarantine` or `p=reject` for stricter enforcement.

**Verification:**

```bash
dig TXT _dmarc.itsrighttime.group
```

## 7. PTR / Reverse DNS (Optional but Recommended)

**Purpose:** Maps VPS IPs back to the hostname, critical for deliverability and spam prevention.

| IP Type | IP Address           | PTR / Hostname          |
| ------- | -------------------- | ----------------------- |
| IPv4    | 72.60.201.63         | mail.itsrighttime.group |
| IPv6    | 2a02:4780:12:8498::1 | mail.itsrighttime.group |

**How to set PTR:**

- Through Hostinger VPS control panel or support ticket
- Required for major providers (Gmail, Outlook) to avoid spam folder

**Verification:**

```bash
dig -x 72.60.201.63
dig -x 2a02:4780:12:8498::1
```

## 8. Summary Table of All DNS Records

| Record Type | Host                | Value / Points to                                          | Purpose                      |
| ----------- | ------------------- | ---------------------------------------------------------- | ---------------------------- |
| A           | mail                | 72.60.201.63                                               | Mail server IPv4             |
| AAAA        | mail                | 2a02:4780:12:8498::1                                       | Mail server IPv6             |
| MX          | @                   | mail.itsrighttime.group.                                   | Incoming mail routing        |
| TXT (SPF)   | @                   | v=spf1 a mx ip4:72.60.201.63 ip6:2a02:4780:12:8498::1 ~all | Sender authorization         |
| TXT (DKIM)  | default.\_domainkey | DKIM public key                                            | Outgoing mail authentication |
| TXT (DMARC) | \_dmarc             | v=DMARC1; p=none; ...                                      | Anti-spoofing / reporting    |

This completes the DNS configuration setup for a fully functional, self-hosted mail server.
