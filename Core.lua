--[[
    Core.lua — Your game-specific script
    
    This file lives separately in your GitHub repo.
    It loads PhantomHack.lua first, then adds its own tabs.
    PhantomHack.lua handles ALL the GUI — you never touch it.
    
    Loadstring for players (loads Core, which loads the menu automatically):
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Le-Oreo/PhantomHack/main/Core.lua"))()
    
    File structure in your GitHub:
        PhantomHack/
        ├── PhantomHack.lua   ← the GUI template (never edited)
        └── Core.lua          ← your features (this file)
--]]

-- ── Step 1: Load the GUI template ────────────────────────────
local PH = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Le-Oreo/PhantomHack/main/PhantomHack.lua"
))()

-- PH gives you three things:
--   PH:Tab("Name", "icon")  → creates a new sidebar tab, returns a tab object
--   PH:Notify(title, msg, duration, kind)  → shows a notification
--   PH.Config  → the theme/config table (read-only, don't break it)

-- ── Step 2: Add your tabs ─────────────────────────────────────

-- ╔══════════════════════════════════════╗
-- ║  COMBAT TAB                          ║
-- ╚══════════════════════════════════════╝
local Combat = PH:Tab("Combat", "⚔")

Combat:Section("Aim Assist")

local aimbotEnabled = false
Combat:Toggle("Aimbot", false, function(on)
    aimbotEnabled = on
    -- your aimbot code here
end)

Combat:Slider("FOV Radius", 50, 500, 150, function(value)
    -- update your FOV circle
end)

Combat:Slider("Smoothness", 1, 20, 5, function(value)
    -- update smoothness
end)

Combat:Dropdown("Target Part", {"Head", "HumanoidRootPart", "Torso"}, "Head", function(choice)
    -- update target part
end)

Combat:Toggle("Visible Check", true, function(on)
    -- toggle ray check
end)

Combat:Toggle("Team Check", true, function(on)
    -- toggle team filter
end)

Combat:Section("Kill Aura")

Combat:Toggle("Kill Aura", false, function(on)
    -- your kill aura logic
end)

Combat:Slider("Kill Aura Range", 5, 60, 15, function(value)
    -- update range
end)

Combat:Toggle("Auto Block", false, function(on)
    -- your code
end)

-- ╔══════════════════════════════════════╗
-- ║  MOVEMENT TAB                        ║
-- ╚══════════════════════════════════════╝
local Movement = PH:Tab("Movement", "⚡")

Movement:Section("Speed")

local Players     = game:GetService("Players")
local LP          = Players.LocalPlayer
local speedActive = false

Movement:Toggle("Walkspeed Modifier", false, function(on)
    speedActive = on
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = on and 50 or 16 end
end)

Movement:Slider("Walkspeed", 16, 250, 50, function(value)
    if not speedActive then return end
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = value end
end)

Movement:Slider("Jump Power", 50, 400, 50, function(value)
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = value end
end)

Movement:Toggle("Infinite Jump", false, function(on)
    -- your infinite jump logic
end)

Movement:Section("Flight")

Movement:Toggle("Fly", false, function(on)
    -- your fly logic
end)

Movement:Slider("Fly Speed", 10, 200, 60, function(value)
    -- update fly speed
end)

Movement:Toggle("Noclip", false, function(on)
    -- your noclip logic
end)

Movement:Toggle("Anti-AFK", false, function(on)
    -- your anti-afk logic
end)

-- ╔══════════════════════════════════════╗
-- ║  FARMING TAB                         ║
-- ╚══════════════════════════════════════╝
local Farm = PH:Tab("Farm", "🌾")

Farm:Section("Auto Farm")

Farm:Toggle("Auto Farm Level", false, function(on)
    -- your farm logic
end)

Farm:Dropdown("Target Mob", {"Delinquent","Bandit","Pirate","Soldier"}, "Delinquent", function(choice)
    -- set target mob
end)

Farm:Toggle("Auto Farm Mob", false, function(on)
    -- your mob farm logic
end)

Farm:Toggle("Auto Farm All Mobs", false, function(on)
    -- farm all mobs logic
end)

Farm:Section("Boss")

Farm:Dropdown("Boss", {"---","Iron Giant","Atomic","Sky Dragon"}, "---", function(choice)
    -- set boss target
end)

Farm:Dropdown("Difficulty", {"Easy","Normal","Hard","Nightmare"}, "Normal", function(choice)
    -- set difficulty
end)

Farm:Toggle("Auto Kill Boss", false, function(on)
    -- your boss kill logic
end)

-- ╔══════════════════════════════════════╗
-- ║  VISUALS TAB                         ║
-- ╚══════════════════════════════════════╝
local Visuals = PH:Tab("Visuals", "👁")

Visuals:Section("ESP")

Visuals:Toggle("Player ESP", false, function(on)
    -- your ESP logic
end)

Visuals:Toggle("Box ESP", false, function(on)
    -- box logic
end)

Visuals:Toggle("Name Tags", true, function(on)
    -- name tag logic
end)

Visuals:Toggle("Health Bars", true, function(on)
    -- health bar logic
end)

Visuals:Toggle("Distance", true, function(on)
    -- distance logic
end)

Visuals:Section("World")

Visuals:Toggle("Fullbright", false, function(on)
    local Lighting = game:GetService("Lighting")
    Lighting.Brightness = on and 2 or 1
    Lighting.ClockTime  = on and 14 or 14
    Lighting.FogEnd     = on and 10000 or 10000
    Lighting.GlobalShadows = not on
end)

Visuals:Slider("Field of View", 70, 120, 70, function(value)
    workspace.CurrentCamera.FieldOfView = value
end)

-- ╔══════════════════════════════════════╗
-- ║  MISC TAB                            ║
-- ╚══════════════════════════════════════╝
local Misc = PH:Tab("Misc", "◈")

Misc:Section("Utility")

local TargetBox = Misc:Textbox("Target Player", "Username...")

Misc:Button("Teleport to Player", function()
    local name   = TargetBox.Text
    local target = game:GetService("Players"):FindFirstChild(name)
    if target and target.Character and LP.Character then
        LP.Character:PivotTo(target.Character:GetPivot())
        PH:Notify("Teleport","Teleported to "..name,2,"success")
    else
        PH:Notify("Teleport","Player not found.",2,"error")
    end
end)

Misc:Button("Save Position", function()
    if LP.Character then
        -- savedPos = LP.Character:GetPivot()
        PH:Notify("Saved","Position saved.",2,"success")
    end
end)

Misc:Button("Load Position", function()
    -- if savedPos and LP.Character then LP.Character:PivotTo(savedPos) end
    PH:Notify("Loaded","Position loaded.",2)
end)

Misc:Section("Server")

Misc:Button("Server Hop", function()
    PH:Notify("Server Hop","Finding server...",3,"info")
    -- your server hop logic
end)

Misc:Button("Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)

-- ── Done! ─────────────────────────────────────────────────────
PH:Notify("Core","Game features loaded!",3,"success")
