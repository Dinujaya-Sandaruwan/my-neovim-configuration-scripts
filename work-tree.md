# Work Tree

## 2026-08-01 - Markdown preview mode + neo-tree/colorscheme cleanup

- Added `render-markdown.nvim` plugin so markdown files render styled (headers, checkboxes, code fences) by default instead of raw syntax, with `<leader>mp` mapped to `:RenderMarkdown toggle` to switch between preview and raw/code mode.
- Key file: `lua/plugins/render-markdown.lua` (new), plus `lazy-lock.json` updated for the new plugin lock entry.
- Cleaned up `lua/plugins/neo-tree.lua`: enabled `filesystem.use_libuv_file_watcher` for auto-refresh on external file changes, removed an old startup autocmd.
- Switched active colorscheme from catppuccin to ayu-dark (catppuccin commented out, `ayu.nvim` spec added) and removed the unused `mini.map` plugin.
- Both changes were committed directly to the nvim config git repo (`~/.config/nvim`) in separate commits during this session.

## 2026-08-02 - Neo-tree auto-open and force-refresh on focus

- Added a `VimEnter` autocmd that calls `require("neo-tree.command").execute({action = "show"})` so Neo-tree opens automatically on every Neovim startup instead of requiring `Ctrl+N`.
- Added a `FocusGained` autocmd that force-refreshes the filesystem source via `neo-tree.sources.manager`, covering cases the `use_libuv_file_watcher` misses (collapsed directories, git-status decorations for changes made externally, e.g. by Claude Code) — mirrors the existing buffer `checktime` `FocusGained` pattern in `vim-options.lua`.
- Also enabled `enable_git_status` and `git_status_async` in the `filesystem` config for git decoration support.
- Key file: `lua/plugins/neo-tree.lua`. Committed as "Auto-open neo-tree on startup and force-refresh on focus" (1031649).

## 2026-08-02 - Auto-copy mouse-drag visual selections to clipboard

- Terminal mouse reporting (needed for `mouse=a`: cursor placement, split resizing, Neo-tree clicks) was blocking iTerm2's native selection-to-clipboard copy, triggering its "disable mouse reporting?" prompt.
- Set `vim.opt.mouse = "a"` explicitly (modern Neovim only defaults to `"nvi"`).
- Added a `<LeftRelease>` mapping scoped to Visual mode only: checks whether the mouse actually dragged (compares `getpos("v")` vs `getpos(".")`) to avoid firing on a plain click, then yanks the selection into the `"+` register and shows a `vim.notify` message ("Copied N lines/chars to clipboard"). Normal-mode clicks, split-resizing, and Neo-tree clicks are unaffected since the mapping only applies in Visual mode.
- Deliberately did not set `clipboard = "unnamedplus"` globally, so ordinary deletes (`dd`, `x`, etc.) don't overwrite the system clipboard — only mouse-drag selections do.
- Key file: `lua/vim-options.lua`. Committed as "Auto-copy mouse-drag visual selections to system clipboard" (d3286bc).

## 2026-08-02 - Restored mini.map minimap on the right

- User wanted the minimap back after it was dropped in the 2026-08-01 cleanup (commit `9c205be`). Recreated `lua/plugins/mini-map.lua` with the same `echasnovski/mini.map` config as before: `window.side = 'right'`, `focusable = false`, `width = 20`, dot-encoded symbols, and a `BufRead` autocmd that calls `require('mini.map').open()` so it auto-opens for every buffer instead of needing a manual command.
- `lazy-lock.json` will get its `mini.map` lock entry automatically on the next lazy.nvim sync/install — not hand-edited.
- Key file: `lua/plugins/mini-map.lua` (re-added). Uncommitted, pending user approval — not yet requested by the user.

## 2026-08-02 - Fixed mini.map overlapping wrapped text

- User reported the minimap was visually covering wrapped line content in the editor. Researched `mini.map` source/docs: it always opens as a floating window (`relative='editor'`) and never shrinks the main buffer's window, so Neovim's `wrap` (which always wraps at the *full* window width) ran text underneath it. No built-in config option exists to change this.
- Presented the user three trade-off options (reserve real gutter space / shrink+fade the map / disable wrap); user chose "reserve real gutter space."
- Added `open_map_gutter()` in `lua/plugins/mini-map.lua`: opens a real, empty, fixed-width (`winfixwidth`, matches `MAP_WIDTH = 20`) scratch window via `botright vsplit` + `enew` on the far right on `VimEnter`/`TabNewEntered` (deferred with `vim.schedule` so it runs after startup/neo-tree settle), guarded per-tab via `vim.t.minimap_gutter_win` so it's only created once. This shrinks the main buffer's actual window width, so wrap now stops before the map instead of running underneath it; the map floats over the now-blank gutter instead of real text.
- Known caveat (not yet handled): if the user runs `:only` or otherwise closes the gutter window, it isn't automatically recreated until the next `VimEnter`/`TabNewEntered` (a full restart or new tab) — no `WinClosed` re-creation logic was added, kept intentionally minimal per user's chosen option.
- Key file: `lua/plugins/mini-map.lua`. Uncommitted, pending user approval.

## 2026-08-02 - Separate project-wide vs. current-document diagnostics view

- User wanted to see TypeScript errors and lint problems for the whole open project vs. just the currently open document, separately. Previously there was no lint diagnostics source at all (only `typescript-tools.nvim` type errors and `none-ls` formatting-only sources), and no aggregated list UI — just inline virtual text per buffer.
- Verified current API (via research) before implementing: `folke/trouble.nvim` v3's exact commands are `:Trouble diagnostics toggle` (whole workspace) and `:Trouble diagnostics toggle filter.buf=0` (current buffer only); `nvim-lspconfig`'s ESLint server is named `eslint` (backed by `vscode-eslint-language-server`, Mason package `eslint-lsp`).
- Added `lua/plugins/trouble.lua`: `folke/trouble.nvim` with keymaps `<leader>xw` (project-wide diagnostics list) and `<leader>xd` (current-document-only diagnostics list).
- Added `lspconfig.eslint.setup({capabilities = capabilities})` in `lua/plugins/lsp-config.lua` so ESLint problems publish as native `vim.diagnostic` (picked up automatically by Mason via `auto_install = true`), appearing in Trouble alongside `typescript-tools.nvim`'s type errors.
- User reported the `<leader>xw`/`<leader>xd` keymaps appeared to do nothing when tested; before root-causing, user instead asked for easier-to-use Ex commands. Added `:Err here` (current file) and `:Err all` (whole project) as a single `Err` user command with tab-completable `here`/`all` arguments, registered at file scope (not inside the plugin's lazy `config`/`opts`) so the command exists immediately at startup rather than only after `trouble.nvim` loads — it internally calls `:Trouble diagnostics toggle[ filter.buf=0]`, which is still what actually triggers the lazy load. Kept the original `<leader>xw`/`<leader>xd` keymaps as well.
- User tested `:Err all` with no files opened in the session and got "No results for diagnostics" despite knowing the project had TS errors on disk. Root cause: `vim.diagnostic`/Trouble's diagnostics source only reflects files the LSP has actually loaded into a buffer — it can't see errors in files never opened this session, so it isn't a true whole-project scan.
- Redesigned `:Err all` to run `tsc --noEmit --pretty false` and `eslint . -f unix` as real async CLI jobs (`vim.fn.jobstart`, cwd = `getcwd()`) in parallel, parse their plain-text output (tsc: `file(line,col): error TSxxxx: msg`; eslint unix formatter: `file:line:col: msg`) into the quickfix list, then open it via `:Trouble qflist toggle`. Notifies "Scanning project..." on start (since it's async) and reports stderr from either tool (e.g. missing `tsconfig.json`, `eslint`/`tsc` not installed locally) if zero results come back, instead of a bare "no results". Uses `npx --no-install` so it only runs binaries already present in the project's `node_modules`, never triggers a network install.
- `:Err here` unchanged — current-buffer LSP diagnostics, which are accurate the moment a file is open.
- Key files: `lua/plugins/trouble.lua` (new), `lua/plugins/lsp-config.lua`. Uncommitted, pending user testing/approval.

## 2026-08-02 - :Pwd command to show project root path

- Added `:Pwd` user command showing `vim.fn.getcwd()` (the project root, i.e. what neo-tree is rooted at) in a centered floating toast for 10 seconds, then auto-closing via `vim.defer_fn`.
- Deliberately did not use plain `vim.notify()` for this — with no notification plugin installed (checked: no `nvim-notify` or similar in `lazy-lock.json`), `vim.notify()` just echoes to the message area and stays until something else overwrites it, it doesn't auto-dismiss after a fixed duration. Built a dedicated floating window instead so the 10-second auto-close is guaranteed regardless of other activity.
- Key file: `lua/vim-options.lua`. Uncommitted, pending user testing/approval.

## 2026-08-02 - Unified toast notifications (bottom-right, then moved to top-right)

- User wanted the clipboard-copy message and `:Pwd`'s path display to both appear as toast notifications (not the plain message-area `vim.notify`) and auto-remove after 10 seconds.
- Refactored into a single shared `show_toast(text, duration)` helper in `lua/vim-options.lua`: floating window, auto-closed via `vim.defer_fn` after `duration` (default 10000ms). Tracks currently-visible toasts in `active_toasts` and stacks new ones so simultaneous toasts (e.g. a clipboard copy right after `:Pwd`) don't overlap/overwrite each other.
- Replaced the clipboard mapping's `vim.notify(...)` calls and `:Pwd`'s standalone floating window with calls to `show_toast(...)`.
- Initially anchored bottom-right (stacking upward); user then asked for top-right instead — changed to `row = 1` anchored at the top, stacking downward (`row += 3` per active toast), `col` unchanged (`vim.o.columns - width - 2`, right-aligned).
- Key file: `lua/vim-options.lua`. Uncommitted, pending user testing/approval.

## 2026-08-02 - Rust development setup (LSP, DAP, crates.nvim)

- User wanted full Rust support: LSP, formatting, treesitter, debugging, and Cargo.toml dependency management. Previously there was no Rust config at all in this repo.
- Added `lua/plugins/rust.lua`: `mrcjkb/rustaceanvim` (manages the rust-analyzer client itself, not via `lspconfig.rust_analyzer.setup()` — avoids a duplicate client) with clippy-on-save and `cargo.features = "all"`; keymaps `<leader>rr`/`rt`/`re`/`rd` (runnables/testables/expand-macro/debug). Also `saecki/crates.nvim` for Cargo.toml dependency version completion, lazy-loaded on `BufRead Cargo.toml`, keymaps `<leader>cu`/`cU` (update/upgrade crate).
- Added `lua/plugins/dap.lua`: `nvim-dap` + `nvim-dap-ui` + `jay-babu/mason-nvim-dap.nvim` (auto-installs the `codelldb` adapter via Mason, which rustaceanvim's `:RustLsp debug` auto-detects). Keymaps `<leader>db/dc/di/do/dO/dr/du` for breakpoint/continue/step/repl/toggle-ui.
- Edited `lua/plugins/lsp-config.lua`: added `rust_analyzer` to mason-lspconfig's `ensure_installed`. Discovered during verification that `auto_install = true` alone does NOT install it — that mechanism only fires when a server is set up via `lspconfig.<server>.setup()`, which rustaceanvim deliberately bypasses, so the binary was never being installed without this explicit entry.
- Edited `lua/plugins/treesitter.lua` (added `rust`, `toml` to `ensure_installed`) and `lua/plugins/completions.lua` (added `{ name = "crates" }` cmp source).
- Version note: pinned `rustaceanvim` to `version = "^5"` instead of the current `^6`, because v6 requires Neovim >= 0.11 and this machine runs 0.10.2 (Homebrew). `mason-lspconfig` and `typescript-tools.nvim` are drifting the same way (both warned about needing >= 0.11 during testing) — worth a `brew upgrade neovim` at some point, after which `rustaceanvim` can move back to `^6`.
- Verified end-to-end, not just written: ran `Lazy! restore`/`install` headlessly, confirmed rust-analyzer attaches on a real scratch `.rs` buffer with no duplicate client, confirmed `codelldb` installs via Mason, confirmed `crates.nvim` loads cleanly on `Cargo.toml`, confirmed clean headless startup with no Lua errors.
- Caught and reverted a self-inflicted regression during testing: an initial `Lazy! sync` (rather than `install`/`restore`) upgraded 27 unrelated pre-existing plugins and broke `mason-lspconfig` (nil `automatic_enable` field) — reverted `lazy-lock.json` to the committed version before proceeding, so only the new Rust/DAP plugins' lock entries changed.
- No Rust toolchain (`rustc`/`cargo`) is installed on this machine — user still needs `rustup` for rust-analyzer to fully load real project workspaces.
- Key files: `lua/plugins/rust.lua` (new), `lua/plugins/dap.lua` (new), `lua/plugins/lsp-config.lua`, `lua/plugins/treesitter.lua`, `lua/plugins/completions.lua`, `lazy-lock.json`. Uncommitted, pending user testing/approval.
