#!/usr/bin/env bash

#Creating user and grant access for execute commands, adding ssh-key
useradd -m -d /home/ansible ansible
mkdir /home/ansible/.ssh
chown -R ansible:ansible /home/ansible/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCY4cNhoi5aiJgdVJTqsQl7wHm0KEKq67B0x6aj/Y62zXV0gR5t14xNHjW5YFtn5Nzd8vufSnjyu3oZPbjw1cK/c85RlrbJUq71lK7HIfmRx4HGgv+dcYaQfPwx1zVPou93YseWFfRImZzd/WhXi/ol6/WKgUmo/1DUw14W/UwTEWseFrcwwozWWKaHxdUU850hQ01ZQVm5GCpkWzfVrP2yESFHmmYD6ff5NkE+XjPd/9ghLfv20UnRutn3EbEEgmOzaeQ14epUMKujeQ57ww7YmWbageOfzL2h00AD8s55CwUDu+5g5tf5F/j0IydcZul7qUk8bXYDWj4xjilXaXcP root@mgmt" >> /home/ansible/.ssh/authorized_keys
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
