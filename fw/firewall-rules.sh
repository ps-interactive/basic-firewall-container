#!/bin/bash

# Enable IP forwarding
echo "1" > /proc/sys/net/ipv4/ip_forward

# Flush existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t mangle -F

# Set default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established and related connections
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Log dropped packets
iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "IPTABLES-DROP: " --log-level 4
iptables -A FORWARD -m limit --limit 5/min -j LOG --log-prefix "IPTABLES-FORWARD-DROP: " --log-level 4

# Save rules for persistence
iptables-save > /etc/iptables/rules.v4