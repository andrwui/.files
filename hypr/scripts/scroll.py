import evdev
import sys

dev = next(d for d in map(evdev.InputDevice, evdev.list_devices()) if 'ydotoold' in d.name)
direction = 1 if sys.argv[1] == 'up' else -1
count = int(sys.argv[2]) if len(sys.argv) > 2 else 3

for _ in range(count):
    dev.write(evdev.ecodes.EV_REL, evdev.ecodes.REL_WHEEL, direction)
    dev.write(evdev.ecodes.EV_REL, evdev.ecodes.REL_WHEEL_HI_RES, 120 * direction)
    dev.write(evdev.ecodes.EV_SYN, evdev.ecodes.SYN_REPORT, 0)
