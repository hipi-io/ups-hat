#!/bin/sh
##################################################################
# HiPi.io UPS hat installation script
# https://github.com/hipi-io/ups-hat
##################################################################

# Install git onto your pi
sudo apt update; sudo apt install git -y

# Clone the shell script from the Buyapi.ca repository
git clone https://github.com/hipi-io/ups-hat

# Navigate into the UPS script folder
cd ups-hat/scripts

# Make the script executable
sudo chmod -v +x ups.sh

# Stop previous instance, if any
sudo systemctl stop ups

# copy the script to the init.d directory to run the script on startup
sudo cp -v ups.sh /etc/init.d/ups.sh

# update the rc file
sudo update-rc.d ups.sh defaults

echo "Starting the service..."
sudo systemctl start ups
echo "Service active!"
