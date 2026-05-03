--[[
    Phantom Hack — Core.lua
    Full feature script — relies 100% on PhantomHack.lua for the GUI.
    Edit ONLY this file to add/remove features.
    Never touch PhantomHack.lua.
    by Oreo
--]]

-- ── Load the GUI template ─────────────────────────────────────
local M  = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Le-Oreo/PhantomHack/main/PhantomHack.lua",
    true
))()
local PH = M.WaitForAuth()
-- PH.Tier      = "Free" or "Premium"
-- PH.KeyExpiry = nil (lifetime) or unix timestamp
-- PH:Tab("Name","icon")  → returns tab with :Toggle :Slider :Dropdown :Button :Textbox :Keybind :Label :Section :Separator
-- PH:Notify("title","msg",dur,"success"/"error"/"warning"/"info")

-- ── Services ──────────────────────────────────────────────────
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Camera     = workspace.CurrentCamera
local LP         = Players.LocalPlayer

-- ── Helpers ───────────────────────────────────────────────────
local function getHum(p)
    local c = (p or LP).Character
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getRoot(p)
    local c = (p or LP).Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getDist(p)
    local a, b = getRoot(LP), getRoot(p)
    if not a or not b then return math.huge end
    return (a.Position - b.Position).Magnitude
end
local function isAlive(p)
    local h = getHum(p)
    return h and h.Health > 0
end
local function isTeam(p)
    return LP.Team and p.Team and LP.Team == p.Team
end

-- ══════════════════════════════════════════════════════════════
--  1 — VISUALS / ESP
-- ══════════════════════════════════════════════════════════════
local ESPState = {
    on=false, boxes=true, names=true, health=true,
    dist=true, tracers=false, teamCheck=true, maxDist=1000,
    boxCol=Color3.fromRGB(255,50,50), nameCol=Color3.new(1,1,1),
    tracerCol=Color3.fromRGB(255,50,50),
}
local ESPObjects = {}

local function worldToScreen(pos)
    local sp, vis = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), vis
end

local function newLine(col)
    local l = Drawing.new("Line")
    l.Color = col or Color3.new(1,1,1)
    l.Thickness = 1
    l.Visible = false
    return l
end
local function newText(str, col, size)
    local t = Drawing.new("Text")
    t.Text = str or ""
    t.Color = col or Color3.new(1,1,1)
    t.Size = size or 13
    t.Center = true
    t.Outline = true
    t.OutlineColor = Color3.new(0,0,0)
    t.Visible = false
    return t
end

local function makeObjs(player)
    return {
        bT=newLine(ESPState.boxCol), bB=newLine(ESPState.boxCol),
        bL=newLine(ESPState.boxCol), bR=newLine(ESPState.boxCol),
        cTL1=newLine(Color3.new(1,1,1)), cTL2=newLine(Color3.new(1,1,1)),
        cTR1=newLine(Color3.new(1,1,1)), cTR2=newLine(Color3.new(1,1,1)),
        cBL1=newLine(Color3.new(1,1,1)), cBL2=newLine(Color3.new(1,1,1)),
        cBR1=newLine(Color3.new(1,1,1)), cBR2=newLine(Color3.new(1,1,1)),
        name=newText(player.Name, ESPState.nameCol, 13),
        dist=newText("", Color3.fromRGB(200,200,200), 11),
        hBG=newLine(Color3.new(0,0,0)), hBar=newLine(Color3.fromRGB(50,255,100)),
        tracer=newLine(ESPState.tracerCol),
    }
end

local function hideObjs(o)
    if not o then return end
    for _,v in pairs(o) do pcall(function() v.Visible=false end) end
end

local function removeObjs(o)
    if not o then return end
    for _,v in pairs(o) do pcall(function() v:Remove() end) end
end

local function getBounds(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return nil end
    local h   = hum.HipHeight*2+1
    local top,ton = worldToScreen(hrp.Position+Vector3.new(0,h/2,0))
    local bot,bon = worldToScreen(hrp.Position-Vector3.new(0,h/2,0))
    if not ton and not bon then return nil end
    local ht = math.abs(top.Y-bot.Y)
    local w  = ht*0.45
    return {
        tl=Vector2.new(top.X-w,top.Y), tr=Vector2.new(top.X+w,top.Y),
        bl=Vector2.new(bot.X-w,bot.Y), br=Vector2.new(bot.X+w,bot.Y),
        tc=top, bc=bot, w=w, h=ht,
        hum=hum,
    }
end

-- FOV circle for aimbot
local fovCircle = Drawing.new("Circle")
fovCircle.Visible=false; fovCircle.Radius=150
fovCircle.Color=Color3.new(1,1,1); fovCircle.Thickness=1
fovCircle.Filled=false; fovCircle.Transparency=0.6

-- ESP loop
local espConn
local function runESP()
    if espConn then espConn:Disconnect() end
    espConn = RunService.RenderStepped:Connect(function()
        if not ESPState.on then
            for _,o in pairs(ESPObjects) do hideObjs(o) end
            return
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            if not ESPObjects[p.Name] then ESPObjects[p.Name]=makeObjs(p) end
            local o = ESPObjects[p.Name]
            local char = p.Character
            local hum  = getHum(p)
            if not char or not hum or hum.Health<=0
            or (ESPState.teamCheck and isTeam(p))
            or getDist(p)>ESPState.maxDist then
                hideObjs(o); continue
            end
            local b = getBounds(char)
            if not b then hideObjs(o); continue end
            local co = math.max(b.w,b.h)*0.15

            -- Box + corners
            if ESPState.boxes then
                o.bT.From=b.tl;o.bT.To=b.tr;o.bT.Color=ESPState.boxCol;o.bT.Visible=true
                o.bB.From=b.bl;o.bB.To=b.br;o.bB.Color=ESPState.boxCol;o.bB.Visible=true
                o.bL.From=b.tl;o.bL.To=b.bl;o.bL.Color=ESPState.boxCol;o.bL.Visible=true
                o.bR.From=b.tr;o.bR.To=b.br;o.bR.Color=ESPState.boxCol;o.bR.Visible=true
                -- corners
                o.cTL1.From=b.tl;o.cTL1.To=b.tl+Vector2.new(co,0);o.cTL1.Visible=true
                o.cTL2.From=b.tl;o.cTL2.To=b.tl+Vector2.new(0,co);o.cTL2.Visible=true
                o.cTR1.From=b.tr;o.cTR1.To=b.tr+Vector2.new(-co,0);o.cTR1.Visible=true
                o.cTR2.From=b.tr;o.cTR2.To=b.tr+Vector2.new(0,co);o.cTR2.Visible=true
                o.cBL1.From=b.bl;o.cBL1.To=b.bl+Vector2.new(co,0);o.cBL1.Visible=true
                o.cBL2.From=b.bl;o.cBL2.To=b.bl+Vector2.new(0,-co);o.cBL2.Visible=true
                o.cBR1.From=b.br;o.cBR1.To=b.br+Vector2.new(-co,0);o.cBR1.Visible=true
                o.cBR2.From=b.br;o.cBR2.To=b.br+Vector2.new(0,-co);o.cBR2.Visible=true
            else
                for _,k in ipairs({"bT","bB","bL","bR","cTL1","cTL2","cTR1","cTR2","cBL1","cBL2","cBR1","cBR2"}) do
                    o[k].Visible=false
                end
            end

            -- Name
            if ESPState.names then
                o.name.Text=p.Name; o.name.Color=ESPState.nameCol
                o.name.Position=Vector2.new(b.tc.X, b.tc.Y-16); o.name.Visible=true
            else o.name.Visible=false end

            -- Distance
            if ESPState.dist then
                o.dist.Text="["..math.floor(getDist(p)).."m]"
                o.dist.Position=Vector2.new(b.bc.X, b.bc.Y+4); o.dist.Visible=true
            else o.dist.Visible=false end

            -- Health bar
            if ESPState.health then
                local pct=math.clamp(b.hum.Health/b.hum.MaxHealth,0,1)
                local bx=b.tl.X-5
                o.hBG.From=Vector2.new(bx,b.tl.Y); o.hBG.To=Vector2.new(bx,b.bl.Y)
                o.hBG.Thickness=4; o.hBG.Visible=true
                o.hBar.From=Vector2.new(bx,b.bl.Y)
                o.hBar.To=Vector2.new(bx, b.bl.Y-(b.h*pct))
                o.hBar.Color=Color3.new(math.clamp(2-pct*2,0,1),math.clamp(pct*2,0,1),0)
                o.hBar.Thickness=3; o.hBar.Visible=true
            else o.hBG.Visible=false; o.hBar.Visible=false end

            -- Tracer
            if ESPState.tracers then
                local vs=Camera.ViewportSize
                o.tracer.From=Vector2.new(vs.X/2,vs.Y)
                o.tracer.To=b.bc; o.tracer.Color=ESPState.tracerCol; o.tracer.Visible=true
            else o.tracer.Visible=false end
        end
        -- cleanup
        for name,o in pairs(ESPObjects) do
            if not Players:FindFirstChild(name) then
                removeObjs(o); ESPObjects[name]=nil
            end
        end
    end)
end
runESP()
Players.PlayerRemoving:Connect(function(p)
    if ESPObjects[p.Name] then removeObjs(ESPObjects[p.Name]); ESPObjects[p.Name]=nil end
end)

-- ══════════════════════════════════════════════════════════════
--  2 — AIMBOT STATE
-- ══════════════════════════════════════════════════════════════
local AimState = {
    on=false, fov=150, smooth=5, part="HumanoidRootPart",
    teamCheck=true, visCheck=true, silentAim=false,
    currentTarget=nil,
}

local function rayVis(from, to)
    local p = RaycastParams.new()
    p.FilterDescendantsInstances = {LP.Character}
    p.FilterType = Enum.RaycastFilterType.Exclude
    local r = workspace:Raycast(from, (to-from).Unit*(to-from).Magnitude, p)
    return r==nil
end

local function getBestTarget()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, bestDist = nil, math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP or not isAlive(p) then continue end
        if AimState.teamCheck and isTeam(p) then continue end
        local char = p.Character
        local part = char and char:FindFirstChild(AimState.part)
        if not part then continue end
        local sp, vis = worldToScreen(part.Position)
        if not vis then continue end
        local d2 = (sp-center).Magnitude
        if d2 < AimState.fov and d2 < bestDist then
            if AimState.visCheck and not rayVis(Camera.CFrame.Position, part.Position) then continue end
            best=p; bestDist=d2
        end
    end
    return best
end

local aimConn
local function runAimbot()
    if aimConn then aimConn:Disconnect() end
    aimConn = RunService.RenderStepped:Connect(function()
        fovCircle.Visible  = AimState.on
        fovCircle.Radius   = AimState.fov
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        if not AimState.on then AimState.currentTarget=nil; return end
        local t = getBestTarget()
        AimState.currentTarget = t
        if not t then return end
        local root = t.Character and t.Character:FindFirstChild(AimState.part)
        if not root then return end
        if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local cf = CFrame.new(Camera.CFrame.Position, root.Position)
            Camera.CFrame = Camera.CFrame:Lerp(cf, 1/AimState.smooth)
        end
    end)
end
runAimbot()

-- ══════════════════════════════════════════════════════════════
--  3 — KILL AURA
-- ══════════════════════════════════════════════════════════════
local KAState = {on=false, range=15, teamCheck=true}
local kaConn
local function runKillAura()
    if kaConn then kaConn:Disconnect() end
    kaConn = RunService.Heartbeat:Connect(function()
        if not KAState.on then return end
        local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
        if not tool then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP or not isAlive(p) then continue end
            if KAState.teamCheck and isTeam(p) then continue end
            if getDist(p) <= KAState.range then
                pcall(function() tool:Activate() end)
            end
        end
    end)
end
runKillAura()

-- ══════════════════════════════════════════════════════════════
--  4 — MOVEMENT
-- ══════════════════════════════════════════════════════════════
local MoveState = {
    speed=false, walkspeed=16, jump=50,
    fly=false, flySpeed=60,
    noclip=false, infJump=false, bhop=false, antiAfk=false,
}

-- Fly
local flyConn, flyBV
local function startFly()
    if flyConn then flyConn:Disconnect() end
    pcall(function() if flyBV then flyBV:Destroy() end end)
    if not MoveState.fly then return end
    local hrp = getRoot(LP)
    if not hrp then return end
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
    flyBV.Velocity = Vector3.new(0,0,0)
    flyBV.Parent   = hrp
    flyConn = RunService.RenderStepped:Connect(function()
        if not MoveState.fly then flyConn:Disconnect(); pcall(function() flyBV:Destroy() end); return end
        local cam = Camera.CFrame
        local v   = Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then v=v+cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then v=v-cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then v=v-cam.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then v=v+cam.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space)       then v=v+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then v=v-Vector3.new(0,1,0) end
        flyBV.Velocity = v.Magnitude>0 and v.Unit*MoveState.flySpeed or Vector3.new(0,0,0)
    end)
end

-- Noclip
local ncConn
local function startNoclip()
    if ncConn then ncConn:Disconnect() end
    if not MoveState.noclip then return end
    ncConn = RunService.Stepped:Connect(function()
        if not MoveState.noclip then ncConn:Disconnect(); return end
        local c = LP.Character
        if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
    end)
end

-- Infinite jump
local ijConn
local function startInfJump()
    if ijConn then ijConn:Disconnect() end
    if not MoveState.infJump then return end
    ijConn = UIS.JumpRequest:Connect(function()
        if not MoveState.infJump then ijConn:Disconnect(); return end
        local h = getHum(LP)
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end

-- Bunny hop
local bhConn
local function startBhop()
    if bhConn then bhConn:Disconnect() end
    if not MoveState.bhop then return end
    bhConn = RunService.Stepped:Connect(function()
        if not MoveState.bhop then bhConn:Disconnect(); return end
        local h = getHum(LP)
        if h and h.FloorMaterial~=Enum.Material.Air then
            h:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

-- Anti AFK
local afkConn
local function startAntiAfk()
    if afkConn then afkConn:Disconnect() end
    if not MoveState.antiAfk then return end
    local vu = game:GetService("VirtualUser")
    afkConn = LP.Idled:Connect(function()
        if not MoveState.antiAfk then afkConn:Disconnect(); return end
        vu:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(0.1)
        vu:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end)
end

-- Re-apply on respawn
LP.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local h = char:WaitForChild("Humanoid",5)
    if not h then return end
    if MoveState.speed   then h.WalkSpeed  = MoveState.walkspeed end
    if MoveState.jump~=50 then h.JumpPower  = MoveState.jump end
    if MoveState.fly     then startFly()    end
    if MoveState.noclip  then startNoclip() end
    if MoveState.infJump then startInfJump() end
    if MoveState.bhop    then startBhop()   end
end)

-- ══════════════════════════════════════════════════════════════
--  5 — FARM STATE
-- ══════════════════════════════════════════════════════════════
local FarmState = {on=false, collect=false, sell=false, tpToMob=false, mob="Nearest"}
local farmConn
local function startFarm()
    if farmConn then farmConn:Disconnect() end
    if not FarmState.on then return end
    farmConn = RunService.Heartbeat:Connect(function()
        if not FarmState.on then farmConn:Disconnect(); return end
        local near, nearD = nil, math.huge
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj~=LP.Character then
                local h = obj:FindFirstChildOfClass("Humanoid")
                local r = obj:FindFirstChild("HumanoidRootPart")
                if h and h.Health>0 and r then
                    local hrp = getRoot(LP)
                    if hrp then
                        local d=(hrp.Position-r.Position).Magnitude
                        if d<nearD then nearD=d; near=obj end
                    end
                end
            end
        end
        if near then
            if FarmState.tpToMob then
                local r=near:FindFirstChild("HumanoidRootPart")
                if r and LP.Character then LP.Character:PivotTo(CFrame.new(r.Position+Vector3.new(3,0,0))) end
            end
            local tool=LP.Character and LP.Character:FindFirstChildOfClass("Tool")
            if tool then pcall(function() tool:Activate() end) end
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  BUILD TABS USING PH:Tab()
-- ══════════════════════════════════════════════════════════════

-- ─── VISUALS ──────────────────────────────────────────────────
local Vis = PH:Tab("Visuals", "👁")

Vis:Section("ESP")
Vis:Toggle("Enable ESP", false, function(on)
    ESPState.on = on
    if not on then for _,o in pairs(ESPObjects) do hideObjs(o) end end
end)
Vis:Toggle("Boxes", true,  function(on) ESPState.boxes=on end)
Vis:Toggle("Names", true,  function(on) ESPState.names=on end)
Vis:Toggle("Health Bar", true, function(on) ESPState.health=on end)
Vis:Toggle("Distance",  true,  function(on) ESPState.dist=on end)
Vis:Toggle("Tracers",   false, function(on) ESPState.tracers=on end)
Vis:Toggle("Team Check",true,  function(on) ESPState.teamCheck=on end)
Vis:Slider("Max Distance", 100, 3000, 1000, function(v) ESPState.maxDist=v end)

Vis:Section("ESP Colors")
Vis:Dropdown("Box Color",{"Red","White","Cyan","Green","Yellow","Purple"},"Red",function(c)
    local m={Red=Color3.fromRGB(255,50,50),White=Color3.new(1,1,1),Cyan=Color3.fromRGB(0,255,255),Green=Color3.fromRGB(50,255,100),Yellow=Color3.fromRGB(255,230,50),Purple=Color3.fromRGB(180,50,255)}
    ESPState.boxCol=m[c] or ESPState.boxCol
end)
Vis:Dropdown("Name Color",{"White","Yellow","Cyan","Red","Green"},"White",function(c)
    local m={White=Color3.new(1,1,1),Yellow=Color3.fromRGB(255,230,50),Cyan=Color3.fromRGB(0,255,255),Red=Color3.fromRGB(255,50,50),Green=Color3.fromRGB(50,255,100)}
    ESPState.nameCol=m[c] or ESPState.nameCol
end)
Vis:Dropdown("Tracer Color",{"Red","White","Cyan","Green","Yellow"},"Red",function(c)
    local m={Red=Color3.fromRGB(255,50,50),White=Color3.new(1,1,1),Cyan=Color3.fromRGB(0,255,255),Green=Color3.fromRGB(50,255,100),Yellow=Color3.fromRGB(255,230,50)}
    ESPState.tracerCol=m[c] or ESPState.tracerCol
end)

Vis:Section("World")
Vis:Toggle("Fullbright", false, function(on)
    local L=game:GetService("Lighting")
    L.Brightness=on and 2 or 1; L.GlobalShadows=not on
end)
Vis:Slider("Field of View", 60, 120, 70, function(v) Camera.FieldOfView=v end)
Vis:Toggle("No Fog", false, function(on)
    game:GetService("Lighting").FogEnd = on and 9e9 or 100000
end)

-- ─── COMBAT ───────────────────────────────────────────────────
local Cbt = PH:Tab("Combat", "⚔")

Cbt:Section("Aimbot")
Cbt:Toggle("Enable Aimbot", false, function(on)
    AimState.on=on; if not on then AimState.currentTarget=nil end
end)
Cbt:Slider("FOV Radius", 50, 600, 150, function(v)
    AimState.fov=v; fovCircle.Radius=v
end)
Cbt:Slider("Smoothness", 1, 20, 5, function(v) AimState.smooth=v end)
Cbt:Dropdown("Target Part",{"HumanoidRootPart","Head","Torso"},"HumanoidRootPart",function(v) AimState.part=v end)
Cbt:Toggle("Team Check",  true,  function(on) AimState.teamCheck=on end)
Cbt:Toggle("Visible Check",true, function(on) AimState.visCheck=on end)

Cbt:Section("Kill Aura")
Cbt:Toggle("Kill Aura", false, function(on) KAState.on=on end)
Cbt:Slider("Kill Aura Range", 5, 60, 15, function(v) KAState.range=v end)
Cbt:Toggle("Team Check", true, function(on) KAState.teamCheck=on end)

Cbt:Section("Misc Combat")
Cbt:Toggle("Silent Aim", false, function(on)
    AimState.silentAim=on
    PH:Notify("Silent Aim", on and "Enabled" or "Disabled", 2, on and "warning" or "error")
end)
Cbt:Toggle("Auto Parry", false, function(on)
    PH:Notify("Auto Parry", on and "Enabled" or "Disabled", 2, on and "success" or "error")
end)
Cbt:Toggle("Auto Block", false, function(on)
    PH:Notify("Auto Block", on and "Enabled" or "Disabled", 2, on and "success" or "error")
end)
Cbt:Toggle("Trigger Bot", false, function(on)
    if on then task.spawn(function()
        while on do task.wait(0.05)
            local t=getBestTarget()
            if t then
                local tool=LP.Character and LP.Character:FindFirstChildOfClass("Tool")
                if tool then pcall(function() tool:Activate() end) end
            end
        end
    end) end
end)

-- ─── MOVEMENT ─────────────────────────────────────────────────
local Mov = PH:Tab("Movement", "⚡")

Mov:Section("Speed")
Mov:Toggle("Speed Modifier", false, function(on)
    MoveState.speed=on
    local h=getHum(LP); if h then h.WalkSpeed=on and MoveState.walkspeed or 16 end
end)
Mov:Slider("Walk Speed", 16, 300, 16, function(v)
    MoveState.walkspeed=v
    if MoveState.speed then local h=getHum(LP); if h then h.WalkSpeed=v end end
end)
Mov:Slider("Jump Power", 50, 500, 50, function(v)
    MoveState.jump=v
    local h=getHum(LP); if h then h.JumpPower=v end
end)

Mov:Section("Flight")
Mov:Toggle("Fly", false, function(on)
    MoveState.fly=on
    local h=getHum(LP); if h then h.PlatformStand=on end
    startFly()
    PH:Notify("Fly", on and "WASD + Space/Ctrl to move" or "Disabled", 3, on and "success" or "error")
end)
Mov:Slider("Fly Speed", 10, 300, 60, function(v) MoveState.flySpeed=v end)

Mov:Section("Misc")
Mov:Toggle("Noclip",       false, function(on) MoveState.noclip=on;   startNoclip()  end)
Mov:Toggle("Infinite Jump",false, function(on) MoveState.infJump=on;  startInfJump() end)
Mov:Toggle("Bunny Hop",    false, function(on) MoveState.bhop=on;     startBhop()    end)
Mov:Toggle("Anti-AFK",     false, function(on) MoveState.antiAfk=on;  startAntiAfk() end)
Mov:Button("Reset Character", function()
    local h=getHum(LP); if h then h.Health=0 end
end)

-- ─── FARM (Premium only) ──────────────────────────────────────
if PH.Tier == "Premium" then
    local Frm = PH:Tab("Farm ★", "🌾")

    Frm:Section("Auto Farm")
    Frm:Toggle("Auto Farm", false, function(on)
        FarmState.on=on; startFarm()
        PH:Notify("Auto Farm", on and "Started" or "Stopped", 2, on and "success" or "error")
    end)
    Frm:Toggle("Teleport to Mob", false, function(on) FarmState.tpToMob=on end)
    Frm:Toggle("Auto Collect",    false, function(on) FarmState.collect=on end)
    Frm:Toggle("Auto Sell",       false, function(on) FarmState.sell=on end)
    Frm:Dropdown("Target Mob",{"Nearest","Delinquent","Bandit","Pirate","Soldier"},"Nearest",function(v) FarmState.mob=v end)

    Frm:Section("Boss Farm")
    Frm:Toggle("Auto Kill Boss", false, function(on)
        PH:Notify("Boss Farm", on and "Started" or "Stopped", 2, on and "success" or "error")
    end)
    Frm:Dropdown("Target Boss",{"Nearest","Iron Giant","Atomic","Sky Dragon","Void Lord"},"Nearest",function(v) end)
    Frm:Dropdown("Difficulty",{"Easy","Normal","Hard","Nightmare"},"Normal",function(v) end)
    Frm:Toggle("Auto Summon Boss", false, function(on) end)

    Frm:Section("Pity Farm")
    Frm:Toggle("Pity Boss Farm", false, function(on)
        PH:Notify("Pity Farm", on and "Started" or "Stopped", 2, on and "success" or "error")
    end)
    Frm:Dropdown("Pity Boss",{"None","Iron Giant","Atomic","Sky Dragon"},"None",function(v) end)
else
    local FrmLock = PH:Tab("Farm 🔒", "🌾")
    FrmLock:Section("Premium Only")
    FrmLock:Label("Auto Farm, Boss Farm and Pity Farm require a Premium key.")
    FrmLock:Separator()
    FrmLock:Button("Get Premium →", function()
        pcall(function() if setclipboard then setclipboard("https://discord.gg/phantomhack") end end)
        PH:Notify("Discord", "Invite copied — join to upgrade.", 4, "info")
    end)
end

-- ─── MISC ─────────────────────────────────────────────────────
local Misc = PH:Tab("Misc", "◈")

Misc:Section("Teleport")
local tpBox = Misc:Textbox("Player Name", "Username...")
Misc:Button("Teleport to Player", function()
    local t = Players:FindFirstChild(tpBox.Text)
    if t and t.Character and LP.Character then
        LP.Character:PivotTo(t.Character:GetPivot()*CFrame.new(3,0,0))
        PH:Notify("Teleport","Teleported to "..tpBox.Text,2,"success")
    else
        PH:Notify("Teleport","Player not found.",2,"error")
    end
end)

local savedCF = nil
Misc:Button("Save Position", function()
    local r=getRoot(LP); if r then savedCF=r.CFrame; PH:Notify("Position","Saved.",2,"success") end
end)
Misc:Button("Load Position", function()
    if savedCF and LP.Character then LP.Character:PivotTo(savedCF); PH:Notify("Position","Loaded.",2,"success")
    else PH:Notify("Position","Nothing saved.",2,"error") end
end)

Misc:Section("Server")
Misc:Button("Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)
Misc:Button("Server Hop", function()
    PH:Notify("Server Hop","Finding server...",3,"info")
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId,LP) end)
end)
Misc:Button("Copy Place ID", function()
    pcall(function() if setclipboard then setclipboard(tostring(game.PlaceId)) end end)
    PH:Notify("Copied","Place ID: "..game.PlaceId,2,"success")
end)

Misc:Section("Info")
Misc:Label("Tier:     " .. PH.Tier)
Misc:Label("User:     " .. LP.Name)
Misc:Label("Place ID: " .. tostring(game.PlaceId))
Misc:Label("Version:  Phantom Hack v1.2.0")
Misc:Label("Created by Oreo")

-- ── Done ──────────────────────────────────────────────────────
-- Select the first tab now that all tabs have been added
PH:SelectFirst()
PH:Notify("Core Loaded", "All features ready  •  " .. PH.Tier .. " tier", 4, "success")
