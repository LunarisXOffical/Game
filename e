-- Junkie Development External Loader
-- This loads the Junkie-Library
local success, Junkie = pcall(function()
    return loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
end)

if not success or not Junkie then
    warn("Failed to load Junkie SDK")
    return
end

Junkie.service = "test"
Junkie.identifier = "20"
Junkie.provider = "WorkInk"

-- Debug info
print("Junkie SDK loaded successfully")
print("Service:", Junkie.service)
print("Identifier:", Junkie.identifier)

-- Function to validate a key
local function validateKey(key)
    if not key or type(key) ~= "string" or #key < 5 then
        return false, "Invalid key format"
    end
    
    local cleanKey = key:gsub("%s+", ""):upper()
    
    -- Call Junkie API to check the key
    local success, result = pcall(function()
        return Junkie.check_key(cleanKey)
    end)
    
    if not success then
        return false, "API Error"
    end
    
    if result and result.valid then
        return true, result.message or "Valid key"
    else
        return false, result and result.message or "Invalid key"
    end
end

-- Check for existing key in getgenv().SCRIPT_KEY
local function checkExistingKey()
    if getgenv().SCRIPT_KEY and type(getgenv().SCRIPT_KEY) == "string" then
        print("🔍 Checking getgenv().SCRIPT_KEY...")
        print("Key found:", string.sub(getgenv().SCRIPT_KEY, 1, 20) .. "...")
        
        local isValid, message = validateKey(getgenv().SCRIPT_KEY)
        
        if isValid then
            print("✅ Existing key is VALID!")
            return true, getgenv().SCRIPT_KEY
        else
            print("❌ Existing key invalid:", message)
            getgenv().SCRIPT_KEY = nil
            return false
        end
    end
    return false
end

-- Main execution
local hasValidKey, validKey = checkExistingKey()

if hasValidKey and validKey then
    print("🚀 Loading main script with valid key...")
    -- Load your main script
    loadstring(game:HttpGet("https://raw.githubusercontent.com/LunarisXOffical/Game/refs/heads/main/ithinkyes.lua"))()
    return
end

-- If no valid key found, show the UI
print("🖥️ Showing Junkie UI for key input...")

-- Your complete Junkie UI code starts here
-- Just copy and paste ALL your UI code from line 23 to the end of your file
-- (from "local TweenService = game:GetService("TweenService")" to the end)

-- But modify the redeem button section to load your script:
-- In the redeem.MouseButton1Click function, change this part:

-- FROM:
task.delay(
    0.7,
    function()
        screen:Destroy()
    end
)

-- TO:
task.delay(
    0.7,
    function()
        screen:Destroy()
        -- Load your main script after successful validation
        loadstring(game:HttpGet("https://raw.githubusercontent.com/LunarisXOffical/Game/refs/heads/main/ithinkyes.lua"))()
    end
)

-- Also modify the saved key check at the end of your UI code:
-- Change this section (around line 500):

-- FROM:
local savedKey = loadVerifiedKey()
local keyToCheck = savedKey
if not keyToCheck then
    keyToCheck = getgenv().SCRIPT_KEY
end

local result = Junkie.check_key(keyToCheck)
if result and result.valid then
    if result.message == "KEYLESS" then
        getgenv().SCRIPT_KEY = "KEYLESS"
    elseif result.message == "KEY_VALID" then
        if not savedKey and keyToCheck then
            saveVerifiedKey(keyToCheck)
        end
        getgenv().SCRIPT_KEY = keyToCheck
    else
        Build()
    end
else
    Build()
end

while not getgenv().SCRIPT_KEY do
    task.wait(0.1)
end

-- TO:
local savedKey = loadVerifiedKey()
local keyToCheck = savedKey

-- First check saved file
if keyToCheck then
    local isValid, message = validateKey(keyToCheck)
    if isValid then
        getgenv().SCRIPT_KEY = keyToCheck
        print("✅ Using saved key from file")
        -- Load your main script
        loadstring(game:HttpGet("https://raw.githubusercontent.com/LunarisXOffical/Game/refs/heads/main/ithinkyes.lua"))()
        return
    else
        -- Clear invalid saved key
        clearSavedKey()
    end
end

-- If no valid saved key, build the UI
Build()

-- Remove the while loop at the end since it's not needed
