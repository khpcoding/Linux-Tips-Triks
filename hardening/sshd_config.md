Here's the `sshd_config` file converted to a README.md format with a step-by-step explanation of how the configuration works:

```markdown
# SSH Server (sshd) Configuration Guide

This document explains the security-focused SSH server configuration file (`sshd_config`).

## Table of Contents
1. [Basic Security Settings](#basic-security-settings)
2. [Authentication Configuration](#authentication-configuration)
3. [Connection Settings](#connection-settings)
4. [Network Security](#network-security)
5. [Subsystem Configuration](#subsystem-configuration)

## Basic Security Settings

```config
DisableForwarding yes
GSSAPIAuthentication no
PermitRootLogin no
LogLevel INFO
```

- **DisableForwarding yes**: Disables all TCP, X11, and agent forwarding, preventing port forwarding tunnels
- **GSSAPIAuthentication no**: Disables GSSAPI authentication (Kerberos)
- **PermitRootLogin no**: Blocks direct root login (users must first login as regular user then use sudo)
- **LogLevel INFO**: Provides detailed logging of SSH connections

## Authentication Configuration

```config
LoginGraceTime 0m
MaxAuthTries 8
MaxSessions 8
allowgroups sudo
AllowUsers user1 user2
AuthorizedKeysFile .ssh/authorized_keys
ClientAliveInterval 15
ClientAliveCountMax 3
UseDNS no
MaxStartups 10:30:60
```

- **LoginGraceTime 0m**: Immediately disconnects if login isn't completed (no grace period)
- **MaxAuthTries 8**: Allows 8 authentication attempts per connection
- **MaxSessions 8**: Limits to 8 simultaneous sessions per network connection
- **allowgroups sudo**: Only allows users in the 'sudo' group to login
- **AllowUsers user1 user2**: Whitelists only these two users for SSH access
- **AuthorizedKeysFile**: Looks for authorized keys in standard location
- **ClientAlive***: Checks connection every 15 seconds, drops after 3 failed checks (45s timeout)
- **UseDNS no**: Skips DNS reverse lookups (faster logins, prevents DNS-related issues)
- **MaxStartups**: Connection rate limiting (10 initial, 30% drop probability when reaching 60 connections)

## Connection Settings

```config
#Port 22
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::
```

(Note: These are commented out, using default values)
- Default port 22
- Listens on all interfaces (IPv4 and IPv6)

## Network Security

```config
# AllowAgentForwarding yes
# AllowTcpForwarding yes
# GatewayPorts no
# X11Forwarding no
```

(Note: Forwarding is disabled via `DisableForwarding yes` override)
- All forwarding (agent, TCP, X11) is disabled by the global setting

## Subsystem Configuration

```config
Subsystem sftp /usr/libexec/openssh/sftp-server
```

- Enables SFTP subsystem with default implementation

## Security Summary

This configuration implements:
1. Strict user access controls (whitelisting)
2. Disabled root login
3. Disabled all forwarding
4. Connection timeouts and limits
5. Reduced attack surface (disabled GSSAPI, DNS lookups)
6. Rate limiting against brute force attacks

To apply changes after modifying this file:
```bash
sudo systemctl restart sshd
```

Note: Always test new SSH configurations in a parallel session to avoid locking yourself out.
```

## Key Security Features Explained:

1. **User Restrictions**:
   - Only users "user1" and "user2" in the "sudo" group can login
   - Complete blocking of root login

2. **Network Hardening**:
   - All port forwarding disabled (prevents tunneling)
   - No X11 forwarding (graphical interface over SSH)
   - No DNS lookups (prevents potential delays and leaks)

3. **Brute Force Protection**:
   - Limited authentication attempts
   - Connection rate limiting
   - Immediate disconnection for failed logins

4. **Session Controls**:
   - Limits on simultaneous sessions
   - Active connection monitoring
   - Detailed logging

The configuration takes a restrictive approach, only enabling essential features while explicitly disabling many optional capabilities that could present security risks.
