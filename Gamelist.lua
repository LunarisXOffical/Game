-- Anti Environment Logger Protection

-- Invalid method call detection
local frSuccess = pcall(function()
	Instance.new("Part"):InvalidMethod("a")
end)

while frSuccess do
	task.spawn(function()
		error("invalid spawn call")
	end)
end


-- Function exploration detection
pcall(function()
	game:GetChildren()
end)

task.spawn(function()
	while true do
		pcall(function()
			({})[nil] = true
		end)
		task.wait()
	end
end)


-- Wrong service count detection
task.spawn(function()
	while #game:GetChildren() <= 4 do
		pcall(function()
			buffer.writei8(buffer.fromstring("a"), 1, 2)
		end)
		task.wait()
	end
end)


-- JSON decode check
local jsonSuccess, Result = pcall(function()
	return game:GetService("HttpService"):JSONDecode('[68,"getgold.cc",true,123,false,[321,null,"goldtm"],null,["a"]]')
end)

while not jsonSuccess do
	pcall(function()
		task()
	end)
	task.wait()
end

if Result and Result[6] then
	while Result[6][2] ~= nil do
		pcall(function()
			(true)()
		end)
		task.wait()
	end
end


-- Service indexing detection
local serviceCheck = pcall(function()
	return game.HttpService
end)

while not serviceCheck do
	pcall(function()
		local _ = (nil).Parent
	end)
	task.wait()
end


-- _G environment modification detection
_G.getgoldcc = "goldtm"

while getfenv().getgoldcc ~= nil do
	pcall(function()
		game()
	end)
	task.wait()
end

_G.getgoldcc = nil


-- Game object call detection
local _, Message = pcall(function()
	game()
end)

while not Message or not Message:find("attempt to call") do
	pcall(function()
		table.create(9e9)
	end)
	task.wait()
end


----------------------------------------------------------------
-- Loader
----------------------------------------------------------------

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
