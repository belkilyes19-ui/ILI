-- Exemple de LocalScript pour Roblox Studio
-- Emplacement recommandé: StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Crée une GUI simple avec un bouton et une zone de texte
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ExampleToggleGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 80)
frame.Position = UDim2.new(0.5, -120, 0.5, -40)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 24)
title.Position = UDim2.new(0, 10, 0, 8)
title.BackgroundTransparency = 1
title.Text = "Exemple LocalScript"
title.TextColor3 = Color3.fromRGB(230, 230, 230)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 100, 0, 30)
btn.Position = UDim2.new(0.5, -50, 0, 36)
btn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
btn.BorderSizePixel = 0
btn.Text = "Cacher GUI"
btn.TextColor3 = Color3.fromRGB(230, 230, 230)
btn.Font = Enum.Font.Gotham
btn.TextSize = 12
btn.Parent = frame

local guiVisible = true

local function setVisible(v)
    guiVisible = v
    frame.Visible = v
    if v then
        btn.Text = "Cacher GUI"
    else
        btn.Text = "Afficher GUI"
    end
end

btn.MouseButton1Click:Connect(function()
    setVisible(not guiVisible)
end)

-- Touche V pour toggle
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.V then
            setVisible(not guiVisible)
        end
    end
end)

print("Example LocalScript chargé")
