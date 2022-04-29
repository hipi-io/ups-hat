# One-liner installation with defaults:
  `curl https://raw.githubusercontent.com/Martin-HiPi/ups-hat/main/scripts/install-UPS.sh | bash`

---
# Manual installation

## change the permissions for the script 

  `sudo chmod +x ups.sh`

## copy the script to the init.d directory to run the script on startup

  `sudo cp ups.sh /etc/init.d/`

## update the rc file

  `sudo update-rc.d ups.sh defaults`
