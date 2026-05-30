local folderToClean = "nova"
local folderToKeep = "nova/profiles"
local loaderUrl = "https://raw.githubusercontent.com/UdAxol/novabws/main/nova.lua"

local function deleteRecursive(path)
	if path == folderToKeep then return end
	if isfolder and isfolder(path) then
		for _, item in ipairs(listfiles(path)) do
			deleteRecursive(item)
		end
		if path ~= folderToKeep then
			pcall(function() if delfolder then delfolder(path) end end)
		end
	else
		pcall(function() delfile(path) end)
	end
end

if not isfolder(folderToClean) then
	print("[Nova] folder '" .. folderToClean .. "' not found, nothing to reset.")
else
	for _, item in ipairs(listfiles(folderToClean)) do
		if item ~= folderToKeep then
			deleteRecursive(item)
		end
	end
end

print("[Nova] reset complete, reloading...")
task.wait(1)
loadstring(game:HttpGet(loaderUrl, true), "loader")()
