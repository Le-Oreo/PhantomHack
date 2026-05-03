--[[
    Phantom Hack — BoogaBooga.lua
    Custom script for Booga Booga (Place ID: 11729688377)
    by Oreo
]]

local M  = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Le-Oreo/PhantomHack/main/PhantomHack.lua", true
))()
local PH = M.WaitForAuth()

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera     = workspace.CurrentCamera
local LP         = Players.LocalPlayer

-- ── Helpers ───────────────────────────────────────────────────
local function getChar(p) return (p or LP).Character end
local function getHum(p)  local c=getChar(p); return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot(p) local c=getChar(p); return c and c:FindFirstChild("HumanoidRootPart") end
local function getDist(p)
    local a,b = getRoot(LP), getRoot(p)
    if not a or not b then return math.huge end
    return (a.Position - b.Position).Magnitude
end
local function isAlive(p) local h=getHum(p); return h and h.Health > 0 end
local function isTeam(p)
    local myChar = getChar(LP); local theirChar = getChar(p)
    if not myChar or not theirChar then return false end
    local mine   = myChar:FindFirstChild("TribeName")
    local theirs = theirChar:FindFirstChild("TribeName")
    if not mine or not theirs then return false end
    return mine.Value ~= "" and mine.Value ~= "NoTribe" and mine.Value == theirs.Value
end

-- ══════════════════════════════════════════════════════════════
--  PLAYER ESP
-- ══════════════════════════════════════════════════════════════
local ESPState = {
    players=false, boxes=true, names=true, health=true,
    dist=true, tracers=false, teamCheck=true, maxDist=800,
    boxCol=Color3.fromRGB(255,50,50),
    ores=false, drops=false, mobs=false,
}
local ESPObjs = {}

local function w2s(pos)
    local sp,vis = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X,sp.Y), vis, sp.Z
end
local function mkLine(col,th)
    local l=Drawing.new("Line"); l.Color=col or Color3.new(1,1,1)
    l.Thickness=th or 1; l.Visible=false; return l
end
local function mkText(str,col,sz)
    local t=Drawing.new("Text"); t.Text=str or ""; t.Color=col or Color3.new(1,1,1)
    t.Size=sz or 13; t.Center=true; t.Outline=true
    t.OutlineColor=Color3.new(0,0,0); t.Visible=false; return t
end
local function mkESP(p)
    return {
        bT=mkLine(ESPState.boxCol), bB=mkLine(ESPState.boxCol),
        bL=mkLine(ESPState.boxCol), bR=mkLine(ESPState.boxCol),
        cTL1=mkLine(Color3.new(1,1,1),2), cTL2=mkLine(Color3.new(1,1,1),2),
        cTR1=mkLine(Color3.new(1,1,1),2), cTR2=mkLine(Color3.new(1,1,1),2),
        cBL1=mkLine(Color3.new(1,1,1),2), cBL2=mkLine(Color3.new(1,1,1),2),
        cBR1=mkLine(Color3.new(1,1,1),2), cBR2=mkLine(Color3.new(1,1,1),2),
        name   = mkText(p.Name, Color3.new(1,1,1), 13),
        dist   = mkText("", Color3.fromRGB(200,200,200), 11),
        hBG    = mkLine(Color3.new(0,0,0), 4),
        hBar   = mkLine(Color3.fromRGB(50,255,100), 3),
        tracer = mkLine(ESPState.boxCol, 1),
    }
end
local function hideESP(o) if not o then return end; for _,v in pairs(o) do pcall(function() v.Visible=false end) end end
local function freeESP(o) if not o then return end; for _,v in pairs(o) do pcall(function() v:Remove() end) end end

local function initESP(p)
    if p == LP then return end
    ESPObjs[p.Name] = mkESP(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        freeESP(ESPObjs[p.Name])
        ESPObjs[p.Name] = mkESP(p)
    end)
end
-- Init for everyone already in game
for _,p in ipairs(Players:GetPlayers()) do initESP(p) end
-- And anyone who joins later
Players.PlayerAdded:Connect(function(p) task.wait(1); initESP(p) end)
Players.PlayerRemoving:Connect(function(p)
    freeESP(ESPObjs[p.Name]); ESPObjs[p.Name] = nil
end)

local function getBounds(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return nil end
    local h    = math.max(hum.HipHeight*2+1, 3)
    local top, ton = w2s(hrp.Position + Vector3.new(0, h/2, 0))
    local bot, bon = w2s(hrp.Position - Vector3.new(0, h/2, 0))
    if not ton and not bon then return nil end
    local ht = math.abs(top.Y - bot.Y)
    if ht < 2 then return nil end
    local w  = ht * 0.45
    return {
        tl=Vector2.new(top.X-w,top.Y), tr=Vector2.new(top.X+w,top.Y),
        bl=Vector2.new(bot.X-w,bot.Y), br=Vector2.new(bot.X+w,bot.Y),
        tc=top, bc=bot, w=w, h=ht, hum=hum,
    }
end

-- Item ESP objects pool
local ItemDrawings = {}

-- Main ESP render loop
RunService.RenderStepped:Connect(function()
    -- ── Player ESP ────────────────────────────────────────────
    for _,p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        if not ESPObjs[p.Name] then initESP(p) end
        local o    = ESPObjs[p.Name]
        local char = getChar(p)
        local hum  = getHum(p)
        if not ESPState.players or not char or not hum
        or hum.Health <= 0
        or (ESPState.teamCheck and isTeam(p))
        or getDist(p) > ESPState.maxDist then
            hideESP(o); continue
        end
        local b = getBounds(char)
        if not b then hideESP(o); continue end
        local co = math.max(b.w, b.h) * 0.15

        -- Box lines
        local show = ESPState.boxes
        o.bT.From=b.tl; o.bT.To=b.tr; o.bT.Color=ESPState.boxCol; o.bT.Visible=show
        o.bB.From=b.bl; o.bB.To=b.br; o.bB.Color=ESPState.boxCol; o.bB.Visible=show
        o.bL.From=b.tl; o.bL.To=b.bl; o.bL.Color=ESPState.boxCol; o.bL.Visible=show
        o.bR.From=b.tr; o.bR.To=b.br; o.bR.Color=ESPState.boxCol; o.bR.Visible=show
        -- Corners
        o.cTL1.From=b.tl; o.cTL1.To=b.tl+Vector2.new(co,0);  o.cTL1.Visible=show
        o.cTL2.From=b.tl; o.cTL2.To=b.tl+Vector2.new(0,co);  o.cTL2.Visible=show
        o.cTR1.From=b.tr; o.cTR1.To=b.tr+Vector2.new(-co,0); o.cTR1.Visible=show
        o.cTR2.From=b.tr; o.cTR2.To=b.tr+Vector2.new(0,co);  o.cTR2.Visible=show
        o.cBL1.From=b.bl; o.cBL1.To=b.bl+Vector2.new(co,0);  o.cBL1.Visible=show
        o.cBL2.From=b.bl; o.cBL2.To=b.bl+Vector2.new(0,-co); o.cBL2.Visible=show
        o.cBR1.From=b.br; o.cBR1.To=b.br+Vector2.new(-co,0); o.cBR1.Visible=show
        o.cBR2.From=b.br; o.cBR2.To=b.br+Vector2.new(0,-co); o.cBR2.Visible=show
        -- Name
        if ESPState.names then
            o.name.Text=p.Name; o.name.Position=Vector2.new(b.tc.X, b.tc.Y-16); o.name.Visible=true
        else o.name.Visible=false end
        -- Distance
        if ESPState.dist then
            o.dist.Text="["..math.floor(getDist(p)).."m]"
            o.dist.Position=Vector2.new(b.bc.X, b.bc.Y+4); o.dist.Visible=true
        else o.dist.Visible=false end
        -- Health bar
        if ESPState.health then
            local pct = math.clamp(b.hum.Health/b.hum.MaxHealth, 0, 1)
            local bx  = b.tl.X - 5
            o.hBG.From=Vector2.new(bx,b.tl.Y); o.hBG.To=Vector2.new(bx,b.bl.Y); o.hBG.Visible=true
            o.hBar.From=Vector2.new(bx,b.bl.Y); o.hBar.To=Vector2.new(bx, b.bl.Y - b.h*pct)
            o.hBar.Color=Color3.new(math.clamp(2-pct*2,0,1), math.clamp(pct*2,0,1), 0)
            o.hBar.Visible=true
        else o.hBG.Visible=false; o.hBar.Visible=false end
        -- Tracer
        if ESPState.tracers then
            local vs=Camera.ViewportSize
            o.tracer.From=Vector2.new(vs.X/2,vs.Y); o.tracer.To=b.bc
            o.tracer.Color=ESPState.boxCol; o.tracer.Visible=true
        else o.tracer.Visible=false end
    end

    -- ── World ESP (ores, drops, mobs) ─────────────────────────
    -- Clean up stale drawings
    for id,entry in pairs(ItemDrawings) do
        if not entry.obj or not entry.obj.Parent then
            pcall(function() entry.lbl:Remove() end)
            ItemDrawings[id] = nil
        end
    end

    if ESPState.ores or ESPState.drops or ESPState.mobs then
        local hrp = getRoot(LP)
        for _,obj in ipairs(workspace:GetDescendants()) do
            if not obj:IsA("Model") and not obj:IsA("BasePart") then continue end

            local name = obj.Name
            local isOre  = ESPState.ores  and (
                name=="Rock" or name=="IronRock" or name=="GoldRock" or
                name=="DiamondRock" or name=="EmeraldRock" or name=="OnyxRock" or
                name=="CoalRock" or name=="CrystalRock"
            )
            local isMob  = ESPState.mobs  and (
                name=="Crab" or name=="Scorpion" or name=="Spider" or
                name=="BigCrab" or name=="God" or name=="GodBoss" or
                name=="Boar" or name=="Bird"
            )
            local isDrop = ESPState.drops and (
                name=="Dropped" or name=="ItemDrop" or
                (obj:IsA("Model") and obj:FindFirstChild("PickupPart"))
            )

            if not isOre and not isMob and not isDrop then continue end

            local id = tostring(obj)
            if not ItemDrawings[id] then
                local col = isOre  and Color3.fromRGB(255,210,50)
                         or isMob  and Color3.fromRGB(255,80,80)
                         or Color3.fromRGB(80,255,80)
                local lbl = mkText(name, col, 12)
                ItemDrawings[id] = {obj=obj, lbl=lbl}
            end

            local entry = ItemDrawings[id]
            local part  = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
            if not part then entry.lbl.Visible=false; continue end

            local sp, vis = w2s(part.Position)
            local d = hrp and (hrp.Position - part.Position).Magnitude or math.huge
            if vis and d < ESPState.maxDist then
                entry.lbl.Text     = name .. " [" .. math.floor(d) .. "m]"
                entry.lbl.Position = sp
                entry.lbl.Visible  = true
            else
                entry.lbl.Visible = false
            end
        end
    else
        for _,e in pairs(ItemDrawings) do pcall(function() e.lbl.Visible=false end) end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  MOVEMENT — Heartbeat reapply to bypass server correction
-- ══════════════════════════════════════════════════════════════
local MoveState = {
    speed=false, ws=16, jump=50,
    fly=false, flySpd=60,
    noclip=false, infJump=false,
}

-- Continuously reapply every frame so server can't override it
RunService.Heartbeat:Connect(function()
    local char = LP.Character; if not char then return end
    local hum  = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if MoveState.speed    then hum.WalkSpeed  = MoveState.ws    end
    if MoveState.jump~=50 then hum.JumpPower  = MoveState.jump  end
    if MoveState.noclip   then
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

local flyConn, flyBV, flyBG
local function stopFly()
    if flyConn then flyConn:Disconnect(); flyConn=nil end
    pcall(function() if flyBV then flyBV:Destroy(); flyBV=nil end end)
    pcall(function() if flyBG then flyBG:Destroy(); flyBG=nil end end)
    local hum = getHum(LP)
    if hum then hum.PlatformStand=false; hum.AutoRotate=true end
end

local function startFly()
    stopFly()
    if not MoveState.fly then return end
    local hrp = getRoot(LP); local hum = getHum(LP)
    if not hrp or not hum then return end
    hum.PlatformStand=true; hum.AutoRotate=false
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
    flyBV.Velocity = Vector3.new(0,0,0)
    flyBV.Parent   = hrp
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5)
    flyBG.P = 1e4; flyBG.CFrame = hrp.CFrame; flyBG.Parent = hrp
    flyConn = RunService.RenderStepped:Connect(function()
        if not MoveState.fly then stopFly(); return end
        local cam = Camera.CFrame; local v = Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then v=v+cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then v=v-cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then v=v-cam.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then v=v+cam.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space)       then v=v+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then v=v-Vector3.new(0,1,0) end
        if v.Magnitude > 0 then
            flyBV.Velocity = v.Unit * MoveState.flySpd
            flyBG.CFrame   = CFrame.new(hrp.Position, hrp.Position+v)
        else
            flyBV.Velocity = Vector3.new(0,0,0)
            flyBG.CFrame   = hrp.CFrame
        end
    end)
end

local ijConn
local function startIJ()
    if ijConn then ijConn:Disconnect() end
    if not MoveState.infJump then return end
    ijConn = UIS.JumpRequest:Connect(function()
        if not MoveState.infJump then ijConn:Disconnect(); return end
        local h = getHum(LP); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end

LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if MoveState.fly     then startFly() end
    if MoveState.infJump then startIJ()  end
end)

-- ══════════════════════════════════════════════════════════════
--  COMBAT
-- ══════════════════════════════════════════════════════════════

-- Kill Aura — fires tool every heartbeat for players in range
local KAState = {on=false, range=12, tribeCheck=true}
RunService.Heartbeat:Connect(function()
    if not KAState.on then return end
    local char = LP.Character; if not char then return end
    local tool = char:FindFirstChildOfClass("Tool"); if not tool then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p == LP or not isAlive(p) then continue end
        if KAState.tribeCheck and isTeam(p) then continue end
        if getDist(p) <= KAState.range then
            -- Face the target before activating
            local hrp = getRoot(LP); local tRoot = getRoot(p)
            if hrp and tRoot then
                hrp.CFrame = CFrame.lookAt(hrp.Position, tRoot.Position)
            end
            pcall(function() tool:Activate() end)
        end
    end
end)

-- Hitbox Expander
local HBState = {on=false, size=8}
local origHB  = {}
RunService.Heartbeat:Connect(function()
    if not HBState.on then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        local char = getChar(p); if not char then continue end
        local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
        if not origHB[p.Name] then origHB[p.Name] = hrp.Size end
        hrp.Size = Vector3.new(HBState.size, HBState.size, HBState.size)
    end
end)
local function resetHB()
    for name,sz in pairs(origHB) do
        local p = Players:FindFirstChild(name)
        if p then
            local hrp = getChar(p) and getChar(p):FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Size = sz end
        end
    end
    origHB = {}
end

-- ══════════════════════════════════════════════════════════════
--  AUTO HEAL — uses food item selected by the player in the UI
-- ══════════════════════════════════════════════════════════════
local HealState = {
    on        = false,
    threshold = 70,   -- heal when HP % drops below this
    foodName  = "",   -- set by the dropdown in the UI
}

-- Get list of food/consumable items currently in backpack
local function getFoodItems()
    local bp    = LP:FindFirstChild("Backpack")
    local char  = LP.Character
    local items = {}
    local seen  = {}
    local function scan(container)
        if not container then return end
        for _,tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") and not seen[tool.Name] then
                -- Check if it's likely food: has Hunger value, or name contains food words
                local hunger = tool:FindFirstChild("Hunger") or tool:FindFirstChild("HP")
                    or tool:FindFirstChild("Health") or tool:FindFirstChild("Food")
                local nameLower = tool.Name:lower()
                local isFoodName = nameLower:find("berry") or nameLower:find("meat")
                    or nameLower:find("fish") or nameLower:find("bread")
                    or nameLower:find("apple") or nameLower:find("mushroom")
                    or nameLower:find("mango") or nameLower:find("coconut")
                    or nameLower:find("banana") or nameLower:find("grape")
                    or nameLower:find("food") or nameLower:find("fruit")
                    or nameLower:find("steak") or nameLower:find("cooked")
                    or nameLower:find("raw") or nameLower:find("egg")
                if hunger or isFoodName then
                    table.insert(items, tool.Name)
                    seen[tool.Name] = true
                end
            end
        end
    end
    scan(bp)
    scan(char)
    if #items == 0 then table.insert(items, "-- No food found --") end
    return items
end

-- Perform heal using the selected food
local function doHeal()
    if not HealState.on then return end
    local hum = getHum(LP); if not hum then return end
    local pct = (hum.Health / hum.MaxHealth) * 100
    if pct >= HealState.threshold then return end
    if HealState.foodName == "" or HealState.foodName == "-- No food found --" then return end

    local bp   = LP:FindFirstChild("Backpack")
    local char = LP.Character
    local food = (bp and bp:FindFirstChild(HealState.foodName))
              or (char and char:FindFirstChild(HealState.foodName))
    if not food then return end

    -- Move to character, activate, move back
    local wasInBP = food.Parent == bp
    if wasInBP then food.Parent = char end
    task.wait(0.05)
    pcall(function() food:Activate() end)
    task.wait(0.3)
    if food and food.Parent == char and wasInBP then
        food.Parent = bp
    end
end

RunService.Heartbeat:Connect(function()
    if not HealState.on then return end
    local hum = getHum(LP); if not hum then return end
    local pct = (hum.Health / hum.MaxHealth) * 100
    if pct < HealState.threshold then
        doHeal()
    end
end)

-- ══════════════════════════════════════════════════════════════
--  AUTO FARM
-- ══════════════════════════════════════════════════════════════
local FarmState = {on=false, range=15}
local FARMABLE = {
    Rock=true, IronRock=true, GoldRock=true, DiamondRock=true,
    EmeraldRock=true, OnyxRock=true, CoalRock=true, CrystalRock=true,
    Tree=true, Bush=true, Log=true, Fiber=true, Plant=true,
}

RunService.Heartbeat:Connect(function()
    if not FarmState.on then return end
    local hrp = getRoot(LP); if not hrp then return end
    local char = LP.Character; if not char then return end
    local tool = char:FindFirstChildOfClass("Tool"); if not tool then return end

    local nearest, nearD = nil, math.huge
    for _,obj in ipairs(workspace:GetDescendants()) do
        if not obj:IsA("BasePart") then continue end
        local pName = obj.Parent and obj.Parent.Name or ""
        if not FARMABLE[obj.Name] and not FARMABLE[pName] then continue end
        local d = (hrp.Position - obj.Position).Magnitude
        if d < nearD then nearD=d; nearest=obj end
    end

    if nearest and nearD <= FarmState.range then
        -- Face and swing
        hrp.CFrame = CFrame.lookAt(hrp.Position, nearest.Position)
        pcall(function() tool:Activate() end)
    elseif nearest then
        -- Walk toward it
        local hum = getHum(LP)
        if hum then hum:MoveTo(nearest.Position) end
    end
end)

-- Auto Collect drops
local CollectState = {on=false, range=20}
RunService.Heartbeat:Connect(function()
    if not CollectState.on then return end
    local hrp = getRoot(LP); if not hrp then return end
    for _,obj in ipairs(workspace:GetDescendants()) do
        local isDrop = obj.Name=="Dropped" or obj.Name=="ItemDrop"
        if not isDrop then continue end
        local part = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
        if not part then continue end
        local d = (hrp.Position - part.Position).Magnitude
        if d <= CollectState.range then
            LP.Character:PivotTo(CFrame.new(part.Position + Vector3.new(0,3,0)))
            task.wait(0.05)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  BUILD TABS
-- ══════════════════════════════════════════════════════════════

-- ── VISUALS ──────────────────────────────────────────────────
local Vis = PH:Tab("Visuals","👁")
Vis:Section("Player ESP")
Vis:Toggle("Player ESP",false,function(on)
    ESPState.players=on
    if not on then for _,o in pairs(ESPObjs) do hideESP(o) end end
end)
Vis:Toggle("Boxes",true,function(on) ESPState.boxes=on end)
Vis:Toggle("Names",true,function(on) ESPState.names=on end)
Vis:Toggle("Health Bar",true,function(on) ESPState.health=on end)
Vis:Toggle("Distance",true,function(on) ESPState.dist=on end)
Vis:Toggle("Tracers",false,function(on) ESPState.tracers=on end)
Vis:Toggle("Tribe Check",true,function(on) ESPState.teamCheck=on end)
Vis:Slider("Max Distance",50,2000,800,function(v) ESPState.maxDist=v end)
Vis:Section("World ESP")
Vis:Toggle("Ore ESP",false,function(on)
    ESPState.ores=on
    if not on then for _,e in pairs(ItemDrawings) do pcall(function() e.lbl.Visible=false end) end end
end)
Vis:Toggle("Drop ESP",false,function(on)
    ESPState.drops=on
end)
Vis:Toggle("Mob ESP",false,function(on)
    ESPState.mobs=on
end)
Vis:Section("World")
Vis:Toggle("Fullbright",false,function(on)
    local L=game:GetService("Lighting"); L.Brightness=on and 2 or 1; L.GlobalShadows=not on
end)
Vis:Toggle("No Fog",false,function(on)
    game:GetService("Lighting").FogEnd=on and 9e9 or 100000
end)
Vis:Slider("Field of View",60,120,70,function(v) Camera.FieldOfView=v end)

-- ── COMBAT ────────────────────────────────────────────────────
local Cbt = PH:Tab("Combat","⚔")
Cbt:Section("Kill Aura")
Cbt:Toggle("Kill Aura",false,function(on) KAState.on=on end)
Cbt:Slider("Kill Aura Range",3,30,12,function(v) KAState.range=v end)
Cbt:Toggle("Tribe Check",true,function(on) KAState.tribeCheck=on end)
Cbt:Section("Hitbox Expander")
Cbt:Toggle("Hitbox Expander",false,function(on)
    HBState.on=on; if not on then resetHB() end
end)
Cbt:Slider("Hitbox Size",3,25,8,function(v) HBState.size=v end)
Cbt:Section("Auto Heal")
Cbt:Toggle("Auto Heal",false,function(on) HealState.on=on end)
Cbt:Slider("Heal Below HP %",10,99,70,function(v) HealState.threshold=v end)
-- Food picker — refreshes list from current inventory
local foodDropdown = Cbt:Dropdown("Food Item",{"-- Select --"},"-- Select --",function(v)
    HealState.foodName = v
end)
Cbt:Button("Refresh Food List",function()
    local foods = getFoodItems()
    -- Update the dropdown options (rebuild)
    HealState.foodName = foods[1] or ""
    PH:Notify("Food List",#foods.." item(s) found in inventory",3,"info")
    -- Show what was found
    for _,f in ipairs(foods) do
        PH:Notify("Food",f,2,"info")
    end
end)

-- ── MOVEMENT ─────────────────────────────────────────────────
local Mov = PH:Tab("Movement","⚡")
Mov:Section("Speed")
Mov:Toggle("Speed Modifier",false,function(on)
    MoveState.speed=on
    if not on then local h=getHum(LP);if h then h.WalkSpeed=16 end end
end)
Mov:Slider("Walk Speed",16,150,16,function(v) MoveState.ws=v end)
Mov:Slider("Jump Power",50,300,50,function(v) MoveState.jump=v end)
Mov:Section("Flight")
Mov:Toggle("Fly",false,function(on)
    MoveState.fly=on; if on then startFly() else stopFly() end
end)
Mov:Slider("Fly Speed",10,200,60,function(v) MoveState.flySpd=v end)
Mov:Section("Misc")
Mov:Toggle("Noclip",false,function(on) MoveState.noclip=on end)
Mov:Toggle("Infinite Jump",false,function(on) MoveState.infJump=on; startIJ() end)
Mov:Button("Reset Character",function() local h=getHum(LP);if h then h.Health=0 end end)

-- ── FARM ─────────────────────────────────────────────────────
local Frm = PH:Tab("Farm","🌾")
Frm:Section("Auto Farm")
Frm:Toggle("Auto Farm",false,function(on) FarmState.on=on end)
Frm:Slider("Farm Range",5,40,15,function(v) FarmState.range=v end)
Frm:Section("Auto Collect")
Frm:Toggle("Auto Collect",false,function(on) CollectState.on=on end)
Frm:Slider("Collect Range",5,30,20,function(v) CollectState.range=v end)

-- ── MISC ─────────────────────────────────────────────────────
local Misc = PH:Tab("Misc","◈")
Misc:Section("Teleport")
local tpBox = Misc:Textbox("Player Name","Username...")
Misc:Button("Teleport to Player",function()
    local t = Players:FindFirstChild(tpBox.Text)
    if t and t.Character and LP.Character then
        LP.Character:PivotTo(t.Character:GetPivot()*CFrame.new(3,0,0))
        PH:Notify("Teleport","Teleported to "..tpBox.Text,2,"success")
    else PH:Notify("Teleport","Player not found.",2,"error") end
end)
local savedCF=nil
Misc:Button("Save Position",function() local r=getRoot(LP);if r then savedCF=r.CFrame;PH:Notify("Position","Saved.",2,"success") end end)
Misc:Button("Load Position",function()
    if savedCF and LP.Character then LP.Character:PivotTo(savedCF);PH:Notify("Position","Loaded.",2,"success")
    else PH:Notify("Position","Nothing saved.",2,"error") end
end)
Misc:Section("Server")
Misc:Button("Rejoin",function() game:GetService("TeleportService"):Teleport(game.PlaceId,LP) end)
Misc:Button("Copy Place ID",function()
    pcall(function() if setclipboard then setclipboard(tostring(game.PlaceId)) end end)
    PH:Notify("Copied","Place ID: "..game.PlaceId,2,"success")
end)

PH:SelectFirst()
PH:Notify("Booga Booga","Script loaded  •  "..PH.Tier,4,"success")
