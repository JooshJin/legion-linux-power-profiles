#!/bin/bash
# ==============================
# STAND MODE - Charging and Performance Optimized
# ==============================

echo "Switching to Stand Mode..."

# GPU: Switch to hybrid (NVIDIA + Intel) 
sudo envycontrol --switch hybrid

# CPU: Set governor to performance 
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo "performance" | sudo tee $cpu > /dev/null
done
echo "[OK] CPU governor set to performance"

# Refresh rate: Restore to 165hz 
if xrandr --output eDP-1 --mode 1920x1080 --rate 165 2>/dev/null; then
    echo "[OK] Refresh rate set to 165Hz"
else
    echo "[WARN] Could not set refresh rate - run 'xrandr' to check your output name and available rates"
fi

# Battery: Remove charge limit (allow full charge)
echo 0 | sudo tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode
echo "[OK] Charge limit removed (full charge allowed)"

#  WiFi: Disable power saving (reduces latency spikes) 
sudo iwconfig wlp0s20f3 power off 2>/dev/null && echo "[OK] WiFi power saving disabled" || \
echo "[WARN] Could not disable WiFi power saving"

#  Bluetooth: Leave as-is (user preference) 

# TLP: Apply AC profile 
sudo tlp ac 2>/dev/null && echo "[OK] TLP AC profile applied"

echo ""
echo "Stand Mode active."
echo "NOTE: GPU switch (hybrid) requires a reboot to take effect."
echo "Reminder: Toggle Fn+Q to 'Performance' mode for fan profile."