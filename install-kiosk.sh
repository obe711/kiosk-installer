#!/bin/sh

KIOSK_URL='http://nexus-dashboard.local'
KIOSK_USER='kiosk'

sudo apt update
sudo apt upgrade -y

sudo apt install chromium-browser sed xdotool lightdm openbox xorg unclutter x11-xserver-utils -y

# Create kiosk user
sudo useradd -m "$KIOSK_USER"

KIOSK_USER_DIR="/home/${KIOSK_USER}"

# 2. Create a minimal xinitrc
sudo tee "${KIOSK_USER_DIR}"/.xinitrc << EOF
#!/bin/bash

# Disable screen blanking and power management
xset s off
xset s noblank
xset -dpms

# Hide mouse cursor
unclutter -idle 0.1 -root &

# Start Chromium
exec chromium-browser --kiosk --start-fullscreen --hide-scrollbars --disable-infobars \
  --noerrdialogs --disable-translate --no-first-run --fast --fast-start \
  --disable-features=TranslateUI --disable-session-crashed-bubble \
  --disk-cache-dir=/dev/null --password-store=basic \
  "${KIOSK_URL}"
EOF


# 3. Create a minimal X session
sudo tee /usr/share/xsessions/kiosk.desktop << 'EOF'
[Desktop Entry]
Name=Kiosk
Comment=Kiosk Mode
Exec=/usr/bin/openbox-session
Type=Application
EOF

# 4. Configure LightDM for automatic login
sudo tee /etc/lightdm/lightdm.conf << EOF
[SeatDefaults]
autologin-user=${KIOSK_USER}
autologin-user-timeout=0
user-session=kiosk
xserver-command=X -nocursor
EOF

# 5. Create Openbox autostart
sudo mkdir -p "${KIOSK_USER_DIR}"/.config/openbox
sudo tee "${KIOSK_USER_DIR}"/.config/openbox/autostart << EOF
# Start the browser directly
chromium-browser --kiosk --start-fullscreen --hide-scrollbars --disable-infobars \
  --noerrdialogs --disable-translate --no-first-run --fast --fast-start \
  --disable-features=TranslateUI --disable-session-crashed-bubble \
  --disk-cache-dir=/dev/null --password-store=basic \
  "${KIOSK_URL}" &
EOF

sudo chmod +x "${KIOSK_USER_DIR}"/.config/openbox/autostart

# 6. Create minimal Openbox configuration
sudo mkdir -p "${KIOSK_USER_DIR}"/.config/openbox
sudo tee "${KIOSK_USER_DIR}"/.config/openbox/rc.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config>
  <applications>
    <application class="*">
      <decor>no</decor>
      <focus>yes</focus>
      <fullscreen>yes</fullscreen>
    </application>
  </applications>
</openbox_config>
EOF

sudo systemctl enable lightdm

# sudo reboot now