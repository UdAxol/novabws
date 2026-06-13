-- [Nova v2 loader] Lives on the `rewrite` branch. Different file/branch than the
-- production loader so both can coexist while v2 is in development.
-- Inject with:
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/UdAxol/novabws/rewrite/nova_v2.lua"))()

if shared.nova then pcall(function() shared.nova:Uninject() end) end

local isfile = isfile or function(f) local ok,r = pcall(readfile, f) return ok and r ~= nil end
local isfolder = isfolder or function(f) return false end
local makefolder = makefolder or function() end
local delfile = delfile or function() end

for _, folder in ipairs({"nova", "nova/games", "nova/profiles", "nova/assets", "nova/libraries", "nova/guis"}) do
    if not isfolder(folder) then makefolder(folder) end
end

-- v2 always pulls fresh during development (no commit-based cache).
local BRANCH = "rewrite"
local REPO = "https://raw.githubusercontent.com/UdAxol/novabws/" .. BRANCH

local function downloadFile(path)
    -- Always re-fetch during v2 dev so we don't have to deal with cache wipes.
    local relpath = path:gsub("^nova/", "")
    local url = REPO .. "/" .. relpath
    local ok, res = pcall(function() return game:HttpGet(url, true) end)
    if not ok then error("[Nova v2 loader] HttpGet failed: " .. tostring(res)) end
    if res == "404: Not Found" then error("[Nova v2 loader] 404: " .. relpath) end
    pcall(writefile, path, res)
    return res
end

writefile("nova/profiles/commit.txt", BRANCH)

local mainSrc = downloadFile("nova/main.lua")
local mainFn, err = loadstring(mainSrc, "main")
if not mainFn then error("[Nova v2 loader] main.lua compile error: " .. tostring(err)) end

return mainFn({
    Username = shared.ValidatedUsername or game:GetService("Players").LocalPlayer.Name,
    downloadFile = downloadFile,
})
