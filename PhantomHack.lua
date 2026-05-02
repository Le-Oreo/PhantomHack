--[===[ PHANTOM HACK MENU BY OREO - PREMIUM EDITION ]===]--
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PhantomHackMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- Main Frame (bigger & smoother)
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 620, 0, 520)
Main.Position = UDim2.new(0.5, -310, 0.5, -260)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
UICorner.Parent = Main

-- Title Bar with Logo Style
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 90)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 16)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "PHANTOM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.Parent = TitleBar

local HackText = Instance.new("TextLabel")
HackText.Size = UDim2.new(1, 0, 0, 40)
HackText.Position = UDim2.new(0, 0, 0.55, 0)
HackText.BackgroundTransparency = 1
HackText.Text = "HACK"
HackText.TextColor3 = Color3.fromRGB(255, 0, 0)
HackText.TextScaled = true
HackText.Font = Enum.Font.GothamBlack
HackText.Parent = TitleBar

-- Subtitle
local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0, 30)
Subtitle.Position = UDim2.new(0, 0, 0.85, 0)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "by Oreo • V1.0"
Subtitle.TextColor3 = Color3.fromRGB(100, 100, 255)
Subtitle.TextScaled = true
Subtitle.Font = Enum.Font.Gotham
Subtitle.Parent = TitleBar

-- Key Input Area
local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.85, 0, 0, 65)
KeyBox.Position = UDim2.new(0.075, 0, 0.32, 0)
KeyBox.PlaceholderText = "ENTER KEY HERE"
KeyBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
KeyBox.TextColor3 = Color3.fromRGB(0, 255, 255)
KeyBox.TextScaled = true
KeyBox.Font = Enum.Font.GothamSemibold
KeyBox.Parent = Main

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 12)
KeyCorner.Parent = KeyBox

-- Submit Button
local Submit = Instance.new("TextButton")
Submit.Size = UDim2.new(0.85, 0, 0, 70)
Submit.Position = UDim2.new(0.075, 0, 0.52, 0)
Submit.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
Submit.Text = "LOAD PHANTOM HACK"
Submit.TextColor3 = Color3.fromRGB(255, 255, 255)
Submit.TextScaled = true
Submit.Font = Enum.Font.GothamBold
Submit.Parent = Main

local SubmitCorner = Instance.new("UICorner")
SubmitCorner.CornerRadius = UDim.new(0, 14)
SubmitCorner.Parent = Submit

Submit.MouseButton1Click:Connect(function()
    if KeyBox.Text:find("^PHANTOM%-") then
        Submit.Text = "LOADING CORE..."
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Le-Oreo/Phantomhack/main/Core.lua"))()
        ScreenGui:Destroy()
    else
        Submit.Text = "INVALID KEY"
        wait(1.5)
        Submit.Text = "LOAD PHANTOM HACK"
    end
end)

-- Footer
local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, 0, 0, 30)
Footer.Position = UDim2.new(0, 0, 0.9, 0)
Footer.BackgroundTransparency = 1
Footer.Text = "Made by Oreo • Phantom Hack"
Footer.TextColor3 = Color3.fromRGB(120, 120, 120)
Footer.TextScaled = true
Footer.Font = Enum.Font.Gotham
Footer.Parent = Main

print("Phantom Premium Menu by Oreo Loaded")
