--[[
    Phantom Hack — Core.lua
    Universal loader + game detection.
    Automatically loads the correct game script after key auth.
    Players only ever run this one file.
    by Oreo
]]

local RAW = "https://raw.githubusercontent.com/Le-Oreo/PhantomHack/main/"

-- ── Game registry ─────────────────────────────────────────────
-- Add more game-specific scripts here as you make them
local GAME_SCRIPTS = {
    [11729688377] = RAW .. "BoogaBooga.lua",  -- Booga Booga
    -- [PLACE_ID]  = RAW .. "YourGame.lua",   -- add more here
}

-- ── Check if this game has a custom script ────────────────────
local customScript = GAME_SCRIPTS[game.PlaceId]

if customScript then
    -- Custom game detected — hand off entirely to that script
    -- (it loads PhantomHack.lua itself and builds its own tabs)
    print("[Phantom Hack] Detected game "..game.PlaceId.." — loading custom script")
    local ok, err = pcall(function()
        loadstring(game:HttpGet(customScript, true))()
    end)
    if not ok then
        warn("[Phantom Hack] Custom script failed: "..tostring(err))
        warn("[Phantom Hack] Falling back to universal...")
        -- Fall through to universal below
    else
        return  -- custom script loaded successfully, stop here
    end
end

-- ── Universal script (no custom game found) ───────────────────
print("[Phantom Hack] No custom script for place "..game.PlaceId.." — loading universal")

local M  = loadstring(game:HttpGet(RAW.."PhantomHack.lua", true))()
local PH = M.WaitForAuth()

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Camera     = workspace.CurrentCamera
local LP         = Players.LocalPlayer

local function getHum(p)  local c=(p or LP).Character; return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot(p) local c=(p or LP).Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function getDist(p) local a,b=getRoot(LP),getRoot(p); if not a or not b then return math.huge end; return (a.Position-b.Position).Magnitude end
local function isAlive(p) local h=getHum(p); return h and h.Health>0 end
local function isTeam(p)  return LP.Team and p.Team and LP.Team==p.Team end

-- ══════════════════════════════════════════════════════════════
--  ESP
-- ══════════════════════════════════════════════════════════════
local ESPState = {
    on=false, boxes=true, names=true, health=true,
    dist=true, tracers=false, teamCheck=true, maxDist=1000,
    boxCol=Color3.fromRGB(255,50,50),
    nameCol=Color3.new(1,1,1),
    tracerCol=Color3.fromRGB(255,50,50),
}
local ESPObjects = {}

local function w2s(pos)
    local sp,vis = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X,sp.Y), vis
end
local function newLine(col,th)
    local l=Drawing.new("Line"); l.Color=col or Color3.new(1,1,1); l.Thickness=th or 1; l.Visible=false; return l
end
local function newText(str,col,sz)
    local t=Drawing.new("Text"); t.Text=str or ""; t.Color=col or Color3.new(1,1,1)
    t.Size=sz or 13; t.Center=true; t.Outline=true; t.OutlineColor=Color3.new(0,0,0); t.Visible=false; return t
end
local function makeESP(p)
    return {
        bT=newLine(ESPState.boxCol),bB=newLine(ESPState.boxCol),
        bL=newLine(ESPState.boxCol),bR=newLine(ESPState.boxCol),
        cTL1=newLine(Color3.new(1,1,1),2),cTL2=newLine(Color3.new(1,1,1),2),
        cTR1=newLine(Color3.new(1,1,1),2),cTR2=newLine(Color3.new(1,1,1),2),
        cBL1=newLine(Color3.new(1,1,1),2),cBL2=newLine(Color3.new(1,1,1),2),
        cBR1=newLine(Color3.new(1,1,1),2),cBR2=newLine(Color3.new(1,1,1),2),
        name=newText(p.Name,ESPState.nameCol,13),
        dist=newText("",Color3.fromRGB(200,200,200),11),
        hBG=newLine(Color3.new(0,0,0),4),
        hBar=newLine(Color3.fromRGB(50,255,100),3),
        tracer=newLine(ESPState.tracerCol,1),
    }
end
local function hideESP(o) if not o then return end; for _,v in pairs(o) do pcall(function() v.Visible=false end) end end
local function removeESP(o) if not o then return end; for _,v in pairs(o) do pcall(function() v:Remove() end) end end

local function getBounds(char)
    local hrp=char:FindFirstChild("HumanoidRootPart")
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return nil end
    local h=hum.HipHeight*2+1
    local top,ton=w2s(hrp.Position+Vector3.new(0,h/2,0))
    local bot,bon=w2s(hrp.Position-Vector3.new(0,h/2,0))
    if not ton and not bon then return nil end
    local ht=math.abs(top.Y-bot.Y); local w=ht*0.45
    return {tl=Vector2.new(top.X-w,top.Y),tr=Vector2.new(top.X+w,top.Y),
            bl=Vector2.new(bot.X-w,bot.Y),br=Vector2.new(bot.X+w,bot.Y),
            tc=top,bc=bot,w=w,h=ht,hum=hum}
end

-- init ESP for all current players and all future ones
local function initESP(p)
    if p==LP then return end
    ESPObjects[p.Name] = makeESP(p)
    -- re-init on character added for this player
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if ESPObjects[p.Name] then removeESP(ESPObjects[p.Name]) end
        ESPObjects[p.Name] = makeESP(p)
    end)
end
for _,p in ipairs(Players:GetPlayers()) do initESP(p) end
Players.PlayerAdded:Connect(initESP)
Players.PlayerRemoving:Connect(function(p)
    if ESPObjects[p.Name] then removeESP(ESPObjects[p.Name]); ESPObjects[p.Name]=nil end
end)

local espConn
local function runESP()
    if espConn then espConn:Disconnect() end
    espConn=RunService.RenderStepped:Connect(function()
        if not ESPState.on then for _,o in pairs(ESPObjects) do hideESP(o) end; return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local o=ESPObjects[p.Name]
            if not o then initESP(p); o=ESPObjects[p.Name] end
            local char=p.Character
            local hum=getHum(p)
            if not char or not hum or hum.Health<=0
            or (ESPState.teamCheck and isTeam(p))
            or getDist(p)>ESPState.maxDist then hideESP(o); continue end
            local b=getBounds(char); if not b then hideESP(o); continue end
            local co=math.max(b.w,b.h)*0.15
            -- Box + corners
            if ESPState.boxes then
                o.bT.From=b.tl;o.bT.To=b.tr;o.bT.Color=ESPState.boxCol;o.bT.Visible=true
                o.bB.From=b.bl;o.bB.To=b.br;o.bB.Color=ESPState.boxCol;o.bB.Visible=true
                o.bL.From=b.tl;o.bL.To=b.bl;o.bL.Color=ESPState.boxCol;o.bL.Visible=true
                o.bR.From=b.tr;o.bR.To=b.br;o.bR.Color=ESPState.boxCol;o.bR.Visible=true
                o.cTL1.From=b.tl;o.cTL1.To=b.tl+Vector2.new(co,0);o.cTL1.Visible=true
                o.cTL2.From=b.tl;o.cTL2.To=b.tl+Vector2.new(0,co);o.cTL2.Visible=true
                o.cTR1.From=b.tr;o.cTR1.To=b.tr+Vector2.new(-co,0);o.cTR1.Visible=true
                o.cTR2.From=b.tr;o.cTR2.To=b.tr+Vector2.new(0,co);o.cTR2.Visible=true
                o.cBL1.From=b.bl;o.cBL1.To=b.bl+Vector2.new(co,0);o.cBL1.Visible=true
                o.cBL2.From=b.bl;o.cBL2.To=b.bl+Vector2.new(0,-co);o.cBL2.Visible=true
                o.cBR1.From=b.br;o.cBR1.To=b.br+Vector2.new(-co,0);o.cBR1.Visible=true
                o.cBR2.From=b.br;o.cBR2.To=b.br+Vector2.new(0,-co);o.cBR2.Visible=true
            else for _,k in ipairs({"bT","bB","bL","bR","cTL1","cTL2","cTR1","cTR2","cBL1","cBL2","cBR1","cBR2"}) do o[k].Visible=false end end
            -- Name
            if ESPState.names then
                o.name.Text=p.Name;o.name.Color=ESPState.nameCol
                o.name.Position=Vector2.new(b.tc.X,b.tc.Y-16);o.name.Visible=true
            else o.name.Visible=false end
            -- Distance
            if ESPState.dist then
                o.dist.Text="["..math.floor(getDist(p)).."m]"
                o.dist.Position=Vector2.new(b.bc.X,b.bc.Y+4);o.dist.Visible=true
            else o.dist.Visible=false end
            -- Health bar
            if ESPState.health then
                local pct=math.clamp(b.hum.Health/b.hum.MaxHealth,0,1)
                local bx=b.tl.X-5
                o.hBG.From=Vector2.new(bx,b.tl.Y);o.hBG.To=Vector2.new(bx,b.bl.Y);o.hBG.Visible=true
                o.hBar.From=Vector2.new(bx,b.bl.Y);o.hBar.To=Vector2.new(bx,b.bl.Y-b.h*pct)
                o.hBar.Color=Color3.new(math.clamp(2-pct*2,0,1),math.clamp(pct*2,0,1),0);o.hBar.Visible=true
            else o.hBG.Visible=false;o.hBar.Visible=false end
            -- Tracer
            if ESPState.tracers then
                local vs=Camera.ViewportSize
                o.tracer.From=Vector2.new(vs.X/2,vs.Y);o.tracer.To=b.bc
                o.tracer.Color=ESPState.tracerCol;o.tracer.Visible=true
            else o.tracer.Visible=false end
        end
    end)
end
runESP()

-- ══════════════════════════════════════════════════════════════
--  AIMBOT + SILENT AIM
-- ══════════════════════════════════════════════════════════════
local AimState = {
    on=false,fov=150,smooth=5,part="HumanoidRootPart",
    teamCheck=true,visCheck=true,silentAim=false,
    silentChance=85,currentTarget=nil,
}

local fovCircle=Drawing.new("Circle")
fovCircle.Visible=false;fovCircle.Radius=150;fovCircle.Color=Color3.new(1,1,1)
fovCircle.Thickness=1;fovCircle.Filled=false;fovCircle.Transparency=0.6

local function rayVis(from,to)
    local p=RaycastParams.new()
    p.FilterDescendantsInstances={LP.Character}
    p.FilterType=Enum.RaycastFilterType.Exclude
    local r=workspace:Raycast(from,(to-from).Unit*(to-from).Magnitude,p)
    return r==nil
end

local function getBestTarget()
    local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    local best,bestD=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP or not isAlive(p) then continue end
        if AimState.teamCheck and isTeam(p) then continue end
        local char=p.Character
        local part=char and char:FindFirstChild(AimState.part)
        if not part then continue end
        local sp,vis=w2s(part.Position)
        if not vis then continue end
        local d=(sp-center).Magnitude
        if d<AimState.fov and d<bestD then
            if AimState.visCheck and not rayVis(Camera.CFrame.Position,part.Position) then continue end
            best=p;bestD=d
        end
    end
    return best
end

-- Silent aim: hook camera's WorldToScreenPoint equivalent via
-- manipulating the camera CFrame briefly during a ray/bullet trace
-- The standard approach for Roblox is to hook the mouse hit via
-- FindPartOnRay or redirect tool fire events
local silentConn
local function startSilentAim()
    if silentConn then silentConn:Disconnect();silentConn=nil end
    if not AimState.silentAim then return end
    -- Override mouse.Hit and mouse.Target for tools that read them
    silentConn=RunService.RenderStepped:Connect(function()
        if not AimState.silentAim then silentConn:Disconnect();return end
        local target=getBestTarget()
        if not target then return end
        local part=target.Character and target.Character:FindFirstChild(AimState.part)
        if not part then return end
        -- Apply silent aim by temporarily rotating camera toward target
        -- when fire button is held, making projectiles hit the target
        if math.random(1,100)<=AimState.silentChance then
            local mouse=LP:GetMouse()
            -- Override mouse hit via camera manipulation
            pcall(function()
                -- This works for tools that use mouse.Hit
                local cf=CFrame.new(Camera.CFrame.Position,part.Position)
                Camera.CFrame=cf
            end)
        end
    end)
end

local aimConn
local function runAimbot()
    if aimConn then aimConn:Disconnect() end
    aimConn=RunService.RenderStepped:Connect(function()
        fovCircle.Visible=AimState.on
        fovCircle.Radius=AimState.fov
        fovCircle.Position=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
        if not AimState.on then AimState.currentTarget=nil;return end
        local t=getBestTarget(); AimState.currentTarget=t
        if not t then return end
        local root=t.Character and t.Character:FindFirstChild(AimState.part)
        if not root then return end
        if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local cf=CFrame.new(Camera.CFrame.Position,root.Position)
            Camera.CFrame=Camera.CFrame:Lerp(cf,1/AimState.smooth)
        end
    end)
end
runAimbot()

-- Kill Aura
local KAState={on=false,range=15,teamCheck=true}
local kaConn
local function runKA()
    if kaConn then kaConn:Disconnect() end
    kaConn=RunService.Heartbeat:Connect(function()
        if not KAState.on then return end
        local tool=LP.Character and LP.Character:FindFirstChildOfClass("Tool")
        if not tool then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP or not isAlive(p) then continue end
            if KAState.teamCheck and isTeam(p) then continue end
            if getDist(p)<=KAState.range then pcall(function() tool:Activate() end) end
        end
    end)
end
runKA()

-- ══════════════════════════════════════════════════════════════
--  MOVEMENT
-- ══════════════════════════════════════════════════════════════
local MoveState={
    speed=false,walkspeed=16,jump=50,
    fly=false,flySpeed=60,
    noclip=false,infJump=false,bhop=false,antiAfk=false,
}

-- Heartbeat loop: reapplies speed/noclip/bhop every frame to fight server correction
local movLoop
local function startMovLoop()
    if movLoop then movLoop:Disconnect() end
    movLoop=RunService.Heartbeat:Connect(function()
        local char=LP.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        if MoveState.speed   then hum.WalkSpeed=MoveState.walkspeed end
        if MoveState.jump~=50 then hum.JumpPower=MoveState.jump end
        if MoveState.noclip  then for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
        if MoveState.bhop and hum.FloorMaterial~=Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end
startMovLoop()

local flyConn,flyBV,flyBG
local function stopFly()
    if flyConn then flyConn:Disconnect();flyConn=nil end
    pcall(function() if flyBV then flyBV:Destroy();flyBV=nil end end)
    pcall(function() if flyBG then flyBG:Destroy();flyBG=nil end end)
    local hum=getHum(LP); if hum then hum.PlatformStand=false;hum.AutoRotate=true end
end
local function startFly()
    stopFly(); if not MoveState.fly then return end
    local char=LP.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand=true;hum.AutoRotate=false
    flyBV=Instance.new("BodyVelocity");flyBV.MaxForce=Vector3.new(1e5,1e5,1e5);flyBV.Velocity=Vector3.new(0,0,0);flyBV.Parent=hrp
    flyBG=Instance.new("BodyGyro");flyBG.MaxTorque=Vector3.new(1e5,1e5,1e5);flyBG.P=1e4;flyBG.CFrame=hrp.CFrame;flyBG.Parent=hrp
    flyConn=RunService.RenderStepped:Connect(function()
        if not MoveState.fly then stopFly();return end
        local cam=Camera.CFrame; local v=Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then v=v+cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then v=v-cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then v=v-cam.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then v=v+cam.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space)       then v=v+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then v=v-Vector3.new(0,1,0) end
        if v.Magnitude>0 then flyBV.Velocity=v.Unit*MoveState.flySpeed;flyBG.CFrame=CFrame.new(hrp.Position,hrp.Position+v)
        else flyBV.Velocity=Vector3.new(0,0,0);flyBG.CFrame=hrp.CFrame end
    end)
end

local ijConn
local function startInfJump()
    if ijConn then ijConn:Disconnect() end
    if not MoveState.infJump then return end
    ijConn=UIS.JumpRequest:Connect(function()
        if not MoveState.infJump then ijConn:Disconnect();return end
        local h=getHum(LP); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end

local afkConn
local function startAntiAfk()
    if afkConn then afkConn:Disconnect() end
    if not MoveState.antiAfk then return end
    local vu=game:GetService("VirtualUser")
    afkConn=LP.Idled:Connect(function()
        if not MoveState.antiAfk then afkConn:Disconnect();return end
        vu:Button2Down(Vector2.new(0,0),Camera.CFrame);task.wait(0.1);vu:Button2Up(Vector2.new(0,0),Camera.CFrame)
    end)
end

LP.CharacterAdded:Connect(function()
    task.wait(0.5); startMovLoop()
    if MoveState.fly     then startFly()     end
    if MoveState.infJump then startInfJump() end
end)

-- ══════════════════════════════════════════════════════════════
--  BUILD TABS
-- ══════════════════════════════════════════════════════════════

-- VISUALS
local Vis=PH:Tab("Visuals","👁")
Vis:Section("ESP")
Vis:Toggle("Enable ESP",false,function(on) ESPState.on=on; if not on then for _,o in pairs(ESPObjects) do hideESP(o) end end end)
Vis:Toggle("Boxes",true,function(on) ESPState.boxes=on end)
Vis:Toggle("Names",true,function(on) ESPState.names=on end)
Vis:Toggle("Health Bar",true,function(on) ESPState.health=on end)
Vis:Toggle("Distance",true,function(on) ESPState.dist=on end)
Vis:Toggle("Tracers",false,function(on) ESPState.tracers=on end)
Vis:Toggle("Team Check",true,function(on) ESPState.teamCheck=on end)
Vis:Slider("Max Distance",100,3000,1000,function(v) ESPState.maxDist=v end)
Vis:Section("ESP Colors")
Vis:Dropdown("Box Color",{"Red","White","Cyan","Green","Yellow","Purple"},"Red",function(c)
    local m={Red=Color3.fromRGB(255,50,50),White=Color3.new(1,1,1),Cyan=Color3.fromRGB(0,255,255),Green=Color3.fromRGB(50,255,100),Yellow=Color3.fromRGB(255,230,50),Purple=Color3.fromRGB(180,50,255)}
    ESPState.boxCol=m[c] or ESPState.boxCol
end)
Vis:Section("World")
Vis:Toggle("Fullbright",false,function(on) local L=game:GetService("Lighting");L.Brightness=on and 2 or 1;L.GlobalShadows=not on end)
Vis:Slider("Field of View",60,120,70,function(v) Camera.FieldOfView=v end)
Vis:Toggle("No Fog",false,function(on) game:GetService("Lighting").FogEnd=on and 9e9 or 100000 end)

-- COMBAT
local Cbt=PH:Tab("Combat","⚔")
Cbt:Section("Aimbot")
Cbt:Toggle("Enable Aimbot",false,function(on) AimState.on=on;if not on then AimState.currentTarget=nil end end)
Cbt:Slider("FOV Radius",50,600,150,function(v) AimState.fov=v;fovCircle.Radius=v end)
Cbt:Slider("Smoothness",1,20,5,function(v) AimState.smooth=v end)
Cbt:Dropdown("Target Part",{"HumanoidRootPart","Head","Torso"},"HumanoidRootPart",function(v) AimState.part=v end)
Cbt:Toggle("Team Check",true,function(on) AimState.teamCheck=on end)
Cbt:Toggle("Visible Check",true,function(on) AimState.visCheck=on end)
Cbt:Section("Silent Aim")
Cbt:Toggle("Silent Aim",false,function(on)
    AimState.silentAim=on
    if on then startSilentAim() else if silentConn then silentConn:Disconnect();silentConn=nil end end
    PH:Notify("Silent Aim",on and "Enabled" or "Disabled",2,on and "warning" or "error")
end)
Cbt:Slider("Hit Chance %",1,100,85,function(v) AimState.silentChance=v end)
Cbt:Section("Kill Aura")
Cbt:Toggle("Kill Aura",false,function(on) KAState.on=on end)
Cbt:Slider("Kill Aura Range",5,60,15,function(v) KAState.range=v end)
Cbt:Toggle("Team Check (KA)",true,function(on) KAState.teamCheck=on end)

-- MOVEMENT
local Mov=PH:Tab("Movement","⚡")
Mov:Section("Speed")
Mov:Toggle("Speed Modifier",false,function(on) MoveState.speed=on; if not on then local h=getHum(LP);if h then h.WalkSpeed=16 end end end)
Mov:Slider("Walk Speed",16,300,16,function(v) MoveState.walkspeed=v end)
Mov:Slider("Jump Power",50,500,50,function(v) MoveState.jump=v end)
Mov:Section("Flight")
Mov:Toggle("Fly",false,function(on) MoveState.fly=on;if on then startFly() else stopFly() end end)
Mov:Slider("Fly Speed",10,300,60,function(v) MoveState.flySpeed=v end)
Mov:Section("Misc")
Mov:Toggle("Noclip",false,function(on) MoveState.noclip=on end)
Mov:Toggle("Infinite Jump",false,function(on) MoveState.infJump=on;startInfJump() end)
Mov:Toggle("Bunny Hop",false,function(on) MoveState.bhop=on end)
Mov:Toggle("Anti-AFK",false,function(on) MoveState.antiAfk=on;startAntiAfk() end)
Mov:Button("Reset Character",function() local h=getHum(LP);if h then h.Health=0 end end)

-- MISC
local Misc=PH:Tab("Misc","◈")
Misc:Section("Teleport")
local tpBox=Misc:Textbox("Player Name","Username...")
Misc:Button("Teleport to Player",function()
    local t=Players:FindFirstChild(tpBox.Text)
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
PH:Notify("Core Loaded","Universal script ready  •  "..PH.Tier,4,"success")
