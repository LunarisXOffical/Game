-- This loads the Junkie-Library
local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
Junkie.service = "test"
Junkie.identifier = "20"
Junkie.provider = "WorkInk"

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
        return false, "API Error: " .. tostring(result)
    end
    
    if result and result.valid then
        return true, result.message or "Valid key"
    else
        return false, result and result.message or "Invalid key"
    end
end

-- Check for existing key in getgenv().SCRIPT_KEY FIRST
if getgenv().SCRIPT_KEY and type(getgenv().SCRIPT_KEY) == "string" then
    print("🔍 Checking existing getgenv().SCRIPT_KEY...")
    local isValid, message = validateKey(getgenv().SCRIPT_KEY)
    
    if isValid then
        print("✅ Existing getgenv().SCRIPT_KEY is VALID!")
        -- Load your main script immediately
        loadstring(game:HttpGet("https://raw.githubusercontent.com/LunarisXOffical/Game/refs/heads/main/ithinkyes.lua"))()
        return  -- Stop execution here
    else
        print("❌ Existing getgenv().SCRIPT_KEY is invalid:", message)
        getgenv().SCRIPT_KEY = nil  -- Clear invalid key
    end
end

-- If we get here, either no key exists or it's invalid
-- So we continue with your Junkie UI code...

-- [YOUR ENTIRE JUNKIE UI CODE GOES HERE - I'll show the important modifications needed]

-- Modify the part where you check saved keys (around line 500 in your code)
local savedKey = loadVerifiedKey()
local keyToCheck = savedKey

-- MODIFIED: Only check getgenv().SCRIPT_KEY if we haven't already checked it above
if not keyToCheck then
    keyToCheck = getgenv().SCRIPT_KEY
end

-- Check if we have a key to validate
if keyToCheck then
    print("🔑 Checking key...")
    local result = Junkie.check_key(keyToCheck)
    
    if result and result.valid then
        if result.message == "KEYLESS" then
            getgenv().SCRIPT_KEY = "KEYLESS"
            -- Load your main script
            loadstring(game:HttpGet("https://raw.githubusercontent.com/LunarisXOffical/Game/refs/heads/main/ithinkyes.lua"))()
            return
        elseif result.message == "KEY_VALID" then
            if not savedKey and keyToCheck then
                saveVerifiedKey(keyToCheck)
            end
            getgenv().SCRIPT_KEY = keyToCheck
            -- Load your main script
            loadstring(game:HttpGet("https://raw.githubusercontent.com/LunarisXOffical/Game/refs/heads/main/ithinkyes.lua"))()
            return
        else
            Build()
        end
    else
        Build()
    end
else
    Build()
end

-- Also modify the redeem button in the Build() function to set getgenv().SCRIPT_KEY
-- Find this section in your redeem.MouseButton1Click function:
redeem.MouseButton1Click:Connect(
    function()
        local key = box.Text:upper()
        SetStatus("verifying")
        redeem.Text = "..."
        redeem.Active = false
        
        local result = Junkie.check_key(key)
        
        redeem.Active = true
        redeem.Text = "Redeem"
        
        if not result then
            SetStatus("error")
            ToastSystem.Create(screen, "API request failed: " .. tostring(result), "error")
            return
        end
        
        if result.valid then
            saveVerifiedKey(key)
            getgenv().SCRIPT_KEY = key  -- This is already there, good!
            SetStatus("success")
            ToastSystem.Create(screen, "Access granted!", "success", nil, status)
            task.wait(0.8)
            SetBlur(false)
            Utils.Tween(
                main,
                {
                    Position = UDim2.new(0.5, 0, 0.5, 100),
                    BackgroundTransparency = 1
                },
                0.7,
                Enum.EasingStyle.Exponential,
                Enum.EasingDirection.In
            )
            task.delay(
                0.7,
                function()
                    screen:Destroy()
                    -- ADD THIS LINE to load your main script after validation
                    loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/15f465ee60342132491cef9599ab1d1d0708c408a60699a8fecda99e5b36f25d/download"))()
                end
            )
        else
            SetStatus("error")
            ToastSystem.Create(screen, result.message or "Invalid key", "error", nil, status)
        end
    end
)

-- Wait for key if needed
while not getgenv().SCRIPT_KEY do
    task.wait(0.1)
end
