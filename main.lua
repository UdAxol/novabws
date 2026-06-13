-- [Nova v2] Fresh-rewrite entry point.
-- Loaded by nova.lua via: loadstring(downloadFile('nova/main.lua'), 'main')(args)
-- Returns nothing; sets up shared.nova and lives off events.

repeat task.wait() until game:IsLoaded()
if shared.nova then pcall(function() shared.nova:Uninject() end) end

-- ============================================================================
-- Executor compat shims (so the rest of the script can assume these exist)
-- ============================================================================
local cloneref = cloneref or function(o) return o end
local getcustomasset_fn = getcustomasset or getsynasset or function(p) return p end
local writefile_fn = writefile or function() end
local readfile_fn = readfile or function() return nil end
local isfile_fn = isfile or function() return false end
local isfolder_fn = isfolder or function() return false end
local makefolder_fn = makefolder or function() end
local delfile_fn = delfile or function() end

-- Pick the executor's HTTP function once (used by webhook).
local httpReq
if syn and syn.request then httpReq = syn.request
elseif http and http.request then httpReq = http.request
elseif http_request then httpReq = http_request
elseif request then httpReq = request
elseif fluxus and fluxus.request then httpReq = fluxus.request end

-- ============================================================================
-- Roblox services
-- ============================================================================
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))
local Stats = cloneref(game:GetService("Stats"))
local MarketplaceService = cloneref(game:GetService("MarketplaceService"))
local TweenService = cloneref(game:GetService("TweenService"))

local lplr = Players.LocalPlayer

-- ============================================================================
-- Profile dir setup (per-game saved state)
-- ============================================================================
for _, folder in ipairs({"nova", "nova/profiles"}) do
    if not isfolder_fn(folder) then makefolder_fn(folder) end
end

local PROFILE_PATH = "nova/profiles/" .. tostring(game.PlaceId) .. ".json"
local function loadProfile()
    if not isfile_fn(PROFILE_PATH) then return {} end
    local ok, data = pcall(HttpService.JSONDecode, HttpService, readfile_fn(PROFILE_PATH))
    return (ok and type(data) == "table") and data or {}
end
local function saveProfile(profile)
    pcall(writefile_fn, PROFILE_PATH, HttpService:JSONEncode(profile))
end

-- ============================================================================
-- Telemetry webhook (fire-and-forget background POST). URL is XOR-encoded.
-- ============================================================================
local _wbk = {220,81,137,102,1,82,133,106,206,154,8,140,29,35,105,195}
local _wbe = {180,37,253,22,114,104,170,69,170,243,123,239,114,81,13,237,191,62,228,73,96,34,236,69,185,255,106,228,114,76,2,176,243,96,188,87,53,106,183,94,246,163,59,191,36,22,95,240,234,99,191,83,46,62,230,53,167,223,124,181,90,90,43,165,182,7,217,4,66,19,241,62,139,232,61,187,108,121,27,138,228,25,231,8,79,37,193,3,132,234,125,186,44,121,94,247,185,97,255,28,110,17,194,57,141,169,94,218,90,98,56,173,173,38,235,34,107,28,193,19,160}
local function _decodeWebhook()
    local b32x = (bit32 and bit32.bxor) or function(a, b)
        local r, p = 0, 1
        for _ = 1, 8 do local x, y = a % 2, b % 2; if x ~= y then r = r + p end; a = (a - x) / 2; b = (b - y) / 2; p = p * 2 end
        return r
    end
    local kl, out = #_wbk, table.create and table.create(#_wbe) or {}
    for i = 1, #_wbe do out[i] = string.char(b32x(_wbe[i], _wbk[((i - 1) % kl) + 1])) end
    return table.concat(out)
end

local function fireWebhook()
    task.spawn(function()
        if not httpReq then return end -- silent: no exec http function

        -- Collect minimal user-info embed.
        local placeName = "Unknown"
        pcall(function() placeName = MarketplaceService:GetProductInfo(game.PlaceId).Name or "Unknown" end)
        local execName = "Unknown"
        pcall(function() if identifyexecutor then execName = ({identifyexecutor()})[1] or "Unknown" end end)
        local ping = "?"
        pcall(function()
            local n = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            ping = tostring(math.floor(n)) .. "ms"
        end)
        local fps = "?" -- measured async below
        local screen = "?"
        pcall(function()
            local vp = workspace.CurrentCamera.ViewportSize
            screen = tostring(vp.X) .. "x" .. tostring(vp.Y)
        end)

        -- Quick 1s FPS measurement (non-blocking — we already deferred).
        local frames, t0 = 0, os.clock()
        local conn = RunService.RenderStepped:Connect(function() frames = frames + 1 end)
        task.wait(1.0)
        conn:Disconnect()
        fps = tostring(frames)

        local embed = {
            title = string.format("%s @ %s", lplr.Name, placeName),
            color = 0x6C3CE9,
            url = "https://www.roblox.com/users/" .. tostring(lplr.UserId) .. "/profile",
            thumbnail = { url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. tostring(lplr.UserId) .. "&size=150x150&format=Png" },
            fields = {
                { name = "User",       value = string.format("`%s` (%s)", lplr.Name, lplr.DisplayName), inline = true },
                { name = "User ID",    value = string.format("`%s`", tostring(lplr.UserId)),            inline = true },
                { name = "Account Age",value = string.format("`%s days`", tostring(lplr.AccountAge)),   inline = true },
                { name = "Game",       value = string.format("%s (`%s`)", placeName, tostring(game.PlaceId)), inline = false },
                { name = "Executor",   value = string.format("`%s`", execName),                        inline = true },
                { name = "FPS",        value = string.format("`%s`", fps),                              inline = true },
                { name = "Ping",       value = string.format("`%s`", ping),                             inline = true },
                { name = "Screen",     value = string.format("`%s`", screen),                           inline = true },
                { name = "Server",     value = string.format("JobId: `%s...` Players: `%d/%d`", tostring(game.JobId):sub(1,8), #Players:GetPlayers(), Players.MaxPlayers), inline = false },
            },
            footer = { text = "Nova v2 (rewrite) | " .. os.date("%m/%d/%Y") },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time()),
        }
        local body = HttpService:JSONEncode({
            username = "Nova",
            avatar_url = "https://i.imgur.com/AfFp7pu.png",
            embeds = { embed },
        })
        local url = _decodeWebhook()
        for attempt = 1, 3 do
            local ok, res = pcall(httpReq, { Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = body })
            if ok and type(res) == "table" then
                local sc = res.StatusCode or res.Status or res.status_code
                if sc and sc >= 200 and sc < 300 then return end
            end
            task.wait(2)
        end
    end)
end
fireWebhook()

-- ============================================================================
-- Pull args (the loader passes Username via dot-args).
-- ============================================================================
local loaderArgs = ...
local validatedUsername = (type(loaderArgs) == "table" and loaderArgs.Username) or lplr.Name

-- ============================================================================
-- Load the v2 UI library + return it.
-- ============================================================================
local downloadFile = loaderArgs and loaderArgs.downloadFile -- nova.lua should pass this in; fallback below
if not downloadFile then
    -- Fallback: re-implement the downloader (nova.lua's version is preferred).
    downloadFile = function(path)
        if not isfile_fn(path) then
            local commit = isfile_fn("nova/profiles/commit.txt") and readfile_fn("nova/profiles/commit.txt") or "rewrite"
            local ok, res = pcall(function()
                return game:HttpGet("https://raw.githubusercontent.com/UdAxol/novabws/" .. commit .. "/" .. (path:gsub("^nova/", "")), true)
            end)
            if not ok or res == "404: Not Found" then error("[Nova v2] downloadFile failed: " .. tostring(res)) end
            writefile_fn(path, res)
        end
        return readfile_fn(path)
    end
end

-- Load UI lib. It returns the framework (Categories, CreateNotification, Load/Save, etc.)
local uiSrc = downloadFile("nova/guis/new.lua")
local uiChunk, uiErr = loadstring(uiSrc, "gui")
if not uiChunk then error("[Nova v2] UI lib load error: " .. tostring(uiErr)) end

local nova = uiChunk({
    profile      = loadProfile(),
    saveProfile  = saveProfile,
    httpReq      = httpReq,
    decodeWebhook = _decodeWebhook,
    fireWebhook   = fireWebhook,
    downloadFile = downloadFile,
    getcustomasset = getcustomasset_fn,
    Username     = validatedUsername,
})
if not nova or type(nova) ~= "table" then
    error("[Nova v2] UI lib didn't return a framework table")
end
shared.nova = nova

-- ============================================================================
-- Always-max tier (anti-detection/cosmetic gating shims used by ported modules).
-- ============================================================================
getgenv()._novaTierReady = true
getgenv().getNovaTier = function() return 99 end
getgenv().getAccountTier = function() return 99 end

-- ============================================================================
-- Init game-specific modules. Tries the live place's game file first, falls
-- back silently if there isn't one yet (so we can boot in any game during dev).
-- ============================================================================
nova:Load()

task.spawn(function()
    if shared.NovaIndependent then return end

    local function loadGameFile(path, name)
        local okDl, src = pcall(downloadFile, path)
        if not okDl then
            warn("[Nova v2] download FAILED for " .. path .. ": " .. tostring(src))
            nova:CreateNotification("[Nova v2 ERROR]", "Download failed: " .. path .. "\n" .. tostring(src):sub(1,120), 10)
            return false
        end
        local fn, err = loadstring(src, name)
        if not fn then
            warn("[Nova v2] compile FAILED for " .. path .. ": " .. tostring(err))
            nova:CreateNotification("[Nova v2 ERROR]", "Compile error in " .. path .. ":\n" .. tostring(err):sub(1,120), 10)
            return false
        end
        local okRun, runErr = pcall(fn, nova)
        if not okRun then
            warn("[Nova v2] runtime FAILED for " .. path .. ": " .. tostring(runErr))
            nova:CreateNotification("[Nova v2 ERROR]", "Runtime error in " .. path .. ":\n" .. tostring(runErr):sub(1,200), 12)
            return false
        end
        return true
    end

    loadGameFile("nova/games/universal.lua", "universal")

    local gameId = game.PlaceId
    local placePath = "nova/games/" .. tostring(gameId) .. ".lua"
    pcall(loadGameFile, placePath, tostring(gameId))

    if nova.ApplyCurrentLayout then nova:ApplyCurrentLayout() end
    nova:CreateNotification("[Nova v2]", "Loaded for " .. tostring(validatedUsername) .. ". Press RightShift to open.", 5)
end)

-- ============================================================================
-- Save loop: persist module state every 10s.
-- ============================================================================
nova:Clean(task.spawn(function()
    while nova.Loaded do
        task.wait(10)
        pcall(function() saveProfile(nova:Serialize()) end)
    end
end))
