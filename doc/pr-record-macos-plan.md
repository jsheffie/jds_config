# Port PR demo recording (pr-record + claude-in-chrome routing) to megan (macOS)

Tracking issue: https://github.com/jsheffie/jds_config/issues/6

## Goal

Get lucy's "record a demo video for a PR" workflow working on megan: a Claude Code
session drives Chrome through claude-in-chrome, records just that Chrome window,
packs the video small enough for GitHub, and attaches it to the PR.

## What exists on lucy (reference implementation)

Lives in the private repo `jsheffie/jds_config_omarchy` (master). There is no
Claude skill; it is four pieces:

| Piece | Purpose | Status on megan |
|---|---|---|
| `bin/claude-chrome-browser` | Maps Chrome profiles to Claude extension deviceIds by reading Chrome's own leveldb files | Works unchanged. Verified on megan 2026-11-09 |
| `make claude-hooks` (top-level `Makefile`) | Installs the script as a SessionStart hook in `~/.claude/settings.json` | Needs porting |
| `agents/AGENTS.md`, section "Browser work on lucy" | Tells agents to run the script, select the browser, and use `pr-record` | Needs a megan version |
| `bin/pr-record` | `start`/`stop`/`pack`/`attach`/`status` | Capture is Hyprland + gpu-screen-recorder only; `pack`/`attach`/`status` are mostly portable |

Design notes and troubleshooting: `doc/claude-in-chrome.md` in that repo.

Read them from megan with:

    gh api -H "Accept: application/vnd.github.raw" repos/jsheffie/jds_config_omarchy/contents/bin/pr-record
    gh api -H "Accept: application/vnd.github.raw" repos/jsheffie/jds_config_omarchy/contents/bin/claude-chrome-browser
    gh api -H "Accept: application/vnd.github.raw" repos/jsheffie/jds_config_omarchy/contents/doc/claude-in-chrome.md
    gh api -H "Accept: application/vnd.github.raw" repos/jsheffie/jds_config_omarchy/contents/agents/AGENTS.md
    gh api -H "Accept: application/vnd.github.raw" repos/jsheffie/jds_config_omarchy/contents/Makefile

## What megan has (surveyed 2026-11-09)

- macOS 15.6.1, Apple M3 Pro, one 3440x1440 ultrawide display. "UI Looks like"
  equals native resolution, so points == pixels (no Retina scaling to handle).
- Installed: ffmpeg/ffprobe (libx264 and h264_videotoolbox), jq, gh, python3,
  yabai, skhd. Claude Code at `~/.local/bin/claude`.
- yabai replaces `hyprctl`. `yabai -m query --windows` gives id, title, frame
  (points), space, display. Chrome window titles end with the profile, e.g.
  `... - Google Chrome - Jeff (huvrdata.com)`, so `--title` can disambiguate
  profiles.
- Built-in `screencapture -v -R x,y,w,h` records a screen region with no new
  installs. ffmpeg's avfoundation listed no "Capture screen" devices over ssh
  (most likely TCC), and that API is deprecated.
- No `~/Videos`; the macOS equivalent is `~/Movies`.
- Chrome profiles (from `claude-chrome-browser`):

      ROLE      PROFILE DIR ACCOUNT                 EXT NAME
      work      Profile 1   (huvrdata.com account)  Work
      personal  Default     (gmail.com account)     Personal
      other     Profile 5   (no Google account)     tt-work

- `~/.claude/settings.json` already has SessionStart hooks (herdr, rex). Keep them.
- `~/AGENTS.md` is installed from `dotfiles/AGENTS.md` (`make -C dotfiles install`),
  and `~/.claude/CLAUDE.md` links to it.
- `jds_config/bin` is on PATH directly (zshrc, since PR #5), so new scripts in
  `bin/` need no install step.

## Where it lives

Everything goes in `jds_config`. Nothing needs to go in `jds_private_config`.

`jds_config` is PUBLIC. Do not copy email addresses into it. Lucy's AGENTS.md
section names both accounts; the megan version says "Work (huvrdata.com
account)" and "Personal", since `claude-chrome-browser` prints the real accounts
at runtime.

## Plan

### 1. Spike the capture by hand (do this first; it is the main risk)

Must run from Ghostty on megan, not over ssh: macOS grants Screen Recording
permission per app.

- Grant Ghostty Screen Recording permission (System Settings -> Privacy &
  Security -> Screen & System Audio Recording). If Claude runs inside herdr, it
  inherits the permission from Ghostty.
- Check `screencapture -v -R<x>,<y>,<w>,<h> out.mov` with a frame from yabai:
  - Is the region right?
  - Does `kill -INT <pid>` finalize a playable file? Try SIGTERM if not.
- Check whether `screencapture -v -l <yabai window id>` works. If it does, the
  recording follows the window even when it moves, which is better than a fixed
  region.
- Check that `yabai -m window --focus <id>` brings the window forward, including
  from another space.
- If `screencapture` fails, fall back to ffmpeg avfoundation screen capture with
  a crop filter.

### 2. `bin/claude-chrome-browser`

Copy it from jds_config_omarchy unchanged. It already reads
`~/Library/Application Support/Google/Chrome` on Darwin.

### 3. `bin/pr-record` (macOS)

Keep the same commands and output as lucy (`start`/`stop`/`pack`/`attach`/`status`),
so the AGENTS.md wording matches on both machines.

- `start [--title SUBSTR] [--fullscreen] [--cursor]`: find the most recently used
  window with `yabai -m query --windows` (app `Google Chrome`, title contains
  SUBSTR), focus it with `yabai -m window --focus`, start `screencapture -v` in
  the background, and save the pid and output path to a run file under `$TMPDIR`.
  `--cursor` maps to `screencapture -C`.
- `stop [--no-pack]`: signal the recorder, wait for the file to be finalized, then
  `pack`.
- `pack`: reuse lucy's ffmpeg pipeline (mpdecimate idle-collapse, 1280 px, 30 fps,
  libx264 crf 28, yuv420p, faststart). Use `wc -c <` instead of GNU `stat -c %s`.
  The input will be `.mov`; the output stays `.mp4`.
- `attach`: unchanged (`gh pr comment --attach`).
- Output dir: `$PR_RECORD_DIR`, else `~/Movies`.
- Notifications through `osascript -e 'display notification ...'`. No menu-bar
  recording indicator.
- Run shellcheck on it.

### 4. New `claude/` module with a Makefile

This follows the repo convention: one folder per area, each with a Makefile
(see `.claude/CLAUDE.md`).

- `install`: symlink `~/.claude/hooks/claude-chrome-browser` to
  `$(repo)/bin/claude-chrome-browser`, then add the SessionStart hook to
  `~/.claude/settings.json` with jq, only if missing, keeping a `.bak`. Port it
  from lucy's `claude-hooks` target. Do not touch the existing herdr/rex hooks.

### 5. `dotfiles/AGENTS.md`

Add a "Browser work on megan (claude-in-chrome, pr-record)" section adapted
from lucy's (no emails, `~/Movies` instead of `~/Videos`, point at the doc
below). Install it with `make -C dotfiles install`.

Add `doc/claude-in-chrome.md`, adapted from lucy's, with a troubleshooting
entry for Screen Recording permission.

### 6. Setup changes in Chrome and gh

- Rename megan's extension display names to `megan:Work` and `megan:Personal`
  (extension popup). Lucy's browser list also shows megan's browsers, and "Work"
  alone is ambiguous there.
- Make sure `gh auth status` works in Ghostty; `attach` needs it. Over ssh
  the keychain is locked, so gh and git HTTPS fail there.

### 7. End to end

From a huvr checkout on megan:
1. Start a session and confirm the hook routes to Work.
2. Open a page, `pr-record start --title <substr>`, drive a few steps through
   claude-in-chrome, then `pr-record stop`.
3. Check the clip: right region, idle collapsed, under 10MB.
4. With the user's OK (it posts publicly), `pr-record attach` it to a test PR.

## Open decision

`Profile 5` ("tt-work") has the Claude extension but no Google account, so
`claude-chrome-browser` reports it as role "other" and cannot route to it.
Ask the user which profile tt-calc-app sessions should use on megan: Profile 5
or Work (Work is what lucy does).

## Later (not in this branch)

`claude-chrome-browser` will exist in both `jds_config` and
`jds_config_omarchy`, and the copies can drift apart. Lucy also has `jds_config`
cloned, so lucy could later use the `jds_config` copy and keep only one.
