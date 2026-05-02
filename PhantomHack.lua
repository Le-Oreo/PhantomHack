--[===[ PHANTOM HACK PREMIUM HUB BY OREO - FULL VERSION ]===]--
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PhantomHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- Main Hub Frame (large and premium)
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 920, 0, 620)
Main.Position = UDim2.new(0.5, -460, 0.5, -310)
Main.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 18)
MainCorner.Parent = Main

-- Left Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 240, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(8, 8, 13)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 18)
SidebarCorner.Parent = Sidebar

-- Logo in Sidebar
local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 80, 0, 80)
Logo.Position = UDim2.new(0.5, -40, 0, 30)
Logo.BackgroundTransparency = 1
Logo.Image = "https://i.imgur.com/jr7hGNT.png" -- YOUR PHANTOM LOGO
Logo.Parent = Sidebar

-- PHANTOM HACK Title in Sidebar
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

-- Sidebar Navigation Buttons
local navY = 260
local function createNavButton(text, yOffset)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 45)
    btn.Position = UDim2.new(0, 10, 0, yOffset)
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = Sidebar
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 10)
    return btn
end

local KeyTab = createNavButton("🔑 Key System", navY)
local GeneralTab = createNavButton("⚙️ General", navY + 55)
local FarmingTab = createNavButton("🌾 Farming", navY + 110)
local CombatTab = createNavButton("⚔️ Combat", navY + 165)
local VisualsTab = createNavButton("👁️ Visuals", navY + 220)
local MiscTab = createNavButton("🔧 Misc", navY + 275)

-- Main Content Area
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -250, 1, 0)
Content.Position = UDim2.new(0, 250, 0, 0)
Content.BackgroundTransparency = 1
Content.Parent = Main

-- === KEY SYSTEM SECTION (Default Visible) ===
local KeySection = Instance.new("Frame")
KeySection.Size = UDim2.new(1, -40, 1, -40)
KeySection.Position = UDim2.new(0, 20, 0, 20)
KeySection.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
KeySection.Visible = true
KeySection.Parent = Content

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 14)
KeyCorner.Parent = KeySection

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.9, 0, 0, 80)
KeyBox.Position = UDim2.new(0.05, 0, 0.15, 0)
KeyBox.PlaceholderText = "ENTER KEY (PHANTOM-XXXXXX)"
KeyBox.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.TextScaled = true
KeyBox.Font = Enum.Font.GothamSemibold
KeyBox.Parent = KeySection

local KeyBoxCorner = Instance.new("UICorner")
KeyBoxCorner.CornerRadius = UDim.new(0, 12)
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
LoadBtnCorner.CornerRadius = UDim.new(0, 12)
LoadBtnCorner.Parent = LoadBtn

-- Dark / Light Mode Toggle (bottom of key section)
local ModeToggle = Instance.new("TextButton")
ModeToggle.Size = UDim2.new(0.9, 0, 0, 55)
ModeToggle.Position = UDim2.new(0.05, 0, 0.7, 0)
ModeToggle.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
ModeToggle.Text = "SWITCH TO LIGHT MODE"
ModeToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeToggle.TextScaled = true
ModeToggle.Font = Enum.Font.GothamSemibold
ModeToggle.Parent = KeySection

local ModeToggleCorner = Instance.new("UICorner")
ModeToggleCorner.CornerRadius = UDim.new(0, 12)
ModeToggleCorner.Parent = ModeToggle

-- Close Button (top right of whole hub)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -50, 0, 10)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Main
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- === THEME SWITCHING ===
local isDark = true
local function applyTheme(dark)
    if dark then
        Main.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
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

-- === KEY SUBMIT LOGIC ===
LoadBtn.MouseButton1Click:Connect(function()
    local key = KeyBox.Text
    if key:find("^PHANTOM%-") then
        LoadBtn.Text = "LOADING FULL HUB..."
        task.wait(0.6)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Le-Oreo/Phantomhack/main/Core.lua"))()
        ScreenGui:Destroy()
    else
        LoadBtn.Text = "INVALID KEY"
        task.wait(1.8)
        LoadBtn.Text = "LOAD PHANTOM HACK"
    end
end)

print("Phantom Premium Hub by Oreo - Full Version Loaded")
