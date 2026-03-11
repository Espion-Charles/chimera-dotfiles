#!/bin/bash

DOT_GPU_DIR="$HOME/laptop-dotfiles/hypr/gpu"
GPU_ADDR=$(lspci | grep -i nvidia | cut -d' ' -f1 | sed 's/^/0000:/')

echo "Select GPU Mode:"
echo "1) Integrated (Intel - Kill Nvidia Power)"
echo "2) NVIDIA (Performance - Wake Nvidia)"
read -p "Selection: " choice

case $choice in
   1)
        echo "Switching to Integrated mode..."
        
        # 1. Update the Hyprland config link
        ln -sf integrated.conf "$DOT_GPU_DIR/current.conf"

        # 2. Set EnvyControl
        sudo envycontrol -s integrated

        # 3. Aggressively unload NVIDIA modules
        # This is the most important part to prevent "Permission Denied"
        echo "Unloading drivers..."
        sudo modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia 2>/dev/null

        # 4. Force power down using a subshell for better permission handling
        if [ -n "$GPU_ADDR" ]; then
            echo "Cutting power to GPU at $GPU_ADDR..."
            sudo sh -c "echo 1 > /sys/bus/pci/devices/$GPU_ADDR/remove" || echo "Hardware is busy, will power down on reboot."
        fi
        ;;
    2)
        # 1. Wake the PCI bus so the driver can see the card
        echo 1 | sudo tee /sys/bus/pci/rescan
        sleep 1 # Give the bus a second to react
        
        # 2. Now switch the hardware mode
        sudo envycontrol -s nvidia
        ln -sf nvidia.conf "$DOT_GPU_DIR/current.conf"
        ;;
    *)
        echo "Invalid choice."
        exit 1
        ;;
esac

echo "Done. Please reboot to finalize the driver load."