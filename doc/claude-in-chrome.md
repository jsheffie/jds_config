# claude-in-chrome with several Chrome profiles (megan, macOS)

The macOS port of lucy's setup (`doc/claude-in-chrome.md` in the private
`jds_config_omarchy` repo). Tracking issue: #6.

## The problem

Several Chrome profiles run on megan, each with the Claude extension installed:

| Role     | Chrome profile dir | Account                 | Used for                         |
|----------|--------------------|-------------------------|----------------------------------|
| Work     | `Profile 1`        | huvrdata.com account    | huvr, tt-calc-app (Google login) |
| Personal | `Default`          | gmail.com account       | GitHub                           |
| other    | `Profile 5`        | none (no Google login)  | not routed                       |

`claude-chrome-browser` prints the real accounts at runtime; this repo is public,
so they are not written down here.

Claude Code sessions kept driving the wrong profile, for three reasons:

1. **Names never reach the CLI.** The extension keeps the display name you set
   (`megan:Work`, `megan:Personal`) in its own local storage only. Claude Code's
   `list_connected_browsers` calls every browser "Browser 1", "Browser 2", and so
   on, so a session cannot tell Work from Personal by name.
2. **The selection is one global default.** The last browser picked is saved in
   `~/.claude.json` under `chromeExtension.pairedDeviceId` and becomes the default
   for every new session in every directory.
3. **Other machines are in the list too.** lucy's browsers show up next to
   megan's.

None of this is configurable per project in Claude Code today.

## The fix

The extension's device id is stable per profile. It lives in the profile's
extension storage (leveldb) under the key `bridgeDeviceId`.
`bin/claude-chrome-browser` reads it straight out of Chrome's files
(`~/Library/Application Support/Google/Chrome`) and maps it to the signed-in
Google account. A SessionStart hook then tells each Claude session which id to
select for its directory.

Pieces:

- `bin/claude-chrome-browser` (on PATH, since `jds_config/bin` is). Run it
  without arguments to print the role / profile / device id table.
  `claude-chrome-browser hook` reads the hook JSON on stdin and prints routing
  guidance for that cwd. Work directories are `~/workspace/huvr*` and
  `~/workspace/tt-calc-app*`; everything else is Personal. Edit the constants at
  the top of the script to change either list. A profile with no Google account
  (Profile 5) has role "other" and is never routed to.
- `~/.claude/hooks/claude-chrome-browser`, a symlink to the script, and a
  SessionStart hook (startup, resume, clear, compact, fork) in
  `~/.claude/settings.json` that runs it. `make -C claude install` sets up both.
  It only writes settings.json when the entry is missing, keeps
  `settings.json.bak` when it does, and leaves the other hooks alone.
- `dotfiles/AGENTS.md` (installed to `~/AGENTS.md`, which `~/.claude/CLAUDE.md`
  links to) tells Claude to run `claude-chrome-browser` and call
  `select_browser` with the matching device id before the first browser tool
  call. Running the script on demand also covers sessions whose hook output was
  compacted away.

Every session selects its own browser explicitly, so the shared global default
no longer matters.

The script is a copy of lucy's with one shellcheck fix. Keep the two in step
until lucy uses this repo's copy.

## Day-to-day flow

1. Have the Chrome profiles open, with the extension signed in to the same
   claude.ai account and org as Claude Code.
2. Start `claude` in the project directory. The hook prints the routing line.
3. Ask for browser work. Say "use megan:Work" to pick a profile explicitly.
   Claude runs `claude-chrome-browser`, selects the right device id, then opens
   its own tab group in that profile.
4. Run `/chrome` -> "Select browser..." only to override for one session.

## Recording a demo for a PR

`bin/pr-record` records a Chrome window without any prompts, so a Claude session
can start it, drive the steps, stop it and attach the video to a PR:

    pr-record start --tab 956881158        # tabId from tabs_context_mcp; front that tab, record its window
    # Claude runs the steps through claude-in-chrome
    pr-record stop                          # stop, pack, prints ~/Movies/pr-record-<ts>.mp4
    pr-record attach 1234                   # gh pr comment --attach with the last packed file

How it works on macOS:

- `yabai -m query --windows` finds the window. It lists windows most recently
  used first, so the first Chrome window whose title contains `--title` wins.
  `yabai -m window --focus` raises it and switches spaces if needed.
- A window's title is its active tab's title, and claude-in-chrome usually puts
  its tab group in an existing window as a background tab, so a window found
  by title would show some other tab. `--tab <tabId>` fixes that: the
  claude-in-chrome tabId is Chrome's own tab id, so `start` finds that tab over
  AppleScript, makes it the active tab of its window, and records the window
  whose title now starts with the tab's title. Windows whose active tab is in a
  tab group (" - Part of group " in the title) win, so a user's own window
  showing the same page loses. The first run may ask to let the terminal
  control Google Chrome (Privacy & Security -> Automation).
- With `--title` instead, when no window title matches, `start` makes the first
  Chrome tab whose title contains it the active tab of its window.
- The built-in `screencapture -v -R x,y,w,h` records that screen region. It needs
  no extra installs. It stops on SIGINT or on any input on stdin, so `start`
  feeds it from a `sleep` that never writes. `stop` sends SIGINT to the recorder
  alone and then ends the `sleep`. If both stop signals arrive together,
  screencapture crashes and writes nothing.
- `screencapture -l <window id>` would follow the window, but it does not work
  with `-v` (it records the whole screen), so the region is fixed at start.
- The pointer is always in the video. `--cursor` exists only for parity with lucy.
- There is no start or stop notification: a banner would land in the recording.
  macOS shows its own screen-recording indicator in the menu bar.

Using it:

- Prefer `--tab`. Every profile's windows belong to the "Google Chrome" app,
  and the window title ends with the profile name (`- Jeff (huvrdata.com)`,
  `- Jeff`, `- jeff tt`). "Jeff" matches all three, so a `--title` must be a
  substring of the page title (navigate first, then start).
- The region is part of the screen, not the window. While recording, do not move,
  resize, or cover the window, and do not switch spaces. Any of these records
  the wrong thing. `--fullscreen` records the whole display the window is on.
- `stop` drops the 60 fps capture to 30 fps, collapses idle stretches about 15x,
  and downscales to 1280 px wide. GitHub takes up to 10MB on free repos and
  100MB on paid org repos; run `pr-record pack RAW.mov --width 960` if a file
  is too big.
- `pr-record status` shows whether a recording is running and the last file.
  State lives in `~/.local/state/pr-record/`, so `status` and `stop` work from
  any terminal.
- `attach` needs `gh auth status` to pass. Over ssh the login keychain is
  locked, so run it from a local terminal.

## Troubleshooting

| Symptom | What to do |
|---|---|
| Hook says it could not find a profile for a role | Run `claude-chrome-browser`. "(extension not found)" means that profile has no Claude extension storage: open the profile and make sure the extension is installed and signed in. |
| `select_browser` rejects the id, or the browser is missing from `list_connected_browsers` | That profile's Chrome window is not open or the extension is signed out. Open it, then `/chrome` -> Reconnect extension. |
| "Receiving end does not exist" mid-session | The extension's service worker went idle. `/chrome` -> Reconnect extension. |
| "Browser extension is not connected" | The extension is signed in to a different claude.ai account or org than Claude Code (`/status` shows the org). |
| The clip shows only the desktop wallpaper, or `start` says screencapture exited right away | The terminal app has no Screen Recording permission. System Settings -> Privacy & Security -> Screen & System Audio Recording: enable Ghostty (herdr and Claude Code inherit it), then restart Ghostty. Over ssh there is no app to grant it to; run from a local terminal. |
| `start` says there is no Chrome tab with that id, or no window or tab with that title | Take the tabId (or title) from `tabs_context_mcp`. If the terminal was denied control of Chrome, allow it under Privacy & Security -> Automation. |
| `start` says the window did not take focus | yabai could not raise it, e.g. it is minimized or on a fullscreen space. Bring it up by hand and retry. |
| The clip shows the wrong area | The window moved or a space switched during the recording. Re-record without touching it. |
| `stop` says the recorder had already exited | Something ended screencapture early. `stop` packs whatever it wrote; check `~/.local/state/pr-record/screencapture.log`. |
| Device id changed | Happens only if the extension is reinstalled in that profile. Nothing to edit: the script re-reads Chrome's files on every session start. |

## Why not just hardcode the ids

The ids are stable, but a reinstall silently changes them and every session would
then select a dead id. Reading Chrome's own data costs about 0.3 s per session
start and cannot drift.
