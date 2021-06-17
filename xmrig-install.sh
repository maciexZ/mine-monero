#!/bin/bash
#you must run as privilege user

user=$(id -u)
if [ "$user" -ne 0 ]
  then echo "Please run as root"
  exit
fi

#copy servicefile for future use
cp xmrig.service /etc/systemd/system/

#update & installing a few useful programs
apt update && apt -y upgrade

#this can be skiped 
#apt -y install lshw fail2ban htop

#installing xmrig dependencies
apt -y install build-essential cmake git libhwloc-dev libssl-dev libuv1-dev

#cloning repo and compiling binary
cd /root
git clone https://github.com/xmrig/xmrig.git
cd xmrig
cmake -Bbuild
make -Cbuild -j$(nproc)

#copying binary and config json
cp build/xmrig ~/xmrig
cp src/config.json ~/xmrig

#security issue if you mine on remote machine
#systemctl enable fail2ban
#systemctl start fail2ban

#configuration of xmrig
cd /root/xmrig
sed --in-place "s/$(grep \"url\": config.json)/\"url\":\"de.minexmr.com:443\",/" config.json 
#YOUR monero address, here mined monero goes.
sed --in-place "s/$(grep \"user\": config.json)/\"user\":\"8BVwcvZHJNqfigwzLQG52B4KPrEQVkucA48knrzXEQCbQTNkt6MuFqrNfFY63uBkXASeHyWtnKpwbL1Qv6zkjwNXDKXXew7\",/" config.json 
sed --in-place "s/$(grep \"rig-id\": config.json)/\"rig-id\":\"miner_$(date +%d.%m.%Y)\",/" config.json 
sed --in-place "s/$(grep "\"tls\": false" config.json)/\"tls\": true,/" config.json 

#enable systemd service to keep miner always working
systemctl enable xmrig.service

#starting the miner
systemctl start xmrig.service

exit
