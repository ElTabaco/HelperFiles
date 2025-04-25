#!/bin/bash
set -e

echo "Setting up early GPIO pin 4 configuration and startup service..."

# 1. Make sure raspi-gpio is installed
sudo apt-get update
sudo apt-get install -y raspi-gpio

# 2. Create the startup script
echo "Creating GPIO startup script..."
sudo tee /usr/local/bin/gpio-startup.sh > /dev/null << 'EOF'
#!/bin/bash
raspi-gpio set 4 op pn dl
sleep 1
raspi-gpio set 4 ip pn
EOF

# 3. Make it executable
sudo chmod +x /usr/local/bin/gpio-startup.sh

# 4. Create the systemd service
echo "Creating systemd service..."
sudo tee /etc/systemd/system/gpio-startup.service > /dev/null << 'EOF'
[Unit]
Description=Run GPIO startup commands
DefaultDependencies=no
After=basic.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/gpio-startup.sh
RemainAfterExit=true

[Install]
WantedBy=basic.target
EOF

# 6. Reload systemd and enable service
sudo systemctl daemon-reexec
sudo systemctl enable gpio-startup.service

echo "Done! GPIO 4 will be set by systemd."
