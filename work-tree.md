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
