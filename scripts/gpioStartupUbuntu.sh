#!/bin/bash
set -e

echo "Setting up early GPIO pin 4 configuration and startup service..."

# 1. Make sure raspi-gpio is installed
sudo apt-get update
sudo apt-get install -y gpiod

# 2. Create the startup script
echo "Creating GPIO startup script..."
sudo tee /usr/local/bin/gpio-startup.sh > /dev/null << 'EOF'
#!/bin/bash
set -euo pipefail

# GPIO4 is line offset 4 on /dev/gpiochip0 (on Raspberry Pi)
CHIP="/dev/gpiochip0"
LINE=4

# Step 1: set GPIO4 as output low (hold low for 1s)
if gpioset --help 2>&1 | grep -q -- '--sec'; then
  # libgpiod >= v2.x
  gpioset --mode=time --sec=1 "$CHIP" "$LINE=0"
else
  # libgpiod 1.x
  gpioset -m time -s 1 "$CHIP" "$LINE=0"
fi

# Step 2: release the line (goes back to input)
# Explicitly request as input with bias=disable (no pull) if supported
if gpioget --help 2>&1 | grep -q -- '--bias'; then

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
