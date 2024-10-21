# Variables
IFACE1="ens5"  # NIC connected to "Consoles" subnet"
IFACE2="ens6"  # NIC connected to "envA" subnet


# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Set default policies to drop traffic
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Allow traffic on the loopback interface
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow incoming traffic on both interfaces
iptables -A INPUT -i $IFACE1 -j ACCEPT
iptables -A INPUT -i $IFACE2 -j ACCEPT

# Allow forwarding between iface1 and iface2
iptables -A FORWARD -i $IFACE1 -o $IFACE2 -j ACCEPT
iptables -A FORWARD -i $IFACE2 -o $IFACE1 -j ACCEPT

# Drop invalid packets
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A FORWARD -m state --state INVALID -j DROP

# Allow established and related connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow ICMP
iptables -A INPUT -p icmp -j ACCEPT
iptables -A FORWARD -p icmp -j ACCEPT

# Log dropped packets (learner can confirm their actions have worked)
iptables -A INPUT -j LOG --log-prefix "INPUT DROP: " --log-level 4
iptables -A FORWARD -j LOG --log-prefix "FORWARD DROP: " --log-level 4

# Save the rules to persist across reboots 
iptables-save > /etc/iptables/rules.v4