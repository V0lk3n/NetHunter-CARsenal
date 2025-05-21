#!/system/bin/sh

RANDOMIZE="$1"

CAN_IFACE="$2"

echo "Starting ICSim... Please wait.\n"

# launch virtual display
Xvfb :1 -screen 0 692x350x16 > /dev/null 2>&1 &
echo "✅ ICSim Virtual Display Started!"
Xvfb :2 -screen 0 835x608x16 > /dev/null 2>&1 &
echo "✅ Controls Virtual Display Started!"

# launch window manager
sleep 5
DISPLAY=:1 fluxbox > /dev/null 2>&1 &
echo "✅ ICSim Window manager Started!"
DISPLAY=:2 fluxbox > /dev/null 2>&1 &
echo "✅ Controls Window manager Started!"

# launch VNC Server
sleep 2
DISPLAY=:1 x11vnc -display :1 -nopw -forever -bg -rfbport 5900 > /dev/null 2>&1
echo "✅ ICSim VNC Server Started!"
DISPLAY=:2 x11vnc -display :2 -nopw -forever -bg -rfbport 5901 > /dev/null 2>&1
echo "✅ Controls VNC Server Started!"

# launch ICSim
cd /opt/car_hacking/ICSim/builddir

if [ "$RANDOMIZE" = " -r" ]; then
    # Capture seed by running ICSim with -r and parsing output
    SEED=$(DISPLAY=:1 ./icsim "$RANDOMIZE" "$CAN_IFACE" 2>&1 | tee /tmp/icsim_output.log | grep "Seed:" | awk '{print $2}')
    
    echo "✅ ICSim Started with seed: $SEED"
    
    # Now run ICSim again in the background with the same seed
    DISPLAY=:1 ./icsim "$SEED" "$CAN_IFACE" > /dev/null 2>&1 &
else
    DISPLAY=:1 ./icsim "$RANDOMIZE" "$CAN_IFACE" > /dev/null 2>&1 &
    echo "✅ ICSim Started without seed!"
fi

# Run controls with the correct seed
if [ -n "$SEED" ]; then
    DISPLAY=:2 ./controls "$SEED" "$CAN_IFACE" > /dev/null 2>&1 &
else
    DISPLAY=:2 ./controls "$CAN_IFACE" > /dev/null 2>&1 &
fi

echo "✅ Controls Started!"

# run noVNC proxy
cd /opt/noVNC
./utils/novnc_proxy --vnc localhost:5900 --listen 6080 > /dev/null 2>&1 &
echo "✅ ICSim noVNC Started!"
./utils/novnc_proxy --vnc localhost:5901 --listen 6081 > /dev/null 2>&1 &
echo "✅ Controls noVNC Started!"

echo "\nICSim and Controls is running! Go back to CARsenal ICSim tab and refresh display!"
