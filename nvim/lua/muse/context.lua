-- muse/context.lua — gather editor/LSP/diagnostic context to paste into chat.
-- Every gatherer returns an attachment: { label = "short display", text = "full markdown block" }.
local M = {}

local MAX_DIAG = 40
local MAX_DIFF_CHARS = 9000
local MAX_REFS = 25

--- True for the muse chat/input panes (never treat as "current file").
function M.is_muse_buffer(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  local name = vim.api.nvim_buf_get_name(bufnr)
  return name:match("^muse://") ~= nil
end

--- True for a real file buffer (excludes muse panes, help, prompt, nofile, etc.).
function M.is_real_file(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  if M.is_muse_buffer(bufnr) then
    return false
  end
  if vim.bo[bufnr].buftype ~= "" then
    return false
  end
  local name = vim.api.nvim_buf_get_name(bufnr)
  return name ~= ""
end

-- Last seen code buffer/win. Updated via note_code_buf() from an autocmd in
-- init.lua, so sends issued from the muse input box still resolve the file
-- the user was just editing.
M._code_buf = nil
M._code_win = nil

function M.note_code_buf(bufnr, winnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not M.is_real_file(bufnr) then
    return
  end
  M._code_buf = bufnr
  local w = winnr or vim.api.nvim_get_current_win()
  if w and vim.api.nvim_win_is_valid(w) and vim.api.nvim_win_get_buf(w) == bufnr then
    M._code_win = w
  end
end

--- Best code buffer: current buffer if it's a real file, else last seen one.
function M.code_buf()
  local cur = vim.api.nvim_get_current_buf()
  if M.is_real_file(cur) then
    return cur
  end
  if M._code_buf and vim.api.nvim_buf_is_valid(M._code_buf) and M.is_real_file(M._code_buf) then
    return M._code_buf
  end
  return nil
end

--- Best code window: a visible window showing the code buffer, if any.
function M.code_win()
  if M._code_win and vim.api.nvim_win_is_valid(M._code_win) then
    local b = vim.api.nvim_win_get_buf(M._code_win)
    if M.is_real_file(b) then
      return M._code_win
    end
  end
  local cb = M.code_buf()
  if cb then
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_is_valid(w) and vim.api.nvim_win_get_buf(w) == cb then
        M._code_win = w
        return w
      end
    end
  end
  return nil
end

--- Run fn with the code window current (so LSP position params + <cword>
--- resolve in the file, not the muse input box). Falls back to current win.
function M.with_code_win(fn)
  local w = M.code_win()
  if w and w ~= vim.api.nvim_get_current_win() then
    local ok, res = pcall(vim.api.nvim_win_call, w, fn)
    if ok then
      return res
    end
  end
  return fn()
end

--- Cursor line (0-indexed) in the code window, for @diag-line / LSP.
function M.code_lnum()
  local w = M.code_win()
  if w then
    local ok, cur = pcall(vim.api.nvim_win_get_cursor, w)
    if ok and cur then
      return cur[1] - 1
    end
  end
  return vim.api.nvim_win_get_cursor(0)[1] - 1
end

function M.project_root()
  local git = vim.fn.systemlist("git rev-parse --show-toplevel")
  if vim.v.shell_error == 0 and git[1] and git[1] ~= "" then
    return git[1]
  end
  return vim.fn.getcwd()
end

function M.relpath(path)
  if not path or path == "" then
    return "[no file]"
  end
  local root = M.project_root()
  if vim.startswith(path, root .. "/") then
    return path:sub(#root + 2)
  end
  return vim.fn.fnamemodify(path, ":~")
end

local function fence(ft, body)
  return "```" .. (ft or "") .. "\n" .. body .. "\n```"
end

local function buf_lines(bufnr, s, e)
  s = math.max(s or 1, 1)
  local count = vim.api.nvim_buf_line_count(bufnr)
  e = math.min(e or count, count)
  if s > e then
    return {}, s, e
  end
  return vim.api.nvim_buf_get_lines(bufnr, s - 1, e, false), s, e
end

--- Whole current buffer (unsaved contents included).
--- Defaults to the last real file buffer (not the muse input box).
function M.current_file(bufnr, max_lines)
  if not bufnr or bufnr == 0 then
    bufnr = M.code_buf()
  end
  if not bufnr or bufnr == 0 or not M.is_real_file(bufnr) then
    return nil
  end
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" then
    return nil
  end
  local ft = vim.bo[bufnr].filetype
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local truncated = false
  if max_lines and #lines > max_lines then
    local kept = {}
    for i = 1, max_lines do
      kept[i] = lines[i]
    end
    lines = kept
    truncated = true
  end
  local label = M.relpath(path) .. " (" .. #lines .. " lines" .. (truncated and ", truncated" or "") .. ")"
  local body = table.concat(lines, "\n")
  if truncated then
    body = body .. "\n... (truncated, file is longer)"
  end
  local text = ("File: `%s` (%s, %d lines%s, may include unsaved changes):\n%s"):format(
    M.relpath(path),
    ft ~= "" and ft or "plain",
    #lines,
    truncated and ", truncated" or "",
    fence(ft ~= "" and ft or nil, body)
  )
  return { label = label, text = text }
end

--- Explicit line range of a buffer.
function M.file_range(bufnr, s, e, why)
  if not bufnr or bufnr == 0 then
    bufnr = M.code_buf()
  end
  if not bufnr or bufnr == 0 or not vim.api.nvim_buf_is_valid(bufnr) then
    return nil
  end
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" then
    return nil
  end
  local ft = vim.bo[bufnr].filetype
  local lines, rs, re = buf_lines(bufnr, s, e)
  local label = ("%s:%d-%d%s"):format(M.relpath(path), rs, re, why and (" " .. why) or "")
  local text = ("File: `%s` lines %d-%d (%s):\n%s"):format(
    M.relpath(path),
    rs,
    re,
    ft ~= "" and ft or "plain",
    fence(ft ~= "" and ft or nil, table.concat(lines, "\n"))
  )
  return { label = label, text = text }
end

--- Live visual selection. Call from a visual-mode mapping: uses `v` and `.`
--- so it works before VisualLeave updates the `<`/`>` marks.
function M.visual_selection()
  local bufnr = vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" then
    return nil
  end
  -- live visual coords when called from a visual mapping, else last marks
  -- (e.g. :'<,'>MuseAddSelection after leaving visual mode)
  local mode = vim.fn.mode()
  local vmode, s, e
  if mode:match("^[vV\22sS]") then
    vmode, s, e = mode, vim.fn.getpos("v"), vim.fn.getpos(".")
  else
    vmode, s, e = vim.fn.visualmode(), vim.api.nvim_buf_get_mark(bufnr, "<"), vim.api.nvim_buf_get_mark(bufnr, ">")
    -- get_mark is 0-indexed col; normalize to getpos shape {_, row, col1}
    s, e = { 0, s[1], s[2] + 1 }, { 0, e[1], e[2] + 1 }
    if s[2] == 0 or e[2] == 0 then
      return nil
    end
  end
  local srow, scol, erow, ecol = s[2], s[3], e[2], e[3]
  if srow > erow or (srow == erow and scol > ecol) then
    srow, scol, erow, ecol = erow, ecol, srow, scol
  end
  local lines
  if vmode == "V" then
    lines = vim.api.nvim_buf_get_lines(bufnr, srow - 1, erow, false)
  else
    lines = vim.api.nvim_buf_get_lines(bufnr, srow - 1, erow, false)
    if #lines > 0 then
      lines[#lines] = lines[#lines]:sub(1, ecol)
      lines[1] = lines[1]:sub(scol)
    end
  end
  if #lines == 0 then
    return nil
  end
  local ft = vim.bo[bufnr].filetype
  return {
    label = ("%s:%d-%d (selection)"):format(M.relpath(path), srow, erow),
    text = ("Selected code from `%s` lines %d-%d:\n%s"):format(
      M.relpath(path),
      srow,
      erow,
      fence(ft ~= "" and ft or nil, table.concat(lines, "\n"))
    ),
  }
end

local severity_name = {
  [vim.diagnostic.severity.ERROR] = "error",
  [vim.diagnostic.severity.WARN] = "warn",
  [vim.diagnostic.severity.INFO] = "info",
  [vim.diagnostic.severity.HINT] = "hint",
}

--- Diagnostics for a buffer (default: current code file), or a single line.
function M.diagnostics(bufnr, line)
  if not bufnr or bufnr == 0 then
    bufnr = M.code_buf()
  end
  if not bufnr or bufnr == 0 or not vim.api.nvim_buf_is_valid(bufnr) then
    return { label = "diagnostics (none)", text = "Diagnostics: no file context." }
  end
  local path = vim.api.nvim_buf_get_name(bufnr)
  local diags = vim.diagnostic.get(bufnr, line and { lnum = line } or nil)
  if #diags == 0 then
    return { label = "diagnostics (none)", text = "Diagnostics: no issues reported." }
  end
  table.sort(diags, function(a, b)
    return (a.severity or 4) < (b.severity or 4) or a.lnum < b.lnum
  end)
  local out = {}
  for i, d in ipairs(diags) do
    if i > MAX_DIAG then
      out[#out + 1] = ("... and %d more"):format(#diags - MAX_DIAG)
      break
    end
    out[#out + 1] = ("- %s:%d:%d [%s] %s%s"):format(
      M.relpath(path),
      d.lnum + 1,
      d.col + 1,
      severity_name[d.severity] or "?",
      d.message:gsub("\n", " "),
      d.source and (" (%s)"):format(d.source) or ""
    )
  end
  local scope = line and ("line %d"):format(line + 1) or M.relpath(path)
  return {
    label = ("diagnostics %s (%d)"):format(scope, #diags),
    text = ("Diagnostics for %s:\n%s"):format(scope, table.concat(out, "\n")),
  }
end

local function lsp_params()
  local params = vim.lsp.util.make_position_params()
  -- make_position_params uses the current window; fine for our use.
  return params
end

local function hover_to_md(result)
  if not result or not result.contents then
    return nil
  end
  local md = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
  md = vim.lsp.util.trim_blankspace(md)
  if #md == 0 then
    return nil
  end
  return table.concat(md, "\n")
end

--- Hover docs for symbol under cursor (uses the code window, not the input box).
function M.lsp_hover(timeout)
  return M.with_code_win(function()
  local resp = vim.lsp.buf_request_sync(0, "textDocument/hover", lsp_params(), timeout or 1200)
  if not resp then
    return nil
  end
  for _, r in pairs(resp) do
    local md = r.result and hover_to_md(r.result)
    if md then
      local word = vim.fn.expand("<cword>")
      return {
        label = ("hover `%s`"):format(word),
        text = ("LSP hover for `%s`:\n\n%s"):format(word, md),
      }
    end
  end
  return nil
  end)
end

local function loc_to_preview(loc, context_lines)
  local uri = loc.uri or loc.targetUri
  if not uri then
    return nil
  end
  local range = loc.range or loc.targetSelectionRange or loc.targetRange
  if not range then
    return nil
  end
  local fname = vim.uri_to_fname(uri)
  local ok, lines = pcall(vim.fn.readfile, fname)
  if not ok or not lines then
    return nil
  end
  local row = (range.start.line or 0) + 1
  local s = math.max(row - (context_lines or 6), 1)
  local e = math.min(row + (context_lines or 6), #lines)
  local body = {}
  for i = s, e do
    body[#body + 1] = (i == row and "> " or "  ") .. lines[i]
  end
  return ("%s:%d\n%s"):format(M.relpath(fname), row, table.concat(body, "\n"))
end

--- Definition(s) of symbol under cursor, with code preview.
function M.lsp_definition(timeout)
  return M.with_code_win(function()
  local resp = vim.lsp.buf_request_sync(0, "textDocument/definition", lsp_params(), timeout or 1200)
  if not resp then
    return nil
  end
  local previews = {}
  for _, r in pairs(resp) do
    local res = r.result
    if res then
      local locs = vim.islist(res) and res or { res }
      for _, loc in ipairs(locs) do
        local p = loc_to_preview(loc, 6)
        if p then
          previews[#previews + 1] = p
        end
        if #previews >= 3 then
          break
        end
      end
    end
  end
  if #previews == 0 then
    return nil
  end
  local word = vim.fn.expand("<cword>")
  return {
    label = ("definition of `%s`"):format(word),
    text = ("LSP definition of `%s`:\n%s"):format(word, fence(nil, table.concat(previews, "\n---\n"))),
  }
  end)
end

--- References to symbol under cursor.
function M.lsp_references(timeout)
  return M.with_code_win(function()
  local params = lsp_params()
  params.context = { includeDeclaration = false }
  local resp = vim.lsp.buf_request_sync(0, "textDocument/references", params, timeout or 1500)
  if not resp then
    return nil
  end
  local refs = {}
  for _, r in pairs(resp) do
    local res = r.result
    if res then
      for _, loc in ipairs(res) do
        local uri = loc.uri or loc.targetUri
        local range = loc.range or loc.targetRange
        if uri and range then
          local fname = vim.uri_to_fname(uri)
          refs[#refs + 1] = ("- %s:%d"):format(M.relpath(fname), (range.start.line or 0) + 1)
          if #refs >= MAX_REFS then
            break
          end
        end
      end
    end
  end
  if #refs == 0 then
    return nil
  end
  local word = vim.fn.expand("<cword>")
  return {
    label = ("%d references to `%s`"):format(#refs, word),
    text = ("LSP references to `%s` (%d):\n%s"):format(word, #refs, table.concat(refs, "\n")),
  }
  end)
end

--- Everything LSP knows about the symbol under the cursor.
function M.symbol_info()
  local parts, labels = {}, {}
  local h = M.lsp_hover()
  if h then
    parts[#parts + 1], labels[#labels + 1] = h.text, h.label
  end
  local d = M.lsp_definition()
  if d then
    parts[#parts + 1], labels[#labels + 1] = d.text, d.label
  end
  local r = M.lsp_references()
  if r then
    parts[#parts + 1], labels[#labels + 1] = r.text, r.label
  end
  if #parts == 0 then
    return nil
  end
  return { label = table.concat(labels, " + "), text = table.concat(parts, "\n\n") }
end

--- Git diff (staged or unstaged), truncated.
function M.git_diff(staged)
  local cmd = staged and "git diff --stat && echo '---' && git diff --cached" or "git diff --stat && echo '---' && git diff"
  local out = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 or out:match("^%s*$") then
    return { label = "git diff (clean)", text = "Git diff: working tree is clean." }
  end
  if #out > MAX_DIFF_CHARS then
    out = out:sub(1, MAX_DIFF_CHARS) .. "\n... (truncated)"
  end
  return {
    label = staged and "staged diff" or "unstaged diff",
    text = ("Git %s diff:\n%s"):format(staged and "staged" or "unstaged", fence("diff", out)),
  }
end

--- Quickfix list contents.
function M.quickfix()
  local qf = vim.fn.getqflist({ items = 1, title = 1 })
  if #qf.items == 0 then
    return nil
  end
  local out = {}
  for i, item in ipairs(qf.items) do
    if i > MAX_DIAG then
      out[#out + 1] = ("... and %d more"):format(#qf.items - MAX_DIAG)
      break
    end
    local name = item.bufnr > 0 and M.relpath(vim.api.nvim_buf_get_name(item.bufnr)) or ""
    out[#out + 1] = ("- %s:%d:%d %s"):format(name, item.lnum, item.col, item.text)
  end
  return {
    label = ("quickfix (%d)"):format(#qf.items),
    text = ("Quickfix list (%s):\n%s"):format(qf.title or "", table.concat(out, "\n")),
  }
end

--- A file from disk by path (for the picker / @buffer:).
function M.file_on_disk(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok or not lines then
    return nil
  end
  local ft = vim.filetype.match({ filename = path }) or ""
  return {
    label = ("%s (%d lines)"):format(M.relpath(path), #lines),
    text = ("File: `%s` (%d lines):\n%s"):format(M.relpath(path), #lines, fence(ft ~= "" and ft or nil, table.concat(lines, "\n"))),
  }
end

--- Repo file list for the attach picker (git-aware, capped).
function M.repo_files(limit)
  limit = limit or 2000
  local files = vim.fn.systemlist("git ls-files")
  if vim.v.shell_error ~= 0 or #files == 0 then
    files = vim.fn.systemlist("fd --type f --hidden --exclude .git 2>/dev/null | head -n " .. limit)
    if vim.v.shell_error ~= 0 or #files == 0 then
      -- last resort: visible listed buffers
      files = {}
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(b) then
          local n = vim.api.nvim_buf_get_name(b)
          if n ~= "" then
            files[#files + 1] = M.relpath(n)
          end
        end
      end
    end
  end
  if #files > limit then
    -- keep it manageable for vim.ui.select
    local trimmed = {}
    for i = 1, limit do
      trimmed[i] = files[i]
    end
    files = trimmed
  end
  return files
end

-- @-mention expansion --------------------------------------------------------
-- Supported in the input box:
--   @file              current buffer
--   @selection         last visual selection (marks '< '>)
--   @diagnostics       buffer diagnostics
--   @diag-line         diagnostics on cursor line
--   @lsp               hover+definition+references for word under cursor
--   @diff / @diff-staged
--   @quickfix
--   @buffer:<name>     first listed buffer whose name matches (fuzzy substring)

local function find_buf_by_name(name)
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) then
      local full = vim.api.nvim_buf_get_name(b)
      if full ~= "" and full:find(name, 1, true) then
        return b
      end
    end
  end
  return nil
end

--- Expand @-mentions in raw input. Returns (expanded_text, labels).
--- @param raw string
--- @param sel_override table|nil pre-captured visual selection attachment
function M.expand_mentions(raw, sel_override)
  local labels = {}
  local function use(att)
    if att then
      labels[#labels + 1] = att.label
      return "\n\n" .. att.text .. "\n"
    end
    return "\n\n(null: context not available)\n"
  end
  local expanded = raw
  expanded = expanded:gsub("@diag%-line", function()
    local cb = M.code_buf()
    return use(M.diagnostics(cb, M.code_lnum()))
  end)
  expanded = expanded:gsub("@diagnostics", function()
    return use(M.diagnostics(M.code_buf()))
  end)
  expanded = expanded:gsub("@selection", function()
    if sel_override then
      return use(sel_override)
    end
    -- fall back to last visual marks in the code buffer (works after leaving visual mode,
    -- even when typed from the muse input box)
    local cb = M.code_buf()
    if not cb then
      return "\n\n(null: no visual selection)\n"
    end
    local s = vim.api.nvim_buf_get_mark(cb, "<")
    local e = vim.api.nvim_buf_get_mark(cb, ">")
    if s[1] == 0 then
      return "\n\n(null: no visual selection)\n"
    end
    return use(M.file_range(cb, s[1], e[1], "(last selection)"))
  end)
  expanded = expanded:gsub("@diff%-staged", function()
    return use(M.git_diff(true))
  end)
  expanded = expanded:gsub("@diff", function()
    return use(M.git_diff(false))
  end)
  expanded = expanded:gsub("@quickfix", function()
    return use(M.quickfix())
  end)
  expanded = expanded:gsub("@lsp", function()
    return use(M.symbol_info())
  end)
  expanded = expanded:gsub("@buffer:([%w%._%-%/]+)", function(name)
    local b = find_buf_by_name(name)
    if not b then
      return ("\n\n(null: no open buffer matching '%s')\n"):format(name)
    end
    return use(M.current_file(b))
  end)
  -- @file last: @buffer: contains "buffer" not "file", no clash; but avoid
  -- matching the "@file" inside an already-expanded block (blocks use backticks, not @file)
  expanded = expanded:gsub("@file", function()
    return use(M.current_file(M.code_buf()))
  end)
  return expanded, labels
end

return M
