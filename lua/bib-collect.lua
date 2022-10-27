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

local function subset_bib(reference_list, main_bib)
	local subset = {}
	local missing_ref = {}
	for reference, _ in pairs(reference_list) do
		local found = 0
		for i, v in ipairs(main_bib) do
			if v.name == reference then
				found = 1
				subset[reference] = v.content 
			end
		end
		if found == 0 then
			missing_ref[k] = "key not found"
		end
	end
	return subset, missing_ref
end

local M = {}
M.bib = function()
	local q = require"vim.treesitter.query"	
	local ts = vim.treesitter
	local bufnr = 0 
	local tparser = ts.get_parser(bufnr, "latex")
	local tstree = tparser:parse()
	local root = tstree[1]:root()
	local query = ts.parse_query("latex", [[
	(text word: (citation) @method)
	]])
	local reference_list = {}
	local sep = ","
	for _, captures, metadata in query:iter_captures(root, bufnr) do
		local cite_list = (string.sub(q.get_node_text(captures, bufnr), 7, -2))
		for str in string.gmatch(cite_list, "([^"..sep.."]+)") do
			reference_list[str] = "citation"
		end
	end
	local main_bib = get_results()
	local project_bib, missing_ref = subset_bib(reference_list, main_bib)
	local bib = io.open("bibliography.bib", "w")
	local missing_bib = io.open("missing_ref.txt", "w")
	for k, entry in pairs(project_bib) do
		for _, line in pairs(entry) do 
			bib:write(line, "\n")
		end
	end
	for _, entry in pairs(missing_ref) do
		missing_bib:write(entry, "\n")
	end
end
return M
