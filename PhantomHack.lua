--[===[ PHANTOM HACK BY OREO - CUSTOM GUI ]===]--
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PhantomHackGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 320)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Top Bar with Logo
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 60)
TopBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TopBar.Parent = MainFrame

local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 50, 0, 50)
Logo.Position = UDim2.new(0, 10, 0, 5)
Logo.BackgroundTransparency = 1
Logo.Image = "https://i.imgur.com/YOUR_PHANTOM_LOGO.png"  -- replace with your logo link
Logo.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 70, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "PHANTOM HACK"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.Parent = TopBar

-- Key Input
local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.8, 0, 0, 50)
KeyBox.Position = UDim2.new(0.1, 0, 0.3, 0)
KeyBox.PlaceholderText = "Enter Key (PHANTOM-XXXX)"
KeyBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.Parent = MainFrame

local Submit = Instance.new("TextButton")
Submit.Size = UDim2.new(0.8, 0, 0, 50)
Submit.Position = UDim2.new(0.1, 0, 0.55, 0)
Submit.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Submit.Text = "SUBMIT KEY"
Submit.TextColor3 = Color3.fromRGB(255, 255, 255)
Submit.Font = Enum.Font.GothamBold
Submit.Parent = MainFrame

-- Dark/Light Toggle
local ThemeToggle = Instance.new("TextButton")
ThemeToggle.Size = UDim2.new(0.8, 0, 0, 40)
ThemeToggle.Position = UDim2.new(0.1, 0, 0.75, 0)
ThemeToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ThemeToggle.Text = "Switch to Light Mode"
ThemeToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ThemeToggle.Parent = MainFrame

local isDark = true
ThemeToggle.MouseButton1Click:Connect(function()
    isDark = not isDark
    if isDark then
        MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
        ThemeToggle.Text = "Switch to Light Mode"
    else
        MainFrame.BackgroundColor3 = Color3.fromRGB(240,240,240)
        ThemeToggle.Text = "Switch to Dark Mode"
    end
end)

Submit.MouseButton1Click:Connect(function()
    if KeyBox.Text:find("^PHANTOM%-") then
        Submit.Text = "LOADING..."
        wait(1)
        print("PHANTOM HACK BY OREO LOADED | Player: " .. player.Name)
        -- ESP
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local box = Instance.new("BoxHandleAdornment", plr.Character)
                box.Adornee = plr.Character.HumanoidRootPart
                box.Size = Vector3.new(4,6,4)
                box.Transparency = 0.5
                box.Color3 = Color3.new(0,1,1)
                box.AlwaysOnTop = true
            end
        end
        ScreenGui:Destroy()
    else
        Submit.Text = "INVALID KEY"
    end
end)

print("Phantom Custom GUI by Oreo Loaded")
