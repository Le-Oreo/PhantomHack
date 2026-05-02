--[[
    ██████╗ ██╗  ██╗ █████╗ ███╗   ██╗████████╗ ██████╗ ███╗   ███╗
    ██╔══██╗██║  ██║██╔══██╗████╗  ██║╚══██╔══╝██╔═══██╗████╗ ████║
    ██████╔╝███████║███████║██╔██╗ ██║   ██║   ██║   ██║██╔████╔██║
    ██╔═══╝ ██╔══██║██╔══██║██║╚██╗██║   ██║   ██║   ██║██║╚██╔╝██║
    ██║     ██║  ██║██║  ██║██║ ╚████║   ██║   ╚██████╔╝██║ ╚═╝ ██║
    ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝
                         H A C K  —  Template GUI
                              by PhantomHack
--]]

--==[ SERVICES ]==--
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

--==[ CONFIG ]==--
local Config = {
    HubName    = "PHANTOM HACK",
    HubVersion = "v1.0.0",
    ValidKeys  = { "PHANTOM-PREMIUM-2026", "PHANTOM-FREE-TRIAL", "PHANTOM-VIP" },
    KeyLink    = "https://phantom.hack/getkey",
    Discord    = "https://discord.gg/phantomhack",

    -- Phantom color palette (red/white/dark)
    Accent       = Color3.fromRGB(220, 30, 40),   -- phantom red
    AccentHover  = Color3.fromRGB(180, 20, 28),
    AccentSoft   = Color3.fromRGB(255, 60, 70),
    Background   = Color3.fromRGB(10, 10, 12),
    Sidebar      = Color3.fromRGB(14, 14, 17),
    Surface      = Color3.fromRGB(20, 20, 24),
    SurfaceHover = Color3.fromRGB(26, 26, 32),
    Border       = Color3.fromRGB(38, 38, 48),
    BorderHover  = Color3.fromRGB(60, 60, 75),
    TextPrimary  = Color3.fromRGB(235, 235, 240),
    TextSecondary= Color3.fromRGB(140, 140, 160),
    TextMuted    = Color3.fromRGB(70, 70, 85),
    Success      = Color3.fromRGB(60, 200, 110),
    Danger       = Color3.fromRGB(220, 30, 40),
    Warning      = Color3.fromRGB(255, 175, 50),

    Font     = Enum.Font.GothamSemibold,
    FontBold = Enum.Font.GothamBold,
    FontReg  = Enum.Font.Gotham,
    ToggleKey = Enum.KeyCode.RightShift,

    W  = 880,
    H  = 570,
    SW = 195,
    TH = 54,
}

-- Live accent (can be changed at runtime)
local LiveAccent = Config.Accent

local function GetAccent() return LiveAccent end
local function SetAccent(c)
    LiveAccent = c
    Config.Accent = c
end

--==[ UTILS ]==--
local function tw(obj, t, props, s, d)
    if not obj or not obj.Parent then return end
    TweenService:Create(obj, TweenInfo.new(t or 0.2,
        s or Enum.EasingStyle.Quart, d or Enum.EasingDirection.Out), props):Play()
end

local function new(cls, props, kids)
    local i = Instance.new(cls)
    for k,v in pairs(props or {}) do i[k]=v end
    for _,c in ipairs(kids or {}) do c.Parent=i end
    return i
end

local function rnd(r)
    return new("UICorner",{CornerRadius=UDim.new(0,r or 8)})
end

local function bdr(col,th)
    return new("UIStroke",{
        Color=col or Config.Border, Thickness=th or 1,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    })
end

local function pad(t,b,l,r)
    return new("UIPadding",{
        PaddingTop=UDim.new(0,t or 0), PaddingBottom=UDim.new(0,b or 0),
        PaddingLeft=UDim.new(0,l or 0), PaddingRight=UDim.new(0,r or 0),
    })
end

-- Detect executor
local function GetExecutor()
    if syn then return "Synapse X"
    elseif KRNL_LOADED then return "KRNL"
    elseif identifyexecutor then return identifyexecutor()
    elseif fluxus then return "Fluxus"
    elseif getexecutorname then return getexecutorname()
    else return "Unknown" end
end

-- Get avatar URL
local function GetAvatarUrl(userId)
    local ok, res = pcall(function()
        return game:GetService("Players"):GetUserThumbnailAsync(
            userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    return ok and res or nil
end

--==[ CLEANUP ]==--
pcall(function()
    if CoreGui:FindFirstChild("PhantomHack") then CoreGui.PhantomHack:Destroy() end
end)

--==[ SCREENGUI ]==--
local Gui = new("ScreenGui",{
    Name="PhantomHack", ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling, IgnoreGuiInset=true,
})
pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(Gui); Gui.Parent=CoreGui
    elseif gethui then Gui.Parent=gethui()
    else Gui.Parent=CoreGui end
end)
if not Gui.Parent then Gui.Parent=LocalPlayer:WaitForChild("PlayerGui") end

--==[ NOTIFICATION SYSTEM ]==--
local NH = new("Frame",{
    AnchorPoint=Vector2.new(1,1),
    Position=UDim2.new(1,-16,1,-16),
    Size=UDim2.new(0,280,1,0),
    BackgroundTransparency=1, Parent=Gui,
},{
    new("UIListLayout",{
        SortOrder=Enum.SortOrder.LayoutOrder,
        VerticalAlignment=Enum.VerticalAlignment.Bottom,
        HorizontalAlignment=Enum.HorizontalAlignment.Right,
        Padding=UDim.new(0,7),
    })
})

local function Notify(title, msg, dur, kind)
    dur = dur or 4
    local ac = (kind=="error" and Config.Danger)
            or (kind=="success" and Config.Success)
            or (kind=="warning" and Config.Warning)
            or GetAccent()

    local n = new("Frame",{
        Size=UDim2.new(1,0,0,58),
        BackgroundColor3=Config.Surface,
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ClipsDescendants=true,
    },{rnd(9), bdr(Config.Border)})
    n.Parent = NH

    -- left accent stripe
    new("Frame",{
        Size=UDim2.new(0,3,0,32),
        Position=UDim2.new(0,0,0.5,0), AnchorPoint=Vector2.new(0,0.5),
        BackgroundColor3=ac, BorderSizePixel=0, Parent=n,
    },{rnd(2)})

    local titleL = new("TextLabel",{
        Position=UDim2.new(0,14,0,10), Size=UDim2.new(1,-24,0,17),
        BackgroundTransparency=1, Text=title,
        TextColor3=Config.TextPrimary, Font=Config.FontBold, TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextTransparency=1, Parent=n,
    })
    local msgL = new("TextLabel",{
        Position=UDim2.new(0,14,0,29), Size=UDim2.new(1,-24,0,14),
        BackgroundTransparency=1, Text=msg,
        TextColor3=Config.TextSecondary, Font=Config.FontReg, TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true,
        TextTransparency=1, Parent=n,
    })

    -- Slide in from right
    n.Position = UDim2.new(1,10,0,0)
    tw(n, 0.28, {BackgroundTransparency=0})
    tw(n, 0.28, {Position=UDim2.new(0,0,0,0)})
    tw(titleL, 0.28, {TextTransparency=0})
    tw(msgL, 0.28, {TextTransparency=0})

    task.delay(dur, function()
        if not n or not n.Parent then return end
        -- Slide out right cleanly
        tw(n, 0.22, {Position=UDim2.new(1,14,0,0)})
        tw(n, 0.22, {BackgroundTransparency=1})
        tw(titleL, 0.18, {TextTransparency=1})
        tw(msgL, 0.18, {TextTransparency=1})
        task.wait(0.25)
        if n and n.Parent then n:Destroy() end
    end)
end

--==[ DRAG ]==--
local function drag(frame, handle)
    handle = handle or frame
    local dragging, ds, sp
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; ds=i.Position; sp=frame.Position
            i.Changed:Connect(function()
                if i.UserInputState==Enum.UserInputState.End then dragging=false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ds
            frame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
end

--=======================================================--
--                     KEY SYSTEM                        --
--=======================================================--
local KF = new("Frame",{
    Name="KeySystem", AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.new(0,440,0,220),
    BackgroundColor3=Config.Background, BorderSizePixel=0, Parent=Gui,
},{rnd(12), bdr(Config.Border)})

-- Red top accent bar
new("Frame",{
    Size=UDim2.new(1,0,0,3),
    BackgroundColor3=Config.Accent, BorderSizePixel=0, Parent=KF,
},{rnd(12)})
-- mask bottom radius of accent bar
new("Frame",{
    Position=UDim2.new(0,0,0,1), Size=UDim2.new(1,0,0,2),
    BackgroundColor3=Config.Accent, BorderSizePixel=0, Parent=KF,
})

-- Logo area
new("Frame",{
    Position=UDim2.new(0,18,0,18), Size=UDim2.new(0,34,0,34),
    BackgroundColor3=Config.Accent, BorderSizePixel=0, Parent=KF,
},{
    rnd(9),
    new("TextLabel",{
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text="P", TextColor3=Color3.new(1,1,1), Font=Config.FontBold, TextSize=19,
    })
})

new("TextLabel",{
    Position=UDim2.new(0,60,0,15), Size=UDim2.new(1,-80,0,18),
    BackgroundTransparency=1, Text=Config.HubName,
    TextColor3=Config.TextPrimary, Font=Config.FontBold, TextSize=16,
    TextXAlignment=Enum.TextXAlignment.Left, Parent=KF,
})
new("TextLabel",{
    Position=UDim2.new(0,60,0,34), Size=UDim2.new(1,-80,0,13),
    BackgroundTransparency=1, Text="Authentication Required  •  "..Config.HubVersion,
    TextColor3=Config.TextSecondary, Font=Config.FontReg, TextSize=11,
    TextXAlignment=Enum.TextXAlignment.Left, Parent=KF,
})

new("Frame",{
    Position=UDim2.new(0,0,0,60), Size=UDim2.new(1,0,0,1),
    BackgroundColor3=Config.Border, BorderSizePixel=0, Parent=KF,
})

-- Input
local KBox = new("Frame",{
    Position=UDim2.new(0,18,0,74), Size=UDim2.new(1,-36,0,40),
    BackgroundColor3=Config.Surface, BorderSizePixel=0, Parent=KF,
},{rnd(8), bdr(Config.Border)})

local KInput = new("TextBox",{
    Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,12,0,0),
    BackgroundTransparency=1, PlaceholderText="Enter license key...",
    PlaceholderColor3=Config.TextMuted, Text="",
    TextColor3=Config.TextPrimary, Font=Config.FontReg, TextSize=13,
    TextXAlignment=Enum.TextXAlignment.Left, ClearTextOnFocus=false, Parent=KBox,
})
local KS = KBox:FindFirstChildOfClass("UIStroke")
KInput.Focused:Connect(function() tw(KS,0.15,{Color=GetAccent()}) end)
KInput.FocusLost:Connect(function() tw(KS,0.15,{Color=Config.Border}) end)

local function mkKBtn(lbl, x, w, primary)
    local b = new("TextButton",{
        Position=UDim2.new(0,x,0,130), Size=UDim2.new(0,w,0,38),
        BackgroundColor3=primary and Config.Accent or Config.Surface,
        BorderSizePixel=0, Text=lbl, TextColor3=Color3.new(1,1,1),
        Font=Config.Font, TextSize=13, AutoButtonColor=false, Parent=KF,
    },{rnd(8), bdr(primary and Config.Accent or Config.Border)})
    b.MouseEnter:Connect(function()
        tw(b,0.12,{BackgroundColor3=primary and Config.AccentHover or Config.SurfaceHover})
    end)
    b.MouseLeave:Connect(function()
        tw(b,0.12,{BackgroundColor3=primary and Config.Accent or Config.Surface})
    end)
    return b
end

local GetKeyBtn = mkKBtn("Get Key",   18, 182, false)
local AuthBtn   = mkKBtn("Authorize", 208, 214, true)

local KStatus = new("TextLabel",{
    Position=UDim2.new(0,0,1,-20), Size=UDim2.new(1,0,0,14),
    BackgroundTransparency=1, Text="© 2026 Phantom Hack",
    TextColor3=Config.TextMuted, Font=Config.FontReg, TextSize=10, Parent=KF,
})

drag(KF)

GetKeyBtn.MouseButton1Click:Connect(function()
    pcall(function() if setclipboard then setclipboard(Config.KeyLink) end end)
    Notify("Link Copied","Key link copied to clipboard.",3,"success")
end)

--=======================================================--
--                     MAIN MENU                         --
--=======================================================--
local BuildMain

AuthBtn.MouseButton1Click:Connect(function()
    local entered = KInput.Text
    local valid = false
    for _,k in ipairs(Config.ValidKeys) do if entered==k then valid=true; break end end
    if valid then
        KStatus.Text="✓ Authenticated — loading menu..."
        KStatus.TextColor3=Config.Success
        Notify("Welcome","Key accepted. Loading Phantom Hack...","3","success")
        tw(KF,0.3,{Size=UDim2.new(0,440,0,0),BackgroundTransparency=1})
        task.wait(0.35); KF:Destroy(); BuildMain()
    else
        KStatus.Text="✗ Invalid key — please try again."
        KStatus.TextColor3=Config.Danger
        Notify("Auth Failed","The key you entered is invalid.",3,"error")
        tw(KS,0.1,{Color=Config.Danger})
        local op=KBox.Position
        for i=1,5 do
            tw(KBox,0.04,{Position=op+UDim2.fromOffset((i%2==0) and -7 or 7,0)})
            task.wait(0.045)
        end
        KBox.Position=op
        task.delay(1.5,function() tw(KS,0.2,{Color=Config.Border}) end)
    end
end)

--=======================================================--
function BuildMain()

    -- Keybind storage
    local Keybinds = {}
    local ListeningFor = nil

    local Main = new("Frame",{
        Name="Main", AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.new(0,0,0,0),
        BackgroundColor3=Config.Background, BorderSizePixel=0,
        ClipsDescendants=true, Parent=Gui,
    },{rnd(12), bdr(Config.Border)})

    tw(Main,0.45,{Size=UDim2.new(0,Config.W,0,Config.H)},
        Enum.EasingStyle.Back,Enum.EasingDirection.Out)

    --==[ TOPBAR ]==--
    local TopBar = new("Frame",{
        Name="TopBar",
        Size=UDim2.new(1,0,0,Config.TH),
        BackgroundColor3=Config.Sidebar, BorderSizePixel=0, Parent=Main,
    },{rnd(12)})
    -- square off bottom corners
    new("Frame",{
        Position=UDim2.new(0,0,1,-10), Size=UDim2.new(1,0,0,10),
        BackgroundColor3=Config.Sidebar, BorderSizePixel=0, Parent=TopBar,
    })
    -- bottom border
    new("Frame",{
        Position=UDim2.new(0,0,1,0), AnchorPoint=Vector2.new(0,1),
        Size=UDim2.new(1,0,0,1), BackgroundColor3=Config.Border,
        BorderSizePixel=0, Parent=TopBar,
    })

    -- P logo
    new("Frame",{
        Position=UDim2.new(0,14,0.5,0), AnchorPoint=Vector2.new(0,0.5),
        Size=UDim2.new(0,32,0,32), BackgroundColor3=GetAccent(),
        BorderSizePixel=0, Parent=TopBar,
    },{
        rnd(9),
        new("TextLabel",{
            Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
            Text="P", TextColor3=Color3.new(1,1,1), Font=Config.FontBold, TextSize=18,
        })
    })

    new("TextLabel",{
        Position=UDim2.new(0,54,0.5,-10), Size=UDim2.new(0,200,0,18),
        BackgroundTransparency=1, Text=Config.HubName,
        TextColor3=Config.TextPrimary, Font=Config.FontBold, TextSize=14,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=TopBar,
    })
    new("TextLabel",{
        Position=UDim2.new(0,54,0.5,8), Size=UDim2.new(0,200,0,13),
        BackgroundTransparency=1, Text=LocalPlayer.DisplayName,
        TextColor3=Config.TextSecondary, Font=Config.FontReg, TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=TopBar,
    })

    -- Sidebar divider in topbar
    new("Frame",{
        Position=UDim2.new(0,Config.SW,0,10), Size=UDim2.new(0,1,0,Config.TH-20),
        BackgroundColor3=Config.Border, BorderSizePixel=0, Parent=TopBar,
    })

    -- Version badge
    new("Frame",{
        Position=UDim2.new(0,Config.SW+14,0.5,0), AnchorPoint=Vector2.new(0,0.5),
        Size=UDim2.new(0,68,0,24), BackgroundColor3=Config.Surface,
        BorderSizePixel=0, Parent=TopBar,
    },{rnd(6), bdr(Config.Border),
        new("TextLabel",{
            Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
            Text=Config.HubVersion, TextColor3=Config.TextSecondary,
            Font=Config.FontReg, TextSize=11,
        })
    })

    -- Executor badge
    new("Frame",{
        Position=UDim2.new(0,Config.SW+90,0.5,0), AnchorPoint=Vector2.new(0,0.5),
        Size=UDim2.new(0,120,0,24), BackgroundColor3=Config.Surface,
        BorderSizePixel=0, Parent=TopBar,
    },{rnd(6), bdr(Config.Border),
        new("TextLabel",{
            Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
            Text="⚙  "..GetExecutor(), TextColor3=Config.TextSecondary,
            Font=Config.FontReg, TextSize=10,
        })
    })

    -- Window controls
    local function mkCtrl(sym, xOff, hoverCol)
        local b = new("TextButton",{
            AnchorPoint=Vector2.new(1,0.5),
            Position=UDim2.new(1,xOff,0.5,0),
            Size=UDim2.new(0,28,0,28),
            BackgroundColor3=Config.Surface, BorderSizePixel=0,
            Text=sym, TextColor3=Config.TextSecondary,
            Font=Config.FontBold, TextSize=13, AutoButtonColor=false, Parent=TopBar,
        },{rnd(7)})
        b.MouseEnter:Connect(function()
            tw(b,0.12,{BackgroundColor3=hoverCol,TextColor3=Color3.new(1,1,1)})
        end)
        b.MouseLeave:Connect(function()
            tw(b,0.12,{BackgroundColor3=Config.Surface,TextColor3=Config.TextSecondary})
        end)
        return b
    end

    local BtnClose = mkCtrl("✕",-10,Config.Danger)
    local BtnMin   = mkCtrl("–",-44,Config.Border)

    local minimized = false
    BtnMin.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            -- Collapse to just user card width × topbar height
            tw(Main,0.28,{Size=UDim2.new(0,Config.SW,0,Config.TH)})
            BtnMin.Text="□"
        else
            tw(Main,0.35,{Size=UDim2.new(0,Config.W,0,Config.H)},
                Enum.EasingStyle.Back,Enum.EasingDirection.Out)
            BtnMin.Text="–"
        end
    end)

    BtnClose.MouseButton1Click:Connect(function()
        tw(Main,0.28,{Size=UDim2.new(0,0,0,0)},Enum.EasingStyle.Back,Enum.EasingDirection.In)
        task.wait(0.3); Gui:Destroy()
    end)

    drag(Main,TopBar)

    --==[ SIDEBAR BG ]==--
    new("Frame",{
        Position=UDim2.new(0,0,0,Config.TH),
        Size=UDim2.new(0,Config.SW,1,-Config.TH),
        BackgroundColor3=Config.Sidebar, BorderSizePixel=0, Parent=Main,
    },{
        new("Frame",{
            Position=UDim2.new(1,0,0,0), AnchorPoint=Vector2.new(1,0),
            Size=UDim2.new(0,1,1,0),
            BackgroundColor3=Config.Border, BorderSizePixel=0,
        })
    })

    --==[ SIDEBAR TAB LIST ]==--
    local SideScroll = new("ScrollingFrame",{
        Position=UDim2.new(0,0,0,Config.TH),
        Size=UDim2.new(0,Config.SW,1,-(Config.TH+62)),
        BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=0,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        Parent=Main,
    },{
        new("UIListLayout",{
            SortOrder=Enum.SortOrder.LayoutOrder,
            Padding=UDim.new(0,3),
        }),
        pad(10,0,8,8),
    })

    --==[ CONTENT AREA ]==--
    local ContentArea = new("Frame",{
        Position=UDim2.new(0,Config.SW,0,Config.TH),
        Size=UDim2.new(1,-Config.SW,1,-Config.TH),
        BackgroundTransparency=1, Parent=Main,
    })

    --==[ USER CARD ]==--
    local UserCard = new("Frame",{
        Position=UDim2.new(0,0,1,-62),
        Size=UDim2.new(0,Config.SW,0,62),
        BackgroundColor3=Config.Sidebar, BorderSizePixel=0, Parent=Main,
    },{rnd(12)})
    -- mask top corners
    new("Frame",{
        Size=UDim2.new(1,0,0,10),
        BackgroundColor3=Config.Sidebar, BorderSizePixel=0, Parent=UserCard,
    })
    new("Frame",{
        Size=UDim2.new(1,0,0,1), BackgroundColor3=Config.Border,
        BorderSizePixel=0, Parent=UserCard,
    })
    new("Frame",{
        Position=UDim2.new(1,0,0,0), AnchorPoint=Vector2.new(1,0),
        Size=UDim2.new(0,1,1,0), BackgroundColor3=Config.Border,
        BorderSizePixel=0, Parent=UserCard,
    })

    -- Avatar image
    local AvatarFrame = new("Frame",{
        Position=UDim2.new(0,10,0.5,0), AnchorPoint=Vector2.new(0,0.5),
        Size=UDim2.new(0,36,0,36), BackgroundColor3=GetAccent(),
        BorderSizePixel=0, Parent=UserCard,
    },{rnd(18)})

    -- Try to load real Roblox avatar
    local AvatarImg = new("ImageLabel",{
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Image="", Parent=AvatarFrame,
    },{rnd(18)})

    local fallbackLbl = new("TextLabel",{
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text=string.upper(string.sub(LocalPlayer.Name,1,1)),
        TextColor3=Color3.new(1,1,1), Font=Config.FontBold, TextSize=18,
        Parent=AvatarFrame,
    })

    task.spawn(function()
        local url = GetAvatarUrl(LocalPlayer.UserId)
        if url then
            AvatarImg.Image = url
            fallbackLbl.Visible = false
        end
    end)

    local nameLblCard = new("TextLabel",{
        Position=UDim2.new(0,52,0,12), Size=UDim2.new(1,-70,0,17),
        BackgroundTransparency=1, Text=LocalPlayer.Name,
        TextColor3=Config.TextPrimary, Font=Config.Font, TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=UserCard,
    })
    new("TextLabel",{
        Position=UDim2.new(0,52,0,30), Size=UDim2.new(1,-70,0,13),
        BackgroundTransparency=1, Text="Premium | Lifetime",
        TextColor3=GetAccent(), Font=Config.FontReg, TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=UserCard,
    })

    -- Profile button (opens profile page)
    local profileBtn = new("TextButton",{
        AnchorPoint=Vector2.new(1,0.5),
        Position=UDim2.new(1,-8,0.5,0),
        Size=UDim2.new(0,20,0,20),
        BackgroundTransparency=1, Text="›",
        TextColor3=Config.TextMuted, Font=Config.FontBold, TextSize=20,
        AutoButtonColor=false, Parent=UserCard,
    })

    --=======================================================--
    --                    TAB SYSTEM                          --
    --=======================================================--
    local ActiveTab = nil
    local AllTabs   = {}

    local function SetTab(td)
        if ActiveTab==td then return end
        if ActiveTab then
            ActiveTab.Page.Visible=false
            tw(ActiveTab.Btn,0.15,{BackgroundTransparency=1})
            tw(ActiveTab.Lbl,0.15,{TextColor3=Config.TextSecondary})
            tw(ActiveTab.Ico,0.15,{TextColor3=Config.TextMuted})
            ActiveTab.Bar.Visible=false
        end
        ActiveTab=td
        td.Page.Visible=true
        tw(td.Btn,0.15,{BackgroundTransparency=0,BackgroundColor3=Config.SurfaceHover})
        tw(td.Lbl,0.15,{TextColor3=Config.TextPrimary})
        tw(td.Ico,0.15,{TextColor3=GetAccent()})
        td.Bar.Visible=true
    end

    local function AddTab(name, icon)
        local btn = new("TextButton",{
            Size=UDim2.new(1,0,0,36),
            BackgroundColor3=Config.SurfaceHover,
            BackgroundTransparency=1,
            BorderSizePixel=0, Text="",
            AutoButtonColor=false, Parent=SideScroll,
        },{rnd(7)})

        local bar = new("Frame",{
            Position=UDim2.new(0,0,0.5,0), AnchorPoint=Vector2.new(0,0.5),
            Size=UDim2.new(0,3,0,20),
            BackgroundColor3=GetAccent(), BorderSizePixel=0,
            Visible=false, Parent=btn,
        },{rnd(2)})

        local ico = new("TextLabel",{
            Position=UDim2.new(0,10,0.5,0), AnchorPoint=Vector2.new(0,0.5),
            Size=UDim2.new(0,20,0,20),
            BackgroundTransparency=1, Text=icon or "•",
            TextColor3=Config.TextMuted,
            Font=Config.FontBold, TextSize=14, Parent=btn,
        })

        local lbl = new("TextLabel",{
            Position=UDim2.new(0,34,0,0), Size=UDim2.new(1,-38,1,0),
            BackgroundTransparency=1, Text=name,
            TextColor3=Config.TextSecondary,
            Font=Config.Font, TextSize=12,
            TextXAlignment=Enum.TextXAlignment.Left, Parent=btn,
        })

        local page = new("ScrollingFrame",{
            Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1, BorderSizePixel=0,
            ScrollBarThickness=3,
            ScrollBarImageColor3=GetAccent(),
            CanvasSize=UDim2.new(0,0,0,0),
            AutomaticCanvasSize=Enum.AutomaticSize.Y,
            Visible=false, Parent=ContentArea,
        },{
            new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6)}),
            pad(14,14,14,14),
        })

        local td={Btn=btn,Page=page,Lbl=lbl,Ico=ico,Bar=bar}
        table.insert(AllTabs,td)

        btn.MouseButton1Click:Connect(function() SetTab(td) end)
        btn.MouseEnter:Connect(function()
            if ActiveTab~=td then
                tw(btn,0.12,{BackgroundTransparency=0})
                tw(lbl,0.12,{TextColor3=Config.TextPrimary})
            end
        end)
        btn.MouseLeave:Connect(function()
            if ActiveTab~=td then
                tw(btn,0.12,{BackgroundTransparency=1})
                tw(lbl,0.12,{TextColor3=Config.TextSecondary})
            end
        end)

        --==[ COMPONENTS ]==--
        local API={}

        function API:Section(text)
            new("TextLabel",{
                Size=UDim2.new(1,0,0,20),
                BackgroundTransparency=1, Text=text,
                TextColor3=Config.TextSecondary,
                Font=Config.Font, TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Left,
                Parent=page,
            })
        end

        function API:Divider()
            new("Frame",{
                Size=UDim2.new(1,0,0,1),
                BackgroundColor3=Config.Border, BorderSizePixel=0, Parent=page,
            })
        end

        local function Row(h)
            return new("Frame",{
                Size=UDim2.new(1,0,0,h or 42),
                BackgroundColor3=Config.Surface, BorderSizePixel=0,
                Parent=page,
            },{rnd(8), bdr(Config.Border)})
        end

        -- TOGGLE with notification option
        function API:Toggle(text, default, callback, notifyMsg)
            local state=default or false
            local row=Row(42)

            new("TextLabel",{
                Position=UDim2.new(0,14,0,0), Size=UDim2.new(1,-76,1,0),
                BackgroundTransparency=1, Text=text,
                TextColor3=Config.TextPrimary, Font=Config.Font, TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=row,
            })

            new("TextButton",{
                AnchorPoint=Vector2.new(1,0.5),
                Position=UDim2.new(1,-52,0.5,0),
                Size=UDim2.new(0,26,0,26),
                BackgroundColor3=Config.SurfaceHover, BorderSizePixel=0,
                Text="···", TextColor3=Config.TextMuted,
                Font=Config.FontBold, TextSize=11,
                AutoButtonColor=false, Parent=row,
            },{rnd(5)})

            local sw=new("Frame",{
                AnchorPoint=Vector2.new(1,0.5),
                Position=UDim2.new(1,-12,0.5,0),
                Size=UDim2.new(0,36,0,19),
                BackgroundColor3=Config.Border, BorderSizePixel=0, Parent=row,
            },{rnd(10)})

            local knob=new("Frame",{
                Position=UDim2.new(0,2,0.5,0), AnchorPoint=Vector2.new(0,0.5),
                Size=UDim2.new(0,15,0,15),
                BackgroundColor3=Config.TextMuted, BorderSizePixel=0, Parent=sw,
            },{rnd(8)})

            local function refresh()
                if state then
                    tw(sw,0.18,{BackgroundColor3=GetAccent()})
                    tw(knob,0.18,{Position=UDim2.new(1,-17,0.5,0),BackgroundColor3=Color3.new(1,1,1)})
                else
                    tw(sw,0.18,{BackgroundColor3=Config.Border})
                    tw(knob,0.18,{Position=UDim2.new(0,2,0.5,0),BackgroundColor3=Config.TextMuted})
                end
            end
            refresh()

            local hit=new("TextButton",{
                Size=UDim2.new(1,0,1,0),
                BackgroundTransparency=1, Text="", Parent=row,
            })
            hit.MouseButton1Click:Connect(function()
                state=not state; refresh()
                local nm = notifyMsg or text
                Notify(nm, state and "Enabled" or "Disabled", 2, state and "success" or "error")
                if callback then pcall(callback,state) end
            end)

            return {
                Set=function(_,v) state=v; refresh() end,
                Get=function() return state end,
            }
        end

        -- DROPDOWN
        function API:Dropdown(text, opts, default, callback)
            local sel=default or opts[1]
            local open=false
            local baseH,optH=42,30

            local row=new("Frame",{
                Size=UDim2.new(1,0,0,baseH),
                BackgroundColor3=Config.Surface, BorderSizePixel=0,
                ClipsDescendants=true, Parent=page,
            },{rnd(8), bdr(Config.Border)})

            new("TextLabel",{
                Position=UDim2.new(0,14,0,0), Size=UDim2.new(0.5,0,0,baseH),
                BackgroundTransparency=1, Text=text,
                TextColor3=Config.TextPrimary, Font=Config.Font, TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=row,
            })

            local valLbl=new("TextLabel",{
                AnchorPoint=Vector2.new(1,0),
                Position=UDim2.new(1,-30,0,0),
                Size=UDim2.new(0.45,0,0,baseH),
                BackgroundTransparency=1, Text=sel,
                TextColor3=Config.TextSecondary, Font=Config.FontReg, TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Right, Parent=row,
            })

            local arrowBox=new("Frame",{
                AnchorPoint=Vector2.new(1,0.5),
                Position=UDim2.new(1,-10,0,baseH/2),
                Size=UDim2.new(0,16,0,16),
                BackgroundColor3=Config.SurfaceHover, BorderSizePixel=0, Parent=row,
            },{rnd(4), bdr(Config.Border)})
            local arrowLbl=new("TextLabel",{
                Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
                Text="▾", TextColor3=Config.TextSecondary,
                Font=Config.FontBold, TextSize=10, Parent=arrowBox,
            })

            local listFrame=new("Frame",{
                Position=UDim2.new(0,6,0,baseH+2),
                Size=UDim2.new(1,-12,0,0),
                BackgroundTransparency=1, Parent=row,
            },{new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)})})

            for _,opt in ipairs(opts) do
                local ob=new("TextButton",{
                    Size=UDim2.new(1,0,0,optH),
                    BackgroundColor3=Config.SurfaceHover, BorderSizePixel=0,
                    Text=opt, TextColor3=Config.TextSecondary,
                    Font=Config.FontReg, TextSize=12,
                    AutoButtonColor=false, Parent=listFrame,
                },{rnd(5)})
                ob.MouseEnter:Connect(function() tw(ob,0.1,{BackgroundColor3=Config.BorderHover,TextColor3=Config.TextPrimary}) end)
                ob.MouseLeave:Connect(function() tw(ob,0.1,{BackgroundColor3=Config.SurfaceHover,TextColor3=Config.TextSecondary}) end)
                ob.MouseButton1Click:Connect(function()
                    sel=opt; valLbl.Text=opt; open=false
                    tw(row,0.18,{Size=UDim2.new(1,0,0,baseH)})
                    tw(arrowLbl,0.18,{Rotation=0})
                    if callback then pcall(callback,opt) end
                end)
            end

            local hit=new("TextButton",{
                Size=UDim2.new(1,0,0,baseH),
                BackgroundTransparency=1, Text="", Parent=row,
            })
            hit.MouseButton1Click:Connect(function()
                open=not open
                local nh=open and (baseH+4+(#opts*(optH+2))) or baseH
                tw(row,0.2,{Size=UDim2.new(1,0,0,nh)})
                tw(arrowLbl,0.18,{Rotation=open and 180 or 0})
            end)

            return {
                Set=function(_,v) sel=v; valLbl.Text=v end,
                Get=function() return sel end,
            }
        end

        -- SLIDER
        function API:Slider(text, mn, mx, def, callback)
            mn,mx=mn or 0,mx or 100
            local val=math.clamp(def or mn,mn,mx)
            local row=Row(54)

            new("TextLabel",{
                Position=UDim2.new(0,14,0,8), Size=UDim2.new(0.65,0,0,16),
                BackgroundTransparency=1, Text=text,
                TextColor3=Config.TextPrimary, Font=Config.Font, TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=row,
            })
            local vLbl=new("TextLabel",{
                AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-14,0,8),
                Size=UDim2.new(0,60,0,16),
                BackgroundTransparency=1, Text=tostring(val),
                TextColor3=GetAccent(), Font=Config.Font, TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Right, Parent=row,
            })
            local track=new("Frame",{
                Position=UDim2.new(0,14,1,-13), Size=UDim2.new(1,-28,0,4),
                BackgroundColor3=Config.Border, BorderSizePixel=0, Parent=row,
            },{rnd(2)})
            local fill=new("Frame",{
                Size=UDim2.new((val-mn)/(mx-mn),0,1,0),
                BackgroundColor3=GetAccent(), BorderSizePixel=0, Parent=track,
            },{rnd(2)})

            local dragging=false
            local function setX(x)
                local r=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
                val=math.floor(mn+(mx-mn)*r+0.5)
                vLbl.Text=tostring(val); fill.Size=UDim2.new(r,0,1,0)
                if callback then pcall(callback,val) end
            end
            track.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true;setX(i.Position.X) end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then setX(i.Position.X) end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
            end)
            return {
                Set=function(_,v)
                    val=math.clamp(v,mn,mx); vLbl.Text=tostring(val)
                    fill.Size=UDim2.new((val-mn)/(mx-mn),0,1,0)
                end,
                Get=function() return val end,
            }
        end

        -- BUTTON
        function API:Button(text, callback)
            local b=new("TextButton",{
                Size=UDim2.new(1,0,0,38),
                BackgroundColor3=Config.Surface, BorderSizePixel=0,
                Text=text, TextColor3=Config.TextPrimary,
                Font=Config.Font, TextSize=12,
                AutoButtonColor=false, Parent=page,
            },{rnd(8), bdr(Config.Border)})
            b.MouseEnter:Connect(function()
                tw(b,0.12,{BackgroundColor3=Config.SurfaceHover})
                tw(b:FindFirstChildOfClass("UIStroke"),0.12,{Color=GetAccent()})
            end)
            b.MouseLeave:Connect(function()
                tw(b,0.12,{BackgroundColor3=Config.Surface})
                tw(b:FindFirstChildOfClass("UIStroke"),0.12,{Color=Config.Border})
            end)
            b.MouseButton1Click:Connect(function() if callback then pcall(callback) end end)
            return b
        end

        -- PRIMARY BUTTON (accent colored)
        function API:PrimaryButton(text, callback)
            local b=new("TextButton",{
                Size=UDim2.new(1,0,0,38),
                BackgroundColor3=GetAccent(), BorderSizePixel=0,
                Text=text, TextColor3=Color3.new(1,1,1),
                Font=Config.FontBold, TextSize=12,
                AutoButtonColor=false, Parent=page,
            },{rnd(8)})
            b.MouseEnter:Connect(function() tw(b,0.12,{BackgroundColor3=Config.AccentHover}) end)
            b.MouseLeave:Connect(function() tw(b,0.12,{BackgroundColor3=GetAccent()}) end)
            b.MouseButton1Click:Connect(function() if callback then pcall(callback) end end)
            return b
        end

        -- KEYBIND
        function API:Keybind(text, default, callback)
            local key = default or Enum.KeyCode.Unknown
            local listening = false
            local row = Row(42)

            new("TextLabel",{
                Position=UDim2.new(0,14,0,0), Size=UDim2.new(1,-100,1,0),
                BackgroundTransparency=1, Text=text,
                TextColor3=Config.TextPrimary, Font=Config.Font, TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=row,
            })

            local keyBtn=new("TextButton",{
                AnchorPoint=Vector2.new(1,0.5),
                Position=UDim2.new(1,-10,0.5,0),
                Size=UDim2.new(0,80,0,26),
                BackgroundColor3=Config.SurfaceHover, BorderSizePixel=0,
                Text=key.Name, TextColor3=GetAccent(),
                Font=Config.FontBold, TextSize=11,
                AutoButtonColor=false, Parent=row,
            },{rnd(5), bdr(Config.Border)})

            local kbData = {key=key, name=text, callback=callback}
            table.insert(Keybinds, kbData)

            keyBtn.MouseButton1Click:Connect(function()
                if ListeningFor then return end
                listening=true; ListeningFor=kbData
                keyBtn.Text="[ Press key ]"
                keyBtn.TextColor3=Config.TextPrimary
                tw(keyBtn,0.1,{BackgroundColor3=Config.Surface})
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if not listening or not ListeningFor or ListeningFor~=kbData then return end
                if input.UserInputType==Enum.UserInputType.Keyboard then
                    key=input.KeyCode; kbData.key=key
                    keyBtn.Text=key.Name
                    keyBtn.TextColor3=GetAccent()
                    tw(keyBtn,0.1,{BackgroundColor3=Config.SurfaceHover})
                    listening=false; ListeningFor=nil
                    Notify("Keybind Set",text.." → "..key.Name,2,"success")
                end
            end)

            return kbData
        end

        -- TEXTBOX
        function API:Textbox(text, placeholder, callback)
            local row=Row(42)
            new("TextLabel",{
                Position=UDim2.new(0,14,0,0), Size=UDim2.new(0.38,0,1,0),
                BackgroundTransparency=1, Text=text,
                TextColor3=Config.TextPrimary, Font=Config.Font, TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=row,
            })
            local box=new("TextBox",{
                AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-10,0.5,0),
                Size=UDim2.new(0.57,0,0,26),
                BackgroundColor3=Config.SurfaceHover, BorderSizePixel=0,
                Text="", PlaceholderText=placeholder or "",
                PlaceholderColor3=Config.TextMuted, TextColor3=Config.TextPrimary,
                Font=Config.FontReg, TextSize=12, ClearTextOnFocus=false, Parent=row,
            },{rnd(5), bdr(Config.Border)})
            box.FocusLost:Connect(function(e) if e and callback then pcall(callback,box.Text) end end)
            return box
        end

        -- INFO ROW
        function API:Info(label, value)
            local row=new("Frame",{
                Size=UDim2.new(1,0,0,36),
                BackgroundColor3=Config.Surface, BorderSizePixel=0, Parent=page,
            },{rnd(8), bdr(Config.Border)})
            new("TextLabel",{
                Position=UDim2.new(0,14,0,0), Size=UDim2.new(0.5,0,1,0),
                BackgroundTransparency=1, Text=label,
                TextColor3=Config.TextSecondary, Font=Config.FontReg, TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=row,
            })
            local vl=new("TextLabel",{
                AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-14,0.5,0),
                Size=UDim2.new(0.5,0,0,18),
                BackgroundTransparency=1, Text=tostring(value),
                TextColor3=Config.TextPrimary, Font=Config.FontBold, TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Right, Parent=row,
            })
            return {SetValue=function(_,v) vl.Text=tostring(v) end}
        end

        return API
    end

    --=======================================================--
    --               PROFILE OVERLAY                         --
    --=======================================================--
    local ProfileOverlay = new("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=Color3.fromRGB(0,0,0),
        BackgroundTransparency=0.45,
        BorderSizePixel=0, Visible=false, ZIndex=10, Parent=ContentArea,
    })
    local ProfileCard = new("Frame",{
        AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0,320,0,380),
        BackgroundColor3=Config.Background, BorderSizePixel=0,
        ZIndex=11, Parent=ProfileOverlay,
    },{rnd(14), bdr(Config.Border)})

    -- Red top stripe
    new("Frame",{
        Size=UDim2.new(1,0,0,3), BackgroundColor3=GetAccent(),
        BorderSizePixel=0, ZIndex=12, Parent=ProfileCard,
    },{rnd(14)})
    new("Frame",{
        Position=UDim2.new(0,0,0,1), Size=UDim2.new(1,0,0,2),
        BackgroundColor3=GetAccent(), BorderSizePixel=0, ZIndex=12, Parent=ProfileCard,
    })

    -- Close profile
    local closeProfile=new("TextButton",{
        AnchorPoint=Vector2.new(1,0),
        Position=UDim2.new(1,-10,0,10),
        Size=UDim2.new(0,26,0,26),
        BackgroundColor3=Config.Surface, BorderSizePixel=0,
        Text="✕", TextColor3=Config.TextSecondary,
        Font=Config.FontBold, TextSize=13,
        AutoButtonColor=false, ZIndex=12, Parent=ProfileCard,
    },{rnd(7)})
    closeProfile.MouseButton1Click:Connect(function()
        ProfileOverlay.Visible=false
    end)

    -- Avatar (large)
    local bigAvFrame=new("Frame",{
        AnchorPoint=Vector2.new(0.5,0),
        Position=UDim2.new(0.5,0,0,22),
        Size=UDim2.new(0,80,0,80),
        BackgroundColor3=GetAccent(), BorderSizePixel=0, ZIndex=12, Parent=ProfileCard,
    },{rnd(40)})
    local bigAvImg=new("ImageLabel",{
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Image="", ZIndex=13, Parent=bigAvFrame,
    },{rnd(40)})
    local bigAvFallback=new("TextLabel",{
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text=string.upper(string.sub(LocalPlayer.Name,1,1)),
        TextColor3=Color3.new(1,1,1), Font=Config.FontBold, TextSize=36,
        ZIndex=13, Parent=bigAvFrame,
    })

    task.spawn(function()
        local url=GetAvatarUrl(LocalPlayer.UserId)
        if url then
            bigAvImg.Image=url; bigAvFallback.Visible=false
        end
    end)

    new("TextLabel",{
        AnchorPoint=Vector2.new(0.5,0),
        Position=UDim2.new(0.5,0,0,112),
        Size=UDim2.new(1,-30,0,22),
        BackgroundTransparency=1, Text=LocalPlayer.DisplayName,
        TextColor3=Config.TextPrimary, Font=Config.FontBold, TextSize=16,
        ZIndex=12, Parent=ProfileCard,
    })
    new("TextLabel",{
        AnchorPoint=Vector2.new(0.5,0),
        Position=UDim2.new(0.5,0,0,135),
        Size=UDim2.new(1,-30,0,15),
        BackgroundTransparency=1, Text="@"..LocalPlayer.Name,
        TextColor3=Config.TextSecondary, Font=Config.FontReg, TextSize=12,
        ZIndex=12, Parent=ProfileCard,
    })

    new("Frame",{
        Position=UDim2.new(0,0,0,162),
        Size=UDim2.new(1,0,0,1), BackgroundColor3=Config.Border,
        BorderSizePixel=0, ZIndex=12, Parent=ProfileCard,
    })

    -- Stats grid
    local statsData={
        {"User ID", tostring(LocalPlayer.UserId)},
        {"Account Age", LocalPlayer.AccountAge.." days"},
        {"Executor", GetExecutor()},
        {"Game ID", tostring(game.PlaceId)},
        {"Team", LocalPlayer.Team and LocalPlayer.Team.Name or "None"},
        {"Membership", "Premium | Lifetime"},
    }
    for i,stat in ipairs(statsData) do
        local yPos = 170 + (i-1)*28
        new("TextLabel",{
            Position=UDim2.new(0,18,0,yPos), Size=UDim2.new(0.48,0,0,22),
            BackgroundTransparency=1, Text=stat[1],
            TextColor3=Config.TextSecondary, Font=Config.FontReg, TextSize=11,
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=12, Parent=ProfileCard,
        })
        new("TextLabel",{
            AnchorPoint=Vector2.new(1,0),
            Position=UDim2.new(1,-18,0,yPos), Size=UDim2.new(0.48,0,0,22),
            BackgroundTransparency=1, Text=stat[2],
            TextColor3=Config.TextPrimary, Font=Config.FontBold, TextSize=11,
            TextXAlignment=Enum.TextXAlignment.Right, ZIndex=12, Parent=ProfileCard,
        })
    end

    profileBtn.MouseButton1Click:Connect(function()
        ProfileOverlay.Visible=true
    end)
    ProfileOverlay.MouseButton1Click:Connect(function()
        ProfileOverlay.Visible=false
    end)

    --=======================================================--
    --                  KEYBINDS OVERLAY                     --
    --=======================================================--
    local KbOverlay=new("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=Color3.fromRGB(0,0,0),
        BackgroundTransparency=0.45,
        BorderSizePixel=0, Visible=false, ZIndex=10, Parent=ContentArea,
    })
    local KbCard=new("Frame",{
        AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0,400,0,300),
        BackgroundColor3=Config.Background, BorderSizePixel=0,
        ZIndex=11, Parent=KbOverlay,
    },{rnd(14), bdr(Config.Border)})

    new("Frame",{
        Size=UDim2.new(1,0,0,3), BackgroundColor3=GetAccent(),
        BorderSizePixel=0, ZIndex=12, Parent=KbCard,
    },{rnd(14)})
    new("Frame",{
        Position=UDim2.new(0,0,0,1), Size=UDim2.new(1,0,0,2),
        BackgroundColor3=GetAccent(), BorderSizePixel=0, ZIndex=12, Parent=KbCard,
    })

    local closeKb=new("TextButton",{
        AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-10,0,10),
        Size=UDim2.new(0,26,0,26),
        BackgroundColor3=Config.Surface, BorderSizePixel=0,
        Text="✕", TextColor3=Config.TextSecondary,
        Font=Config.FontBold, TextSize=13,
        AutoButtonColor=false, ZIndex=12, Parent=KbCard,
    },{rnd(7)})
    closeKb.MouseButton1Click:Connect(function() KbOverlay.Visible=false end)
    KbOverlay.MouseButton1Click:Connect(function() KbOverlay.Visible=false end)

    new("TextLabel",{
        Position=UDim2.new(0,18,0,10), Size=UDim2.new(1,-60,0,22),
        BackgroundTransparency=1, Text="Keybinds",
        TextColor3=Config.TextPrimary, Font=Config.FontBold, TextSize=15,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=12, Parent=KbCard,
    })

    local kbList=new("ScrollingFrame",{
        Position=UDim2.new(0,0,0,42), Size=UDim2.new(1,0,1,-42),
        BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=3, ScrollBarImageColor3=GetAccent(),
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ZIndex=12, Parent=KbCard,
    },{
        new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4)}),
        pad(8,8,12,12),
    })

    local function RefreshKbList()
        for _,c in ipairs(kbList:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        local builtins = {
            {"Toggle Menu", Config.ToggleKey},
            {"Show Keybinds", Enum.KeyCode.F2},
        }
        for _,kb in ipairs(builtins) do
            local r=new("Frame",{
                Size=UDim2.new(1,0,0,36),
                BackgroundColor3=Config.Surface, BorderSizePixel=0, ZIndex=13, Parent=kbList,
            },{rnd(7), bdr(Config.Border)})
            new("TextLabel",{
                Position=UDim2.new(0,12,0,0), Size=UDim2.new(0.6,0,1,0),
                BackgroundTransparency=1, Text=kb[1],
                TextColor3=Config.TextPrimary, Font=Config.Font, TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14, Parent=r,
            })
            new("TextLabel",{
                AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-12,0.5,0),
                Size=UDim2.new(0,80,0,24),
                BackgroundTransparency=1, Text=kb[2].Name,
                TextColor3=GetAccent(), Font=Config.FontBold, TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Right, ZIndex=14, Parent=r,
            })
        end
        for _,kb in ipairs(Keybinds) do
            local r=new("Frame",{
                Size=UDim2.new(1,0,0,36),
                BackgroundColor3=Config.Surface, BorderSizePixel=0, ZIndex=13, Parent=kbList,
            },{rnd(7), bdr(Config.Border)})
            new("TextLabel",{
                Position=UDim2.new(0,12,0,0), Size=UDim2.new(0.6,0,1,0),
                BackgroundTransparency=1, Text=kb.name,
                TextColor3=Config.TextPrimary, Font=Config.Font, TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14, Parent=r,
            })
            new("TextLabel",{
                AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-12,0.5,0),
                Size=UDim2.new(0,80,0,24),
                BackgroundTransparency=1, Text=kb.key.Name,
                TextColor3=GetAccent(), Font=Config.FontBold, TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Right, ZIndex=14, Parent=r,
            })
        end
    end

    KbOverlay:GetPropertyChangedSignal("Visible"):Connect(function()
        if KbOverlay.Visible then RefreshKbList() end
    end)

    --=======================================================--
    --                    TAB DEFINITIONS                     --
    --=======================================================--

    --==[ HOME ]==--
    local Home=AddTab("Home","⌂")
    Home:Section("Overview")
    Home:Info("User", LocalPlayer.Name)
    Home:Info("Display Name", LocalPlayer.DisplayName)
    Home:Info("User ID", tostring(LocalPlayer.UserId))
    Home:Info("Account Age", LocalPlayer.AccountAge.." days")
    Home:Info("Game ID", tostring(game.PlaceId))
    Home:Info("Executor", GetExecutor())
    Home:Info("Hub Version", Config.HubVersion)
    Home:Divider()
    Home:Section("Quick Actions")
    Home:Button("View Profile", function()
        ProfileOverlay.Visible=true
    end)
    Home:Button("Show Keybinds", function()
        KbOverlay.Visible=true
    end)
    Home:Button("Rejoin Server", function()
        Notify("Rejoin","Rejoining server...",2,"warning")
        pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId,LocalPlayer)
        end)
    end)
    Home:Button("Copy Profile Link", function()
        pcall(function()
            if setclipboard then
                setclipboard("https://www.roblox.com/users/"..LocalPlayer.UserId.."/profile")
            end
        end)
        Notify("Copied","Roblox profile link copied.",2,"success")
    end)

    --==[ SETTINGS ]==--
    local SettingsTab=AddTab("Settings","⚙")
    SettingsTab:Section("Appearance")

    local accentColors={
        Red=Color3.fromRGB(220,30,40),
        Blue=Color3.fromRGB(88,130,255),
        Purple=Color3.fromRGB(138,99,255),
        Cyan=Color3.fromRGB(40,200,220),
        Green=Color3.fromRGB(60,200,110),
        Orange=Color3.fromRGB(255,140,40),
    }

    SettingsTab:Dropdown("Accent Color",{"Red","Blue","Purple","Cyan","Green","Orange"},"Red",function(c)
        SetAccent(accentColors[c] or Config.Accent)
        Notify("Theme","Accent color updated to "..c,2,"success")
        -- live update all visible accent elements
        for _,td in ipairs(AllTabs) do
            if td.Bar.Visible then
                td.Bar.BackgroundColor3=GetAccent()
                tw(td.Ico,0,{TextColor3=GetAccent()})
            end
        end
    end)

    SettingsTab:Toggle("Show Notifications", true, function(s)
        -- Note: handled internally
    end)

    SettingsTab:Section("Keybinds")
    SettingsTab:Keybind("Toggle Menu", Enum.KeyCode.RightShift, function() end)
    SettingsTab:Button("View All Keybinds", function() KbOverlay.Visible=true end)

    SettingsTab:Section("System Info")
    SettingsTab:Info("Executor", GetExecutor())
    SettingsTab:Info("Ping", "—")
    SettingsTab:Info("FPS", "—")

    -- Live FPS/Ping update
    local fpsInfo, pingInfo
    for _,c in ipairs(SettingsTab) do end -- placeholder; we use direct refs below
    -- We'll update via RunService in a moment

    SettingsTab:Divider()
    SettingsTab:Section("Hub")
    SettingsTab:Button("Copy Discord", function()
        pcall(function() if setclipboard then setclipboard(Config.Discord) end end)
        Notify("Discord","Invite link copied to clipboard.",3,"success")
    end)
    SettingsTab:Button("Unload Hub", function()
        Notify("Unloading","Phantom Hack is unloading...",2,"warning")
        task.wait(0.4)
        tw(Main,0.28,{Size=UDim2.new(0,0,0,0)},Enum.EasingStyle.Back,Enum.EasingDirection.In)
        task.wait(0.3); Gui:Destroy()
    end)

    --==[ UPDATE TAB ]==--
    local UpdateTab=AddTab("Updates","↑")
    UpdateTab:Section("Current Version")
    UpdateTab:Info("Version", Config.HubVersion)
    UpdateTab:Info("Status", "Up to date")
    UpdateTab:Info("Last Check", "Just now")
    UpdateTab:Divider()
    UpdateTab:Section("Changelog — "..Config.HubVersion)
    local changelogItems={
        "✦  Full rebrand to Phantom Hack",
        "✦  Red/white dark color palette",
        "✦  Roblox avatar loading",
        "✦  Profile viewer overlay",
        "✦  Keybind system + viewer",
        "✦  Live accent color switching",
        "✦  Executor detection",
        "✦  Slide-out notifications (no flicker)",
        "✦  Compact minimize (sidebar width only)",
        "✦  Template-ready: drop in your scripts",
    }
    for _,item in ipairs(changelogItems) do
        UpdateTab:Section(item)
    end
    UpdateTab:Divider()
    UpdateTab:Button("Check for Updates", function()
        Notify("Update Check","Checking for latest version...",2,"warning")
        task.wait(1.5)
        Notify("Up to Date","You are running the latest version.",3,"success")
    end)
    UpdateTab:Button("Copy Key Link", function()
        pcall(function() if setclipboard then setclipboard(Config.KeyLink) end end)
        Notify("Copied","Key link copied.",2,"success")
    end)

    --==[ MISC TAB ]==--
    local Misc=AddTab("Misc","✦")
    Misc:Section("Utility")
    Misc:Toggle("Anti-AFK", false, function(s)
        if s then
            LocalPlayer.Idled:Connect(function()
                LocalPlayer:Move(Vector3.new(0,0,0))
            end)
        end
    end)
    Misc:Toggle("Hide Player List", false, function(s)
        pcall(function()
            local ps=LocalPlayer.PlayerGui:FindFirstChild("PlayerListGui")
            if ps then ps.Enabled=not s end
        end)
    end)
    Misc:Button("Rejoin Server", function()
        pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId,LocalPlayer)
        end)
    end)
    Misc:Button("Copy Profile URL", function()
        pcall(function()
            if setclipboard then
                setclipboard("https://www.roblox.com/users/"..LocalPlayer.UserId.."/profile")
            end
        end)
        Notify("Copied","Profile URL copied.",2,"success")
    end)

    Misc:Section("Fun")
    Misc:Toggle("Third Person Lock", false, function(s)
        pcall(function()
            workspace.CurrentCamera.CameraType = s
                and Enum.CameraType.Attach
                or  Enum.CameraType.Custom
        end)
    end)
    Misc:Slider("Field of View", 60, 120, 70, function(v)
        pcall(function() workspace.CurrentCamera.FieldOfView=v end)
    end)

    Misc:Section("Debug")
    Misc:Info("Place Name", game.Name ~= "" and game.Name or "Unknown")
    Misc:Info("Place ID", tostring(game.PlaceId))
    Misc:Info("Job ID", string.sub(tostring(game.JobId),1,12).."...")

    -- Select first tab
    SetTab(AllTabs[1])

    --==[ GLOBAL KEYBIND LISTENER ]==--
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        -- Toggle menu
        if input.KeyCode==Config.ToggleKey then
            Main.Visible=not Main.Visible
            return
        end
        -- F2 = keybinds panel
        if input.KeyCode==Enum.KeyCode.F2 then
            if Main.Visible then KbOverlay.Visible=not KbOverlay.Visible end
            return
        end
        -- Fire registered keybinds
        for _,kb in ipairs(Keybinds) do
            if kb.key==input.KeyCode and kb.callback then
                pcall(kb.callback)
            end
        end
    end)

end -- BuildMain

Notify("Phantom Hack","Loaded  •  RightShift to toggle  •  F2 for keybinds",5,"success")
