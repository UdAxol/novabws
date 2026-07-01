local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local delfile = delfile or function(file)
	writefile(file, '')
end

local function ensureParentFolders(path)
	-- For "nova/assets/new/nova.png", make sure nova, nova/assets, nova/assets/new all exist
	local cur = ''
	for segment in path:gmatch('([^/]+)') do
		if cur == '' then
			cur = segment
		else
			cur = cur .. '/' .. segment
		end
		-- Don't try to make the final filename a folder
		if segment:find('%.') then break end
		if not isfolder(cur) then
			pcall(makefolder, cur)
		end
	end
end

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/UdAxol/novabws/'..readfile('nova/profiles/commit.txt')..'/'..select(1, path:gsub('nova/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after nova updates.\n'..res
		end
		ensureParentFolders(path)
		pcall(writefile, path, res)
	end
	return (func or readfile)(path)
end

local function wipeFolder(path)
	if not isfolder(path) then return end
	for _, file in listfiles(path) do
		if file:find('loader') then continue end
		if isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if its cached, remove it to make the file persist after nova updates.')) == 1 then
			delfile(file)
		end
	end
end

for _, folder in {'nova', 'nova/games', 'nova/profiles', 'nova/assets', 'nova/libraries', 'nova/guis'} do
	pcall(function()
		if not isfolder(folder) then
			makefolder(folder)
		end
	end)
end

if not shared.NovaDeveloper then
	local _, subbed = pcall(function()
		return game:HttpGet('https://github.com/UdAxol/novabws')
	end)
	local commit = subbed:find('currentOid')
	commit = commit and subbed:sub(commit + 13, commit + 52) or nil
	commit = commit and #commit == 40 and commit or 'main'
	if commit == 'main' or (isfile('nova/profiles/commit.txt') and readfile('nova/profiles/commit.txt') or '') ~= commit then
		wipeFolder('nova')
		wipeFolder('nova/games')
		wipeFolder('nova/guis')
		wipeFolder('nova/libraries')
	end
	writefile('nova/profiles/commit.txt', commit)
end

return loadstring(downloadFile('nova/main.lua'), 'main')({
    Username = shared.ValidatedUsername
})
