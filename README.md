# Legion Linux Power Profiles
Shell scripts for quickly switching between battery-optimized and performance power profiles on a Lenovo Legion laptop running Linux.

## Scripts

### `work.sh` — Battery / Work Mode
Optimizes the system for productivity and battery life:
- **GPU**: Switches to integrated graphics only (via `envycontrol`)
- **CPU**: Sets governor to `powersave`
- **Display**: Sets refresh rate to 60Hz
- **Battery**: Removes charge cap (allows full charge)
- **WiFi**: Enables power saving
- **Bluetooth**: Turns off
- **TLP**: Applies battery profile

> ⚠️ GPU switch requires a reboot to take effect. Set Fn+Q to **Quiet** mode for the fan profile.

---

### `gaming.sh` — Performance / Gaming Mode
Maximizes performance for gaming:
- **GPU**: Switches to hybrid mode (NVIDIA + Intel via `envycontrol`)
- **CPU**: Sets governor to `performance`
- **Display**: Restores refresh rate to 165Hz
- **Battery**: Enables conservation mode (caps charge to ~60% to preserve battery health)
- **WiFi**: Disables power saving (reduces latency spikes)
- **TLP**: Applies AC profile

> ⚠️ GPU switch requires a reboot to take effect. Set Fn+Q to **Performance** mode for the fan profile.

---

## Installation

Copy the scripts to `/usr/local/bin` so they're available system-wide:

```bash
sudo cp work.sh gaming.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/work.sh /usr/local/bin/gaming.sh
```

Then run either script from anywhere:

```bash
sudo work.sh
sudo gaming.sh
```

## Dependencies

- [`envycontrol`](https://github.com/bayasdev/envycontrol) — GPU switching
- `tlp` — Power management profiles
- `iwconfig` (wireless-tools) — WiFi power saving control
- `rfkill` — Bluetooth toggle
- `xrandr` — Refresh rate switching

## Notes

- Tested on a **Lenovo Legion 5 (2020)** running **Linux Mint**
- Work mode uses iGPU only — HDMI output will not work in this mode. Change `envycontrol --switch integrated` to `--switch hybrid` if you need it
- The conservation mode charge cap and WiFi interface name (`wlp0s20f3`) may differ on other models — edit the scripts as needed
- 60Hz mode in `work.sh` requires a custom xrandr mode to be set up if your panel doesn't natively advertise 60Hz