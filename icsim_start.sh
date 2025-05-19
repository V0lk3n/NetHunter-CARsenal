#!/system/bin/sh

RANDOMIZE="$1"

CAN_IFACE="$2"

export DISPLAY=:1

echo -e "Starting ICSim... Please wait.\n"

# launch virtual display
Xvfb :1 -screen 0 692x350x16 > /dev/null 2>&1 &
echo "✅ Virtual Display Started!"

# launch window manager
sleep 5
fluxbox > /dev/null 2>&1 &
echo "✅ Window manager Started!"

# launch VNC Server
sleep 2
x11vnc -display :1 -nopw -forever -bg -rfbport 5900 > /dev/null 2>&1
echo "✅ VNC Server Started!"

cd /opt/car_hacking/ICSim/builddir
./icsim "$RANDOMIZE" "$CAN_IFACE" > /dev/null 2>&1 &
echo "✅ ICSim running..."

# run noVNC proxy
cd /opt/noVNC
./utils/novnc_proxy --vnc localhost:5900 --listen 6080 > /dev/null 2>&1 &
echo "✅ noVNC is running! Go back to ICSim and refresh display!"
