Perfect, a 8-wide × 2-tall grid. Here's the full setup:


## Step 1: Install Homebrew (if you don't have it)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Step 2: Install Yabai and skhd


```bash
brew install asmvik/formulae/yabai
brew install asmvik/formulae/skhd
```

## Step 3: Create your 16 desktops first

Yabai can navigate spaces but **cannot create them without SIP modifications**. 
So you need to manually create all 16 workspace spaces in Mission Control before this will work:

3.1. Press F3 (or Control+Up) to open Mission Control
3.2. Click the **+** button in the top-right corner to add a desktop
3.3. Repeat until you have 20 desktops total

You can also drag them to reorder if needed. 
Note: that macOS may rearrange spaces based on recency unless you disable that — see Step 6.

## Step 4: Enable native macOS space-switching shortcuts

System Settings → Keyboard → Keyboard Shortcuts → Mission Control → Mission Control section. Check the boxes for "Switch to Desktop 1" through "Switch to Desktop 16" (macOS only exposes shortcuts up to 16 natively, but that's fine — skhd will handle the rest via yabai commands directly, which don't depend on these).

This step is mostly so things feel consistent; yabai's `space --focus` doesn't actually need these.

## Step 5: Create the skhd config

```bash
mkdir -p ~/.config/skhd
touch ~/.config/skhd/skhdrc
curl -fsSL https://raw.githubusercontent.com/jsheffie/spacemap/refs/heads/main/docs/skhd-configurations/skhdrc-8-by-2 > ~/.config/skhd/skhdrc
```
**Note on Control+Left/Right:** macOS itself binds these to space switching. If there's a conflict, disable the system shortcut in System Settings → Keyboard → Keyboard Shortcuts → Mission Control, or skhd's binding will lose.

## Step 6: Disable automatic space rearranging

This is critical — macOS reorders spaces based on most recent use by default, which will completely break your grid mental model:

System Settings → Desktop & Dock → Mission Control → **uncheck "Automatically rearrange Spaces based on most recent use."**

## Step 7: Start the services

```bash
skhd --install-service
skhd --start-service
```
To check status's 
```bash
skhd --restart-service
skhd --stop-service
skhd --uninstall-service
```

```bash
yabai --install-service
yabai --start-service
```


You'll get prompts to grant **Accessibility permissions** to both yabai and skhd. Approve them in System Settings → Privacy & Security → Accessibility. You may need to restart the services after granting permissions:

```bash
skhd --restart-service
yabai --restart-service
```

## Step 8: Test it

Try Control+Right, Control+Down, Control+Cmd+5, etc. If something doesn't work:

```bash
# Check skhd is loaded
launchctl list | grep skhd

# Check yabai is loaded
launchctl list | grep yabai

# View logs
tail -f /tmp/skhd_$USER.err.log
tail -f /tmp/yabai_$USER.err.log

# Reload skhd config after edits
skhd --reload
```
## Fix folders opened from desktop not tiling
documented [here](https://github.com/asmvik/yabai/wiki/Tips-and-tricks#fix-folders-opened-from-desktop-not-tiling)
When opening a folder on the desktop there's an animation that conflicts with yabai trying to tile the window. This animation can be disabled:

```bash
defaults write com.apple.finder DisableAllAnimations -bool true
killall Finder # or logout and login

# to reset system defaults, delete the key instead
# defaults delete com.apple.finder DisableAllAnimations
```

## A few notes on the grid behavior

- **Wrapping:** `space --focus next` wraps from D16 back to D1, not from D8 to D9. So Ctrl+Right at D8 goes to D9 (the bottom-left of the grid), not back to D1. If you want strict row-wrapping (D8 → D1, D16 → D9), the config gets more complex with modulo math — let me know and I'll write that version.
- **Edge cases:** Ctrl+Down at D11 tries to focus D19, which doesn't exist. Yabai will silently fail. Same for Ctrl+Up at D1–D8 (would target 0 or negative). If you want vertical wrap (D11 → D3, D3 → D11), that's also doable with modulo logic.
- **Animations:** Space-switching animations on macOS are slow. Consider System Settings → Accessibility → Display → **Reduce Motion** for a snappier feel.


Reference: The developer's github account for yabai and skhd changed
`koekeishiya` vs new name `asmvik`
