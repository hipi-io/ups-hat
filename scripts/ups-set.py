#!/bin/python
import sys

try:
    import RPi.GPIO as GPIO
except RuntimeError:
    print("Error importing RPi.GPIO!  This is probably because you need superuser privileges.  You can achieve this by using 'sudo' to run your script")
  
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

GPIO.setup(17, GPIO.IN)
GPIO.setup(18, GPIO.OUT, initial=GPIO.LOW)
GPIO.setup(27, GPIO.IN)

#GPIO.cleanup()  # This resets the GPIO to defaults
sys.exit(0)
