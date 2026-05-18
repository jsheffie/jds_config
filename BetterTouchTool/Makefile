BTT_URL  := http://127.0.0.1:63362
SECRET   := bttweb
DEST     := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: pull push help

## pull: copy current BTT config into this repo (canonical source)
pull:
	curl -sf "$(BTT_URL)/get_triggers/?sharedSecret=$(SECRET)" -o "$(DEST)triggers.json"
	curl -sf "$(BTT_URL)/get_preset_details/?sharedSecret=$(SECRET)" -o "$(DEST)presets.json"
	cp ~/Library/Application\ Support/BetterTouchTool/btt_user_variables.plist "$(DEST)btt_user_variables.plist"
	cp ~/Library/Preferences/com.hegenberg.BetterTouchTool.plist "$(DEST)com.hegenberg.BetterTouchTool.plist"
	@echo "✓ BTT config pulled"

## push: import triggers.json back into BTT (requires BTT web server running)
push:
	@echo "To restore: open BTT → File → Import Preset, or use:"
	@echo "  curl -sf '$(BTT_URL)/import_preset/?sharedSecret=$(SECRET)&path=$(DEST)triggers.json'"

## help: show this message
help:
	@grep -E '^## ' Makefile | sed 's/## //'
