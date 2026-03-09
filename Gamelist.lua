local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Games = {
	[8944906740] = "https://cdn.azguard.my.id/SC-Z5Yv9fFpaeT.lua" -- Dive Down
}

local url = Games[game.GameId]

if url then
	local success, scriptData = pcall(function()
		return game:HttpGet(url)
	end)

	if success and scriptData then
		loadstring(scriptData)()
	else
		warn("Failed to fetch script.")
	end
else
	if Players.LocalPlayer then
		Players.LocalPlayer:Kick("Unsupported game.")
	end
end
