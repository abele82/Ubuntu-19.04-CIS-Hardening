#! /bin/bash

# This script hardens the workstation against all the level 1 NOT SCORED requirements in the CIS benchmark

# Confirming that the script is being run as root before proceeding

if [[ $UID -ne 0 ]]; then
	echo "Need to run this script as root (with sudo su -)"
	exit 1
fi

echo "[I] Beginning level 1 (NOT SCORED) hardening script now"

#########################################################################################################################################

# 1.1.17 Ensure nodev option set on removable media partitions (Not Scored)

# Can't decide how best to do this.  It's largely down to individual systems and the removable media that is present.  Could maybe
# do some sort of 'if' statement to look for common ones like 'cdrom' and then add the necessary hardening to fstab.

#########################################################################################################################################

# 1.1.18 Ensure nosuid option set on removable media partitions (Not Scored)

# As above, it's dependent on the system setup.  Will need to look at this again.

#########################################################################################################################################

# 1.1.19 Ensure noexec option set on removable media partitions (Not Scored)

# As above

#########################################################################################################################################

# 1.2.1 Ensure package manager repositories are configured (Not Scored)

# Need to establish an approved list of repositories.  At the moment, the default ones are fine.

#########################################################################################################################################






















$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

DELETE ALL BELOW ONCE COMPLETE

$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$







apt update
apt upgrade



# 1.1.1.1 Ensure mounting of cramfs filesystems is disabled (Scored)
# NOT ENABLED BY DEFAULT ON UBUNTU
#echo "[i] Disabling the mounting of cramfs filesystems"
#echo "install cramfs /bin/true" > /etc/modprobe.d/cramfs.conf
#rmmod cramfs
#sleep 1

#########################################################################################################################################

# 1.1.1.2 Ensure mounting of freevxfs filesystems is disabled (Scored)
# NOT ENABLED BY DEFAULT ON UBUNTU
#echo "[I] Disabling the mounting of freevxfs filesystems"
#echo "install freevxfs /bin/true" > /etc/modprobe.d/freevxfs.conf
#rmmod freevxfs
#sleep 1

#########################################################################################################################################

# 1.1.1.3 Ensure mounting of jffs2 filesystems is disabled (Scored)
# NOT ENABLED BY DEFAULT ON UBUNTU
#echo "[I] Disabling the mounting of jffs2 filesystems"
#echo "install jffs2 /bin/true" > /etc/modprobe.d/jffs2.conf
#rmmod jffs2
#sleep 1

#########################################################################################################################################

# 1.1.1.4 Ensure mounting of hfs filesystems is disabled (Scored)
# NOT ENABLED BY DEFAULT ON UBUNTU
#echo "[I] Disabling the mounting of hfs filesystems"
#echo "install hfs /bin/true" > /etc/modprobe.d/hfs.conf
#rmmod hfs
#sleep 1

#########################################################################################################################################

# 1.1.1.5 Ensure mounting of hfsplus filesystems is disabled (Scored)
# NOT ENABLED BY DEFAULT ON UBUNTU
#echo "[I] Disabling the mounting of hfsplus filesystems"
#echo "install hfsplus /bin/true" > /etc/modprobe.d/hfsplus.conf
#rmmod hfsplus
#sleep 1

#########################################################################################################################################

# 1.1.1.6 Ensure mounting of udf filesystems is disabled (Scored)
# NOT ENABLED BY DEFAULT ON UBUNTU
#echo "[I] Disabling the mounting of udf filesystems"
#echo "install udf /bin/true" > /etc/modprobe.d/udf.conf
#rmmod udf
#sleep 1

#########################################################################################################################################

# 1.1.3 Ensure nodev option set /tmp partition (Scored)
# 1.1.4 Ensure nosuid option set on /tmp partition (Scored)

echo "[i] Ensuring that nodev & nosuid are set on the /tmp partition"

LINETMP="tmpfs /tmp tmpfs nosuid,noexec,nodev,relatime,rw 0 0"

grep -F "$LINETMP" /etc/fstab || echo "$LINETMP" | tee -a /etc/fstab > /dev/null

#########################################################################################################################################

# 1.1.7 Ensure nodev option set on /var/tmp partition (Scored)
# 1.1.8 Ensure nosuid option set on /var/tmp partition (Scored)
# 1.1.9 Ensure noexec option set on /var/tmp partition (Scored)



#########################################################################################################################################

# 1.1.13 Ensure nodev option set on /home partition (Scored)

echo "[i] Ensuring that the nodev option is set on the /home partition"

echo "[i] If you have a separate home partition, you need to provide it's name"
echo "[i] If a separate home partition doesn't exist, leave this blank."
echo "[i] Home partition example: /dev/xvda1"
read -p "[?] Enter home partition: " HOME_PARTITION

if [ -b $HOME_PARTITION ]

then

    LINEHOME="$HOME_PARTITION /home ext4 rw,relatime,nodev,data=ordered 0 0"

    grep -F "$LINEHOME" /etc/fstab || echo "$LINEHOME" | tee -a /etc/fstab > /dev/null

fi

#########################################################################################################################################

# 1.1.14 Ensure nodev option set on /dev/shm partition (Scored)
# 1.1.15 Ensure nosuid option set on /dev/shm partition (Scored)
# 1.1.16 Ensure noexec option set on /dev/shm partition (Scored)

echo "[i] Ensuring that nodev, nosuid & noexec is set on the /dev/shm partition"

LINEDEVSHM="tmpfs /dev/shm tmpfs nosuid,noexec,nodev,relatime,rw 0 0"

grep -F "$LINEDEVSHM" /etc/fstab || echo "$LINEDEVSHM" | tee -a /etc/fstab > /dev/null

#########################################################################################################################################

# 1.1.20 Ensure sticky bit is set on all world-writable directories (Scored)

echo "[i] Ensuring that sticky bit is set on all world-writable directories"

df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d -perm -0002 2>/dev/null | xargs chmod a+t

#########################################################################################################################################

# 1.4.1 Ensure permissions on bootloader config are configured (Scored)

echo "[i] Setting correct permissions for the bootloader config"

chown root:root /boot/grub/grub.cfg
chmod og-rwx /boot/grub/grub.cfg

#########################################################################################################################################

# 1.4.2 Ensure bootloader password is set (Scored)

echo "[i] Setting bootloader password"

SAFE_SSH=1

if [ $SAFE_SSH != 1 ]
then
    if ( grep -q "^set superusers" /boot/grub/grub.cfg )
    then
        echo "Superusers: EXIST"
    else
        echo "Superusers: I sleep."

        FILE=/home/out

        # Create boot password for boot loader.
        grub-mkpasswd-pbkdf2 | sudo tee "$FILE"

        enc_pass=$( grep .sha512 "$FILE" | awk -F "is " '{print $2}' )

        # Remove out file
        rm "$FILE"

        FILE=/etc/grub.d/40_custom
        LINE="set superusers=\"root\""

        enc_pass="password_pbkdf2 root $enc_pass"

        # Append superusers and password if not exist.
        grep -qF "$LINE" "$FILE" || echo "$LINE" | sudo tee --append "$FILE" > /dev/null
        grep -qF "$enc_pass" "$FILE" || echo "$enc_pass" | sudo tee --append "$FILE" > /dev/null

        # Update grub config file
        update-grub

    fi
fi

#########################################################################################################################################

# 1.4.3 Ensure authentication required for single user maode (Scored)

echo "[i] Checking if the root user already has a password set"

if ! grep ^root:[*\!]: /etc/shadow

then
	echo "[i] root user already has a password set"
	echo "[i] no further action required"
else
	echo "[i] root user hasn't got a password set"
	echo "[i] Setting a password for the root user"
	passwd root
fi

#########################################################################################################################################

# 1.5.1 Ensure core dumps are restricted (Scored)

echo "[i] Ensuring core dumps are restricted"

DUMPLINE="* hard core 0"
DUMPFILE=/etc/security/limits.conf

grep -qF "$DUMPLINE" "$DUMPFILE" || echo "$DUMPLINE" | tee -a "$DUMPFILE" > /dev/null

DUMPABLELINE="fs.suid_dumpable=0"
DUMPABLEFILE=/etc/sysctl.conf

grep -qF "$DUMPABLELINE" "$DUMPABLEFILE" || echo "$DUMPABLELINE" | tee -a "$DUMPABLEFILE" > /dev/null

sysctl -w fs.suid_dumpable=0

#########################################################################################################################################

# 1.5.3 Ensure address space layout randomization (ASLR) is enabled (Scored)

echo "[i] Ensuring address space layout randomization (ASLR) is enabled"

ASLRLINE="kernel.randomize_va_space = 2"
ASLRFILE=/etc/sysctl.d/99-walson-hardening.conf

touch "$ASLRFILE"

grep -qF "$ASLRLINE" "$ASLRFILE" || echo "$ASLRLINE" | tee -a "$ASLRFILE" > /dev/null

sysctl -w kernel.randomize_va_space=2

#########################################################################################################################################

# 1.5.4 Ensure prelink is disabled (Scored)
# PRELINK NOT INSTALLED ON UBUNTU
#echo "[i] Restoring the prelink binaries to normal"
#prelink -ua
#echo "[i] Uninstalling prelink"
#apt-get remove prelink

#########################################################################################################################################

# 1.7.1.1 Ensure message of the day is configured properly (Scored)

echo "[i] Creating the message of the day"
echo "Unauthorised use of this system is an offence under the Computer Misuse Act 1990. All activity may be monitored and reported." > /etc/motd

#########################################################################################################################################

# 1.7.1.2 Ensure local login warning banner is configured properly (Scored)

echo "[i] Creating the local login warning banner"
echo "Unauthorised use of this system is an offence under the Computer Misuse Act 1990. All activity may be monitored and reported." > /etc/issue

#########################################################################################################################################

# 1.7.1.3 Ensure remote login warning banner is configured properly (Scored)

echo "[i] Creating the remote login warning banner"
echo "Unauthorised use of this system is an offence under the Computer Misuse Act 1990. All activity may be monitored and reported." > /etc/issue.net

#########################################################################################################################################

# 1.7.1.4 Ensure permissions on /etc/motd are configured (Scored)

echo "[i] Setting correct permissions on /etc/motd"
chown root:root /etc/motd
chmod 644 /etc/motd

#########################################################################################################################################

# 1.7.1.5 Ensure permissions on /etc/issue are configured (Scored)

echo "[i] Setting correct permissions on /etc/issue"
chown root:root /etc/issue
chmod 644 /etc/issue

#########################################################################################################################################

# 1.7.1.6 Ensure permissions on /etc/issue.net are configured (Scored)

echo "[i] Setting correct permissions on /etc/issue.net"
chown root:root /etc/issue.net
chmod 644 /etc/issue.net

#########################################################################################################################################

# 1.7.2 Ensure GDM login banner is configured (Scored)
# Removed as changing this borks the entire install on Ubuntu. Not entirely sure why.
#echo "[i] Setting the GDM login banner"
#echo "[org/gnome/login-screen]" > /etc/gdm3/greeter.dconf-defaults
#echo "banner-message-enable=true" >> /etc/gdm3/greeter.dconf-defaults
#echo "banner-message-text='Unauthorised use of this system is an offence under the Computer Misuse Act 1990. All activity may be monitored and reported." >> /etc/gdm3/greeter.dconf-defaults

#########################################################################################################################################

# 2.1.1 Ensure chargen services are not enabled (Scored)
# 2.1.2 Ensure daytime services are not enabled (Scored)
# 2.1.3 Ensure discard services are not enabled (Scored)
# 2.1.4 Ensure echo services are not enabled (Scored)
# 2.1.5 Ensure time services are not enabled (Scored)
# 2.1.6 Ensure rsh server is not enabled (Scored)
# 2.1.7 Ensure talk server is not enabled (Scored)
# 2.1.8 Ensure telnet server is not enabled (Scored)
# 2.1 9 Ensure tftp server is not enabled (Scored)

# All the above are only valid if inetd is installed but it isn't installed by default in Ubuntu.  Therefore, none of the hardening is being performed.  I might create an extra inetd hardening script for anyone who has installed it and needs it disabling! 
# The 'workstation_cis_hardening_level1_CHECK.sh' script will highlight if inetd services are enabled and need to be disabled (but they shouldn't be).

#########################################################################################################################################

# 2.1.10 Ensure xinetd is not enabled (Scored)
# NOT ENABLED IN UBUNTU
#echo "[i] Disabling xinetd"
#systemctl disable xinetd

#########################################################################################################################################

# 2.1.11 Ensure openbsd-inetd is not installed

echo "[i] Removing openbsd-inetd"
apt-get remove openbsd-inetd

#########################################################################################################################################

# 2.2.1.2 Ensure ntp is configured

echo "[i] Installing NTP"

apt install --assume-yes ntp

echo "[i] Configuring ntp"

sed -i 's/^restrict -4.*/restrict -4 default kod nomodify notrap nopeer noquery/' /etc/ntp.conf
sed -i 's/^restrict -6.*/restrict -6 default kod nomodify notrap nopeer noquery/' /etc/ntp.conf

# Adding NTP servers for the UK

if grep -q "^server.*" /etc/ntp.conf; then
	sed '/^server.*/d' /etc/ntp.conf
	echo "server 0.uk.pool.ntp.org" >> /etc/ntp.conf
	echo "server 1.uk.pool.ntp.org" >> /etc/ntp.conf
	echo "server 2.uk.pool.ntp.org" >> /etc/ntp.conf
	echo "server 3.uk.pool.ntp.org" >> /etc/ntp.conf
else
	echo "server 0.uk.pool.ntp.org" >> /etc/ntp.conf
	echo "server 1.uk.pool.ntp.org" >> /etc/ntp.conf
	echo "server 2.uk.pool.ntp.org" >> /etc/ntp.conf
	echo "server 3.uk.pool.ntp.org" >> /etc/ntp.conf
fi

# Adding ntp user as the RUNAS user in the /etc/init.d/ntp file

if grep -q "^RUNASUSER=" /etc/init.d/ntp; then 
	sed -i 's/^RUNASUSER=.*/RUNASUSER=ntp/' /etc/init.d/ntp
else
    echo "RUNASUSER=ntp" >> /etc/init.d/ntp
fi

#########################################################################################################################################

# 2.2.1.3 Ensure chrony is configured (Scored)

echo "[i] Installing chrony"

apt install --assume-yes chrony

echo "[i] Configuring chrony"

# Adding NTP servers for the UK

if grep -q "^server.*" /etc/chrony/chrony.conf; then
	sed '/^server.*/d' /etc/chrony/chrony.conf
	echo "server 0.uk.pool.ntp.org" >> /etc/chrony/chrony.conf
	echo "server 1.uk.pool.ntp.org" >> /etc/chrony/chrony.conf
	echo "server 2.uk.pool.ntp.org" >> /etc/chrony/chrony.conf
	echo "server 3.uk.pool.ntp.org" >> /etc/chrony/chrony.conf
else
	echo "server 0.uk.pool.ntp.org" >> /etc/chrony/chrony.conf
	echo "server 1.uk.pool.ntp.org" >> /etc/chrony/chrony.conf
	echo "server 2.uk.pool.ntp.org" >> /etc/chrony/chrony.conf
	echo "server 3.uk.pool.ntp.org" >> /etc/chrony/chrony.conf
fi

#########################################################################################################################################

# 2.2.3 Ensure Avahi Server is not enabled (Scored)

echo "[i] Disabling Avahi Server"

systemctl disable avahi-daemon

#########################################################################################################################################

# 2.2.5 Ensure DHCP Server is not enabled (Scored)
# Not enabled in Ubuntu
#echo "[i] Disabling DHCP Server"

#systemctl disable isc-dhcp-server
#systemctl disable isc-dhcp-server6

#########################################################################################################################################

# 2.2.6 Ensure LDAP server is not enabled (Scored)
# Not enabled in Ubuntu
#echo "[i] Disabling LDAP server"

#systemctl disable slapd

#########################################################################################################################################

# 2.2.7 Ensure NFS and RPC are not enabled (Scored)
# Not enabled in Ubuntu
#echo "[i] Disabling NFS and RPC"

#systemctl disable nfs-server
#systemctl disable rpcbind

#########################################################################################################################################

# 2.2.8 Ensure DNS Server is not enabled (Scored)
# Not enabled in Ubuntu
#echo "[i] Disabling DNS Server"

#systemctl disable bind9

#########################################################################################################################################

# 2.2.9 Ensure FTP Server is not enabled (Scored)
# Not enabled in Ubuntu
#echo "[i] Disabling FTP Server"

#systemctl disable vsftpd

#########################################################################################################################################

# 2.2.10 Ensure HTTP Server is not enabled (Scored)
# Not enabled in Ubuntu
#echo "[i] Disabling HTTP Server"

#systemctl disable apache2

#########################################################################################################################################

# 2.2.11 Ensure IMAP and POP3 server is not enabled (Scored)
# Not enabled in Ubuntu
#echo "[i] Disabling IMAP and POP3 Server"

#systemctl disable dovecot

#########################################################################################################################################

# 2.2.12 Ensure Samba is not enabled (Scored)
# Not enabled in Ubuntu
#echo "[i] Disabling Samba"

#systemctl disable smbd

#########################################################################################################################################

# 2.2.13 Ensure HTTP Proxy Server is not enabled (Scored)
# Not enabled in Ubuntu
#echo "[i] Disabling HTTP Proxy Server"

#systemctl disable squid

#########################################################################################################################################

# 2.2.14 Ensure SNMP Server is not enabled (Scored)
# Not enabled in Ubuntu
#echo "[i] Disabling SNMP Server"

#systemctl disable snmpd

#########################################################################################################################################

# 2.2.15 Ensure mail transfer agent is configured for local-only mode (Scored)

echo "[i] Configuring mail transfer agent for local-only mode"

if grep -q "^inet_interfaces = " /etc/postfix/main.cf; then 
	sed -i 's/^inet_interfaces.*/inet_interface = loopback-only/' /etc/postfix/main.cf
else
    echo "inet_interfaces = loopback-only" >> /etc/postfix/main.cf
fi

systemctl restart postfix

#########################################################################################################################################

# 2.2.16 Ensure rsync service is not enabled (Scored)

echo "[i] Disabling rsync service"

systemctl disable rsync

#########################################################################################################################################

# 2.2.17 Ensure NIS Server is not enabled (Scored)

echo "[i] Disabling NIS Server"

systemctl disable nis

#########################################################################################################################################

# 2.3.1 Ensure NIS Client is not installed (Scored)

echo "[i] Uninstalling NIS client"

apt remove -y nis

#########################################################################################################################################

# 2.3.2 Ensure rsh client is not installed (Scored)

echo "[i] Uninstalling the rsh client"

apt remove -y rsh-client rsh-redone-client

#########################################################################################################################################

# 2.3.3 Ensure talk client is not installed (Scored)

echo "[i] Uninstalling the talk client"

apt remove -y talk

#########################################################################################################################################

# 2.3.4 Ensure telnet client is not installed (Scored)

echo "[i] Uninstalling the telnet client"

apt remove -y telnet

#########################################################################################################################################

# 2.3.5 Ensure LDAP client is not installed (Scored)

echo "[i] Uninstalling the LDAP client"

apt remove -y ldap-utils

#########################################################################################################################################

# 3.1.1 Ensure IP forwarding is disabled (Scored)
# 3.1.2 Ensure packet redirect sending is disabled (Scored)

# This are only required if the system is to act as a host only.  If needed, run the 'workstation_cis_hardening_level1_scored_HOSTONLY.sh' script to apply these controls

#########################################################################################################################################

# 3.2.1 Ensure source routed packets are not accepted (Scored)

echo "[i] Ensuring source routed packets are not accepted"

if grep -q "^net.ipv4.conf.all.accept_source_route" /etc/sysctl.conf; then 
	sed -i 's/^net.ipv4.conf.all.accept_source_route.*/net.ipv4.conf.all.accept_source_route = 0/' /etc/sysctl.conf
else
    echo "net.ipv4.conf.all.accept_source_route = 0" >> /etc/sysctl.conf
fi

if grep -q "^net.ipv4.conf.default.accept_source_route" /etc/sysctl.conf; then 
	sed -i 's/^net.ipv4.conf.default.accept_source_route.*/net.ipv4.conf.default.accept_source_route = 0/' /etc/sysctl.conf
else
    echo "net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.conf
fi

sysctl -w net.ipv4.conf.all.accept_source_route=0
sysctl -w net.ipv4.conf.default.accept_source_route=0
sysctl -w net.ipv4.route.flush=1

#########################################################################################################################################

# 3.2.2 Ensure ICMP redirects are not accepted (Scored)

echo "[i] Ensuring ICMP redirects are not accepted"

if grep -q "^net.ipv4.conf.all.accept_redirects" /etc/sysctl.conf; then 
	sed -i 's/^net.ipv4.conf.all.accept_redirects.*/net.ipv4.conf.all.accept_redirects = 0/' /etc/sysctl.conf
else
    echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
fi

if grep -q "^net.ipv4.conf.default.accept_redirects" /etc/sysctl.conf; then 
	sed -i 's/^net.ipv4.conf.default.accept_redirects.*/net.ipv4.conf.default.accept_redirects = 0/' /etc/sysctl.conf
else
    echo "net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.conf
fi

sysctl -w net.ipv4.conf.all.accept_redirects=0
sysctl -w net.ipv4.conf.default.accept_redirects=0
sysctl -w net.ipv4.route.flush=1

#########################################################################################################################################

# 3.2.3 Ensure secure ICMP redirects are not accepted (Scored)

echo "[i] Ensuring secure ICMP redirects are not accepted"

if grep -q "^net.ipv4.conf.all.secure_redirects" /etc/sysctl.conf; then 
	sed -i 's/^net.ipv4.conf.all.secure_redirects.*/net.ipv4.conf.all.secure_redirects = 0/' /etc/sysctl.conf
else
    echo "net.ipv4.conf.all.secure_redirects = 0" >> /etc/sysctl.conf
fi

if grep -q "^net.ipv4.conf.default.secure_redirects" /etc/sysctl.conf; then 
	sed -i 's/^net.ipv4.conf.default.secure_redirects.*/net.ipv4.conf.default.secure_redirects = 0/' /etc/sysctl.conf
else
    echo "net.ipv4.conf.default.secure_redirects = 0" >> /etc/sysctl.conf
fi

sysctl -w net.ipv4.conf.all.secure_redirects=0
sysctl -w net.ipv4.conf.default.secure_redirects=0
sysctl -w net.ipv4.route.flush=1

#########################################################################################################################################

# 3.2.4 Ensure suspicious packets are logged (Scored)

echo "[i] Ensuring suspicious packets are logged"

if grep -q "^net.ipv4.conf.all.log_martians" /etc/sysctl.conf; then 
	sed -i 's/^net.ipv4.conf.all.log_martians.*/net.ipv4.conf.all.log_martians = 1/' /etc/sysctl.conf
else
    echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.conf
fi

if grep -q "^net.ipv4.conf.default.log_martians" /etc/sysctl.conf; then 
	sed -i 's/^net.ipv4.conf.default.log_martians.*/net.ipv4.conf.default.log_martians = 1/' /etc/sysctl.conf
else
    echo "net.ipv4.conf.default.log_martians = 1" >> /etc/sysctl.conf
fi

sysctl -w net.ipv4.conf.all.log_martians=1
sysctl -w net.ipv4.conf.default.log_martians=1
sysctl -w net.ipv4.route.flush=1

#########################################################################################################################################

# 3.2.5 Ensure broadcast ICMP requests are ignored (Scored)

echo "[i] Ensuring broadcast ICMP requests are ignored"

if grep -q "^net.ipv4.icmp_echo_ignore_broadcasts" /etc/sysctl.conf; then 
	sed -i 's/^net.ipv4.icmp_echo_ignore_broadcasts.*/net.ipv4.icmp_echo_ignore_broadcasts = 1/' /etc/sysctl.conf
else
    echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.conf
fi

sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1
sysctl -w net.ipv4.route.flush=1

#########################################################################################################################################

# 3.2.6 Ensure bogus ICMP responses are ignored (Scored)

echo "[i] Ensuring bogus ICMP responses are ignored"

if grep -q "^net.ipv4.icmp_ignore_bogus_error_responses" /etc/sysctl.conf; then 
	sed -i 's/^net.ipv4.icmp_ignore_bogus_error_responses.*/net.ipv4.icmp_ignore_bogus_error_responses = 1/' /etc/sysctl.conf
else
    echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >> /etc/sysctl.conf
fi

sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1
sysctl -w net.ipv4.route.flush=1

#########################################################################################################################################

# 3.2.7 Ensure Reverse Path Filtering is enabled (Scored)

echo "[i] Ensuring Reverse Path Filtering is enabled"

if grep -q "^net.ipv4.conf.all.rp_filter" /etc/sysctl.conf; then 
	sed -i 's/^net.ipv4.conf.all.rp_filter.*/net.ipv4.conf.all.rp_filter = 1/' /etc/sysctl.conf
else
    echo "net.ipv4.conf.all.rp_filter = 1" >> /etc/sysctl.conf
fi

if grep -q "^net.ipv4.conf.default.rp_filter" /etc/sysctl.conf; then 
	sed -i 's/^net.ipv4.conf.default.rp_filter.*/net.ipv4.conf.default.rp_filter = 1/' /etc/sysctl.conf
else
    echo "net.ipv4.conf.default.rp_filter = 1" >> /etc/sysctl.conf
fi

sysctl -w net.ipv4.conf.all.rp_filter=1
sysctl -w net.ipv4.conf.default.rp_filter=1
sysctl -w net.ipv4.route.flush=1

#########################################################################################################################################

# 3.2.8 Ensure TCP SYN Cookies is enabled (Scored)

echo "[i] Ensuring TCP SYN Cookies is enabled"

if grep -q "^net.ipv4.tcp_syncookies" /etc/sysctl.conf; then 
	sed -i 's/^net.ipv4.tcp_syncookies.*/net.ipv4.tcp_syncookies = 1/' /etc/sysctl.conf
else
    echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf
fi

sysctl -w net.ipv4.tcp_syncookies=1
sysctl -w net.ipv4.route.flush=1

#########################################################################################################################################

# 3.4.1 Ensure TCP Wrappers is installed (Scored)

echo "[i] Installing TCP Wrappers"

apt install -y tcpd

#########################################################################################################################################

# 3.4.2 Ensure /etc/hosts.allow is configured (Scored)

# This control is dependent on the individual organisation so will need to be set manually
# By default, nothing is in the hosts.allow so when we generate the hosts.deny in the next section, no IP addresses with be permitted to connect with the host

#########################################################################################################################################

# 3.4.3 Ensure /etc/hosts.deny is configured (Scored)

echo "[i] The hosts.deny file is being created with a default 'deny all' rule"

echo "ALL: ALL" >> /etc/hosts.deny

#########################################################################################################################################

# 3.4.4 Ensure permissions on /etc/hosts.allow are configured (Scored)

echo "[i] Setting the correct permissions for the 'hosts.allow' file"

chown root:root /etc/hosts.allow
chmod 644 /etc/hosts.allow

#########################################################################################################################################

# 3.4.4 Ensure permissions on /etc/hosts.deny are configured (Scored)

echo "[i] Setting the correct permissions for the 'hosts.deny' file"

chown root:root /etc/hosts.deny
chmod 644 /etc/hosts.deny

#########################################################################################################################################

# 3.6.1 Ensure iptables is installed (Scored)
# 3.6.2 Ensure default deny firewall policy (Scored)
# 3.6.3 Ensure loopback traffic is configured (Scored)
# 3.6.5 Ensure firewall rules exist for all open ports (Scored)

echo "[i] Installing iptables"

apt install -y iptables

echo "[i] Flushing iptable rules"
iptables -F

echo "[i] Adding default deny firewall policy"

#iptables -P INPUT DROP
#iptables -P OUTPUT DROP 
iptables -P FORWARD DROP 
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

echo "[i] Configuring loopback traffic rules within firewall policy"
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -s 127.0.0.0/8 -j DROP

echo "[i] Opening inbound ssh (tcp port 22) connections within the firewall policy" 
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT

echo "[i] All additional rules will need to be added manually if required"

#########################################################################################################################################

# 4.2.1.1 Ensure rsyslog Service is enabled (Scored)
# 4.2.3 Ensure rsyslog or syslog-ng is installed

# Although 4.2.3 should come later, rsyslog needs to be confirmed as installed now otherwise the other controls would fail 

apt install -y rsyslog
apt install -y syslog-ng

echo "[i] Enabling rsyslog service"

systemctl enable rsyslog

#########################################################################################################################################

# 4.2.1.3 Ensure rsyslog default file permissions configured (Scored)

echo "[i] Configuring rsyslog default file permissions"

if grep -q "^$FileCreateMode" /etc/sysctl.conf; then 
	sed -i 's/^$FileCreateMode.*/$FileCreateMode 0640/' /etc/sysctl.conf
else
    echo "$FileCreateMode 0640" >> /etc/sysctl.conf
fi

#########################################################################################################################################

# 4.2.1.4 Ensure rsyslog is configured to send logs to a remote log host server (Scored)

# This requires the system administrator to manually add the url of a log host

#########################################################################################################################################

# 4.2.2.1 Ensure syslog-ng service is enabled (Scored)

echo "[i] Enabling syslog-ng service"

update-rc.d syslog-ng enable

#########################################################################################################################################

# 4.2.2.3 Ensure syslog-ng default file permissions configured (Scored)

echo "[i] Configuring the syslog-ng default file permissions"

if grep -q "^options {" /etc/syslog-ng/syslog-ng.conf; then 
	sed -i 's/^options {.*/options { chain_hostnames(off); flush_lines(0); perm(0640); stats_freq(3600); threaded(yes); };/' /etc/syslog-ng/syslog-ng.conf
else
    echo "options { chain_hostnames(off); flush_lines(0); perm(0640); stats_freq(3600); threaded(yes); };" >> /etc/syslog-ng/syslog-ng.conf
fi

#########################################################################################################################################

# 4.2.3 Ensure rsyslog or syslog-ng is installed

# The installation was already carried out during the '4.2.1.1' control above

#########################################################################################################################################

# 4.2.4 Ensure permissions on all logfiles are configured (Scored)

echo "[i] Setting correct permissions on all log files"

chmod -R g-wx, o-rwx /var/log/*

#########################################################################################################################################

# 5.1.1 Ensure cron daemon is enabled (Scored)

echo "[i] Enabling the cron daemon"

systemctl enable cron

#########################################################################################################################################

# 5.1.2 Ensure permissions on /etc/crontab are configured (Scored)

echo "[i] Setting the correct permissions on /etc/crontab"

chown root:root /etc/crontab
chmod og-rwx /etc/crontab

#########################################################################################################################################

# 5.1.3 Ensure permissions on /etc/cron.hourly are configured (Scored)

echo "[i] Setting the correct permissions on /etc/cron.hourly"

chown root:root /etc/cron.hourly
chmod og-rwx /etc/cron.hourly

#########################################################################################################################################

# 5.1.4 Ensure permissions on /etc/cron.daily are configured (Scored)

echo "[i] Setting the correct permissions on /etc/cron.daily"

chown root:root /etc/cron.daily
chmod og-rwx /etc/cron.daily

#########################################################################################################################################

# 5.1.5 Ensure permissions on /etc/cron.weekly are configured (Scored)

echo "[i] Setting the correct permissions on /etc/cron.weekly"

chown root:root /etc/cron.weekly
chmod og-rwx /etc/cron.weekly

#########################################################################################################################################

# 5.1.6 Ensure permissions on /etc/cron.monthly are configured (Scored)

echo "[i] Setting the correct permissions on /etc/cron.monthly"

chown root:root /etc/cron.monthly
chmod og-rwx /etc/cron.monthly

#########################################################################################################################################

# 5.1.7 Ensure permissions on /etc/cron.d are configured (Scored)

echo "[i] Setting the correct permissions on /etc/cron.d"

chown root:root /etc/cron.d
chmod og-rwx /etc/cron.d

#########################################################################################################################################

# 5.1.8 Ensure at/cron is restricted to authorized users (Scored)

echo "[i] Restricting at/cron to authorised users"

touch /etc/cron.allow
touch /etc/at.allow
chmod og-rwx /etc/cron.allow
chmod og-rwx /etc/at.allow
chown root:root /etc/cron.allow
chown root:root /etc/at.allow

#########################################################################################################################################

# 5.2.1 Ensure permissions on /etc/ssh/sshd_config are configured correctly (Scored)

echo "[i] Setting correct permission on /etc/ssh/sshd_config"

chown root:root /etc/ssh/sshd_config
chmod og-rwx /etc/ssh/sshd_config

#########################################################################################################################################

# 5.2.2 Ensure SSH Protocol is set to 2 (Scored)

echo "[i] Ensuring SSH Protocol is set to 2"

if grep -q "^Protocol" /etc/ssh/sshd_config; then 
	sed -i 's/^Protocol.*/Protocol 2/' /etc/ssh/sshd_config
else
    echo "Protocol 2" >> /etc/ssh/sshd_config
fi

#########################################################################################################################################

# 5.2.3 Ensure SSH LogLevel is set to INFO (Scored)

echo "[i] Ensuring SSH LogLevel is set to INFO"

if grep -q "^LogLevel" /etc/ssh/sshd_config; then 
	sed -i 's/^LogLevel.*/LogLevel INFO/' /etc/ssh/sshd_config
else
    echo "LogLevel INFO" >> /etc/ssh/sshd_config
fi

#########################################################################################################################################

# 5.2.4 Ensure SSH X11 forwarding is disabled (Scored)

echo "[i] Disabling SSH X11 forwarding"

if grep -q "^X11Forwarding" /etc/ssh/sshd_config; then 
	sed -i 's/^X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config
else
    echo "X11Forwarding No" >> /etc/ssh/sshd_config
fi

#########################################################################################################################################

# 5.2.5 Ensure SSH MaxAuthTries is set to 4 or less (Scored)

echo "[i] Setting SSH MaxAuthTries to 4"

if grep -q "^MaxAuthTries" /etc/ssh/sshd_config; then 
	sed -i 's/^MaxAuthTries.*/MaxAuthTries 4/' /etc/ssh/sshd_config
else
    echo "MaxAuthTries 4" >> /etc/ssh/sshd_config
fi

#########################################################################################################################################

# 5.2.6 Ensure SSH IgnoreRhosts is enabled (Scored)

echo "[i] Enabling SSH IgnoreRhosts"

if grep -q "^IgnoreRhosts" /etc/ssh/sshd_config; then 
	sed -i 's/^IgnoreRhosts.*/IgnoreRhosts yes/' /etc/ssh/sshd_config
else
    echo "IgnoreRhosts yes" >> /etc/ssh/sshd_config
fi

#########################################################################################################################################

# 5.2.7 Ensure SSH HostbasedAuthentication is disabled (Scored)

echo "[i] Disabling SSH HostbasedAuthentication"

if grep -q "^HostbasedAuthentication" /etc/ssh/sshd_config; then 
	sed -i 's/^HostbasedAuthentication.*/HostbasedAuthentication no/' /etc/ssh/sshd_config
else
    echo "HostbasedAuthentication no" >> /etc/ssh/sshd_config
fi

#########################################################################################################################################

# 5.2.8 Ensure SSH root login is disabled (Scored)

echo "[i] Disabling SSH root login"

if grep -q "^PermitRootLogin" /etc/ssh/sshd_config; then 
	sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
else
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config
fi

#########################################################################################################################################

# Ensure SSH PermitEmptyPasswords is disabled (Scored)

echo "[i] Disabling SSH PermitEmptyPasswords"

if grep -q "^PermitEmptyPasswords" /etc/ssh/sshd_config; then 
	sed -i 's/^PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
else
    echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config
fi

#########################################################################################################################################

# 5.2.10 Ensure SSH PermitUserEnvironment is disabled (Scored)

echo "[i] Disabling SSH PermitUserEnvironment"

if grep -q "^PermitUserEnvironment" /etc/ssh/sshd_config; then 
	sed -i 's/^PermitUserEnvironment.*/PermitUserEnvironment no/' /etc/ssh/sshd_config
else
    echo "PermitUserEnvironment no" >> /etc/ssh/sshd_config
fi

#########################################################################################################################################

# 5.2.11 Ensure only approved MAC algorithms are used (Scored)

echo "[i] Ensuring only approved MAC algorithms are used"

if grep -q "^MACs" /etc/ssh/sshd_config; then 
	sed -i 's/^MACs.*/MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com/' /etc/ssh/sshd_config
else
    echo "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com" >> /etc/ssh/sshd_config
fi

#########################################################################################################################################

# 5.2.12 Ensure SSH Idle Timeout Interval is configured (Scored)

echo "[i] Configuring the SSH Idle Timeout Interval"

if grep -q "^ClientAliveInterval" /etc/ssh/sshd_config; then 
	sed -i 's/^ClientAliveInterval.*/ClientAliveInterval 300/' /etc/ssh/sshd_config
else
    echo "ClientAliveInterval 300" >> /etc/ssh/sshd_config
fi

if grep -q "^ClientAliveCountMax" /etc/ssh/sshd_config; then 
	sed -i 's/^ClientAliveCountMax.*/ClientAliveCountMax 0/' /etc/ssh/sshd_config
else
    echo "ClientAliveCountMax 0" >> /etc/ssh/sshd_config
fi

#########################################################################################################################################

# 5.2.13 Ensure SSH LoginGraceTime is set to one minute or less (Scored)

echo "[i] Setting SSH LoginGraceTime to 1 minute"

if grep -q "^LoginGraceTime" /etc/ssh/sshd_config; then 
	sed -i 's/^LoginGraceTime.*/LoginGraceTime 60/' /etc/ssh/sshd_config
else
    echo "LoginGraceTime 60" >> /etc/ssh/sshd_config
fi

#########################################################################################################################################

# 5.2.14 Ensure SSH access is limited (Scored)

# This will need to be manually set by the system administrator as it will be unique per organisation/system

#########################################################################################################################################

# 5.2.15 Ensure SSH warning banner is configured (Scored)

echo "[i] Setting SSH warning banner"

if grep -q "^Banner" /etc/ssh/sshd_config; then 
	sed -i 's/^Banner.*/Banner /etc/issue.net/' /etc/ssh/sshd_config
else
    echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
fi

#########################################################################################################################################

# 5.3.1 Ensure password creation requirements are configured (Scored)

echo "[i] Installing the Privileged Access Management Password Quality module"

apt install -y libpam-pwquality

echo "[i] Setting password policies to align with CIS guidance"
echo "[i] If you have different password policy requirements, you will need to set these yourself"

if grep -q "pam_pwquality.so" /etc/pam.d/common-password; then 
	sed -i 's/.*pam_pwquality.so.*/password requisite pam_pwquality.so retry=3/' /etc/pam.d/common-password
else
    echo "password requisite pam_pwquality.so retry=3" >> /etc/pam.d/common-password
fi

if grep -q "^minlen" /etc/security/pwquality.conf; then 
	sed -i 's/^minlen.*/minlen = 14/' /etc/security/pwquality.conf
else
    echo "minlen = 14" >> /etc/security/pwquality.conf
fi

if grep -q "^dcredit" /etc/security/pwquality.conf; then 
	sed -i 's/^dcredit.*/dcredit = -1/' /etc/security/pwquality.conf
else
    echo "dcredit = -1" >> /etc/security/pwquality.conf
fi

if grep -q "^ucredit" /etc/security/pwquality.conf; then 
	sed -i 's/^ucredit.*/ucredit = -1/' /etc/security/pwquality.conf
else
    echo "ucredit = -1" >> /etc/security/pwquality.conf
fi

if grep -q "^ocredit" /etc/security/pwquality.conf; then 
	sed -i 's/^ocredit.*/ocredit = -1/' /etc/security/pwquality.conf
else
    echo "ocredit = -1" >> /etc/security/pwquality.conf
fi

if grep -q "^lcredit" /etc/security/pwquality.conf; then 
	sed -i 's/^lcredit.*/lcredit = -1/' /etc/security/pwquality.conf
else
    echo "lcredit = -1" >> /etc/security/pwquality.conf
fi

#########################################################################################################################################

# 5.3.2 Ensure lockout for failed password attempts is configured (Scored)

echo "[i] Configuring lockout for failed password attempts to 5"

if grep -q "pam_tally2.so" /etc/pam.d/common-auth; then 
	sed -i 's/.*pam_tally2.so.*/auth required pam_tally2.so onerr=fail audit silent deny=5 unlock_time=900/' /etc/pam.d/common-auth
else
    echo "auth required pam_tally2.so onerr=fail audit silent deny=5 unlock_time=900" >> /etc/pam.d/common-auth
fi

#########################################################################################################################################

# 5.3.3 Ensure password reuse is limited (Scored)

echo "[i] Limiting password reuse to the last 5 passwords"

if grep -q "pam_pwhistory.so" /etc/pam.d/common-password; then 
	sed -i 's/.*pam_pwhistory.so.*/password required pam_pwhistory.so remember=5/' /etc/pam.d/common-password
else
    echo "password required pam_pwhistory.so remember=5" >> /etc/pam.d/common-password
fi

#########################################################################################################################################

# 5.3.4 Ensure password hashing algorithm is SHA-512 (Scored)

echo "[i] Setting the password hashing algorithm to SHA-512"

if grep -q "pam_unix.so" /etc/pam.d/common-password; then 
	sed -i 's/.*pam_unix.so.*/password [success=1 default=ignore] pam_unix.so sha512/' /etc/pam.d/common-password
else
    echo "password [success=1 default=ignore] pam_unix.so sha512" >> /etc/pam.d/common-password
fi

#########################################################################################################################################

# 5.4.1.1 Ensure password expiration is 365 days or less (Scored)

echo "[i] Setting password expiry at 365 days"

if grep -q "PASS_MAX_DAYS" /etc/login.defs; then
	sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 365/' /etc/login.defs
else
	echo "PASS_MAX_DAYS 90" >> /etc/login.defs
fi

#########################################################################################################################################

# 5.4.1.2 Ensure minimum days between password changes is 7 or more (Scored)

echo "[i] Setting the minimum days between password changes to 7"

if grep -q "PASS_MIN_DAYS" /etc/login.defs; then
	sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS 7/' /etc/login.defs
else
	echo "PASS_MIN_DAYS 7" >> /etc/login.defs
fi

#########################################################################################################################################

# 5.4.1.3 Ensure password expiration warning days is 7 or more (Scored)

echo "[i] Setting password expiration warning to 7 days"

if grep -q "PASS_WARN_AGE" /etc/login.defs; then
	sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE 7/' /etc/login.defs
else
	echo "PASS_WARN_AGE 7" >> /etc/login.defs
fi

#########################################################################################################################################

# 5.4.1.4 Ensure inactive password lock is 30 days or less (Scored)

echo "[i] Locking passwords after 30 days of inactivity"

useradd -D -f 30

#########################################################################################################################################

# 5.4.1.5 Ensure all users last password change date is in the past (Scored)

# This is a manual task.  Run the following commands and confirm for each user:

# cat/etc/shadow | cut -d: -f1
# <list of users>
# chage --list <user>
# Last Change			: <date>

#########################################################################################################################################

# 5.4.2 Ensure system accounts are non-login (Scored)

# This is a manual task.

# Run the following audit task to identify users which have interactive login privs which shouldn't:

# egrep -v "^\+" /etc/passwd | awk -F: '($1!="root" && $1!="sync" && $1!="shutdown" && $1!="halt" && $3<1000 && $7!="/usr/sbin/nologin" && $7!="/bin/false") {print}'

# for user in `awk -F: '($1!="root" && $3 < 1000) {print $1 }' /etc/passwd`; do passwd -S $user | awk -F ' ' '($2!="L") {print $1}'; done

# To remediate, set the shell for all necessary accounts identified by the audit script to /usr/sbin/nologin by running the following command:

# usermod -s /usr/sbin/nologin <user>
# passwd -l <user>

#########################################################################################################################################

# 5.4.3 Ensure default group for the root account is GID 0 (Scored)

echo "[i] Setting the default group for root to GID 0"

usermod -g 0 root

#########################################################################################################################################

# 5.4.4 Ensure default user umask is 027 or more restrictive (Scored)

echo "[i] Setting default user umask to 027"

umask 027

#########################################################################################################################################

# 5.6 Ensure access to the su command is restricted (Scored)

echo "[i] Restricting access to the su command"

if grep -q "pam_wheel.so" /etc/pam.d/su; then
	sed -i 's/.*pam_wheel.so.*/auth required pam_wheel.so/' /etc/pam.d/su
else
	echo "auth required pam_wheel.so" >> /etc/pam.d/su
fi

# An administrator will need to create a comma separated list of users in the sudo statement in the /etc/group file:
# sudo:x:10:root,<user list>

#########################################################################################################################################

# 6.1.2 Ensure permissions on /etc/passwd are configured (Scored)

echo "[i] Setting correct permissions on /etc/passwd"

chown root:root /etc/passwd
chmod 644 /etc/passwd

#########################################################################################################################################

# 6.1.3 Ensure permissions on /etc/shadow are configured (Scored)

echo "[i] Setting correct permissions on /etc/shadow"

chown root:shadow /etc/shadow
chmod o-rwx,g-wx /etc/shadow

#########################################################################################################################################

# 6.1.4 Ensure permissions on /etc/group are configured (Scored)

echo "[i] Setting correct permissions on /etc/group"

chown root:root /etc/group
chmod 644 /etc/group

#########################################################################################################################################

# 6.1.5 Ensure permissions on /etc/gshadow are configured (Scored)

echo "[i] Setting correct permissions on /etc/gshadow"

chown root:shadow /etc/gshadow
chmod o-rwx,g-rw /etc/gshadow

#########################################################################################################################################

# 6.1.6 Ensure permission on /etc/passwd- are configured (Scored)

echo "[i] Setting correct permissions on /etc/passwd-"

chown root:root /etc/passwd-
chmod u-x,go-wx /etc/passwd-

#########################################################################################################################################

# 6.1.7 Ensure permissions on /etc/shadow- are configured (Scored)

echo "[i] Setting correct permissions on /etc/shadow-"

chown root:shadow /etc/shadow-
chmod o-rwx,g-rw /etc/shadow-

#########################################################################################################################################

# 6.1.8 Ensure permissions on /etc/group- are configured (Scored)

echo "[i] Setting correct permissions on /etc/group-"

chown root:root /etc/group-
chmod u-x,go-wx /etc/group-

#########################################################################################################################################

# 6.1.9 Ensure permissions on /etc/gshadow- are configured (Scored)

echo "[i] Setting correct permissions on /etc/gshadow-"

chown root:shadow /etc/gshadow-
chmod o-rwx,g-rw /etc/gshadow-

#########################################################################################################################################

# 1.3.1 Ensure AIDE is installed
# Added to the end because it goes a bit weird if run after 1.2

echo "[i] Installing AIDE"

apt-get install --assume-yes aide aide-common && aideinit &

echo "[i] Generating AIDE config file"

update-aide.conf
cp /var/lib/aide/aide.conf.autogenerated /etc/aide/aide.conf

echo "[i] Adding necessary config items to the AIDE config file"

LINESAIDE=( "!/var/lib/lxcfs" "!/var/lib/private/systemd" "!/var/log/journal" )
AIDECONFFILE=/etc/aide/aide.conf

for current_line in "${LINESAIDE[@]}"
do
    grep -F "$current_line" "$AIDECONFFILE" || echo "$current_line" | tee -a "$AIDECONFFILE" > /dev/null
done

#########################################################################################################################################

# 1.3.2 Ensure filesystem integrity is regularly checked (Scored)
# as above

echo "[i] Creating a cron job to regularly check filesystem integrity using AIDE"

LINEAIDECRON="0 5 * * * /usr/bin/aide.wrapper --config /etc/aide/aide.conf --check"
AIDECRONFILE=/home/tmp.cron

crontab -l -u root 2>/dev/null

if [ $? -eq 0 ]
then
    crontab -u root -l > $AIDECRONFILE
else
    touch $AIDECRONFILE
fi

grep -qF "$LINEAIDECRON" "$AIDECRONFILE" || echo "$LINEAIDECRON" | tee -a "$AIDECRONFILE" > /dev/null

crontab -u root $AIDECRONFILE

rm $AIDECRONFILE

# Removing any redundant packages

apt autoremove

# Rebooting system to ensure all changes take effect

read -r -p "[i] System will now reboot to ensure all changes take effect. Press ENTER to continue..."

reboot
