SKHD_CONFIG := $(HOME)/.config/skhd/skhdrc
REPO_FILE   := $(shell pwd)/skhdrc

.PHONY: install uninstall fetch reload start stop restart status build-8x2 build-4x4

# Simple Keyboard Hotkey Daemon

install:
	@mkdir -p $(HOME)/.config/skhd
	@if [ -L $(SKHD_CONFIG) ]; then \
	  echo "Already symlinked: $(SKHD_CONFIG) -> $$(readlink $(SKHD_CONFIG))"; \
	elif [ -f $(SKHD_CONFIG) ]; then \
	  echo "ERROR: $(SKHD_CONFIG) exists and is not a symlink. Move or remove it first."; \
	  exit 1; \
	else \
	  ln -s $(REPO_FILE) $(SKHD_CONFIG); \
	  echo "Linked: $(SKHD_CONFIG) → $(REPO_FILE)"; \
	fi
	@echo "Done. Run 'make start' to start skhd, or 'make reload' if it's already running."

uninstall:
	@if [ -L $(SKHD_CONFIG) ]; then \
	  rm $(SKHD_CONFIG); \
	  echo "Removed symlink."; \
	else \
	  echo "$(SKHD_CONFIG) is not a symlink — not touching it."; \
	fi

fetch:
	@if [ -L $(SKHD_CONFIG) ]; then \
	  echo "$(SKHD_CONFIG) is a symlink to this repo — nothing to fetch."; \
	elif [ -f $(SKHD_CONFIG) ]; then \
	  cp $(SKHD_CONFIG) $(REPO_FILE); \
	  echo "Fetched: $(SKHD_CONFIG) → $(REPO_FILE)"; \
	else \
	  echo "No config found at $(SKHD_CONFIG)"; \
	fi

reload:
	skhd --reload


start:
	skhd --start-service

stop:
	skhd --stop-service

restart:
	skhd --restart-service

status:
	launchctl list | grep skhd

build-8x2:
	cat skhdrc-8-by-2 skhdrc-app-launchers > skhdrc

build-4x4:
	cat skhdrc-4-by-4 skhdrc-app-launchers > skhdrc

reload8: build-8x2
	skhd --reload
