#!/bin/bash
# =============================
# WORK MODE - Battery Optimized
# =============================

echo "Switching to Work Mode..."

# GPU: Switch to iGPU
sudo envycontrol --switch integrated

# CPU: Set governor to powersave
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo "powersave" | sudo tee $cpu > /dev/null
done
echo "[OK] CPU governor set to powersave"

# Refresh rate: set to 60hz (make sure the profile exists in xrandr)
if xrandr --output eDP-1 --mode 1920x1080 --rate 59.99 2>/dev/null; then
    echo "[OK] Refresh rate set to 60Hz"
else
    echo "[WARN] Could not set refresh rate - run 'xrandr' to check your output name and available rates"
fi

# Battery: Remove charge limit (allow full charge)
echo 0 | sudo tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode
echo "[OK] Charge limit removed (full charge allowed)"

# TLP: Apply battery profile (do this BEFORE the wifi override, for
# consistency with stand.sh's ordering)
sudo tlp bat 2>/dev/null && echo "[OK] TLP battery profile applied"

# WiFi: Enable power saving
sudo iw dev wlp0s20f3 set power_save on 2>/dev/null && echo "[OK] WiFi power saving enabled" || \
echo "[WARN] Could not set WiFi power saving"

# Bluetooth: Turn off 
sudo rfkill block bluetooth && echo "[OK] Bluetooth disabled" || \
echo "[WARN] Could not disable Bluetooth"

echo ""
echo "Work Mode active."
echo "NOTE: GPU switch (integrated) requires a reboot to take effect."
echo "Reminder: Toggle Fn+Q to 'Quiet' mode for fan profile."