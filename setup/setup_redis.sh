#!/bin/bash
PASSWORD="osboxes.org"

echo "Starting corrected installation..."

# 1. KILL the background auto-updaters so they release the lock
echo "$PASSWORD" | sudo -S systemctl stop unattended-upgrades
echo "$PASSWORD" | sudo -S killall apt apt-get dpkg 2>/dev/null

# 2. Wait and force-clear the locks just in case
echo "$PASSWORD" | sudo -S rm /var/lib/dpkg/lock-frontend
echo "$PASSWORD" | sudo -S rm /var/lib/apt/lists/lock
echo "$PASSWORD" | sudo -S rm /var/cache/apt/archives/lock
echo "$PASSWORD" | sudo -S dpkg --configure -a

# 3. Now proceed with the installation
echo "$PASSWORD" | sudo -S apt-mark unhold redis-server

echo "$PASSWORD" | sudo -S apt-get update

echo "$PASSWORD" | sudo -S apt-get install -y \
    --allow-downgrades \
    --allow-change-held-packages \
    redis-server=5:5.0.7-2ubuntu0.1 \
    redis-tools=5:5.0.7-2ubuntu0.1

# 4. Lock the version
echo "$PASSWORD" | sudo -S apt-mark hold redis-server

# 5. Configuration
echo "Configuring Redis..."
echo "$PASSWORD" | sudo -S sed -i "s/bind 127.0.0.1 ::1/bind 0.0.0.0/" /etc/redis/redis.conf
echo "$PASSWORD" | sudo -S sed -i "s/protected-mode yes/protected-mode no/" /etc/redis/redis.conf

# 6. Restart
echo "$PASSWORD" | sudo -S systemctl restart redis-server

echo ""

echo "Redis setup complete."