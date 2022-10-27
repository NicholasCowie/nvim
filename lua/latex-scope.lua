local path = require("plenary.path")
local putils = require("telescope.previewers.utils")
local actions = require("telescope.actions")

local function end_of_entry(line, par_mismatch)
	local line_blank = line:gsub("%s", "")
	for _ in (line_blank):gmatch("{") do
		par_mismatch = par_mismatch + 1
	end
	for _ in (line_blank):gmatch("}") do
		par_mismatch = par_mismatch - 1
	end
	return par_mismatch == 0
end

local function read_file()
	local entries = {}
	local contents = {}
	local p = path:new([[/Users/nicow/ref/My Library.bib]])
	if not p:exists() then
		return {}
	end
	local current_entry = ""
	local in_entry = false
	local par_mismatch = 0
	for line in p:iter() do
		if line:match("@%w*{") then
			in_entry = true
			par_mismatch = 1
			local entry = line:gsub("@%w*{", "")
			entry = entry:sub(1, -2)
			current_entry = entry
			table.insert(entries, entry)
			contents[current_entry] = { line }
		elseif in_entry and line ~= "" then
			table.insert(contents[current_entry], line)
			if end_of_entry(line, par_mismatch) then
				in_entry = false
			end
		end
	end
	return entries, contents
end

local function get_results()
   local results = {}
   local result, content = read_file()
   for _, entry in pairs(result) do
      table.insert(results, { name = entry, content = content[entry] })
   end
   return results
end

local function insert_line_with(line, prompt_bufnr, mode)
   -- disable autopairs so it doesn't get crazy with the ("
   mode = mode or "o"
   vim.api.nvim_set_var("matched", line)
   print(line)
   actions.close(prompt_bufnr)
   vim.cmd([[exe "normal! ]] .. mode .. [[" . matched]])
end

local M = {}
M.bib = function()

  local results = get_results()
  require("telescope.pickers").new({
     results_title = "Bibliography",
     prompt_prefix = "龎",
     finder = require("telescope.finders").new_table({
        results = results,
        entry_maker = function(line)
        return {
           value = line.name,
           ordinal = line.name,
           display = line.name,
           preview_command = function(entry, bufnr)
           vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, results[entry.index].content)
           putils.highlighter(bufnr, "bib")
           end,
        }
        end,
     }),
     -- the selected entry will be accessed through results, which has the content
     previewer = require("telescope.previewers").display_content.new(results),
     sorter = require("telescope.sorters").get_fzy_sorter(),
     attach_mappings = function(prompt_bufnr, map)
       -- On enter, insert "\autocite{ref}"
       map("i", "<cr>", function(bufnr)
         local content = require("telescope.actions.state").get_selected_entry(bufnr)
         local match = content.value
         insert_line_with([[\cite{]] .. match .. [[}]], prompt_bufnr, "a")
       end)
       -- the ref id itself
       map("i", "<C-i>", function(bufnr)
         local content = require("telescope.actions.state").get_selected_entry(bufnr)
         local match = content.value
         insert_line_with(match, prompt_bufnr, "a")
       end)
       return true
     end,
  }):find()
  end

return M
