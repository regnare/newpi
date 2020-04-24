iptables -F

# Input table
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
iptables -A INPUT -i lo -j ACCEPT

# Drop broadcast spam
iptables -A INPUT -m addrtype --dst-type BROADCAST -j DROP
iptables -A INPUT -p udp --dport 5353 -m addrtype --dst-type MULTICAST -j ACCEPT

# Log and allow pings
iptables -A INPUT -p icmp --icmp-type echo-request -j LOG --log-prefix "ALLOW PING: " --log-level info
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Log and allow ssh
iptables -A INPUT -p tcp --dport 22 -j LOG --log-level info --log-prefix "SSH: "
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Log default DROP
iptables -A INPUT -j LOG --log-level info --log-prefix "DROP: "

# Set default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
