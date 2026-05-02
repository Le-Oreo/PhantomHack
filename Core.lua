--[[
    Core.lua — Phantom Hack Game Features
    
    HOW THIS WORKS:
    ───────────────
    1. Player runs:  loadstring(game:HttpGet("RAW_URL_OF_THIS_FILE"))()
    2. This loads PhantomHack.lua (the GUI template) automatically
    3. Player enters their key on the key screen
    4. WaitForAuth() yields until they authenticate
    5. PH is returned with their Tier ("Free" or "Premium")
    6. Tabs are built based on their tier
    
    YOU ONLY EDIT THIS FILE for new features.
    PhantomHack.lua is never touched.
    
    File layout in your GitHub:
        PhantomHack/
        ├── PhantomHack.lua   ← GUI template (never edit)
        ├── Core.lua          ← your features (edit this)
        └── keys.json         ← managed by the Discord bot
]]

-- ── Step 1: Load the GUI template ────────────────────────────
local MENU_URL = "https://raw.githubusercontent.com/Le-Oreo/PhantomHack/main/PhantomHack.lua"

local MenuModule = loadstring(game:HttpGet(MENU_URL, true))()

-- ── Step 2: Wait for the player to authenticate ───────────────
-- This line YIELDS (pauses) until the player enters a valid key.
-- After they do, PH contains their tier and the Tab/Notify functions.
local PH = MenuModule.WaitForAuth()

-- PH.Tier      = "Free" or "Premium"
-- PH.KeyExpiry = unix timestamp (or nil for lifetime)
-- PH:Tab("Name","icon") → creates a sidebar tab
-- PH:Notify("title","msg",dur,"kind")

local LP = game:GetService("Players").LocalPlayer

-- ── Step 3: Add tabs based on tier ───────────────────────────

-- ╔══════════════════════════════════════╗
-- ║  HOME TAB (all tiers)                ║
-- ╚══════════════════════════════════════╝
local Home = PH:Tab("Home", "⌂")
Home:Section("Welcome")
Home:Label("Welcome, "..LP.Name.."! You are on "..PH.Tier.." tier.")
if PH.KeyExpiry then
    local remaining = PH.KeyExpiry - os.time()
    local days = math.floor(remaining / 86400)
    Home:Label("Your key expires in "..days.." days.")
else
    Home:Label("Your key never expires.")
end
Home:Separator()
Home:Button("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)
Home:Button("Copy Place ID", function()
    pcall(function() if setclipboard then setclipboard(tostring(game.PlaceId)) end end)
    PH:Notify("Copied","Place ID copied.",2,"success")
end)


-- ╔══════════════════════════════════════╗
-- ║  COMBAT TAB (all tiers)              ║
-- ╚══════════════════════════════════════╝
local Combat = PH:Tab("Combat", "⚔")
Combat:Section("Aim Assist")
Combat:Toggle("Aimbot", false, function(on)
    -- your aimbot code
end)
Combat:Slider("FOV Radius", 50, 500, 150, function(v)
    -- update FOV circle
end)
Combat:Slider("Smoothness", 1, 20, 5, function(v)
    -- update smoothness
end)
Combat:Dropdown("Target Part", {"Head","HumanoidRootPart","Torso"}, "Head", function(v)
    -- update target
end)
Combat:Toggle("Team Check", true, function(on) end)
Combat:Toggle("Visible Check", true, function(on) end)

Combat:Section("Kill Aura")
Combat:Toggle("Kill Aura", false, function(on)
    -- your kill aura
end)
Combat:Slider("Kill Aura Range", 5, 60, 15, function(v)
    -- update range
end)


-- ╔══════════════════════════════════════╗
-- ║  MOVEMENT TAB (all tiers)            ║
-- ╚══════════════════════════════════════╝
local Movement = PH:Tab("Movement", "⚡")
Movement:Section("Speed")
Movement:Toggle("Walkspeed Modifier", false, function(on)
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = on and 50 or 16 end
end)
Movement:Slider("Walkspeed", 16, 250, 50, function(v)
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = v end
end)
Movement:Slider("Jump Power", 50, 400, 50, function(v)
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = v end
end)
Movement:Toggle("Infinite Jump", false, function(on)
    -- your infinite jump
end)
Movement:Section("Flight")
Movement:Toggle("Fly", false, function(on) end)
Movement:Slider("Fly Speed", 10, 200, 60, function(v) end)
Movement:Toggle("Noclip", false, function(on) end)
Movement:Toggle("Anti-AFK", false, function(on) end)


-- ╔══════════════════════════════════════╗
-- ║  VISUALS TAB (all tiers)             ║
-- ╚══════════════════════════════════════╝
local Visuals = PH:Tab("Visuals", "👁")
Visuals:Section("ESP")
Visuals:Toggle("Player ESP",   false, function(on) end)
Visuals:Toggle("Box ESP",      false, function(on) end)
Visuals:Toggle("Name Tags",    true,  function(on) end)
Visuals:Toggle("Health Bars",  true,  function(on) end)
Visuals:Toggle("Distance",     true,  function(on) end)
Visuals:Section("World")
Visuals:Toggle("Fullbright", false, function(on)
    local L = game:GetService("Lighting")
    L.Brightness = on and 2 or 1
    L.GlobalShadows = not on
end)
Visuals:Slider("Field of View", 70, 120, 70, function(v)
    workspace.CurrentCamera.FieldOfView = v
end)


-- ╔══════════════════════════════════════╗
-- ║  PREMIUM ONLY TABS                   ║
-- ║  Only added if PH.Tier == "Premium"  ║
-- ╚══════════════════════════════════════╝
if PH.Tier == "Premium" then

    -- Advanced Combat (Premium only)
    local AdvCombat = PH:Tab("Advanced ★", "★")
    AdvCombat:Section("Premium Combat")
    AdvCombat:Toggle("Silent Aim", false, function(on)
        -- premium feature
    end)
    AdvCombat:Slider("Hit Chance %", 1, 100, 85, function(v)
        -- hit chance
    end)
    AdvCombat:Toggle("Anti-Aim", false, function(on)
        -- anti aim
    end)
    AdvCombat:Toggle("Rapid Fire", false, function(on)
        -- rapid fire
    end)
    AdvCombat:Section("Prediction")
    AdvCombat:Toggle("Bullet Drop Compensation", false, function(on) end)
    AdvCombat:Slider("Prediction Amount", 0, 20, 5, function(v) end)

    -- Farming (Premium only)
    local Farm = PH:Tab("Farm ★", "🌾")
    Farm:Section("Auto Farm")
    Farm:Toggle("Auto Farm Level", false, function(on) end)
    Farm:Dropdown("Target Mob", {"Delinquent","Bandit","Pirate","Soldier"}, "Delinquent", function(v) end)
    Farm:Toggle("Auto Farm Mob", false, function(on) end)
    Farm:Section("Boss")
    Farm:Dropdown("Boss", {"---","Iron Giant","Atomic","Sky Dragon"}, "---", function(v) end)
    Farm:Dropdown("Difficulty", {"Easy","Normal","Hard","Nightmare"}, "Normal", function(v) end)
    Farm:Toggle("Auto Kill Boss", false, function(on) end)

    PH:Notify("Premium","Premium features unlocked!",4,"success")

else
    -- Free tier — show an upgrade prompt tab
    local Upgrade = PH:Tab("Upgrade →", "↑")
    Upgrade:Section("Get Premium")
    Upgrade:Label("You are on the Free tier.")
    Upgrade:Label("Upgrade to Premium to unlock:")
    Upgrade:Label("• Silent Aim & Anti-Aim")
    Upgrade:Label("• Auto Farm & Boss Farm")
    Upgrade:Label("• Rapid Fire & Prediction")
    Upgrade:Label("• All future Premium features")
    Upgrade:Separator()
    Upgrade:Button("Join Discord to Upgrade", function()
        pcall(function() if setclipboard then setclipboard("https://discord.gg/phantomhack") end end)
        PH:Notify("Discord","Invite copied! Join to get Premium.",4,"info")
    end)
end


-- ╔══════════════════════════════════════╗
-- ║  MISC TAB (all tiers)                ║
-- ╚══════════════════════════════════════╝
local Misc = PH:Tab("Misc", "◈")
Misc:Section("Teleport")
local TargetBox = Misc:Textbox("Target Player","Username...")
Misc:Button("Teleport to Player", function()
    local target = game:GetService("Players"):FindFirstChild(TargetBox.Text)
    if target and target.Character and LP.Character then
        LP.Character:PivotTo(target.Character:GetPivot())
        PH:Notify("Teleport","Teleported to "..TargetBox.Text,2,"success")
    else
        PH:Notify("Teleport","Player not found.",2,"error")
    end
end)
Misc:Button("Save Position", function()
    -- savedPos = LP.Character and LP.Character:GetPivot()
    PH:Notify("Saved","Position saved.",2,"success")
end)
Misc:Button("Load Position", function()
    -- if savedPos and LP.Character then LP.Character:PivotTo(savedPos) end
    PH:Notify("Loaded","Position loaded.",2)
end)
Misc:Section("Server")
Misc:Button("Server Hop", function()
    PH:Notify("Server Hop","Finding server...",3,"info")
    -- server hop logic
end)


-- Done!
PH:Notify("Core","Game features loaded  •  "..PH.Tier.." tier",3,"success")
