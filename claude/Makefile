# Claude Code wiring that lives outside AGENTS.md (that one is in dotfiles/).
#
#   make install   symlink bin/claude-chrome-browser into ~/.claude/hooks and add
#                  it as a SessionStart hook in ~/.claude/settings.json
#   make status    show the hook symlink and whether settings.json runs it
#   make fetch     nothing to pull back: the hook is a symlink into this repo
#
# install only writes settings.json when the hook entry is missing, keeps a
# backup of the previous file next to it, and leaves other hooks alone.
# Background: doc/claude-in-chrome.md.

REPO_DIR        := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)
HOOK_SRC        := $(REPO_DIR)/bin/claude-chrome-browser
CLAUDE_SETTINGS := $(HOME)/.claude/settings.json
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

status:
	@ls -l "$(HOOK_DST)" 2>/dev/null || echo "missing: $(HOOK_DST)"
	@if jq -e --arg c '$(CHROME_HOOK_CMD)' \
		'[.hooks.SessionStart[]?.hooks[]?.command] | index($$c)' \
		"$(CLAUDE_SETTINGS)" >/dev/null 2>&1; then \
		echo "$(CLAUDE_SETTINGS): SessionStart hook present"; \
	else \
		echo "$(CLAUDE_SETTINGS): SessionStart hook missing (run make install)"; \
	fi

fetch:
	@echo "Nothing to fetch: $(HOOK_DST) is a symlink into this repo."
