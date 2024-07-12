# Technicolor TG789 V2

iiNet gave me a modem-router when I signed up for 18 months in 2018. This particular device has been added to the pile of ISP-supplied modem-routers since moving house a few times, new ISPs contracts, and upgrading to pfSense. Rather than let it become e-waste, I've transformed it into a useful member of society (my network).

What I'm documenting here is for the near futurewhen I need to do a factory reset.

## Problem/Goal

The Technicolor TG789 V2 has a single core processor, 32 MB of falsh memory and 64 MB of RAM. By todays standards, it is an edge device. I'm waiting for a mini PC to arrive to serve as a home server. In the meantime, the TG789 can do some of things now, and provide failover in the future.

- I want a device to perform IoT data ETL tasks on a schedule. It's the new tax year and I want to collect data from the power meters. Also, track the solar power generation/grid power consumption, monitor the temperature at sensors around the house.
- I coud use an extra switch while I'm getting the rest of the network setup.
- I'm going to be setting up a local DNS server. I don't want the mini PC to be a single source of failure since I'm going to be tinkering with it constantly. I'm of two minds whether TG789 should handle anything, or simply alert me if DNS is down. 

## Transforming TG789

## 0. Factory Reset

Clone this repo. Disconnect the devices (host and TG789) from the internet. Connect a host with the ability to set a static IP (requires admin creds) via ethernet to TG789 WAN port.

## 1. Gain route access

This router of the pile of routers was the most readily hacked to gain root access. I used the extensive listing at [hack-techniclor](https://github.com/hack-technicolor/hack-technicolor/) to discover this firmware version is hacked with [tch-exploit](https://github.com/BoLaMN/tch-exploit). A copy of the tool is include in this repo. Run the tch-exploit tool and follow the instructions to get root access over ssh.

## 2. Relieve TG789 of router duties (reconfigure interfaces, dhcp, dnsmasq and firewall)

DHCP duties are assigned to the main router, so this is a DHCP client now. DNS duties also removed. The firewall should be disabled to be able to use this as a switch. This is achieved by replacing the config files for dhcp, network and dnsmasq, restarting the services and disabling the firewall.

Tweak any of the repo config files and run script in repo on local machine - `./script/local.sh`:

```sh
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
```

## 3. Install the other things (service checks, data ETL)

The original TG789 firmware is packaged with Lua. It's an excellent candiate for a lightweight Python replacement. 'Install' the Lua script for service checks. This is dependent on the script being installed, however the install script will follow these steps:

- Check Lua is available
- Check the required modules are installed. If not, install using `luarocks` or directly from file
- Copy script, and run tests
- Schedule script using cron
- Add healthcheck entry
