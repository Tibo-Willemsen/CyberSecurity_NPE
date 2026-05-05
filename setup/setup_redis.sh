#!/bin/bash
PASSWORD="osboxes.org"

# Begin aan de installatie
echo "Losmaken van de redis-server"
echo "$PASSWORD" | sudo -S apt-mark unhold redis-server

echo "Update de packages"
echo "$PASSWORD" | sudo -S apt-get update

echo "Beginnen met de redis installatie"
echo "$PASSWORD" | sudo -S apt-get install -y \
    --allow-downgrades \
    --allow-change-held-packages \
    redis-server=5:5.0.7-2 \
    redis-tools=5:5.0.7-2

echo "Vastzetten van de versie"
# Vastzetten van de versie
echo "$PASSWORD" | sudo -S apt-mark hold redis-server

# Configuratie
echo "Redis configureren"
echo "$PASSWORD" | sudo -S sed -i "s/bind 127.0.0.1 ::1/bind 0.0.0.0/" /etc/redis/redis.conf
echo "$PASSWORD" | sudo -S sed -i "s/protected-mode yes/protected-mode no/" /etc/redis/redis.conf

echo "Redis herstarten"
# Herstarten
echo "$PASSWORD" | sudo -S systemctl restart redis-server

echo ""

echo "Redis setup complete."