# global agent instructions

- Never use the em dash "—". Use plain dash "-" instead
- When writing commit messages, NEVER auto-add your agent name as co-author
- Never manually modify CHANGELOG.md files or any files that are marked as auto-generated
- When making technical decisions, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- For one-off or infrequent operational work, start with the simplest direct end-to-end path. Do not build wrappers, control planes, policy layers, custom verifiers, or automation unless the direct path exposes a concrete blocker or repeated need that justifies the added machinery.
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would experience it as possible.
  This makes sure you find the real problem so your fix will actually solve it.
- When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection.
  If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way.
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness.
  If you see one, even if it is not caused by what you are working on right now, still get it fixed.
- Before using "dynamic workflows", "ultra code" or any harness feature that immediately spawns a large swarm of subagents, always explain the tradeoffs and ask the user for explicit approval.
- When creating a branch for working on a pr, make sure to prepend jds-<issue number> to the branchname

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.

## Browser work on megan (claude-in-chrome, pr-record)

Chrome profiles here with the Claude extension: `megan:Work` (huvrdata.com
account; huvr and tt-calc-app, which use Google login) and `megan:Personal`
(gmail.com account; GitHub is logged in here). Claude Code only sees them as
"Browser N", and the last selection is a global default shared by every session,
so never trust names or the current selection.

- Before the first browser tool call, run `claude-chrome-browser`. It prints
  each profile's role, account, deviceId and extension name. Call
  `mcp__claude-in-chrome__select_browser` with the matching deviceId: the
  profile the user named, else Work under `~/workspace/huvr*` and
  `~/workspace/tt-calc-app*`, else Personal.
- Never log in or switch Google accounts in the browser; ask the user.
- On "not connected" / "Receiving end does not exist", stop and ask the user to
  open that profile and run `/chrome` -> Reconnect extension.

To record a demo for a PR (`pr-record --help` for all options):

    pr-record start --tab <tabId>   # brings that tab to the front, focuses its window, records its region
    # drive the steps through claude-in-chrome
    pr-record stop                  # packs; prints ~/Movies/pr-record-<ts>.mp4
    pr-record attach <PR>           # gh pr comment --attach the last file

- Open the page first and pass its tabId from `tabs_context_mcp`.
  `--title <page title substring>` also works but can match the user's own tabs. While recording, do not move, resize or cover the window, and do not
  switch spaces: the capture is a fixed screen region.
- `attach` posts publicly: confirm with the user first unless they asked for it.
  Over 10MB only works on paid org repos; re-pack with `--width 960`.

Details and troubleshooting: `~/workspace/jds_config/doc/claude-in-chrome.md`.
