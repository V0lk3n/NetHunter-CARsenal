#!/system/bin/sh

echo "Stopping ICSim...\n"

# Kill ICSim
pkill -f "/opt/car_hacking/ICSim/builddir/icsim"
echo "✅ ICSim Stopped!"

# Kill ICSim
pkill -f "/opt/car_hacking/ICSim/builddir/controls"
echo "✅ Controls Stopped!"

# Kill noVNC proxy
pkill -f "novnc_proxy"
echo "✅ noVNC Stopped!"

# Kill x11vnc
pkill -f "x11vnc"
echo "✅ VNC Server Stopped!"

# Kill fluxbox
pkill -f "fluxbox"
echo "✅ Window manager Stopped!"

# Kill Xvfb ICSim and Controls display
pkill -f "ICSim Xvfb :1"
echo "✅ Virtual Display Stopped!"
pkill -f "Xvfb :2"
echo "✅ Controls Virtual Display Stopped!"

echo "\n✅ All ICSim-related processes Stopped."
