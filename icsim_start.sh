#!/system/bin/sh

CAN_IFACE="$1"

if [ -z "$CAN_IFACE" ]; then
    CAN_IFACE="vcan0"
fi

export DISPLAY=:1

# launch virtual display
Xvfb :1 -screen 0 692x350x16 &

# launch window manager
sleep 5
fluxbox &

# launch VNC Server
sleep 2
x11vnc -display :1 -nopw -forever -bg -rfbport 5900

cd /opt/car_hacking/ICSim/builddir
./icsim "$CAN_IFACE" &

# run noVNC proxy
cd /opt/noVNC
./utils/novnc_proxy --vnc localhost:5900 --listen 6080
