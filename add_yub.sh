#!/bin/bash

# Check usage
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <vm-name> <USEC_INITIALIZED_1> [<USEC_INITIALIZED_2> ...]"
    exit 1
fi

VM_NAME="$1"
shift
USEC_LIST=("$@")

# Helper to extract bus/device for matching USEC
get_bus_device_for_usec() {
    local target_usec="$1"
    while IFS= read -r line; do
        # Parse out bus and device
        BUS=$(echo "$line" | awk '{print $2}')
        DEV=$(echo "$line" | awk '{print $4}' | tr -d ':')

        # Run udevadm to check USEC
        DEV_PATH="/dev/bus/usb/${BUS}/${DEV}"
        if [ -e "$DEV_PATH" ]; then
            DEV_USEC=$(udevadm info --query=all --name="$DEV_PATH" 2>/dev/null | grep USEC_INITIALIZED | cut -d= -f2)
            if [ "$DEV_USEC" = "$target_usec" ]; then
                echo "$BUS $DEV"
                return 0
            fi
        fi
    done < <(lsusb | grep 1050:0407)
    return 1
}

# Track temp XML files
XML_FILES=()

for USEC in "${USEC_LIST[@]}"; do
    echo "[INFO] Searching for device with USEC_INITIALIZED=$USEC"

    BUSDEV=$(get_bus_device_for_usec "$USEC")
    if [ -z "$BUSDEV" ]; then
        echo "[WARN] No device found for USEC $USEC"
        continue
    fi

    BUS=$(echo "$BUSDEV" | awk '{print $1}' | sed 's/^0*//')
    DEV=$(echo "$BUSDEV" | awk '{print $2}' | sed 's/^0*//')

    echo "[INFO] Found device at bus $BUS, device $DEV"

    XML_FILE=$(mktemp)
    XML_FILES+=("$XML_FILE")

    cat > "$XML_FILE" <<EOF
<hostdev mode='subsystem' type='usb' managed='yes'>
  <source>
    <address bus='${BUS}' device='${DEV}'/>
  </source>
</hostdev>
EOF

    virsh attach-device "$VM_NAME" "$XML_FILE" --live
done

echo "[INFO] Sleeping 60 seconds before detaching devices..."
sleep 60

for XML in "${XML_FILES[@]}"; do
    echo "[INFO] Detaching device using XML: $XML"
    virsh detach-device "$VM_NAME" "$XML" --live
    rm -f "$XML"
done

