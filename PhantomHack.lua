--[===[ PHANTOM HACK PREMIUM HUB BY OREO - COMPACT START + EXPAND ]===]--
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PhantomHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- ==================== SMALL INITIAL MENU ====================
local SmallMenu = Instance.new("Frame")
SmallMenu.Size = UDim2.new(0, 460, 0, 320)
SmallMenu.Position = UDim2.new(0.5, -230, 0.5, -160)
SmallMenu.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
SmallMenu.BackgroundTransparency = 0.05
SmallMenu.BorderSizePixel = 0
SmallMenu.Parent = ScreenGui

local SmallCorner = Instance.new("UICorner")
SmallCorner.CornerRadius = UDim.new(0, 18)
SmallCorner.Parent = SmallMenu

-- Title Bar (Small)
local SmallTitleBar = Instance.new("Frame")
SmallTitleBar.Size = UDim2.new(1, 0, 0, 80)
SmallTitleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
SmallTitleBar.Parent = SmallMenu

local SmallTitle = Instance.new("TextLabel")
SmallTitle.Size = UDim2.new(1, 0, 1, 0)
SmallTitle.BackgroundTransparency = 1
SmallTitle.Text = "PHANTOM"
SmallTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SmallTitle.TextScaled = true
SmallTitle.Font = Enum.Font.GothamBlack
SmallTitle.Parent = SmallTitleBar

local SmallHack = Instance.new("TextLabel")
SmallHack.Size = UDim2.new(1, 0, 0, 30)
SmallHack.Position = UDim2.new(0, 0, 0.55, 0)
SmallHack.BackgroundTransparency = 1
SmallHack.Text = "HACK"
SmallHack.TextColor3 = Color3.fromRGB(255, 0, 0)
SmallHack.TextScaled = true
SmallHack.Font = Enum.Font.GothamBlack
SmallHack.Parent = SmallTitleBar

local SmallSubtitle = Instance.new("TextLabel")
SmallSubtitle.Size = UDim2.new(1, 0, 0, 20)
SmallSubtitle.Position = UDim2.new(0, 0, 0.85, 0)
SmallSubtitle.BackgroundTransparency = 1
SmallSubtitle.Text = "by Oreo • V1.0"
SmallSubtitle.TextColor3 = Color3.fromRGB(170, 170, 170)
SmallSubtitle.TextScaled = true
SmallSubtitle.Font = Enum.Font.Gotham
SmallSubtitle.Parent = SmallTitleBar

-- Key Input in Small Menu
local SmallKeyBox = Instance.new("TextBox")
SmallKeyBox.Size = UDim2.new(0.85, 0, 0, 65)
SmallKeyBox.Position = UDim2.new(0.075, 0, 0.35, 0)
SmallKeyBox.PlaceholderText = "ENTER KEY (PHANTOM-XXXXXX)"
SmallKeyBox.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
SmallKeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SmallKeyBox.TextScaled = true
SmallKeyBox.Font = Enum.Font.GothamSemibold
SmallKeyBox.Parent = SmallMenu

local SmallKeyCorner = Instance.new("UICorner")
SmallKeyCorner.CornerRadius = UDim.new(0, 14)
SmallKeyCorner.Parent = SmallKeyBox

local SmallLoadBtn = Instance.new("TextButton")
SmallLoadBtn.Size = UDim2.new(0.85, 0, 0, 70)
SmallLoadBtn.Position = UDim2.new(0.075, 0, 0.6, 0)
SmallLoadBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
SmallLoadBtn.Text = "LOAD PHANTOM HACK"
SmallLoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SmallLoadBtn.TextScaled = true
SmallLoadBtn.Font = Enum.Font.GothamBold
SmallLoadBtn.Parent = SmallMenu

local SmallLoadCorner = Instance.new("UICorner")
SmallLoadCorner.CornerRadius = UDim.new(0, 14)
SmallLoadCorner.Parent = SmallLoadBtn

-- ==================== FULL HUB (appears after key) ====================
local FullHub = Instance.new("Frame")
FullHub.Size = UDim2.new(0, 920, 0, 620)
FullHub.Position = UDim2.new(0.5, -460, 0.5, -310)
FullHub.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
FullHub.BackgroundTransparency = 0.05
FullHub.BorderSizePixel = 0
FullHub.Visible = false
FullHub.Parent = ScreenGui

local FullCorner = Instance.new("UICorner")
FullCorner.CornerRadius = UDim.new(0, 18)
FullCorner.Parent = FullHub

-- Left Sidebar for Full Hub
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 240, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(8, 8, 13)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = FullHub

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 18)
SidebarCorner.Parent = Sidebar

-- Logo and Title in Full Sidebar
local FullLogo = Instance.new("ImageLabel")
FullLogo.Size = UDim2.new(0, 70, 0, 70)
FullLogo.Position = UDim2.new(0.5, -35, 0, 30)
FullLogo.BackgroundTransparency = 1
FullLogo.Image = "https://i.imgur.com/jr7hGNT.png"
FullLogo.Parent = Sidebar

local FullPhantom = Instance.new("TextLabel")
FullPhantom.Size = UDim2.new(1, 0, 0, 45)
FullPhantom.Position = UDim2.new(0, 0, 0, 120)
FullPhantom.BackgroundTransparency = 1
FullPhantom.Text = "PHANTOM"
FullPhantom.TextColor3 = Color3.fromRGB(255, 255, 255)
FullPhantom.TextScaled = true
FullPhantom.Font = Enum.Font.GothamBlack
FullPhantom.Parent = Sidebar

local FullHack = Instance.new("TextLabel")
FullHack.Size = UDim2.new(1, 0, 0, 35)
FullHack.Position = UDim2.new(0, 0, 0, 160)
FullHack.BackgroundTransparency = 1
FullHack.Text = "HACK"
FullHack.TextColor3 = Color3.fromRGB(255, 0, 0)
FullHack.TextScaled = true
FullHack.Font = Enum.Font.GothamBlack
FullHack.Parent = Sidebar

-- Navigation Buttons
local function createNav(text, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 48)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = Sidebar
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 10)
    return btn
end

local btnY = 240
createNav("🔑 Key System", btnY)
createNav("⚙️ General", btnY + 58)
createNav("🌾 Farming", btnY + 116)
createNav("⚔️ Combat", btnY + 174)
createNav("👁️ Visuals", btnY + 232)
createNav("🔧 Misc", btnY + 290)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -50, 0, 15)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = FullHub
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- ==================== LOGIC ====================
SmallLoadBtn.MouseButton1Click:Connect(function()
    local key = SmallKeyBox.Text
    if key:find("^PHANTOM%-") then
        SmallLoadBtn.Text = "LOADING..."
        task.wait(0.8)
        
        -- Hide small menu and show full hub
        SmallMenu.Visible = false
        FullHub.Visible = true
        
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Le-Oreo/Phantomhack/main/Core.lua"))()
    else
        SmallLoadBtn.Text = "INVALID KEY"
        task.wait(1.5)
        SmallLoadBtn.Text = "LOAD PHANTOM HACK"
    end
end)

print("Phantom Hub by Oreo - Compact Start + Full Expand Loaded")
