-- muse/rpc.lua — minimal JSONL-RPC client for `pi --mode rpc`.
-- Spawns one long-lived `pi` process per Neovim instance (cwd = project root)
-- so the chat keeps conversational + tool state across messages. Streaming
-- deltas arrive as `message_update` events; responses correlate via `id`.
local M = {}

local Client = {}
Client.__index = Client

local seq = 0
local function next_id()
  seq = seq + 1
  return "nvim-" .. seq
end

--- Create (but do not start) a client.
--- @param opts table: { pi_bin, spawn_args (list), cwd, on_event(fn), on_exit(fn) }
function M.new(opts)
  opts = opts or {}
  return setmetatable({
    pi_bin = opts.pi_bin or "pi",
    spawn_args = opts.spawn_args or {},
    cwd = opts.cwd or vim.fn.getcwd(),
    on_event = opts.on_event or function() end,
    on_exit = opts.on_exit or function() end,
    on_ui_request = opts.on_ui_request, -- filled in by init.lua (needs UI)
    job = nil,
    _partial = "",
    _pending = {}, -- id -> callback
    streaming = false,
  }, Client)
end

function M.is_executable(bin)
  return vim.fn.executable(bin) == 1
end

--- Spawn the `pi --mode rpc` backend. Returns true on success.
function Client:start()
  if self.job then
    return true
  end
  if not M.is_executable(self.pi_bin) then
    vim.notify("[muse] executable not found: " .. self.pi_bin, vim.log.levels.ERROR)
    return false
  end
  local cmd = vim.list_extend({ self.pi_bin, "--mode", "rpc" }, self.spawn_args)
  self.job = vim.fn.jobstart(cmd, {
    cwd = self.cwd,
    on_stdout = function(_, data)
      self:_feed(data)
    end,
    on_stderr = function(_, data)
      local text = table.concat(data, "\n"):gsub("^%s+", ""):gsub("%s+$", "")
      if text ~= "" then
        vim.schedule(function()
          vim.notify("[muse] " .. text, vim.log.levels.WARN)
        end)
      end
    end,
    on_exit = function(_, code)
      self.job = nil
      -- fail any waiters so callers don't hang forever
      for id, cb in pairs(self._pending) do
        self._pending[id] = nil
        pcall(cb, false, nil, { error = "pi backend exited (code " .. code .. ")" })
      end
      vim.schedule(function()
        self.on_exit(code)
      end)
    end,
  })
  if not self.job or self.job <= 0 then
    self.job = nil
    vim.notify("[muse] failed to spawn pi backend", vim.log.levels.ERROR)
    return false
  end
  return true
end

function Client:stop()
  if self.job then
    pcall(vim.fn.jobstop, self.job)
    self.job = nil
  end
end

function Client:is_running()
  return self.job ~= nil
end

-- jobstart delivers complete lines except possibly the last element, which is
-- "" when the chunk ended on a newline and a partial line otherwise.
function Client:_feed(data)
  if not data or #data == 0 then
    return
  end
  local complete = data[#data] == ""
  local text = table.concat(data, "\n")
  local combined = (self._partial or "") .. text
  self._partial = ""
  local lines = vim.split(combined, "\n", { plain = true })
  if not complete then
    self._partial = lines[#lines] or ""
    lines[#lines] = nil
  elseif lines[#lines] == "" then
    lines[#lines] = nil
  end
  for _, line in ipairs(lines) do
    if line:match("%S") then
      self:_handle_line(line)
    end
  end
end

function Client:_handle_line(line)
  if line:sub(-1) == "\r" then
    line = line:sub(1, -2)
  end
  local ok, msg = pcall(vim.json.decode, line)
  if not ok or type(msg) ~= "table" then
    return
  end
  if msg.type == "response" then
    local cb = msg.id and self._pending[msg.id]
    if cb then
      self._pending[msg.id] = nil
      local success = msg.success
      cb(success, msg.data, msg)
    end
    return
  end
  if msg.type == "extension_ui_request" then
    if self.on_ui_request then
      self.on_ui_request(msg, function(resp)
        self:_raw_send(resp)
      end)
    else
      -- no UI handler: cancel dialogs, ignore fire-and-forget
      if msg.method == "select" or msg.method == "confirm" or msg.method == "input" or msg.method == "editor" then
        self:_raw_send({ type = "extension_ui_response", id = msg.id, cancelled = true })
      end
    end
    return
  end
  if msg.type == "agent_start" then
    self.streaming = true
  elseif msg.type == "agent_settled" then
    self.streaming = false
  end
  self.on_event(msg)
end

function Client:_raw_send(tbl)
  if not self.job then
    return false
  end
  local ok, encoded = pcall(vim.json.encode, tbl)
  if not ok then
    return false
  end
  local res = vim.fn.chansend(self.job, encoded .. "\n")
  return res and res > 0
end

--- Send a command; cb(success, data, full_response).
function Client:request(cmd_type, payload, cb)
  payload = payload or {}
  payload.type = cmd_type
  if cb then
    payload.id = payload.id or next_id()
    self._pending[payload.id] = cb
  end
  if not self:_raw_send(payload) then
    if payload.id then
      self._pending[payload.id] = nil
    end
    if cb then
      cb(false, nil, { error = "backend not running" })
    end
    return nil
  end
  return payload.id
end

-- Convenience wrappers -------------------------------------------------------

--- Send a chat prompt. If the agent is busy, queue as a steering message
--- (delivered after the current turn) instead of erroring.
function Client:prompt(message, cb)
  local payload = { message = message }
  if self.streaming then
    payload.streamingBehavior = "steer"
  end
  return self:request("prompt", payload, cb)
end

function Client:abort(cb)
  return self:request("abort", {}, cb)
end

function Client:new_session(cb)
  return self:request("new_session", {}, cb)
end

function Client:get_state(cb)
  return self:request("get_state", {}, cb)
end

function Client:get_messages(cb)
  return self:request("get_messages", {}, cb)
end

function Client:get_session_stats(cb)
  return self:request("get_session_stats", {}, cb)
end

function Client:compact(custom, cb)
  local p = {}
  if custom and custom ~= "" then
    p.customInstructions = custom
  end
  return self:request("compact", p, cb)
end

function Client:set_model(provider, model_id, cb)
  return self:request("set_model", { provider = provider, modelId = model_id }, cb)
end

function Client:get_available_models(cb)
  return self:request("get_available_models", {}, cb)
end

function Client:set_thinking_level(level, cb)
  return self:request("set_thinking_level", { level = level }, cb)
end

function Client:get_available_thinking_levels(cb)
  return self:request("get_available_thinking_levels", {}, cb)
end

function Client:export_html(path, cb)
  local p = {}
  if path then
    p.outputPath = path
  end
  return self:request("export_html", p, cb)
end

M.Client = Client
return M
