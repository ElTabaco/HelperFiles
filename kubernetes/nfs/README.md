# nfs file share

Build a own nfs file share.

_Everyone can contribute and commit solved bugs is welcome_

## create nfs server und prepare strage

* See nfs.sh

# manual mount and umount

* mount
```console
sudo mount -v -t nfs mr0:/srv/nfs4/homes Documents/destmount 
# or with ip
sudo mount -v -t nfs 192.168.X.X:/srv/nfs4/homes Documents/destmount 
```
* umount
```console
sudo umount -v -t nfs mr0:/srv/nfs4/homes Documents/test
```

To mount an NTFS SSD drive on startup and create an NTFS4 server in Ubuntu without using Samba, you can follow these steps. We'll use `ntfs-3g` for mounting the NTFS drive and `NFS` for sharing it across the network.

### Step 1: Install Required Packages

First, ensure that the required packages are installed.

```bash
sudo apt update
sudo apt install ntfs-3g nfs-kernel-server nfs-common
```

### Step 2: Identify the NTFS Drive

Identify the NTFS drive using the `lsblk` or `fdisk` command:

```bash
lsblk -f
```

Look for the NTFS partition, which will typically have a filesystem type of `ntfs`. Note its device name (e.g., `/dev/sdX1`).

### Step 3: Create a Mount Point

Create a directory where the NTFS partition will be mounted:

```bash
sudo mkdir -p /mnt/ntfs-drive
```

### Step 4: Mount the NTFS Drive

You can manually mount the NTFS drive to test:

```bash
sudo mount -t ntfs-3g /dev/sdX1 /mnt/ntfs-drive
```

### Step 5: Configure the Drive to Mount at Startup

Edit the `/etc/fstab` file to automatically mount the NTFS drive at startup:

```bash
sudo nano /etc/fstab
```

Add the following line at the end of the file:

```bash
/dev/sdX1 /mnt/ntfs-drive ntfs-3g defaults,auto,users,rw,umask=000 0 0
```

Replace `/dev/sdX1` with the actual device name of your NTFS partition.
Replace `/mnt/ntfs-drive` with the actual directory name to your NTFS partition.

Save and close the file.

### Step 6: Set Up an NFS Server

Now, configure the NFS server to share the mounted NTFS drive over the network.

Edit the NFS exports file:

```bash
sudo nano /etc/exports
```

Add the following line to export the directory:

```bash
/srv/nfs4/homes *(rw,async,no_subtree_check,no_root_squash,insecure,crossmnt)
# /srv/nfs4/public *(rw,async,all_squash,anonuid=0,anongid=0,insecure,no_subtree_check,crossmnt)
```

### Step 7: Restart NFS Server

Restart the NFS server to apply the changes and sync:

```bash
sudo exportfs -ar
sudo systemctl restart nfs-kernel-server.service
sudo exportfs -ar
sudo exportfs -v 
sudo systemctl status nfs-kernel-server.service
```

### Step 8: Test the NFS Share

You can now test the NFS share by mounting it on a client machine:

```bash
sudo mount -t nfs4 <server-ip>:/mnt/ntfs-drive /mnt/nfs-client
```

Replace `<server-ip>` with the IP address of your Ubuntu server.

### Step 9: Ensure NFS Starts at Boot

To ensure the NFS server starts at boot, enable the NFS service:

```bash
sudo systemctl enable nfs-kernel-server
```

### Conclusion

You've successfully mounted an NTFS SSD drive on startup in Ubuntu and created an NFS4 server to share it over the network without using Samba. The NTFS partition will automatically mount at boot, and the NFS server will be ready to serve the shared directory.