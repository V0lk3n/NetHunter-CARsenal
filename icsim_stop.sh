#!/system/bin/sh

# Kill ICSim
pkill -f "/opt/car_hacking/ICSim/builddir/icsim"

# Kill noVNC proxy
pkill -f "novnc_proxy"

# Kill x11vnc
pkill -f "x11vnc"

# Kill fluxbox
pkill -f "fluxbox"

# Kill Xvfb
pkill -f "Xvfb :1"

echo "All ICSim-related processes stopped."
