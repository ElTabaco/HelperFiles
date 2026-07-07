

#Network speed test
# server
iperf -s
# client
iperf -c 192.168.0.XX

# Speedtest from Client 
dd if=/dev/zero of=Downloads/test.iso bs=1G count=8 