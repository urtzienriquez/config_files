vim.pack.add({ "https://github.com/justinmk/guh.nvim" })

local fzf_get = require("plugins.fzf-lua").get

-- guh.nvim buffers picker
local function guh_buffers()
  local label_to_buf = {}
  local entries = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) then
      local name = vim.api.nvim_buf_get_name(b)
      if name:match("^guh://") then
        local g = vim.b[b].guh
        local label
        if g and g.feat then
          label = string.format(
            "%-11s %s%s%s",
            g.feat,
            g.repo and (g.repo .. "#" .. tostring(g.id)) or tostring(g.id or ""),
            g.title and g.title ~= "" and "  " or "",
            g.title or ""
          )
        else
          label = name
        end
        entries[#entries + 1] = label
        label_to_buf[label] = b
      end
    end
  end

  if #entries == 0 then
    vim.notify("No guh.nvim buffers open", vim.log.levels.INFO)
    return
  end

  fzf_get().fzf_exec(entries, {
    prompt = "GitHub buffers❯ ",
    actions = {
      ["default"] = function(selected)
        local buf = label_to_buf[selected[1]]
        ---@diagnostic disable-next-line: unnecessary-if
        if buf and vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_set_current_buf(buf)
        end
      end,
      ["ctrl-x"] = {
        fn = function(selected)
          local buf = label_to_buf[selected[1]]
          ---@diagnostic disable-next-line: unnecessary-if
          if buf and vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end,
        reload = true,
      },
    },
  })
end

vim.keymap.set("n", "<leader>fu", guh_buffers, { desc = "GitHub buffers" })
