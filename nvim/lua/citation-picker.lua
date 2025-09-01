-- Citation completion setup for .bib files
-- Add this to your vim-options.lua or create a new file in lua/

-- Path to your .bib file (adjust as needed)
local bib_file = vim.fn.expand("~/Documents/zotero.bib") -- Change this to your actual .bib file path

-- Function to parse .bib file and extract citation keys
local function parse_bib_file(file_path)
    local citations = {}
    local file = io.open(file_path, "r")
    
    if not file then
        return citations
    end
    
    for line in file:lines() do
        -- Match @article{key, @book{key, etc.
        local key = line:match("^%s*@%w+%s*{%s*([^,%s]+)")
        if key then
            table.insert(citations, key)
        end
    end
    
    file:close()
    return citations
end

-- Context-aware omnifunc that falls back to default completion
local function smart_omnifunc(findstart, base)
    if findstart == 1 then
        -- Find the start of the citation
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2]
        
        -- Look for @ symbol before cursor for citation context
        local start = col
        local found_at = false
        while start > 0 do
            local char = line:sub(start, start)
            if char == "@" then
                found_at = true
                break
            elseif char:match("%s") then
                break
            end
            start = start - 1
        end
        
        if found_at then
            return start  -- Return 0-based column for citation completion
        else
            -- Fall back to default omnifunc behavior (keyword completion)
            local word_start = col
            while word_start > 0 do
                local char = line:sub(word_start, word_start)
                if char:match("[%w_]") then
                    word_start = word_start - 1
                else
                    break
                end
            end
            return word_start  -- Return start of current word
        end
    else
        -- Check if we're in citation context
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2]
        
        -- Look for @ symbol before current position
        local in_citation = false
        local start = col - #base
        while start > 0 do
            local char = line:sub(start, start)
            if char == "@" then
                in_citation = true
                break
            elseif char:match("%s") then
                break
            end
            start = start - 1
        end
        
        if in_citation then
            -- Return citation candidates
            local citations = parse_bib_file(bib_file)
            local matches = {}
            
            for _, citation in ipairs(citations) do
                if citation:lower():find(base:lower(), 1, true) then
                    table.insert(matches, citation)
                end
            end
            
            return matches
        else
            -- Fall back to default completion (syntaxcomplete, dictionary, etc.)
            -- This mimics the default omnifunc behavior
            local words = {}
            local current_buf = vim.api.nvim_get_current_buf()
            local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
            
            -- Extract words from current buffer
            for _, line_text in ipairs(lines) do
                for word in line_text:gmatch("[%w_]+") do
                    if word:lower():find(base:lower(), 1, true) and #word > #base then
                        if not vim.tbl_contains(words, word) then
                            table.insert(words, word)
                        end
                    end
                end
            end
            
            return words
        end
    end
end

-- Set up the omnifunc for markdown files
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "rmd", "Rmd", "qmd", "Qmd", "tex", "pandoc" },
    callback = function()
        -- Set the smart omnifunc that handles both citations and normal completion
        vim.bo.omnifunc = "v:lua.smart_omnifunc"
    end,
})

-- Make the function globally accessible
_G.smart_omnifunc = smart_omnifunc
