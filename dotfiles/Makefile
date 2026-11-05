REPO_DIR    := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
REPO_AGENTS := $(REPO_DIR)AGENTS.md
AGENTS      := $(HOME)/AGENTS.md
CLAUDE_MD   := $(HOME)/.claude/CLAUDE.md
CLAUDE_LINK := ../AGENTS.md

.PHONY: install fetch status

# Copy AGENTS.md to ~/AGENTS.md and point ~/.claude/CLAUDE.md at it.
# If ~/AGENTS.md differs from the repo copy, show the diff and ask first.
install:
	@if [ -f "$(AGENTS)" ] && ! diff -q "$(AGENTS)" "$(REPO_AGENTS)" >/dev/null; then \
	  echo "--- current $(AGENTS)"; \
	  echo "+++ repo $(REPO_AGENTS)"; \
	  diff "$(AGENTS)" "$(REPO_AGENTS)" || true; \
	  printf "Overwrite $(AGENTS)? (run 'make fetch' instead to keep it) [y/N] "; \
	  read -r reply; \
	  case "$$reply" in [Yy]*) ;; *) echo "Aborted. $(AGENTS) unchanged."; exit 1;; esac; \
	fi
	@cp "$(REPO_AGENTS)" "$(AGENTS)"
	@echo "Installed: $(REPO_AGENTS) -> $(AGENTS)"
	@mkdir -p "$(HOME)/.claude"
	@if [ -L "$(CLAUDE_MD)" ] && [ "$$(readlink "$(CLAUDE_MD)")" = "$(CLAUDE_LINK)" ]; then \
	  echo "Already linked: $(CLAUDE_MD) -> $(CLAUDE_LINK)"; \
	elif [ -e "$(CLAUDE_MD)" ] || [ -L "$(CLAUDE_MD)" ]; then \
	  echo "ERROR: $(CLAUDE_MD) exists and is not a link to $(CLAUDE_LINK). Move or remove it first."; \
	  exit 1; \
	else \
	  ln -s "$(CLAUDE_LINK)" "$(CLAUDE_MD)"; \
	  echo "Linked: $(CLAUDE_MD) -> $(CLAUDE_LINK)"; \
	fi

# Pull ~/AGENTS.md back into the repo.
fetch:
	@cp "$(AGENTS)" "$(REPO_AGENTS)"
	@echo "Fetched: $(AGENTS) -> $(REPO_AGENTS)"

# Show whether ~/AGENTS.md has drifted from the repo copy.
status:
	@if diff -q "$(AGENTS)" "$(REPO_AGENTS)" >/dev/null; then \
	  echo "In sync: $(AGENTS)"; \
	else \
	  diff "$(REPO_AGENTS)" "$(AGENTS)" || true; \
	fi
	@ls -l "$(CLAUDE_MD)"
