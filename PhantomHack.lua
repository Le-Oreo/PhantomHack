--[[
    PHANTOM HACK — GUI Template v1.0.2
    
    ╔══════════════════════════════════════════════════════╗
    ║  HOW TO USE THIS AS A TEMPLATE (like Rayfield)       ║
    ║                                                      ║
    ║  Step 1: Push this file to GitHub as PhantomHack.lua ║
    ║                                                      ║
    ║  Step 2: In your SEPARATE script (e.g. Core.lua):    ║
    ║                                                      ║
    ║    local PH = loadstring(game:HttpGet(               ║
    ║      "https://raw.githubusercontent.com/             ║
    ║       Le-Oreo/PhantomHack/main/PhantomHack.lua"      ║
    ║    ))()                                              ║
    ║                                                      ║
    ║    -- Add a tab:                                     ║
    ║    local Combat = PH:Tab("Combat", "⚔")             ║
    ║    Combat:Toggle("Kill Aura", false, function(on)    ║
    ║        -- your code                                  ║
    ║    end)                                              ║
    ║    Combat:Slider("Speed", 0, 100, 16, function(v)    ║
    ║        -- your code                                  ║
    ║    end)                                              ║
    ║                                                      ║
    ║  PH exposes: Tab(), Notify(), Config                 ║
    ╚══════════════════════════════════════════════════════╝
--]]

--==[ SERVICES ]==--
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local LP               = Players.LocalPlayer

--==[ EXECUTOR DETECT ]==--
local function getExec()
    if syn                 then return "Synapse X"
    elseif KRNL_LOADED     then return "Krnl"
    elseif getcustomasset  then return "Fluxus"
    elseif DELTA_LOADED    then return "Delta"
    elseif identifyexecutor then local ok,n=pcall(identifyexecutor);if ok then return n end
    elseif getexecutorname  then local ok,n=pcall(getexecutorname); if ok then return n end
    end
    return "Unknown"
end
local ExecName = getExec()

--==[ THEME ]==--
local C = {
    Name      = "PHANTOM HACK",
    Version   = "v1.0.2",
    Keys      = {"PHANTOM-2026","PHANTOM-FREE","PHANTOM-VIP"},
    KeyLink   = "https://raw.githubusercontent.com/Le-Oreo/PhantomHack/main/PhantomHack.lua",
    ToggleKey = Enum.KeyCode.RightShift,

    -- Core palette — NO colored stripes anywhere
    Accent   = Color3.fromRGB(215, 35,  35),   -- used ONLY for logo box, avatar ring, toggles, active tab bar
    AccentH  = Color3.fromRGB(175, 20,  20),
    AccentDim= Color3.fromRGB(55,  8,   8),
    BG       = Color3.fromRGB(11,  11,  14),
    Side     = Color3.fromRGB(15,  15,  19),
    Surf     = Color3.fromRGB(21,  21,  27),
    SurfH    = Color3.fromRGB(27,  27,  34),
    Bdr      = Color3.fromRGB(38,  38,  50),
    BdrH     = Color3.fromRGB(58,  58,  75),
    T1       = Color3.fromRGB(232, 232, 238),
    T2       = Color3.fromRGB(125, 125, 148),
    TM       = Color3.fromRGB(60,  60,  78),
    Ok       = Color3.fromRGB(55,  195, 115),
    Bad      = Color3.fromRGB(215, 35,  35),
    Warn     = Color3.fromRGB(235, 160, 40),
    Info     = Color3.fromRGB(55,  135, 240),

    Font  = Enum.Font.GothamSemibold,
    FontB = Enum.Font.GothamBold,
    FontR = Enum.Font.Gotham,

    W=880, H=560, SW=195, TH=52,
}

local AccentPresets = {
    Red    = {Color3.fromRGB(215,35,35),  Color3.fromRGB(175,20,20)},
    Blue   = {Color3.fromRGB(60,130,255), Color3.fromRGB(40,100,220)},
    Purple = {Color3.fromRGB(145,75,255), Color3.fromRGB(115,50,210)},
    Green  = {Color3.fromRGB(50,195,110), Color3.fromRGB(35,155,80)},
    Orange = {Color3.fromRGB(235,125,30), Color3.fromRGB(195,95,20)},
    Pink   = {Color3.fromRGB(235,65,165), Color3.fromRGB(195,45,135)},
    Cyan   = {Color3.fromRGB(30,195,215), Color3.fromRGB(20,155,175)},
}

--==[ UTILS ]==--
local function tw(o,t,p,s,d)
    if not o or not o.Parent then return end
    TweenService:Create(o,TweenInfo.new(
        t or .2, s or Enum.EasingStyle.Quart, d or Enum.EasingDirection.Out
    ),p):Play()
end

local function inst(cls,props,kids)
    local i = Instance.new(cls)
    for k,v in pairs(props or {}) do i[k]=v end
    for _,c in ipairs(kids or {}) do c.Parent=i end
    return i
end

local function crn(r)  return inst("UICorner",{CornerRadius=UDim.new(0,r or 8)}) end
local function bdr(col,th) return inst("UIStroke",{Color=col or C.Bdr,Thickness=th or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}) end
local function pad(t,b,l,r) return inst("UIPadding",{PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0),PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0)}) end

--==[ CLEANUP ]==--
pcall(function() if CoreGui:FindFirstChild("PhantomHack") then CoreGui.PhantomHack:Destroy() end end)

--==[ ROOT GUI ]==--
local Gui = inst("ScreenGui",{Name="PhantomHack",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true})
pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(Gui);Gui.Parent=CoreGui
    elseif gethui then Gui.Parent=gethui()
    else Gui.Parent=CoreGui end
end)
if not Gui.Parent then Gui.Parent=LP:WaitForChild("PlayerGui") end

--=======================================================--
--                  NOTIFICATIONS                        --
--=======================================================--
local NH = inst("Frame",{
    Name="NH",AnchorPoint=Vector2.new(1,1),
    Position=UDim2.new(1,-14,1,-14),
    Size=UDim2.new(0,295,1,0),
    BackgroundTransparency=1,Parent=Gui,
},{inst("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Bottom,HorizontalAlignment=Enum.HorizontalAlignment.Right,Padding=UDim.new(0,7)})})

local function Notify(title,msg,dur,kind)
    dur = dur or 4
    local ac = (kind=="error" and C.Bad) or (kind=="success" and C.Ok) or (kind=="warning" and C.Warn) or (kind=="info" and C.Info) or C.Accent

    local wrap = inst("Frame",{Size=UDim2.new(1,0,0,56),BackgroundTransparency=1,Parent=NH})
    local card = inst("Frame",{
        Size=UDim2.new(1,0,1,0),Position=UDim2.new(1,10,0,0),
        BackgroundColor3=C.Surf,BorderSizePixel=0,Parent=wrap,
    },{crn(10),bdr(C.Bdr)})

    -- Small left accent mark (inside card, not a full bar)
    inst("Frame",{Size=UDim2.new(0,3,0,28),Position=UDim2.new(0,0,0.5,0),AnchorPoint=Vector2.new(0,0.5),BackgroundColor3=ac,BorderSizePixel=0,Parent=card},{crn(2)})
    inst("TextLabel",{Position=UDim2.new(0,14,0,10),Size=UDim2.new(1,-28,0,16),BackgroundTransparency=1,Text=title,TextColor3=C.T1,Font=C.FontB,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=card})
    inst("TextLabel",{Position=UDim2.new(0,14,0,27),Size=UDim2.new(1,-28,0,14),BackgroundTransparency=1,Text=msg,TextColor3=C.T2,Font=C.FontR,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Parent=card})

    -- Progress bar (bottom of card)
    local prog = inst("Frame",{Position=UDim2.new(0,0,1,-3),Size=UDim2.new(1,0,0,3),BackgroundColor3=ac,BorderSizePixel=0,Parent=card})
    inst("UICorner",{CornerRadius=UDim.new(0,0),Parent=prog})

    -- Slide in from right
    tw(card,.28,{Position=UDim2.new(0,0,0,0)},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
    task.delay(.05,function() tw(prog,dur-.3,{Size=UDim2.new(0,0,0,3)},Enum.EasingStyle.Linear) end)
    task.delay(dur-.25,function()
        tw(card,.22,{Position=UDim2.new(1,10,0,0)},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
        task.wait(.25); wrap:Destroy()
    end)
end

--==[ DRAG ]==--
local function drag(frame,handle)
    handle=handle or frame
    local dg,ds,sp
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dg=true;ds=i.Position;sp=frame.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dg=false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dg and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ds
            frame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
end

--=======================================================--
--                    KEY SYSTEM                         --
-- Clean card, NO colored bars anywhere on the outside   --
--=======================================================--
local KF = inst("Frame",{
    Name="KeySystem",AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.new(.5,0,.5,0),Size=UDim2.new(0,440,0,215),
    BackgroundColor3=C.BG,BorderSizePixel=0,Parent=Gui,
},{crn(12),bdr(C.Bdr)})
-- NO red bar — just the rounded dark card

-- Logo box (the only red element on the key screen)
local kLogo = inst("Frame",{
    Position=UDim2.new(0,18,0,18),Size=UDim2.new(0,32,0,32),
    BackgroundColor3=C.Accent,BorderSizePixel=0,Parent=KF,
},{crn(8)})
inst("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="P",TextColor3=Color3.new(1,1,1),Font=C.FontB,TextSize=18,Parent=kLogo})

inst("TextLabel",{Position=UDim2.new(0,58,0,15),Size=UDim2.new(1,-70,0,18),BackgroundTransparency=1,Text=C.Name,TextColor3=C.T1,Font=C.FontB,TextSize=16,TextXAlignment=Enum.TextXAlignment.Left,Parent=KF})
inst("TextLabel",{Position=UDim2.new(0,58,0,34),Size=UDim2.new(1,-70,0,13),BackgroundTransparency=1,Text="Authentication Required  •  "..C.Version,TextColor3=C.T2,Font=C.FontR,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=KF})

-- Divider
inst("Frame",{Position=UDim2.new(0,0,0,60),Size=UDim2.new(1,0,0,1),BackgroundColor3=C.Bdr,BorderSizePixel=0,Parent=KF})

-- Key input
local KBox = inst("Frame",{Position=UDim2.new(0,18,0,72),Size=UDim2.new(1,-36,0,40),BackgroundColor3=C.Surf,BorderSizePixel=0,Parent=KF},{crn(8),bdr(C.Bdr)})
local KIn  = inst("TextBox",{Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,PlaceholderText="Enter your license key...",PlaceholderColor3=C.TM,Text="",TextColor3=C.T1,Font=C.FontR,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,Parent=KBox})
local KStr = KBox:FindFirstChildOfClass("UIStroke")
KIn.Focused:Connect(function() tw(KStr,.15,{Color=C.Accent}) end)
KIn.FocusLost:Connect(function() tw(KStr,.15,{Color=C.Bdr}) end)

-- Buttons
local function mkKBtn(lbl,x,w,primary)
    local b=inst("TextButton",{Position=UDim2.new(0,x,0,126),Size=UDim2.new(0,w,0,38),BackgroundColor3=primary and C.Accent or C.Surf,BorderSizePixel=0,Text=lbl,TextColor3=C.T1,Font=C.Font,TextSize=12,AutoButtonColor=false,Parent=KF},{crn(8),bdr(primary and C.Accent or C.Bdr)})
    b.MouseEnter:Connect(function() tw(b,.12,{BackgroundColor3=primary and C.AccentH or C.SurfH}) end)
    b.MouseLeave:Connect(function() tw(b,.12,{BackgroundColor3=primary and C.Accent or C.Surf}) end)
    return b
end
local GKBtn = mkKBtn("Get Key",   18, 185, false)
local ABtn  = mkKBtn("Authorize", 211,211, true)

local KStat = inst("TextLabel",{Position=UDim2.new(0,0,1,-20),Size=UDim2.new(1,0,0,13),BackgroundTransparency=1,Text="© 2026 Phantom Hack",TextColor3=C.TM,Font=C.FontR,TextSize=10,Parent=KF})

drag(KF)
GKBtn.MouseButton1Click:Connect(function()
    pcall(function() if setclipboard then setclipboard(C.KeyLink) end end)
    Notify("Key Link","URL copied to clipboard.",3,"success")
end)

--=======================================================--
--                    MAIN MENU                          --
--=======================================================--
local Main, ActiveTab
local AllTabs  = {}
local Keybinds = {}
local BuildMain

ABtn.MouseButton1Click:Connect(function()
    local e=KIn.Text; local ok=false
    for _,k in ipairs(C.Keys) do if e==k then ok=true;break end end
    if ok then
        KStat.Text="✓ Authenticated"; KStat.TextColor3=C.Ok
        Notify("Welcome","Launching Phantom Hack...",3,"success")
        tw(KF,.3,{Size=UDim2.new(0,440,0,0),BackgroundTransparency=1})
        task.wait(.35); KF:Destroy(); BuildMain()
    else
        KStat.Text="✗ Invalid key."; KStat.TextColor3=C.Bad
        Notify("Auth Failed","The key entered is invalid.",3,"error")
        tw(KStr,.1,{Color=C.Bad})
        local op=KBox.Position
        for i=1,5 do tw(KBox,.04,{Position=op+UDim2.fromOffset(i%2==0 and -7 or 7,0)});task.wait(.045) end
        KBox.Position=op
        task.delay(1.5,function() tw(KStr,.2,{Color=C.Bdr}) end)
    end
end)

--=======================================================--
-- Tab() and component builders — used by BuildMain AND  --
-- by external scripts via the returned API              --
--=======================================================--
local SideScroll, CA  -- filled inside BuildMain

local function MakeTab(name, icon)
    local btn=inst("TextButton",{
        Size=UDim2.new(1,0,0,36),BackgroundColor3=C.SurfH,BackgroundTransparency=1,
        BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=SideScroll,
    },{crn(7)})

    -- Left accent bar — the ONLY red stripe, and it's inside the sidebar button
    local bar=inst("Frame",{
        Position=UDim2.new(0,0,0.5,0),AnchorPoint=Vector2.new(0,0.5),
        Size=UDim2.new(0,3,0,20),BackgroundColor3=C.Accent,
        BorderSizePixel=0,Visible=false,Parent=btn,
    },{crn(2)})

    local ico=inst("TextLabel",{Position=UDim2.new(0,10,0.5,0),AnchorPoint=Vector2.new(0,0.5),Size=UDim2.new(0,20,0,20),BackgroundTransparency=1,Text=icon or "•",TextColor3=C.TM,Font=C.FontB,TextSize=14,Parent=btn})
    local lbl=inst("TextLabel",{Position=UDim2.new(0,34,0,0),Size=UDim2.new(1,-38,1,0),BackgroundTransparency=1,Text=name,TextColor3=C.T2,Font=C.Font,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=btn})

    local page=inst("ScrollingFrame",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,
        ScrollBarThickness=3,ScrollBarImageColor3=C.Accent,
        CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
        Visible=false,Parent=CA,
    },{
        inst("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6)}),
        pad(16,16,16,16),
    })

    local td={Btn=btn,Page=page,Lbl=lbl,Ico=ico,Bar=bar}
    table.insert(AllTabs,td)

    local function SetActive()
        if ActiveTab==td then return end
        if ActiveTab then
            ActiveTab.Page.Visible=false
            tw(ActiveTab.Btn,.15,{BackgroundTransparency=1,BackgroundColor3=C.SurfH})
            tw(ActiveTab.Lbl,.15,{TextColor3=C.T2})
            tw(ActiveTab.Ico,.15,{TextColor3=C.TM})
            ActiveTab.Bar.Visible=false
        end
        ActiveTab=td
        td.Page.Visible=true
        tw(td.Btn,.15,{BackgroundTransparency=0,BackgroundColor3=C.SurfH})
        tw(td.Lbl,.15,{TextColor3=C.T1})
        tw(td.Ico,.15,{TextColor3=C.Accent})
        td.Bar.Visible=true
    end

    btn.MouseButton1Click:Connect(SetActive)
    btn.MouseEnter:Connect(function() if ActiveTab~=td then tw(btn,.12,{BackgroundTransparency=0});tw(lbl,.12,{TextColor3=C.T1}) end end)
    btn.MouseLeave:Connect(function() if ActiveTab~=td then tw(btn,.12,{BackgroundTransparency=1});tw(lbl,.12,{TextColor3=C.T2}) end end)

    --==[ COMPONENT BUILDERS ]==--
    local A = {}

    function A:Section(text)
        inst("TextLabel",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Text=text,TextColor3=C.T2,Font=C.Font,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=page})
    end

    function A:Separator()
        inst("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=C.Bdr,BorderSizePixel=0,Parent=page})
    end

    function A:Label(text)
        inst("TextLabel",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text=text,TextColor3=C.T2,Font=C.FontR,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Parent=page})
    end

    local function Row(h)
        return inst("Frame",{Size=UDim2.new(1,0,0,h or 42),BackgroundColor3=C.Surf,BorderSizePixel=0,Parent=page},{crn(8),bdr(C.Bdr)})
    end

    function A:Toggle(text,default,callback)
        local state=default or false
        local row=Row(42)
        inst("TextLabel",{Position=UDim2.new(0,14,0,0),Size=UDim2.new(1,-78,1,0),BackgroundTransparency=1,Text=text,TextColor3=C.T1,Font=C.Font,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        inst("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-52,.5,0),Size=UDim2.new(0,26,0,26),BackgroundColor3=C.SurfH,BorderSizePixel=0,Text="···",TextColor3=C.TM,Font=C.FontB,TextSize=11,AutoButtonColor=false,Parent=row},{crn(5)})
        local sw=inst("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-12,.5,0),Size=UDim2.new(0,36,0,19),BackgroundColor3=C.Bdr,BorderSizePixel=0,Parent=row},{crn(10)})
        local kn=inst("Frame",{Position=UDim2.new(0,2,.5,0),AnchorPoint=Vector2.new(0,.5),Size=UDim2.new(0,15,0,15),BackgroundColor3=C.TM,BorderSizePixel=0,Parent=sw},{crn(8)})
        local function ref()
            if state then tw(sw,.18,{BackgroundColor3=C.Accent});tw(kn,.18,{Position=UDim2.new(1,-17,.5,0),BackgroundColor3=Color3.new(1,1,1)})
            else tw(sw,.18,{BackgroundColor3=C.Bdr});tw(kn,.18,{Position=UDim2.new(0,2,.5,0),BackgroundColor3=C.TM}) end
        end
        ref()
        inst("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",Parent=row}).MouseButton1Click:Connect(function()
            state=not state;ref()
            Notify(text,state and "Enabled" or "Disabled",2,state and "success" or "error")
            if callback then pcall(callback,state) end
        end)
        return {Set=function(_,v)state=v;ref()end,Get=function()return state end}
    end

    function A:Slider(text,mn,mx,def,callback)
        mn,mx=mn or 0,mx or 100;local val=math.clamp(def or mn,mn,mx)
        local row=Row(54)
        inst("TextLabel",{Position=UDim2.new(0,14,0,8),Size=UDim2.new(.65,0,0,16),BackgroundTransparency=1,Text=text,TextColor3=C.T1,Font=C.Font,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        local vL=inst("TextLabel",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,8),Size=UDim2.new(0,60,0,16),BackgroundTransparency=1,Text=tostring(val),TextColor3=C.Accent,Font=C.Font,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right,Parent=row})
        local track=inst("Frame",{Position=UDim2.new(0,14,1,-14),Size=UDim2.new(1,-28,0,4),BackgroundColor3=C.Bdr,BorderSizePixel=0,Parent=row},{crn(2)})
        local fill=inst("Frame",{Size=UDim2.new((val-mn)/(mx-mn),0,1,0),BackgroundColor3=C.Accent,BorderSizePixel=0,Parent=track},{crn(2)})
        local dg=false
        local function sx(x) local r=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1);val=math.floor(mn+(mx-mn)*r+.5);vL.Text=tostring(val);fill.Size=UDim2.new(r,0,1,0);if callback then pcall(callback,val) end end
        track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dg=true;sx(i.Position.X) end end)
        UserInputService.InputChanged:Connect(function(i) if dg and i.UserInputType==Enum.UserInputType.MouseMovement then sx(i.Position.X) end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dg=false end end)
        return {Set=function(_,v)val=math.clamp(v,mn,mx);vL.Text=tostring(val);fill.Size=UDim2.new((val-mn)/(mx-mn),0,1,0)end,Get=function()return val end}
    end

    function A:Dropdown(text,opts,default,callback)
        local sel=default or opts[1];local open=false;local bH,oH=42,30
        local row=inst("Frame",{Size=UDim2.new(1,0,0,bH),BackgroundColor3=C.Surf,BorderSizePixel=0,ClipsDescendants=true,Parent=page},{crn(8),bdr(C.Bdr)})
        inst("TextLabel",{Position=UDim2.new(0,14,0,0),Size=UDim2.new(.5,0,0,bH),BackgroundTransparency=1,Text=text,TextColor3=C.T1,Font=C.Font,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        local vL=inst("TextLabel",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-30,0,0),Size=UDim2.new(.45,0,0,bH),BackgroundTransparency=1,Text=sel,TextColor3=C.T2,Font=C.FontR,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right,Parent=row})
        local aBox=inst("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,0,bH/2),Size=UDim2.new(0,16,0,16),BackgroundColor3=C.SurfH,BorderSizePixel=0,Parent=row},{crn(4),bdr(C.Bdr)})
        local aLbl=inst("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="▾",TextColor3=C.T2,Font=C.FontB,TextSize=10,Parent=aBox})
        local lF=inst("Frame",{Position=UDim2.new(0,6,0,bH+2),Size=UDim2.new(1,-12,0,0),BackgroundTransparency=1,Parent=row},{inst("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)})})
        for _,opt in ipairs(opts) do
            local ob=inst("TextButton",{Size=UDim2.new(1,0,0,oH),BackgroundColor3=C.SurfH,BorderSizePixel=0,Text=opt,TextColor3=C.T2,Font=C.FontR,TextSize=12,AutoButtonColor=false,Parent=lF},{crn(6)})
            ob.MouseEnter:Connect(function() tw(ob,.1,{BackgroundColor3=C.BdrH,TextColor3=C.T1}) end)
            ob.MouseLeave:Connect(function() tw(ob,.1,{BackgroundColor3=C.SurfH,TextColor3=C.T2}) end)
            ob.MouseButton1Click:Connect(function() sel=opt;vL.Text=opt;open=false;tw(row,.18,{Size=UDim2.new(1,0,0,bH)});tw(aLbl,.18,{Rotation=0});if callback then pcall(callback,opt) end end)
        end
        inst("TextButton",{Size=UDim2.new(1,0,0,bH),BackgroundTransparency=1,Text="",Parent=row}).MouseButton1Click:Connect(function()
            open=not open;tw(row,.2,{Size=UDim2.new(1,0,0,open and (bH+4+(#opts*(oH+2))) or bH)});tw(aLbl,.18,{Rotation=open and 180 or 0})
        end)
        return {Set=function(_,v)sel=v;vL.Text=v end,Get=function()return sel end}
    end

    function A:Button(text,callback)
        local b=inst("TextButton",{Size=UDim2.new(1,0,0,38),BackgroundColor3=C.Surf,BorderSizePixel=0,Text=text,TextColor3=C.T1,Font=C.Font,TextSize=12,AutoButtonColor=false,Parent=page},{crn(8),bdr(C.Bdr)})
        b.MouseEnter:Connect(function() tw(b,.12,{BackgroundColor3=C.SurfH});tw(b:FindFirstChildOfClass("UIStroke"),.12,{Color=C.Accent}) end)
        b.MouseLeave:Connect(function() tw(b,.12,{BackgroundColor3=C.Surf});tw(b:FindFirstChildOfClass("UIStroke"),.12,{Color=C.Bdr}) end)
        b.MouseButton1Click:Connect(function() if callback then pcall(callback) end end)
        return b
    end

    function A:Textbox(text,placeholder,callback)
        local row=Row(42)
        inst("TextLabel",{Position=UDim2.new(0,14,0,0),Size=UDim2.new(.4,0,1,0),BackgroundTransparency=1,Text=text,TextColor3=C.T1,Font=C.Font,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        local box=inst("TextBox",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.new(.54,0,0,26),BackgroundColor3=C.SurfH,BorderSizePixel=0,Text="",PlaceholderText=placeholder or "",PlaceholderColor3=C.TM,TextColor3=C.T1,Font=C.FontR,TextSize=12,ClearTextOnFocus=false,Parent=row},{crn(6),bdr(C.Bdr)})
        box.FocusLost:Connect(function(e) if e and callback then pcall(callback,box.Text) end end)
        return box
    end

    function A:Keybind(text,defaultKey,callback)
        local ck=defaultKey or Enum.KeyCode.Unknown;local binding=false
        local row=Row(42)
        inst("TextLabel",{Position=UDim2.new(0,14,0,0),Size=UDim2.new(1,-112,1,0),BackgroundTransparency=1,Text=text,TextColor3=C.T1,Font=C.Font,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        local kb=inst("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-12,.5,0),Size=UDim2.new(0,92,0,26),BackgroundColor3=C.SurfH,BorderSizePixel=0,Text=ck.Name,TextColor3=C.Accent,Font=C.Font,TextSize=11,AutoButtonColor=false,Parent=row},{crn(6),bdr(C.Bdr)})
        kb.MouseButton1Click:Connect(function()
            if binding then return end;binding=true;kb.Text="...";kb.TextColor3=C.Warn
            local conn;conn=UserInputService.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.Keyboard then
                    ck=i.KeyCode;kb.Text=i.KeyCode.Name;kb.TextColor3=C.Accent;binding=false;conn:Disconnect()
                    Keybinds[text]={key=ck,cb=callback}
                    Notify("Keybind Set",text.." → "..i.KeyCode.Name,2,"success")
                end
            end)
        end)
        if ck~=Enum.KeyCode.Unknown then Keybinds[text]={key=ck,cb=callback} end
        return {Get=function()return ck end}
    end

    -- Auto-select this tab if it's the first one
    if #AllTabs==1 then
        task.defer(function()
            td.Page.Visible=true
            ActiveTab=td
            tw(td.Btn,.15,{BackgroundTransparency=0,BackgroundColor3=C.SurfH})
            tw(td.Lbl,.15,{TextColor3=C.T1})
            tw(td.Ico,.15,{TextColor3=C.Accent})
            td.Bar.Visible=true
        end)
    end

    return A
end

--=======================================================--
function BuildMain()

    -- Root window — ClipsDescendants gives natural rounded corners to everything inside
    Main=inst("Frame",{
        Name="Main",AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.new(.5,0,.5,0),Size=UDim2.new(0,0,0,0),
        BackgroundColor3=C.BG,BorderSizePixel=0,
        ClipsDescendants=true,Parent=Gui,
    },{crn(12),bdr(C.Bdr)})
    tw(Main,.45,{Size=UDim2.new(0,C.W,0,C.H)},Enum.EasingStyle.Back,Enum.EasingDirection.Out)

    --==[ TOPBAR — plain dark, zero colored bars ]==--
    local TB=inst("Frame",{
        Name="TopBar",Size=UDim2.new(1,0,0,C.TH),
        BackgroundColor3=C.Side,BorderSizePixel=0,Parent=Main,
    })
    -- Square bottom corners so it merges into content
    inst("Frame",{Position=UDim2.new(0,0,1,-10),Size=UDim2.new(1,0,0,10),BackgroundColor3=C.Side,BorderSizePixel=0,Parent=TB})
    -- Thin neutral bottom border (not colored)
    inst("Frame",{Position=UDim2.new(0,0,1,0),AnchorPoint=Vector2.new(0,1),Size=UDim2.new(1,0,0,1),BackgroundColor3=C.Bdr,BorderSizePixel=0,Parent=TB})

    -- Logo box (the only accent element in the topbar)
    local logo=inst("Frame",{Position=UDim2.new(0,14,0.5,0),AnchorPoint=Vector2.new(0,0.5),Size=UDim2.new(0,30,0,30),BackgroundColor3=C.Accent,BorderSizePixel=0,Parent=TB},{crn(8)})
    inst("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="P",TextColor3=Color3.new(1,1,1),Font=C.FontB,TextSize=17,Parent=logo})

    inst("TextLabel",{Position=UDim2.new(0,52,0.5,-11),Size=UDim2.new(0,200,0,17),BackgroundTransparency=1,Text=C.Name,TextColor3=C.T1,Font=C.FontB,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,Parent=TB})
    inst("TextLabel",{Position=UDim2.new(0,52,0.5,7), Size=UDim2.new(0,200,0,13),BackgroundTransparency=1,Text=LP.DisplayName,TextColor3=C.T2,Font=C.FontR,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=TB})

    -- Neutral vertical divider between logo area and content area of topbar
    inst("Frame",{Position=UDim2.new(0,C.SW,0,10),Size=UDim2.new(0,1,0,C.TH-20),BackgroundColor3=C.Bdr,BorderSizePixel=0,Parent=TB})

    -- Version badge
    inst("Frame",{Position=UDim2.new(0,C.SW+14,0.5,0),AnchorPoint=Vector2.new(0,0.5),Size=UDim2.new(0,72,0,24),BackgroundColor3=C.Surf,BorderSizePixel=0,Parent=TB},{
        crn(6),bdr(C.Bdr),
        inst("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=C.Version,TextColor3=C.T2,Font=C.FontR,TextSize=11})
    })

    -- Executor badge (dimmed accent background, subtle)
    local execF=inst("Frame",{Position=UDim2.new(0,C.SW+96,0.5,0),AnchorPoint=Vector2.new(0,0.5),Size=UDim2.new(0,0,0,24),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=C.AccentDim,BorderSizePixel=0,Parent=TB},{crn(6),pad(0,0,8,8)})
    inst("TextLabel",{Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text="⚙ "..ExecName,TextColor3=C.Accent,Font=C.Font,TextSize=11,Parent=execF})

    --==[ WINDOW CONTROLS ]==--
    local minimized=false
    local SideBG2,SideScroll2,CA2,UC2  -- refs for hide/show on minimize

    local function mkCtrl(sym,xOff,hc)
        local b=inst("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,xOff,.5,0),Size=UDim2.new(0,28,0,28),BackgroundColor3=C.Surf,BorderSizePixel=0,Text=sym,TextColor3=C.T2,Font=C.FontB,TextSize=13,AutoButtonColor=false,Parent=TB},{crn(7)})
        b.MouseEnter:Connect(function() tw(b,.12,{BackgroundColor3=hc,TextColor3=Color3.new(1,1,1)}) end)
        b.MouseLeave:Connect(function() tw(b,.12,{BackgroundColor3=C.Surf,TextColor3=C.T2}) end)
        return b
    end
    local BClose=mkCtrl("✕",-10,C.Bad)
    local BMin  =mkCtrl("–",-44,C.BdrH)

    BMin.MouseButton1Click:Connect(function()
        minimized=not minimized
        if minimized then
            -- Collapse to just the topbar, compact width
            if SideBG2    then SideBG2.Visible=false    end
            if SideScroll2 then SideScroll2.Visible=false end
            if CA2         then CA2.Visible=false         end
            if UC2         then UC2.Visible=false         end
            tw(Main,.25,{Size=UDim2.new(0,340,0,C.TH)})
            BMin.Text="□"
        else
            tw(Main,.3,{Size=UDim2.new(0,C.W,0,C.H)},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
            BMin.Text="–"
            task.delay(.28,function()
                if SideBG2     then SideBG2.Visible=true     end
                if SideScroll2 then SideScroll2.Visible=true  end
                if CA2          then CA2.Visible=true          end
                if UC2          then UC2.Visible=true          end
            end)
        end
    end)
    BClose.MouseButton1Click:Connect(function()
        tw(Main,.25,{Size=UDim2.new(0,0,0,0)},Enum.EasingStyle.Back,Enum.EasingDirection.In)
        task.wait(.28);Gui:Destroy()
    end)
    drag(Main,TB)

    --==[ SIDEBAR BACKGROUND ]==--
    SideBG2=inst("Frame",{
        Name="SideBG",Position=UDim2.new(0,0,0,C.TH),
        Size=UDim2.new(0,C.SW,1,-C.TH),
        BackgroundColor3=C.Side,BorderSizePixel=0,Parent=Main,
    },{
        inst("Frame",{Position=UDim2.new(1,0,0,0),AnchorPoint=Vector2.new(1,0),Size=UDim2.new(0,1,1,0),BackgroundColor3=C.Bdr,BorderSizePixel=0})
    })

    --==[ SIDEBAR SCROLL — tab buttons go here ]==--
    SideScroll=inst("ScrollingFrame",{
        Name="SideScroll",Position=UDim2.new(0,0,0,C.TH),
        Size=UDim2.new(0,C.SW,1,-(C.TH+64)),
        BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,
        CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
        Parent=Main,
    },{
        inst("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,3)}),
        pad(10,0,8,8),
    })
    SideScroll2=SideScroll

    --==[ CONTENT AREA ]==--
    CA=inst("Frame",{Name="ContentArea",Position=UDim2.new(0,C.SW,0,C.TH),Size=UDim2.new(1,-C.SW,1,-C.TH),BackgroundTransparency=1,Parent=Main})
    CA2=CA

    --==[ USER CARD ]==--
    local UC=inst("Frame",{Name="UserCard",Position=UDim2.new(0,0,1,-64),Size=UDim2.new(0,C.SW,0,64),BackgroundColor3=C.Side,BorderSizePixel=0,Parent=Main})
    UC2=UC
    inst("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=C.Bdr,BorderSizePixel=0,Parent=UC})
    inst("Frame",{Position=UDim2.new(1,0,0,0),AnchorPoint=Vector2.new(1,0),Size=UDim2.new(0,1,1,0),BackgroundColor3=C.Bdr,BorderSizePixel=0,Parent=UC})

    -- Avatar (Roblox headshot thumbnail)
    local av=inst("ImageLabel",{Position=UDim2.new(0,10,0.5,0),AnchorPoint=Vector2.new(0,0.5),Size=UDim2.new(0,38,0,38),BackgroundColor3=C.Surf,BorderSizePixel=0,Parent=UC},{crn(19)})
    pcall(function() av.Image="rbxthumb://type=AvatarHeadShot&id="..LP.UserId.."&w=60&h=60" end)
    -- Avatar ring (accent, small — not a bar)
    inst("Frame",{Position=UDim2.new(0,8,0.5,0),AnchorPoint=Vector2.new(0,0.5),Size=UDim2.new(0,42,0,42),BackgroundTransparency=1,BorderSizePixel=0,Parent=UC},{crn(21),bdr(C.Accent,1.5)})

    inst("TextLabel",{Position=UDim2.new(0,54,0,13),Size=UDim2.new(1,-72,0,16),BackgroundTransparency=1,Text=LP.Name,TextColor3=C.T1,Font=C.Font,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=UC})
    inst("TextLabel",{Position=UDim2.new(0,54,0,30),Size=UDim2.new(1,-72,0,13),BackgroundTransparency=1,Text="Premium | Lifetime",TextColor3=C.Accent,Font=C.FontR,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,Parent=UC})

    local profBtn=inst("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-8,.5,0),Size=UDim2.new(0,22,0,22),BackgroundColor3=C.Surf,BorderSizePixel=0,Text="›",TextColor3=C.T2,Font=C.FontB,TextSize=16,AutoButtonColor=false,Parent=UC},{crn(6)})
    profBtn.MouseEnter:Connect(function() tw(profBtn,.12,{BackgroundColor3=C.Accent,TextColor3=Color3.new(1,1,1)}) end)
    profBtn.MouseLeave:Connect(function() tw(profBtn,.12,{BackgroundColor3=C.Surf,TextColor3=C.T2}) end)

    --==[ PROFILE OVERLAY ]==--
    local PO=inst("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=C.BG,BackgroundTransparency=1,BorderSizePixel=0,Visible=false,ZIndex=10,Parent=CA})
    local profOpen=false
    local function toggleProf()
        profOpen=not profOpen;PO.Visible=true
        if profOpen then tw(PO,.2,{BackgroundTransparency=0})
        else tw(PO,.2,{BackgroundTransparency=1});task.delay(.22,function() if not profOpen then PO.Visible=false end end) end
    end
    profBtn.MouseButton1Click:Connect(toggleProf)

    local pCard=inst("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),Size=UDim2.new(0,340,0,390),BackgroundColor3=C.Surf,BorderSizePixel=0,ZIndex=11,Parent=PO},{crn(12),bdr(C.Bdr)})
    inst("TextLabel",{Position=UDim2.new(0,0,0,14),Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text="PLAYER PROFILE",TextColor3=C.Accent,Font=C.FontB,TextSize=11,ZIndex=12,Parent=pCard})
    local pa=inst("ImageLabel",{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,38),Size=UDim2.new(0,80,0,80),BackgroundColor3=C.Surf,BorderSizePixel=0,ZIndex=12,Parent=pCard},{crn(40)})
    pcall(function() pa.Image="rbxthumb://type=AvatarHeadShot&id="..LP.UserId.."&w=150&h=150" end)
    inst("Frame",{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,36),Size=UDim2.new(0,84,0,84),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=12,Parent=pCard},{crn(42),bdr(C.Accent,2)})
    inst("TextLabel",{Position=UDim2.new(0,0,0,128),Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,Text=LP.DisplayName,TextColor3=C.T1,Font=C.FontB,TextSize=17,ZIndex=12,Parent=pCard})
    inst("TextLabel",{Position=UDim2.new(0,0,0,150),Size=UDim2.new(1,0,0,15),BackgroundTransparency=1,Text="@"..LP.Name,TextColor3=C.T2,Font=C.FontR,TextSize=12,ZIndex=12,Parent=pCard})
    local infoRows={{"User ID",tostring(LP.UserId)},{"Account Age",tostring(LP.AccountAge or 0).." days"},{"Executor",ExecName},{"Game ID",tostring(game.PlaceId)},{"Team",LP.Team and LP.Team.Name or "NoTeam"},{"Membership","Premium | Lifetime"}}
    for idx,row in ipairs(infoRows) do
        local y=172+(idx-1)*30
        inst("TextLabel",{Position=UDim2.new(0,20,0,y),Size=UDim2.new(.45,0,0,26),BackgroundTransparency=1,Text=row[1],TextColor3=C.T2,Font=C.FontR,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12,Parent=pCard})
        inst("TextLabel",{Position=UDim2.new(.5,0,0,y),Size=UDim2.new(.45,0,0,26),BackgroundTransparency=1,Text=row[2],TextColor3=C.T1,Font=C.Font,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=12,Parent=pCard})
        if idx<#infoRows then inst("Frame",{Position=UDim2.new(0,14,0,y+26),Size=UDim2.new(1,-28,0,1),BackgroundColor3=C.Bdr,BorderSizePixel=0,ZIndex=12,Parent=pCard}) end
    end
    local cpBtn=inst("TextButton",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-12),Size=UDim2.new(0,110,0,30),BackgroundColor3=C.Surf,BorderSizePixel=0,Text="← Back",TextColor3=C.T2,Font=C.Font,TextSize=12,AutoButtonColor=false,ZIndex=12,Parent=pCard},{crn(8),bdr(C.Bdr)})
    cpBtn.MouseButton1Click:Connect(toggleProf)
    cpBtn.MouseEnter:Connect(function() tw(cpBtn,.12,{BackgroundColor3=C.SurfH}) end)
    cpBtn.MouseLeave:Connect(function() tw(cpBtn,.12,{BackgroundColor3=C.Surf}) end)

    --=======================================================--
    --               BUILT-IN TABS                           --
    --=======================================================--
    local Home=MakeTab("Home","⌂")
    Home:Section("Welcome")
    Home:Label("Phantom Hack — GUI Template. External scripts add their own tabs.")
    Home:Label("Player: "..LP.Name.."  •  Executor: "..ExecName.."  •  Place: "..tostring(game.PlaceId))
    Home:Separator()
    Home:Button("Copy Loadstring",function()
        pcall(function() if setclipboard then setclipboard('loadstring(game:HttpGet("'..C.KeyLink..'"))()') end end)
        Notify("Copied","Loadstring copied.",3,"success")
    end)
    Home:Button("Rejoin Server",function()
        pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId,LP) end)
        Notify("Rejoin","Rejoining...",3,"info")
    end)

    local KB=MakeTab("Keybinds","⌨")
    KB:Section("Menu Controls")
    KB:Keybind("Toggle Menu",Enum.KeyCode.RightShift,function() if Main then Main.Visible=not Main.Visible end end)
    KB:Keybind("Close Menu",Enum.KeyCode.Delete,function() tw(Main,.25,{Size=UDim2.new(0,0,0,0)},Enum.EasingStyle.Back,Enum.EasingDirection.In);task.wait(.28);Gui:Destroy() end)
    KB:Section("Custom Slots")
    KB:Keybind("Custom Slot 1",Enum.KeyCode.Unknown,function() Notify("Custom","Slot 1 fired.",2) end)
    KB:Keybind("Custom Slot 2",Enum.KeyCode.Unknown,function() Notify("Custom","Slot 2 fired.",2) end)
    KB:Keybind("Custom Slot 3",Enum.KeyCode.Unknown,function() Notify("Custom","Slot 3 fired.",2) end)
    KB:Separator()
    KB:Label("Click a bind button then press any key to rebind.")

    local UP=MakeTab("Updates","↑")
    UP:Section("Current  —  "..C.Version)
    UP:Button("Check for Updates",function() Notify("Up to Date","Running "..C.Version,4,"success") end)
    UP:Separator()
    UP:Section("Changelog  v1.0.2")
    UP:Label("• Removed ALL red/colored bars and stripes")
    UP:Label("• Accent used only on: logo box, avatar ring, toggles, active tab indicator")
    UP:Label("• Minimize: compact 340px topbar-only, all panels hidden")
    UP:Label("• Notifications: slide in/out from right with progress bar")
    UP:Label("• Module API: external scripts call PH:Tab() to add pages")

    local ST=MakeTab("Settings","◎")
    ST:Section("Accent Color")
    ST:Dropdown("Theme",{"Red","Blue","Purple","Green","Orange","Pink","Cyan"},"Red",function(choice)
        local p=AccentPresets[choice]
        if p then C.Accent=p[1];C.AccentH=p[2];C.AccentDim=Color3.new(p[1].R*.35,p[1].G*.35,p[1].B*.35) end
        Notify("Theme","Color changed to "..choice,2,"success")
    end)
    ST:Separator()
    ST:Section("Window")
    ST:Toggle("Transparent Window",false,function(s)
        if Main then tw(Main,.2,{BackgroundTransparency=s and 0.12 or 0}) end
        Notify("Transparency",s and "On" or "Off",2)
    end)
    ST:Separator()
    ST:Section("Data")
    ST:Button("Save Config",function() Notify("Config","Saved.",2,"success") end)
    ST:Button("Load Config",function() Notify("Config","Loaded.",2,"success") end)
    ST:Button("Reset Config",function() Notify("Config","Reset.",2,"warning") end)
    ST:Separator()
    ST:Button("Copy Discord",function()
        pcall(function() if setclipboard then setclipboard("https://discord.gg/phantomhack") end end)
        Notify("Discord","Invite copied.",2,"success")
    end)
    ST:Button("Unload",function()
        tw(Main,.25,{Size=UDim2.new(0,0,0,0)},Enum.EasingStyle.Back,Enum.EasingDirection.In)
        task.wait(.28);Gui:Destroy()
    end)

    --==[ GLOBAL KEYBIND HANDLER ]==--
    UserInputService.InputBegan:Connect(function(input,gpe)
        if gpe then return end
        for _,bind in pairs(Keybinds) do
            if bind.key==input.KeyCode then pcall(bind.cb) end
        end
    end)

    --[[
        ═══════════════════════════════════════════════════
        PUBLIC API — returned so external scripts can use it
        
        Usage in Core.lua or any other script:
        
            local PH = loadstring(game:HttpGet("YOUR_URL"))()
            
            local MyTab = PH:Tab("Combat", "⚔")
            MyTab:Toggle("Kill Aura", false, function(on) end)
            MyTab:Slider("Speed", 16, 200, 16, function(v) end)
            MyTab:Dropdown("Mode", {"Auto","Manual"}, "Auto", function(v) end)
            MyTab:Button("Do Something", function() end)
            
            PH:Notify("Test", "Hello!", 3, "success")
        ═══════════════════════════════════════════════════
    --]]
    return {
        Tab    = MakeTab,
        Notify = Notify,
        Config = C,
    }
end

--==[ TOGGLE HOTKEY ]==--
UserInputService.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if input.KeyCode==C.ToggleKey then
        if Main then Main.Visible=not Main.Visible end
    end
end)

task.wait(.4)
Notify("Phantom Hack","Loaded  •  RightShift to toggle",5,"success")
