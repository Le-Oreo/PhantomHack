--[[
╔══════════════════════════════════════════════════════════════╗
║            PHANTOM HACK — GUI Template v1.2.0               ║
║                                                             ║
║  Fixes in this version:                                     ║
║  • Minimized bar: no overflow, compact and clean            ║
║  • Accent color change: instantly recolors EVERYTHING       ║
║  • Logo: loads image from GitHub URL or falls back to text  ║
║  • All corners fully rounded everywhere                     ║
║  • Cleaner component styling                                ║
║                                                             ║
║  HOW TO USE (like Rayfield):                                ║
║    local M = loadstring(game:HttpGet(PHANTOMHACK_URL))()    ║
║    local PH = M.WaitForAuth()                               ║
║    local Tab = PH:Tab("Combat","⚔")                        ║
║    Tab:Toggle("Kill Aura",false,function(on) end)           ║
╚══════════════════════════════════════════════════════════════╝

LOGO / BRANDING:
  Upload your image to Roblox as a Decal, get the asset ID, set it as LogoID.
  Example: roblox.com/catalog/12345678 → LogoID = "12345678"
  Leave LogoID empty to use the letter fallback.

ACCENT RECOLOR:
  Changing the accent in Settings instantly recolors every accent-colored
  object in the GUI — toggles, tab bars, borders, badges, rings, etc.
  All accent objects are tracked in a list and updated together.
]]

--==[ SERVICES ]==--
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local HttpService      = game:GetService("HttpService")
local LP               = Players.LocalPlayer

--==[ BRANDING — edit these ]==--
local BRAND = {
    Name       = "PHANTOM HACK",
    Version    = "v1.2.0",
    ToggleKey  = Enum.KeyCode.RightShift,
    KeysURL    = "https://raw.githubusercontent.com/Le-Oreo/PhantomHack/main/keys.json",
    -- Logo: upload your image to Roblox (a Decal or Image asset),
    -- then paste the asset ID number here.
    -- Example: if your decal URL is roblox.com/library/12345678 then set LogoID = "12345678"
    -- Leave as "" to use the letter fallback (shows first letter of hub name).
    LogoID     = "110187797072022",
    -- Offline / fallback keys — these ALWAYS work, even without internet
    -- Delete or change these when you go live
    OfflineKeys = {
        "PHANTOM-FREE-TEST",   -- Free tier test key
        "PHANTOM-PREM-TEST",   -- Premium tier test key
        "PHANTOM-2026",        -- Legacy fallback (Premium)
        "PHANTOM-FREE",        -- Free fallback
        "PHANTOM-VIP",         -- VIP fallback (Premium)
    },
}

--==[ EXECUTOR DETECT ]==--
local function getExec()
    if identifyexecutor then local ok,n=pcall(identifyexecutor);if ok and n and n~="" then return tostring(n) end end
    if getexecutorname  then local ok,n=pcall(getexecutorname); if ok and n and n~="" then return tostring(n) end end
    if KRNL_LOADED then return "Krnl" end
    if DELTA_LOADED then return "Delta" end
    if syn and syn.request then return "Synapse X" end
    if fluxus then return "Fluxus" end
    if pebc_execute then return "Electron" end
    return "Unknown"
end
local ExecName = getExec()

--==[ THEME ]==--
-- All accent-colored objects are registered in AccentObjects so
-- changing the accent color instantly updates everything.
local AccentObjects = {} -- {object, property} pairs

local C = {
    Accent   = Color3.fromRGB(215,35,35),
    AccentH  = Color3.fromRGB(175,20,20),
    AccentDim= Color3.fromRGB(55,8,8),
    BG       = Color3.fromRGB(11,11,14),
    Side     = Color3.fromRGB(15,15,19),
    Surf     = Color3.fromRGB(21,21,27),
    SurfH    = Color3.fromRGB(27,27,34),
    Bdr      = Color3.fromRGB(38,38,50),
    BdrH     = Color3.fromRGB(58,58,75),
    T1       = Color3.fromRGB(232,232,238),
    T2       = Color3.fromRGB(125,125,148),
    TM       = Color3.fromRGB(60,60,78),
    Ok       = Color3.fromRGB(55,195,115),
    Bad      = Color3.fromRGB(215,35,35),
    Warn     = Color3.fromRGB(235,160,40),
    Info     = Color3.fromRGB(55,135,240),
    Gold     = Color3.fromRGB(255,190,50),
    Font     = Enum.Font.GothamSemibold,
    FontB    = Enum.Font.GothamBold,
    FontR    = Enum.Font.Gotham,
    W=880, H=560, SW=195, TH=52,
}

-- Register an object so it gets recolored when accent changes
local function trackAccent(obj, prop)
    table.insert(AccentObjects, {obj=obj, prop=prop})
    return obj
end

-- Apply a new accent color to EVERYTHING registered
local function applyAccent(newAccent, newAccentH, newAccentDim)
    C.Accent    = newAccent
    C.AccentH   = newAccentH  or Color3.new(newAccent.R*.8, newAccent.G*.8, newAccent.B*.8)
    C.AccentDim = newAccentDim or Color3.new(newAccent.R*.25, newAccent.G*.25, newAccent.B*.25)
    C.Bad       = newAccent  -- keep Bad in sync with accent (red danger stays if accent not red)
    for _, entry in ipairs(AccentObjects) do
        pcall(function()
            if entry.obj and entry.obj.Parent then
                entry.obj[entry.prop] = newAccent
            end
        end)
    end
end

local AccentPresets = {
    Red    = {Color3.fromRGB(215,35,35),  Color3.fromRGB(175,20,20),  Color3.fromRGB(55,8,8)},
    Blue   = {Color3.fromRGB(60,130,255), Color3.fromRGB(40,100,220), Color3.fromRGB(10,30,70)},
    Purple = {Color3.fromRGB(145,75,255), Color3.fromRGB(115,50,210), Color3.fromRGB(35,15,65)},
    Green  = {Color3.fromRGB(50,195,110), Color3.fromRGB(35,155,80),  Color3.fromRGB(8,45,20)},
    Orange = {Color3.fromRGB(235,125,30), Color3.fromRGB(195,95,20),  Color3.fromRGB(55,28,5)},
    Pink   = {Color3.fromRGB(235,65,165), Color3.fromRGB(195,45,135), Color3.fromRGB(55,10,38)},
    Cyan   = {Color3.fromRGB(30,195,215), Color3.fromRGB(20,155,175), Color3.fromRGB(5,45,52)},
    White  = {Color3.fromRGB(200,200,215), Color3.fromRGB(160,160,175),Color3.fromRGB(40,40,50)},
}

--==[ UTILS ]==--
local function tw(o,t,p,s,d)
    if not o or not o.Parent then return end
    TweenService:Create(o,TweenInfo.new(t or .2,s or Enum.EasingStyle.Quart,d or Enum.EasingDirection.Out),p):Play()
end
local function inst(cls,props,kids)
    local i=Instance.new(cls)
    for k,v in pairs(props or {}) do i[k]=v end
    for _,c in ipairs(kids or {}) do c.Parent=i end
    return i
end
local function crn(r)    return inst("UICorner",{CornerRadius=UDim.new(0,r or 8)}) end
local function bdr(col,th) return inst("UIStroke",{Color=col or C.Bdr,Thickness=th or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}) end
local function pad(t,b,l,r) return inst("UIPadding",{PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0),PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0)}) end

-- Accent-tracked border
local function abdr(th)
    local s = bdr(C.Accent,th)
    trackAccent(s,"Color")
    return s
end

local function fmtExpiry(unix)
    local r = unix - os.time()
    if r<=0 then return "EXPIRED" end
    local d=math.floor(r/86400); local h=math.floor((r%86400)/3600); local m=math.floor((r%3600)/60)
    if d>365 then return math.floor(d/365).."y "..math.floor((d%365)/30).."mo"
    elseif d>30 then return math.floor(d/30).."mo "..d%30 .."d"
    elseif d>0 then return d.."d "..h.."h"
    elseif h>0 then return h.."h "..m.."m"
    else return m.."m" end
end

--==[ CLEANUP ]==--
pcall(function() if CoreGui:FindFirstChild("PhantomHack") then CoreGui.PhantomHack:Destroy() end end)

--==[ ROOT GUI ]==--
local Gui=inst("ScreenGui",{Name="PhantomHack",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true})
pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(Gui);Gui.Parent=CoreGui
    elseif gethui then Gui.Parent=gethui()
    else Gui.Parent=CoreGui end
end)
if not Gui.Parent then Gui.Parent=LP:WaitForChild("PlayerGui") end

--=======================================================--
--                  NOTIFICATIONS                        --
--=======================================================--
local NH=inst("Frame",{
    Name="NH",AnchorPoint=Vector2.new(1,1),
    Position=UDim2.new(1,-14,1,-14),Size=UDim2.new(0,295,1,0),
    BackgroundTransparency=1,Parent=Gui,
},{inst("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Bottom,HorizontalAlignment=Enum.HorizontalAlignment.Right,Padding=UDim.new(0,7)})})

local function Notify(title,msg,dur,kind)
    dur=dur or 4
    local ac=(kind=="error" and C.Bad)or(kind=="success" and C.Ok)or(kind=="warning" and C.Warn)or(kind=="info" and C.Info)or C.Accent
    local wrap=inst("Frame",{Size=UDim2.new(1,0,0,56),BackgroundTransparency=1,Parent=NH})
    local card=inst("Frame",{Size=UDim2.new(1,0,1,0),Position=UDim2.new(1,10,0,0),BackgroundColor3=C.Surf,BorderSizePixel=0,Parent=wrap},{crn(10),bdr(C.Bdr)})
    inst("Frame",{Size=UDim2.new(0,3,0,28),Position=UDim2.new(0,0,0.5,0),AnchorPoint=Vector2.new(0,0.5),BackgroundColor3=ac,BorderSizePixel=0,Parent=card},{crn(2)})
    inst("TextLabel",{Position=UDim2.new(0,14,0,10),Size=UDim2.new(1,-28,0,16),BackgroundTransparency=1,Text=title,TextColor3=C.T1,Font=C.FontB,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=card})
    inst("TextLabel",{Position=UDim2.new(0,14,0,27),Size=UDim2.new(1,-28,0,14),BackgroundTransparency=1,Text=msg,TextColor3=C.T2,Font=C.FontR,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Parent=card})
    local prog=inst("Frame",{Position=UDim2.new(0,0,1,-3),Size=UDim2.new(1,0,0,3),BackgroundColor3=ac,BorderSizePixel=0,Parent=card})
    inst("UICorner",{CornerRadius=UDim.new(0,0),Parent=prog})
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

--==[ LOGO HELPER ]==--
-- Simple: just uses rbxassetid:// directly from BRAND.LogoID.
-- No downloading, no writefile, works on every executor instantly.
-- To use: upload your image to Roblox as a Decal, copy the asset ID number.

local function makeLogo(parent, size, pos, anchor)
    -- ClipsDescendants=true makes the ImageLabel clip to the rounded frame
    local frame = inst("Frame", {
        Position         = pos    or UDim2.new(0, 0, 0, 0),
        AnchorPoint      = anchor or Vector2.new(0, 0),
        Size             = size   or UDim2.new(0, 32, 0, 32),
        BackgroundColor3 = C.Accent,
        BorderSizePixel  = 0,
        ClipsDescendants = true,   -- clips image to rounded corners
        Parent           = parent,
    }, {crn(8)})
    trackAccent(frame, "BackgroundColor3")

    local letter = string.upper(string.sub(BRAND.Name, 1, 1))

    if BRAND.LogoID and BRAND.LogoID ~= "" then
        local img = inst("ImageLabel", {
            Size                  = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency= 1,
            Image                 = "rbxassetid://" .. BRAND.LogoID,
            ScaleType             = Enum.ScaleType.Fit,
            Parent                = frame,
        })
        -- Letter sits behind as fallback while image loads
        inst("TextLabel", {
            Size                  = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency= 1,
            Text                  = letter,
            TextColor3            = Color3.new(1, 1, 1),
            Font                  = C.FontB,
            TextSize              = 18,
            ZIndex                = 0,
            Parent                = frame,
        })
    else
        inst("TextLabel", {
            Size                  = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency= 1,
            Text                  = letter,
            TextColor3            = Color3.new(1, 1, 1),
            Font                  = C.FontB,
            TextSize              = 18,
            Parent                = frame,
        })
    end

    return frame
end

--=======================================================--
--              KEY VALIDATION                           --
--=======================================================--
local function validateKey(entered)
    -- Always check offline/fallback keys FIRST — instant, no HTTP needed
    local offlineTiers = {
        ["PHANTOM-FREE-TEST"]  = "Free",
        ["PHANTOM-PREM-TEST"]  = "Premium",
        ["PHANTOM-2026"]       = "Premium",
        ["PHANTOM-FREE"]       = "Free",
        ["PHANTOM-VIP"]        = "Premium",
    }
    for _,k in ipairs(BRAND.OfflineKeys) do
        if entered == k then
            return true, (offlineTiers[k] or "Free"), nil, nil
        end
    end

    -- Then try GitHub live validation
    local ok,raw=pcall(function() return game:HttpGet(BRAND.KeysURL,true) end)
    if not ok or not raw or raw=="" then
        return false,nil,nil,"Could not reach key server. Check your connection."
    end
    local pok,data=pcall(function() return HttpService:JSONDecode(raw) end)
    if not pok or not data or not data.keys then
        return false,nil,nil,"Key server returned invalid data."
    end
    local kd=data.keys[entered]
    if not kd then return false,nil,nil,"Invalid key." end
    if kd.revoked then return false,nil,nil,"This key has been revoked." end
    if not kd.redeemed then return false,nil,nil,"Key not redeemed yet. Use /redeem in Discord." end
    local expiresAt=kd.expiresAt
    if expiresAt and os.time()>expiresAt then
        local d=math.floor((os.time()-expiresAt)/86400)
        return false,nil,nil,"Key expired "..(d>0 and d.."d ago." or "recently.")
    end
    return true,(kd.tier or "Free"),expiresAt,nil
end

--=======================================================--
--                    KEY SCREEN                         --
--=======================================================--
local KF=inst("Frame",{
    Name="KeySystem",AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.new(.5,0,.5,0),Size=UDim2.new(0,440,0,220),
    BackgroundColor3=C.BG,BorderSizePixel=0,Parent=Gui,
},{crn(12),bdr(C.Bdr)})

-- Logo (36x36, vertically centered in the 56px header area)
makeLogo(KF, UDim2.new(0,36,0,36), UDim2.new(0,14,0,10), Vector2.new(0,0))
inst("TextLabel",{Position=UDim2.new(0,58,0,10),Size=UDim2.new(1,-70,0,18),BackgroundTransparency=1,Text=BRAND.Name,TextColor3=C.T1,Font=C.FontB,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,Parent=KF})
inst("TextLabel",{Position=UDim2.new(0,58,0,29),Size=UDim2.new(1,-70,0,13),BackgroundTransparency=1,Text="by Oreo  •  "..BRAND.Version,TextColor3=C.T2,Font=C.FontR,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=KF})
inst("Frame",{Position=UDim2.new(0,0,0,56),Size=UDim2.new(1,0,0,1),BackgroundColor3=C.Bdr,BorderSizePixel=0,Parent=KF})

local KBox=inst("Frame",{Position=UDim2.new(0,18,0,72),Size=UDim2.new(1,-36,0,40),BackgroundColor3=C.Surf,BorderSizePixel=0,Parent=KF},{crn(8),bdr(C.Bdr)})
local KIn=inst("TextBox",{Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,PlaceholderText="Enter your license key...",PlaceholderColor3=C.TM,Text="",TextColor3=C.T1,Font=C.FontR,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,Parent=KBox})
local KStr=KBox:FindFirstChildOfClass("UIStroke")
KIn.Focused:Connect(function() tw(KStr,.15,{Color=C.Accent}) end)
KIn.FocusLost:Connect(function() tw(KStr,.15,{Color=C.Bdr}) end)

local KStatus=inst("TextLabel",{Position=UDim2.new(0,18,0,122),Size=UDim2.new(1,-36,0,16),BackgroundTransparency=1,Text="Enter your key then press Authorize",TextColor3=C.TM,Font=C.FontR,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=KF})

local function mkKBtn(lbl,x,w,primary)
    local b=inst("TextButton",{Position=UDim2.new(0,x,0,148),Size=UDim2.new(0,w,0,38),BackgroundColor3=primary and C.Accent or C.Surf,BorderSizePixel=0,Text=lbl,TextColor3=C.T1,Font=C.Font,TextSize=12,AutoButtonColor=false,Parent=KF},{crn(8),bdr(primary and C.Accent or C.Bdr)})
    if primary then trackAccent(b,"BackgroundColor3") end
    b.MouseEnter:Connect(function() tw(b,.12,{BackgroundColor3=primary and C.AccentH or C.SurfH}) end)
    b.MouseLeave:Connect(function() tw(b,.12,{BackgroundColor3=primary and C.Accent or C.Surf}) end)
    return b
end
local GKBtn=mkKBtn("Get Key",18,185,false)
local ABtn =mkKBtn("Authorize",211,211,true)
inst("TextLabel",{Position=UDim2.new(0,0,1,-20),Size=UDim2.new(1,0,0,13),BackgroundTransparency=1,Text="© 2026 Phantom Hack  •  by Oreo",TextColor3=C.TM,Font=C.FontR,TextSize=10,Parent=KF})

drag(KF)
GKBtn.MouseButton1Click:Connect(function()
    pcall(function() if setclipboard then setclipboard("https://discord.gg/phantomhack") end end)
    Notify("Discord","Join our Discord to get a key!",3,"info")
end)

--=======================================================--
--               MAIN MENU STATE                        --
--=======================================================--
local Main,ActiveTab
local AllTabs  = {}
local Keybinds = {}
local SideScroll,CA  -- set in BuildMain
local ValidatedTier   = "Free"
local ValidatedExpiry = nil
local BuildMain

--=======================================================--
--            MAKETAB + COMPONENTS                       --
--=======================================================--
local function MakeTab(name,icon,hideSidebar)
    local btn=inst("TextButton",{
        Size=UDim2.new(1,0,0,36),BackgroundColor3=C.SurfH,BackgroundTransparency=1,
        BorderSizePixel=0,Text="",AutoButtonColor=false,
        Visible=not hideSidebar,  -- hidden from sidebar if hideSidebar=true
        Parent=SideScroll,
    },{crn(7)})
    local bar=inst("Frame",{
        Position=UDim2.new(0,0,0.5,0),AnchorPoint=Vector2.new(0,0.5),
        Size=UDim2.new(0,3,0,20),BackgroundColor3=C.Accent,BorderSizePixel=0,Visible=false,Parent=btn,
    },{crn(2)})
    trackAccent(bar,"BackgroundColor3")

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
    -- Track scrollbar color
    trackAccent(page,"ScrollBarImageColor3")

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

    -- (auto-select is handled by PH:SelectFirst() called from Core.lua)
    btn.MouseButton1Click:Connect(SetActive)
    btn.MouseEnter:Connect(function() if ActiveTab~=td then tw(btn,.12,{BackgroundTransparency=0});tw(lbl,.12,{TextColor3=C.T1}) end end)
    btn.MouseLeave:Connect(function() if ActiveTab~=td then tw(btn,.12,{BackgroundTransparency=1});tw(lbl,.12,{TextColor3=C.T2}) end end)

    --==[ COMPONENTS ]==--
    local A={}

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

        -- ··· button opens inline keybind picker for this toggle
        local bindKey = Enum.KeyCode.Unknown
        local bindBinding = false
        local kbBtn = inst("TextButton",{
            AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-52,.5,0),
            Size=UDim2.new(0,26,0,26),BackgroundColor3=C.SurfH,BorderSizePixel=0,
            Text="···",TextColor3=C.TM,Font=C.FontB,TextSize=11,AutoButtonColor=false,Parent=row,
        },{crn(5)})

        -- Keybind popup row (hidden by default, slides out below)
        local kbRow = inst("Frame",{
            Position=UDim2.new(0,0,1,2),Size=UDim2.new(1,0,0,30),
            BackgroundColor3=C.SurfH,BorderSizePixel=0,Visible=false,Parent=row,
        },{crn(6),bdr(C.Bdr)})
        inst("TextLabel",{Position=UDim2.new(0,10,0,0),Size=UDim2.new(.45,0,1,0),BackgroundTransparency=1,Text="Keybind:",TextColor3=C.T2,Font=C.FontR,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=kbRow})
        local kbLabel = inst("TextButton",{
            AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-8,.5,0),
            Size=UDim2.new(0,90,0,22),BackgroundColor3=C.Surf,BorderSizePixel=0,
            Text="None",TextColor3=C.Accent,Font=C.Font,TextSize=11,AutoButtonColor=false,Parent=kbRow,
        },{crn(5),bdr(C.Bdr)})
        trackAccent(kbLabel,"TextColor3")

        local kbOpen = false
        kbBtn.MouseButton1Click:Connect(function()
            kbOpen = not kbOpen
            kbRow.Visible = kbOpen
            -- Expand/contract the row to show keybind area
            tw(row,.2,{Size=UDim2.new(1,0,0,kbOpen and 76 or 42)})
        end)

        kbLabel.MouseButton1Click:Connect(function()
            if bindBinding then return end
            bindBinding = true
            kbLabel.Text = "..."
            kbLabel.TextColor3 = C.Warn
            local conn; conn = UserInputService.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.Keyboard then
                    bindKey = i.KeyCode
                    kbLabel.Text = i.KeyCode.Name
                    kbLabel.TextColor3 = C.Accent
                    bindBinding = false
                    conn:Disconnect()
                    -- Register in global keybinds
                    Keybinds[text.."_toggle"] = {
                        key = bindKey,
                        cb  = function()
                            state = not state
                            if state then sw.BackgroundColor3=C.Accent;tw(kn,.18,{Position=UDim2.new(1,-17,.5,0),BackgroundColor3=Color3.new(1,1,1)})
                            else sw.BackgroundColor3=C.Bdr;tw(kn,.18,{Position=UDim2.new(0,2,.5,0),BackgroundColor3=C.TM}) end
                            Notify(text,state and "Enabled" or "Disabled",2,state and "success" or "error")
                            if callback then pcall(callback,state) end
                        end
                    }
                    Notify("Keybind",text.." → "..i.KeyCode.Name,2,"success")
                end
            end)
        end)

        local sw=inst("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-12,.5,0),Size=UDim2.new(0,36,0,19),BackgroundColor3=C.Bdr,BorderSizePixel=0,Parent=row},{crn(10)})
        local kn=inst("Frame",{Position=UDim2.new(0,2,.5,0),AnchorPoint=Vector2.new(0,.5),Size=UDim2.new(0,15,0,15),BackgroundColor3=C.TM,BorderSizePixel=0,Parent=sw},{crn(8)})
        trackAccent(sw,"BackgroundColor3")
        local function ref()
            if state then
                sw.BackgroundColor3=C.Accent
                tw(kn,.18,{Position=UDim2.new(1,-17,.5,0),BackgroundColor3=Color3.new(1,1,1)})
            else
                sw.BackgroundColor3=C.Bdr
                tw(kn,.18,{Position=UDim2.new(0,2,.5,0),BackgroundColor3=C.TM})
            end
        end
        table.remove(AccentObjects,#AccentObjects)
        ref()
        inst("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",Parent=row}).MouseButton1Click:Connect(function()
            state=not state
            if state then sw.BackgroundColor3=C.Accent;tw(kn,.18,{Position=UDim2.new(1,-17,.5,0),BackgroundColor3=Color3.new(1,1,1)})
            else sw.BackgroundColor3=C.Bdr;tw(kn,.18,{Position=UDim2.new(0,2,.5,0),BackgroundColor3=C.TM}) end
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
        trackAccent(vL,"TextColor3")
        local track=inst("Frame",{Position=UDim2.new(0,14,1,-14),Size=UDim2.new(1,-28,0,4),BackgroundColor3=C.Bdr,BorderSizePixel=0,Parent=row},{crn(2)})
        local fill=inst("Frame",{Size=UDim2.new((val-mn)/(mx-mn),0,1,0),BackgroundColor3=C.Accent,BorderSizePixel=0,Parent=track},{crn(2)})
        trackAccent(fill,"BackgroundColor3")
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
        b.MouseEnter:Connect(function()
            tw(b,.12,{BackgroundColor3=C.SurfH})
            local s=b:FindFirstChildOfClass("UIStroke");if s then tw(s,.12,{Color=C.Accent}) end
        end)
        b.MouseLeave:Connect(function()
            tw(b,.12,{BackgroundColor3=C.Surf})
            local s=b:FindFirstChildOfClass("UIStroke");if s then tw(s,.12,{Color=C.Bdr}) end
        end)
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
        trackAccent(kb,"TextColor3")
        kb.MouseButton1Click:Connect(function()
            if binding then return end;binding=true;kb.Text="...";kb.TextColor3=C.Warn
            local conn;conn=UserInputService.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.Keyboard then
                    ck=i.KeyCode;kb.Text=i.KeyCode.Name;kb.TextColor3=C.Accent;binding=false;conn:Disconnect()
                    Keybinds[text]={key=ck,cb=callback}
                    Notify("Keybind",text.." → "..i.KeyCode.Name,2,"success")
                end
            end)
        end)
        if ck~=Enum.KeyCode.Unknown then Keybinds[text]={key=ck,cb=callback} end
        return {Get=function()return ck end}
    end

    return A
end

--=======================================================--
function BuildMain(tier, expiresAt)
    ValidatedTier   = tier   or "Free"
    ValidatedExpiry = expiresAt

    -- CORRECT corner approach:
    -- Outer frame: has UICorner + UIStroke, NO background, NO ClipsDescendants
    -- Inner frame: has ClipsDescendants=true, clips all children neatly
    -- This gives rounded corners AND proper clipping without the green box bug.
    local Outer=inst("Frame",{
        Name="MainOuter",AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.new(.5,0,.5,0),Size=UDim2.new(0,0,0,0),
        BackgroundTransparency=1,BorderSizePixel=0,Parent=Gui,
    },{crn(12),bdr(C.Bdr)})
    tw(Outer,.45,{Size=UDim2.new(0,C.W,0,C.H)},Enum.EasingStyle.Back,Enum.EasingDirection.Out)

    Main=inst("Frame",{
        Name="Main",Size=UDim2.new(1,0,1,0),
        BackgroundColor3=C.BG,BorderSizePixel=0,
        ClipsDescendants=true,Parent=Outer,
    },{crn(12)})

    -- Mirror size changes from Outer to Main for minimize/restore
    -- (we tween Outer, Main follows via Size=1,0,1,0)

    --==[ TOPBAR ]==--
    local TB=inst("Frame",{
        Name="TopBar",Size=UDim2.new(1,0,0,C.TH),
        BackgroundColor3=C.Side,BorderSizePixel=0,Parent=Main,
    })
    -- No UICorner on TB - it sits inside ClipsDescendants Main
    -- Bottom square cover
    inst("Frame",{
        Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1),
        BackgroundColor3=C.Side,BorderSizePixel=0,Parent=TB,
    })
    -- Bottom border line
    inst("Frame",{
        Position=UDim2.new(0,0,1,0),AnchorPoint=Vector2.new(0,1),
        Size=UDim2.new(1,0,0,1),BackgroundColor3=C.Bdr,BorderSizePixel=0,Parent=TB,
    })

    -- Logo box
    makeLogo(TB, UDim2.new(0,34,0,34), UDim2.new(0,12,.5,0), Vector2.new(0,.5))
    inst("TextLabel",{Position=UDim2.new(0,54,0.5,-11),Size=UDim2.new(0,200,0,17),BackgroundTransparency=1,Text=BRAND.Name,TextColor3=C.T1,Font=C.FontB,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,Parent=TB})
    inst("TextLabel",{Position=UDim2.new(0,54,0.5,7),Size=UDim2.new(0,200,0,13),BackgroundTransparency=1,Text=LP.DisplayName,TextColor3=C.T2,Font=C.FontR,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=TB})

    -- Sidebar divider
    inst("Frame",{Position=UDim2.new(0,C.SW,0,10),Size=UDim2.new(0,1,0,C.TH-20),BackgroundColor3=C.Bdr,BorderSizePixel=0,Parent=TB})

    -- ── Topbar right side: version + controls only. No executor/tier badges here.
    -- They spilled out the right edge when minimized. Moved to sidebar/profile instead.
    inst("Frame",{
        Position=UDim2.new(0,C.SW+14,0.5,0),AnchorPoint=Vector2.new(0,0.5),
        Size=UDim2.new(0,66,0,22),BackgroundColor3=C.Surf,BorderSizePixel=0,Parent=TB,
    },{crn(6),bdr(C.Bdr),inst("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=BRAND.Version,TextColor3=C.T2,Font=C.FontR,TextSize=11})})
    -- "by Oreo" credit label, sits right of version badge
    inst("TextLabel",{
        Position=UDim2.new(0,C.SW+90,0.5,0),AnchorPoint=Vector2.new(0,0.5),
        Size=UDim2.new(0,55,0,22),
        BackgroundTransparency=1,
        Text="by Oreo",
        TextColor3=C.TM,
        Font=C.FontR,
        TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left,
        Parent=TB,
    })

    --==[ WINDOW CONTROLS ]==--
    local minimized=false
    local SideBG2,SideScroll2,CA2,UC2

    local function mkCtrl(sym,xOff,hc)
        local b=inst("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,xOff,.5,0),Size=UDim2.new(0,28,0,28),BackgroundColor3=C.Surf,BorderSizePixel=0,Text=sym,TextColor3=C.T2,Font=C.FontB,TextSize=13,AutoButtonColor=false,Parent=TB},{crn(7)})
        b.MouseEnter:Connect(function() tw(b,.12,{BackgroundColor3=hc,TextColor3=Color3.new(1,1,1)}) end)
        b.MouseLeave:Connect(function() tw(b,.12,{BackgroundColor3=C.Surf,TextColor3=C.T2}) end)
        return b
    end
    local BClose=mkCtrl("✕",-10,Color3.fromRGB(200,40,40))
    local BMin  =mkCtrl("–",-44,C.BdrH)

    BMin.MouseButton1Click:Connect(function()
        minimized=not minimized
        if minimized then
            if SideBG2     then SideBG2.Visible=false    end
            if SideScroll2 then SideScroll2.Visible=false end
            if CA2         then CA2.Visible=false         end
            if UC2         then UC2.Visible=false         end
            tw(Outer,.25,{Size=UDim2.new(0,420,0,C.TH)})
            BMin.Text="□"
        else
            tw(Outer,.3,{Size=UDim2.new(0,C.W,0,C.H)},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
            BMin.Text="–"
            task.delay(.28,function()
                if SideBG2     then SideBG2.Visible=true    end
                if SideScroll2 then SideScroll2.Visible=true end
                if CA2         then CA2.Visible=true         end
                if UC2         then UC2.Visible=true         end
            end)
        end
    end)
    BClose.MouseButton1Click:Connect(function()
        tw(Outer,.25,{Size=UDim2.new(0,0,0,0)},Enum.EasingStyle.Back,Enum.EasingDirection.In)
        task.wait(.28);Gui:Destroy()
    end)
    drag(Outer,TB)

    --==[ SIDEBAR ]==--
    SideBG2=inst("Frame",{Name="SideBG",Position=UDim2.new(0,0,0,C.TH),Size=UDim2.new(0,C.SW,1,-C.TH),BackgroundColor3=C.Side,BorderSizePixel=0,Parent=Main},{
        inst("Frame",{Position=UDim2.new(1,0,0,0),AnchorPoint=Vector2.new(1,0),Size=UDim2.new(0,1,1,0),BackgroundColor3=C.Bdr,BorderSizePixel=0})
    })
    SideScroll=inst("ScrollingFrame",{
        Name="SideScroll",Position=UDim2.new(0,0,0,C.TH),
        Size=UDim2.new(0,C.SW,1,-(C.TH+64)),
        BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,
        CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Parent=Main,
    },{inst("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,3)}),pad(10,0,8,8)})
    SideScroll2=SideScroll

    CA=inst("Frame",{Name="ContentArea",Position=UDim2.new(0,C.SW,0,C.TH),Size=UDim2.new(1,-C.SW,1,-C.TH),BackgroundTransparency=1,Parent=Main})
    CA2=CA

    --==[ USER CARD ]==--
    local UC=inst("Frame",{Name="UserCard",Position=UDim2.new(0,0,1,-64),Size=UDim2.new(0,C.SW,0,64),BackgroundColor3=C.Side,BorderSizePixel=0,Parent=Main})
    UC2=UC
    inst("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=C.Bdr,BorderSizePixel=0,Parent=UC})
    inst("Frame",{Position=UDim2.new(1,0,0,0),AnchorPoint=Vector2.new(1,0),Size=UDim2.new(0,1,1,0),BackgroundColor3=C.Bdr,BorderSizePixel=0,Parent=UC})

    local av=inst("ImageLabel",{Position=UDim2.new(0,10,0.5,0),AnchorPoint=Vector2.new(0,0.5),Size=UDim2.new(0,38,0,38),BackgroundColor3=C.Surf,BorderSizePixel=0,Parent=UC},{crn(19)})
    pcall(function() av.Image="rbxthumb://type=AvatarHeadShot&id="..LP.UserId.."&w=60&h=60" end)
    local avRing=inst("Frame",{Position=UDim2.new(0,8,0.5,0),AnchorPoint=Vector2.new(0,0.5),Size=UDim2.new(0,42,0,42),BackgroundTransparency=1,BorderSizePixel=0,Parent=UC},{crn(21),abdr(1.5)})

    inst("TextLabel",{Position=UDim2.new(0,54,0,10),Size=UDim2.new(1,-72,0,16),BackgroundTransparency=1,Text=LP.Name,TextColor3=C.T1,Font=C.Font,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=UC})
    local tierColor=(ValidatedTier=="Premium") and C.Gold or C.Accent
    local tierStr=ValidatedTier.."  •  "..(ValidatedExpiry and fmtExpiry(ValidatedExpiry).." left" or "Lifetime")
    local ucTierLbl=inst("TextLabel",{Position=UDim2.new(0,54,0,27),Size=UDim2.new(1,-72,0,13),BackgroundTransparency=1,Text=tierStr,TextColor3=tierColor,Font=C.FontR,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,Parent=UC})

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

    local pCard=inst("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),Size=UDim2.new(0,340,0,430),BackgroundColor3=C.Surf,BorderSizePixel=0,ZIndex=11,Parent=PO},{crn(12),bdr(C.Bdr)})
    inst("TextLabel",{Position=UDim2.new(0,0,0,14),Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text="PLAYER PROFILE",TextColor3=C.Accent,Font=C.FontB,TextSize=11,ZIndex=12,Parent=pCard})
    trackAccent(pCard:FindFirstChild("TextLabel") or pCard,"TextColor3")

    local pa=inst("ImageLabel",{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,38),Size=UDim2.new(0,80,0,80),BackgroundColor3=C.Surf,BorderSizePixel=0,ZIndex=12,Parent=pCard},{crn(40)})
    pcall(function() pa.Image="rbxthumb://type=AvatarHeadShot&id="..LP.UserId.."&w=150&h=150" end)
    inst("Frame",{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,36),Size=UDim2.new(0,84,0,84),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=12,Parent=pCard},{crn(42),abdr(2)})

    inst("TextLabel",{Position=UDim2.new(0,0,0,128),Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,Text=LP.DisplayName,TextColor3=C.T1,Font=C.FontB,TextSize=17,ZIndex=12,Parent=pCard})
    inst("TextLabel",{Position=UDim2.new(0,0,0,150),Size=UDim2.new(1,0,0,15),BackgroundTransparency=1,Text="@"..LP.Name,TextColor3=C.T2,Font=C.FontR,TextSize=12,ZIndex=12,Parent=pCard})

    local infoRows={
        {"User ID",    tostring(LP.UserId)},
        {"Account Age",tostring(LP.AccountAge or 0).." days"},
        {"Executor",   ExecName},
        {"Game ID",    tostring(game.PlaceId)},
        {"Tier",       ValidatedTier},
        {"Expires",    ValidatedExpiry and fmtExpiry(ValidatedExpiry).." left" or "Lifetime"},
        {"Created By",  "Oreo"},
    }
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
    --   BUILT-IN TABS — Settings only (no Keybinds tab)    --
    --=======================================================--

    -- SETTINGS (accessible via sidebar AND the ⚙ button in topbar)
    -- Settings: hidden from sidebar — only via ⚙ topbar button
    local ST=MakeTab("Settings","◎",true)

    ST:Section("Menu Controls")
    ST:Keybind("Toggle Menu",Enum.KeyCode.RightShift,function()
        if Outer then Outer.Visible=not Outer.Visible end
    end)
    ST:Keybind("Close Menu",Enum.KeyCode.Delete,function()
        tw(Outer,.25,{Size=UDim2.new(0,0,0,0)},Enum.EasingStyle.Back,Enum.EasingDirection.In)
        task.wait(.28);Gui:Destroy()
    end)
    ST:Separator()

    ST:Section("Accent Color")
    ST:Dropdown("Theme",{"Red","Blue","Purple","Green","Orange","Pink","Cyan","White"},"Red",function(choice)
        local p=AccentPresets[choice]
        if p then
            applyAccent(p[1],p[2],p[3])
            C.Bad=Color3.fromRGB(215,35,35)
        end
        Notify("Theme","Color changed to "..choice,2,"success")
    end)
    ST:Separator()

    ST:Section("Window")
    ST:Toggle("Transparent Window",false,function(s)
        if Main then tw(Main,.2,{BackgroundTransparency=s and 0.12 or 0}) end
        Notify("Transparency",s and "On" or "Off",2)
    end)
    ST:Separator()

    ST:Button("Copy Discord",function()
        pcall(function() if setclipboard then setclipboard("https://discord.gg/phantomhack") end end)
        Notify("Discord","Invite copied.",2,"success")
    end)
    ST:Separator()
    ST:Section("Credits")
    ST:Label("Phantom Hack — created by Oreo")
    ST:Label("GUI Template  •  "..BRAND.Version)
    ST:Label("discord.gg/phantomhack")
    ST:Separator()
    ST:Button("Unload",function()
        tw(Outer,.25,{Size=UDim2.new(0,0,0,0)},Enum.EasingStyle.Back,Enum.EasingDirection.In)
        task.wait(.28);Gui:Destroy()
    end)

    -- ⚙ Settings shortcut button in topbar (next to minimize)
    -- Defined here so ST page reference is available
    local settingsShortcut = inst("TextButton",{
        AnchorPoint=Vector2.new(1,.5),
        Position=UDim2.new(1,-78,.5,0),  -- sits left of the minimize button
        Size=UDim2.new(0,28,0,28),
        BackgroundColor3=C.Surf,BorderSizePixel=0,
        Text="⚙",TextColor3=C.T2,Font=C.FontB,TextSize=14,
        AutoButtonColor=false,Parent=TB,
    },{crn(7)})
    settingsShortcut.MouseEnter:Connect(function()
        tw(settingsShortcut,.12,{BackgroundColor3=C.Accent,TextColor3=Color3.new(1,1,1)})
    end)
    settingsShortcut.MouseLeave:Connect(function()
        tw(settingsShortcut,.12,{BackgroundColor3=C.Surf,TextColor3=C.T2})
    end)
    -- Wire up settings shortcut to directly activate the Settings tab page
    local function openSettings()
        -- Find Settings tab by label text (it's hidden from sidebar)
        local stData = nil
        for _,td in ipairs(AllTabs) do
            if td.Lbl and td.Lbl.Text == "Settings" then stData=td; break end
        end
        if not stData then return end
        if ActiveTab == stData then return end
        if ActiveTab then
            ActiveTab.Page.Visible=false
            tw(ActiveTab.Btn,.15,{BackgroundTransparency=1,BackgroundColor3=C.SurfH})
            tw(ActiveTab.Lbl,.15,{TextColor3=C.T2})
            tw(ActiveTab.Ico,.15,{TextColor3=C.TM})
            ActiveTab.Bar.Visible=false
        end
        ActiveTab=stData
        stData.Page.Visible=true
        tw(stData.Btn,.15,{BackgroundTransparency=0,BackgroundColor3=C.SurfH})
        tw(stData.Lbl,.15,{TextColor3=C.T1})
        tw(stData.Ico,.15,{TextColor3=C.Accent})
        stData.Bar.Visible=true
    end

    settingsShortcut.MouseButton1Click:Connect(function()
        openSettings()
        if Outer and not Outer.Visible then Outer.Visible=true end
        if minimized then
            minimized=false
            tw(Outer,.3,{Size=UDim2.new(0,C.W,0,C.H)},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
            BMin.Text="–"
            task.delay(.28,function()
                if SideBG2  then SideBG2.Visible=true  end
                if SideScroll2 then SideScroll2.Visible=true end
                if CA2      then CA2.Visible=true       end
                if UC2      then UC2.Visible=true       end
            end)
        end
    end)

    --==[ GLOBAL KEYBIND HANDLER ]==--
    UserInputService.InputBegan:Connect(function(input,gpe)
        if gpe then return end
        for _,bind in pairs(Keybinds) do
            if bind.key==input.KeyCode then pcall(bind.cb) end
        end
    end)

    -- SelectFirst: call this after all your tabs are added in Core.lua
    -- It picks the first visible sidebar tab and activates it
    local function SelectFirst()
        for _,td in ipairs(AllTabs) do
            if td.Btn.Visible and td.Btn.Parent then
                if ActiveTab == td then return end  -- already selected
                if ActiveTab then
                    ActiveTab.Page.Visible=false
                    ActiveTab.Btn.BackgroundTransparency=1
                    tw(ActiveTab.Lbl,.15,{TextColor3=C.T2})
                    tw(ActiveTab.Ico,.15,{TextColor3=C.TM})
                    ActiveTab.Bar.Visible=false
                end
                ActiveTab=td
                td.Page.Visible=true
                td.Btn.BackgroundTransparency=0
                td.Btn.BackgroundColor3=C.SurfH
                td.Lbl.TextColor3=C.T1
                td.Ico.TextColor3=C.Accent
                td.Bar.Visible=true
                return
            end
        end
    end

    return {
        -- Wrappers that accept colon-call syntax (self is ignored)
        Tab         = function(self, name, icon) return MakeTab(name, icon, false) end,
        Notify      = function(self, ...) return Notify(...) end,
        SelectFirst = function(self) return SelectFirst() end,
        Config      = C,
        Tier        = ValidatedTier,
        KeyExpiry   = ValidatedExpiry,
    }
end

--=======================================================--
--                   AUTH FLOW                           --
--=======================================================--

-- Shared event so WaitForAuth() knows when auth is done
local AuthDone    = false
local AuthAPI     = nil  -- set after BuildMain succeeds

local function doAuth()
    local entered = KIn.Text
    if entered == "" then
        KStatus.Text = "Please enter your key."
        KStatus.TextColor3 = C.Warn
        return
    end
    ABtn.Text = "Checking..."
    KStatus.Text = "Validating..."
    KStatus.TextColor3 = C.T2

    task.spawn(function()
        local ok, tier, expiresAt, err = validateKey(entered)
        if ok then
            KStatus.Text      = "✓ Authenticated — launching ["..tier.."]"
            KStatus.TextColor3 = C.Ok
            Notify("Welcome","Phantom Hack ["..tier.."] loading...",3,"success")
            task.wait(.5)
            tw(KF,.3,{Size=UDim2.new(0,440,0,0),BackgroundTransparency=1})
            task.wait(.35)
            pcall(function() KF:Destroy() end)
            -- Build the main menu and store the returned API
            AuthAPI  = BuildMain(tier, expiresAt)
            AuthDone = true
        else
            ABtn.Text          = "Authorize"
            KStatus.Text       = "✗ "..err
            KStatus.TextColor3 = C.Bad
            Notify("Auth Failed", err, 4, "error")
            tw(KStr,.1,{Color=C.Bad})
            local op = KBox.Position
            for i=1,5 do
                tw(KBox,.04,{Position=op+UDim2.fromOffset(i%2==0 and -7 or 7,0)})
                task.wait(.045)
            end
            KBox.Position = op
            task.delay(1.5, function() tw(KStr,.2,{Color=C.Bdr}) end)
        end
    end)
end

ABtn.MouseButton1Click:Connect(doAuth)

-- Allow pressing Enter in the key box to submit
KIn.FocusLost:Connect(function(enterPressed)
    if enterPressed then doAuth() end
end)

--==[ TOGGLE HOTKEY ]==--
UserInputService.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if input.KeyCode==BRAND.ToggleKey then
        if Outer then Outer.Visible = not Outer.Visible end
    end
end)

task.wait(.4)
Notify("Phantom Hack","Loaded  •  RightShift to toggle",5,"success")

--=======================================================--
--                   PUBLIC API                          --
--=======================================================--
-- Core.lua calls:
--   local M  = loadstring(game:HttpGet(URL))()
--   local PH = M.WaitForAuth()
--
-- WaitForAuth() yields until the player successfully authenticates,
-- then returns the full API with the correct Tier already set.
return {
    WaitForAuth = function()
        -- Yield until auth completes (AuthDone flipped by doAuth on success)
        while not AuthDone do
            task.wait(0.05)
        end
        -- AuthAPI was set by BuildMain — return it directly
        return AuthAPI
    end
}
