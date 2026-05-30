local nova = shared.nova
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and nova then
		nova:CreateNotification('Nova', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
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
		writefile(path, res)
	end
	return (func or readfile)(path)
end

nova.Place = 11630038968
if isfile('nova/games/'..nova.Place..'.lua') then
	loadstring(readfile('nova/games/'..nova.Place..'.lua'), 'bridge duel')()
else
	if not shared.NovaDeveloper then
		local suc, res = pcall(function() return
			game:HttpGet('https://raw.githubusercontent.com/UdAxol/novabws/'..readfile('nova/profiles/commit.txt')..'/games/'..nova.Place..'.lua', true)
		end)
		if suc and res ~= '404: Not Found' then
			loadstring(downloadFile('nova/games/'..nova.Place..'.lua'), 'bridge duel')()
		end
	end
end
