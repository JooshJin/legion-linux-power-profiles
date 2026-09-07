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

# TLP: Apply AC profile (do this BEFORE the wifi override, since tlp ac
# can re-enable power_save if WIFI_PWR_ON_AC isn't set to 'off')
sudo tlp ac 2>/dev/null && echo "[OK] TLP AC profile applied"

# WiFi: Disable power saving (reduces latency spikes)
# Using 'iw' instead of 'iwconfig' - iwconfig's power management
# is legacy WEXT and silently no-ops on most modern nl80211 drivers.
sudo iw dev wlp0s20f3 set power_save off 2>/dev/null && echo "[OK] WiFi power saving disabled" || \
echo "[WARN] Could not disable WiFi power saving"

#  Bluetooth: Leave as-is (user preference) 

echo ""
echo "Stand Mode active."
echo "NOTE: GPU switch (hybrid) requires a reboot to take effect."
echo "Reminder: Toggle Fn+Q to 'Performance' mode for fan profile."