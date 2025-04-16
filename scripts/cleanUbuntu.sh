#!/bin/bash
echo "Disable Powersave"
sudo systemctl stop sleep.target suspend.target hibernate.target hybrid-sleep.target
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

echo "Mask not needed Services"
sudo systemctl stop syslog.socket
sudo systemctl disable syslog.socket

sudo systemctl stop systemd-journald-dev-log.socket
sudo systemctl stop systemd-journald.socket
sudo systemctl stop systemd-journald-audit.socket
sudo systemctl stop systemd-journal-flush.service

sudo systemctl disable systemd-journald-dev-log.socket
sudo systemctl disable systemd-journald.socket
sudo systemctl disable systemd-journald-audit.socket
sudo systemctl disable systemd-journal-flush.service

sudo systemctl disable systemd-fsck-root.service
sudo systemctl disable systemd-logind.service

sudo systemctl stop systemd-journald.service
sudo systemctl disable systemd-journald.service

echo "Change runlevel"
# https://www.systutorials.com/change-systemd-boot-target-linux/
# https://www.tecmint.com/change-runlevels-targets-in-systemd/
# sudo systemctl isolate multi-user.target
sudo systemctl enable multi-user.target
sudo systemctl set-default multi-user.target

echo "Remove not needed Services"
#sudo apt-get -y purge --auto-remove xubuntu-deskto*
sudo apt-get -y purge --auto-remove cloud*
sudo apt-get -y purge --auto-remove snapd plymouth
sudo apt-get -y purge --auto-remove cryptsetup* avahi-daemon 
sudo apt-get -y purge --auto-remove appor* ufw
sudo apt-get -y purge --auto-remove open-vm-tools open-iscsi
sudo apt-get -y purge --auto-remove pollinate
sudo apt-get -y purge --auto-remove ubuntu-advantage-tools
sudo apt-get -y purge --auto-remove cloud-init
#sudo apt-get -y purge --auto-remove \
#    lxd* \
#    landscape-common \
#    unattended-upgrades \
#    cups* \
#    rpcbind \
#    samba* \
#    modemmanager \
#    plymouth \
#    bolt \
#    bluez* \
#    wpasupplicant \
#    ubuntu-server-minimal \
#    ubuntu-server

sudo service --status-all

#sudo apt-get -y purge --auto-remove systemd-journal-remote
#sudo apt-get remove -y --purge 'python*'

#sudo apt-get -y autopurge ubuntu-advantage-tools
sudo apt -y -f autoremove
sudo apt -y -f autoclean
