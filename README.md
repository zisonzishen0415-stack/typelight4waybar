# TypeLight

> Blink the ThinkPad power LED on every keystroke.

A tiny daemon that makes your ThinkPad's power LED pulse with every keypress. Like a heartbeat for your typing.

Also includes a Waybar module that shows keystroke count and typing state indicator.

---

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Autostart](#autostart)
- [How It Works](#how-it-works)
- [Troubleshooting](#troubleshooting)
- [Uninstall](#uninstall)
- [License](#license)

---

## Overview

TypeLight monitors keyboard input events and blinks the power LED on each keypress. It's:

- **Lightweight**: ~2-3 MB RAM, near 0% CPU
- **Event-driven**: Only wakes on keystroke, not polling
- **Non-intrusive**: Runs silently in background, no terminal popup
- **Headless**: Works invisibly, doesn't require a visible window

Works on ThinkPads with exposed power LED control via sysfs.

---

## Requirements

- **ThinkPad** with controllable power LED (`/sys/class/leds/tpacpi::power`)
- **evtest** package
- Linux with sysfs support

Check if your ThinkPad supports it:

```bash
ls /sys/class/leds/tpacpi::power/brightness
```

If the file exists, you're good to go.

---

## Installation

### 1. Install evtest

```bash
sudo apt install evtest
```

### 2. Set LED permission (persistent)

```bash
echo 'w /sys/class/leds/tpacpi::power/brightness - - - - 666' | sudo tee /etc/tmpfiles.d/typelight.conf
```

Apply immediately:

```bash
sudo chmod 666 /sys/class/leds/tpacpi::power/brightness
```

### 3. Install script

```bash
ln -sf ~/development/typelight/typelight ~/.local/bin/typelight
```

---

## Usage

### Run manually

```bash
typelight
```

Press `Ctrl+C` to stop.

### Test LED

```bash
# Turn on
echo 255 > /sys/class/leds/tpacpi::power/brightness

# Turn off
echo 0 > /sys/class/leds/tpacpi::power/brightness
```

---

## Autostart

When autostarted, TypeLight runs headlessly in the background—no terminal window appears.

### Sway

Add to `~/.config/sway/config`:

```bash
exec ~/.local/bin/typelight
```

Reload Sway: `Mod+Shift+C`

### Waybar Module

TypeLight includes a Waybar module that displays:

- **Typing state indicator**: Shows `█` (full block) when typing, `░` (light shade) when idle
- **Keystroke count**: Total number of keypresses since start
- **Wave animation**: `● ○ ○` / `○ ● ○` / `○ ○ ●` cycles with each keystroke

The module is optimized for low CPU usage (~0%):
- Uses bash `read` builtin instead of spawning `cat`
- 50ms sleep interval, 100ms typing detection threshold
- Single instance lock via `flock`

**Install Waybar module:**

```bash
ln -sf ~/development/typelight/waybar-module.sh ~/.config/waybar/scripts/typelight.sh
```

**Add to Waybar config (`~/.config/waybar/config`):**

```json
"custom/typelight": {
    "exec": "~/.config/waybar/scripts/typelight.sh",
    "format": "{}",
    "return-type": "json"
}
```

**Add CSS styles (`~/.config/waybar/style.css`):**

The module uses dynamic classes: `t0`-`t63` (typing) and `i0`-`i63` (idle) for color cycling. Example:

```css
#custom-typelight {
    padding: 0 8px;
    margin-right: 8px;
    font-size: 16px;
}

/* Typing state - bright colors */
#custom-typelight.t0, #custom-typelight.t1, #custom-typelight.t2 {
    color: #88c0d0;
    font-weight: bold;
}

/* Idle state - dim colors */
#custom-typelight.i0, #custom-typelight.i1, #custom-typelight.i2 {
    color: #4c566a;
}
```

Reload Waybar: `pkill -SIGUSR2 waybar`

### systemd user service

Create `~/.config/systemd/user/typelight.service`:

```ini
[Unit]
Description=Blink power LED on keystroke
After=graphical.target

[Service]
ExecStart=%h/.local/bin/typelight
Restart=on-failure

[Install]
WantedBy=default.target
```

Enable:

```bash
systemctl --user enable --now typelight
```

---

## How It Works

```
Keyboard → evtest (monitor) → grep (filter keydown) → LED brightness write
```

1. `evtest` listens to keyboard input device
2. `grep` filters for `EV_KEY` events with `value 1` (key down)
3. On match: write `255` to LED, sleep 30ms, write `0`

The script is blocked on input most of the time, consuming virtually no resources.

---

## Troubleshooting

### LED doesn't blink

```bash
# Check permission
ls -la /sys/class/leds/tpacpi::power/brightness

# Fix permission
sudo chmod 666 /sys/class/leds/tpacpi::power/brightness
```

### No keyboard found

```bash
# Check keyboard device
ls /dev/input/by-path/*kbd*
```

### Permission lost after reboot

Ensure tmpfiles config exists:

```bash
cat /etc/tmpfiles.d/typelight.conf
```

Should show:
```
w /sys/class/leds/tpacpi::power/brightness - - - - 666
```

---

## Uninstall

```bash
# Remove symlink
rm ~/.local/bin/typelight

# Remove from Sway config (edit manually)
# Remove the "exec ~/.local/bin/typelight" line

# Remove tmpfiles config
sudo rm /etc/tmpfiles.d/typelight.conf

# Delete project
rm -rf ~/development/typelight
```

---

## License

MIT