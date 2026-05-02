--[===[ PHANTOM HACK PREMIUM MENU BY OREO ]===]--
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PhantomHackMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- Main Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 640, 0, 560)
Main.Position = UDim2.new(0.5, -320, 0.5, -280)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 18)
MainCorner.Parent = Main

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 100)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 18)
TitleBarCorner.Parent = TitleBar

-- YOUR LOGO (replace the link below with your direct image link)
local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 70, 0, 70)
Logo.Position = UDim2.new(0, 20, 0, 15)
Logo.BackgroundTransparency = 1
Logo.Image = "https://i.imgur.com/jr7hGNT.png"  -- ← YOUR LOGO FROM https://imgur.com/a/jr7hGNT
Logo.Parent = TitleBar

-- PHANTOM Text
local PhantomText = Instance.new("TextLabel")
PhantomText.Size = UDim2.new(0, 300, 0, 55)
PhantomText.Position = UDim2.new(0, 110, 0, 10)
PhantomText.BackgroundTransparency = 1
PhantomText.Text = "PHANTOM"
PhantomText.TextColor3 = Color3.fromRGB(255, 255, 255)
PhantomText.TextScaled = true
PhantomText.Font = Enum.Font.GothamBlack
PhantomText.Parent = TitleBar

-- HACK Text
local HackText = Instance.new("TextLabel")
HackText.Size = UDim2.new(0, 300, 0, 40)
HackText.Position = UDim2.new(0, 110, 0, 55)
HackText.BackgroundTransparency = 1
HackText.Text = "HACK"
HackText.TextColor3 = Color3.fromRGB(255, 0, 0)
HackText.TextScaled = true
HackText.Font = Enum.Font.GothamBlack
HackText.Parent = TitleBar

-- Subtitle
local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(0, 300, 0, 20)
Subtitle.Position = UDim2.new(0, 110, 0, 80)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "by Oreo • V1.0"
Subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
Subtitle.TextScaled = true
Subtitle.Font = Enum.Font.Gotham
Subtitle.Parent = TitleBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -50, 0, 10)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Key Input
local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.85, 0, 0, 70)
KeyBox.Position = UDim2.new(0.075, 0, 0.32, 0)
KeyBox.PlaceholderText = "ENTER KEY (PHANTOM-XXXXXX)"
KeyBox.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.TextScaled = true
KeyBox.Font = Enum.Font.GothamSemibold
KeyBox.Parent = Main

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 16)
KeyCorner.Parent = KeyBox

-- Submit Button
local Submit = Instance.new("TextButton")
Submit.Size = UDim2.new(0.85, 0, 0, 75)
Submit.Position = UDim2.new(0.075, 0, 0.52, 0)
Submit.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Submit.Text = "LOAD PHANTOM HACK"
Submit.TextColor3 = Color3.fromRGB(255, 255, 255)
Submit.TextScaled = true
Submit.Font = Enum.Font.GothamBold
Submit.Parent = Main

local SubmitCorner = Instance.new("UICorner")
SubmitCorner.CornerRadius = UDim.new(0, 16)
SubmitCorner.Parent = Submit

-- Dark/Light Mode Toggle
local ModeToggle = Instance.new("TextButton")
ModeToggle.Size = UDim2.new(0.85, 0, 0, 50)
ModeToggle.Position = UDim2.new(0.075, 0, 0.72, 0)
ModeToggle.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
ModeToggle.Text = "SWITCH TO LIGHT MODE"
ModeToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeToggle.TextScaled = true
ModeToggle.Font = Enum.Font.GothamSemibold
ModeToggle.Parent = Main

local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0, 14)
ModeCorner.Parent = ModeToggle

-- Theme Switching
local isDark = true
local function applyTheme(dark)
    if dark then
        Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
        TitleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        KeyBox.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        ModeToggle.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        Submit.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ModeToggle.Text = "SWITCH TO LIGHT MODE"
    else
        Main.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
        TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        KeyBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ModeToggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Submit.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        ModeToggle.Text = "SWITCH TO DARK MODE"
    end
end

ModeToggle.MouseButton1Click:Connect(function()
    isDark = not isDark
    applyTheme(isDark)
end)

-- Submit Logic
Submit.MouseButton1Click:Connect(function()
    local key = KeyBox.Text
    if key:find("^PHANTOM%-") then
        Submit.Text = "LOADING..."
        task.wait(0.8)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Le-Oreo/Phantomhack/main/Core.lua"))()
        ScreenGui:Destroy()
    else
        Submit.Text = "INVALID KEY"
        task.wait(1.5)
        Submit.Text = "LOAD PHANTOM HACK"
    end
end)

print("Phantom Premium Menu by Oreo Loaded")
