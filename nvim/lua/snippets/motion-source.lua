local source = {}

source.new = function()
  return setmetatable({}, { __index = source })
end

source.get_completions = function(_, ctx, callback)
  local input = ctx.line:match("m%.(%w*)$")
  if not input then
    return callback({ items = {}, is_incomplete_forward = false })
  end

  local tags = { "span", "div", "button", "a", "p", "ul", "li", "nav", "section", "header" }
  local items = {}


  for _, tag in ipairs(tags) do
    if tag:sub(1, #input) == input then
      table.insert(items, {
        label = "m." .. tag,
        kind = vim.lsp.protocol.CompletionItemKind.Snippet,
        insertTextFormat = 2,
        insertText = "<motion." .. tag .. ">$1</motion." .. tag .. ">",
        textEdit = {
          newText = "<motion." .. tag .. ">$1</motion." .. tag .. ">",
          range = {
            start = { line = ctx.cursor[1] - 1, character = ctx.cursor[2] - #("m." .. input) },
            ["end"] = { line = ctx.cursor[1] - 1, character = ctx.cursor[2] },
          },
        },
      })
    end
  end


  if #input > 0 then
    table.insert(items, 1, {
      label = "m." .. input,
      kind = vim.lsp.protocol.CompletionItemKind.Snippet,
      insertTextFormat = 2,
      textEdit = {
        newText = "<motion." .. input .. ">$1</motion." .. input .. ">",
        range = {
          start = { line = ctx.cursor[1] - 1, character = ctx.cursor[2] - #("m." .. input) },
          ["end"] = { line = ctx.cursor[1] - 1, character = ctx.cursor[2] },
        },
      },
    })
  end

  callback({ items = items, is_incomplete_forward = true })
end

return source
