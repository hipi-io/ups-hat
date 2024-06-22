# One-liner installation with defaults (Bullseye and newer):
  `curl https://raw.githubusercontent.com/hipi-io/ups-hat/main/systemd/install-UPS-systemd-Bullseye.sh | bash`

# One-liner installation with defaults (Buster and older):
  `curl https://raw.githubusercontent.com/hipi-io/ups-hat/main/systemd/install-UPS-systemd-Buster.sh | bash`

---
# Manual installation (adapt to the OS you are using)

## change the permissions for the script

  `sudo chmod +x ups.sh`

## copy the script to the init.d directory to run the script on startup

  `sudo cp ups.sh /etc/init.d/`

## update the rc file

  `sudo update-rc.d ups.sh defaults`
