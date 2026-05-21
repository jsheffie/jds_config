# Yabai — Bypassing the 16-Space Limit

macOS Mission Control enforces a UI limit of 16 spaces per display. Yabai can create and manage spaces beyond this limit by using its OSAX scripting addition (injected into `Dock.app`), which calls private SkyLight/CoreGraphics APIs directly.

## Requirements

Bypassing the limit requires partial SIP (System Integrity Protection) disable and the yabai scripting addition installed.

https://github.com/asmvik/yabai/wiki/Disabling-System-Integrity-Protection

### 1. Disable SIP (partial)

Boot into Recovery Mode (`Command + R` on Intel, hold power button on Apple Silicon), open Terminal, and run:

```sh
# If you're on Apple Silicon macOS 13.x.x OR newer
# Requires Filesystem Protections, Debugging Restrictions and NVRAM Protection to be disabled
# (printed warning can be safely ignored)
csrutil enable --without fs --without debug --without nvram
```

### 1.1 Reboot

### 2. 


### 2. Install and load the scripting addition

https://github.com/asmvik/yabai/wiki/Installing-yabai-(latest-release)

```sh
#sudo yabai --install-sa
#sudo yabai --load-sa
```

The scripting addition must be reloaded after each macOS update.

### 3. Create spaces beyond 16

Use yabai's IPC — do not use the Mission Control UI:

```sh
yabai -m space --create
```

Repeat as needed. Verify all spaces with:

```sh
yabai -m query --spaces
```

## Notes

- The Mission Control visual strip will not display spaces past 16 reliably. Navigate using yabai commands instead:
  ```sh
  yabai -m space --focus <index>
  ```
- The scripting addition injection requires partial SIP disable — full `csrutil disable` also works but partial is preferred.
- After rebuilding yabai, run `make sign` before restarting to avoid macOS revoking accessibility permissions.
