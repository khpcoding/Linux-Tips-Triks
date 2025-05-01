# Linux Server Hardening with iptables  

This guide provides a comprehensive set of `iptables` rules to harden a Linux server. These rules are designed to enhance security by restricting unnecessary access, preventing common attacks, and ensuring only authorized traffic is allowed.  

---

## **Table of Contents**  
1. [Basic Security Policies](#basic-security-policies)  
2. [Allow Essential Services](#allow-essential-services)  
3. [Block Common Attacks](#block-common-attacks)  
4. [Rate Limiting & Anti-DDoS](#rate-limiting--anti-ddos)  
5. [Logging & Monitoring](#logging--monitoring)  
6. [Saving & Applying Rules](#saving--applying-rules)  

---

## **1. Basic Security Policies**  
These rules set a secure default policy, allowing only explicitly permitted traffic.  

```bash
# Flush existing rules (start fresh)
iptables -F
iptables -X

# Set default policies (DROP all incoming, allow outgoing)
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow localhost traffic (loopback interface)
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established/related connections (for ongoing sessions)
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
```

**Explanation:**  
- **Default DROP policy**: Blocks all incoming traffic unless explicitly allowed.  
- **Allow loopback (`lo`)**: Required for local services.  
- **Allow ESTABLISHED/RELATED**: Ensures responses to outgoing connections are permitted.  

---

## **2. Allow Essential Services**  
These rules permit necessary services (SSH, HTTP/HTTPS, DNS, ICMP).  

### **SSH (Port 22) - Secure Access**  
```bash
# Allow SSH (adjust port if using a non-default one)
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT

# Optionally, restrict SSH to a specific IP (replace 1.2.3.4)
iptables -A INPUT -p tcp --dport 22 -s 1.2.3.4 -j ACCEPT
```

### **Web Traffic (HTTP/HTTPS) - Ports 80 & 443**  
```bash
iptables -A INPUT -p tcp --dport 80 -j ACCEPT   # HTTP
iptables -A INPUT -p tcp --dport 443 -j ACCEPT  # HTTPS
```

### **DNS (Port 53) - For Servers Running DNS**  
```bash
iptables -A INPUT -p udp --dport 53 -j ACCEPT  # UDP DNS
iptables -A INPUT -p tcp --dport 53 -j ACCEPT  # TCP DNS (for large queries)
```

### **ICMP (Ping) - Limited Allowance**  
```bash
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/second -j ACCEPT
iptables -A INPUT -p icmp -j DROP  # Drop all other ICMP traffic
```

**Explanation:**  
- **SSH restricted**: Only allows new SSH connections (optionally from a specific IP).  
- **Web traffic allowed**: For serving websites.  
- **DNS permitted**: If running a DNS server.  
- **ICMP rate-limited**: Prevents ping floods while allowing basic diagnostics.  

---

## **3. Block Common Attacks**  
These rules mitigate brute-force attacks, port scanning, and malicious traffic.  

### **Block Null Packets (Common in Scans)**  
```bash
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
```

### **Block SYN-Flood Attacks**  
```bash
iptables -A INPUT -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
iptables -A INPUT -p tcp --syn -m connlimit --connlimit-above 30 -j DROP
```

### **Block Common Exploit Attempts**  
```bash
iptables -A INPUT -p tcp --dport 80 -m string --string "cmd.exe" --algo bm -j DROP
iptables -A INPUT -p tcp --dport 80 -m string --string "/etc/passwd" --algo bm -j DROP
```

### **Drop Invalid Packets**  
```bash
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
```

**Explanation:**  
- **Null packets**: Often used in scans—drop them.  
- **SYN-flood protection**: Prevents DoS attacks.  
- **Exploit blocking**: Stops common web attack patterns.  
- **Invalid packets**: Drops malformed traffic.  

---

## **4. Rate Limiting & Anti-DDoS**  
Prevents brute-force attacks and excessive connections.  

### **SSH Rate Limiting**  
```bash
iptables -A INPUT -p tcp --dport 22 -m recent --name ssh --set
iptables -A INPUT -p tcp --dport 22 -m recent --name ssh --update --seconds 60 --hitcount 5 -j DROP
```

### **General Connection Throttling**  
```bash
iptables -A INPUT -p tcp --syn -m limit --limit 10/s --limit-burst 20 -j ACCEPT
iptables -A INPUT -p tcp --syn -j DROP
```

**Explanation:**  
- **SSH rate limit**: Allows 5 attempts per minute, then blocks.  
- **General SYN limit**: Prevents connection flooding.  

---

## **5. Logging & Monitoring**  
Logs suspicious activity for later analysis.  

```bash
# Log dropped packets (for debugging)
iptables -N LOGGING
iptables -A INPUT -j LOGGING
iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables-Dropped: " --log-level 4
iptables -A LOGGING -j DROP
```

**Explanation:**  
- Logs dropped packets at a controlled rate (`2/min` to avoid log spam).  
- Logs appear in `/var/log/syslog` or `/var/log/messages`.  

---

## **6. Saving & Applying Rules**  

### **For Debian/Ubuntu**  
```bash
iptables-save > /etc/iptables/rules.v4
```

### **For CentOS/RHEL**  
```bash
service iptables save
systemctl restart iptables
```

### **Persistent Rules (After Reboot)**  
```bash
apt install iptables-persistent  # Debian/Ubuntu
dnf install iptables-services    # CentOS/RHEL
```

---

## **Final Notes**  
✅ **Test rules before applying** (use `iptables-apply` or a second SSH session).  
✅ **Adjust IPs/ports** as needed for your environment.  
✅ **Monitor logs** (`tail -f /var/log/syslog | grep IPTables`).  

This setup provides a **strong security baseline** while allowing essential services. Modify as needed for your specific use case.  

🔐 **For maximum security**, consider combining with:  
- **Fail2Ban** (automated blocking of brute-force attacks)  
- **Cloudflare/WAF** (for web-facing servers)  
- **Port knocking** (for hidden SSH access)  

🚀 **Stay secure!** 🚀
