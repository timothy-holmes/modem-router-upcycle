# replace conf files
scp ./local_network root@192.168.1.1:/etc/config/network
scp ./local_dhcp root@192.168.1.1:/etc/config/dhcp
scp ./local_wireless root@192.168.1.1:/etc/config/wireless
scp ./disable_services.sh root@192.168.1.1:/usr/bin/disable.sh

# disable unnecessary services
ssh root@10.1.1.1 "sh /usr/bin/disable.sh"

# fingers crossed
ssh root@10.1.1.1 "/etc/init.d/network restart && /etc/init.d/dhcp restart"
echo "Sleeping 60 seconds"
sleep 60