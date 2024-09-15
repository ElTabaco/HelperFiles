echo "Full Upgrade"
sudo apt-get update
sudo apt-get -y -f install
sudo apt-get -y full-upgrade
sudo apt-get -y dist-upgrade

echo "Delete old kernel"
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