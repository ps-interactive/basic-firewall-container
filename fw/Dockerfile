FROM debian:latest

# Install system dependencies
RUN apt update && apt install -y \
    iptables iptables-persistent \
    apache2 php libapache2-mod-php \
    python3 python3-pip python3-venv \
    openssh-server rsyslog \
    && rm -rf /var/lib/apt/lists/*

# Create SSH directory and set permissions
RUN mkdir /var/run/sshd && echo 'root:firewall123' | chpasswd

# Enable root SSH login and password authentication (not recommended for production)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Create a virtual environment for Python and install packages
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"
RUN pip install --no-cache-dir flask flask-cors flask-login flask-bcrypt

# Expose necessary ports
EXPOSE 22 80 5000

# Copy firewall rules script, web UI, and API files
COPY firewall-rules.sh /firewall-rules.sh
COPY firewall_api.py /firewall_api.py
COPY web-interface.html /var/www/html

# Start SSH, rsyslog, restore iptables, and run the firewall API + Apache
CMD ["bash", "-c", "service ssh start && service rsyslog start && iptables-restore < /etc/iptables/rules.v4 && python3 /firewall_api.py & apachectl -D FOREGROUND"]
