#!/bin/bash
##################################################################
# HiPi.io UPS hat installation script for systemd
# https://github.com/hipi-io/ups-hat
##################################################################

# Install git onto your pi
sudo apt update; sudo apt install git gpiod -y

# Clone the shell script from the HiPi-io ups-hat repository
git clone https://github.com/hipi-io/ups-hat.git  # Production repo
#git clone https://github.com/Martin-HiPi/ups-hat.git  # Staging repo

# Navigate into the UPS script folder
cd ups-hat

# Make the service script executable
sudo chmod -v +x scripts/gpiod/ups-gpiod.sh

# Stop and disable the existing service
sudo systemctl disable ups hipi-io-ups-hat.service
sudo systemctl stop ups hipi-io-ups-hat.service

# Remove previous SysV copies of the service
if [ -e /etc/init.d/ups.sh ]
then 
	echo "Removing SystemV service..."
	sudo killall "ups.sh"
	sudo rm -v /etc/init.d/ups.sh
	echo
	echo "*** REBOOT RECOMMENDED!!! ***"
	echo
fi

# copy the hipi-io-ups-hat.service unit file to the /etc/systemd/system directory to run the script on startup
# Should we use /usr/local/lib/systemd/system, "for use by the system administrator when installing software locally"?
sudo cp -v systemd/hipi-io-ups-hat.service /etc/systemd/system/hipi-io-ups-hat.service
sudo chown -v root:root /etc/systemd/system/hipi-io-ups-hat.service

# copy the UPS hat script to /usr/local/sbin (Tertiary hierarchy for local data, specific to this host.)
sudo cp -v scripts/gpiod/ups-gpiod.sh /usr/local/sbin/hipi-io-ups-hat-service
sudo chown -v root:root /usr/local/sbin/hipi-io-ups-hat-service

# reload daemons
sudo systemctl daemon-reload

echo "Starting UPS hat service..."
sudo systemctl enable hipi-io-ups-hat.service
sudo systemctl start hipi-io-ups-hat.service

echo "Service hipi-io-ups-hat.service should be active!"
#ps -aux | grep "hipi-io-ups-hat-service"
sudo systemctl status hipi-io-ups-hat.service
