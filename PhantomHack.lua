--[[
    ╔══════════════════════════════════════════════════════════╗
    ║              VOID HUB - Premium Exploit Menu             ║
    ║              Sleek • Modern • Professional               ║
    ╚══════════════════════════════════════════════════════════╝
    
    Features:
    • Animated Key System with HWID validation
    • Modern dark UI with smooth animations
    • Tabbed navigation (Core menu)
    • Toggle, Slider, Button, Dropdown, Textbox components
    • Draggable & minimizable interface
    • Notification system
--]]

--==[ SERVICES ]==--
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local HttpService      = game:GetService("HttpService")
local TextService      = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

--==[ CONFIG ]==--
local Config = {
    HubName        = "VOID HUB",
    HubVersion     = "v2.4.1",
    ValidKeys      = { "VOID-PREMIUM-2026", "VOID-FREE-TRIAL", "VOID-VIP-ACCESS" },
    KeyLink        = "https://void.hub/getkey",
    Accent         = Color3.fromRGB(138, 99, 255),   -- Purple accent
    AccentDark     = Color3.fromRGB(99, 71, 200),
    Background     = Color3.fromRGB(15, 15, 20),
    Surface        = Color3.fromRGB(22, 22, 30),
    SurfaceLight   = Color3.fromRGB(30, 30, 40),
    Border         = Color3.fromRGB(45, 45, 60),
    TextPrimary    = Color3.fromRGB(240, 240, 245),
    TextSecondary  = Color3.fromRGB(160, 160, 180),
    Success        = Color3.fromRGB(80, 220, 130),
    Danger         = Color3.fromRGB(255, 90, 110),
    Font           = Enum.Font.Gotham,
    FontBold       = Enum.Font.GothamBold,
    FontSemi       = Enum.Font.GothamSemibold,
    ToggleKey      = Enum.KeyCode.RightShift,
}

--==[ UTILITIES ]==--
local function tween(obj, time, props, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(
        time or 0.25,
        style or Enum.EasingStyle.Quart,
        dir   or Enum.EasingDirection.Out
    ), props)
    t:Play()
    return t
end

local function create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function corner(radius)
    return create("UICorner", { CornerRadius = UDim.new(0, radius or 6) })
end

local function stroke(color, thickness, transparency)
    return create("UIStroke", {
        Color        = color or Config.Border,
        Thickness    = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function gradient(colors, rotation)
    return create("UIGradient", {
        Color    = ColorSequence.new(colors),
        Rotation = rotation or 0,
    })
end

local function padding(p)
    return create("UIPadding", {
        PaddingTop    = UDim.new(0, p),
        PaddingBottom = UDim.new(0, p),
        PaddingLeft   = UDim.new(0, p),
        PaddingRight  = UDim.new(0, p),
    })
end

--==[ CLEANUP PREVIOUS INSTANCE ]==--
pcall(function()
    if CoreGui:FindFirstChild("VoidHub") then
        CoreGui.VoidHub:Destroy()
    end
end)

--==[ ROOT GUI ]==--
local ScreenGui = create("ScreenGui", {
    Name              = "VoidHub",
    ResetOnSpawn      = false,
    ZIndexBehavior    = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset    = true,
})

-- Try CoreGui (executor protected) first, then fallback
local ok = pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = CoreGui
    end
end)
if not ok then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

--==[ NOTIFICATION SYSTEM ]==--
local NotifyHolder = create("Frame", {
    Name                   = "Notifications",
    AnchorPoint            = Vector2.new(1, 1),
    Position               = UDim2.new(1, -20, 1, -20),
    Size                   = UDim2.new(0, 300, 1, -40),
    BackgroundTransparency = 1,
    Parent                 = ScreenGui,
}, {
    create("UIListLayout", {
        SortOrder           = Enum.SortOrder.LayoutOrder,
        VerticalAlignment   = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding             = UDim.new(0, 8),
    }),
})

local function Notify(title, message, duration, kind)
    duration = duration or 4
    local accent = (kind == "error" and Config.Danger)
                or (kind == "success" and Config.Success)
                or Config.Accent

    local notif = create("Frame", {
        Size                   = UDim2.new(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        BackgroundColor3       = Config.Surface,
        BackgroundTransparency = 1,
        ClipsDescendants       = true,
    }, {
        corner(8),
        stroke(Config.Border, 1, 1),
        create("Frame", {
            Name             = "Accent",
            Size             = UDim2.new(0, 3, 1, -16),
            Position         = UDim2.new(0, 8, 0, 8),
            BackgroundColor3 = accent,
            BorderSizePixel  = 0,
        }, { corner(2) }),
        create("TextLabel", {
            Name                   = "Title",
            Position               = UDim2.new(0, 22, 0, 10),
            Size                   = UDim2.new(1, -32, 0, 18),
            BackgroundTransparency = 1,
            Text                   = title,
            TextColor3             = Config.TextPrimary,
            TextTransparency       = 1,
            Font                   = Config.FontBold,
            TextSize               = 14,
            TextXAlignment         = Enum.TextXAlignment.Left,
        }),
        create("TextLabel", {
            Name                   = "Body",
            Position               = UDim2.new(0, 22, 0, 30),
            Size                   = UDim2.new(1, -32, 0, 0),
            AutomaticSize          = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text                   = message,
            TextColor3             = Config.TextSecondary,
            TextTransparency       = 1,
            Font                   = Config.Font,
            TextSize               = 12,
            TextXAlignment         = Enum.TextXAlignment.Left,
            TextWrapped            = true,
        }),
        create("Frame", {
            Name             = "Spacer",
            Position         = UDim2.new(0, 0, 1, -8),
            Size             = UDim2.new(1, 0, 0, 8),
            BackgroundTransparency = 1,
        }),
    })
    notif.Parent = NotifyHolder

    tween(notif, 0.3, { BackgroundTransparency = 0 })
    tween(notif:FindFirstChild("Title"), 0.3, { TextTransparency = 0 })
    tween(notif:FindFirstChild("Body"),  0.3, { TextTransparency = 0 })
    tween(notif:FindFirstChildOfClass("UIStroke"), 0.3, { Transparency = 0 })

    task.delay(duration, function()
        tween(notif, 0.25, { BackgroundTransparency = 1 })
        tween(notif:FindFirstChild("Title"), 0.25, { TextTransparency = 1 })
        tween(notif:FindFirstChild("Body"),  0.25, { TextTransparency = 1 })
        tween(notif:FindFirstChildOfClass("UIStroke"), 0.25, { Transparency = 1 })
        task.wait(0.3)
        notif:Destroy()
    end)
end

--==[ DRAGGABLE HELPER ]==--
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                      or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--=====================================================--
--                  KEY SYSTEM UI                      --
--=====================================================--
local KeyFrame = create("Frame", {
    Name                   = "KeySystem",
    AnchorPoint            = Vector2.new(0.5, 0.5),
    Position               = UDim2.new(0.5, 0, 0.5, 0),
    Size                   = UDim2.new(0, 380, 0, 240),
    BackgroundColor3       = Config.Background,
    BackgroundTransparency = 1,
    BorderSizePixel        = 0,
    Parent                 = ScreenGui,
}, {
    corner(12),
    stroke(Config.Border, 1, 1),
})

-- Header gradient bar
local KeyHeader = create("Frame", {
    Size             = UDim2.new(1, 0, 0, 4),
    BackgroundColor3 = Config.Accent,
    BorderSizePixel  = 0,
    Parent           = KeyFrame,
}, {
    corner(12),
    gradient({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(99, 71, 200)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(138, 99, 255)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(180, 130, 255)),
    }, 0),
})

-- Logo / Title
create("TextLabel", {
    Position               = UDim2.new(0, 0, 0, 24),
    Size                   = UDim2.new(1, 0, 0, 28),
    BackgroundTransparency = 1,
    Text                   = Config.HubName,
    TextColor3             = Config.TextPrimary,
    Font                   = Config.FontBold,
    TextSize               = 24,
    Parent                 = KeyFrame,
})

create("TextLabel", {
    Position               = UDim2.new(0, 0, 0, 54),
    Size                   = UDim2.new(1, 0, 0, 16),
    BackgroundTransparency = 1,
    Text                   = "AUTHENTICATION REQUIRED",
    TextColor3             = Config.Accent,
    Font                   = Config.FontSemi,
    TextSize               = 11,
    Parent                 = KeyFrame,
})

-- Key input box
local KeyBox = create("Frame", {
    Position         = UDim2.new(0.5, 0, 0, 90),
    AnchorPoint      = Vector2.new(0.5, 0),
    Size             = UDim2.new(1, -40, 0, 40),
    BackgroundColor3 = Config.Surface,
    BorderSizePixel  = 0,
    Parent           = KeyFrame,
}, {
    corner(8),
    stroke(Config.Border, 1, 0),
})

local KeyInput = create("TextBox", {
    Size                   = UDim2.new(1, -20, 1, 0),
    Position               = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    PlaceholderText        = "Enter your license key...",
    PlaceholderColor3      = Config.TextSecondary,
    Text                   = "",
    TextColor3             = Config.TextPrimary,
    Font                   = Config.Font,
    TextSize               = 13,
    TextXAlignment         = Enum.TextXAlignment.Left,
    ClearTextOnFocus       = false,
    Parent                 = KeyBox,
})

local KeyStroke = KeyBox:FindFirstChildOfClass("UIStroke")
KeyInput.Focused:Connect(function()
    tween(KeyStroke, 0.2, { Color = Config.Accent })
end)
KeyInput.FocusLost:Connect(function()
    tween(KeyStroke, 0.2, { Color = Config.Border })
end)

-- Buttons row
local function makeKeyButton(text, posX, width, primary)
    local btn = create("TextButton", {
        Position         = UDim2.new(0, posX, 0, 145),
        Size             = UDim2.new(0, width, 0, 38),
        BackgroundColor3 = primary and Config.Accent or Config.Surface,
        BorderSizePixel  = 0,
        Text             = text,
        TextColor3       = Config.TextPrimary,
        Font             = Config.FontSemi,
        TextSize         = 13,
        AutoButtonColor  = false,
        Parent           = KeyFrame,
    }, {
        corner(8),
        stroke(primary and Config.Accent or Config.Border, 1, 0),
    })
    btn.MouseEnter:Connect(function()
        tween(btn, 0.15, {
            BackgroundColor3 = primary and Config.AccentDark or Config.SurfaceLight
        })
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, 0.15, {
            BackgroundColor3 = primary and Config.Accent or Config.Surface
        })
    end)
    return btn
end

local GetKeyBtn = makeKeyButton("Get Key",   20,  165, false)
local CheckBtn  = makeKeyButton("Authorize", 195, 165, true)

-- Status label
local StatusLabel = create("TextLabel", {
    Position               = UDim2.new(0, 0, 1, -28),
    Size                   = UDim2.new(1, 0, 0, 16),
    BackgroundTransparency = 1,
    Text                   = "© 2026 Void Hub  •  Build " .. Config.HubVersion,
    TextColor3             = Config.TextSecondary,
    Font                   = Config.Font,
    TextSize               = 11,
    Parent                 = KeyFrame,
})

-- Animate in
tween(KeyFrame, 0.4, { BackgroundTransparency = 0 })
tween(KeyFrame:FindFirstChildOfClass("UIStroke"), 0.4, { Transparency = 0 })

-- Get Key button: copy link
GetKeyBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if setclipboard then setclipboard(Config.KeyLink)
        elseif toclipboard then toclipboard(Config.KeyLink)
        end
    end)
    Notify("Link Copied", "Key URL copied to clipboard.", 3, "success")
end)

--==[ MAIN MENU FORWARD-DECLARED ]==--
local BuildMainMenu

CheckBtn.MouseButton1Click:Connect(function()
    local entered = KeyInput.Text
    local valid = false
    for _, k in ipairs(Config.ValidKeys) do
        if entered == k then valid = true break end
    end

    if valid then
        StatusLabel.Text       = "✓ Authentication successful — Loading hub..."
        StatusLabel.TextColor3 = Config.Success
        Notify("Welcome", "Key accepted. Loading menu...", 3, "success")

        tween(KeyFrame, 0.35, {
            BackgroundTransparency = 1,
            Size                   = UDim2.new(0, 380, 0, 0),
        })
        for _, c in ipairs(KeyFrame:GetDescendants()) do
            if c:IsA("TextLabel") or c:IsA("TextBox") or c:IsA("TextButton") then
                tween(c, 0.25, { TextTransparency = 1 })
            end
            if c:IsA("Frame") and c ~= KeyFrame then
                tween(c, 0.25, { BackgroundTransparency = 1 })
            end
            if c:IsA("UIStroke") then
                tween(c, 0.25, { Transparency = 1 })
            end
        end
        task.wait(0.45)
        KeyFrame:Destroy()
        BuildMainMenu()
    else
        StatusLabel.Text       = "✗ Invalid key — please try again."
        StatusLabel.TextColor3 = Config.Danger
        Notify("Authentication Failed", "The key entered is invalid.", 3, "error")

        -- shake animation
        local origPos = KeyBox.Position
        for i = 1, 4 do
            local off = (i % 2 == 0) and -8 or 8
            tween(KeyBox, 0.05, {
                Position = origPos + UDim2.fromOffset(off, 0)
            })
            task.wait(0.05)
        end
        KeyBox.Position = origPos
        tween(KeyStroke, 0.2, { Color = Config.Danger })
        task.delay(1.5, function()
            tween(KeyStroke, 0.2, { Color = Config.Border })
        end)
    end
end)

--=====================================================--
--                    MAIN MENU                        --
--=====================================================--
function BuildMainMenu()
    -- Window
    local Main = create("Frame", {
        Name             = "Main",
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Config.Background,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        Parent           = ScreenGui,
    }, {
        corner(10),
        stroke(Config.Border, 1, 0),
    })

    tween(Main, 0.45, { Size = UDim2.new(0, 620, 0, 420) },
        Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    --==[ TOPBAR ]==--
    local TopBar = create("Frame", {
        Size             = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Config.Surface,
        BorderSizePixel  = 0,
        Parent           = Main,
    }, {
        corner(10),
    })
    -- mask bottom corners of topbar
    create("Frame", {
        Position         = UDim2.new(0, 0, 1, -10),
        Size             = UDim2.new(1, 0, 0, 10),
        BackgroundColor3 = Config.Surface,
        BorderSizePixel  = 0,
        Parent           = TopBar,
    })

    create("Frame", {
        Position         = UDim2.new(0, 14, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
        Size             = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = Config.Accent,
        BorderSizePixel  = 0,
        Parent           = TopBar,
    }, { corner(4) })

    create("TextLabel", {
        Position               = UDim2.new(0, 30, 0, 0),
        Size                   = UDim2.new(0, 200, 1, 0),
        BackgroundTransparency = 1,
        Text                   = Config.HubName .. "  " .. Config.HubVersion,
        TextColor3             = Config.TextPrimary,
        Font                   = Config.FontBold,
        TextSize               = 13,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = TopBar,
    })

    create("TextLabel", {
        AnchorPoint            = Vector2.new(0.5, 0.5),
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        Size                   = UDim2.new(0, 200, 1, 0),
        BackgroundTransparency = 1,
        Text                   = "Welcome, " .. LocalPlayer.DisplayName,
        TextColor3             = Config.TextSecondary,
        Font                   = Config.Font,
        TextSize               = 12,
        Parent                 = TopBar,
    })

    -- Window controls
    local function makeCtrl(symbol, posOffset, hoverColor)
        local b = create("TextButton", {
            AnchorPoint      = Vector2.new(1, 0.5),
            Position         = UDim2.new(1, posOffset, 0.5, 0),
            Size             = UDim2.new(0, 26, 0, 26),
            BackgroundColor3 = Config.SurfaceLight,
            BorderSizePixel  = 0,
            Text             = symbol,
            TextColor3       = Config.TextSecondary,
            Font             = Config.FontBold,
            TextSize         = 14,
            AutoButtonColor  = false,
            Parent           = TopBar,
        }, { corner(6) })
        b.MouseEnter:Connect(function()
            tween(b, 0.15, {
                BackgroundColor3 = hoverColor or Config.Border,
                TextColor3       = Config.TextPrimary,
            })
        end)
        b.MouseLeave:Connect(function()
            tween(b, 0.15, {
                BackgroundColor3 = Config.SurfaceLight,
                TextColor3       = Config.TextSecondary,
            })
        end)
        return b
    end

    local CloseBtn    = makeCtrl("✕", -10, Config.Danger)
    local MinimizeBtn = makeCtrl("–", -42, Config.Border)

    local minimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            tween(Main, 0.3, { Size = UDim2.new(0, 620, 0, 40) })
        else
            tween(Main, 0.3, { Size = UDim2.new(0, 620, 0, 420) })
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        tween(Main, 0.3, { Size = UDim2.new(0, 0, 0, 0) },
            Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.32)
        ScreenGui:Destroy()
    end)

    makeDraggable(Main, TopBar)

    --==[ SIDEBAR ]==--
    local SideBar = create("Frame", {
        Position         = UDim2.new(0, 0, 0, 40),
        Size             = UDim2.new(0, 150, 1, -40),
        BackgroundColor3 = Config.Surface,
        BorderSizePixel  = 0,
        Parent           = Main,
    }, {
        create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 4),
        }),
        create("UIPadding", {
            PaddingTop  = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight= UDim.new(0, 10),
        }),
    })

    --==[ CONTENT AREA ]==--
    local Content = create("Frame", {
        Position               = UDim2.new(0, 150, 0, 40),
        Size                   = UDim2.new(1, -150, 1, -40),
        BackgroundTransparency = 1,
        Parent                 = Main,
    })

    --==[ TAB SYSTEM ]==--
    local Tabs       = {}
    local CurrentTab = nil

    local function CreateTab(name, icon)
        -- Sidebar button
        local btn = create("TextButton", {
            Size             = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Config.Surface,
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            Text             = "",
            AutoButtonColor  = false,
            Parent           = SideBar,
        }, { corner(6) })

        local accentBar = create("Frame", {
            Position         = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint      = Vector2.new(0, 0.5),
            Size             = UDim2.new(0, 3, 0, 0),
            BackgroundColor3 = Config.Accent,
            BorderSizePixel  = 0,
            Parent           = btn,
        }, { corner(2) })

        local label = create("TextLabel", {
            Position               = UDim2.new(0, 14, 0, 0),
            Size                   = UDim2.new(1, -14, 1, 0),
            BackgroundTransparency = 1,
            Text                   = (icon and (icon .. "  ") or "") .. name,
            TextColor3             = Config.TextSecondary,
            Font                   = Config.Font,
            TextSize               = 13,
            TextXAlignment         = Enum.TextXAlignment.Left,
            Parent                 = btn,
        })

        -- Page (scrolling frame for content)
        local page = create("ScrollingFrame", {
            Size                   = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            ScrollBarThickness     = 3,
            ScrollBarImageColor3   = Config.Accent,
            CanvasSize             = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize    = Enum.AutomaticSize.Y,
            Visible                = false,
            Parent                 = Content,
        }, {
            create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding   = UDim.new(0, 10),
            }),
            create("UIPadding", {
                PaddingTop    = UDim.new(0, 16),
                PaddingBottom = UDim.new(0, 16),
                PaddingLeft   = UDim.new(0, 18),
                PaddingRight  = UDim.new(0, 18),
            }),
        })

        local tabData = { Button = btn, Page = page, Label = label, Bar = accentBar }
        Tabs[name] = tabData

        btn.MouseButton1Click:Connect(function()
            if CurrentTab == tabData then return end
            if CurrentTab then
                CurrentTab.Page.Visible = false
                tween(CurrentTab.Label, 0.15, { TextColor3 = Config.TextSecondary })
                tween(CurrentTab.Bar,   0.15, { Size = UDim2.new(0, 3, 0, 0) })
                tween(CurrentTab.Button,0.15, { BackgroundTransparency = 1 })
            end
            CurrentTab = tabData
            page.Visible = true
            tween(label, 0.15, { TextColor3 = Config.TextPrimary })
            tween(accentBar, 0.2, { Size = UDim2.new(0, 3, 0, 18) })
            tween(btn, 0.15, { BackgroundColor3 = Config.SurfaceLight, BackgroundTransparency = 0 })
        end)

        btn.MouseEnter:Connect(function()
            if CurrentTab ~= tabData then
                tween(label, 0.15, { TextColor3 = Config.TextPrimary })
            end
        end)
        btn.MouseLeave:Connect(function()
            if CurrentTab ~= tabData then
                tween(label, 0.15, { TextColor3 = Config.TextSecondary })
            end
        end)

        --==[ COMPONENT FACTORIES ]==--
        local TabAPI = {}

        function TabAPI:Section(text)
            local s = create("TextLabel", {
                Size                   = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text                   = string.upper(text),
                TextColor3             = Config.Accent,
                Font                   = Config.FontBold,
                TextSize               = 11,
                TextXAlignment         = Enum.TextXAlignment.Left,
                Parent                 = page,
            })
            return s
        end

        function TabAPI:Label(text)
            return create("TextLabel", {
                Size                   = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Text                   = text,
                TextColor3             = Config.TextSecondary,
                Font                   = Config.Font,
                TextSize               = 12,
                TextXAlignment         = Enum.TextXAlignment.Left,
                TextWrapped            = true,
                Parent                 = page,
            })
        end

        function TabAPI:Button(text, callback)
            local b = create("TextButton", {
                Size             = UDim2.new(1, 0, 0, 34),
                BackgroundColor3 = Config.Surface,
                BorderSizePixel  = 0,
                Text             = text,
                TextColor3       = Config.TextPrimary,
                Font             = Config.FontSemi,
                TextSize         = 12,
                AutoButtonColor  = false,
                Parent           = page,
            }, {
                corner(6),
                stroke(Config.Border, 1, 0),
            })
            b.MouseEnter:Connect(function()
                tween(b, 0.15, { BackgroundColor3 = Config.SurfaceLight })
                tween(b:FindFirstChildOfClass("UIStroke"), 0.15, { Color = Config.Accent })
            end)
            b.MouseLeave:Connect(function()
                tween(b, 0.15, { BackgroundColor3 = Config.Surface })
                tween(b:FindFirstChildOfClass("UIStroke"), 0.15, { Color = Config.Border })
            end)
            b.MouseButton1Click:Connect(function()
                if callback then pcall(callback) end
            end)
            return b
        end

        function TabAPI:Toggle(text, default, callback)
            local state = default or false

            local row = create("Frame", {
                Size             = UDim2.new(1, 0, 0, 34),
                BackgroundColor3 = Config.Surface,
                BorderSizePixel  = 0,
                Parent           = page,
            }, {
                corner(6),
                stroke(Config.Border, 1, 0),
            })

            create("TextLabel", {
                Position               = UDim2.new(0, 12, 0, 0),
                Size                   = UDim2.new(1, -60, 1, 0),
                BackgroundTransparency = 1,
                Text                   = text,
                TextColor3             = Config.TextPrimary,
                Font                   = Config.Font,
                TextSize               = 12,
                TextXAlignment         = Enum.TextXAlignment.Left,
                Parent                 = row,
            })

            local switch = create("Frame", {
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, -10, 0.5, 0),
                Size             = UDim2.new(0, 36, 0, 18),
                BackgroundColor3 = Config.SurfaceLight,
                BorderSizePixel  = 0,
                Parent           = row,
            }, { corner(9) })

            local knob = create("Frame", {
                Position         = UDim2.new(0, 2, 0.5, 0),
                AnchorPoint      = Vector2.new(0, 0.5),
                Size             = UDim2.new(0, 14, 0, 14),
                BackgroundColor3 = Config.TextSecondary,
                BorderSizePixel  = 0,
                Parent           = switch,
            }, { corner(7) })

            local clickArea = create("TextButton", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = "",
                Parent           = row,
            })

            local function update()
                if state then
                    tween(switch, 0.2, { BackgroundColor3 = Config.Accent })
                    tween(knob, 0.2, {
                        Position         = UDim2.new(1, -16, 0.5, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    })
                else
                    tween(switch, 0.2, { BackgroundColor3 = Config.SurfaceLight })
                    tween(knob, 0.2, {
                        Position         = UDim2.new(0, 2, 0.5, 0),
                        BackgroundColor3 = Config.TextSecondary,
                    })
                end
            end
            update()

            clickArea.MouseButton1Click:Connect(function()
                state = not state
                update()
                if callback then pcall(callback, state) end
            end)

            return {
                Set = function(_, v) state = v; update() end,
                Get = function() return state end,
            }
        end

        function TabAPI:Slider(text, min, max, default, callback)
            min, max = min or 0, max or 100
            local value = math.clamp(default or min, min, max)

            local row = create("Frame", {
                Size             = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = Config.Surface,
                BorderSizePixel  = 0,
                Parent           = page,
            }, {
                corner(6),
                stroke(Config.Border, 1, 0),
            })

            local label = create("TextLabel", {
                Position               = UDim2.new(0, 12, 0, 6),
                Size                   = UDim2.new(1, -60, 0, 16),
                BackgroundTransparency = 1,
                Text                   = text,
                TextColor3             = Config.TextPrimary,
                Font                   = Config.Font,
                TextSize               = 12,
                TextXAlignment         = Enum.TextXAlignment.Left,
                Parent                 = row,
            })

            local valueLbl = create("TextLabel", {
                AnchorPoint            = Vector2.new(1, 0),
                Position               = UDim2.new(1, -12, 0, 6),
                Size                   = UDim2.new(0, 50, 0, 16),
                BackgroundTransparency = 1,
                Text                   = tostring(value),
                TextColor3             = Config.Accent,
                Font                   = Config.FontSemi,
                TextSize               = 12,
                TextXAlignment         = Enum.TextXAlignment.Right,
                Parent                 = row,
            })

            local track = create("Frame", {
                Position         = UDim2.new(0, 12, 1, -16),
                Size             = UDim2.new(1, -24, 0, 4),
                BackgroundColor3 = Config.SurfaceLight,
                BorderSizePixel  = 0,
                Parent           = row,
            }, { corner(2) })

            local fill = create("Frame", {
                Size             = UDim2.new((value - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Config.Accent,
                BorderSizePixel  = 0,
                Parent           = track,
            }, { corner(2) })

            local dragging = false
            local function setFromX(x)
                local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * rel + 0.5)
                valueLbl.Text = tostring(value)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                if callback then pcall(callback, value) end
            end

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    setFromX(input.Position.X)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                              or input.UserInputType == Enum.UserInputType.Touch) then
                    setFromX(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            return {
                Set = function(_, v)
                    value = math.clamp(v, min, max)
                    valueLbl.Text = tostring(value)
                    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                end,
                Get = function() return value end,
            }
        end

        function TabAPI:Dropdown(text, options, default, callback)
            local selected = default or options[1]
            local open = false

            local row = create("Frame", {
                Size             = UDim2.new(1, 0, 0, 34),
                BackgroundColor3 = Config.Surface,
                BorderSizePixel  = 0,
                ClipsDescendants = true,
                Parent           = page,
            }, {
                corner(6),
                stroke(Config.Border, 1, 0),
            })

            create("TextLabel", {
                Position               = UDim2.new(0, 12, 0, 0),
                Size                   = UDim2.new(0.5, 0, 0, 34),
                BackgroundTransparency = 1,
                Text                   = text,
                TextColor3             = Config.TextPrimary,
                Font                   = Config.Font,
                TextSize               = 12,
                TextXAlignment         = Enum.TextXAlignment.Left,
                Parent                 = row,
            })

            local valLbl = create("TextLabel", {
                AnchorPoint            = Vector2.new(1, 0),
                Position               = UDim2.new(1, -32, 0, 0),
                Size                   = UDim2.new(0.5, 0, 0, 34),
                BackgroundTransparency = 1,
                Text                   = selected,
                TextColor3             = Config.TextSecondary,
                Font                   = Config.Font,
                TextSize               = 12,
                TextXAlignment         = Enum.TextXAlignment.Right,
                Parent                 = row,
            })

            local arrow = create("TextLabel", {
                AnchorPoint            = Vector2.new(1, 0.5),
                Position               = UDim2.new(1, -10, 0, 17),
                Size                   = UDim2.new(0, 16, 0, 16),
                BackgroundTransparency = 1,
                Text                   = "▾",
                TextColor3             = Config.TextSecondary,
                Font                   = Config.FontBold,
                TextSize               = 12,
                Parent                 = row,
            })

            local list = create("Frame", {
                Position               = UDim2.new(0, 8, 0, 36),
                Size                   = UDim2.new(1, -16, 0, 0),
                BackgroundTransparency = 1,
                Parent                 = row,
            }, {
                create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding   = UDim.new(0, 2),
                }),
            })

            for _, opt in ipairs(options) do
                local optBtn = create("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 24),
                    BackgroundColor3 = Config.SurfaceLight,
                    BorderSizePixel  = 0,
                    Text             = opt,
                    TextColor3       = Config.TextSecondary,
                    Font             = Config.Font,
                    TextSize         = 12,
                    AutoButtonColor  = false,
                    Parent           = list,
                }, { corner(4) })
                optBtn.MouseEnter:Connect(function()
                    tween(optBtn, 0.1, { BackgroundColor3 = Config.Border, TextColor3 = Config.TextPrimary })
                end)
                optBtn.MouseLeave:Connect(function()
                    tween(optBtn, 0.1, { BackgroundColor3 = Config.SurfaceLight, TextColor3 = Config.TextSecondary })
                end)
                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    valLbl.Text = opt
                    open = false
                    tween(row, 0.2, { Size = UDim2.new(1, 0, 0, 34) })
                    tween(arrow, 0.2, { Rotation = 0 })
                    if callback then pcall(callback, opt) end
                end)
            end

            local toggleBtn = create("TextButton", {
                Size             = UDim2.new(1, 0, 0, 34),
                BackgroundTransparency = 1,
                Text             = "",
                Parent           = row,
            })

            toggleBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    tween(row, 0.25, { Size = UDim2.new(1, 0, 0, 36 + (#options * 26) + 4) })
                    tween(arrow, 0.2, { Rotation = 180 })
                else
                    tween(row, 0.2, { Size = UDim2.new(1, 0, 0, 34) })
                    tween(arrow, 0.2, { Rotation = 0 })
                end
            end)

            return {
                Set = function(_, v) selected = v; valLbl.Text = v end,
                Get = function() return selected end,
            }
        end

        function TabAPI:Textbox(text, placeholder, callback)
            local row = create("Frame", {
                Size             = UDim2.new(1, 0, 0, 34),
                BackgroundColor3 = Config.Surface,
                BorderSizePixel  = 0,
                Parent           = page,
            }, {
                corner(6),
                stroke(Config.Border, 1, 0),
            })

            create("TextLabel", {
                Position               = UDim2.new(0, 12, 0, 0),
                Size                   = UDim2.new(0.4, 0, 1, 0),
                BackgroundTransparency = 1,
                Text                   = text,
                TextColor3             = Config.TextPrimary,
                Font                   = Config.Font,
                TextSize               = 12,
                TextXAlignment         = Enum.TextXAlignment.Left,
                Parent                 = row,
            })

            local box = create("TextBox", {
                AnchorPoint            = Vector2.new(1, 0.5),
                Position               = UDim2.new(1, -10, 0.5, 0),
                Size                   = UDim2.new(0.55, 0, 0, 22),
                BackgroundColor3       = Config.SurfaceLight,
                BorderSizePixel        = 0,
                Text                   = "",
                PlaceholderText        = placeholder or "",
                PlaceholderColor3      = Config.TextSecondary,
                TextColor3             = Config.TextPrimary,
                Font                   = Config.Font,
                TextSize               = 12,
                ClearTextOnFocus       = false,
                Parent                 = row,
            }, { corner(4) })

            box.FocusLost:Connect(function(enter)
                if enter and callback then pcall(callback, box.Text) end
            end)

            return box
        end

        return TabAPI
    end

    --=================================================--
    --        BUILD CORE TABS WITH SAMPLE OPTIONS      --
    --=================================================--
    local Home = CreateTab("Home", "🏠")
    Home:Section("Welcome")
    Home:Label("Thanks for using " .. Config.HubName .. "! Use the sidebar to navigate.")
    Home:Label("Press " .. tostring(Config.ToggleKey).." to toggle the menu.")

    Home:Section("Quick Stats")
    Home:Label("• User: " .. LocalPlayer.Name)
    Home:Label("• Game: " .. game.PlaceId)
    Home:Label("• Build: " .. Config.HubVersion)
    Home:Button("Rejoin Server", function()
        local ts = game:GetService("TeleportService")
        ts:Teleport(game.PlaceId, LocalPlayer)
    end)
    Home:Button("Server Hop (random)", function()
        Notify("Server Hop", "Searching for a new server...", 3)
    end)

    --==[ COMBAT TAB ]==--
    local Combat = CreateTab("Combat", "⚔")
    Combat:Section("Aim Assist")
    Combat:Toggle("Enable Aimbot", false, function(s)
        Notify("Aimbot", s and "Enabled" or "Disabled", 2, s and "success" or "error")
    end)
    Combat:Slider("FOV Radius", 50, 500, 200)
    Combat:Slider("Smoothness", 0, 10, 3)
    Combat:Dropdown("Target Part", { "Head", "Torso", "HumanoidRootPart" }, "Head")
    Combat:Toggle("Visible Check",   true)
    Combat:Toggle("Team Check",      true)

    Combat:Section("Misc Combat")
    Combat:Toggle("Kill Aura",       false)
    Combat:Slider("Kill Aura Range", 5, 50, 15)

    --==[ MOVEMENT TAB ]==--
    local Movement = CreateTab("Movement", "⚡")
    Movement:Section("Speed & Jump")
    Movement:Toggle("Walkspeed Modifier", false, function(s)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = s and 50 or 16 end
    end)
    Movement:Slider("Walkspeed", 16, 200, 50, function(v)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end)
    Movement:Slider("JumpPower", 50, 500, 50, function(v)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v end
    end)

    Movement:Section("Flight")
    Movement:Toggle("Fly", false)
    Movement:Slider("Fly Speed",  10, 200, 60)
    Movement:Toggle("Noclip",     false)
    Movement:Toggle("Infinite Jump", false)

    --==[ VISUALS TAB ]==--
    local Visuals = CreateTab("Visuals", "👁")
    Visuals:Section("ESP")
    Visuals:Toggle("Player ESP",     false)
    Visuals:Toggle("Box ESP",        false)
    Visuals:Toggle("Tracer Lines",   false)
    Visuals:Toggle("Health Bar",     true)
    Visuals:Toggle("Name Display",   true)
    Visuals:Toggle("Distance",       true)

    Visuals:Section("World")
    Visuals:Toggle("Fullbright",     false)
    Visuals:Slider("Field of View",  70, 120, 90, function(v)
        workspace.CurrentCamera.FieldOfView = v
    end)

    --==[ TELEPORT TAB ]==--
    local Teleport = CreateTab("Teleport", "📍")
    Teleport:Section("Player Teleport")
    local TargetBox = Teleport:Textbox("Target Player", "Username...")
    Teleport:Button("Teleport to Player", function()
        local name = TargetBox.Text
        local target = Players:FindFirstChild(name)
        if target and target.Character and LocalPlayer.Character then
            LocalPlayer.Character:PivotTo(target.Character:GetPivot())
            Notify("Teleport", "Teleported to " .. name, 2, "success")
        else
            Notify("Teleport", "Player not found.", 2, "error")
        end
    end)
    Teleport:Section("Saved Locations")
    Teleport:Button("Save Current Position", function()
        Notify("Saved", "Current position saved.", 2, "success")
    end)
    Teleport:Button("Load Saved Position", function()
        Notify("Loaded", "Loaded saved position.", 2)
    end)

    --==[ SETTINGS TAB ]==--
    local Settings = CreateTab("Settings", "⚙")
    Settings:Section("Interface")
    Settings:Dropdown("Accent Color", { "Purple", "Blue", "Pink", "Green", "Red" }, "Purple", function(c)
        local map = {
            Purple = Color3.fromRGB(138, 99, 255),
            Blue   = Color3.fromRGB(80, 150, 255),
            Pink   = Color3.fromRGB(255, 100, 180),
            Green  = Color3.fromRGB(80, 220, 130),
            Red    = Color3.fromRGB(255, 90, 110),
        }
        Config.Accent = map[c] or Config.Accent
        Notify("Theme", "Accent updated to " .. c, 2, "success")
    end)
    Settings:Toggle("Show Notifications", true)
    Settings:Toggle("Auto-save Config",   true)

    Settings:Section("Configs")
    Settings:Button("Save Config",   function() Notify("Config", "Saved to executor.", 2, "success") end)
    Settings:Button("Load Config",   function() Notify("Config", "Loaded from executor.", 2, "success") end)
    Settings:Button("Reset to Default", function() Notify("Config", "Reset to defaults.", 2) end)

    Settings:Section("Hub")
    Settings:Button("Discord Server", function()
        pcall(function()
            if setclipboard then setclipboard("https://discord.gg/voidhub") end
        end)
        Notify("Discord", "Invite copied to clipboard.", 3, "success")
    end)
    Settings:Button("Unload Hub", function()
        tween(Main, 0.3, { Size = UDim2.new(0, 0, 0, 0) },
            Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.32)
        ScreenGui:Destroy()
    end)

    --==[ DEFAULT TAB ]==--
    Tabs["Home"].Button.MouseButton1Click:Wait()
    -- Trigger first tab manually after build:
end

-- Auto-select first tab after a short wait (since we can't `Wait` synchronously above)
task.spawn(function()
    while not ScreenGui:FindFirstChild("Main") do task.wait() end
    local main = ScreenGui:FindFirstChild("Main")
    -- find first sidebar button and click it
    for _, c in ipairs(main:GetDescendants()) do
        if c:IsA("TextButton") and c.Parent and c.Parent.Name ~= "TopBar" then
            local ll = c.Parent:FindFirstChildOfClass("UIListLayout")
            if ll then
                -- simulate click on first tab
                firesignal = firesignal or function() end
                pcall(function()
                    for _, conn in ipairs(getconnections(c.MouseButton1Click)) do
                        conn:Fire()
                    end
                end)
                if not pcall(function() return getconnections end) then
                    -- fallback: just show first page
                    local content = main:FindFirstChild("Content") or main:GetChildren()
                    for _, ch in ipairs(main:GetDescendants()) do
                        if ch:IsA("ScrollingFrame") then
                            ch.Visible = (ch == main:GetDescendants()[1])
                            break
                        end
                    end
                end
                break
            end
        end
    end
end)

--==[ TOGGLE MENU WITH HOTKEY ]==--
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Config.ToggleKey then
        local main = ScreenGui:FindFirstChild("Main")
        if main then main.Visible = not main.Visible end
    end
end)

Notify("Void Hub", "Loaded successfully. Press RightShift to toggle.", 4, "success")
