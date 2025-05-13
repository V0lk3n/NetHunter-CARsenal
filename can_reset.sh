#!/bin/bash

# Get a list of all interfaces starting with can, vcan, or slcan
interfaces=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^(can|vcan|slcan)[0-9]+')

# Loop through and process each interface
for iface in $interfaces; do
    echo "Processing interface: $iface"

    # Bring down the interface
    sudo ip link set "$iface" down

    # If it's a vcan interface, delete it
    if [[ $iface == vcan* ]]; then
        echo "Deleting vcan interface: $iface"
        sudo ip link delete "$iface"
    fi
done
