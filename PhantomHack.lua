--[===[ PHANTOM HACK PREMIUM HUB BY OREO - FINAL REQUESTED VERSION ]===]--
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PhantomHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- Main Frame (slightly transparent)
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 920, 0, 620)
Main.Position = UDim2.new(0.5, -460, 0.5, -310)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Main.BackgroundTransparency = 0.08  -- More transparent as requested
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 18)
MainCorner.Parent = Main

-- Make menu draggable
local dragging = false
local dragInput
local dragStart
local startPos

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

Main.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Left Sidebar (hidden until key accepted)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 240, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(8, 8, 13)
Sidebar.BorderSizePixel = 0
Sidebar.Visible = false
Sidebar.Parent = Main

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 18)
SidebarCorner.Parent = Sidebar

-- Logo + Title in Sidebar
local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 80, 0, 80)
Logo.Position = UDim2.new(0.5, -40, 0, 30)
Logo.BackgroundTransparency = 1
Logo.Image = "https://i.imgur.com/jr7hGNT.png"
Logo.Parent = Sidebar

local PhantomTitle = Instance.new("TextLabel")
PhantomTitle.Size = UDim2.new(1, 0, 0, 50)
PhantomTitle.Position = UDim2.new(0, 0, 0, 130)
PhantomTitle.BackgroundTransparency = 1
PhantomTitle.Text = "PHANTOM"
PhantomTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
PhantomTitle.TextScaled = true
PhantomTitle.Font = Enum.Font.GothamBlack
PhantomTitle.Parent = Sidebar

local HackTitle = Instance.new("TextLabel")
HackTitle.Size = UDim2.new(1, 0, 0, 35)
HackTitle.Position = UDim2.new(0, 0, 0, 175)
HackTitle.BackgroundTransparency = 1
HackTitle.Text = "HACK"
HackTitle.TextColor3 = Color3.fromRGB(255, 0, 0)
HackTitle.TextScaled = true
HackTitle.Font = Enum.Font.GothamBlack
HackTitle.Parent = Sidebar

local ByOreo = Instance.new("TextLabel")
ByOreo.Size = UDim2.new(1, 0, 0, 20)
ByOreo.Position = UDim2.new(0, 0, 0, 210)
ByOreo.BackgroundTransparency = 1
ByOreo.Text = "by Oreo • V1.0"
ByOreo.TextColor3 = Color3.fromRGB(160, 160, 160)
ByOreo.TextScaled = true
ByOreo.Font = Enum.Font.Gotham
ByOreo.Parent = Sidebar

-- Navigation Buttons (only appear after key success)
local navButtons = {}

local function createNavButton(text, icon, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 50)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    btn.Text = "  " .. icon .. "  " .. text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Sidebar
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 10)
    table.insert(navButtons, btn)
    return btn
end

local KeySystemBtn   = createNavButton("Key System", "🔑", 260)
local GeneralBtn     = createNavButton("General", "⚙️", 320)
local FarmingBtn     = createNavButton("Farming", "🌾", 380)
local CombatBtn      = createNavButton("Combat", "⚔️", 440)
local VisualsBtn     = createNavButton("Visuals", "👁️", 500)
local MiscBtn        = createNavButton("Misc", "🔧", 560)

-- Main Content Area
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -250, 1, 0)
Content.Position = UDim2.new(0, 240, 0, 0)
Content.BackgroundTransparency = 1
Content.Parent = Main

-- KEY SYSTEM SECTION (shown first)
local KeySection = Instance.new("Frame")
KeySection.Size = UDim2.new(1, -40, 1, -40)
KeySection.Position = UDim2.new(0, 20, 0, 20)
KeySection.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
KeySection.BackgroundTransparency = 0.1
KeySection.Parent = Content

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 16)
KeyCorner.Parent = KeySection

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.9, 0, 0, 80)
KeyBox.Position = UDim2.new(0.05, 0, 0.2, 0)
KeyBox.PlaceholderText = "ENTER KEY (PHANTOM-XXXXXX)"
KeyBox.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.TextScaled = true
KeyBox.Font = Enum.Font.GothamSemibold
KeyBox.Parent = KeySection

local KeyBoxCorner = Instance.new("UICorner")
KeyBoxCorner.CornerRadius = UDim.new(0, 14)
KeyBoxCorner.Parent = KeyBox

local LoadBtn = Instance.new("TextButton")
LoadBtn.Size = UDim2.new(0.9, 0, 0, 80)
LoadBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
LoadBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
LoadBtn.Text = "LOAD PHANTOM HACK"
LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadBtn.TextScaled = true
LoadBtn.Font = Enum.Font.GothamBold
LoadBtn.Parent = KeySection

local LoadBtnCorner = Instance.new("UICorner")
LoadBtnCorner.CornerRadius = UDim.new(0, 14)
LoadBtnCorner.Parent = LoadBtn

-- Loading Screen Overlay
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
LoadingFrame.BackgroundTransparency = 0.4
LoadingFrame.Visible = false
LoadingFrame.Parent = Main

local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1, 0, 0, 100)
LoadingText.Position = UDim2.new(0, 0, 0.4, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "LOADING PHANTOM HACK..."
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.TextScaled = true
LoadingText.Font = Enum.Font.GothamBold
LoadingText.Parent = LoadingFrame

-- Dark/Light Mode Toggle (in key section)
local ModeToggle = Instance.new("TextButton")
ModeToggle.Size = UDim2.new(0.9, 0, 0, 55)
ModeToggle.Position = UDim2.new(0.05, 0, 0.7, 0)
ModeToggle.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
ModeToggle.Text = "SWITCH TO LIGHT MODE"
ModeToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeToggle.TextScaled = true
ModeToggle.Font = Enum.Font.GothamSemibold
ModeToggle.Parent = KeySection

local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0, 12)
ModeCorner.Parent = ModeToggle

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -55, 0, 15)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Main

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Theme Logic
local isDark = true
local function applyTheme(dark)
    if dark then
        Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
        KeySection.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        KeyBox.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        ModeToggle.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        LoadBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ModeToggle.Text = "SWITCH TO LIGHT MODE"
    else
        Main.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
        KeySection.BackgroundColor3 = Color3.fromRGB(230, 230, 235)
        KeyBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ModeToggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        LoadBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        ModeToggle.Text = "SWITCH TO DARK MODE"
    end
end

ModeToggle.MouseButton1Click:Connect(function()
    isDark = not isDark
    applyTheme(isDark)
end)

-- Key Submit Logic
LoadBtn.MouseButton1Click:Connect(function()
    local key = KeyBox.Text
    if key:find("^PHANTOM%-") then
        LoadingFrame.Visible = true
        LoadBtn.Text = "LOADING..."
        task.wait(1.2)
        
        -- Hide key section and show full hub
        KeySection.Visible = false
        Sidebar.Visible = true
        
        -- Load the actual hack
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Le-Oreo/Phantomhack/main/Core.lua"))()
        
        LoadingFrame.Visible = false
        ScreenGui:Destroy()
    else
        LoadBtn.Text = "INVALID KEY"
        task.wait(1.6)
        LoadBtn.Text = "LOAD PHANTOM HACK"
    end
end)

print("Phantom Premium Hub by Oreo Loaded - Draggable + Transparent + Loading Screen")
