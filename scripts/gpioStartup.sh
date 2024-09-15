

echo "Install raspi-gpio"
sudo apt update
sudo apt -y install raspi-gpio 

echo "Mdify startup file rc.local"
sed -i '/exit/i\raspi-gpio set 4 op pn dl\nsleep 1\nraspi-gpio set 4 ip pn\n' /etc/rc.local 

#raspi-gpio set 4 op pn dl
#sleep 1
#raspi-gpio set 4 ip pn
