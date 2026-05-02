--[===[ PHANTOM MENU BY OREO ]===]--
local player = game.Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player.PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 480, 0, 380)
Main.Position = UDim2.new(0.5, -240, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(15,15,15)
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 60)
Title.BackgroundColor3 = Color3.fromRGB(0,0,0)
Title.Text = "PHANTOM HACK BY OREO"
Title.TextColor3 = Color3.fromRGB(255,0,0)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.Parent = Main

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.8, 0, 0, 50)
KeyBox.Position = UDim2.new(0.1, 0, 0.3, 0)
KeyBox.PlaceholderText = "Enter Key"
KeyBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
KeyBox.TextColor3 = Color3.fromRGB(255,255,255)
KeyBox.Parent = Main

local Submit = Instance.new("TextButton")
Submit.Size = UDim2.new(0.8, 0, 0, 60)
Submit.Position = UDim2.new(0.1, 0, 0.5, 0)
Submit.BackgroundColor3 = Color3.fromRGB(255,0,0)
Submit.Text = "SUBMIT & LOAD CORE"
Submit.TextColor3 = Color3.fromRGB(255,255,255)
Submit.Parent = Main

Submit.MouseButton1Click:Connect(function()
    _G.Key = KeyBox.Text
    if _G.Key:find("^PHANTOM%-") then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Le-Oreo/Phantomhack/main/Core.lua"))()
        ScreenGui:Destroy()
    else
        Submit.Text = "INVALID KEY"
    end
end)

print("Phantom Menu by Oreo Loaded")
