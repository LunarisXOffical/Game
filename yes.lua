-- External Loader for Junkie Development
-- Service Configuration
local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
Junkie.service = "test"  -- Change this to your service name
Junkie.identifier = "546"  -- Change this to your script ID
Junkie.provider = "WorkInk"  -- Change this to your provider name

-- Configuration
local maxAttempts = 5
local attempts = 0
local validated = false
local keyLink = Junkie.get_key_link()

-- Save/Load Key Functions
local function hasFileSupport()
    local success = pcall(function()
        return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
    end)
    return success
end

local function saveKey(key)
    if hasFileSupport() then
        pcall(function()
            writefile("junkie_key.txt", key)
        end)
    end
end

local function loadKey()
    if hasFileSupport() then
        local success, content = pcall(function()
            if isfile("junkie_key.txt") then
                return readfile("junkie_key.txt")
            end
        end)
        if success then
            return content
        end
    end
    return nil
end

-- Clear old key if exists (optional)
pcall(function()
    if isfile then
        delfile("junkie_key.txt")
    end
end)

-- Try saved key first
local savedKey = loadKey()
if savedKey then
    local validation = Junkie.check_key(savedKey)
    if validation and validation.valid then
        getgenv().SCRIPT_KEY = savedKey
        validated = true
        print("✓ Using saved key")
    else
        -- Clear invalid saved key
        if hasFileSupport() then
            pcall(function()
                delfile("junkie_key.txt")
            end)
        end
    end
end

-- Create Custom UI for Key Input
if not validated then
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    
    -- Create GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "JunkieLoaderUI"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999
    screenGui.Parent = game.CoreGui or game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(59, 130, 246)
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    stroke.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 50)
    title.Position = UDim2.new(0, 20, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = "JUNKIE LOADER"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -40, 0, 20)
    subtitle.Position = UDim2.new(0, 20, 0, 60)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Enter your license key to continue"
    subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    subtitle.TextSize = 14
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = mainFrame
    
    -- Status Label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -40, 0, 30)
    statusLabel.Position = UDim2.new(0, 20, 0, 90)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Attempts: 0/" .. maxAttempts
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.GothamMedium
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = mainFrame
    
    -- Input Field
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, -40, 0, 50)
    inputFrame.Position = UDim2.new(0, 20, 0, 130)
    inputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    inputFrame.Parent = mainFrame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = inputFrame
    
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -20, 1, -10)
    inputBox.Position = UDim2.new(0, 10, 0, 5)
    inputBox.BackgroundTransparency = 1
    inputBox.Text = ""
    inputBox.PlaceholderText = "Paste your key here..."
    inputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.TextSize = 16
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.Parent = inputFrame
    
    -- Buttons
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, -40, 0, 50)
    buttonFrame.Position = UDim2.new(0, 20, 1, -80)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = mainFrame
    
    -- Copy Link Button
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0.4, -5, 1, 0)
    copyBtn.Position = UDim2.new(0, 0, 0, 0)
    copyBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
    copyBtn.Text = "COPY KEY LINK"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.TextSize = 14
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.Parent = buttonFrame
    
    local copyCorner = Instance.new("UICorner")
    copyCorner.CornerRadius = UDim.new(0, 8)
    copyCorner.Parent = copyBtn
    
    -- Submit Button
    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(0.4, -5, 1, 0)
    submitBtn.Position = UDim2.new(0.6, 5, 0, 0)
    submitBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
    submitBtn.Text = "VALIDATE KEY"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.TextSize = 14
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.Parent = buttonFrame
    
    local submitCorner = Instance.new("UICorner")
    submitCorner.CornerRadius = UDim.new(0, 8)
    submitCorner.Parent = submitBtn
    
    -- Error Message
    local errorLabel = Instance.new("TextLabel")
    errorLabel.Size = UDim2.new(1, -40, 0, 20)
    errorLabel.Position = UDim2.new(0, 20, 0, 190)
    errorLabel.BackgroundTransparency = 1
    errorLabel.Text = ""
    errorLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    errorLabel.TextSize = 13
    errorLabel.Font = Enum.Font.Gotham
    errorLabel.TextXAlignment = Enum.TextXAlignment.Left
    errorLabel.Visible = false
    errorLabel.Parent = mainFrame
    
    -- Loading Animation
    local loadingFrame = Instance.new("Frame")
    loadingFrame.Size = UDim2.new(1, 0, 1, 0)
    loadingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    loadingFrame.BackgroundTransparency = 0.5
    loadingFrame.Visible = false
    loadingFrame.Parent = mainFrame
    
    local loadingText = Instance.new("TextLabel")
    loadingText.Size = UDim2.new(1, 0, 0, 30)
    loadingText.Position = UDim2.new(0, 0, 0.5, -15)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = "Validating..."
    loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadingText.TextSize = 16
    loadingText.Font = Enum.Font.GothamBold
    loadingText.Parent = loadingFrame
    
    -- Button Hover Effects
    local function setupButtonHover(button, defaultColor)
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
        end)
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        end)
    end
    
    setupButtonHover(copyBtn, Color3.fromRGB(59, 130, 246))
    setupButtonHover(submitBtn, Color3.fromRGB(40, 200, 80))
    
    -- Copy Link Function
    copyBtn.MouseButton1Click:Connect(function()
        if keyLink and setclipboard then
            setclipboard(keyLink)
            
            -- Show success message
            local originalText = copyBtn.Text
            copyBtn.Text = "COPIED!"
            copyBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
            
            task.wait(1)
            
            copyBtn.Text = originalText
            copyBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
        else
            errorLabel.Text = "Clipboard not available"
            errorLabel.Visible = true
            task.wait(2)
            errorLabel.Visible = false
        end
    end)
    
    -- Validation Function
    local function validateKey(key)
        attempts = attempts + 1
        statusLabel.Text = "Attempts: " .. attempts .. "/" .. maxAttempts
        
        if #key < 10 then
            return false, "Key too short"
        end
        
        loadingFrame.Visible = true
        submitBtn.Active = false
        copyBtn.Active = false
        
        local success, result = pcall(function()
            return Junkie.check_key(key)
        end)
        
        loadingFrame.Visible = false
        submitBtn.Active = true
        copyBtn.Active = true
        
        if not success then
            return false, "API Error"
        end
        
        if result and result.valid then
            return true, result.message or "Valid key"
        else
            return false, result and result.message or "Invalid key"
        end
    end
    
    -- Submit Button Handler
    submitBtn.MouseButton1Click:Connect(function()
        local key = inputBox.Text:gsub("%s+", ""):upper()
        
        if #key == 0 then
            errorLabel.Text = "Please enter a key"
            errorLabel.Visible = true
            task.wait(2)
            errorLabel.Visible = false
            return
        end
        
        local isValid, message = validateKey(key)
        
        if isValid then
            -- Success
            validated = true
            getgenv().SCRIPT_KEY = key
            saveKey(key)
            
            -- Show success
            errorLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            errorLabel.Text = "✓ " .. message
            errorLabel.Visible = true
            
            submitBtn.Text = "SUCCESS!"
            submitBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
            
            -- Fade out and load script
            task.wait(1)
            
            local tween = TweenService:Create(mainFrame, TweenInfo.new(0.5), {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 0, 0)
            })
            tween:Play()
            
            tween.Completed:Wait()
            screenGui:Destroy()
            
            -- Load main script
            loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/15f465ee60342132491cef9599ab1d1d0708c408a60699a8fecda99e5b36f25d/download"))()
        else
            -- Error
            errorLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            errorLabel.Text = "✗ " .. message
            errorLabel.Visible = true
            
            -- Shake animation for error
            local shake = 5
            for i = 1, 3 do
                mainFrame.Position = UDim2.new(0.5, -200 + shake, 0.5, -150)
                task.wait(0.05)
                mainFrame.Position = UDim2.new(0.5, -200 - shake, 0.5, -150)
                task.wait(0.05)
                mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
            end
            
            inputBox.Text = ""
            
            if attempts >= maxAttempts then
                errorLabel.Text = "Too many attempts! Please restart."
                submitBtn.Active = false
                copyBtn.Active = false
                task.wait(3)
                game:Shutdown()
            end
        end
    end)
    
    -- Make window draggable
    local dragging = false
    local dragInput, dragStart, startPos
    
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Focus input box
    inputBox:CaptureFocus()
    
    -- Wait for validation
    while not validated and attempts < maxAttempts do
        RunService.Heartbeat:Wait()
    end
    
    if not validated then
        screenGui:Destroy()
        warn("Key validation failed")
        return
    end
end

-- If already validated (from saved key)
if validated and getgenv().SCRIPT_KEY then
    print("Loading script with saved key...")
    loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/15f465ee60342132491cef9599ab1d1d0708c408a60699a8fecda99e5b36f25d/download"))()
end
