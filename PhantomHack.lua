--[===[ PHANTOM LOADER + MENU BY OREO ]===]--
local player = game.Players.LocalPlayer

local key = _G.Key or ""
if not key:find("^PHANTOM%-") then
    player:Kick("Invalid Key - Get one with /generatekey in Discord")
    return
end

-- Beautiful Custom Menu
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player.PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 480, 0, 380)
Main.Position = UDim2.new(0.5, -240, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(15,15,15)
Main.Parent = ScreenGui

-- Title with Logo (replace with your image link)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 60)
Title.BackgroundColor3 = Color3.fromRGB(0,0,0)
Title.Text = "PHANTOM HACK BY OREO"
Title.TextColor3 = Color3.fromRGB(255,0,0)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.Parent = Main

local LoadBtn = Instance.new("TextButton")
LoadBtn.Size = UDim2.new(0.8, 0, 0, 60)
LoadBtn.Position = UDim2.new(0.1, 0, 0.4, 0)
LoadBtn.BackgroundColor3 = Color3.fromRGB(255,0,0)
LoadBtn.Text = "LOAD FULL HACK"
LoadBtn.TextColor3 = Color3.fromRGB(255,255,255)
LoadBtn.Parent = Main

LoadBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Le-Oreo/Phantomhack/main/Core.lua"))()
    ScreenGui:Destroy()
end)

print("Phantom Menu by Oreo Loaded")
