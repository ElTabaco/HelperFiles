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

sudo systemctl disable accounts-daemon.service

echo "Change runlevel"
# https://www.systutorials.com/change-systemd-boot-target-linux/
# https://www.tecmint.com/change-runlevels-targets-in-systemd/
# sudo systemctl isolate multi-user.target
sudo systemctl enable multi-user.target
sudo systemctl set-default multi-user.target

echo "Remove not needed Services"
sudo apt-get -y purge --auto-remove cloud* snapd plymouth
sudo apt-get -y purge --auto-remove cryptsetup* avahi-daemon 
sudo apt-get -y purge --auto-remove curl
sudo apt-get -y purge --auto-remove open-vm-tools open-iscsi
sudo apt-get -y purge --auto-remove pollinate
sudo apt-get -y purge --auto-remove ubuntu-advantage-tools
sudo service --status-all

#sudo apt-get -y purge --auto-remove systemd-journal-remote
#sudo apt-get remove -y --purge 'python*'

#sudo apt-get -y autopurge ubuntu-advantage-tools
sudo apt -y -f autoremove

echo "Full Upgrade"
sudo apt-get update
sudo apt-get -y -f install
sudo apt-get -y full-upgrade
sudo apt-get -y dist-upgrade

echo "Delet old kernel"
#sudo dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs sudo apt-get -y purge
dpkg --list | grep -i -E --color 'linux-image|linux-kernel' | grep '^ii'
dpkg --list | egrep -i --color 'linux-image|linux-headers' | grep '^ii' | wc -l
sudo apt-get --purge remove $(dpkg --list | egrep -i 'linux-image|linux-headers' | awk '/ii/{ print $2}' | egrep -v "$i")

sudo apt -y -f autoremove --purge
sudo apt -y -f autoremove 
sudo apt autoclean
#sudo apt-get --purge remove $(dpkg --list | egrep -i 'linux-image|linux-headers' | awk '/ii/{ print $2}' | egrep -v "$i")
sudo rm -r -v /boot/firmware/*.bak
sudo rm -r -v /boot/firmware/overlays/*.bak
sudo rm -r -v /boot/*.old
sudo rm -fR -v /var/lib/apt/lists
sudo rm -fR -v /var/lib/apt/lists /tmp/* /var/tmp/* ~/.cache

sudo journalctl --vacuum-size=5M

echo "Configuration"
# sudo timedatectl set-timezone Europe/Berlin
# sudolocaledef -i en_US -f UTF-8 en_US.UTF-8

# Chang PW
# passwd

echo "Snapcast"
# echo "deb http://ftp.de.debian.org/debian bullseye-backports main" | sudo tee /etc/apt/sources.list.d/snapcast.list > /dev/null


#https://askubuntu.com/questions/34074/how-do-i-change-my-username
#sudo adduser temporary
#sudo adduser temporary sudo

#sudo usermod -l egg ubuntu
#sudo usermod -d /home/egg -m egg