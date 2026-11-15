# Claude Code wiring that lives outside AGENTS.md (that one is in dotfiles/).
#
#   make install   symlink bin/claude-chrome-browser into ~/.claude/hooks, add
#                  it as a SessionStart hook in ~/.claude/settings.json, and
#                  merge settings-overlay.json into settings.json
#   make status    show the hook symlink, whether settings.json runs it, and
#                  whether the overlay is applied
#   make fetch     nothing to pull back: the hook is a symlink into this repo
#
# install only writes settings.json when the hook entry is missing or an
# overlay value differs, keeps a backup of the previous file next to it, and
# leaves other keys alone. settings-overlay.json holds the settings.json keys
# this repo owns (attribution: no Co-Authored-By trailer or PR footer).
# Background: doc/claude-in-chrome.md.

REPO_DIR        := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)
HOOK_SRC        := $(REPO_DIR)/bin/claude-chrome-browser
CLAUDE_SETTINGS := $(HOME)/.claude/settings.json
CLAUDE_OVERLAY  := $(REPO_DIR)/claude/settings-overlay.json
CLAUDE_HOOKS    := $(HOME)/.claude/hooks
HOOK_DST        := $(CLAUDE_HOOKS)/claude-chrome-browser
CHROME_HOOK_CMD := bash $(HOOK_DST) hook

.PHONY: install status fetch

install:
	@command -v jq >/dev/null || { echo "claude: jq is required (brew install jq)" >&2; exit 1; }
	@mkdir -p "$(CLAUDE_HOOKS)"
	@ln -sfn "$(HOOK_SRC)" "$(HOOK_DST)"
	@echo "Linked: $(HOOK_DST) -> $(HOOK_SRC)"
	@[ -f "$(CLAUDE_SETTINGS)" ] || echo '{}' > "$(CLAUDE_SETTINGS)"
	@if jq -e --arg c '$(CHROME_HOOK_CMD)' \
		'[.hooks.SessionStart[]?.hooks[]?.command] | index($$c)' \
		"$(CLAUDE_SETTINGS)" >/dev/null; then \
		echo "$(CLAUDE_SETTINGS): SessionStart hook already present"; \
	else \
		cp "$(CLAUDE_SETTINGS)" "$(CLAUDE_SETTINGS).bak"; \
		jq --arg c '$(CHROME_HOOK_CMD)' \
			'.hooks.SessionStart += [{"matcher": "^(startup|resume|clear|compact|fork)$$", "hooks": [{"type": "command", "command": $$c, "timeout": 10}]}]' \
			"$(CLAUDE_SETTINGS).bak" > "$(CLAUDE_SETTINGS)"; \
		echo "$(CLAUDE_SETTINGS): added SessionStart hook (backup: $(CLAUDE_SETTINGS).bak)"; \
	fi
	@if jq -e --slurpfile o "$(CLAUDE_OVERLAY)" '. * $$o[0] == .' "$(CLAUDE_SETTINGS)" >/dev/null; then \
		echo "$(CLAUDE_SETTINGS): overlay already applied"; \
	else \
		cp "$(CLAUDE_SETTINGS)" "$(CLAUDE_SETTINGS).bak"; \
		jq --slurpfile o "$(CLAUDE_OVERLAY)" '. * $$o[0]' \
			"$(CLAUDE_SETTINGS).bak" > "$(CLAUDE_SETTINGS)"; \
		echo "$(CLAUDE_SETTINGS): applied $(CLAUDE_OVERLAY) (backup: $(CLAUDE_SETTINGS).bak)"; \
	fi

status:
	@ls -l "$(HOOK_DST)" 2>/dev/null || echo "missing: $(HOOK_DST)"
	@if jq -e --arg c '$(CHROME_HOOK_CMD)' \
		'[.hooks.SessionStart[]?.hooks[]?.command] | index($$c)' \
		"$(CLAUDE_SETTINGS)" >/dev/null 2>&1; then \
		echo "$(CLAUDE_SETTINGS): SessionStart hook present"; \
	else \
		echo "$(CLAUDE_SETTINGS): SessionStart hook missing (run make install)"; \
	fi
	@if jq -e --slurpfile o "$(CLAUDE_OVERLAY)" '. * $$o[0] == .' "$(CLAUDE_SETTINGS)" >/dev/null 2>&1; then \
		echo "$(CLAUDE_SETTINGS): overlay applied"; \
	else \
		echo "$(CLAUDE_SETTINGS): overlay not applied (run make install)"; \
	fi

fetch:
	@echo "Nothing to fetch: $(HOOK_DST) is a symlink into this repo."
