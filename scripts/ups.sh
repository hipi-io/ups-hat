#!/bin/bash
##################################################################
# HiPi.io UPS hat service script
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

gpio_reset_sysfs() {
	### Reset needed GPIOs to unconfigured state
	# Default state is input, pull-down
	# NOTE: SysFS has no method to handle Pull-up/downs!!!
	if [ -e /sys/class/gpio/gpio17 ]; then echo 17 > /sys/class/gpio/unexport; fi
	if [ -e /sys/class/gpio/gpio18 ]; then echo 18 > /sys/class/gpio/unexport; fi
	if [ -e /sys/class/gpio/gpio27 ]; then echo 27 > /sys/class/gpio/unexport; fi
}

gpio_reset_py() {
	# Using a RPi.GPIO Python script allows pull-up/down control
	# Installed by default with Raspberry Pi OS
	/usr/local/sbin/hipi-io-ups-hat-gpio-reset;
}

gpio_set_sysfs() {
	### Configure the needed GPIO
	# NOTE: SysFS has no method to handle Pull-up/downs!!!
	#
	# GPIO17 (input) used to read current power status.
	# 0 - normal (or battery power switched on manually).
	# 1 - power fault, switched to battery.
	echo 17 > /sys/class/gpio/export;
	echo in > /sys/class/gpio/gpio17/direction;

	# GPIO27 (input) used to indicate that UPS is online
	# 1Hz = normal
	echo 27 > /sys/class/gpio/export;
	echo in > /sys/class/gpio/gpio27/direction;

	# GPIO18 used to inform UPS that Pi is still working.
	# After power-off, this pin returns to Hi-Z state (read as high by hat).
	# Returning to hi-Z/high starts a 10-seconds timer to power disconnect.
	echo 18 > /sys/class/gpio/export;
	echo out > /sys/class/gpio/gpio18/direction;
	echo 0 > /sys/class/gpio/gpio18/value;
}

gpio_set_py() {
	# GPIO27 (input) used to indicate that UPS is online
	# 1Hz = normal
	#echo 27 > /sys/class/gpio/export;
	#echo in > /sys/class/gpio/gpio27/direction;

	# Using a RPi.GPIO Python script allows pull-up/down control
	# Installed by default with Raspberry Pi OS
	/usr/local/sbin/hipi-io-ups-hat-gpio-set;
}

main_loop() {
	power_timer=0;
	inval_power="0";

	ups_online1="0";
	ups_online2="0";
	ups_online_timer="0";

	while true
	do
		# read GPIO27 pin value
		# normally, UPS toggles this pin every 0.5s
		ups_online1=$(cat /sys/class/gpio/gpio27/value);

		sleep 0.1;

		ups_online2=$(cat /sys/class/gpio/gpio27/value);

		ups_online_timer=$((ups_online_timer+1));

		# toggled?
		if  (( "$ups_online1" != "$ups_online2" )); then
			ups_online_timer=0;
		fi

		# reset all timers if ups is offline longer than 3s (no toggling detected)
		if (("$ups_online_timer" > 30));
		then
			echo "$ups_online_timer";

			ups_online_timer=30;
			power_timer=0;
			inval_power=0;
			#echo "UPS offline. Exit";
			#exit;
		fi

		# read GPIO17 pin value
		inval_power=$(cat /sys/class/gpio/gpio17/value);

		#echo "inval_power= "$inval_power;

		if (( "$inval_power" == 1 )); then
			power_timer=$((power_timer+1));
		else
			power_timer=0;
		fi

		#echo "power_timer=     "$power_timer;

		# If power was not restored in 60 seconds
		if (( "$power_timer" == 600 )); then
			echo "Powering off..."
			sleep 2;
			systemctl poweroff; #turn off
			exit;
		fi

		if [ -e /tmp/ups-hat.exit ]
		then
			#break
			echo "Shutting down service..."
			gpio_reset_py;
			echo
			echo "*** UPS service stopped ***"
			echo
			touch /tmp/ups-hat.quit;
			#gpio_reset_py;
			rm -v /tmp/ups-hat.exit;

			exit;

		fi

	done

}

main() {
	gpio_reset_py;
	gpio_reset_sysfs;
	if [ -e /tmp/ups-hat.exit ]; then rm -v /tmp/ups-hat.exit; fi
	if [ -e /tmp/ups-hat.quit ]; then rm -v /tmp/ups-hat.quit; fi
	gpio_set_sysfs;
	gpio_set_py;
	main_loop;
}

main
