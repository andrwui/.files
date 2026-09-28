# muse.nvim

Chat with pi (Muse Spark) from a small right pane in Neovim, with real
editor context: current file, visual selections, diagnostics, LSP
hover/definition/references, and git diffs.

The backend is one long-lived `pi --mode rpc` process per project root, so
the conversation (including the agent's file edits and shell commands) keeps
state across messages. Responses stream token-by-token into the chat log.

```
┌────────────────────┬────────────────────┐
│ your code          │ ## ✨ Muse          │
│                    │ streamed markdown… │
│                    │ - tool `read` `…`  │
│                    │   - ok done        │
│                    ├────────────────────┤
│                    │ > your prompt…     │  input box
└────────────────────┴────────────────────┘
```

## Requirements

- `pi` on `$PATH` with auth configured (`pi` TUI → `/login`, or API keys).
  The plugin uses your pi defaults (`~/.pi/agent/settings.json`).
- `render-markdown.nvim` (already in this config) for pretty chat rendering.
  `dressing.nvim` (already here) makes the pickers/dialogs nicer.

## Usage

| Key / command | What it does |
|---|---|
| `<leader>mc` / `:Muse` | toggle the pane |
| `<leader>mf` | attach current file to next message |
| `<leader>mF` / `:MuseAddFile [path]` | pick a repo file to attach |
| `<leader>ms` (visual) | attach selection to next message |
| `<leader>md` / `<leader>mD` | attach buffer / line diagnostics |
| `<leader>ml` | attach LSP hover + definition + references for word under cursor |
| `<leader>mg` | attach unstaged git diff (`:MuseAddDiff staged` for staged) |
| `<leader>mn` / `:MuseNew` | fresh session (old one stays in `~/.pi/agent/sessions/`) |
| `<leader>ma` / `:MuseAbort` | stop the running response |
| `<leader>mm` / `:MuseModel` | switch model (all 60+ pi models) |
| `<leader>mt` / `:MuseThinking` | switch thinking level |
| `:MuseSend <text>` | send without opening input (`:'<,'>MuseSend …` adds range) |
| `:MuseRestart` | kill backend, fresh process + session (recovers wedges, picks up `rpc.lua` edits / new cwd) |
| `:MuseCompact` / `:MuseStats` / `:MuseExport` / `:MuseClear` | compact · tokens/cost · HTML export · clear log |

In the input box: `<CR>` or `<C-s>` sends. In the chat log: `q` closes. `C-c` in either pane stops the running response.

Attachments queue up (shown as `📎 …` above the input) and are prepended
to your next message. Or skip the queue and type **@-mentions** inline:

`@file` · `@selection` · `@diagnostics` · `@diag-line` · `@lsp` ·
`@diff` · `@diff-staged` · `@quickfix` · `@buffer:<name>`

```
> why is this slow? @selection @diagnostics
```

Permission prompts from pi extensions (allow/block, questions) pop up as
`vim.ui` dialogs — answer them and the agent continues.

## Config

In `lua/plugins/muse.lua` (`require("muse").setup({...})`):

```lua
{
  pi_bin = "pi",
  provider = nil,  -- nil = pi defaults; or "anthropic", "openai", …
  model = nil,     -- e.g. "anthropic/claude-sonnet-4-20250514"
  thinking = nil,  -- e.g. "high"
  session_name = "nvim-muse",
  approve = false, -- true = pass --approve (load project-local pi resources)
  resume = false,  -- true = --continue last session for this project
  width = 72,      -- pane width (<1 = fraction of screen)
  input_height = 10,
  show_thinking = true, -- stream thinking blocks as normal Muse text
  auto_focus_input = true,
  auto_attach_file = true, -- include current file buffer automatically on send
  auto_attach_diagnostics = true, -- include LSP diagnostics automatically (only when non-empty)
  max_auto_file_lines = 1200, -- truncate auto-attached file,
  system_extra = "…",    -- appended to the pi system prompt
}
```

## How it works

- `lua/muse/rpc.lua` — JSONL client for `pi --mode rpc` over stdio
  (`prompt`/`abort`/`new_session`/`set_model`/…, responses matched by `id`,
  partial-line buffering, `extension_ui_request` dialog support).
- `lua/muse/context.lua` — context gatherers + `@`-mention expansion.
- `lua/muse/ui.lua` — right split with chat log (`markdown`, rendered)
  and input box; buffers persist across toggle.
- `lua/muse/init.lua` — wiring: commands, keymaps, event → UI rendering,
  stats in the winbar.

## Hot-reload (tweak without restarting nvim)

Both the config and the plugin code are live-editable:

1. Edit setup opts in `lua/plugins/muse.lua`, or any code in `lua/muse/`.
2. Run `:MuseReload` (or `<leader>mR`).

The reload syntax-checks everything first (aborts safely on error), then
preserves: the open pane + full chat history, queued 📎 attachments,
input-box text, cursor focus, and even the live backend connection — your
pi session survives, only the Lua handlers are rewired. If a response was
mid-stream it continues below a fresh header.

## Troubleshooting

- `executable not found: pi` — install pi / fix `$PATH`.
- Empty/failed answers — check auth: run `pi` in a terminal once.
- Backend died (`backend exited…`) — next send auto-restarts it.
- Project-local pi extensions/skills ignored — set `approve = true`
  (trusts `.pi/` in the project, same as `pi --approve`).
