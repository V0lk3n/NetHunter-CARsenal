#!/bin/bash

# --- Utility Functions ---

checkAndInstall() {
    NAME="$1"
    FILE="$2"
    FOLDER="$3"
    INSTALL_COMMAND="$4"

    if [[ -f "$FILE" && -d "$FOLDER" ]]; then
        echo -e "\n✅ $NAME already installed!"
    else
        echo -e "\n📦 Installing $NAME...\n"
        eval "$INSTALL_COMMAND"
    fi
}

checkAndUpdate() {
    NAME="$1"
    FILE="$2"
    FOLDER="$3"
    UPDATE_COMMAND="$4"

    if [[ -f "$FILE" && -d "$FOLDER" ]]; then
        echo -e "\n🔄 $NAME detected! Checking for updates...\n"
        eval "$UPDATE_COMMAND"
    else
        echo -e "⚠️ $NAME not detected! Please run Setup first."
    fi
}

# --- Setup Function ---
setup() {
    echo -ne "\033]0;CARsenal Setup\007"
    clear
    echo -e "\n🔧 Installing Packages...\n"

    sudo apt update

    sudo apt install -y autoconf cmake expect fluxbox git libconfig-dev libsdl2-dev libsdl2-image-dev libsocketcan-dev make maven meson python3-pip python3-venv websockify x11vnc xserver-xephyr xvfb

    gem install serialport

    mkdir -p /opt/car_hacking

    checkAndInstall "Can-Utils" "/usr/bin/cangen" "/opt/car_hacking/can-utils" \
        "cd /opt/car_hacking && sudo git clone https://github.com/v0lk3n/can-utils.git && cd can-utils && sudo make && sudo make install"

    checkAndInstall "Cannelloni" "/usr/local/bin/cannelloni" "/opt/car_hacking/cannelloni" \
        "cd /opt/car_hacking && sudo git clone https://github.com/v0lk3n/cannelloni.git && cd cannelloni && sudo cmake -DCMAKE_BUILD_TYPE=Release . && sudo make && sudo make install"

    checkAndInstall "USB-CAN" "/usr/local/bin/canusb" "/opt/car_hacking/usb-can" \
        "cd /opt/car_hacking && sudo git clone https://github.com/v0lk3n/usb-can.git && cd usb-can && sudo gcc -o canusb canusb.c && sudo cp canusb /usr/local/bin/canusb"

    checkAndInstall "Freediag" "/usr/local/bin/freediag" "/opt/car_hacking/freediag" \
        "cd /opt/car_hacking && sudo git clone https://github.com/v0lk3n/freediag.git && cd freediag && ./build_simple.sh && sudo cp build/scantool/freediag /usr/local/bin/freediag && sudo cp build/scantool/diag_test /usr/local/bin/diag_test"

    checkAndInstall "Socketcand" "/usr/local/sbin/socketcand" "/opt/car_hacking/socketcand" \
        "cd /opt/car_hacking && sudo git clone https://github.com/V0lk3n/socketcand.git && cd socketcand && sudo meson setup -Dlibconfig=true --buildtype=release build && sudo meson compile -C build && sudo meson install -C build"

    checkAndInstall "hlcand" "/usr/local/bin/hlcand" "/opt/car_hacking/usb-can-2" \
        "cd /opt/car_hacking && sudo git clone https://github.com/V0lk3n/usb-can-2.git && cd usb-can-2 && sudo ./build.sh && sudo cp -f src/hlcand /usr/local/bin/hlcand"

    checkAndInstall "CaringCaribou" "/usr/local/bin/caringcaribou" "/opt/car_hacking/caringcaribou" \
        "cd /opt/car_hacking && sudo git clone https://github.com/V0lk3n/caringcaribou.git && cd caringcaribou && sudo python3 setup.py install"

    checkAndInstall "noVNC" "/opt/noVNC/utils/novnc_proxy" "/opt/noVNC" \
        "cd /opt && sudo git clone https://github.com/novnc/noVNC.git"

    checkAndInstall "ICSIM" "/opt/car_hacking/ICSim/builddir/icsim" "/opt/car_hacking/ICSim" \
        "cd /opt/car_hacking && sudo git clone https://github.com/V0lk3n/ICSim.git && cd ICSim && sudo cp /opt/car_hacking/can-utils/lib.o . && sudo meson setup builddir && cd builddir && sudo meson compile && cd /opt/car_hacking && wget https://raw.githubusercontent.com/V0lk3n/NetHunter-CARsenal/refs/heads/main/icsim_start.sh && wget https://raw.githubusercontent.com/V0lk3n/NetHunter-CARsenal/refs/heads/main/icsim_stop.sh && wget wget https://raw.githubusercontent.com/V0lk3n/NetHunter-CARsenal/refs/heads/main/icsim_service.sh && sudo chmod +x icsim_start.sh icsim_stop.sh icsim_service.sh"

    checkAndInstall "sequence_finder.sh" "/opt/car_hacking/sequence_finder.sh" "/opt/car_hacking" \
        "cd /opt/car_hacking && sudo wget https://raw.githubusercontent.com/V0lk3n/NetHunter-CARsenal/refs/heads/main/sequence_finder.sh && sudo chmod +x sequence_finder.sh"

    checkAndInstall "can_reset.sh" "/opt/car_hacking/can_reset.sh" "/opt/car_hacking" \
        "cd /opt/car_hacking && sudo wget https://raw.githubusercontent.com/V0lk3n/NetHunter-CARsenal/refs/heads/main/can_reset.sh && sudo chmod +x can_reset.sh"

    checkAndInstall "VinInfo" "/opt/car_hacking/car_venv/bin/vininfo" "/opt/car_hacking/car_venv" \
        "sudo python3 -m venv /opt/car_hacking/car_venv && /opt/car_hacking/car_venv/bin/pip install vininfo[cli]"

    echo -e "\n✅ Setup complete! Closing in 3 seconds..."
    sleep 3
}

# --- Update Function ---
update() {
    echo -ne "\033]0;CARsenal Update\007"
    clear
    echo -e "\n🔄 Updating Packages...\n"

    sudo apt update

    sudo apt install -y autoconf cmake expect fluxbox git libconfig-dev libsdl2-dev libsdl2-image-dev libsocketcan-dev make maven meson python3-pip python3-venv websockify x11vnc xserver-xephyr xvfb

    checkAndUpdate "Can-Utils" "/usr/bin/cangen" "/opt/car_hacking/can-utils" \
        "cd /opt/car_hacking/can-utils && old=\$(git rev-parse HEAD) && sudo git pull && new=\$(git rev-parse HEAD) && [[ \"\$old\" != \"\$new\" ]] && { echo 'Update detected! Updating...'; sudo make && sudo make install; }"

    checkAndUpdate "Cannelloni" "/usr/local/bin/cannelloni" "/opt/car_hacking/cannelloni" \
        "cd /opt/car_hacking/cannelloni && old=\$(git rev-parse HEAD) && sudo git pull && new=\$(git rev-parse HEAD) && [[ \"\$old\" != \"\$new\" ]] && { echo 'Update detected! Updating...'; sudo cmake -DCMAKE_BUILD_TYPE=Release . && sudo make && sudo make install; }"

    checkAndUpdate "USB-CAN" "/usr/local/bin/canusb" "/opt/car_hacking/usb-can" \
        "cd /opt/car_hacking/usb-can && old=\$(git rev-parse HEAD) && sudo git pull && new=\$(git rev-parse HEAD) && [[ \"\$old\" != \"\$new\" ]] && { echo 'Update detected! Updating...'; sudo gcc -o canusb canusb.c && sudo cp canusb /usr/local/bin/canusb; }"

    checkAndUpdate "Freediag" "/usr/local/bin/freediag" "/opt/car_hacking/freediag" \
        "cd /opt/car_hacking/freediag && old=\$(git rev-parse HEAD) && sudo git pull && new=\$(git rev-parse HEAD) && [[ \"\$old\" != \"\$new\" ]] && { echo 'Update detected! Updating...'; ./build_simple.sh && sudo cp build/scantool/freediag /usr/local/bin/freediag && sudo cp build/scantool/diag_test /usr/local/bin/diag_test; }"

    checkAndUpdate "Socketcand" "/usr/local/sbin/socketcand" "/opt/car_hacking/socketcand" \
        "cd /opt/car_hacking/socketcand && old=\$(git rev-parse HEAD) && sudo git pull && new=\$(git rev-parse HEAD) && [[ \"\$old\" != \"\$new\" ]] && { echo 'Update detected! Updating...'; sudo meson setup -Dlibconfig=true --buildtype=release build && sudo meson compile -C build && sudo meson install -C build; }"

    checkAndUpdate "hlcand" "/usr/local/bin/hlcand" "/opt/car_hacking/usb-can-2" \
        "cd /opt/car_hacking/usb-can-2 && old=\$(git rev-parse HEAD) && sudo git pull && new=\$(git rev-parse HEAD) && [[ \"\$old\" != \"\$new\" ]] && { echo 'Update detected! Updating...'; sudo ./build.sh && sudo cp -f src/hlcand /usr/local/bin/hlcand; }"

    checkAndUpdate "CaringCaribou" "/usr/local/bin/caringcaribou" "/opt/car_hacking/caringcaribou" \
        "cd /opt/car_hacking/caringcaribou && old=\$(git rev-parse HEAD) && sudo git pull && new=\$(git rev-parse HEAD) && [[ \"\$old\" != \"\$new\" ]] && { echo 'Update detected! Updating...'; sudo python3 setup.py install; }"

    checkAndUpdate "noVNC" "/opt/noVNC/utils/novnc_proxy" "/opt/noVNC" \
        "cd /opt/noVNC && sudo git pull"

    checkAndUpdate "ICSIM" "/opt/car_hacking/ICSim/builddir/icsim" "/opt/car_hacking/ICSim" \
        "cd /opt/car_hacking/ICSim && old=\$(git rev-parse HEAD) && sudo git pull && new=\$(git rev-parse HEAD) && [[ \"\$old\" != \"\$new\" ]] && { echo 'Update detected! Updating...'; sudo meson setup builddir && sudo cp /opt/car_hacking/can-utils/lib.o . && cd builddir && sudo meson compile; }; \
         cd /opt/car_hacking && sudo rm -f icsim_start.sh icsim_stop.sh && \
         sudo wget https://raw.githubusercontent.com/V0lk3n/NetHunter-CARsenal/refs/heads/main/icsim_start.sh && \
         sudo wget https://raw.githubusercontent.com/V0lk3n/NetHunter-CARsenal/refs/heads/main/icsim_stop.sh && \
         sudo wget https://raw.githubusercontent.com/V0lk3n/NetHunter-CARsenal/refs/heads/main/icsim_service.sh && \
         sudo chmod +x icsim_start.sh icsim_stop.sh icsim_service.sh"

    checkAndUpdate "can_reset.sh" "/opt/car_hacking/can_reset.sh" "/opt/car_hacking" \
        "cd /opt/car_hacking && sudo rm -f can_reset.sh && wget https://raw.githubusercontent.com/V0lk3n/NetHunter-CARsenal/refs/heads/main/can_reset.sh && sudo chmod +x can_reset.sh"

    checkAndUpdate "sequence_finder.sh" "/opt/car_hacking/sequence_finder.sh" "/opt/car_hacking" \
        "cd /opt/car_hacking && sudo rm -f sequence_finder.sh && wget https://raw.githubusercontent.com/V0lk3n/NetHunter-CARsenal/refs/heads/main/sequence_finder.sh && sudo chmod +x sequence_finder.sh"

    checkAndUpdate "VinInfo" "/opt/car_hacking/car_venv/bin/vininfo" "/opt/car_hacking/car_venv" \
        "sudo python3 -m venv /opt/car_hacking/car_venv && /opt/car_hacking/car_venv/bin/pip install vininfo[cli]"

    echo -e "\n✅ Update complete! Closing in 3 seconds..."
    sleep 3
}

case "$1" in
  setup)
    setup
    ;;
  update)
    update
    ;;
  *)
    echo "Usage: $0 {setup|update}"
    exit 1
    ;;
esac
