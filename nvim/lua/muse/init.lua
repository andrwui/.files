-- muse/init.lua — chat with pi (Muse Spark) from a right-side pane.
-- Backend: `pi --mode rpc` (one process per project root). Context: current
-- file, visual selections, diagnostics, LSP hover/definition/references,
-- git diffs — via explicit attaches or @-mentions typed in the input box.
local M = {}

local rpc = require("muse.rpc")
local ctx = require("muse.context")
local ui = require("muse.ui")

M.config = {
  pi_bin = "pi",
  provider = nil, -- nil = pi defaults (your ~/.pi/agent/settings.json)
  model = nil, -- e.g. "anthropic/claude-sonnet-4-20250514"
  thinking = nil, -- e.g. "high"
  session_name = "nvim-muse",
  approve = false, -- pass --approve (trust project-local pi resources)
  resume = false, -- pass --continue (reopen last session for this project)
  width = 72, -- columns, or <1 as fraction of total width
  input_height = 10,
  show_thinking = true, -- stream thinking blocks as normal Muse text
  auto_focus_input = true,
  auto_attach_file = true, -- include current file buffer automatically on send
  auto_attach_diagnostics = true, -- include LSP diagnostics automatically (only when non-empty)
  max_auto_file_lines = 1200, -- truncate auto-attached file to this many lines,
  system_extra = "You are chatting inside Neovim via a side pane. "
    .. "File/diagnostic/LSP context the user attaches is pasted inline as markdown. "
    .. "Keep answers concise, use markdown, reference code as `path:line`. "
    .. "Do not use emojis in your responses. "
    .. "You can read/edit files and run commands with your tools when asked.",
}

M.pending = {} -- attachments queued for the next message
M.client = nil
M._ready = false
M._cancel_pending = false -- set by abort(), consumed by agent_settled (shows "Request cancelled" once)
M.tool_args = {} -- toolCallId -> args (cached on start, used on end for diff paths)

local function pending_labels()
  local out = {}
  for _, p in ipairs(M.pending) do
    out[#out + 1] = p.label
  end
  return out
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  ui.setup(M.config)
  ui.on_send(function()
    M.send()
  end)
  ui.on_abort(function()
    M.abort()
  end)

  -- commands ---------------------------------------------------------------
  local function cmd(name, fn, copts)
    vim.api.nvim_create_user_command(name, fn, copts or {})
  end
  cmd("Muse", function()
    M.toggle()
  end, { desc = "Toggle Muse chat pane" })
  cmd("MuseToggle", function()
    M.toggle()
  end, { desc = "Toggle Muse chat pane" })
  cmd("MuseOpen", function()
    M.open()
  end, { desc = "Open Muse chat pane" })
  cmd("MuseClose", function()
    ui.close()
  end, { desc = "Close Muse chat pane" })
  cmd("MuseSend", function(o)
    M.send_cmd(o)
  end, { desc = "Send prompt to Muse (range adds those lines as context)", nargs = "*", range = true })
  cmd("MuseNew", function()
    M.new_session()
  end, { desc = "Start a fresh Muse session" })
  cmd("MuseAbort", function()
    M.abort()
  end, { desc = "Stop the running Muse response" })
  cmd("MuseAddFile", function(o)
    M.add_file(o.args ~= "" and o.args or nil)
  end, { desc = "Attach file to next message (:MuseAddFile [path])", nargs = "?", complete = "file" })
  cmd("MuseAddSelection", function()
    M.add_selection()
  end, { desc = "Attach visual selection to next message", range = true })
  cmd("MuseAddDiagnostics", function()
    M.add_diagnostics(false)
  end, { desc = "Attach buffer diagnostics to next message" })
  cmd("MuseAddLSP", function()
    M.add_lsp()
  end, { desc = "Attach LSP symbol info to next message" })
  cmd("MuseAddDiff", function(o)
    M.add_diff(o.args == "staged")
  end, { desc = "Attach git diff (:MuseAddDiff [staged])", nargs = "?" })
  cmd("MuseModel", function()
    M.pick_model()
  end, { desc = "Switch pi model" })
  cmd("MuseThinking", function()
    M.pick_thinking()
  end, { desc = "Switch thinking level" })
  cmd("MuseCompact", function()
    M.compact()
  end, { desc = "Compact conversation context" })
  cmd("MuseStats", function()
    M.stats()
  end, { desc = "Show session tokens/cost" })
  cmd("MuseExport", function()
    M.export_html()
  end, { desc = "Export session to HTML" })
  cmd("MuseClear", function()
    ui.clear_chat()
  end, { desc = "Clear chat log (session kept)" })
  cmd("MuseReload", function()
    M.reload()
  end, { desc = "Hot-reload muse.nvim (config + code, keeps session)" })
  cmd("MuseRestart", function()
    M.restart()
  end, { desc = "Restart pi backend (fresh process + session)" })

  -- keymaps ----------------------------------------------------------------
  local map = vim.keymap.set
  map("n", "<leader>mc", function()
    M.toggle()
  end, { desc = "Muse: toggle chat" })
  map("n", "<leader>mn", function()
    M.new_session()
  end, { desc = "Muse: new session" })
  map("n", "<leader>ma", function()
    M.abort()
  end, { desc = "Muse: stop response" })
  map("n", "<leader>mf", function()
    M.add_file()
  end, { desc = "Muse: attach current file" })
  map("n", "<leader>mF", function()
    M.pick_file()
  end, { desc = "Muse: pick file to attach" })
  map("x", "<leader>ms", function()
    M.add_selection()
  end, { desc = "Muse: attach selection" })
  map("n", "<leader>md", function()
    M.add_diagnostics(false)
  end, { desc = "Muse: attach diagnostics" })
  map("n", "<leader>mD", function()
    M.add_diagnostics(true)
  end, { desc = "Muse: attach line diagnostics" })
  map("n", "<leader>ml", function()
    M.add_lsp()
  end, { desc = "Muse: attach LSP symbol" })
  map("n", "<leader>mg", function()
    M.add_diff(false)
  end, { desc = "Muse: attach git diff" })
  map("n", "<leader>mm", function()
    M.pick_model()
  end, { desc = "Muse: switch model" })
  map("n", "<leader>mt", function()
    M.pick_thinking()
  end, { desc = "Muse: switch thinking" })
  map("n", "<leader>mR", function()
    M.reload()
  end, { desc = "Muse: hot-reload plugin" })

  M._ready = true

  -- track the last real file buffer so sends from the input box still know
  -- which file/diags to auto-attach (muse:// panes are ignored)
  local function note_cur()
    local b = vim.api.nvim_get_current_buf()
    if ctx.is_real_file and ctx.is_real_file(b) then
      ctx.note_code_buf(b, vim.api.nvim_get_current_win())
    end
  end
  local grp = vim.api.nvim_create_augroup("MuseTrackCode", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, { group = grp, callback = note_cur })
  -- seed from the buffer setup() was called with (usually your file)
  pcall(note_cur)
end

-- backend -------------------------------------------------------------------

local function spawn_args()
  local c = M.config
  local args = { "--name", c.session_name }
  if c.provider then
    args[#args + 1] = "--provider"
    args[#args + 1] = c.provider
  end
  if c.model then
    args[#args + 1] = "--model"
    args[#args + 1] = c.model
  end
  if c.thinking then
    args[#args + 1] = "--thinking"
    args[#args + 1] = c.thinking
  end
  if c.approve then
    args[#args + 1] = "--approve"
  end
  if c.resume then
    args[#args + 1] = "--continue"
  end
  if c.system_extra and c.system_extra ~= "" then
    args[#args + 1] = "--append-system-prompt"
    args[#args + 1] = c.system_extra
  end
  return args
end

--- Point a backend client at this (freshly loaded) module's handlers.
function M.wire_client(client)
  M.client = client
  client.on_event = function(ev)
    M.handle_event(ev)
  end
  client.on_ui_request = function(req, respond)
    M.handle_ui_request(req, respond)
  end
  client.on_exit = function(code)
    M.client = nil
    M._cancel_pending = false
    ui.set_status(false)
    ui.append_error(("backend exited (code %d) — next send restarts it"):format(code))
  end
end

--- Adopt an already-running backend (used by hot-reload to keep the session).
function M.adopt_client(client)
  M.wire_client(client)
  ui.set_status(client.streaming)
  if client.streaming then
    -- response continues below a fresh header; pre-reload text stays above
    ui.assistant_begin()
  end
  M.refresh_stats()
end

--- Ensure a running backend. Returns client or nil.
function M.ensure_client()
  if M.client and M.client:is_running() then
    return M.client
  end
  local client = rpc.new({
    pi_bin = M.config.pi_bin,
    spawn_args = spawn_args(),
    cwd = ctx.project_root(),
  })
  M.wire_client(client)
  if not client:start() then
    M.client = nil
    return nil
  end
  -- pull model/session info + any resumed history
  client:get_state(function(ok, data)
    if not ok or not data then
      return
    end
    vim.schedule(function()
      local m = data.model
      ui.set_meta(("%s/%s"):format(m and m.provider or "?", m and m.id or "?"))
    end)
  end)
  client:get_messages(function(ok, data)
    if ok and data and data.messages and #data.messages > 0 then
      vim.schedule(function()
        ui.render_messages(data.messages)
      end)
    end
  end)
  return client
end

-- events --------------------------------------------------------------------

local function tool_preview(name, args)
  args = args or {}
  if type(args) ~= "table" then
    return tostring(args)
  end
  if name == "bash" then
    return tostring(args.command or "")
  end
  if name == "read" or name == "write" then
    return tostring(args.path or args.file or "")
  end
  if name == "edit" then
    return tostring(args.path or args.file or "")
  end
  if name == "grep" then
    return tostring(args.pattern or args.query or "")
  end
  if name == "find" or name == "ls" then
    return tostring(args.pattern or args.path or "")
  end
  for _, v in pairs(args) do
    if type(v) == "string" and v ~= "" then
      return v
    end
  end
  return ""
end

function M.handle_event(ev)
  local t = ev.type
  if t == "agent_start" then
    ui.set_status(true)
    ui.assistant_begin()
  elseif t == "message_update" then
    local a = ev.assistantMessageEvent or {}
    if a.type == "text_delta" then
      ui.append_delta(a.delta or "")
    elseif a.type == "thinking_delta" then
      -- thinking streams as normal Muse text (disable with show_thinking=false)
      if M.config.show_thinking ~= false then
        ui.append_thinking_delta(a.delta or "")
      end
    elseif a.type == "text_start" or a.type == "thinking_start" then
      ui.assistant_begin()
    end
  elseif t == "tool_execution_start" then
    if ev.toolCallId and type(ev.args) == "table" then
      M.tool_args[ev.toolCallId] = ev.args
    end
    ui.append_tool_start(ev.toolName or "tool", tool_preview(ev.toolName, ev.args))
  elseif t == "tool_execution_end" then
    local args = (ev.toolCallId and M.tool_args[ev.toolCallId]) or {}
    if ev.toolCallId then
      M.tool_args[ev.toolCallId] = nil
    end
    ui.append_tool_end(not ev.isError, ev.toolName or "tool", args, ev.result)
  elseif t == "agent_settled" then
    local was_cancel = M._cancel_pending
    M._cancel_pending = false
    ui.assistant_end()
    ui.set_status(false)
    if was_cancel then
      ui.append_system("Request cancelled")
    end
    M.refresh_stats()
  elseif t == "compaction_start" then
    ui.append_system("compacting context…")
  elseif t == "compaction_end" then
    local r = ev.result
    if r and r.summary then
      ui.append_system(("context compacted (est. %s → %s tokens)"):format(r.tokensBefore or "?", r.estimatedTokensAfter or "?"))
    elseif ev.aborted then
      ui.append_system("compaction aborted")
    else
      ui.append_error("compaction failed" .. (ev.errorMessage and (": " .. ev.errorMessage) or ""))
    end
  elseif t == "auto_retry_start" then
    ui.append_system(("retrying in %ds… (%s)"):format(math.floor((ev.delayMs or 0) / 1000), ev.errorMessage or "transient error"))
  elseif t == "extension_error" then
    ui.append_error(("extension error: %s"):format(ev.error or "?"))
  elseif t == "queue_update" then
    local n = #(ev.steering or {}) + #(ev.followUp or {})
    if n > 0 then
      ui.append_system(("%d message(s) queued"):format(n))
    end
  end
end

--- Extension permission prompts (ask_user etc.) surface as vim.ui dialogs.
function M.handle_ui_request(req, respond)
  local function resp(tbl)
    tbl.type = "extension_ui_response"
    tbl.id = req.id
    respond(tbl)
  end
  vim.schedule(function()
    if req.method == "select" then
      vim.ui.select(req.options or {}, { prompt = req.title or "Choose:" }, function(choice)
        if choice == nil then
          resp({ cancelled = true })
        else
          resp({ value = choice })
        end
      end)
    elseif req.method == "confirm" then
      local prompt = req.title or "Confirm"
      if req.message and req.message ~= "" then
        prompt = prompt .. " — " .. req.message
      end
      vim.ui.select({ "Yes", "No" }, { prompt = prompt }, function(choice)
        resp({ confirmed = choice == "Yes" })
      end)
    elseif req.method == "input" or req.method == "editor" then
      vim.ui.input({ prompt = (req.title or "Input") .. ": ", default = req.prefill or "" }, function(val)
        if val == nil then
          resp({ cancelled = true })
        else
          resp({ value = val })
        end
      end)
    elseif req.method == "notify" then
      local lvl = vim.log.levels.INFO
      if req.notifyType == "error" then
        lvl = vim.log.levels.ERROR
      elseif req.notifyType == "warning" then
        lvl = vim.log.levels.WARN
      end
      vim.notify("[muse] " .. (req.message or ""), lvl)
    else
      -- setStatus / setWidget / setTitle / set_editor_text: nothing to do
    end
  end)
end

function M.refresh_stats()
  if not (M.client and M.client:is_running()) then
    return
  end
  M.client:get_session_stats(function(ok, data)
    if not ok or not data then
      return
    end
    vim.schedule(function()
      local tok = data.tokens and data.tokens.total or nil
      local parts = {}
      if tok then
        parts[#parts + 1] = tok >= 1000 and ("%.1fk tok"):format(tok / 1000) or (tok .. " tok")
      end
      if data.cost then
        parts[#parts + 1] = ("$%.3f"):format(data.cost)
      end
      if data.contextUsage and data.contextUsage.percent then
        parts[#parts + 1] = ("ctx %d%%"):format(data.contextUsage.percent)
      end
      M.client:get_state(function(ok2, st)
        vim.schedule(function()
          local base = ""
          if ok2 and st and st.model then
            base = ("%s/%s"):format(st.model.provider or "?", st.model.id or "?")
          end
          local extra = table.concat(parts, " · ")
          ui.set_meta(base .. (extra ~= "" and (" · " .. extra) or ""))
        end)
      end)
    end)
  end)
end

-- sending -------------------------------------------------------------------

function M.open()
  ui.open()
end

function M.toggle()
  ui.toggle()
end

function M.send_cmd(o)
  -- :MuseSend with a visual/line range adds those lines as context
  local range_att = nil
  if o.range and o.range > 0 then
    range_att = ctx.file_range(0, o.line1, o.line2, "(range)")
  end
  if o.args and o.args ~= "" then
    if not ui.is_open() then
      ui.open()
    end
    -- seed the input box so @-mentions/quoting behave uniformly
    local cur = ui.get_input()
    if cur ~= "" and not cur:match("\n$") then
      cur = cur .. "\n"
    end
    -- put pending range + typed args through the normal send path
    if range_att then
      M.pending[#M.pending + 1] = range_att
      ui.set_attachments(pending_labels())
    end
    M.send_text(o.args)
  else
    if range_att then
      M.pending[#M.pending + 1] = range_att
      ui.set_attachments(pending_labels())
    end
    ui.open()
    ui.focus_input()
  end
end

--- Send the current input-box contents (with @-expansion + pending attaches).
function M.send()
  local raw = ui.get_input()
  M.send_text(raw, true)
end

--- Core send path. from_input=true means the text came from the input box
--- (clear it after sending). Auto-attaches the current file + diagnostics
--- unless disabled in config or already referenced via @-mentions/pending.
function M.send_text(raw, from_input)
  local text = (raw or ""):match("^%s*(.-)%s*$") or ""
  if text == "" and #M.pending == 0 then
    vim.notify("[muse] type a message, attach context, or use @-mentions", vim.log.levels.INFO)
    return
  end
  local expanded, mention_labels = ctx.expand_mentions(text)
  local blocks, labels = {}, {}
  -- auto context: current file + diagnostics (skipped when explicitly mentioned)
  local code_buf = ctx.code_buf and ctx.code_buf() or nil
  local has_file_pending = false
  local has_diag_pending = false
  for _, p in ipairs(M.pending) do
    if p.text and (p.text:match("^File:") or p.text:match("^Selected code")) then
      has_file_pending = true
    end
    if p.text and p.text:match("^Diagnostics for") then
      has_diag_pending = true
    end
  end
  local mentioned_file = text:match("@file") or text:match("@buffer:") or text:match("@selection")
  local mentioned_diag = text:match("@diagnostics") or text:match("@diag%-line")
  if code_buf then
    if M.config.auto_attach_file and not mentioned_file and not has_file_pending then
      local fatt = ctx.current_file(code_buf, M.config.max_auto_file_lines)
      if fatt then
        table.insert(blocks, 1, fatt.text)
        table.insert(labels, 1, fatt.label)
      end
    end
    if M.config.auto_attach_diagnostics and not mentioned_diag and not has_diag_pending then
      local datt = ctx.diagnostics(code_buf)
      if datt and not datt.label:match("%(none%)") and not datt.text:match("no file context") and not datt.text:match("no issues") then
        blocks[#blocks + 1] = datt.text
        labels[#labels + 1] = datt.label
      end
    end
  end
  for _, p in ipairs(M.pending) do
    blocks[#blocks + 1] = p.text
    labels[#labels + 1] = p.label
  end
  for _, l in ipairs(mention_labels) do
    labels[#labels + 1] = l
  end
  local full = expanded
  if #blocks > 0 then
    full = table.concat(blocks, "\n\n") .. "\n\n---\n\n" .. (expanded ~= "" and expanded or "(see attached context)")
  end

  local prev_win = vim.api.nvim_get_current_win()
  if not ui.is_open() then
    ui.open()
  end
  ui.append_user(text ~= "" and text or "(context only)", #labels > 0 and table.concat(labels, " · ") or nil)
  if not from_input and vim.api.nvim_win_is_valid(prev_win) then
    -- :MuseSend from a code buffer shouldn't steal the cursor
    vim.api.nvim_set_current_win(prev_win)
  end
  if from_input then
    ui.clear_input()
  end
  M.pending = {}
  ui.set_attachments({})
  ui.set_status(true)

  local client = M.ensure_client()
  if not client then
    ui.append_error("could not start pi backend")
    ui.set_status(false)
    return
  end
  client:prompt(full, function(ok, _, resp)
    if not ok then
      vim.schedule(function()
        ui.append_error("prompt rejected: " .. ((resp and resp.error) or "unknown"))
        ui.set_status(false)
      end)
    end
  end)
end

-- attaches ------------------------------------------------------------------

local function attach(att)
  if not att then
    vim.notify("[muse] no context found (is an LSP server attached?)", vim.log.levels.WARN)
    return
  end
  M.pending[#M.pending + 1] = att
  ui.set_attachments(pending_labels())
  if not ui.is_open() then
    ui.open()
  else
    ui.focus_input()
  end
  vim.notify("[muse] attached: " .. att.label, vim.log.levels.INFO)
end

function M.add_file(path)
  if path then
    local full = vim.fn.fnamemodify(path, ":p")
    if vim.fn.filereadable(full) == 1 then
      attach(ctx.file_on_disk(full))
    else
      vim.notify("[muse] not readable: " .. path, vim.log.levels.ERROR)
    end
    return
  end
  attach(ctx.current_file(ctx.code_buf and ctx.code_buf() or nil))
end

function M.pick_file()
  local files = ctx.repo_files(2000)
  if #files == 0 then
    vim.notify("[muse] no files found", vim.log.levels.WARN)
    return
  end
  vim.ui.select(files, { prompt = "Attach file:" }, function(choice)
    if not choice then
      return
    end
    local full = ctx.project_root() .. "/" .. choice
    if vim.fn.filereadable(full) ~= 1 then
      full = vim.fn.fnamemodify(choice, ":p")
    end
    attach(ctx.file_on_disk(full))
  end)
end

function M.add_selection()
  attach(ctx.visual_selection())
end

function M.add_diagnostics(line_only)
  local cb = ctx.code_buf and ctx.code_buf() or vim.api.nvim_get_current_buf()
  if line_only then
    local lnum = ctx.code_lnum and ctx.code_lnum() or (vim.api.nvim_win_get_cursor(0)[1] - 1)
    attach(ctx.diagnostics(cb, lnum))
  else
    attach(ctx.diagnostics(cb))
  end
end

function M.add_lsp()
  local info = ctx.symbol_info()
  if not info then
    vim.notify("[muse] no LSP info for symbol under cursor", vim.log.levels.WARN)
    return
  end
  attach(info)
end

function M.add_diff(staged)
  attach(ctx.git_diff(staged))
end

-- session controls ------------------------------------------------------------

function M.new_session()
  local client = M.ensure_client()
  if not client then
    return
  end
  if not ui.is_open() then
    ui.open()
  end
  client:new_session(function(ok)
    vim.schedule(function()
      if ok then
        ui.clear_chat()
        ui.append_system("started a new chat")
        M.refresh_stats()
      else
        ui.append_error("could not start a new session")
      end
    end)
  end)
end

--- Kill the backend and spawn a fresh one. Unlike :MuseNew (new session,
--- same process), this also picks up rpc.lua changes, a new cwd/project
--- root, and recovers a wedged backend. Chat log is kept with a note.
function M.restart()
  if not ui.is_open() then
    ui.open()
  end
  local old = M.client
  M.client = nil
  M._cancel_pending = false
  if old then
    if old.streaming then
      ui.assistant_end() -- close any partial answer cleanly
    end
    old.on_exit = function() end -- intentional: no "backend exited" noise
    old:stop()
  end
  ui.set_status(false)
  if M.ensure_client() then
    ui.append_system("backend restarted — new session, history above is from the previous one")
  end
end

function M.abort()
  if not (M.client and M.client:is_running()) then
    ui.set_status(false)
    return
  end
  if not M.client.streaming then
    return -- idle: nothing to cancel, don't spam the log
  end
  if not M._cancel_pending then
    M._cancel_pending = true
  end
  M.client:abort(function(ok)
    -- fallback if agent_settled never arrives; normally settled consumes
    -- the flag first and this becomes a no-op (abort responds after idle).
    vim.schedule(function()
      if not M._cancel_pending then
        return
      end
      -- abort failed (e.g. backend died): let on_exit's error speak
      if ok == false then
        M._cancel_pending = false
        return
      end
      M._cancel_pending = false
      ui.assistant_end()
      ui.set_status(false)
      ui.append_system("Request cancelled")
      M.refresh_stats()
    end)
  end)
end

function M.compact()
  local client = M.ensure_client()
  if not client then
    return
  end
  client:compact(nil, function(ok, data)
    vim.schedule(function()
      if ok and data then
        ui.append_system("compacted" .. (data.summary and (": " .. data.summary:sub(1, 200)) or ""))
      else
        ui.append_error("compaction failed")
      end
    end)
  end)
end

function M.stats()
  local client = M.ensure_client()
  if not client then
    return
  end
  if not ui.is_open() then
    ui.open()
  end
  client:get_session_stats(function(ok, data)
    vim.schedule(function()
      if not ok or not data then
        ui.append_error("could not fetch stats")
        return
      end
      local t = data.tokens or {}
      ui.append_system(
        ("msgs %d · tools %d · tok in %d / out %d · cost $%.4f"):format(
          data.totalMessages or 0,
          data.toolCalls or 0,
          t.input or 0,
          t.output or 0,
          data.cost or 0
        )
      )
      M.refresh_stats()
    end)
  end)
end

function M.export_html()
  local client = M.ensure_client()
  if not client then
    return
  end
  client:export_html(nil, function(ok, data)
    vim.schedule(function()
      if ok and data and data.path then
        ui.append_system("exported to " .. data.path)
        pcall(vim.ui.open, data.path)
      else
        ui.append_error("export failed")
      end
    end)
  end)
end

--- Hot-reload: re-read lua/plugins/muse.lua + lua/muse/*.lua without
--- restarting nvim. Preserves: open pane + chat history (buffers are
--- reused by name), queued attachments, input-box text, and the live
--- backend (session kept; only its callbacks are rewired). Mid-stream
--- reloads continue the answer below a fresh header.
function M.reload()
  local saved = {
    pending = M.pending,
    input = ui.get_input(),
    was_open = ui.is_open(),
    focus = ui.current_part(),
    client = (M.client and M.client:is_running()) and M.client or nil,
  }
  local cfg_dir = vim.fn.stdpath("config")
  local files = vim.fn.glob(cfg_dir .. "/lua/muse/*.lua", false, true)
  files[#files + 1] = cfg_dir .. "/lua/plugins/muse.lua"
  for _, f in ipairs(files) do
    local chunk, err = loadfile(f)
    if not chunk then
      vim.notify(("[muse] reload aborted, syntax error in %s:\n%s"):format(vim.fn.fnamemodify(f, ":t"), err), vim.log.levels.ERROR)
      return
    end
  end
  if saved.was_open then
    ui.close()
  end
  _G.__muse_keep = saved
  for name in pairs(package.loaded) do
    if name == "muse" or name:match("^muse%.") or name == "plugins.muse" then
      package.loaded[name] = nil
    end
  end
  local chunk = loadfile(cfg_dir .. "/lua/plugins/muse.lua")
  local ok, spec = pcall(chunk)
  local entry
  if ok and type(spec) == "table" then
    for _, s in ipairs(spec) do
      if type(s) == "table" and s.name == "muse-nvim" then
        entry = s
        break
      end
    end
  end
  if not entry or type(entry.config) ~= "function" then
    _G.__muse_keep = nil
    vim.notify("[muse] reload failed: muse-nvim spec not found", vim.log.levels.ERROR)
    return
  end
  local ok2, err2 = pcall(entry.config)
  if not ok2 then
    _G.__muse_keep = nil
    vim.notify("[muse] reload failed in setup(): " .. tostring(err2), vim.log.levels.ERROR)
    return
  end
  -- fresh modules below; restore stashed state
  local fresh = require("muse")
  local fresh_ui = require("muse.ui")
  local keep = _G.__muse_keep
  _G.__muse_keep = nil
  fresh.pending = keep.pending or {}
  fresh_ui.set_attachments((function()
    local labels = {}
    for _, p in ipairs(fresh.pending) do
      labels[#labels + 1] = p.label
    end
    return labels
  end)())
  if keep.client then
    fresh.adopt_client(keep.client)
  end
  if keep.was_open then
    fresh.open()
    if keep.input and keep.input ~= "" then
      fresh_ui.set_input(keep.input)
    end
    if keep.focus == "chat" then
      fresh_ui.focus_chat()
    elseif keep.focus == "input" then
      fresh_ui.focus_input()
    end
  end
  vim.notify("[muse] reloaded", vim.log.levels.INFO)
end

function M.pick_model()
  local client = M.ensure_client()
  if not client then
    return
  end
  client:get_available_models(function(ok, data)
    if not ok or not data then
      return
    end
    local models = data.models or {}
    vim.schedule(function()
      local items, idx = {}, {}
      for _, m in ipairs(models) do
        local label = ("%s  (%s/%s)"):format(m.name or m.id, m.provider or "?", m.id or "?")
        items[#items + 1] = label
        idx[label] = m
      end
      vim.ui.select(items, { prompt = "Muse model:" }, function(choice)
        if not choice then
          return
        end
        local m = idx[choice]
        client:set_model(m.provider, m.id, function(ok2)
          vim.schedule(function()
            if ok2 then
              ui.append_system("model → " .. choice)
              M.refresh_stats()
            else
              ui.append_error("model switch failed")
            end
          end)
        end)
      end)
    end)
  end)
end

function M.pick_thinking()
  local client = M.ensure_client()
  if not client then
    return
  end
  client:get_available_thinking_levels(function(ok, data)
    if not ok or not data then
      return
    end
    vim.schedule(function()
      vim.ui.select(data.levels or { "off" }, { prompt = "Thinking level:" }, function(choice)
        if not choice then
          return
        end
        client:set_thinking_level(choice, function(ok2)
          vim.schedule(function()
            if ok2 then
              ui.append_system("thinking → " .. choice)
            else
              ui.append_error("thinking switch failed")
            end
          end)
        end)
      end)
    end)
  end)
end

return M
