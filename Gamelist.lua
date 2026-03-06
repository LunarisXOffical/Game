local Games = {
  [131756752872026] = "https://cdn.azguard.my.id/SC-Z5Yv9fFpaeT.lua" -- Dive down
}

local URL = Games[game.GameId]

if URL then
  loadstring(game:HttpGet(URL))()
end
