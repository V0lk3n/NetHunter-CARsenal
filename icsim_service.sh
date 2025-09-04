#!/system/bin/sh

ACTION="$1"

start_icsim() {
    CAN_IFACE="$1"
    LEVEL_PARAM="$2"
    LEVEL="$3"
    SEED="1747857648"

    echo "Starting ICSim... Please wait."

    # ICSim
    export DISPLAY=:1
    Xvfb :1 -screen 0 692x350x16 > /dev/null 2>&1 &
    echo "✅ ICSim Virtual Display Started!"
    sleep 5
    fluxbox > /dev/null 2>&1 &
    echo "✅ ICSim Window manager Started!"
    sleep 2
    x11vnc -display :1 -nopw -forever -bg -rfbport 5900 > /dev/null 2>&1
    echo "✅ ICSim VNC Server Started!"
    cd /opt/car_hacking/ICSim/builddir
    ./icsim -s "$SEED" "$CAN_IFACE" > /dev/null 2>&1 &
    echo "✅ ICSim Started on $CAN_IFACE with seed: $SEED"
    cd /opt/noVNC
    ./utils/novnc_proxy --vnc localhost:5900 --listen 6080 > /dev/null 2>&1 &
    echo "✅ ICSim noVNC Started!"

    echo "\nStarting Controls... Please wait."

    export DISPLAY=:2
    Xvfb :2 -screen 0 835x608x16 > /dev/null 2>&1 &
    echo "✅ Controls Virtual Display Started!"
    sleep 5
    fluxbox > /dev/null 2>&1 &
    echo "✅ Controls Window manager Started!"
    sleep 2
    x11vnc -display :2 -nopw -forever -bg -rfbport 5901 > /dev/null 2>&1
    echo "✅ Controls VNC Server Started!"
    cd /opt/car_hacking/ICSim/builddir    
    if [ -n "$LEVEL_PARAM" ] && [ -n "$LEVEL" ]; then
        ./controls "$CAN_IFACE" -s "$SEED" "$LEVEL_PARAM" "$LEVEL" > /dev/null 2>&1 &
        echo "✅ Controls Started with $LEVEL_PARAM $LEVEL"
    else
        ./controls "$CAN_IFACE" -s "$SEED" > /dev/null 2>&1 &
        echo "✅ Controls Started without extra params"
    fi
    echo "✅ Controls Started!"
    cd /opt/noVNC
    ./utils/novnc_proxy --vnc localhost:5901 --listen 6081 > /dev/null 2>&1 &
    echo "✅ Controls noVNC Started!"

    echo "\nICSim and Controls is running! Go back to CARsenal ICSim tab and refresh display!"
}

stop_icsim() {
    echo "Stopping ICSim..."

    pkill -x icsim
    echo "✅ ICSim Stopped!"
    pkill -x controls
    echo "✅ Controls Stopped!"
    pkill -f "novnc_proxy"
    echo "✅ noVNC Stopped!"
    pkill -f "x11vnc"
    echo "✅ VNC Server Stopped!"
    pkill -f "fluxbox"
    echo "✅ Window manager Stopped!"
    pkill -f "Xvfb :1"
    echo "✅ ICSim Virtual Display Stopped!"
    pkill -f "Xvfb :2"
    echo "✅ Controls Virtual Display Stopped!"

    echo "\n✅ All ICSim-related processes Stopped."
}

# Main Execution Logic
if [ "$ACTION" = "stop" ]; then
    stop_icsim
elif [ -n "$ACTION" ]; then
    start_icsim "$@"
else
    echo "Usage:"
    echo "  $0 <caninterface> [level-param] [level]  # to start ICSim"
    echo "  $0 stop                                  # to stop ICSim"
    exit 1
fi
