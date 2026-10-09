### Old Workflow Tooling
OS: windows/linux/macOS
(old/old)
0.5. terminal multiplexer: screen -> tmux
1. terminal ( xterm2 -> ghostty ) 
2. ide: notepad -> vi -> emacs -> sublime -> vscode -> zed
3. source control: github desktop, cli, github web protal
4. 

### New Workflow Tooling 
OS: macOS/Linux
1. terminal multiplexer: herdr
2. ide/idp: neovim
    - mason installer/package manager.
    - plugins: see below this is some stuff
2. source control: git
    - gh-dash
    - octo.nvim - `pwntester/octo.nvim`
3. Github TUI
    - gh dash ( also install gum from charm )
        - keystroke rules for checkout 'O'
        - keystroke for code-review/diff 'C' -> herdr/pane veovim + Octo 
        - keystroke for lazygit add 'a' -> lazygit
        - keystroke for approve 'v' -> gh + gum 
4. Github 

### Neovim Setup (as of 2026-09-22)

Config: `~/.config/nvim/init.lua` (kickstart.nvim, using Neovim 0.12's built-in `vim.pack` plugin manager)
- Lockfile: `~/.config/nvim/nvim-pack-lock.json`
- Plugins installed to: `~/.local/share/nvim/site/pack/core/opt/`
- Config is a local git repo (`~/.config/nvim`, no remote yet)
- Neovim 0.12.5 installed via `brew install neovim` (2026-09-15)

#### Plugins (21)

| Area | Plugins |
|---|---|
| Completion / snippets | blink.cmp, LuaSnip |
| LSP / tooling | nvim-lspconfig, mason.nvim, mason-lspconfig.nvim, mason-tool-installer.nvim, fidget.nvim |
| Formatting | conform.nvim, guess-indent.nvim |
| Fuzzy finding | telescope.nvim, telescope-fzf-native.nvim, telescope-ui-select.nvim, plenary.nvim |
| Syntax | nvim-treesitter (`main` branch) |
| Git / GitHub | gitsigns.nvim, octo.nvim (GitHub issues and PR reviews via `gh`, e.g. `:Octo pr list`) |
| UI / helpers | which-key.nvim, todo-comments.nvim, mini.nvim, tokyonight.nvim (colorscheme) |
| Markdown | render-markdown.nvim (renders markdown in the buffer, `<leader>tm` toggles rendered/raw; also renders octo buffers) |

#### Mason-installed tools

- lua-language-server
- python-lsp-server
- stylua
- typescript-language-server

#### Supporting Homebrew installs

```sh
brew install ripgrep   # used by telescope live_grep
brew install lazygit   # terminal git UI
```
