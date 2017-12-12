#!/usr/bin/env bash

#Creating user and grant access for execute commands, adding ssh-key
useradd -m -d /home/ansible ansible
mkdir /home/ansible/.ssh
chown -R ansible:ansible /home/ansible/.ssh
echo "your ansible user of local machine" >> /home/ansible/.ssh/authorized_keys
chmod 744 /home/ansible/.ssh/authorized_keys

cat <<EOT >> /etc/sudoers
ansible ALL=(ALL:ALL) NOPASSWD:/usr/bin/mysqldump,/usr/bin/rsync
Defaults!/usr/bin/rsync !requiretty
Defaults:ansible !requiretty
EOT

osname=`lsb_release -i | awk '{print tolower($3)}'`
rsync_vers=`rsync --version | awk 'NR==1{print $6}'`

#Installing python-mysql
function InstallPythonMysql () {
	if [[ ${osname} == "ubuntu" ]] || [[ ${osname} == "debian" ]] || [[ ${osname} == "linuxmint" ]]
	then
		apt-get update
		apt-get install -y python-mysqldb
	elif [[ ${osname} == "centos" ]]
	then
		yum install -y MySQL-python
	fi
}

#Upgrading rsync
function CheckRsyncVersion () {
        if [[ ${osname} == "ubuntu" ]] || [[ ${osname} == "debian" ]] || [[ ${osname} == "linuxmint" ]] && [[ ${rsync_vers} < "31" ]]
        then
		apt-get install -y --only-upgrade rsync
        elif [[ ${osname} == "centos" ]] && [[ ${rsync_vers} < "31" ]]
        then
		wget http://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/r/rsync-3.1.2-2.fc24.x86_64.rpm -d /opt
		rpm -Uvh /opt/rsync-3.1.2-2.fc24.x86_64.rpm
		rm /opt/rsync-3.1.2-2.fc24.x86_64.rpm
	fi
}

InstallPythonMysql
CheckRsyncVersion
