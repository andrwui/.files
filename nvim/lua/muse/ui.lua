-- muse/ui.lua — right-pane chat window + input box.
-- Layout (inside a right vertical split):
--   ┌──────────────┐
--   │ chat (md)    │  read-only log, rendered by render-markdown.nvim
--   ├──────────────┤
--   │ input (md)   │  type prompt, <CR>/<C-s> to send
--   └──────────────┘
-- Buffers survive close/open (named muse://chat, muse://input) so history
-- isn't lost by toggling.
local M = {}

local cfg = {}
local chat_buf, chat_win, input_buf, input_win
local assistant_open = false
local busy = false
local attachments = {} -- labels for the input winbar
local meta = "" -- "model · session · tok/cost" line
local on_send_hook = nil
local on_abort_hook = nil
local last_kind = nil -- "thinking" | "text" | nil: what streamed last in this turn

-- Permanent bottom-of-buffer status footer. The old inline "_thinking..._"
-- placeholder was pushed and removed within the same tick (before redraw),
-- so it never became visible. The footer instead lives as the last 3 lines
-- of the chat buffer at all times: "", "---", status.
local FOOTER_LEN = 3
local FOOTER_IDLE = "_○ idle — send a message (`i` for input)_"
local FOOTER_BUSY = "_● thinking... (`<C-c>` to stop)_"

local ns = vim.api.nvim_create_namespace("muse_chat")
local diff_ns = vim.api.nvim_create_namespace("muse_chat_diff")
local active_start = nil -- 0-indexed start row of the message being built
local active_group = nil

-- Nerd-Font icons, same set as opencode.nvim so the two panes read alike.
-- (Falls back gracefully: a missing glyph is just a box, text still legible.)
local ICONS = {
  reasoning = "󰧑 ",
  read = " ",
  edit = " ",
  write = " ",
  bash = " ",
  tool = " ",
  file = " ",
}

local reasoning_start = nil -- os.time() when thinking started this turn
local reasoning_header_row = nil -- 0-indexed buffer row of "** Reasoning**"

local function ensure_hl()
  -- subtle grays that read on dark monochrome + transparent Normal;
  -- light-bg fallback for completeness.
  -- Diff + gutter palette is strictly monochrome (no green/red): added =
  -- bright-on-dark-grey + bold, removed = dim grey, context = dim.
  -- Mirrors opencode.nvim's gutter/line structure, but in grey.
  if vim.o.background == "light" then
    vim.api.nvim_set_hl(0, "MuseChatUser", { bg = "#e8e8e8" })
    vim.api.nvim_set_hl(0, "MuseChatAssistant", { bg = "#f4f4f4" })
    vim.api.nvim_set_hl(0, "MuseDiffAdd", { bg = "#d8d8d8", fg = "#000000", bold = true })
    vim.api.nvim_set_hl(0, "MuseDiffDelete", { bg = "#efefef", fg = "#707070" })
    vim.api.nvim_set_hl(0, "MuseDiffContext", { fg = "#505050" })
    vim.api.nvim_set_hl(0, "MuseDiffGutter", { fg = "#909090", bg = "#e0e0e0" })
    vim.api.nvim_set_hl(0, "MuseDiffAddGutter", { fg = "#000000", bg = "#c8c8c8", bold = true })
    vim.api.nvim_set_hl(0, "MuseDiffDeleteGutter", { fg = "#707070", bg = "#e0e0e0" })
    vim.api.nvim_set_hl(0, "MuseReasoning", { fg = "#707070", italic = true })
  else
    vim.api.nvim_set_hl(0, "MuseChatUser", { bg = "#262626" })
    vim.api.nvim_set_hl(0, "MuseChatAssistant", { bg = "#1a1a1a" })
    vim.api.nvim_set_hl(0, "MuseDiffAdd", { bg = "#2e2e2e", fg = "#ffffff", bold = true })
    vim.api.nvim_set_hl(0, "MuseDiffDelete", { bg = "#222222", fg = "#808080" })
    vim.api.nvim_set_hl(0, "MuseDiffContext", { fg = "#a0a0a0" })
    vim.api.nvim_set_hl(0, "MuseDiffGutter", { fg = "#6b7280", bg = "#1a1a1a" })
    vim.api.nvim_set_hl(0, "MuseDiffAddGutter", { fg = "#ffffff", bg = "#2e2e2e", bold = true })
    vim.api.nvim_set_hl(0, "MuseDiffDeleteGutter", { fg = "#808080", bg = "#222222" })
    vim.api.nvim_set_hl(0, "MuseReasoning", { fg = "#808080", italic = true })
  end
end

local function hl_buf_valid()
  return chat_buf and vim.api.nvim_buf_is_valid(chat_buf)
end

local function footer_status()
  return busy and FOOTER_BUSY or FOOTER_IDLE
end

-- raw check, no writes: does the buffer currently end with the footer?
local function has_footer_raw()
  if not hl_buf_valid() then
    return false
  end
  local n = vim.api.nvim_buf_line_count(chat_buf)
  if n < FOOTER_LEN then
    return false
  end
  local ok, lines = pcall(vim.api.nvim_buf_get_lines, chat_buf, n - FOOTER_LEN, n, false)
  if not ok or not lines or #lines ~= FOOTER_LEN then
    return false
  end
  return lines[1] == "" and lines[2] == "---" and type(lines[3]) == "string" and lines[3]:match("^_[○●]") ~= nil
end

-- drop legacy inline placeholder left by older versions (exact match only)
local function clear_legacy_placeholder_raw()
  local ok, lines = pcall(vim.api.nvim_buf_get_lines, chat_buf, 0, -1, false)
  if not ok or not lines then
    return
  end
  for i = #lines, 1, -1 do
    if lines[i] == "_thinking..._" then
      pcall(vim.api.nvim_buf_set_lines, chat_buf, i - 1, i, false, {})
    end
  end
end

-- caller must hold modifiable (i.e. inside M._write)
local function ensure_footer_raw()
  if has_footer_raw() then
    return
  end
  clear_legacy_placeholder_raw()
  if has_footer_raw() then
    return
  end
  pcall(vim.api.nvim_buf_set_lines, chat_buf, -1, -1, false, { "", "---", footer_status() })
end

local function update_footer_raw()
  if not hl_buf_valid() then
    return
  end
  -- status flips are rare (not per-delta), so sweep legacy placeholders here
  -- even when the footer already exists (upgrade from old inline indicator).
  clear_legacy_placeholder_raw()
  ensure_footer_raw()
  local n = vim.api.nvim_buf_line_count(chat_buf)
  if n < 1 then
    return
  end
  pcall(vim.api.nvim_buf_set_lines, chat_buf, n - 1, n, false, { footer_status() })
end

local function ensure_footer()
  if not hl_buf_valid() then
    return
  end
  M._write(function()
    ensure_footer_raw()
  end)
end

local function update_footer()
  if not hl_buf_valid() then
    return
  end
  M._write(function()
    update_footer_raw()
  end)
end

local function hl_start(group)
  if not hl_buf_valid() then
    return
  end
  ensure_hl()
  -- highlight content only, never the footer
  local n = vim.api.nvim_buf_line_count(chat_buf)
  if has_footer_raw() then
    n = n - FOOTER_LEN
  end
  active_start = n
  active_group = group
end

local function hl_end()
  if not active_start or not active_group then
    return
  end
  if not hl_buf_valid() then
    active_start, active_group = nil, nil
    return
  end
  local s, g = active_start, active_group
  active_start, active_group = nil, nil
  local e = vim.api.nvim_buf_line_count(chat_buf)
  if has_footer_raw() then
    e = e - FOOTER_LEN
  end
  if e <= s then
    return
  end
  pcall(vim.api.nvim_buf_set_extmark, chat_buf, ns, s, 0, {
    end_row = e,
    end_col = 0,
    line_hl_group = g,
    hl_eol = true,
    strict = false,
  })
end

local function hl_clear()
  active_start, active_group = nil, nil
  reasoning_start, reasoning_header_row = nil, nil
  if hl_buf_valid() then
    pcall(vim.api.nvim_buf_clear_namespace, chat_buf, ns, 0, -1)
    pcall(vim.api.nvim_buf_clear_namespace, chat_buf, diff_ns, 0, -1)
  end
end

-- filetype for a code fence, same rule as opencode.nvim:
-- vim.filetype.match first, then extension fallback.
local function fence_ft_for_path(path)
  if not path or path == "" or path == "?" then
    return ""
  end
  local ok, ft = pcall(vim.filetype.match, { filename = path })
  if ok and ft and ft ~= "" then
    return ft
  end
  local ext = path:match("%.([%w_%-]+)$")
  return ext or ""
end

-- Parse pi's compact diff (generateDiffString): lines look like
--   " 14 content"  context
--   "+18 content"  added
--   "-13 content"  removed
--   "    ..."      collapsed run
-- Returns entries + max lnum width, or nil when text isn't pi-diff.
local function parse_pi_diff(text)
  local raw = vim.split(text, "\n", { plain = true })
  local entries, pi_like, total = {}, 0, 0
  local max_w = 1
  for _, line in ipairs(raw) do
    total = total + 1
    if line:match("^%s*%.%.%.$") or line:match("^%s+%.%.%.$") then
      entries[#entries + 1] = { kind = "skip" }
      pi_like = pi_like + 1
    else
      local prefix, num, content = line:match("^([+%- ])(%s*%d*)%s?(.*)$")
      -- pi always emits a line number (or blank for skip); a bare
      -- unified-diff line like "+foo" has no number gap, so require
      -- the shape "<sign><num><space>" to avoid misfiring on real code.
      if prefix and num and num:match("%d") then
        local kind = prefix == "+" and "add" or prefix == "-" and "del" or "ctx"
        num = num:gsub("%s+", "")
        if #num > max_w then
          max_w = #num
        end
        entries[#entries + 1] = { kind = kind, lnum = num, sign = prefix, content = content }
        pi_like = pi_like + 1
      else
        entries[#entries + 1] = { kind = "raw", content = line }
      end
    end
  end
  if total > 0 and pi_like / total >= 0.5 then
    return entries, max_w
  end
  return nil, nil
end

function M.setup(config)
  cfg = config
end

function M.on_send(fn)
  on_send_hook = fn
end

function M.on_abort(fn)
  on_abort_hook = fn
end

local function do_abort()
  if on_abort_hook then
    on_abort_hook()
  end
end

local function valid(v, kind)
  if kind == "buf" then
    return v and vim.api.nvim_buf_is_valid(v)
  end
  return v and vim.api.nvim_win_is_valid(v)
end

function M.is_open()
  return valid(chat_win, "win") and valid(chat_buf, "buf")
end

local function width()
  local w = cfg.width or 72
  if w < 1 then
    w = math.floor(vim.o.columns * w)
  end
  return math.max(40, math.min(w, math.floor(vim.o.columns * 0.6)))
end

local function input_height()
  return math.max(6, math.min(cfg.input_height or 10, math.floor(vim.o.lines * 0.3)))
end

local function mkbuf(name, ft)
  local existing = vim.fn.bufnr(name)
  if existing ~= -1 and vim.api.nvim_buf_is_valid(existing) then
    return existing
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, name)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.bo[buf].undolevels = -1
  vim.bo[buf].filetype = ft
  return buf
end

local function set_win_opts(win, is_input)
  local function set(name, val)
    pcall(vim.api.nvim_set_option_value, name, val, { win = win })
  end
  set("number", false)
  set("relativenumber", false)
  set("signcolumn", "no")
  set("foldcolumn", "0")
  set("wrap", true)
  set("linebreak", true)
  set("breakindent", true)
  set("cursorline", false)
  set("winfixwidth", true)
  set("spell", false)
  if not is_input then
    set("conceallevel", 2)
  end
end

local function refresh_winbars()
  local state = busy and "thinking" or "idle"
  if valid(chat_win, "win") then
    local left = (" Muse %s %s"):format(state, meta ~= "" and ("· " .. meta) or "")
    pcall(
      vim.api.nvim_set_option_value,
      "winbar",
      left .. "%=" .. "(q: close)",
      { win = chat_win }
    )
  end
  if valid(input_win, "win") then
    local att = #attachments > 0 and ("attached: " .. table.concat(attachments, " · ") .. "  ") or ""
    pcall(
      vim.api.nvim_set_option_value,
      "winbar",
      (" %s<C-s>/<CR>: send"):format(att),
      { win = input_win }
    )
  end
end

function M.set_status(is_busy)
  busy = is_busy
  refresh_winbars()
  update_footer()
end

function M.set_attachments(labels)
  attachments = labels or {}
  refresh_winbars()
end

function M.set_meta(text)
  meta = text or ""
  refresh_winbars()
end

local function map_input()
  local opts = { buffer = input_buf, noremap = true, silent = true }
  vim.keymap.set("n", "<CR>", function()
    if on_send_hook then
      on_send_hook()
    end
  end, opts)
  vim.keymap.set({ "n", "i" }, "<C-s>", function()
    if on_send_hook then
      on_send_hook()
    end
  end, opts)
  vim.keymap.set({ "n", "i", "v" }, "<C-c>", function()
    do_abort()
  end, vim.tbl_extend("force", opts, { desc = "Muse: stop response" }))
end

local function map_chat()
  vim.keymap.set("n", "q", function()
    M.close()
  end, { buffer = chat_buf, noremap = true, silent = true, desc = "Close Muse chat" })
  vim.keymap.set({ "n", "v" }, "<C-c>", function()
    do_abort()
  end, { buffer = chat_buf, noremap = true, silent = true, desc = "Muse: stop response" })
  -- `i` (and friends) jumps to the input box, since the log is read-only
  for _, lhs in ipairs({ "i", "a", "o", "I", "A" }) do
    vim.keymap.set("n", lhs, function()
      M.focus_input()
      vim.cmd("startinsert")
    end, { buffer = chat_buf, noremap = true, silent = true, desc = "Muse: focus input" })
  end
end

local WELCOME = {
  "# Muse chat",
  "",
  "Ask about the codebase. Attach context first, or use @-mentions inline:",
  "",
  "- `@file` — current buffer · `@selection` — visual selection",
  "- `@diagnostics` / `@diag-line` — LSP diagnostics",
  "- `@lsp` — hover + definition + references for word under cursor",
  "- `@diff` / `@diff-staged` — git diff · `@quickfix` · `@buffer:<name>`",
  "",
  "Keys: `<leader>mf` file · `<leader>ms` selection (visual) · `<leader>md` diagnostics",
  "· `<leader>ml` symbol · `<leader>mg` diff · `<leader>mn` new chat · `<leader>ma` stop",
  "",
  "---",
  "",
}

function M.open()
  if M.is_open() then
    ensure_footer()
    M.focus_input()
    return
  end
  chat_buf = mkbuf("muse://chat", "markdown")
  input_buf = mkbuf("muse://input", "markdown")
  ensure_hl()
  -- input stays plain text; chat keeps full rendering.
  -- NB: `disable` is global, so use buffer-local variants.
  -- (render-markdown.lua `ignore` keeps input plain across lazy-loads.)
  vim.api.nvim_buf_call(input_buf, function()
    pcall(vim.cmd, "RenderMarkdown buf_disable")
  end)
  vim.api.nvim_buf_call(chat_buf, function()
    pcall(vim.cmd, "RenderMarkdown buf_enable")
  end)

  vim.cmd("botright vsplit")
  vim.cmd("vertical resize " .. width())
  chat_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(chat_win, chat_buf)
  set_win_opts(chat_win, false)
  map_chat()

  vim.cmd("belowright split")
  vim.cmd("resize " .. input_height())
  input_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(input_win, input_buf)
  set_win_opts(input_win, true)
  map_input()

  -- back to chat to keep layout: chat on top, input below
  if vim.api.nvim_buf_line_count(chat_buf) == 1 and vim.api.nvim_buf_get_lines(chat_buf, 0, 1, false)[1] == "" then
    M._write(function()
      vim.api.nvim_buf_set_lines(chat_buf, 0, -1, false, WELCOME)
    end)
  end
  ensure_footer()
  update_footer()
  refresh_winbars()
  if cfg.auto_focus_input ~= false then
    M.focus_input()
  end
end

function M.close()
  for _, w in ipairs({ input_win, chat_win }) do
    if valid(w, "win") then
      pcall(vim.api.nvim_win_close, w, false)
    end
  end
  chat_win, input_win = nil, nil
end

function M.toggle()
  if M.is_open() then
    M.close()
  else
    M.open()
  end
end

function M.focus_input()
  if valid(input_win, "win") then
    vim.api.nvim_set_current_win(input_win)
  elseif M.is_open() then
    M.open()
  end
end

function M.focus_chat()
  if valid(chat_win, "win") then
    vim.api.nvim_set_current_win(chat_win)
  end
end

--- Which part of the pane holds the cursor: "input", "chat", or nil.
function M.current_part()
  local cur = vim.api.nvim_get_current_win()
  if valid(input_win, "win") and cur == input_win then
    return "input"
  end
  if valid(chat_win, "win") and cur == chat_win then
    return "chat"
  end
  return nil
end

-- writing ---------------------------------------------------------------

--- Run fn with the chat buffer modifiable. Internal but exposed for init.
function M._write(fn)
  if not valid(chat_buf, "buf") then
    return
  end
  local at_bottom = true
  if valid(chat_win, "win") then
    local cur = vim.api.nvim_win_get_cursor(chat_win)[1]
    at_bottom = cur >= vim.api.nvim_buf_line_count(chat_buf) - 4
  end
  vim.bo[chat_buf].modifiable = true
  pcall(fn)
  vim.bo[chat_buf].modifiable = false
  vim.bo[chat_buf].modified = false
  if at_bottom and valid(chat_win, "win") then
    pcall(vim.api.nvim_win_set_cursor, chat_win, { vim.api.nvim_buf_line_count(chat_buf), 0 })
  end
end

local function push(lines)
  if not hl_buf_valid() then
    return nil
  end
  local at_row = nil
  M._write(function()
    ensure_footer_raw()
    local n = vim.api.nvim_buf_line_count(chat_buf)
    local at = n - FOOTER_LEN -- 0-indexed insertion point before footer
    if at < 0 then
      at = n
    end
    at_row = at
    vim.api.nvim_buf_set_lines(chat_buf, at, at, false, lines)
  end)
  return at_row
end

-- Like push(), but applies a gutter + monochrome line highlight to the
-- pushed code-content rows (opencode.nvim layout, grey palette).
-- `marks` is aligned with `lines`: one entry per line, nil for fences.
local function push_with_marks(lines, marks)
  local at_row = push(lines)
  if not at_row or not marks then
    return
  end
  M._write(function()
    for i = 1, math.max(#lines, #marks) do
      local m = marks[i]
      if m then
        local row = at_row + (i - 1)
        local opts = {
          virt_text = { { m.gutter, m.gutter_hl }, { m.sign, m.gutter_hl }, { " ", m.gutter_hl } },
          virt_text_pos = "overlay",
          priority = 5000,
          strict = false,
        }
        if m.line_hl then
          opts.line_hl_group = m.line_hl
          opts.hl_eol = true
        end
        pcall(vim.api.nvim_buf_set_extmark, chat_buf, diff_ns, row, 0, opts)
      end
    end
  end)
end

local function stamp()
  return os.date("%H:%M")
end

function M.append_user(display, label_note)
  hl_start("MuseChatUser")
  push({ "", "---", "", ("## You · %s"):format(stamp()), "" })
  -- keep the log readable: very long messages fold into <details>
  local lines = vim.split(display, "\n", { plain = true })
  if #lines > 30 then
    local head = {}
    for i = 1, 12 do
      head[#head + 1] = lines[i]
    end
    head[#head + 1] = ""
    head[#head + 1] = "<details><summary>… full message (" .. #lines .. " lines)</summary>"
    head[#head + 1] = ""
    for i = 13, #lines do
      head[#head + 1] = lines[i]
    end
    head[#head + 1] = ""
    head[#head + 1] = "</details>"
    lines = head
  end
  push(lines)
  if label_note and label_note ~= "" then
    push({ "", ("> attached: %s"):format(label_note) })
  end
  push({ "" })
  hl_end()
end

function M.assistant_begin()
  if assistant_open then
    return
  end
  assistant_open = true
  last_kind = nil
  reasoning_start, reasoning_header_row = nil, nil
  hl_start("MuseChatAssistant")
  push({ ("## Muse · %s"):format(stamp()), "" })
  update_footer()
end

-- Rewrite the "** Reasoning**" header in place to include elapsed time,
-- e.g. "** Reasoning 3s**" like opencode.nvim. Row is stable: later
-- pushes insert before the footer, always after this header.
local function finalize_reasoning_header()
  if not reasoning_header_row or not reasoning_start then
    return
  end
  local secs = os.difftime(os.time(), reasoning_start)
  if secs < 0 then
    secs = 0
  end
  local label = secs > 0 and ("**%sReasoning %ds**"):format(ICONS.reasoning, secs)
    or ("**%sReasoning**"):format(ICONS.reasoning)
  M._write(function()
    pcall(vim.api.nvim_buf_set_lines, chat_buf, reasoning_header_row, reasoning_header_row + 1, false, { label, "" })
  end)
  reasoning_start, reasoning_header_row = nil, nil
end

--- Append a streaming delta to the content above the footer.
local function append_raw(delta)
  if not hl_buf_valid() then
    return
  end
  M._write(function()
    ensure_footer_raw()
    local n = vim.api.nvim_buf_line_count(chat_buf)
    local last_idx = n - FOOTER_LEN - 1 -- 0-indexed last content line
    if last_idx < 0 then
      return
    end
    local parts = vim.split(delta, "\n", { plain = true })
    local last = vim.api.nvim_buf_get_lines(chat_buf, last_idx, last_idx + 1, false)[1] or ""
    vim.api.nvim_buf_set_lines(chat_buf, last_idx, last_idx + 1, false, { last .. parts[1] })
    if #parts > 1 then
      local rest = {}
      for i = 2, #parts do
        rest[#rest + 1] = parts[i]
      end
      vim.api.nvim_buf_set_lines(chat_buf, last_idx + 1, last_idx + 1, false, rest)
    end
  end)
end

function M.append_delta(delta)
  if not assistant_open then
    M.assistant_begin()
  end
  -- thinking ran first: stamp its duration and break onto a fresh
  -- paragraph before the answer (mirrors opencode's Reasoning block).
  if last_kind == "thinking" then
    finalize_reasoning_header()
    push({ "", "" })
  end
  last_kind = "text"
  if delta and delta ~= "" then
    append_raw(delta)
  end
end

--- Thinking streams as its own Reasoning block (opencode.nvim layout,
--- monochrome): a bold header once, then plain text below it.
function M.append_thinking_delta(delta)
  if not assistant_open then
    M.assistant_begin()
  end
  if last_kind ~= "thinking" then
    reasoning_start = os.time()
    local at = push({ ("**%sReasoning**"):format(ICONS.reasoning), "" })
    -- header text is the first pushed line
    if at then
      reasoning_header_row = at
    end
  end
  last_kind = "thinking"
  if delta and delta ~= "" then
    append_raw(delta)
  end
end

--- Show the CWD-relative path for file tools.
local function display_path(path)
  if not path or path == "" then
    return "?"
  end
  local cwd = vim.fn.getcwd()
  if cwd ~= "" and vim.startswith(path, cwd .. "/") then
    return path:sub(#cwd + 2)
  end
  return vim.fn.fnamemodify(path, ":~")
end

local function tool_icon(name)
  if name == "read" then
    return ICONS.read
  elseif name == "edit" then
    return ICONS.edit
  elseif name == "write" then
    return ICONS.write
  elseif name == "bash" then
    return ICONS.bash
  else
    return ICONS.tool
  end
end

function M.append_tool_start(name, preview)
  if not assistant_open then
    M.assistant_begin()
  end
  -- thinking -> tool: stamp Reasoning duration first
  if last_kind == "thinking" then
    finalize_reasoning_header()
  end
  last_kind = "tool"
  preview = preview and preview:gsub("\n", " / ") or ""
  if #preview > 120 then
    preview = preview:sub(1, 117) .. "..."
  end
  -- opencode.nvim action line, monochrome: bold header + `path`, no color.
  -- File previews use a CWD-relative path so the 72-col pane doesn't wrap.
  local detail = ""
  if preview ~= "" then
    if name == "read" or name == "edit" or name == "write" then
      preview = display_path(preview)
    end
    detail = (" `%s`"):format(preview)
  end
  push({ "", (("**%s%s**%s"):format(tool_icon(name), name, detail)), "" })
end

local MAX_TOOL_LINES = 120

local function result_texts(result)
  if type(result) ~= "table" then
    return {}
  end
  local c = result.content
  if type(c) == "string" then
    return c ~= "" and { c } or {}
  end
  if type(c) ~= "table" then
    return {}
  end
  local out = {}
  for _, b in ipairs(c) do
    if type(b) == "table" and b.type == "text" and b.text and b.text ~= "" then
      out[#out + 1] = b.text
    elseif type(b) == "string" and b ~= "" then
      out[#out + 1] = b
    end
  end
  return out
end

local function push_truncated_fence(ft, text, max_lines)
  max_lines = max_lines or MAX_TOOL_LINES
  local lines = vim.split(text, "\n", { plain = true })
  local truncated = false
  if #lines > max_lines then
    truncated = true
    local kept = {}
    for i = 1, max_lines do
      kept[i] = lines[i]
    end
    lines = kept
  end
  -- use a 5-backtick fence when the payload itself contains ```
  -- (same rule as opencode.nvim's format_code/format_diff)
  local fence = "```"
  if text:find("```", 1, true) then
    fence = "`````"
  end
  local block = { (fence .. "%s"):format(ft or "") }
  for _, l in ipairs(lines) do
    block[#block + 1] = l
  end
  if truncated then
    block[#block + 1] = ("... (truncated, %d more lines)"):format(#vim.split(text, "\n", { plain = true }) - max_lines)
  end
  block[#block + 1] = fence
  block[#block + 1] = ""
  push(block)
end

-- Render pi's compact diff the way opencode.nvim renders edits, but in
-- monochrome: a filetype fence (so the file's own syntax highlights)
-- plus a virtual-text gutter (line number + +/-) and a grey line
-- background for added/removed rows. Falls back to a plain ```diff
-- fence when the text isn't pi-diff shaped (e.g. unified patch).
local function push_pi_diff(path, diff_text, max_lines)
  max_lines = max_lines or 80
  local entries, max_w = parse_pi_diff(diff_text)
  if not entries then
    push_truncated_fence("diff", diff_text, max_lines)
    return
  end
  local ft = fence_ft_for_path(path or "")
  -- truncate to the hunk, keep the shape stable
  if #entries > max_lines then
    local kept = {}
    for i = 1, max_lines do
      kept[i] = entries[i]
    end
    entries = kept
  end
  local truncated = #vim.split(diff_text, "\n", { plain = true }) - #entries
  -- does any content line contain a fence? then go long.
  local fence = "```"
  for _, e in ipairs(entries) do
    if e.content and e.content:find("```", 1, true) then
      fence = "`````"
      break
    end
  end
  local block, marks = {}, {}
  block[1], marks[1] = (fence .. "%s"):format(ft), nil
  for _, e in ipairs(entries) do
    if e.kind == "skip" then
      block[#block + 1] = string.rep(" ", max_w + 2) .. "..."
      marks[#block] = {
        gutter = string.rep(" ", max_w),
        sign = " ",
        gutter_hl = "MuseDiffGutter",
        line_hl = nil,
      }
    elseif e.kind == "raw" then
      block[#block + 1] = e.content
      marks[#block] = nil -- fence-adjacent raw line, no gutter
    else
      local content = e.content or ""
      block[#block + 1] = string.rep(" ", max_w + 2) .. content
      local gutter = string.format("%" .. max_w .. "s", e.lnum or "")
      if e.kind == "add" then
        marks[#block] = {
          gutter = gutter,
          sign = "+",
          gutter_hl = "MuseDiffAddGutter",
          line_hl = "MuseDiffAdd",
        }
      elseif e.kind == "del" then
        marks[#block] = {
          gutter = gutter,
          sign = "-",
          gutter_hl = "MuseDiffDeleteGutter",
          line_hl = "MuseDiffDelete",
        }
      else
        marks[#block] = {
          gutter = gutter,
          sign = " ",
          gutter_hl = "MuseDiffGutter",
          line_hl = nil,
        }
      end
    end
  end
  if truncated and truncated > 0 then
    block[#block + 1] = ("... (truncated, %d more lines)"):format(truncated)
    marks[#block] = nil
  end
  block[#block + 1] = fence
  marks[#block] = nil
  block[#block + 1] = ""
  marks[#block] = nil
  push_with_marks(block, marks)
end

--- Render a finished tool call. Header was already pushed by
--- append_tool_start (opencode.nvim style), so success is quiet:
--- reads/writes show nothing more, edits show the filetype diff with a
--- monochrome gutter, other tools show truncated output only when
--- meaningful. Errors always surface.
function M.append_tool_end(ok, name, args, result)
  name = name or "tool"
  args = (type(args) == "table") and args or {}
  result = (type(result) == "table") and result or {}
  local path = args.path or args.file
  local details = result.details
  if type(details) ~= "table" then
    details = nil
  end
  -- header (from tool_start) already names the file; a successful read
  -- needs no extra line. Surface failures only.
  if name == "read" then
    if not ok then
      push({ "> error reading `" .. display_path(path or "?") .. "`", "" })
    end
    return
  end
  -- edit: filetype fence + monochrome gutter (pi diff already collapses
  -- unchanged runs with `...`; patch fallback uses a plain diff fence)
  if name == "edit" and details and (details.diff or details.patch) then
    local raw_path = path or "?"
    local diff_text = details.diff or details.patch
    if not ok then
      push({ "> error editing `" .. display_path(raw_path) .. "`", "" })
    end
    if details.diff then
      push_pi_diff(raw_path, diff_text, 80)
    else
      push_truncated_fence("diff", diff_text, 80)
    end
    return
  end
  -- write: header already names the file. Show the new content as a
  -- filetype block when we have it (like opencode), else stay quiet.
  if name == "write" then
    if not ok then
      push({ "> error writing `" .. display_path(path or "?") .. "`", "" })
      local texts = result_texts(result)
      if #texts > 0 then
        push_truncated_fence(nil, table.concat(texts, "\n"))
      end
      return
    end
    local content = args.content
    if type(content) == "string" and content ~= "" then
      local ft = fence_ft_for_path(path or "")
      push_truncated_fence(ft, content, 80)
    end
    return
  end
  local texts = result_texts(result)
  local body = table.concat(texts, "\n")
  if body:match("^%s*$") then
    if result.truncated then
      body = "output truncated, see full log"
    elseif not ok then
      body = "failed"
    else
      -- quiet success: header from tool_start already says what ran.
      return
    end
  end
  -- hide boilerplate one-liners in favor of real content (header suffices)
  local first = body:gsub("^%s+", ""):match("[^\n]*") or ""
  local boilerplate = first:match("^Successfully replaced") or first:match("^Successfully wrote")
  if boilerplate and #texts <= 1 and #vim.split(body, "\n", { plain = true }) == 1 then
    if ok then
      return
    end
  end
  if not ok then
    push({ "> error", "" })
  end
  push_truncated_fence(nil, body)
end

function M.assistant_end()
  -- response ended while still thinking (no text/tools followed):
  -- stamp the Reasoning duration so the header isn't left open.
  if last_kind == "thinking" then
    finalize_reasoning_header()
  end
  last_kind = nil
  reasoning_start, reasoning_header_row = nil, nil
  if assistant_open then
    assistant_open = false
    hl_end()
    push({ "" })
  end
end

function M.append_system(text)
  push({ "", ("> %s"):format(text), "" })
end

function M.append_error(text)
  push({ "", ("> error: %s"):format(text), "" })
end

function M.clear_chat()
  assistant_open = false
  last_kind = nil
  hl_clear()
  M._write(function()
    vim.api.nvim_buf_set_lines(chat_buf, 0, -1, false, WELCOME)
    ensure_footer_raw()
    update_footer_raw()
  end)
end

-- input -----------------------------------------------------------------

function M.get_input()
  if not valid(input_buf, "buf") then
    return ""
  end
  return table.concat(vim.api.nvim_buf_get_lines(input_buf, 0, -1, false), "\n")
end

function M.clear_input()
  if valid(input_buf, "buf") then
    vim.api.nvim_buf_set_lines(input_buf, 0, -1, false, {})
  end
end

function M.set_input(text)
  if not valid(input_buf, "buf") then
    input_buf = mkbuf("muse://input", "markdown")
  end
  vim.api.nvim_buf_set_lines(input_buf, 0, -1, false, vim.split(text or "", "\n", { plain = true }))
end

-- history restore --------------------------------------------------------

local function content_text(content)
  if type(content) == "string" then
    return content
  end
  if type(content) ~= "table" then
    return ""
  end
  local out = {}
  for _, block in ipairs(content) do
    if type(block) == "table" then
      if block.type == "text" and block.text then
        out[#out + 1] = block.text
      elseif block.type == "thinking" and block.thinking and block.thinking ~= "" then
        out[#out + 1] = block.thinking
      elseif block.type == "image" then
        out[#out + 1] = "[image]"
      end
    elseif type(block) == "string" then
      out[#out + 1] = block
    end
  end
  return table.concat(out, "\n")
end

--- Render past AgentMessages (from get_messages) into the log.
function M.render_messages(messages)
  if not messages or #messages == 0 then
    return
  end
  local show = messages
  local skipped = 0
  if #messages > 60 then
    skipped = #messages - 60
    show = vim.list_slice(messages, #messages - 59, #messages)
  end
  M._write(function()
    vim.api.nvim_buf_set_lines(chat_buf, 0, -1, false, WELCOME)
  end)
  hl_clear()
  if skipped > 0 then
    push({ "", ("> showing last %d of %d messages"):format(#show, #messages), "" })
  end
  for _, m in ipairs(show) do
    if m.role == "user" then
      local t = content_text(m.content)
      if t ~= "" then
        hl_start("MuseChatUser")
        push({ "", "---", "", "## You", "" })
        push(vim.split(t, "\n", { plain = true }))
        push({ "" })
        hl_end()
      end
    elseif m.role == "assistant" then
      hl_start("MuseChatAssistant")
      push({ "## Muse", "" })
      local texts, thinkings, tools = {}, {}, {}
      for _, b in ipairs(m.content or {}) do
        if b.type == "text" and b.text and b.text ~= "" then
          texts[#texts + 1] = b.text
        elseif b.type == "thinking" and b.thinking and b.thinking ~= "" then
          thinkings[#thinkings + 1] = b.thinking
        elseif b.type == "toolCall" then
          local icon = (b.name == "read" and ICONS.read)
            or (b.name == "edit" and ICONS.edit)
            or (b.name == "write" and ICONS.write)
            or (b.name == "bash" and ICONS.bash)
            or ICONS.tool
          tools[#tools + 1] = (("**%s%s**"):format(icon, b.name or "?"))
        end
      end
      if #thinkings > 0 then
        push({ (("**%sReasoning**"):format(ICONS.reasoning)), "" })
        push(vim.split(table.concat(thinkings, "\n"), "\n", { plain = true }))
        push({ "", "" })
      end
      if #texts > 0 then
        push(vim.split(table.concat(texts, "\n"), "\n", { plain = true }))
      end
      if #tools > 0 then
        push({ "" })
        push(tools)
      end
      push({ "" })
      hl_end()
    end
  end
end

return M
