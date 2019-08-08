#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# PXE Server - basic test
# -----------------
#
# Author      :   Salvador Teran Ochoa
#
# Requirements:   pxe-server
#

@test "setup" {
  [ -f /etc/dnsmasq.conf ] && skip
  [ -f /etc/nginx/nginx.conf ] && skip
  [ -f /etc/nginx/conf.d/ipxe.conf ] && skip
  [ -f /etc/systemd/resolved.conf ] && skip
  [ -f /etc/systemd/network/70-internal-static.network ] && skip
  [ -f /etc/sysctl.d/80-nat-forwarding.conf ] && skip
  [ -f /var/db/dnsmasq.leases ] && skip
  [ -d /var/www/ipxe ] && skip
  [ -d /srv/tftp ] && skip
  iptables -t nat -L -nv --line-numbers | egrep -q "^[0-9]" && skip
  [ $(< /proc/sys/net/ipv4/ip_forward) == 1 ] && skip
  systemctl is-active -q dnsmasq.service && skip
  systemctl is-active -q nginx.service && skip

  # set variables
  ipxe_app_name=ipxe
  ipxe_port=50000
  web_root=/var/www
  ipxe_root=$web_root/$ipxe_app_name
  tftp_root=/srv/tftp
  external_iface=$(ip a | awk '/inet.*brd/{print $NF; exit}')
  internal_iface=enp0s3
  pxe_subnet=192.168.1
  pxe_internal_ip=$pxe_subnet.1
  pxe_subnet_mask_ip=255.255.255.0
  pxe_subnet_bitmask=16
  url=https://download.clearlinux.org

  # Create another network interface
  lsmod | grep dummy || modprobe dummy
  ip link add dummy0 type dummy
  ip link set name $internal_iface dev dummy0

  # Download the latest network-bootable release of Clear Linux and extract the files
  mkdir -p $ipxe_root
  latest_ver=$(curl --fail --silent --show-error ${url}/latest)
  curl -o /tmp/clear-pxe.tar.xz ${url}/current/clear-${latest_ver}-pxe.tar.xz
  tar -xJf /tmp/clear-pxe.tar.xz -C $ipxe_root
  ln -sf "$ipxe_root/org.clearlinux."* "$ipxe_root/linux"

  # Create an iPXE boot script with the following contents.
  cat > $ipxe_root/ipxe_boot_script.ipxe << EOF
#!ipxe
kernel linux quiet init=/usr/lib/systemd/systemd-bootchart initcall_debug \
	tsc=reliable no_timer_check noreplace-smp rw initrd=initrd
initrd initrd
boot
EOF

  #Create a configuration file for nginx to serve Clear Linux to PXE clients
  mkdir -p /etc/nginx/conf.d
  cat > /etc/nginx/conf.d/$ipxe_app_name.conf << EOF
server {
  listen $ipxe_port;
  server_name localhost;
  location /$ipxe_app_name/ {
  root $web_root;
  autoindex on;
  }
}
EOF

  cp /usr/share/nginx/conf/nginx.conf.example /etc/nginx/nginx.conf

  # Start nginx
  systemctl start nginx
  sleep 5

  # The pxe-server bundle contains a lightweight DNS server which conflicts with the DNS
  # stub listener provided in systemd-resolved. Disable the DNS stub listener and temporarily stop systemd-resolved.
  cat > /etc/systemd/resolved.conf << EOF
[Resolve]
DNSStubListener=no
EOF

  systemctl stop systemd-resolved

  # Assign a static IP address to the network adapter for the private network and restart systemd-networkd
  mkdir -p /etc/systemd/network
  cat > /etc/systemd/network/70-internal-static.network << EOF
[Match]
Name=$internal_iface
[Network]
DHCP=no
Address=$pxe_internal_ip/$pxe_subnet_bitmask
EOF

  systemctl restart systemd-networkd
  sleep 5

  # Configure NAT to route traffic from the private network to the public network.
  iptables -t nat -F POSTROUTING
  iptables -t nat -A POSTROUTING -o $external_iface -j MASQUERADE
  sleep 5

  # Configure the kernel to forward network packets to different interfaces. Otherwise, NAT will not work.
  mkdir -p /etc/sysctl.d
  echo net.ipv4.ip_forward=1 > /etc/sysctl.d/80-nat-forwarding.conf
  echo 1 > /proc/sys/net/ipv4/ip_forward

  # Create a TFTP hosting directory and populate the directory with the iPXE firmware images
  mkdir -p $tftp_root
  ln -sf /usr/share/ipxe/undionly.kpxe $tftp_root/undionly.kpxe

  # Create a configuration file for dnsmasq to listen on a dedicated IP address for those functions.
  echo "listen-address=$pxe_internal_ip" > /etc/dnsmasq.conf

  # Add the options to serve iPXE firmware images to PXE clients over TFTP to the dnsmasq configuration file.
  cat >> /etc/dnsmasq.conf << EOF
enable-tftp
tftp-root=$tftp_root
EOF

  # Add the options to host a DHCP server for PXE clients to the dnsmasq configuration file.
  cat >> /etc/dnsmasq.conf << EOF
dhcp-leasefile=/var/db/dnsmasq.leases

dhcp-authoritative
dhcp-option=option:router,$pxe_internal_ip
dhcp-option=option:dns-server,$pxe_internal_ip

dhcp-match=set:pxeclient,60,PXEClient*
dhcp-range=tag:pxeclient,$pxe_subnet.2,$pxe_subnet.253,$pxe_subnet_mask_ip,15m
dhcp-range=tag:!pxeclient,$pxe_subnet.2,$pxe_subnet.253,$pxe_subnet_mask_ip,6h

dhcp-match=set:ipxeboot,175
dhcp-boot=tag:ipxeboot,http://$pxe_internal_ip:$ipxe_port/$ipxe_app_name/ipxe_boot_script.ipxe
dhcp-boot=tag:!ipxeboot,undionly.kpxe,$pxe_internal_ip
EOF

  # The configuration provides the following important functions:

  # Directs PXE clients without an iPXE implementation to the TFTP server to acquire
  # architecture-specific iPXE firmware images that allow them to perform an iPXE boot.
  # Activates only on the network adapter that has an IP address on the defined subnet.
  # Directs PXE clients to the DNS server.
  # Directs PXE clients to the PXE server for routing via NAT.
  # Divides the private network into two pools of IP addresses. One pool is for
  # network boot and one pool is used after boot. Each pool has their own lease times.

  # Create a file for dnsmasq to record the IP addresses it provides to PXE clients
  mkdir -p /var/db
  touch /var/db/dnsmasq.leases

  # Start dnsmasq
  systemctl restart dnsmasq
  sleep 5

  # Start systemd-resolved
  systemctl start systemd-resolved
  sleep 5
}

@test "remove" {
  [ ! -f /etc/systemd/network/70-internal-static.network ] && skip
  [ ! -f /etc/sysctl.d/80-nat-forwarding.conf ] && skip

  rm -f /etc/dnsmasq.conf
  rm -f /etc/systemd/resolved.conf
  rm -f /etc/systemd/network/70-internal-static.network
  rm -rf /etc/nginx
  rm -rf /etc/sysctl.d
  rm -rf /var/db
  rm -rf /var/www/ipxe
  rm -rf /srv/tftp
  iptables -t nat -F POSTROUTING
  echo 0 > /proc/sys/net/ipv4/ip_forward
  ip link delete enp0s3
  systemctl daemon-reload
  systemctl restart systemd-networkd
  sleep 5
  systemctl restart systemd-resolved
  sleep 5
  systemctl stop nginx.service
  sleep 5
  systemctl stop dnsmasq.service
  sleep 5
}
