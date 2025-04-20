#!/bin/bash
echo "Disable Powersave"
sudo systemctl stop sleep.target suspend.target hibernate.target hybrid-sleep.target
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

echo "Mask not needed Services"
sudo systemctl stop syslog.socket
sudo systemctl disable syslog.socket
sudo systemctl stop rsyslog.service
sudo systemctl disable rsyslog.service

sudo systemctl stop systemd-journald-dev-log.socket systemd-journald.socket systemd-journald-audit.socket systemd-journal-flush.service systemd-logind.socket
sudo systemctl disable systemd-journald-dev-log.socket systemd-journald.socket systemd-journald-audit.socket systemd-journal-flush.service systemd-logind.socket

sudo systemctl disable systemd-fsck-root.service
sudo systemctl disable systemd-logind.service

sudo systemctl stop systemd-journald.service
sudo systemctl disable systemd-journald.service

echo "Remove not needed Services"
sudo apt-get -y purge --auto-remove cryptsetup* avahi-daemon 
sudo apt-get -y purge --auto-remove curl
sudo apt-get -y purge --auto-remove triggerhappy dphys-swapfile
sudo apt-get -y purge --auto-remove raspi-config
sudo apt-get -y purge --auto-remove firmware-nvidia-graphics

sudo apt-get -y purge --auto-remove keyboard-configuration 

sudo apt-get -y purge --auto-remove cryptsetup*
sudo apt-get -y purge --auto-remove sysstat

sudo service --status-all

#sudo apt-get -y purge --auto-remove systemd-journal-remote
#sudo apt-get remove -y --purge 'python*'

