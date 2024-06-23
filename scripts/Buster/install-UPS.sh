#!/bin/sh
##################################################################
# HiPi.io UPS hat installation script
# https://github.com/hipi-io/ups-hat
##################################################################

# Install git onto your pi
sudo apt update; sudo apt install git -y

# Clone the shell script from the HiPi.io repository
git clone https://github.com/hipi-io/ups-hat.git
#git clone https://github.com/Martin-HiPi/ups-hat.git

# Navigate into the UPS script folder
cd ups-hat/scripts

# Stop previous instance, if any
sudo systemctl stop ups

# copy the script to the init.d directory to run the script on startup
sudo cp -v ups.sh /etc/init.d/ups.sh

# Make the script executable
sudo chmod -v +x /etc/init.d/ups.sh

# update the rc file
sudo update-rc.d ups.sh defaults

#echo "Starting the service..."
#sudo systemctl start ups
#echo "Service active!"
echo "*** Reboot to activate the service! ***"
