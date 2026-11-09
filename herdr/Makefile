# herdr config for this machine.
#
#   make install   validate config.toml, back up the live one, install it to ~/.config/herdr
#   make plugins   install the herdr plugins the keybindings in config.toml call
#   make fetch     pull ~/.config/herdr/config.toml back into the repo
#   make status    show drift between the live config and the repo copy
#
# After install, `herdr server reload-config` applies it to the running session
# and its attached clients without a restart (see README.md in this directory).

REPO_DIR    := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
REPO_CONFIG := $(REPO_DIR)config.toml
CONFIG      := $(HOME)/.config/herdr/config.toml

# owner/repo@commit, pinned to what megan runs
PLUGINS := smarzban/herdr-file-viewer@78441da81e63d5fc416ab63fa99d006161595523

.PHONY: install plugins fetch status

# If the live config differs from the repo copy, show the diff and ask first.
# The previous file is kept as config.toml.bak.<timestamp>.
install:
	@command -v herdr >/dev/null || { echo "install: herdr is not on PATH" >&2; exit 1; }
	@HERDR_CONFIG_PATH="$(REPO_CONFIG)" herdr config check || { echo "install: fix the issues above first" >&2; exit 1; }
	@mkdir -p "$(dir $(CONFIG))"
	@if [ -f "$(CONFIG)" ] && diff -q "$(CONFIG)" "$(REPO_CONFIG)" >/dev/null; then \
	  echo "Already installed: $(CONFIG)"; \
	  exit 0; \
	fi; \
	if [ -f "$(CONFIG)" ]; then \
	  echo "--- current $(CONFIG)"; \
	  echo "+++ repo $(REPO_CONFIG)"; \
	  diff "$(CONFIG)" "$(REPO_CONFIG)" || true; \
	  printf "Overwrite $(CONFIG)? (run 'make -C herdr fetch' instead to keep it) [y/N] "; \
	  read -r reply; \
	  case "$$reply" in [Yy]*) ;; *) echo "Aborted. $(CONFIG) unchanged."; exit 1;; esac; \
	  backup="$(CONFIG).bak.$$(date +%Y%m%d-%H%M%S)"; \
	  cp "$(CONFIG)" "$$backup"; \
	  echo "Backup: $$backup"; \
	fi; \
	cp "$(REPO_CONFIG)" "$(CONFIG)"; \
	echo "Installed: $(REPO_CONFIG) -> $(CONFIG)"; \
	echo "Now reload (no restart needed): herdr server reload-config"

# Idempotent: skips plugins that are already installed.
plugins:
	@command -v jq >/dev/null || { echo "plugins: jq is required" >&2; exit 1; }
	@installed="$$(herdr plugin list --json | jq -r '.result.plugins[].source | "\(.owner)/\(.repo)"')"; \
	for p in $(PLUGINS); do \
	  repo="$${p%@*}"; ref="$${p#*@}"; \
	  if printf '%s\n' "$$installed" | grep -qx "$$repo"; then \
	    echo "Already installed: $$repo"; \
	  else \
	    herdr plugin install "$$repo" --ref "$$ref" --yes || exit 1; \
	  fi; \
	done

# Pull the live config back into the repo.
fetch:
	@cp "$(CONFIG)" "$(REPO_CONFIG)"
	@echo "Fetched: $(CONFIG) -> $(REPO_CONFIG)"

# Show whether the live config has drifted from the repo copy.
status:
	@if diff -q "$(CONFIG)" "$(REPO_CONFIG)" >/dev/null; then \
	  echo "In sync: $(CONFIG)"; \
	else \
	  diff "$(REPO_CONFIG)" "$(CONFIG)" || true; \
	fi
