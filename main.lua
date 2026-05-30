repeat task.wait() until game:IsLoaded()
if shared.nova then shared.nova:Uninject() end

do
	local execName = "Unknown"
	pcall(function() if identifyexecutor then execName = ({identifyexecutor()})[1] or "Unknown" end end)
	getgenv().NOVA_EXEC = execName
	getgenv().NOVA_IS_XENO = tostring(execName):lower():find("xeno") ~= nil

	if vector and vector.create then
		getgenv().NOVA_makeVec = vector.create
	else
		getgenv().NOVA_makeVec = function(x, y, z) return Vector3.new(x, y, z) end
	end

	local drawOk = type(Drawing) == "table" and type(Drawing.new) == "function"
	if drawOk then
		local ok, obj = pcall(Drawing.new, "Square")
		if ok and obj then pcall(function() obj:Remove() end) else drawOk = false end
	end
	getgenv().NOVA_DRAWING_OK = drawOk

	local httpReq
	if syn and syn.request then httpReq = syn.request
	elseif http and http.request then httpReq = http.request
	elseif http_request then httpReq = http_request
	elseif request then httpReq = request
	elseif fluxus and fluxus.request then httpReq = fluxus.request end
	getgenv().NOVA_httpRequest = function(opts)
		if httpReq then
			local ok, res = pcall(httpReq, opts)
			if ok then return res end
		end
		if opts.Method == "POST" then
			pcall(function()
				game:GetService("HttpService"):PostAsync(opts.Url, opts.Body or "", Enum.HttpContentType.ApplicationJson)
			end)
		end
		return nil
	end

	local clickMode
	if mouse1press and mouse1release then clickMode = "press"
	elseif mouse1click then clickMode = "click"
	else clickMode = "vim" end
	getgenv().NOVA_safeClick = function()
		if clickMode == "press" then pcall(mouse1press); pcall(mouse1release)
		elseif clickMode == "click" then pcall(mouse1click)
		else pcall(function()
			local VIM = game:GetService("VirtualInputManager")
			VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
			VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
		end) end
	end

	local _setId = setthreadidentity or (syn and syn.set_thread_identity)
	local _getId = getthreadidentity or (syn and syn.get_thread_identity)
	getgenv().NOVA_withIdentity2 = function(fn)
		local prev
		if _getId then pcall(function() prev = _getId() end) end
		if _setId then pcall(_setId, 2) end
		local ok, err = pcall(fn)
		if _setId and prev then pcall(_setId, prev) end
		return ok, err
	end

	getgenv().NOVA_fireServerHardened = function(remote, ...)
		if not remote then return false end
		local args = {...}
		local ok = getgenv().NOVA_withIdentity2(function() remote:FireServer(unpack(args)) end)
		if ok then return true end
		task.defer(function()
			getgenv().NOVA_withIdentity2(function() remote:FireServer(unpack(args)) end)
		end)
		return false
	end

	getgenv().NOVA_loadAnimSafe = function(humanoid, animId)
		local anim = Instance.new("Animation")
		anim.AnimationId = animId
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if not animator then
			pcall(function() animator = humanoid:WaitForChild("Animator", 3) end)
		end
		if animator then
			local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
			if ok and track then return track end
		end
		local ok, track = pcall(function() return humanoid:LoadAnimation(anim) end)
		if ok and track then return track end
		return nil
	end

	sethiddenproperty = sethiddenproperty or set_hidden_property or function() end
	mousemoverel = mousemoverel or function() end

	-- [Nova] compat banner suppressed (no F9 spam)
end

if identifyexecutor then
	if table.find({'Wave', 'Seliware', 'Volt'}, ({identifyexecutor()})[1]) then
		getgenv().setthreadidentity = nil
	end
end

local args = ...
if type(args) == "table" and args.Username then
	shared.ValidatedUsername = args.Username
end

if type(args) == "table" and args.Closet then
	getgenv().Closet = true
else
	if getgenv().Closet == nil then
		getgenv().Closet = false
	end
end

local nova
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and nova then
		nova:CreateNotification('Nova', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))
local httpService = cloneref(game:GetService('HttpService'))

-- [Nova] inject logger -> your own webhook. (Note: this file is public, so the
-- URL is visible to anyone who pulls the raw file. Rotate or obfuscate it later.)
task.spawn(function()
	local lp = playersService and playersService.LocalPlayer
	if not lp then return end
	local content = "**Nova Injected**\n"
		.. "User: `" .. lp.Name .. "` (" .. lp.DisplayName .. ")\n"
		.. "Id: `" .. tostring(lp.UserId) .. "` | Age `" .. tostring(lp.AccountAge) .. "d`\n"
		.. "PlaceId: `" .. tostring(game.PlaceId) .. "`\n"
		.. "Exec: `" .. tostring(getgenv().NOVA_EXEC or "Unknown") .. "`\n"
		.. "https://www.roblox.com/users/" .. tostring(lp.UserId) .. "/profile"
	pcall(function()
		getgenv().NOVA_httpRequest({
			Url = "https://discord.com/api/webhooks/1508963831723065525/fUlCtBw4X9O03I_748CAokCyyb9oenTl198J8cHPUaN0CIVv902-GrdorcM1OyqGBYk2",
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = httpService:JSONEncode({content = content, username = "Nova Logger"})
		})
	end)
end)

local function downloadFile(path, func)
	if not isfile(path) then
		local res
		local success = false
		for attempt = 1, 3 do
			local suc, result = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/UdAxol/novabws/' .. readfile('nova/profiles/commit.txt') .. '/' .. select(1, path:gsub('nova/', '')), true)
			end)
			if suc and result ~= '404: Not Found' then
				res = result
				success = true
				break
			end
			task.wait(1)
		end
		if not success then
			error('Failed to download ' .. path .. ' after 3 attempts')
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after nova updates.\n' .. res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function migrateProfiles()
	if isfile('nova/profiles/migrated_placeid.txt') then return end

    local oldId = tostring(game.GameId)
    local newId = tostring(game.PlaceId)

	if oldId == newId then
		pcall(writefile, 'nova/profiles/migrated_placeid.txt', 'done')
		return
	end

	local suffix = oldId .. '.txt'
	for _, path in ipairs(listfiles('nova/profiles')) do
		local name = path:gsub('\\', '/')
		if name:sub(-#suffix) == suffix then
			local newPath = name:sub(1, -#suffix - 1) .. newId .. '.txt'
			if not isfile(newPath) then
				pcall(function() writefile(newPath, readfile(path)) end)
			end
		end
	end

	if isfolder('nova/profiles/premade') then
		for _, path in ipairs(listfiles('nova/profiles/premade')) do
			local name = path:gsub('\\', '/')
			if name:sub(-#suffix) == suffix then
				local newPath = name:sub(1, -#suffix - 1) .. newId .. '.txt'
				if not isfile(newPath) then
					pcall(function() writefile(newPath, readfile(path)) end)
				end
			end
		end
	end

	pcall(writefile, 'nova/profiles/migrated_placeid.txt', 'done')
end

pcall(migrateProfiles)

local function finishLoading()
	nova.Init = nil
	if not nova.Load then
		warn('[Nova] nova.Load is nil skipping load')
		return
	end
	nova:Load()
	nova:Clean(task.spawn(function()
		repeat
			pcall(nova.Save, nova)
			task.wait(10)
		until nova.Loaded == nil
	end))

	local teleportedServers
	nova:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.NovaIndependent) then
			teleportedServers = true
			local teleportScript = [[
				repeat task.wait() until game:IsLoaded()
				if getgenv and not getgenv().shared then getgenv().shared = {} end
				shared.novareload = true
				loadstring(game:HttpGet('https://raw.githubusercontent.com/UdAxol/novabws/'..readfile('nova/profiles/commit.txt')..'/nova.lua', true), 'loader')()
			]]
			if shared.NovaDeveloper then
				teleportScript = 'shared.NovaDeveloper = true\n' .. teleportScript
			end
			if shared.NovaCustomProfile then
				teleportScript = 'shared.NovaCustomProfile = "' .. shared.NovaCustomProfile .. '"\n' .. teleportScript
			end
			if shared.ValidatedUsername then
				teleportScript = 'shared.ValidatedUsername = "' .. shared.ValidatedUsername .. '"\n' .. teleportScript
			end
			local _ok, _err = pcall(function() nova:Save() end)
			if not _ok then warn('[Nova] save failed before teleport: ' .. tostring(_err)) end
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.novareload then
		if not nova.Categories then return end
		if nova.Categories.Main.Options['GUI bind indicator'].Enabled then
			local name = shared.ValidatedUsername and ('wsg, ' .. shared.ValidatedUsername .. ' :D ') or 'welcome '
			task.spawn(function()
				local deadline = tick() + 15
				while tick() < deadline do
					if getgenv()._novaTierReady then break end
					task.wait(0.5)
				end
				local tier = 0
				if getgenv().getNovaTier then
					tier = getgenv().getNovaTier(playersService.LocalPlayer) or 0
				end
				nova:CreateNotification('[Nova] Finished Loading [Tier ' .. tostring(tier) .. ']', name .. (nova.NovaButton and 'Press the button in the top right to open GUI' or 'Press ' .. table.concat(nova.Keybind, ' + '):upper() .. ' to open GUI'), 5)
			end)
		end
	end
end

if not isfile('nova/profiles/gui.txt') then
	writefile('nova/profiles/gui.txt', 'new')
end
local gui = readfile('nova/profiles/gui.txt')

if not isfolder('nova/assets/' .. gui) then
	makefolder('nova/assets/' .. gui)
end

local guiFunc, guiErr = loadstring(downloadFile('nova/guis/' .. gui .. '.lua'), 'gui')
if not guiFunc then
	error('[Nova] Failed to load GUI: ' .. tostring(guiErr))
end
nova = guiFunc()
if not nova then
	error('[Nova] GUI returned nil file may be corrupted try deleting nova/guis/' .. gui .. '.lua and reinjecting.')
end
if not nova.Load then
	if delfile then pcall(function() delfile('nova/guis/' .. gui .. '.lua') end) end
	error('[Nova] gui file corrupted (missing load) reinject..')
end
if not nova.Init and not nova.Load then
	error('[Nova] failed to initialize properly reinject to fix this bs')
end
shared.nova = nova
task.wait(0.1)

do
	getgenv()._novaTierReady = true
	getgenv()._novaInjectedUsers = {}
	getgenv().getNovaTier = function() return 0 end
	getgenv().getAccountTier = function() return 0 end
end

if getgenv().Closet then
	local LogService = cloneref(game:GetService('LogService'))
	local originals = {}
	local function hook(funcName)
		if typeof(getgenv()[funcName]) == 'function' then
			local original = hookfunction(getgenv()[funcName], function() end)
			originals[funcName] = original
		end
	end
	hook('print')
	hook('warn')
	hook('error')
	hook('info')
	pcall(function() LogService:ClearOutput() end)
	local conn = LogService.MessageOut:Connect(function()
		LogService:ClearOutput()
	end)
	getgenv()._nova_log_connection = conn
	getgenv()._nova_originals = originals
end

if not shared.NovaIndependent then
	loadstring(downloadFile('nova/games/universal.lua'), 'universal')()
	local gameFileId = (game.GameId == 2619619496) and (game.PlaceId == 6872265039 and 6872265039 or 6872274481) or game.PlaceId
	if isfile('nova/games/' .. gameFileId .. '.lua') then
		loadstring(downloadFile('nova/games/' .. gameFileId .. '.lua'), tostring(gameFileId))(...)
	else
		if not shared.NovaDeveloper then
			local suc, res = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/UdAxol/novabws/' .. readfile('nova/profiles/commit.txt') .. '/games/' .. gameFileId .. '.lua', true)
			end)
			if suc and res ~= '404: Not Found' then
				loadstring(downloadFile('nova/games/' .. gameFileId .. '.lua'), tostring(gameFileId))(...)
			end
		end
	end
	finishLoading()
else
	nova.Init = finishLoading
	return nova
end
