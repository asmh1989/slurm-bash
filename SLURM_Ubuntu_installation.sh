################################################################################
# Copyright (C) 2019-2022 NI SP GmbH
# All Rights Reserved
#
# info@ni-sp.com / www.ni-sp.com
#
# We provide the information on an as is basis. 
# We provide no warranties, express or implied, related to the
# accuracy, completeness, timeliness, useability, and/or merchantability
# of the data and are not liable for any loss, damage, claim, liability,
# expense, or penalty, or for any direct, indirect, special, secondary,
# incidental, consequential, or exemplary damages or lost profit
# deriving from the use or misuse of this information.
################################################################################
# Version v1.2
#
# SLURM 20.11.3 Build and Installation script for Ubuntu 18.04 and 20.04
# 
# https://slurm.schedmd.com/quickstart_admin.html

# prepare system
sudo apt update
sleep 2
# sudo apt upgrade -y

# SLURM accounting support
sudo apt install mariadb-server libmariadbclient-dev libmariadb-dev -y

export MUNGEUSER=966
sudo groupadd -g $MUNGEUSER munge
sudo useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge  -s /sbin/nologin munge
export SLURMUSER=967
sudo groupadd -g $SLURMUSER slurm
sudo useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm  -s /bin/bash slurm

# install munge
sudo apt install munge libmunge-dev libmunge2 rng-tools -y
sudo rngd -r /dev/urandom

#sudo /usr/sbin/create-munge-key -r -f

#sudo sh -c  "dd if=/dev/urandom bs=1 count=1024 > /etc/munge/munge.key"
#sudo chown munge: /etc/munge/munge.key
#sudo chmod 400 /etc/munge/munge.key

sudo systemctl enable munge
#sudo systemctl start munge

# prepare to build and install SLURM
sudo apt install python3 gcc openssl numactl hwloc lua5.3 man2html \
     make ruby ruby-dev libmunge-dev libpam0g-dev -y
#sudo /usr/bin/gem install fpm

mkdir slurm-tmp
cd slurm-tmp
if [ "$VER" == "" ]; then
    export VER=20.02.6    # latest 20.02.XX version
    export VER=21.08.6
fi
# https://download.schedmd.com/slurm/slurm-20.02.3.tar.bz2
wget https://download.schedmd.com/slurm/slurm-$VER.tar.bz2

tar jxvf slurm-$VER.tar.bz2
cd slurm-$VER
# ./configure
./configure --prefix=/usr --sysconfdir=/etc/slurm --enable-pam --with-pam_dir=/lib/x86_64-linux-gnu/security/ --without-shared-libslurm
make -j8
make contrib -j8 
sudo make install -j8
cd ..
# fpm -s dir -t deb -v 1.0 -n slurm-$VER --prefix=/usr -C /tmp/slurm-build .
#echo Creating deb package for SLURM $VER
#fpm -s dir -t deb -v 1.0 -n slurm-$VER --prefix=/usr -C /usr .
# on compute nodes
# dpkg -i slurm-$VER_1.0_amd64.deb

# clean up
# rm -rf slurm-$VER

# mkdir -p /etc/slurm /etc/slurm/prolog.d /etc/slurm/epilog.d /var/spool/slurm/ctld /var/spool/slurm/d /var/log/slurm
# chown slurm /var/spool/slurm/ctld /var/spool/slurm/d /var/log/slurm

sudo mkdir /var/spool/slurm
sudo chown slurm:slurm /var/spool/slurm
sudo chmod 755 /var/spool/slurm
sudo mkdir /var/spool/slurm/slurmctld
sudo chown slurm:slurm /var/spool/slurm/slurmctld
sudo chmod 755 /var/spool/slurm/slurmctld
sudo mkdir /var/spool/slurm/cluster_state
sudo chown slurm:slurm /var/spool/slurm/cluster_state
sudo touch /var/log/slurmctld.log
sudo chown slurm:slurm /var/log/slurmctld.log
sudo touch /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log
sudo chown slurm: /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log
# sudo touch /var/run/slurmctld.pid /var/run/slurmd.pid
# sudo chown slurm:slurm /var/run/slurmctld.pid /var/run/slurmd.pid
sudo mkdir -p /etc/slurm/prolog.d /etc/slurm/epilog.d 

# rm slurm-$VER.tar.bz2
# cd ..
# rmdir slurm-tmp 

# get perl-Switch
# sudo yum install cpan -y 

# create the SLURM default configuration with
# compute nodes called "NodeName=linux[1-32]"
# in a cluster called "cluster"
# and a partition name called "test"
# Feel free to adapt to your needs

# on compute nodes 
sudo systemctl daemon-reload
sudo systemctl enable slurmd.service
#sudo systemctl start slurmd.service

# firewall will block connections between nodes so in case of cluster
# with multiple nodes adapt the firewall on the compute nodes 
#
# sudo systemctl stop firewalld
# sudo systemctl disable firewalld

# on the master node
#sudo firewall-cmd --permanent --zone=public --add-port=6817/udp
#sudo firewall-cmd --permanent --zone=public --add-port=6817/tcp
#sudo firewall-cmd --permanent --zone=public --add-port=6818/tcp
#sudo firewall-cmd --permanent --zone=public --add-port=6818/tcp
#sudo firewall-cmd --permanent --zone=public --add-port=7321/tcp
#sudo firewall-cmd --permanent --zone=public --add-port=7321/tcp
#sudo firewall-cmd --reload

# sync clock on master and every compute node 
#sudo yum install ntp -y
#sudo chkconfig ntpd on
#sudo ntpdate pool.ntp.org
#sudo systemctl start ntpd


#echo Sleep for a few seconds for slurmd to come up ...
#sleep 2

# checking 
# sudo systemctl status slurmd.service
# sudo journalctl -xe

# if you experience an error with starting up slurmd.service
# like "fatal: Incorrect permissions on state save loc: /var/spool"
# then you might want to adapt with chmod 777 /var/spool

# more checking 
# sudo slurmd -Dvvv -N YOUR_HOSTNAME 
# sudo slurmctld -D vvvvvvvv
# or tracing with sudo strace slurmctld -D vvvvvvvv

# echo Compute node bugs: tail /var/log/slurmd.log
# echo Server node bugs: tail /var/log/slurmctld.log



