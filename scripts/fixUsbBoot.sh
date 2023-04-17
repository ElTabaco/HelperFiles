#!/bin/bash

echo "Fix noot boot7ing USB 3.0 device"
// https://forums.raspberrypi.com/viewtopic.php?t=285806 


lsusb && lsusb -t

Bus 001 Device 003: ID 152d:0578 JMicron Technology Corp. / JMicron USA Technology Corp. JMS567 SATA 6Gb/s bridge
/boot/cmdline.txt:
usb-storage.quirks=152d:0578:u ...
usb-storage.quirks=1058:2642:u

echo "Chekck read speed"
sudo hdparm -tT /dev/sda
sudo hdparm -tT --direct /dev/sda