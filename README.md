# TypeLight

Blink the ThinkPad power LED on every keystroke.

## Requirements

- ThinkPad with controllable power LED (`/sys/class/leds/tpacpi::power`)
- `evtest` package
- Write permission to LED brightness file

## Install

```bash
sudo apt install evtest
sudo chmod 666 /sys/class/leds/tpacpi::power/brightness
```

## Usage

```bash
./typelight
```

Press Ctrl+C to stop.

## Autostart

Add to your Sway config:

```bash
exec ~/.local/bin/typelight
```

Or create a systemd user service.

## License

MIT