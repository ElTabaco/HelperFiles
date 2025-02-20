# https://ubuntu.com/server/docs/service-nfs
# https://wiki.ubuntuusers.de/NFSv4/

sudo fdisk -l
lsblk
# sudo mount -t ntfs-3g /dev/sdb1 /srv/nfs4
# Create new ntfs drive
#sudo mkfs -t ntfs /dev/sdb1
sudo mkfs.ntfs -f /dev/sdb1

# Install server
sudo apt-get update
sudo apt install -y ntfs-3g nfs-kernel-server nfs-common


# Automount driver like USB sticks
# https://developerinsider.co/auto-mount-drive-in-ubuntu-server-22-04-at-startup/

lsblk -o NAME,FSTYPE,UUID,MOUNTPOINTS
#sudo nano /etc/fstab

#UUID=48FD7DB92917E700 /media/ntfs ntfs3 defaults 0 0
#/media/ntfs  /srv/nfs4/public none  bind  0 0
sudo systemctl daemon-reload

# Create and link share folder
sudo mkdir /srv/nfs4 
sudo chmod -R -v 777 /srv/nfs4
sudo chown -R nobody:nogroup /srv/nfs4

sudo mount -t ntfs3 UUID=48FD7DB92917E700 /srv/nfs4
findmnt --verify /srv/nfs4

#sudo mount --bind /media/ntfs /srv/nfs4


sudo mkdir /srv/nfs4/public
sudo mkdir /srv/nfs4/homes
sudo chmod -R 777 /srv/nfs4
sudo chown -R nobody:nogroup /srv/nfs4
ls -l /srv/nfs4/

