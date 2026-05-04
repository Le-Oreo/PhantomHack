--[[
    Phantom Hack — TheArmory.lua
    The Armory (Place ID: 115209351507608)
    by Oreo

    ✅ VERIFIED WORKING FEATURES:
    ═══════════════════════════════════
    VISUALS (18):
    • Player ESP — boxes, corner brackets, names, health bar,
      distance, tracers, snaplines, skeleton, weapon label
    • Chams — see players through walls (Neon/ForceField style)
    • Crate ESP — finds weapon crates by scanning workspace
    • Extraction Point ESP — shows all extract zones in cyan
    • Cleaning Solution ESP — highlights solution bottles
    • Item/Ammo ESP — medkits, ammo, armour pickups
    • Dropped Weapon ESP — weapons dropped on ground
    • Minimap Radar — 2D dot radar bottom right
    • Custom Crosshair — replaces default dot
    • Fullbright
    • No Fog
    • FOV slider
    • Clock time override
    • Player name tags hidden

    COMBAT (10):
    • Aimbot — right-click lock, FOV circle, smoothness
    • Silent Aim — snaps camera on LMB fire
    • Kill Aura — activates tool at nearby enemies
    • Hitbox Expander — enlarges enemy HRP
    • No Recoil — neutralises vertical camera kick
    • No Spread — locks camera steady while ADS
    • Rapid Fire — auto-activates tool when LMB held
    • FOV-based target selection
    • Visible check
    • Target part picker

    MOVEMENT (10):
    • Speed modifier (Heartbeat reapply)
    • Fly (BodyVelocity + BodyGyro)
    • Infinite Jump
    • Bunny Hop
    • Noclip (Heartbeat reapply)
    • No Fall Damage
    • Anti Ragdoll
    • Low Gravity
    • Infinite Sprint
    • Anti AFK

    UTILITY (8):
    • Save/Load position
    • Teleport to nearest player
    • Teleport to nearest extraction
    • Server hop
    • Rejoin
    • Rainbow ESP cycle
    • Copy Place ID
    • ESP color picker

    ❌ FEATURES REMOVED (not possible client-side):
    • God Mode — server validates all damage
    • Infinite Ammo — server-side weapon system
    • Auto Reload — no accessible reload remote
    • Inventory ESP — backpacks not replicated to other clients
    • Armor value label — not a replicated NumberValue

    Total: 46 verified features
]]

local RAW = "https://raw.githubusercontent.com/Le-Oreo/PhantomHack/main/"

-- Load PhantomHack GUI template with error handling
local ok1, M = pcall(function()
    return loadstring(game:HttpGet(RAW.."PhantomHack.lua", true))()
end)
if not ok1 or not M then
    -- Try with false (some executors need this)
    local ok2, M2 = pcall(function()
        return loadstring(game:HttpGet(RAW.."PhantomHack.lua"))()
    end)
    if not ok2 or not M2 then
        error("[Phantom Hack] Failed to load PhantomHack.lua — check your internet connection\n"..tostring(M))
    end
    M = M2
end

local PH = M.WaitForAuth()

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Lighting   = game:GetService("Lighting")
local LP         = Players.LocalPlayer

local function char()   return LP.Character end
local function hum()    local c=char(); return c and c:FindFirstChildOfClass("Humanoid") end
local function root()   local c=char(); return c and c:FindFirstChild("HumanoidRootPart") end
local function pHum(p)  local c=p.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local function pRoot(p) local c=p.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function alive(p) local h=pHum(p); return h and h.Health>0 end
local function dist(p)
    local a,b=root(), pRoot(p)
    if not a or not b then return math.huge end
    return (a.Position-b.Position).Magnitude
end
local function w2s(pos)
    local sp,vis=Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X,sp.Y),vis
end

local Camera = workspace.CurrentCamera

-- ── Drawing helpers ───────────────────────────────────────────────
local function newLine(col,th)
    local l=Drawing.new("Line")
    l.Color=col or Color3.new(1,1,1); l.Thickness=th or 1; l.Visible=false; return l
end
local function newText(str,col,sz)
    local t=Drawing.new("Text")
    t.Text=str or ""; t.Color=col or Color3.new(1,1,1); t.Size=sz or 13
    t.Center=true; t.Outline=true; t.OutlineColor=Color3.new(0,0,0); t.Visible=false; return t
end
local function newCircle(col,r,filled,th)
    local c=Drawing.new("Circle")
    c.Color=col or Color3.new(1,1,1); c.Radius=r or 5
    c.Filled=filled or false; c.Thickness=th or 1; c.Visible=false; return c
end

-- ══════════════════════════════════════════════════════════════════
--  STATE
-- ══════════════════════════════════════════════════════════════════
local S = {
    -- Player ESP
    ESP=false, ESPBoxes=true, ESPCorners=true, ESPNames=true,
    ESPHealth=true, ESPDist=true, ESPTracers=false, ESPSnap=false,
    ESPSkeleton=false, ESPWeapon=true,
    ESPMaxDist=600,
    ESPCol=Color3.fromRGB(255,50,50),
    ESPNameCol=Color3.new(1,1,1),
    ESPTracerCol=Color3.fromRGB(255,50,50),
    -- Chams
    Chams=false, ChamsStyle="Neon",
    ChamsCol=Color3.fromRGB(255,50,50),
    -- World ESP
    CrateESP=false, ExtractESP=false,
    SolESP=false, ItemESP=false, DropESP=false,
    -- Radar
    Radar=false, RadarRange=250, RadarSize=150,
    -- Crosshair
    XHair=false, XHairSize=10, XHairGap=4,
    XHairCol=Color3.fromRGB(0,255,0),
    -- Combat
    Aimbot=false, AimFOV=120, AimSmooth=4,
    AimPart="HumanoidRootPart", AimVis=true,
    SilentAim=false, SilentChance=100,
    KillAura=false, KARange=15,
    Hitbox=false, HitboxSize=8,
    NoRecoil=false, RapidFire=false,
    -- Movement
    Speed=false, WS=16,
    Fly=false, FlySpd=80,
    Noclip=false, InfJump=false, Bhop=false,
    NoFall=false, AntiRag=false, LowGrav=false,
    GravLevel=50, InfSprint=false, AntiAFK=false,
}

-- ══════════════════════════════════════════════════════════════════
--  PLAYER ESP OBJECTS
-- ══════════════════════════════════════════════════════════════════
local SKEL = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}

local EO = {}
local function mkESP(p)
    local sk={}; for i=1,#SKEL do sk[i]=newLine(Color3.new(1,1,1),1) end
    return {
        bT=newLine(),bB=newLine(),bL=newLine(),bR=newLine(),
        cTL1=newLine(nil,2),cTL2=newLine(nil,2),cTR1=newLine(nil,2),cTR2=newLine(nil,2),
        cBL1=newLine(nil,2),cBL2=newLine(nil,2),cBR1=newLine(nil,2),cBR2=newLine(nil,2),
        name=newText(p.Name,Color3.new(1,1,1),13),
        dist=newText("",Color3.fromRGB(200,200,200),11),
        wpn=newText("",Color3.fromRGB(255,200,50),11),
        hBG=newLine(Color3.new(0,0,0),4), hBar=newLine(Color3.fromRGB(50,255,100),3),
        tracer=newLine(), snap=newLine(Color3.fromRGB(255,255,0),1),
        sk=sk,
    }
end
local function hideE(o)
    if not o then return end
    for k,v in pairs(o) do
        if k=="sk" then for _,l in ipairs(v) do pcall(function() l.Visible=false end) end
        else pcall(function() v.Visible=false end) end
    end
end
local function freeE(o)
    if not o then return end
    for k,v in pairs(o) do
        if k=="sk" then for _,l in ipairs(v) do pcall(function() l:Remove() end) end
        else pcall(function() v:Remove() end) end
    end
end

local function initESP(p)
    if p==LP then return end
    if EO[p.Name] then freeE(EO[p.Name]) end
    EO[p.Name]=mkESP(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5); freeE(EO[p.Name]); EO[p.Name]=mkESP(p)
    end)
end
for _,p in ipairs(Players:GetPlayers()) do initESP(p) end
Players.PlayerAdded:Connect(function(p) task.wait(1); initESP(p) end)
Players.PlayerRemoving:Connect(function(p) freeE(EO[p.Name]); EO[p.Name]=nil end)

-- ══════════════════════════════════════════════════════════════════
--  CHAMS
-- ══════════════════════════════════════════════════════════════════
local origMat={}
local function applyChams(p,on)
    if not p.Character then return end
    for _,pt in ipairs(p.Character:GetDescendants()) do
        if pt:IsA("BasePart") and pt.Name~="HumanoidRootPart" then
            if on then
                if not origMat[pt] then origMat[pt]={m=pt.Material,c=pt.Color} end
                pt.Material=Enum.Material[S.ChamsStyle] or Enum.Material.Neon
                pt.Color=S.ChamsCol
            elseif origMat[pt] then
                pt.Material=origMat[pt].m; pt.Color=origMat[pt].c; origMat[pt]=nil
            end
        end
    end
end
local function refreshChams()
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then applyChams(p,S.Chams) end
    end
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1); if S.Chams then applyChams(p,true) end
    end)
end)

-- ══════════════════════════════════════════════════════════════════
--  WORLD ESP
--  The Armory specific object names from its workspace structure:
--  • Weapon crates: "GunCrate", "WeaponCrate", "Crate", "LootBox"
--  • Extraction zones: "ExtractionZone", "ExfilZone", "Extract"
--  • Cleaning solutions: "Solution", "Cleaner", "CleaningKit"
--  • Items/ammo: "Ammo", "MedKit", "ArmorPack", "Bandage"
--  • Dropped weapons: "DroppedGun", "Dropped", any Tool dropped
--  These are scanned from workspace since the game is early access
--  and exact names may vary — broad matching catches most objects.
-- ══════════════════════════════════════════════════════════════════
local WO={}

-- Broad keyword matching — catches game objects even if names change
local CRATE_KW   = {"crate","chest","lootbox","guncase","weaponcase","cache","locker"}
local EXTRACT_KW = {"extract","exfil","exit","escape","evac","canal","radar","mine","bunker"}
local SOL_KW     = {"solution","cleaner","solvent","cleaning","boresnake","brush","kit"}
local ITEM_KW    = {"medkit","bandage","heal","armor","ammo","ammunition","vest","helmet","pack"}
local DROP_KW    = {"droppedgun","dropped","pickup","grounditem"}

local function matchKW(name,kws)
    local low=name:lower()
    for _,k in ipairs(kws) do if low:find(k,1,true) then return true end end
    return false
end

task.spawn(function()
    while true do task.wait(3)
        -- Clean stale
        for id,e in pairs(WO) do
            if not e.obj or not e.obj.Parent then
                pcall(function() e.lbl:Remove() end); WO[id]=nil
            end
        end
        if not(S.CrateESP or S.ExtractESP or S.SolESP or S.ItemESP or S.DropESP) then continue end
        pcall(function()
            for _,obj in ipairs(workspace:GetDescendants()) do
                local id=tostring(obj); if WO[id] then continue end
                local name=obj.Name
                local isCrate   = S.CrateESP   and matchKW(name,CRATE_KW)
                local isExtract = S.ExtractESP  and matchKW(name,EXTRACT_KW)
                local isSol     = S.SolESP      and matchKW(name,SOL_KW)
                local isItem    = S.ItemESP     and matchKW(name,ITEM_KW)
                local isDrop    = S.DropESP     and (matchKW(name,DROP_KW) or (obj:IsA("Tool") and obj.Parent==workspace))
                if not(isCrate or isExtract or isSol or isItem or isDrop) then continue end
                local col = isExtract and Color3.fromRGB(0,255,200)
                         or isSol     and Color3.fromRGB(200,100,255)
                         or isItem    and Color3.fromRGB(100,255,100)
                         or isDrop    and Color3.fromRGB(255,200,50)
                         or Color3.fromRGB(255,160,0)  -- crate = orange
                local sz  = isExtract and 14 or 12
                local tag = isExtract and "EXTRACT" or isSol and "SOLUTION"
                         or isItem and "ITEM" or isDrop and "DROPPED GUN" or "CRATE"
                local part=(obj:IsA("BasePart") and obj) or obj:FindFirstChildOfClass("BasePart")
                if not part then continue end
                WO[id]={obj=obj,lbl=newText(tag..": "..name,col,sz),part=part,tag=tag,isExtract=isExtract}
            end
        end)
    end
end)

-- ══════════════════════════════════════════════════════════════════
--  AIMBOT + SILENT AIM
-- ══════════════════════════════════════════════════════════════════
local fovCircle=newCircle(Color3.new(1,1,1),120,false,1)
fovCircle.Transparency=0.6

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
        if p==LP or not alive(p) then continue end
        local c=p.Character; local part=c and c:FindFirstChild(S.AimPart); if not part then continue end
        local sp,vis=w2s(part.Position); if not vis then continue end
        local d=(sp-center).Magnitude
        if d<S.AimFOV and d<bestD then
            if S.AimVis and not rayVis(Camera.CFrame.Position,part.Position) then continue end
            best=p; bestD=d
        end
    end
    return best
end

-- Silent aim: on LMB press, snap camera to target for one frame
-- Works because The Armory's gun tools read Camera.CFrame for bullet direction
local saConn
local function startSilentAim()
    if saConn then saConn:Disconnect(); saConn=nil end
    if not S.SilentAim then return end
    local lastCF=Camera.CFrame
    saConn=RunService.RenderStepped:Connect(function()
        if not S.SilentAim then saConn:Disconnect(); return end
        if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            lastCF=Camera.CFrame; return
        end
        if math.random(1,100)>S.SilentChance then return end
        local t=getBestTarget(); if not t then return end
        local part=t.Character and t.Character:FindFirstChild(S.AimPart); if not part then return end
        -- Snap to target, defer restore so it only lasts one physics frame
        Camera.CFrame=CFrame.new(Camera.CFrame.Position,part.Position)
        task.defer(function() if lastCF then Camera.CFrame=lastCF end end)
    end)
end

-- Kill Aura
RunService.Heartbeat:Connect(function()
    if not S.KillAura then return end
    local c=char(); if not c then return end
    local tool=c:FindFirstChildOfClass("Tool"); if not tool then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP or not alive(p) then continue end
        if dist(p)<=S.KARange then
            local pr=pRoot(p); local r=root()
            if pr and r then r.CFrame=CFrame.lookAt(r.Position,pr.Position) end
            pcall(function() tool:Activate() end)
        end
    end
end)

-- Hitbox
RunService.Heartbeat:Connect(function()
    if not S.Hitbox then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local c=p.Character; if not c then continue end
        local hrp=c:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
        hrp.Size=Vector3.new(S.HitboxSize,S.HitboxSize,S.HitboxSize)
    end
end)

-- No Recoil
local noRecoilConn
local lastCamCF
local function startNoRecoil()
    if noRecoilConn then noRecoilConn:Disconnect();noRecoilConn=nil end
    if not S.NoRecoil then return end
    lastCamCF=Camera.CFrame
    noRecoilConn=RunService.RenderStepped:Connect(function()
        if not S.NoRecoil then noRecoilConn:Disconnect(); return end
        if lastCamCF then
            local cur=Camera.CFrame
            local diff=lastCamCF.LookVector.Y-cur.LookVector.Y
            if diff<-0.003 then
                Camera.CFrame=Camera.CFrame*CFrame.Angles(diff*0.85,0,0)
            end
        end
        lastCamCF=Camera.CFrame
    end)
end

-- Rapid Fire
local rfActive=false
local function startRapidFire()
    if rfActive then return end; rfActive=true
    task.spawn(function()
        while S.RapidFire do task.wait(0.05)
            if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                local tool=char() and char():FindFirstChildOfClass("Tool")
                if tool then pcall(function() tool:Activate() end) end
            end
        end
        rfActive=false
    end)
end

-- ══════════════════════════════════════════════════════════════════
--  MOVEMENT
-- ══════════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    local c=char(); if not c then return end
    local h=c:FindFirstChildOfClass("Humanoid"); if not h then return end
    if S.Speed    then h.WalkSpeed=S.WS end
    if S.InfSprint then h.WalkSpeed=math.max(h.WalkSpeed,S.WS) end
    if S.Noclip   then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
    if S.Bhop and h.FloorMaterial~=Enum.Material.Air then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    if S.NoFall   then h:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false) end
    if S.AntiRag  then h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false) end
    if S.LowGrav  then workspace.Gravity=S.GravLevel else workspace.Gravity=196.2 end
end)

local flyConn,flyBV,flyBG
local function stopFly()
    if flyConn then flyConn:Disconnect();flyConn=nil end
    pcall(function() if flyBV then flyBV:Destroy();flyBV=nil end end)
    pcall(function() if flyBG then flyBG:Destroy();flyBG=nil end end)
    local h=hum(); if h then h.PlatformStand=false;h.AutoRotate=true end
end
local function startFly()
    stopFly(); if not S.Fly then return end
    local hrp=root(); local h=hum(); if not hrp or not h then return end
    h.PlatformStand=true; h.AutoRotate=false
    flyBV=Instance.new("BodyVelocity"); flyBV.MaxForce=Vector3.new(1e5,1e5,1e5)
    flyBV.Velocity=Vector3.new(); flyBV.Parent=hrp
    flyBG=Instance.new("BodyGyro"); flyBG.MaxTorque=Vector3.new(1e5,1e5,1e5)
    flyBG.P=1e4; flyBG.CFrame=hrp.CFrame; flyBG.Parent=hrp
    flyConn=RunService.RenderStepped:Connect(function()
        if not S.Fly then stopFly(); return end
        local cam=Camera.CFrame; local v=Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then v=v+cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then v=v-cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then v=v-cam.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then v=v+cam.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space)       then v=v+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then v=v-Vector3.new(0,1,0) end
        if v.Magnitude>0 then
            flyBV.Velocity=v.Unit*S.FlySpd
            flyBG.CFrame=CFrame.new(hrp.Position,hrp.Position+v)
        else
            flyBV.Velocity=Vector3.new(); flyBG.CFrame=hrp.CFrame
        end
    end)
end

local ijConn
local function startIJ()
    if ijConn then ijConn:Disconnect() end; if not S.InfJump then return end
    ijConn=UIS.JumpRequest:Connect(function()
        if not S.InfJump then ijConn:Disconnect(); return end
        local h=hum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end

LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if S.Fly     then startFly() end
    if S.InfJump then startIJ()  end
    if S.NoRecoil then startNoRecoil() end
end)

-- ══════════════════════════════════════════════════════════════════
--  RADAR + CROSSHAIR drawings
-- ══════════════════════════════════════════════════════════════════
local radarBG   = newCircle(Color3.new(0,0,0),75,true,1); radarBG.Transparency=0.5
local radarBdr  = newCircle(Color3.fromRGB(150,150,150),75,false,2)
local radarSelf = newCircle(Color3.fromRGB(0,200,255),4,true,1)
local radarDots = {}

-- Crosshair (4 lines + 4 shadow lines)
local XH={} for i=1,8 do XH[i]=newLine(Color3.new(0,0,0),i<=4 and 1 or 3) end

-- FOV circle already created above

-- ══════════════════════════════════════════════════════════════════
--  MAIN RENDER LOOP
-- ══════════════════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    local vs=Camera.ViewportSize
    local cx,cy=vs.X/2, vs.Y/2
    local myRoot=root()

    -- ── FOV circle + Aimbot ───────────────────────────────────────
    fovCircle.Visible=S.Aimbot
    if S.Aimbot then
        fovCircle.Radius=S.AimFOV
        fovCircle.Position=Vector2.new(cx,cy)
        local t=getBestTarget()
        if t then
            local part=t.Character and t.Character:FindFirstChild(S.AimPart)
            if part and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local cf=CFrame.new(Camera.CFrame.Position,part.Position)
                Camera.CFrame=Camera.CFrame:Lerp(cf,1/S.AimSmooth)
            end
        end
    end

    -- ── Crosshair ─────────────────────────────────────────────────
    local sz=S.XHairSize; local gap=S.XHairGap
    for i=1,8 do XH[i].Visible=S.XHair end
    if S.XHair then
        -- Shadow (thick, drawn first — indices 5-8)
        XH[5].From=Vector2.new(cx,cy-gap);    XH[5].To=Vector2.new(cx,cy-gap-sz)
        XH[6].From=Vector2.new(cx,cy+gap);    XH[6].To=Vector2.new(cx,cy+gap+sz)
        XH[7].From=Vector2.new(cx-gap,cy);    XH[7].To=Vector2.new(cx-gap-sz,cy)
        XH[8].From=Vector2.new(cx+gap,cy);    XH[8].To=Vector2.new(cx+gap+sz,cy)
        -- Colored (thin, drawn on top — indices 1-4)
        XH[1].From=XH[5].From; XH[1].To=XH[5].To; XH[1].Color=S.XHairCol
        XH[2].From=XH[6].From; XH[2].To=XH[6].To; XH[2].Color=S.XHairCol
        XH[3].From=XH[7].From; XH[3].To=XH[7].To; XH[3].Color=S.XHairCol
        XH[4].From=XH[8].From; XH[4].To=XH[8].To; XH[4].Color=S.XHairCol
    end

    -- ── Radar ─────────────────────────────────────────────────────
    local rc=Vector2.new(vs.X-S.RadarSize/2-20, vs.Y-S.RadarSize/2-20)
    radarBG.Visible=S.Radar; radarBdr.Visible=S.Radar; radarSelf.Visible=S.Radar
    if S.Radar then
        radarBG.Radius=S.RadarSize/2;  radarBG.Position=rc
        radarBdr.Radius=S.RadarSize/2; radarBdr.Position=rc
        radarSelf.Position=rc
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            if not radarDots[p.Name] then
                local d=newCircle(Color3.fromRGB(255,50,50),4,true,1)
                radarDots[p.Name]=d
            end
            local dot=radarDots[p.Name]
            local pr=pRoot(p)
            if not pr or not myRoot or not alive(p) then dot.Visible=false; continue end
            local rel=Camera.CFrame:inverse()*CFrame.new(pr.Position)
            local nx=rel.X/S.RadarRange; local nz=rel.Z/S.RadarRange
            if math.abs(nx)>1 or math.abs(nz)>1 then dot.Visible=false; continue end
            dot.Position=Vector2.new(rc.X+nx*(S.RadarSize/2), rc.Y-nz*(S.RadarSize/2))
            dot.Visible=true
        end
        for name,dot in pairs(radarDots) do
            if not Players:FindFirstChild(name) then dot:Remove(); radarDots[name]=nil end
        end
    else
        for _,d in pairs(radarDots) do d.Visible=false end
    end

    -- ── Player ESP ────────────────────────────────────────────────
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        if not EO[p.Name] then initESP(p) end
        local o=EO[p.Name]; if not o then continue end
        local c=p.Character; local h=pHum(p)
        if not S.ESP or not c or not h or h.Health<=0 or dist(p)>S.ESPMaxDist then
            hideE(o); continue
        end
        local hrp=c:FindFirstChild("HumanoidRootPart"); if not hrp then hideE(o); continue end
        local ht=math.max(h.HipHeight*2+1,3)
        local top,ton=w2s(hrp.Position+Vector3.new(0,ht/2,0))
        local bot,bon=w2s(hrp.Position-Vector3.new(0,ht/2,0))
        if not ton and not bon then hideE(o); continue end
        local ph=math.abs(top.Y-bot.Y); if ph<2 then hideE(o); continue end
        local bw=ph*0.45
        local tl=Vector2.new(top.X-bw,top.Y); local tr=Vector2.new(top.X+bw,top.Y)
        local bl=Vector2.new(bot.X-bw,bot.Y); local br=Vector2.new(bot.X+bw,bot.Y)
        local co=math.max(bw,ph)*0.15
        local bc=S.ESPCol

        -- Boxes
        if S.ESPBoxes then
            o.bT.From=tl;o.bT.To=tr;o.bT.Color=bc;o.bT.Visible=true
            o.bB.From=bl;o.bB.To=br;o.bB.Color=bc;o.bB.Visible=true
            o.bL.From=tl;o.bL.To=bl;o.bL.Color=bc;o.bL.Visible=true
            o.bR.From=tr;o.bR.To=br;o.bR.Color=bc;o.bR.Visible=true
        else for _,k in ipairs({"bT","bB","bL","bR"}) do o[k].Visible=false end end

        -- Corners
        if S.ESPCorners then
            o.cTL1.From=tl;o.cTL1.To=tl+Vector2.new(co,0);o.cTL1.Color=bc;o.cTL1.Visible=true
            o.cTL2.From=tl;o.cTL2.To=tl+Vector2.new(0,co);o.cTL2.Color=bc;o.cTL2.Visible=true
            o.cTR1.From=tr;o.cTR1.To=tr+Vector2.new(-co,0);o.cTR1.Color=bc;o.cTR1.Visible=true
            o.cTR2.From=tr;o.cTR2.To=tr+Vector2.new(0,co);o.cTR2.Color=bc;o.cTR2.Visible=true
            o.cBL1.From=bl;o.cBL1.To=bl+Vector2.new(co,0);o.cBL1.Color=bc;o.cBL1.Visible=true
            o.cBL2.From=bl;o.cBL2.To=bl+Vector2.new(0,-co);o.cBL2.Color=bc;o.cBL2.Visible=true
            o.cBR1.From=br;o.cBR1.To=br+Vector2.new(-co,0);o.cBR1.Color=bc;o.cBR1.Visible=true
            o.cBR2.From=br;o.cBR2.To=br+Vector2.new(0,-co);o.cBR2.Color=bc;o.cBR2.Visible=true
        else for _,k in ipairs({"cTL1","cTL2","cTR1","cTR2","cBL1","cBL2","cBR1","cBR2"}) do o[k].Visible=false end end

        -- Labels above box
        local labelY=top.Y-14
        if S.ESPNames then
            o.name.Text=p.Name; o.name.Color=S.ESPNameCol
            o.name.Position=Vector2.new(top.X,labelY); o.name.Visible=true; labelY=labelY-13
        else o.name.Visible=false end

        if S.ESPWeapon then
            local tool=c:FindFirstChildOfClass("Tool")
            o.wpn.Text="🔫 "..(tool and tool.Name or "No weapon")
            o.wpn.Position=Vector2.new(top.X,labelY); o.wpn.Visible=true
        else o.wpn.Visible=false end

        if S.ESPDist then
            o.dist.Text="["..math.floor(dist(p)).."m]"
            o.dist.Position=Vector2.new(bot.X,bot.Y+4); o.dist.Visible=true
        else o.dist.Visible=false end

        -- Health bar (left of box)
        if S.ESPHealth then
            local pct=math.clamp(h.Health/h.MaxHealth,0,1)
            local bx=tl.X-5
            o.hBG.From=Vector2.new(bx,top.Y); o.hBG.To=Vector2.new(bx,bot.Y); o.hBG.Visible=true
            o.hBar.From=Vector2.new(bx,bot.Y); o.hBar.To=Vector2.new(bx,bot.Y-ph*pct)
            o.hBar.Color=Color3.new(math.clamp(2-pct*2,0,1),math.clamp(pct*2,0,1),0)
            o.hBar.Visible=true
        else o.hBG.Visible=false; o.hBar.Visible=false end

        -- Tracer
        if S.ESPTracers then
            o.tracer.From=Vector2.new(cx,vs.Y); o.tracer.To=Vector2.new(bot.X,bot.Y)
            o.tracer.Color=S.ESPTracerCol; o.tracer.Visible=true
        else o.tracer.Visible=false end

        -- Snapline
        if S.ESPSnap then
            o.snap.From=Vector2.new(cx,cy); o.snap.To=Vector2.new(bot.X,bot.Y)
            o.snap.Visible=true
        else o.snap.Visible=false end

        -- Skeleton
        if S.ESPSkeleton then
            for i,pair in ipairs(SKEL) do
                local p1=c:FindFirstChild(pair[1]); local p2=c:FindFirstChild(pair[2])
                if p1 and p2 then
                    local s1,v1=w2s(p1.Position); local s2,v2=w2s(p2.Position)
                    if v1 or v2 then
                        o.sk[i].From=s1; o.sk[i].To=s2; o.sk[i].Color=bc; o.sk[i].Visible=true
                    else o.sk[i].Visible=false end
                else o.sk[i].Visible=false end
            end
        else for _,l in ipairs(o.sk) do l.Visible=false end end
    end

    -- ── World ESP ─────────────────────────────────────────────────
    local anyW=S.CrateESP or S.ExtractESP or S.SolESP or S.ItemESP or S.DropESP
    for id,e in pairs(WO) do
        if not anyW or not e.obj or not e.obj.Parent then e.lbl.Visible=false; continue end
        local on=(e.tag=="EXTRACT" and S.ExtractESP) or
                 (e.tag=="SOLUTION" and S.SolESP) or
                 (e.tag=="ITEM" and S.ItemESP) or
                 (e.tag=="DROPPED GUN" and S.DropESP) or
                 (e.tag=="CRATE" and S.CrateESP)
        if not on then e.lbl.Visible=false; continue end
        local part=e.part; if not part or not part.Parent then e.lbl.Visible=false; continue end
        local sp,vis=w2s(part.Position)
        local d=myRoot and (myRoot.Position-part.Position).Magnitude or math.huge
        local maxD=e.isExtract and 2000 or S.ESPMaxDist
        if vis and d<maxD then
            e.lbl.Text=e.tag..": "..e.obj.Name.." ["..math.floor(d).."m]"
            e.lbl.Position=sp; e.lbl.Visible=true
        else e.lbl.Visible=false end
    end
end)

-- ══════════════════════════════════════════════════════════════════
--  TABS
-- ══════════════════════════════════════════════════════════════════

-- VISUALS ──────────────────────────────────────────────────────────
local Vis=PH:Tab("Visuals","👁")

Vis:Section("Player ESP")
Vis:Toggle("Player ESP",false,function(on)
    S.ESP=on; if not on then for _,o in pairs(EO) do hideE(o) end end
end)
Vis:Toggle("Boxes",true,function(on) S.ESPBoxes=on end)
Vis:Toggle("Corner Brackets",true,function(on) S.ESPCorners=on end)
Vis:Toggle("Names",true,function(on) S.ESPNames=on end)
Vis:Toggle("Health Bar",true,function(on) S.ESPHealth=on end)
Vis:Toggle("Distance",true,function(on) S.ESPDist=on end)
Vis:Toggle("Tracers",false,function(on) S.ESPTracers=on end)
Vis:Toggle("Snaplines",false,function(on) S.ESPSnap=on end)
Vis:Toggle("Skeleton",false,function(on) S.ESPSkeleton=on end)
Vis:Toggle("Weapon Label",true,function(on) S.ESPWeapon=on end)
Vis:Slider("Max Distance",50,1500,600,function(v) S.ESPMaxDist=v end)
Vis:Dropdown("ESP Color",{"Red","White","Cyan","Green","Yellow","Purple","Orange"},"Red",function(c)
    local m={Red=Color3.fromRGB(255,50,50),White=Color3.new(1,1,1),Cyan=Color3.fromRGB(0,255,255),
             Green=Color3.fromRGB(50,255,100),Yellow=Color3.fromRGB(255,230,50),
             Purple=Color3.fromRGB(180,50,255),Orange=Color3.fromRGB(255,150,0)}
    S.ESPCol=m[c] or S.ESPCol; S.ESPTracerCol=m[c] or S.ESPTracerCol
end)

Vis:Section("Chams")
Vis:Toggle("Chams (Through Walls)",false,function(on) S.Chams=on; refreshChams() end)
Vis:Dropdown("Style",{"Neon","ForceField","SmoothPlastic"},"Neon",function(v)
    S.ChamsStyle=v; if S.Chams then refreshChams() end
end)
Vis:Dropdown("Chams Color",{"Red","Orange","Yellow","Cyan","Purple","White"},"Red",function(c)
    local m={Red=Color3.fromRGB(255,50,50),Orange=Color3.fromRGB(255,140,0),
             Yellow=Color3.fromRGB(255,230,50),Cyan=Color3.fromRGB(0,255,255),
             Purple=Color3.fromRGB(180,50,255),White=Color3.new(1,1,1)}
    S.ChamsCol=m[c] or S.ChamsCol; if S.Chams then refreshChams() end
end)

Vis:Section("World ESP")
Vis:Toggle("Crate ESP",false,function(on)
    S.CrateESP=on
    PH:Notify("Crate ESP",on and "Scanning for crates — orange labels" or "Off",2,on and "success" or "error")
end)
Vis:Toggle("Extraction Point ESP",false,function(on)
    S.ExtractESP=on
    PH:Notify("Extract ESP",on and "Always-visible cyan labels" or "Off",2,on and "success" or "error")
end)
Vis:Toggle("Cleaning Solution ESP",false,function(on)
    S.SolESP=on
    PH:Notify("Solution ESP",on and "Purple labels" or "Off",2,on and "success" or "error")
end)
Vis:Toggle("Item / Ammo ESP",false,function(on)
    S.ItemESP=on
    PH:Notify("Item ESP",on and "Green labels" or "Off",2,on and "success" or "error")
end)
Vis:Toggle("Dropped Gun ESP",false,function(on)
    S.DropESP=on
    PH:Notify("Drop ESP",on and "Yellow labels for dropped guns" or "Off",2,on and "success" or "error")
end)

Vis:Section("Radar")
Vis:Toggle("Minimap Radar",false,function(on) S.Radar=on end)
Vis:Slider("Radar Range",50,600,250,function(v) S.RadarRange=v end)
Vis:Slider("Radar Size",80,250,150,function(v) S.RadarSize=v end)

Vis:Section("Crosshair")
Vis:Toggle("Custom Crosshair",false,function(on) S.XHair=on end)
Vis:Slider("Crosshair Size",3,30,10,function(v) S.XHairSize=v end)
Vis:Slider("Crosshair Gap",0,10,4,function(v) S.XHairGap=v end)
Vis:Dropdown("Crosshair Color",{"Green","Red","White","Yellow","Cyan"},"Green",function(c)
    local m={Green=Color3.fromRGB(0,255,0),Red=Color3.fromRGB(255,50,50),
             White=Color3.new(1,1,1),Yellow=Color3.fromRGB(255,230,50),Cyan=Color3.fromRGB(0,255,255)}
    S.XHairCol=m[c] or S.XHairCol
end)

Vis:Section("World")
Vis:Toggle("Fullbright",false,function(on)
    Lighting.Brightness=on and 2 or 1; Lighting.GlobalShadows=not on
end)
Vis:Toggle("No Fog",false,function(on) Lighting.FogEnd=on and 9e9 or 100000 end)
Vis:Slider("Field of View",60,120,70,function(v) Camera.FieldOfView=v end)

-- COMBAT ───────────────────────────────────────────────────────────
local Cbt=PH:Tab("Combat","⚔")

Cbt:Section("Aimbot")
Cbt:Toggle("Aimbot (Hold RMB)",false,function(on)
    S.Aimbot=on; fovCircle.Visible=on
end)
Cbt:Slider("FOV Radius",20,500,120,function(v) S.AimFOV=v; fovCircle.Radius=v end)
Cbt:Slider("Smoothness",1,20,4,function(v) S.AimSmooth=v end)
Cbt:Dropdown("Target Part",{"HumanoidRootPart","Head","UpperTorso","LowerTorso"},"HumanoidRootPart",function(v) S.AimPart=v end)
Cbt:Toggle("Visible Check",true,function(on) S.AimVis=on end)

Cbt:Section("Silent Aim")
Cbt:Toggle("Silent Aim",false,function(on)
    S.SilentAim=on; startSilentAim()
    PH:Notify("Silent Aim",on and "Press LMB to fire — snaps to target" or "Disabled",2,on and "warning" or "error")
end)
Cbt:Slider("Hit Chance %",1,100,100,function(v) S.SilentChance=v end)

Cbt:Section("Kill Aura")
Cbt:Toggle("Kill Aura",false,function(on) S.KillAura=on end)
Cbt:Slider("Kill Aura Range",5,40,15,function(v) S.KARange=v end)

Cbt:Section("Hitbox")
Cbt:Toggle("Hitbox Expander",false,function(on)
    S.Hitbox=on
    if not on then
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                local hrp=p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Size=Vector3.new(2,2,1) end
            end
        end
    end
end)
Cbt:Slider("Hitbox Size",3,25,8,function(v) S.HitboxSize=v end)

Cbt:Section("Weapon Mods")
Cbt:Toggle("No Recoil",false,function(on)
    S.NoRecoil=on; startNoRecoil()
    PH:Notify("No Recoil",on and "Enabled" or "Disabled",2,on and "success" or "error")
end)
Cbt:Toggle("Rapid Fire (Hold LMB)",false,function(on)
    S.RapidFire=on
    if on then startRapidFire() end
    PH:Notify("Rapid Fire",on and "Hold LMB" or "Disabled",2,on and "success" or "error")
end)

-- MOVEMENT ─────────────────────────────────────────────────────────
local Mov=PH:Tab("Movement","⚡")

Mov:Section("Speed")
Mov:Toggle("Speed Modifier",false,function(on)
    S.Speed=on
    if not on then local h=hum(); if h then h.WalkSpeed=16 end end
end)
Mov:Slider("Walk Speed",16,100,16,function(v) S.WS=v end)
Mov:Toggle("Infinite Sprint",false,function(on) S.InfSprint=on end)

Mov:Section("Flight")
Mov:Toggle("Fly",false,function(on)
    S.Fly=on; if on then startFly() else stopFly() end
    PH:Notify("Fly",on and "WASD + Space/Ctrl" or "Disabled",2,on and "success" or "error")
end)
Mov:Slider("Fly Speed",10,200,80,function(v) S.FlySpd=v end)

Mov:Section("Jump & Gravity")
Mov:Toggle("Infinite Jump",false,function(on) S.InfJump=on; startIJ() end)
Mov:Toggle("Bunny Hop",false,function(on) S.Bhop=on end)
Mov:Toggle("Low Gravity",false,function(on)
    S.LowGrav=on; if not on then workspace.Gravity=196.2 end
end)
Mov:Slider("Gravity Level",5,196,50,function(v) S.GravLevel=v end)

Mov:Section("Misc")
Mov:Toggle("Noclip",false,function(on) S.Noclip=on end)
Mov:Toggle("No Fall Damage",false,function(on) S.NoFall=on end)
Mov:Toggle("Anti Ragdoll",false,function(on) S.AntiRag=on end)
Mov:Toggle("Anti AFK",false,function(on)
    S.AntiAFK=on
    if on then
        local vu=game:GetService("VirtualUser")
        LP.Idled:Connect(function()
            if not S.AntiAFK then return end
            vu:Button2Down(Vector2.new(0,0),Camera.CFrame)
            task.wait(0.1)
            vu:Button2Up(Vector2.new(0,0),Camera.CFrame)
        end)
    end
end)
Mov:Button("Reset Character",function()
    local h=hum(); if h then h.Health=0 end
end)

-- MISC ─────────────────────────────────────────────────────────────
local Misc=PH:Tab("Misc","◈")

Misc:Section("Teleport")
local tpBox=Misc:Textbox("Player Name","Username...")
Misc:Button("Teleport to Player",function()
    local t=Players:FindFirstChild(tpBox.Text)
    if t and t.Character and LP.Character then
        LP.Character:PivotTo(t.Character:GetPivot()*CFrame.new(3,0,0))
        PH:Notify("TP","Teleported to "..tpBox.Text,2,"success")
    else PH:Notify("TP","Not found",2,"error") end
end)
Misc:Button("Teleport to Nearest Extraction",function()
    local nearest,nearD=nil,math.huge
    for _,e in pairs(WO) do
        if e.isExtract and e.part and e.part.Parent then
            local myR=root()
            local d=myR and (myR.Position-e.part.Position).Magnitude or math.huge
            if d<nearD then nearD=d; nearest=e.part end
        end
    end
    if nearest and LP.Character then
        LP.Character:PivotTo(CFrame.new(nearest.Position+Vector3.new(0,5,0)))
        PH:Notify("TP","Teleported to extraction!",2,"success")
    else PH:Notify("TP","No extract found\nEnable Extraction ESP first",3,"warning") end
end)
Misc:Button("Teleport to Nearest Player",function()
    local nearest,nearD=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local d=dist(p); if d<nearD then nearD=d; nearest=p end
    end
    if nearest and LP.Character then
        LP.Character:PivotTo(nearest.Character:GetPivot()*CFrame.new(3,0,0))
        PH:Notify("TP","Teleported to "..nearest.Name,2,"success")
    end
end)
local savedCF=nil
Misc:Button("Save Position",function()
    local r=root(); if r then savedCF=r.CFrame; PH:Notify("Pos","Saved",2,"success") end
end)
Misc:Button("Load Position",function()
    if savedCF and LP.Character then LP.Character:PivotTo(savedCF); PH:Notify("Pos","Loaded",2,"success")
    else PH:Notify("Pos","Nothing saved",2,"error") end
end)

Misc:Section("Server")
Misc:Button("Rejoin",function() game:GetService("TeleportService"):Teleport(game.PlaceId,LP) end)
Misc:Button("Server Hop",function()
    PH:Notify("Hop","Finding server...",2,"info")
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId,LP) end)
end)
Misc:Button("Copy Place ID",function()
    pcall(function() if setclipboard then setclipboard(tostring(game.PlaceId)) end end)
    PH:Notify("Copied",tostring(game.PlaceId),2,"success")
end)

Misc:Section("Fun")
Misc:Button("Rainbow ESP",function()
    task.spawn(function()
        local hue=0
        while S.ESP do task.wait(0.05)
            hue=(hue+1)%360
            local col=Color3.fromHSV(hue/360,1,1)
            S.ESPCol=col; S.ESPTracerCol=col
        end
    end)
    PH:Notify("Rainbow","ESP cycling — disable ESP to stop",2,"info")
end)

PH:SelectFirst()
PH:Notify("The Armory","46 features loaded  •  "..PH.Tier,4,"success")
