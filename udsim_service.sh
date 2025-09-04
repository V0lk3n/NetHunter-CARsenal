#!/system/bin/sh

ACTION="$1"

start_udsim() {
    CAN_IFACE="$1"
    LOG_PARAM="$2"
    LOG="$3"
    
    echo "Starting UDSim... Please wait."

    # UDSim
    export DISPLAY=:5
    Xvfb :1 -screen 0 692x350x16 > /dev/null 2>&1 &
    echo "✅ UDSim Virtual Display Started!"
    sleep 5
    fluxbox > /dev/null 2>&1 &
    echo "✅ UDSim Window manager Started!"
    sleep 2
    x11vnc -display :5 -nopw -forever -bg -rfbport 5902 > /dev/null 2>&1
    echo "✅ UDSim VNC Server Started!"
    cd /opt/car_hacking/UDSim/src
    ./udsim -f "$CAN_IFACE" > /dev/null 2>&1 &
    echo "✅ UDSim Started on $CAN_IFACE"
    cd /opt/noVNC
    ./utils/novnc_proxy --vnc localhost:5902 --listen 6082 > /dev/null 2>&1 &
    echo "✅ UDSim noVNC Started!"

    echo "\nUDSim is running! Go back to CARsenal Simulator tab and refresh display!"
}

stop_udsim() {
    echo "Stopping UDSim..."

    pkill -x udsim
    echo "✅ UDSim Stopped!"
    pkill -f "novnc_proxy"
    echo "✅ noVNC Stopped!"
    pkill -f "x11vnc"
    echo "✅ VNC Server Stopped!"
    pkill -f "fluxbox"
    echo "✅ Window manager Stopped!"
    pkill -f "Xvfb :5"
    echo "✅ UDSim Virtual Display Stopped!"

    echo "\n✅ All UDSim-related processes Stopped."
}

# Main Execution Logic
if [ "$ACTION" = "stop" ]; then
    stop_udsim
elif [ -n "$ACTION" ]; then
    start_udsim "$@"
else
    echo "Usage:"
    echo "  $0 <caninterface> [log-param] [log]  # to start UDSim"
    echo "  $0 stop                                  # to stop UDSim"
    exit 1
fi
