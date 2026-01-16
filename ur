-- External Loader for Junkie Development
-- Using the structure you provided with YOUR key system UI

-- Load Junkie SDK
local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
Junkie.service = "test"  -- Change to your service
Junkie.identifier = "546"  -- Change to your identifier
Junkie.provider = "WorkInk"  -- Change to your provider

local result = (function()
    -- Clear old globals
    getgenv().SCRIPT_KEY = nil
    getgenv().UI_CLOSED = false
    
    local maxAttempts = 5
    local attempts = 0
    
    -- Your UI functions (using YOUR key system UI)
    local screenGui = nil
    
    local function yourUIGetInput()
        -- Return user input from YOUR UI
        -- This function will be called when user submits a key
        if getgenv().USER_KEY_INPUT then
            local key = getgenv().USER_KEY_INPUT
            getgenv().USER_KEY_INPUT = nil
            return key
        end
        return nil
    end
    
    local function yourUIShowLink(link)
        -- Show link in YOUR UI
        if screenGui and setclipboard then
            setclipboard(link)
            -- Show toast notification
            getgenv().SHOW_TOAST = {message = "Key link copied to clipboard", type = "success"}
        end
    end
    
    local function yourUIShowError(message)
        -- Show error in YOUR UI
        if screenGui then
            getgenv().SHOW_TOAST = {message = message, type = "error"}
        end
    end
    
    local function yourUIShowSuccess(message)
        -- Show success in YOUR UI
        if screenGui then
            getgenv().SHOW_TOAST = {message = message, type = "success"}
        end
    end
    
    local function yourUIShowInfo(message)
        -- Show info in YOUR UI
        if screenGui then
            getgenv().SHOW_TOAST = {message = message, type = "info"}
        end
    end
    
    -- Now load YOUR key system UI code
    -- This is YOUR exact UI code with modifications to work with the structure above
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local Lighting = game:GetService("Lighting")
    local HttpService = game:GetService("HttpService")

    local Icons = {
        Shield = "rbxassetid://105619007041452",
        Loading = "rbxassetid://116535712789945",
        Lock = "rbxassetid://114355063515473",
        Key = "rbxassetid://93569468678423",
        Check = "rbxassetid://119783053916823",
        CheckCircle = "rbxassetid://10709790644",
        XCircle = "rbxassetid://10747384394",
        Warning = "rbxassetid://130226573962640",
        Globe = "rbxassetid://10734950309",
        Info = "rbxassetid://94529541997278",
        ExternalLink = "rbxassetid://71038734318580",
        Copy = "rbxassetid://107485544510830",
        Spinner = "rbxassetid://10709767827",
        Database = "rbxassetid://114209748010261",
        Sparkles = "rbxassetid://10709767827",
        ErrorFolder = "rbxassetid://113312905787220",
        Candy = "rbxassetid://10709767827",
        JunkieNewIcon = "rbxassetid://75038032192167"
    }

    local Configuration = {
        ScreenGuiName = "JunkieKeySystem",
        Window = {Size = UDim2.new(0, 333, 0, 500)},
        Colors = {
            Bg = Color3.fromRGB(12, 12, 12),
            Primary = Color3.fromRGB(59, 130, 246),
            PrimaryDark = Color3.fromRGB(37, 99, 235),
            StatusIdle = Color3.fromRGB(249, 115, 22),
            StatusSuccess = Color3.fromRGB(16, 185, 129),
            StatusError = Color3.fromRGB(239, 68, 68),
            StatusVerifying = Color3.fromRGB(59, 130, 246),
            StatusWarning = Color3.fromRGB(254, 188, 46),
            TextMain = Color3.fromRGB(255, 255, 255),
            TextSec = Color3.fromRGB(161, 161, 170),
            TextMuted = Color3.fromRGB(113, 113, 122),
            Border = Color3.fromRGB(255, 255, 255),
            TrafficRed = Color3.fromRGB(255, 95, 87),
            TrafficYellow = Color3.fromRGB(254, 188, 46),
            TrafficGreen = Color3.fromRGB(40, 200, 64),
            Success = Color3.fromRGB(50, 205, 110),
            Error = Color3.fromRGB(245, 70, 90),
            Warning = Color3.fromRGB(255, 200, 50)
        },
        BorderTransparency = 0.15,
        Animations = {
            VeryFast = 0.1,
            Fast = 0.2,
            Medium = 0.4,
            Slow = 0.5,
            VerySlow = 0.6,
            Bounce = 0.6
        },
        Fonts = {
            Title = 24,
            Subtitle = 12,
            Button = 14,
            Input = 16,
            Body = 13,
            Small = 11,
            Tiny = 12
        }
    }

    local Utils = {}

    Utils.Tween = function(obj, props, time, style, dir)
        local t =
            TweenService:Create(
            obj,
            TweenInfo.new(time or 0.3, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
            props
        )
        t:Play()
        return t
    end

    Utils.Round = function(obj, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 12)
        c.Parent = obj
        return c
    end

    Utils.Stroke = function(obj, color, thick, trans)
        local s = Instance.new("UIStroke")
        s.Color = color or Color3.new(1, 1, 1)
        s.Thickness = thick or 1
        s.Transparency = trans or 0.9
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = obj
        return s
    end

    local ToastSystem = {ActiveToasts = {}, MaxToasts = 3, ToastSpacing = 10}

    ToastSystem.Create = function(parent, message, toastType, duration, statusCode)
        local colors = {
            success = Configuration.Colors.Success,
            error = Configuration.Colors.Error,
            warning = Configuration.Colors.Warning,
            info = Configuration.Colors.Primary
        }
        local icons = {
            success = Icons.CheckCircle,
            error = Icons.ErrorFolder,
            warning = Icons.Warning,
            info = Icons.Info
        }
        local toastColor = colors[toastType] or colors.Bg
        local toastIcon = icons[toastType] or nil
        if #ToastSystem.ActiveToasts >= ToastSystem.MaxToasts then
            local oldest = table.remove(ToastSystem.ActiveToasts, 1)
            if oldest and oldest.Parent then
                oldest:Destroy()
            end
        end
        local toastHeight = 56
        local toast = Instance.new("Frame")
        toast.Name = tick()
        toast.Size = UDim2.new(0, 0, 0, toastHeight)
        toast.Position = UDim2.new(0.5, 0, 0, 20)
        toast.AnchorPoint = Vector2.new(0.5, 0)
        toast.BackgroundColor3 = Configuration.Colors.Bg
        toast.BackgroundTransparency = 0.5
        toast.BorderSizePixel = 0
        toast.ZIndex = 300
        toast.ClipsDescendants = true
        toast.Parent = parent
        Utils.Round(toast, 14)
        local iconBg = Instance.new("Frame")
        iconBg.Name = "IconBg"
        iconBg.Size = UDim2.new(0, 36, 0, 36)
        iconBg.Position = UDim2.new(0, 12, 0.5, 0)
        iconBg.AnchorPoint = Vector2.new(0, 0.5)
        iconBg.BackgroundColor3 = toastColor
        iconBg.BackgroundTransparency = 0.85
        iconBg.BorderSizePixel = 0
        iconBg.ZIndex = 301
        iconBg.Parent = toast
        Utils.Round(iconBg, 18)
        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(0, 20, 0, 20)
        icon.Position = UDim2.new(0.5, 0, 0.5, 0)
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.BackgroundTransparency = 1
        icon.Image = toastIcon
        icon.ImageColor3 = toastColor
        icon.ZIndex = 302
        icon.Parent = iconBg
        local textContainer = Instance.new("Frame")
        textContainer.Name = "TextContainer"
        textContainer.Size = UDim2.new(1, statusCode and -110 or -60, 1, 0)
        textContainer.Position = UDim2.new(0, 56, 0, 0)
        textContainer.BackgroundTransparency = 1
        textContainer.ZIndex = 301
        textContainer.Parent = toast
        local text = Instance.new("TextLabel")
        text.Name = "Message"
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = message or ""
        text.TextColor3 = Configuration.Colors.TextMain
        text.TextSize = Configuration.Fonts.Body
        text.Font = Enum.Font.GothamMedium
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.TextYAlignment = Enum.TextYAlignment.Center
        text.TextWrapped = true
        text.ZIndex = 301
        text.Parent = textContainer
        
        table.insert(ToastSystem.ActiveToasts, toast)
        local targetWidth = 320
        Utils.Tween(toast, {Size = UDim2.new(0, targetWidth, 0, toastHeight)}, 0.4)
        task.delay(
            duration or 3.5,
            function()
                if toast.Parent then
                    Utils.Tween(
                        toast,
                        {
                            Position = UDim2.new(0.5, 0, 0, -80),
                            BackgroundTransparency = 1
                        },
                        0.4
                    )
                    for i, t in ipairs(ToastSystem.ActiveToasts) do
                        if t == toast then
                            table.remove(ToastSystem.ActiveToasts, i)
                            break
                        end
                    end
                    task.wait(0.4)
                    toast:Destroy()
                end
            end
        )
        return toast
    end

    -- MODIFIED Build function to work with the structure
    local function Build()
        local parent = game:GetService("CoreGui")
        local old = parent:FindFirstChild(Configuration.ScreenGuiName)
        if old then
            old:Destroy()
        end
        screen = Instance.new("ScreenGui")
        screen.Name = Configuration.ScreenGuiName
        screen.ResetOnSpawn = false
        screen.Parent = parent
        screenGui = screen  -- Store reference
        
        local main = Instance.new("Frame")
        main.Size = Configuration.Window.Size
        main.Position = UDim2.new(0.5, 0, 0.5, 60)
        main.AnchorPoint = Vector2.new(0.5, 0.5)
        main.BackgroundColor3 = Configuration.Colors.Bg
        main.BackgroundTransparency = 0.2
        main.ClipsDescendants = true
        main.Parent = screen
        Utils.Round(main, 24)
        Utils.Stroke(main, Color3.new(1, 1, 1), 1, 0.92)
        
        local glass = Instance.new("Frame")
        glass.Size = UDim2.fromScale(1, 1)
        glass.BackgroundColor3 = Color3.new(1, 1, 1)
        glass.BackgroundTransparency = 0.985
        glass.ZIndex = 0
        glass.Parent = main
        Utils.Round(glass, 24)
        
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, 0, 0, 54)
        bar.BackgroundTransparency = 1
        bar.Parent = main
        
        local dots = Instance.new("Frame")
        dots.Size = UDim2.new(0, 54, 0, 12)
        dots.Position = UDim2.new(0, 20, 0.5, 0)
        dots.AnchorPoint = Vector2.new(0, 0.5)
        dots.BackgroundTransparency = 1
        dots.Parent = bar
        
        local dColors = {
            Configuration.Colors.TrafficRed,
            Configuration.Colors.TrafficYellow,
            Configuration.Colors.TrafficGreen
        }
        for i, c in ipairs(dColors) do
            local d = Instance.new("Frame")
            d.Size = UDim2.fromOffset(12, 12)
            d.Position = UDim2.fromOffset((i - 1) * 18, 0)
            d.BackgroundColor3 = c
            d.BorderSizePixel = 0
            d.Parent = dots
            Utils.Round(d, 6)
        end
        
        local content = Instance.new("ScrollingFrame")
        content.Size = UDim2.new(1, 0, 1, -54)
        content.Position = UDim2.new(0, 0, 0, 54)
        content.BackgroundTransparency = 1
        content.ScrollBarThickness = 0
        content.CanvasSize = UDim2.new(0, 0, 0, 440)
        content.Parent = main
        
        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 24)
        list.HorizontalAlignment = Enum.HorizontalAlignment.Center
        list.Parent = content
        
        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 5)
        pad.Parent = content
        
        local logoContainer = Instance.new("Frame")
        logoContainer.Size = UDim2.fromOffset(80, 80)
        logoContainer.BackgroundColor3 = Configuration.Colors.Primary
        logoContainer.Parent = content
        Utils.Round(logoContainer, 20)
        
        local sIcon = Instance.new("ImageLabel")
        sIcon.Size = UDim2.fromScale(1, 1)
        sIcon.Position = UDim2.fromScale(0.5, 0.5)
        sIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        sIcon.Image = Icons.JunkieNewIcon
        sIcon.ScaleType = Enum.ScaleType.Fit
        sIcon.BackgroundTransparency = 1
        sIcon.Parent = logoContainer
        
        local titleArea = Instance.new("Frame")
        titleArea.Size = UDim2.new(1, 0, 0, 44)
        titleArea.BackgroundTransparency = 1
        titleArea.Parent = content
        
        local mainTitle = Instance.new("TextLabel")
        mainTitle.Size = UDim2.new(1, 0, 0, 26)
        mainTitle.Text = "Junkie"
        mainTitle.TextColor3 = Color3.new(1, 1, 1)
        mainTitle.TextSize = 26
        mainTitle.Font = Enum.Font.GothamBold
        mainTitle.BackgroundTransparency = 1
        mainTitle.Parent = titleArea
        
        local subTitle = Instance.new("TextLabel")
        subTitle.Size = UDim2.new(1, 0, 0, 16)
        subTitle.Position = UDim2.fromOffset(0, 28)
        subTitle.Text = "junkie-development.de"
        subTitle.TextColor3 = Configuration.Colors.TextSec
        subTitle.TextSize = 13
        subTitle.Font = Enum.Font.Gotham
        subTitle.BackgroundTransparency = 1
        subTitle.Parent = titleArea
        
        local inputFrame = Instance.new("Frame")
        inputFrame.Size = UDim2.new(0, 280, 0, 52)
        inputFrame.BackgroundColor3 = Color3.new(1, 1, 1)
        inputFrame.BackgroundTransparency = 0.975
        inputFrame.Parent = content
        Utils.Round(inputFrame, 14)
        
        local iStroke = Utils.Stroke(inputFrame, Color3.new(1, 1, 1), 1, 0.95)
        
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -85, 1, 0)
        box.Position = UDim2.fromOffset(45, 0)
        box.Text = ""
        box.PlaceholderText = "Enter your key..."
        box.TextColor3 = Color3.new(1, 1, 1)
        box.TextSize = 14
        box.Font = Enum.Font.Gotham
        box.BackgroundTransparency = 1
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.Parent = inputFrame
        
        local paste = Instance.new("ImageButton")
        paste.Size = UDim2.fromOffset(18, 18)
        paste.Position = UDim2.new(1, -14, 0.5, 0)
        paste.AnchorPoint = Vector2.new(1, 0.5)
        paste.Image = Icons.Copy
        paste.ImageColor3 = Configuration.Colors.TextMuted
        paste.BackgroundTransparency = 1
        paste.Parent = inputFrame
        
        local btnRow = Instance.new("Frame")
        btnRow.Size = UDim2.new(0, 280, 0, 50)
        btnRow.BackgroundTransparency = 1
        btnRow.Parent = content
        
        local redeem = Instance.new("TextButton")
        redeem.Size = UDim2.new(0.5, -8, 1, 0)
        redeem.BackgroundColor3 = Configuration.Colors.Primary
        redeem.Text = "Validate"
        redeem.TextColor3 = Color3.new(1, 1, 1)
        redeem.Font = Enum.Font.GothamBold
        redeem.TextSize = 14
        redeem.AutoButtonColor = false
        redeem.Parent = btnRow
        Utils.Round(redeem, 14)
        
        local getKey = Instance.new("TextButton")
        getKey.Size = UDim2.new(0.5, -8, 1, 0)
        getKey.Position = UDim2.new(0.5, 8, 0, 0)
        getKey.BackgroundColor3 = Color3.new(1, 1, 1)
        getKey.BackgroundTransparency = 0.955
        getKey.Text = "Get Key Link"
        getKey.TextColor3 = Color3.new(1, 1, 1)
        getKey.Font = Enum.Font.GothamBold
        getKey.TextSize = 14
        getKey.AutoButtonColor = false
        getKey.Parent = btnRow
        Utils.Round(getKey, 14)
        Utils.Stroke(getKey, Color3.new(1, 1, 1), 1, 0.94)
        
        -- Button hover effects
        local function ApplyHover(btn)
            btn.MouseEnter:Connect(function()
                Utils.Tween(btn, {BackgroundTransparency = 0.1}, 0.2)
            end)
            btn.MouseLeave:Connect(function()
                Utils.Tween(btn, {BackgroundTransparency = btn == getKey and 0.045 or 0}, 0.2)
            end)
        end
        ApplyHover(redeem)
        ApplyHover(getKey)
        
        -- MODIFIED: Get Key Link button - sends "GET_LINK" signal
        getKey.MouseButton1Click:Connect(function()
            getgenv().USER_KEY_INPUT = "GET_LINK"
        end)
        
        -- MODIFIED: Validate button - sends the key
        redeem.MouseButton1Click:Connect(function()
            if box.Text and #box.Text > 0 then
                getgenv().USER_KEY_INPUT = box.Text
                box.Text = ""
            else
                ToastSystem.Create(screen, "Please enter a key first", "warning")
            end
        end)
        
        -- Toast system for notifications
        local function checkForToasts()
            if getgenv().SHOW_TOAST then
                local toast = getgenv().SHOW_TOAST
                getgenv().SHOW_TOAST = nil
                ToastSystem.Create(screen, toast.message, toast.type)
            end
        end
        
        -- Create a thread to check for toasts
        task.spawn(function()
            while screen and screen.Parent do
                checkForToasts()
                task.wait(0.1)
            end
        end)
        
        -- Animate in
        main.Position = UDim2.new(0.5, 0, 0.5, 100)
        main.BackgroundTransparency = 1
        Utils.Tween(main, {
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 0.2
        }, 0.8, Enum.EasingStyle.Exponential)
        
        -- Make draggable
        local dragging, dragStart, startPos
        bar.InputBegan:Connect(function(input)
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
        
        return screen
    end

    -- Build the UI
    Build()
    
    -- Main validation loop (from your structure)
    while not getgenv().SCRIPT_KEY and not getgenv().UI_CLOSED do
        task.wait(0.1)
        
        -- Get user input from YOUR UI
        local userInput = yourUIGetInput()
        
        if userInput == "GET_LINK" then
            local link = Junkie.get_key_link()
            if link then
                yourUIShowLink(link)  -- Display link to user
            else
                yourUIShowError("Rate limited! Wait 5 minutes")
            end
        elseif userInput and #userInput > 0 then
            attempts = attempts + 1
            
            if attempts > maxAttempts then
                yourUIShowError("Too many failed attempts!")
                getgenv().UI_CLOSED = true
                break
            end
            
            -- Use pcall for error handling
            local success, validation = pcall(function()
                return Junkie.check_key(userInput)
            end)
            
            if success and type(validation) == "table" and validation.valid then
                getgenv().SCRIPT_KEY = userInput
                yourUIShowSuccess("Key validated!")
                
                -- Close UI
                task.wait(1)
                if screenGui then
                    screenGui:Destroy()
                end
                break
            else
                local errorMsg = validation and validation.message or "Invalid key"
                yourUIShowError(errorMsg)
                
                -- Handle all possible backend error messages
                if errorMsg == "KEY_EXPIRED" then
                    yourUIShowInfo("Key expired - get a new one")
                elseif errorMsg == "HWID_BANNED" then
                    game.Players.LocalPlayer:Kick("Hardware banned")
                    getgenv().UI_CLOSED = true
                    return nil
                elseif errorMsg == "SERVICE_MISMATCH" then
                    yourUIShowInfo("Key is for a different service")
                elseif errorMsg == "HWID_MISMATCH" then
                    yourUIShowInfo("HWID limit reached")
                end
            end
        end
    end
    
    return getgenv().SCRIPT_KEY
end)()

if not result then
    warn("UI closed without valid key")
    return
end

-- Load your main script with the validated key
print("✅ Key validated! Loading main script...")
loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/15f465ee60342132491cef9599ab1d1d0708c408a60699a8fecda99e5b36f25d/download"))()
