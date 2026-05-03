--[[
    Phantom Hack — BoogaBooga.lua
    Custom script for Booga Booga (Place ID: 11729688377)
    by Oreo

    Booga Booga specific features:
    • Kill Aura with tool activation bypass
    • Auto Heal (eats food automatically)
    • Auto Farm resources (rocks, trees, bushes)
    • Auto Collect drops
    • Item ESP (ores, drops, gods, mobs)
    • Speed bypass (Heartbeat reapply)
    • Auto Eat / Auto Campfire
    • Tribe invite spam
    • Hitbox expander
]]

local M  = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Le-Oreo/PhantomHack/main/PhantomHack.lua", true
))()
local PH = M.WaitForAuth()

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Camera     = workspace.CurrentCamera
local LP         = Players.LocalPlayer
local Char       = LP.Character or LP.CharacterAdded:Wait()

local function getHum(p)  local c=(p or LP).Character;return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot(p) local c=(p or LP).Character;return c and c:FindFirstChild("HumanoidRootPart") end
local function getDist(p) local a,b=getRoot(LP),getRoot(p);if not a or not b then return math.huge end;return (a.Position-b.Position).Magnitude end
local function isAlive(p) local h=getHum(p);return h and h.Health>0 end
local function isTeam(p)
    -- Booga Booga uses Tribe system not Roblox teams
    local myTribe = LP.Character and LP.Character:FindFirstChild("TribeName")
    local theirTribe = p.Character and p.Character:FindFirstChild("TribeName")
    if not myTribe or not theirTribe then return false end
    return myTribe.Value == theirTribe.Value and myTribe.Value ~= "" and myTribe.Value ~= "NoTribe"
end

-- ══════════════════════════════════════════════════════════════
--  ESP (Players + Items)
-- ══════════════════════════════════════════════════════════════
local ESPState = {
    players=false, items=false, ores=false, drops=false,
    mobs=false, boxes=true, names=true, health=true,
    dist=true, tracers=false, teamCheck=true, maxDist=800,
    boxCol=Color3.fromRGB(255,50,50),
}
local ESPObjects = {}
local ItemESP    = {}

local function w2s(pos)
    local sp,vis=Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X,sp.Y),vis
end
local function newLine(col,th) local l=Drawing.new("Line");l.Color=col or Color3.new(1,1,1);l.Thickness=th or 1;l.Visible=false;return l end
local function newText(str,col,sz) local t=Drawing.new("Text");t.Text=str or "";t.Color=col or Color3.new(1,1,1);t.Size=sz or 13;t.Center=true;t.Outline=true;t.OutlineColor=Color3.new(0,0,0);t.Visible=false;return t end

local function makePlayerESP(p)
    return {
        bT=newLine(ESPState.boxCol),bB=newLine(ESPState.boxCol),
        bL=newLine(ESPState.boxCol),bR=newLine(ESPState.boxCol),
        name=newText(p.Name,Color3.new(1,1,1),13),
        dist=newText("",Color3.fromRGB(200,200,200),11),
        hBG=newLine(Color3.new(0,0,0),4),
        hBar=newLine(Color3.fromRGB(50,255,100),3),
        tracer=newLine(ESPState.boxCol,1),
    }
end
local function hideESP(o) if not o then return end;for _,v in pairs(o) do pcall(function() v.Visible=false end) end end
local function removeESP(o) if not o then return end;for _,v in pairs(o) do pcall(function() v:Remove() end) end end

-- Init player ESP objects immediately and on join
local function initPlayerESP(p)
    if p==LP then return end
    ESPObjects[p.Name]=makePlayerESP(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if ESPObjects[p.Name] then removeESP(ESPObjects[p.Name]) end
        ESPObjects[p.Name]=makePlayerESP(p)
    end)
end
for _,p in ipairs(Players:GetPlayers()) do initPlayerESP(p) end
Players.PlayerAdded:Connect(initPlayerESP)
Players.PlayerRemoving:Connect(function(p)
    if ESPObjects[p.Name] then removeESP(ESPObjects[p.Name]);ESPObjects[p.Name]=nil end
end)

local function getBounds(char)
    local hrp=char:FindFirstChild("HumanoidRootPart")
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return nil end
    local h=hum.HipHeight*2+1
    local top,ton=w2s(hrp.Position+Vector3.new(0,h/2,0))
    local bot,bon=w2s(hrp.Position-Vector3.new(0,h/2,0))
    if not ton and not bon then return nil end
    local ht=math.abs(top.Y-bot.Y);local w=ht*0.45
    return {tl=Vector2.new(top.X-w,top.Y),tr=Vector2.new(top.X+w,top.Y),
            bl=Vector2.new(bot.X-w,bot.Y),br=Vector2.new(bot.X+w,bot.Y),
            tc=top,bc=bot,w=w,h=ht,hum=hum}
end

-- Booga Booga item categories to ESP
local ORE_NAMES   = {"Rock","IronRock","GoldRock","DiamondRock","EmeraldRock","RubyRock","OnyxRock"}
local MOB_NAMES   = {"Crab","Scorpion","Spider","BigCrab","God","GodBoss"}
local DROP_TAGS   = {"Dropped","ItemFrame","PickupPart"}

RunService.RenderStepped:Connect(function()
    -- Player ESP
    if ESPState.players then
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            if not ESPObjects[p.Name] then initPlayerESP(p) end
            local o=ESPObjects[p.Name]
            local char=p.Character; local hum=getHum(p)
            if not char or not hum or hum.Health<=0
            or (ESPState.teamCheck and isTeam(p))
            or getDist(p)>ESPState.maxDist then hideESP(o);continue end
            local b=getBounds(char); if not b then hideESP(o);continue end
            o.bT.From=b.tl;o.bT.To=b.tr;o.bT.Color=ESPState.boxCol;o.bT.Visible=ESPState.boxes
            o.bB.From=b.bl;o.bB.To=b.br;o.bB.Color=ESPState.boxCol;o.bB.Visible=ESPState.boxes
            o.bL.From=b.tl;o.bL.To=b.bl;o.bL.Color=ESPState.boxCol;o.bL.Visible=ESPState.boxes
            o.bR.From=b.tr;o.bR.To=b.br;o.bR.Color=ESPState.boxCol;o.bR.Visible=ESPState.boxes
            if ESPState.names then o.name.Text=p.Name;o.name.Position=Vector2.new(b.tc.X,b.tc.Y-16);o.name.Visible=true else o.name.Visible=false end
            if ESPState.dist  then o.dist.Text="["..math.floor(getDist(p)).."m]";o.dist.Position=Vector2.new(b.bc.X,b.bc.Y+4);o.dist.Visible=true else o.dist.Visible=false end
            if ESPState.health then
                local pct=math.clamp(b.hum.Health/b.hum.MaxHealth,0,1)
                local bx=b.tl.X-5
                o.hBG.From=Vector2.new(bx,b.tl.Y);o.hBG.To=Vector2.new(bx,b.bl.Y);o.hBG.Visible=true
                o.hBar.From=Vector2.new(bx,b.bl.Y);o.hBar.To=Vector2.new(bx,b.bl.Y-b.h*pct)
                o.hBar.Color=Color3.new(math.clamp(2-pct*2,0,1),math.clamp(pct*2,0,1),0);o.hBar.Visible=true
            else o.hBG.Visible=false;o.hBar.Visible=false end
            if ESPState.tracers then
                local vs=Camera.ViewportSize
                o.tracer.From=Vector2.new(vs.X/2,vs.Y);o.tracer.To=b.bc;o.tracer.Color=ESPState.boxCol;o.tracer.Visible=true
            else o.tracer.Visible=false end
        end
    else for _,o in pairs(ESPObjects) do hideESP(o) end end

    -- Item / Ore / Mob ESP (text labels on world objects)
    if ESPState.ores or ESPState.drops or ESPState.mobs then
        -- Clean up removed items
        for k,lbl in pairs(ItemESP) do
            pcall(function()
                if not lbl.obj or not lbl.obj.Parent then lbl.draw:Remove();ItemESP[k]=nil end
            end)
        end
        for _,obj in ipairs(workspace:GetDescendants()) do
            local id=tostring(obj)
            if ItemESP[id] then continue end

            local isOre  = ESPState.ores  and obj:IsA("Model") and table.find(ORE_NAMES, obj.Name)
            local isMob  = ESPState.mobs  and obj:IsA("Model") and table.find(MOB_NAMES, obj.Name)
            local isDrop = ESPState.drops and (obj:IsA("BasePart") or obj:IsA("Model")) and obj.Name=="Dropped"

            if isOre or isMob or isDrop then
                local col = isOre and Color3.fromRGB(255,210,50)
                         or isMob and Color3.fromRGB(255,80,80)
                         or Color3.fromRGB(100,255,100)
                local lbl=newText(obj.Name,col,12)
                ItemESP[id]={obj=obj,draw=lbl}
            end
        end

        for _,entry in pairs(ItemESP) do
            pcall(function()
                local obj=entry.obj; local lbl=entry.draw
                local part=obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
                if not part then lbl.Visible=false;return end
                local sp,vis=w2s(part.Position)
                local hrp=getRoot(LP)
                local d=hrp and (hrp.Position-part.Position).Magnitude or math.huge
                if vis and d<ESPState.maxDist then
                    lbl.Text=obj.Name.." ["..math.floor(d).."m]"
                    lbl.Position=sp; lbl.Visible=true
                else lbl.Visible=false end
            end)
        end
    else for _,e in pairs(ItemESP) do pcall(function() e.draw.Visible=false end) end end
end)

-- ══════════════════════════════════════════════════════════════
--  MOVEMENT (Heartbeat bypass for server correction)
-- ══════════════════════════════════════════════════════════════
local MoveState={speed=false,ws=16,jump=50,fly=false,flySpd=60,noclip=false,infJump=false}
local movLoop
local function startMovLoop()
    if movLoop then movLoop:Disconnect() end
    movLoop=RunService.Heartbeat:Connect(function()
        local char=LP.Character;if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid");if not hum then return end
        if MoveState.speed   then hum.WalkSpeed=MoveState.ws end
        if MoveState.jump~=50 then hum.JumpPower=MoveState.jump end
        if MoveState.noclip  then for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
    end)
end
startMovLoop()

local flyConn,flyBV,flyBG
local function stopFly()
    if flyConn then flyConn:Disconnect();flyConn=nil end
    pcall(function() if flyBV then flyBV:Destroy();flyBV=nil end end)
    pcall(function() if flyBG then flyBG:Destroy();flyBG=nil end end)
    local hum=getHum(LP);if hum then hum.PlatformStand=false;hum.AutoRotate=true end
end
local function startFly()
    stopFly();if not MoveState.fly then return end
    local hrp=getRoot(LP);local hum=getHum(LP)
    if not hrp or not hum then return end
    hum.PlatformStand=true;hum.AutoRotate=false
    flyBV=Instance.new("BodyVelocity");flyBV.MaxForce=Vector3.new(1e5,1e5,1e5);flyBV.Velocity=Vector3.new(0,0,0);flyBV.Parent=hrp
    flyBG=Instance.new("BodyGyro");flyBG.MaxTorque=Vector3.new(1e5,1e5,1e5);flyBG.P=1e4;flyBG.CFrame=hrp.CFrame;flyBG.Parent=hrp
    flyConn=RunService.RenderStepped:Connect(function()
        if not MoveState.fly then stopFly();return end
        local cam=Camera.CFrame;local v=Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then v=v+cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then v=v-cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then v=v-cam.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then v=v+cam.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space)       then v=v+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then v=v-Vector3.new(0,1,0) end
        if v.Magnitude>0 then flyBV.Velocity=v.Unit*MoveState.flySpd;flyBG.CFrame=CFrame.new(hrp.Position,hrp.Position+v)
        else flyBV.Velocity=Vector3.new(0,0,0);flyBG.CFrame=hrp.CFrame end
    end)
end

local ijConn
local function startIJ()
    if ijConn then ijConn:Disconnect() end
    if not MoveState.infJump then return end
    ijConn=UIS.JumpRequest:Connect(function()
        if not MoveState.infJump then ijConn:Disconnect();return end
        local h=getHum(LP);if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end

LP.CharacterAdded:Connect(function()
    task.wait(0.5);startMovLoop()
    if MoveState.fly     then startFly() end
    if MoveState.infJump then startIJ()  end
end)

-- ══════════════════════════════════════════════════════════════
--  BOOGA BOOGA SPECIFIC FEATURES
-- ══════════════════════════════════════════════════════════════

-- Kill Aura — uses tool Activate() like real click
local KAState={on=false,range=15,tribe=true}
local kaConn
RunService.Heartbeat:Connect(function()
    if not KAState.on then return end
    local char=LP.Character;if not char then return end
    local tool=char:FindFirstChildOfClass("Tool");if not tool then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP or not isAlive(p) then continue end
        if KAState.tribe and isTeam(p) then continue end
        if getDist(p)<=KAState.range then pcall(function() tool:Activate() end) end
    end
end)

-- Hitbox Expander — increases HRP size so melee is easier to hit
local HBState={on=false,size=6}
local origSizes={}
local function applyHitbox(on)
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local char=p.Character;if not char then continue end
        local hrp=char:FindFirstChild("HumanoidRootPart");if not hrp then continue end
        if on then
            if not origSizes[p.Name] then origSizes[p.Name]=hrp.Size end
            hrp.Size=Vector3.new(HBState.size,HBState.size,HBState.size)
        else
            if origSizes[p.Name] then hrp.Size=origSizes[p.Name];origSizes[p.Name]=nil end
        end
    end
end
RunService.Heartbeat:Connect(function()
    if HBState.on then applyHitbox(true) end
end)

-- Auto Heal — finds food in backpack and eats it
local autoHeal={on=false,threshold=60}
RunService.Heartbeat:Connect(function()
    if not autoHeal.on then return end
    local hum=getHum(LP);if not hum or hum.Health>=autoHeal.threshold then return end
    local bp=LP:FindFirstChild("Backpack");if not bp then return end
    for _,tool in ipairs(bp:GetChildren()) do
        -- Food items in Booga Booga have a "Hunger" value or are tagged as food
        local isFood=tool:FindFirstChild("Hunger") or tool:FindFirstChild("Food")
            or tool.Name:find("Berry") or tool.Name:find("Meat")
            or tool.Name:find("Fish") or tool.Name:find("Bread")
            or tool.Name:find("Apple") or tool.Name:find("Banana")
        if isFood then
            -- Equip and use
            tool.Parent=LP.Character
            task.wait(0.1)
            pcall(function() tool:Activate() end)
            task.wait(0.5)
            if tool.Parent==LP.Character then
                tool.Parent=bp
            end
            break
        end
    end
end)

-- Auto Farm — mines nearby resources (rocks, trees, bushes)
local farmState={on=false,range=20,rocks=true,trees=true,bushes=true}
local FARM_TAGS={Rock=true,IronRock=true,GoldRock=true,DiamondRock=true,
                 EmeraldRock=true,RubyRock=true,OnyxRock=true,
                 Tree=true,Bush=true,Log=true}
RunService.Heartbeat:Connect(function()
    if not farmState.on then return end
    local char=LP.Character;if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart");if not hrp then return end
    local tool=char:FindFirstChildOfClass("Tool");if not tool then return end
    for _,obj in ipairs(workspace:GetDescendants()) do
        if not obj:IsA("BasePart") then continue end
        if not FARM_TAGS[obj.Parent and obj.Parent.Name or ""] and not FARM_TAGS[obj.Name] then continue end
        local dist=(hrp.Position-obj.Position).Magnitude
        if dist<=farmState.range then
            pcall(function() tool:Activate() end)
            break
        end
    end
end)

-- Auto Collect — picks up nearby dropped items
local collectState={on=false,range=15}
RunService.Heartbeat:Connect(function()
    if not collectState.on then return end
    local hrp=getRoot(LP);if not hrp then return end
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj.Name=="Dropped" or (obj:IsA("Model") and obj:FindFirstChild("PickupPart")) then
            local part=obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
            if part then
                local dist=(hrp.Position-part.Position).Magnitude
                if dist<=collectState.range then
                    -- Teleport to pick up (Booga Booga proximity pickup)
                    LP.Character:PivotTo(CFrame.new(part.Position+Vector3.new(0,3,0)))
                end
            end
        end
    end
end)

-- Auto Eat at Campfire — finds campfire and cooks food
local campfireState={on=false}
RunService.Heartbeat:Connect(function()
    if not campfireState.on then return end
    local hrp=getRoot(LP);if not hrp then return end
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj.Name=="Campfire" or obj.Name=="CampfirePart" then
            local part=obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
            if part and (hrp.Position-part.Position).Magnitude<10 then
                -- interact
                pcall(function()
                    local re=obj:FindFirstChild("RemoteEvent") or obj.Parent:FindFirstChild("RemoteEvent")
                    if re then re:FireServer("Cook") end
                end)
                break
            end
        end
    end
end)

-- Tribe Invite Spammer
local inviteState={on=false}
local function spamInvites()
    if not inviteState.on then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        pcall(function()
            local re=workspace:FindFirstChild("TribeRemote") or game:GetService("ReplicatedStorage"):FindFirstChild("TribeRemote")
            if re then re:FireServer("Invite",p) end
        end)
    end
    task.delay(2,function() if inviteState.on then spamInvites() end end)
end

-- ══════════════════════════════════════════════════════════════
--  BUILD TABS
-- ══════════════════════════════════════════════════════════════

-- VISUALS
local Vis=PH:Tab("Visuals","👁")
Vis:Section("Player ESP")
Vis:Toggle("Player ESP",false,function(on) ESPState.players=on end)
Vis:Toggle("Boxes",true,function(on) ESPState.boxes=on end)
Vis:Toggle("Names",true,function(on) ESPState.names=on end)
Vis:Toggle("Health Bar",true,function(on) ESPState.health=on end)
Vis:Toggle("Distance",true,function(on) ESPState.dist=on end)
Vis:Toggle("Tracers",false,function(on) ESPState.tracers=on end)
Vis:Toggle("Tribe Check",true,function(on) ESPState.teamCheck=on end)
Vis:Slider("Max Distance",100,2000,800,function(v) ESPState.maxDist=v end)
Vis:Section("World ESP")
Vis:Toggle("Ore ESP",false,function(on) ESPState.ores=on end)
Vis:Toggle("Drop ESP",false,function(on) ESPState.drops=on end)
Vis:Toggle("Mob ESP",false,function(on) ESPState.mobs=on end)
Vis:Section("World")
Vis:Toggle("Fullbright",false,function(on) local L=game:GetService("Lighting");L.Brightness=on and 2 or 1;L.GlobalShadows=not on end)
Vis:Toggle("No Fog",false,function(on) game:GetService("Lighting").FogEnd=on and 9e9 or 100000 end)
Vis:Slider("Field of View",60,120,70,function(v) Camera.FieldOfView=v end)

-- COMBAT
local Cbt=PH:Tab("Combat","⚔")
Cbt:Section("Kill Aura")
Cbt:Toggle("Kill Aura",false,function(on) KAState.on=on end)
Cbt:Slider("Kill Aura Range",3,30,15,function(v) KAState.range=v end)
Cbt:Toggle("Tribe Check",true,function(on) KAState.tribe=on end)
Cbt:Section("Hitbox Expander")
Cbt:Toggle("Hitbox Expander",false,function(on) HBState.on=on;if not on then applyHitbox(false) end end)
Cbt:Slider("Hitbox Size",3,20,6,function(v) HBState.size=v end)
Cbt:Section("Auto Heal")
Cbt:Toggle("Auto Heal",false,function(on) autoHeal.on=on end)
Cbt:Slider("Heal Below HP %",10,99,60,function(v) autoHeal.threshold=getHum(LP) and getHum(LP).MaxHealth*(v/100) or v end)

-- MOVEMENT
local Mov=PH:Tab("Movement","⚡")
Mov:Section("Speed")
Mov:Toggle("Speed Modifier",false,function(on) MoveState.speed=on;if not on then local h=getHum(LP);if h then h.WalkSpeed=16 end end end)
Mov:Slider("Walk Speed",16,150,16,function(v) MoveState.ws=v end)
Mov:Slider("Jump Power",50,300,50,function(v) MoveState.jump=v end)
Mov:Section("Flight")
Mov:Toggle("Fly",false,function(on) MoveState.fly=on;if on then startFly() else stopFly() end end)
Mov:Slider("Fly Speed",10,200,60,function(v) MoveState.flySpd=v end)
Mov:Section("Misc")
Mov:Toggle("Noclip",false,function(on) MoveState.noclip=on end)
Mov:Toggle("Infinite Jump",false,function(on) MoveState.infJump=on;startIJ() end)
Mov:Button("Reset Character",function() local h=getHum(LP);if h then h.Health=0 end end)

-- FARM
local Frm=PH:Tab("Farm","🌾")
Frm:Section("Auto Farm")
Frm:Toggle("Auto Farm",false,function(on) farmState.on=on end)
Frm:Slider("Farm Range",5,50,20,function(v) farmState.range=v end)
Frm:Toggle("Mine Rocks",true,function(on) farmState.rocks=on end)
Frm:Toggle("Chop Trees",true,function(on) farmState.trees=on end)
Frm:Toggle("Cut Bushes",true,function(on) farmState.bushes=on end)
Frm:Section("Auto Collect")
Frm:Toggle("Auto Collect Drops",false,function(on) collectState.on=on end)
Frm:Slider("Collect Range",5,30,15,function(v) collectState.range=v end)
Frm:Section("Campfire")
Frm:Toggle("Auto Campfire",false,function(on) campfireState.on=on end)
Frm:Section("Tribe")
Frm:Toggle("Tribe Invite Spam",false,function(on)
    inviteState.on=on
    if on then spamInvites() end
    PH:Notify("Tribe Spam",on and "Sending invites..." or "Stopped",2,on and "info" or "error")
end)

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

PH:SelectFirst()
PH:Notify("Booga Booga","Game script loaded  •  "..PH.Tier,4,"success")
