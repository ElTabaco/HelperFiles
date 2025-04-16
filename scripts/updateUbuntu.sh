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

echo ">>> Cleaning apt cache..."
sudo apt -y -f autoremove  --purge
sudo apt -y -f clean
sudo apt -y -f autoclean
sudo apt -y -f autoremove 

echo ">>> Removing backup and leftover config files..."
sudo find /etc -name "*~" -type f -delete
sudo find /etc -name "*.bak" -type f -delete
sudo find /etc -name "*.dpkg-old" -type f -delete
sudo find /etc -name "*.dpkg-dist" -type f -delete

echo ">>> Truncating all log files..."
sudo find /var/log -type f -exec truncate -s 0 {} \;

echo ">>> Deleting user trash and backup files..."
rm -rf -v ~/.local/share/Trash/*
find ~ -type f -name "*~" -delete
find ~ -type f -name "*.bak" -delete

echo ">>> Clean-up done!"


echo ">>> Removing cache and logs..."
#sudo apt-get --purge remove $(dpkg --list | egrep -i 'linux-image|linux-headers' | awk '/ii/{ print $2}' | egrep -v "$i")
sudo rm -r -v /boot/firmware/*.bak
sudo rm -r -v /boot/firmware/overlays/*.bak
sudo rm -r -v /boot/*.old
sudo rm -fR -v /var/lib/apt/lists /tmp/* /var/tmp/*
sudo rm -rf -v /var/lib/snapd /snap /var/snap /var/log/* /var/cache/* ~/.cache/*


echo ">>> Removing old journal logs (if using systemd-journald)..."
sudo journalctl --vacuum-size=1M

echo ">>> Clean-up done!"

# echo "Configuration"
# sudo timedatectl set-timezone Europe/Berlin
# sudolocaledef -i en_US -f UTF-8 en_US.UTF-8

# Chang PW
# passwd
