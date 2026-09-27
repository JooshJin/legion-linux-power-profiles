#!/bin/bash
# =============================
# WORK MODE - Battery Optimized
# =============================

echo "Switching to Work Mode..."

# GPU: Switch to iGPU
sudo envycontrol --switch integrated

# GPU: Verify the dGPU is actually off the PCI bus (not just driver-unbound)
NVIDIA_PCI=$(lspci -d 10de: -D 2>/dev/null | awk '{print $1}' | head -n1)
if [ -n "$NVIDIA_PCI" ]; then
    RUNTIME_STATUS=$(cat /sys/bus/pci/devices/$NVIDIA_PCI/power/runtime_status 2>/dev/null)
    echo "[WARN] dGPU still enumerated at $NVIDIA_PCI (runtime_status=${RUNTIME_STATUS:-unknown}) - expected fully removed from bus, may need reboot"
else
    echo "[OK] dGPU not enumerated on PCI bus - fully powered off"
fi

# CPU: Set governor to powersave
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo "powersave" | sudo tee $cpu > /dev/null
done
echo "[OK] CPU governor set to powersave"

# CPU: Disable turbo boost for lower power draw
if [ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
    echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo > /dev/null
    echo "[OK] Turbo boost disabled"
else
    echo "[WARN] intel_pstate/no_turbo not found - skipping turbo disable"
fi

# CPU: Set energy/performance policy to favor power savings
if command -v x86_energy_perf_policy > /dev/null 2>&1; then
    sudo x86_energy_perf_policy power 2>/dev/null && echo "[OK] Energy/perf policy set to power"
else
    echo "[WARN] x86_energy_perf_policy not installed (part of linux-tools) - skipping"
fi

# System: Apply powertop's recommended runtime PM / autosuspend tunables
# (USB autosuspend, VM writeback timeout, etc. - addresses shift across
# reboots so this is safer than hardcoding sysfs paths)
if command -v powertop > /dev/null 2>&1; then
    sudo powertop --auto-tune > /dev/null 2>&1 && echo "[OK] powertop auto-tune applied"
else
    echo "[WARN] powertop not installed - skipping auto-tune"
fi

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
echo "NOTE: GPU switch (integrated) requires a reboot to take effect on first switch."
echo "Reminder: Toggle Fn+Q to 'Quiet' mode for fan profile."