-- External Loader for Junkie Development
-- This loads and validates keys, then loads your main script

local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
Junkie.service = "test"
Junkie.identifier = "20"
Junkie.provider = "WorkInk"

-- Configuration
local maxAttempts = 5
local attempts = 0
local validated = false
local mainScriptUrl = "https://api.jnkie.com/api/v1/luascripts/public/15f465ee60342132491cef9599ab1d1d0708c408a60699a8fecda99e5b36f25d/download"

-- Debug info
print("🎮 Junkie External Loader")
print("Service: " .. Junkie.service)
print("Identifier: " .. Junkie.identifier)

-- Function to validate a key with Junkie
local function validateKeyWithJunkie(key)
    if not key or type(key) ~= "string" or #key < 5 then
        return false, "Invalid key format"
    end
    
    local cleanKey = key:gsub("%s+", ""):upper()
    
    -- Call Junkie API
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

-- Check if we already have a valid key in getgenv()
if getgenv().SCRIPT_KEY and type(getgenv().SCRIPT_KEY) == "string" then
    print("🔍 Checking existing SCRIPT_KEY...")
    local isValid, message = validateKeyWithJunkie(getgenv().SCRIPT_KEY)
    
    if isValid then
        print("✅ Using existing SCRIPT_KEY from getgenv()")
        validated = true
        -- Load the main script immediately
        loadstring(game:HttpGet(mainScriptUrl))()
        return
    else
        print("❌ Existing key invalid:", message)
        getgenv().SCRIPT_KEY = nil
    end
end

-- Create UI for key input
local function createUI()
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local Lighting = game:GetService("Lighting")
    local HttpService = game:GetService("HttpService")

    -- UI Configuration
    local Configuration = {
        ScreenGuiName = "JunkieExternalLoader",
        Colors = {
            Bg = Color3.fromRGB(12, 12, 12),
            Primary = Color3.fromRGB(59, 130, 246),
            PrimaryDark = Color3.fromRGB(37, 99, 235),
            StatusSuccess = Color3.fromRGB(16, 185, 129),
            StatusError = Color3.fromRGB(239, 68, 68),
            StatusVerifying = Color3.fromRGB(59, 130, 246),
            TextMain = Color3.fromRGB(255, 255, 255),
            TextSec = Color3.fromRGB(161, 161, 170),
            TextMuted = Color3.fromRGB(113, 113, 122),
            TrafficRed = Color3.fromRGB(255, 95, 87),
            TrafficYellow = Color3.fromRGB(254, 188, 46),
            TrafficGreen = Color3.fromRGB(40, 200, 64),
            Success = Color3.fromRGB(50, 205, 110),
            Error = Color3.fromRGB(245, 70, 90),
            Warning = Color3.fromRGB(255, 200, 50)
        }
    }

    local Utils = {}
    Utils.Tween = function(obj, props, time, style, dir)
        local t = TweenService:Create(obj, TweenInfo.new(time or 0.3, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
        t:Play()
        return t
    end

    Utils.Round = function(obj, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 12)
        c.Parent = obj
        return c
    end

    local function SetBlur(enabled)
        local blur = Lighting:FindFirstChild("JunkieBlur")
        if enabled then
            if not blur then
                blur = Instance.new("BlurEffect")
                blur.Name = "JunkieBlur"
                blur.Size = 0
                blur.Parent = Lighting
            end
            Utils.Tween(blur, {Size = 24}, 0.6)
        elseif blur then
            Utils.Tween(blur, {Size = 0}, 0.4)
            task.delay(0.4, function() blur:Destroy() end)
        end
    end

    -- Create the UI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = Configuration.ScreenGuiName
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui") or Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Overlay
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.Parent = screenGui

    -- Main Window
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 400, 0, 350)
    main.Position = UDim2.new(0.5, -200, 0.5, -175)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Configuration.Colors.Bg
    main.BackgroundTransparency = 0.1
    main.BorderSizePixel = 0
    main.Parent = screenGui
    Utils.Round(main, 16)

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "JUNKIE EXTERNAL LOADER"
    title.TextColor3 = Configuration.Colors.Primary
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    -- Status Indicator
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -40, 0, 30)
    statusLabel.Position = UDim2.new(0, 20, 0, 60)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: Ready"
    statusLabel.TextColor3 = Configuration.Colors.TextMain
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = main

    local attemptsLabel = Instance.new("TextLabel")
    attemptsLabel.Size = UDim2.new(1, -40, 0, 20)
    attemptsLabel.Position = UDim2.new(0, 20, 0, 90)
    attemptsLabel.BackgroundTransparency = 1
    attemptsLabel.Text = "Attempts: 0/" .. maxAttempts
    attemptsLabel.TextColor3 = Configuration.Colors.TextSec
    attemptsLabel.TextSize = 12
    attemptsLabel.Font = Enum.Font.Gotham
    attemptsLabel.TextXAlignment = Enum.TextXAlignment.Left
    attemptsLabel.Parent = main

    -- Input Field
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, -40, 0, 50)
    inputFrame.Position = UDim2.new(0, 20, 0, 120)
    inputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = main
    Utils.Round(inputFrame, 8)

    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -20, 1, -10)
    inputBox.Position = UDim2.new(0, 10, 0, 5)
    inputBox.BackgroundTransparency = 1
    inputBox.Text = ""
    inputBox.PlaceholderText = "Enter your license key here..."
    inputBox.PlaceholderColor3 = Configuration.Colors.TextMuted
    inputBox.TextColor3 = Configuration.Colors.TextMain
    inputBox.TextSize = 16
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.Parent = inputFrame

    -- Buttons
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, -40, 0, 40)
    buttonFrame.Position = UDim2.new(0, 20, 1, -120)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = main

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0.48, 0, 1, 0)
    copyBtn.Position = UDim2.new(0, 0, 0, 0)
    copyBtn.BackgroundColor3 = Configuration.Colors.Primary
    copyBtn.Text = "COPY KEY LINK"
    copyBtn.TextColor3 = Color3.new(1, 1, 1)
    copyBtn.TextSize = 14
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.AutoButtonColor = false
    copyBtn.Parent = buttonFrame
    Utils.Round(copyBtn, 8)

    local validateBtn = Instance.new("TextButton")
    validateBtn.Size = UDim2.new(0.48, 0, 1, 0)
    validateBtn.Position = UDim2.new(0.52, 0, 0, 0)
    validateBtn.BackgroundColor3 = Configuration.Colors.StatusSuccess
    validateBtn.Text = "VALIDATE KEY"
    validateBtn.TextColor3 = Color3.new(1, 1, 1)
    validateBtn.TextSize = 14
    validateBtn.Font = Enum.Font.GothamBold
    validateBtn.AutoButtonColor = false
    validateBtn.Parent = buttonFrame
    Utils.Round(validateBtn, 8)

    -- Error Message
    local errorLabel = Instance.new("TextLabel")
    errorLabel.Size = UDim2.new(1, -40, 0, 30)
    errorLabel.Position = UDim2.new(0, 20, 1, -70)
    errorLabel.BackgroundTransparency = 1
    errorLabel.Text = ""
    errorLabel.TextColor3 = Configuration.Colors.Error
    errorLabel.TextSize = 13
    errorLabel.Font = Enum.Font.Gotham
    errorLabel.TextXAlignment = Enum.TextXAlignment.Left
    errorLabel.Visible = false
    errorLabel.Parent = main

    -- Loading Animation
    local loadingFrame = Instance.new("Frame")
    loadingFrame.Size = UDim2.new(1, 0, 1, 0)
    loadingFrame.BackgroundColor3 = Configuration.Colors.Bg
    loadingFrame.BackgroundTransparency = 0.7
    loadingFrame.Visible = false
    loadingFrame.Parent = main

    local loadingText = Instance.new("TextLabel")
    loadingText.Size = UDim2.new(1, 0, 0, 30)
    loadingText.Position = UDim2.new(0, 0, 0.5, -15)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = "Validating..."
    loadingText.TextColor3 = Configuration.Colors.TextMain
    loadingText.TextSize = 16
    loadingText.Font = Enum.Font.GothamBold
    loadingText.Parent = loadingFrame

    -- Button hover effects
    local function setupButton(button)
        button.MouseEnter:Connect(function()
            Utils.Tween(button, {BackgroundTransparency = 0.2}, 0.2)
        end)
        button.MouseLeave:Connect(function()
            Utils.Tween(button, {BackgroundTransparency = 0}, 0.2)
        end)
    end
    
    setupButton(copyBtn)
    setupButton(validateBtn)

    -- Copy Key Link
    copyBtn.MouseButton1Click:Connect(function()
        local link = Junkie.get_key_link()
        if link and setclipboard then
            setclipboard(link)
            errorLabel.TextColor3 = Configuration.Colors.Success
            errorLabel.Text = "✓ Key link copied to clipboard!"
            errorLabel.Visible = true
            
            -- Reset after 3 seconds
            task.delay(3, function()
                if errorLabel then
                    errorLabel.Visible = false
                end
            end)
        else
            errorLabel.TextColor3 = Configuration.Colors.Error
            errorLabel.Text = "✗ Failed to get key link"
            errorLabel.Visible = true
        end
    end)

    -- Validate Key
    validateBtn.MouseButton1Click:Connect(function()
        local key = inputBox.Text:gsub("%s+", ""):upper()
        
        if #key < 5 then
            errorLabel.TextColor3 = Configuration.Colors.Warning
            errorLabel.Text = "Please enter a valid key"
            errorLabel.Visible = true
            return
        end
        
        attempts = attempts + 1
        attemptsLabel.Text = "Attempts: " .. attempts .. "/" .. maxAttempts
        
        -- Show loading
        loadingFrame.Visible = true
        validateBtn.Active = false
        copyBtn.Active = false
        statusLabel.Text = "Status: Validating..."
        
        -- Validate with Junkie
        local isValid, message = validateKeyWithJunkie(key)
        
        -- Hide loading
        loadingFrame.Visible = false
        validateBtn.Active = true
        copyBtn.Active = true
        
        if isValid then
            -- Success!
            validated = true
            getgenv().SCRIPT_KEY = key
            statusLabel.Text = "Status: ✓ Valid Key"
            
            -- Show success
            errorLabel.TextColor3 = Configuration.Colors.Success
            errorLabel.Text = "✓ " .. message
            errorLabel.Visible = true
            
            -- Close UI and load main script
            task.wait(1)
            SetBlur(false)
            Utils.Tween(main, {
                Position = UDim2.new(0.5, -200, 0.5, -250),
                BackgroundTransparency = 1
            }, 0.5)
            
            task.delay(0.5, function()
                screenGui:Destroy()
                -- Load the main Junkie script
                print("✅ Key validated! Loading main script...")
                loadstring(game:HttpGet(mainScriptUrl))()
            end)
        else
            -- Error
            statusLabel.Text = "Status: Invalid Key"
            errorLabel.TextColor3 = Configuration.Colors.Error
            errorLabel.Text = "✗ " .. message
            errorLabel.Visible = true
            
            -- Clear input
            inputBox.Text = ""
            
            -- Check max attempts
            if attempts >= maxAttempts then
                errorLabel.Text = "✗ Too many attempts! Please restart."
                validateBtn.Active = false
                copyBtn.Active = false
                
                task.wait(3)
                game:Shutdown()
            end
        end
    end)

    -- Make draggable
    local dragging = false
    local dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Focus input
    inputBox:CaptureFocus()
    
    -- Add blur
    SetBlur(true)
    
    -- Animate in
    main.Position = UDim2.new(0.5, -200, 0.5, -250)
    main.BackgroundTransparency = 1
    Utils.Tween(main, {
        Position = UDim2.new(0.5, -200, 0.5, -175),
        BackgroundTransparency = 0.1
    }, 0.5)
    
    return screenGui
end

-- If no valid key was found, show the UI
if not validated then
    print("📝 No valid key found. Showing UI...")
    createUI()
    
    -- Wait for validation
    while not validated do
        RunService.Heartbeat:Wait()
    end
end
