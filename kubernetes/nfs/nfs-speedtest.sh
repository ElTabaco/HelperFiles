

#Network speed test
# server
iperf -s
# client
iperf -c 198.168.0.XX

# Speedtest from Client 
dd if=/dev/zero of=Downloads/test.iso bs=1G count=8 