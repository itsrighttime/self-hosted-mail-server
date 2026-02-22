# 06 - OpenDKIM Configuration

This document explains how to configure **OpenDKIM** for signing outgoing emails and verifying authenticity with **DKIM, SPF, and DMARC** records.

## 1. Install OpenDKIM

```bash
sudo apt install opendkim opendkim-tools -y
```

Enable the service:

```bash
sudo systemctl enable opendkim
sudo systemctl start opendkim
sudo systemctl status opendkim
```

## 2. Create DKIM Keys

```bash
sudo mkdir -p /etc/opendkim/keys/itsrighttime.group
cd /etc/opendkim/keys/itsrighttime.group
sudo opendkim-genkey -t -s default -d itsrighttime.group
sudo chown opendkim:opendkim default.private
sudo chmod 600 default.private
```

**Files generated:**

- `default.private` → private key used by OpenDKIM
- `default.txt` → public key for DNS TXT record

## 3. OpenDKIM Configuration Files

### 3.1 Main Configuration – `/etc/opendkim.conf`

```conf
UserID                 opendkim:opendkim
KeyTable               /etc/opendkim/KeyTable
SigningTable           /etc/opendkim/SigningTable
TrustedHosts           /etc/opendkim/TrustedHosts
Canonicalization       relaxed/simple
Mode                   sv
Socket                 inet:12345@localhost
```

### 3.2 KeyTable – `/etc/opendkim/KeyTable`

```conf
default._domainkey.itsrighttime.group itsrighttime.group:default:/etc/opendkim/keys/itsrighttime.group/default.private
```

### 3.3 SigningTable – `/etc/opendkim/SigningTable`

```conf
*@itsrighttime.group default._domainkey.itsrighttime.group
```

### 3.4 TrustedHosts – `/etc/opendkim/TrustedHosts`

```conf
127.0.0.1
::1
localhost
```

### 3.5 Startup Configuration – `/etc/default/opendkim`

```conf
SOCKET="inet:12345@localhost"
```

## 4. Integrate OpenDKIM with Postfix

Edit Postfix main configuration:

```bash
sudo postconf -e "smtpd_milters=inet:localhost:12345"
sudo postconf -e "non_smtpd_milters=inet:localhost:12345"
sudo systemctl restart postfix
sudo systemctl restart opendkim
```

**Verify:**

```bash
sudo systemctl status opendkim
postconf | grep smtpd_milters
```

## 5. DNS Records for Email Authentication

To ensure mail deliverability and reduce spam classification:

### 5.1 SPF Record (TXT)

```conf
v=spf1 a mx ip4:72.60.201.63 ip6:2a02:4780:12:8498::1 ~all
```

### 5.2 DKIM Record (TXT)

- Host: `default._domainkey`
- Value: Copy from `default.txt` generated in Step 2, convert to **single line**:

```conf
v=DKIM1; h=sha256; k=rsa; p=MIIBIjANBgkqhkiG...IDAQAB
```

### 5.3 DMARC Record (TXT)

```conf
v=DMARC1; p=none; rua=mailto:admin@itsrighttime.group; ruf=mailto:admin@itsrighttime.group; sp=none; aspf=s; adkim=s
```

### 5.4 MX Record

- Host: `@`
- Mail server: `mail.itsrighttime.group`
- Priority: `10`

### 5.5 A / AAAA Records

- A → `mail.itsrighttime.group` → `72.60.201.63`
- AAAA → `mail.itsrighttime.group` → `2a02:4780:12:8498::1`

## 6. Verify OpenDKIM Setup

### 6.1 Service Status

```bash
sudo systemctl status opendkim
```

### 6.2 Check DKIM Key Propagation

```bash
dig TXT default._domainkey.itsrighttime.group +short
```

Expected: DKIM public key string appears.

### 6.3 Send Test Email

```bash
sendmail -v check-auth@verifier.port25.com
From: admin@itsrighttime.group
To: check-auth@verifier.port25.com
Subject: DKIM/SPF/DMARC Test

This is a test email from Postfix + OpenDKIM.
.
```

**Check:** SPF, DKIM, and DMARC results in verifier report.

## 7. Troubleshooting

- Ensure correct permissions for `/etc/opendkim/keys/*`
- Check OpenDKIM logs:

```bash
sudo tail -f /var/log/mail.log
sudo journalctl -xe | grep opendkim
```

- Verify Postfix and OpenDKIM integration using:

```bash
postconf -n | grep milter
```

## 8. Summary

- OpenDKIM installed and configured with **selector `default`**
- Postfix integrated with OpenDKIM via milter socket
- SPF, DKIM, DMARC DNS records added for email authentication
- Verified DKIM propagation and mail deliverability
- Ready for secure production mail sending

This completes the **OpenDKIM and email authentication setup**, ensuring outgoing emails are properly signed and trusted by recipient servers.
