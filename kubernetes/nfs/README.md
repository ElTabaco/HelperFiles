# nfs file share

Build a own nfs file share.

_Everyone can contribute and commit solved bugs is welcome_

## create nfs server und prepare strage

* See nfs.sh

## Monthly backup (mr0)

`backup.timer` runs `backup.service` (`/usr/local/bin/backup.sh`) monthly. Every application gets its own backup,
and the newest 6 backups of each application are kept.

| Setting | Value |
|---------|-------|
| Timer | `OnCalendar=monthly` (1st of the month, 00:00), `Persistent=true` (a missed run starts at the next boot) |
| Service | `backup.service`, `Type=oneshot`, runs as root |
| `SOURCE_DIR` | `/srv/nfs4/homes/mr` — every directory directly below it is one application (currently `jellyfin`, `media`, `mqtt`, `observer`, `openhab`, `teddycloud`). A new application directory is backed up automatically. Files and symlinks directly in `SOURCE_DIR` are not backed up (logged as `Skipped`); hidden directories (`.name`) are ignored. |
| `BACKUP_DIR` | `/home/mr/backup` — one sub directory per application: `/home/mr/backup/<application>/` |
| File name | `<application>-YYYY-MM-DD.tar.gz` (tar + gzip), e.g. `/home/mr/backup/openhab/openhab-2026-12-01.tar.gz`; written as `<application>-YYYY-MM-DD.tar.gz.part` and renamed when tar succeeds. A second run on the same day replaces the file of that day. |
| Paths in the archive | relative, starting with `<application>/` (e.g. `openhab/openhab/conf/...`) |
| `EXCLUDES` | `teddycloud:library` — space separated list of `<application>:<path below the application directory>` (no spaces in the path). The content of such a directory is not backed up; the empty directory itself stays in the archive. `teddycloud/library` is the audio library (several GB). `EXCLUDES=""` disables all excludes. |
| `KEEP` | `6` — per application: after a successful backup of an application, its oldest `<application>-YYYY-MM-DD.tar.gz` files beyond the newest 6 are deleted. Other files in `BACKUP_DIR` are never touched. |
| `LOG_FILE` | `/var/log/backup.log` (one line per application backup, failure, skipped entry and deleted backup) |

* The applications are independent: if tar fails for one application (exit code > 1), its `.part` file is removed, none of its backups are deleted, the other applications are still backed up and the service exits with code 1. Tar exit code 1 (files changed while being read) is accepted.
* If `SOURCE_DIR` is missing or contains no directory, nothing is done and the service exits with code 1.
* `KEEP` must be a number >= 1; otherwise the backups are created, nothing is deleted and the service exits with code 1.
* All variables can be overridden from the environment for a test run, e.g. `SOURCE_DIR=/tmp/src BACKUP_DIR=/tmp/bk LOG_FILE=/tmp/log KEEP=2 EXCLUDES="app:cache" /usr/local/bin/backup.sh`.

Restore one application (stop the application first; the excluded `teddycloud/library` content is not in the backup and stays as it is on disk):

```console
# list
tar -tzf /home/mr/backup/openhab/openhab-YYYY-MM-DD.tar.gz
# restore into the share
sudo tar -xzf /home/mr/backup/openhab/openhab-YYYY-MM-DD.tar.gz -C /srv/nfs4/homes/mr
```

Install or update:

```console
cd kubernetes/nfs && ./filecopy.sh
sudo systemctl daemon-reload
sudo systemctl enable --now backup.timer
systemctl list-timers backup.timer
# manual run
sudo systemctl start backup.service
tail /var/log/backup.log
```

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