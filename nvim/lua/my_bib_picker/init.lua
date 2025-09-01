local snacks = require("snacks")

local M = {}

-- Expand ~ to home directory
local function expand_path(path)
  return path:gsub("^~", os.getenv("HOME"))
end

-- Parse a .bib file and return a table of { key, title }
local function parse_bib_file(file_path)
  file_path = expand_path(file_path)
  local entries = {}
  local entry = nil
  local in_title = false
  local title_acc = ""

  for line in io.lines(file_path) do
    local key = line:match("@%w+{(.-),")
    if key then
      if entry then
        table.insert(entries, entry)
      end
      entry = { key = key, title = "" }
      in_title = false
      title_acc = ""
    elseif entry then
      local t_start = line:match("title%s*=%s*{(.*)")
      if t_start then
        in_title = true
        title_acc = t_start
        local t_end = title_acc:match("(.-)}")
        if t_end then
          entry.title = t_end
          in_title = false
        end
      elseif in_title then
        title_acc = title_acc .. " " .. line
        local t_end = title_acc:match("(.-)}")
        if t_end then
          entry.title = t_end
          in_title = false
        end
      end
    end
  end

  if entry then
    table.insert(entries, entry)
  end

  return entries
end

-- Snacks picker function
function M.bib_picker(bibfile)
  local entries = parse_bib_file(bibfile)
  if #entries == 0 then
    print("No entries found in " .. bibfile)
    return
  end

  local items = {}
  for _, entry in ipairs(entries) do
    table.insert(items, entry.key .. " - " .. entry.title)
  end

  -- Use snacks.picker.new instead of snacks.picker directly
  snacks.picker.new({
    prompt_title = "Select a Reference",
    results = items,
    attach_mappings = function(prompt_bufnr, map)
      map("i", "<CR>", function()
        local selection = snacks.get_selected(prompt_bufnr)
        print("You selected: " .. selection)
        snacks.close(prompt_bufnr)
      end)
      return true
    end,
  }):find()
end

return M

