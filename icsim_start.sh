#!/system/bin/sh

CAN_IFACE="$1"
LEVEL="$2"
SEED="1747857648"

echo "Starting ICSim... Please wait.\n"

# ICSim
# launch virtual display
export DISPLAY=:1
Xvfb :1 -screen 0 692x350x16 > /dev/null 2>&1 &
echo "✅ ICSim Virtual Display Started!"
# Launch window manager
sleep 5
fluxbox > /dev/null 2>&1 &
echo "✅ ICSim Window manager Started!"
# launch VNC Server
sleep 2
x11vnc -display :1 -nopw -forever -bg -rfbport 5900 > /dev/null 2>&1
echo "✅ ICSim VNC Server Started!"
# launch ICSim
cd /opt/car_hacking/ICSim/builddir
./icsim -s "$SEED" "$CAN_IFACE" > /dev/null 2>&1 &    
echo "✅ ICSim Started on $CAN_IFACE with seed: $SEED"
# run noVNC proxy
cd /opt/noVNC
./utils/novnc_proxy --vnc localhost:5900 --listen 6080 > /dev/null 2>&1 &
echo "✅ ICSim noVNC Started!"

echo "\nStarting Controls... Please wait.\n"

# Controls
# launch virtual display
export DISPLAY=:2
Xvfb :2 -screen 0 835x608x16 > /dev/null 2>&1 &
echo "✅ Controls Virtual Display Started!"
# launch window manager
sleep 5
fluxbox > /dev/null 2>&1 &
echo "✅ Controls Window manager Started!"
# launch VNC Server
sleep 2
x11vnc -display :2 -nopw -forever -bg -rfbport 5901 > /dev/null 2>&1
echo "✅ Controls VNC Server Started!"
# Run controls with the correct seed
cd /opt/car_hacking/ICSim/builddir
./controls "$CAN_IFACE" -s "$SEED" "$LEVEL" > /dev/null 2>&1 &
echo "✅ Controls Started!"
# run noVNC proxy
cd /opt/noVNC
./utils/novnc_proxy --vnc localhost:5901 --listen 6081 > /dev/null 2>&1 &
echo "✅ Controls noVNC Started!"

echo "\nICSim and Controls is running! Go back to CARsenal ICSim tab and refresh display!"
