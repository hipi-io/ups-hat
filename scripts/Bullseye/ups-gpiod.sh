#!/bin/sh
##################################################################
# HiPi.io UPS hat service script
# for Raspberry Pi OS Bullseye and newer using libgpiod tools
# https://github.com/hipi-io/ups-hat
##################################################################

### BEGIN INIT INFO
# Provides: ups
# Required-Start: $remote_fs
# Required-Stop: $remote_fs
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: UPS-hat Monitor
# Description: Starts the HiPi-io UPS HAT Monitor
### END INIT INFO

# GPIO17 (input) used to read current power status.
# 0 - normal (or battery power switched on manually).
# 1 - power fault, switched to battery.
#echo 17 > /sys/class/gpio/export
#echo in > /sys/class/gpio/gpio17/direction
# use gpioget gpiochip0 17

# GPIO27 (input) used to indicate that UPS is online
#echo 27 > /sys/class/gpio/export
#echo in > /sys/class/gpio/gpio27/direction
# use gpioget gpiochip0 27

# GPIO18 used to inform UPS that Pi is still working. After power-off this pin returns to Hi-Z state.
#echo 18 > /sys/class/gpio/export
#echo out > /sys/class/gpio/gpio18/direction
#echo 0 > /sys/class/gpio/gpio18/value
# use gpioset gpiochip0 GPIO18
gpioset 0 18=0

power_timer=0
inval_power="0"

ups_online1="0"
ups_online2="0"
ups_online_timer="0"

while true
do
	# Read GPIO27 pin value
	# Normally, UPS toggles this pin every 0.5s
	ups_online1=$(gpioget 0 27)

	sleep 0.1

	ups_online2=$(gpioget 0 27)

	ups_online_timer=$((ups_online_timer+1))

	# GPIO27 has toggled?
	if [ "$ups_online1" -ne "$ups_online2" ]; then
		ups_online_timer=0
		toggled="Toggled!"
	else
		toggled=""
	fi

	# Reset all timers if ups is offline longer than 30s (no toggling detected for 300*0.1s)
	if [ "$ups_online_timer" -gt 300 ]
	then
		ups_online_timer=30
		power_timer=0
		inval_power=0
		echo "### UPS offline. Exit"
			gpioset 0 18=1  # Tell UPS hat it is no longer monitored (disables the 10-seconds power disconnect)
		exit
	fi

	# Read GPIO17 pin value (What is the power status?)
	inval_power=$(gpioget 0 17)

	if [ "$inval_power" -eq 1 ]; then
		power_timer=$((power_timer+1))
	else
		power_timer=0
	fi

# To debug, uncomment the next line
#echo "Power="$inval_power", power_timer= "$power_timer", ups_online_timer= "$ups_online_timer", "$ups_online1", "$ups_online2", toggled? "$toggled

	# If power was not restored in 60 seconds (600*0.1s)
	if [ "$power_timer" -eq 600 ]; then
		echo "### Powering off..."
		sleep 2
		systemctl poweroff; # turn off
		exit
	fi
done
