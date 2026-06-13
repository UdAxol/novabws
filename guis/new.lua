local boot = ...
local profile      = boot.profile or {}
local saveProfile  = boot.saveProfile or function() end
local downloadFile = boot.downloadFile or function() return "" end

local cloneref = cloneref or function(o) return o end
local Players          = cloneref(game:GetService("Players"))
local CoreGui          = cloneref(game:GetService("CoreGui"))
local TweenService     = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService       = cloneref(game:GetService("RunService"))
local Lighting         = cloneref(game:GetService("Lighting"))
local Stats            = cloneref(game:GetService("Stats"))
local lplr             = Players.LocalPlayer

local PALETTE = {
    BG_VOID      = Color3.fromRGB(8, 6, 14),
    BG_DEEP      = Color3.fromRGB(14, 11, 24),
    BG_PRIMARY   = Color3.fromRGB(20, 16, 34),
    BG_SECONDARY = Color3.fromRGB(28, 22, 46),
    BG_TERTIARY  = Color3.fromRGB(40, 32, 62),
    BG_RAISED    = Color3.fromRGB(52, 42, 80),
    ACCENT       = Color3.fromRGB(155, 110, 255),
    ACCENT_BRIGHT= Color3.fromRGB(180, 140, 255),
    ACCENT_2     = Color3.fromRGB(120, 80, 240),
    ACCENT_DIM   = Color3.fromRGB(90, 60, 180),
    ACCENT_GLOW  = Color3.fromRGB(190, 150, 255),
    TEXT_PRIMARY = Color3.fromRGB(240, 235, 250),
    TEXT_DIM     = Color3.fromRGB(170, 160, 195),
    TEXT_GHOST   = Color3.fromRGB(110, 100, 135),
    SUCCESS      = Color3.fromRGB(120, 230, 140),
    DANGER       = Color3.fromRGB(245, 100, 110),
    BORDER       = Color3.fromRGB(60, 48, 96),
    BORDER_SOFT  = Color3.fromRGB(40, 32, 64),
    SHADOW       = Color3.fromRGB(0, 0, 0),
}

local FONT = Enum.Font.Gotham
local FONT_MED = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold
local FONT_BLACK = Enum.Font.GothamBlack

local function new(class, props, children)
    local inst = Instance.new(class)
    if props then for k, v in pairs(props) do if k ~= "Parent" then inst[k] = v end end end
    if children then for _, c in ipairs(children) do c.Parent = inst end end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end
local function corner(parent, r) return new("UICorner", {Parent=parent, CornerRadius=UDim.new(0, r or 8)}) end
local function strokeOf(parent, color, t, trans)
    return new("UIStroke", {
        Parent=parent, Thickness=t or 1, Transparency=trans or 0,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Color=color or PALETTE.BORDER,
    })
end
local function pad(parent, t, r, b, l)
    return new("UIPadding", {
        Parent=parent,
        PaddingTop=UDim.new(0,t or 0), PaddingRight=UDim.new(0,r or 0),
        PaddingBottom=UDim.new(0,b or 0), PaddingLeft=UDim.new(0,l or 0),
    })
end
local function listLayout(parent, p, sortOrder)
    return new("UIListLayout", {
        Parent=parent, Padding=UDim.new(0, p or 4),
        SortOrder=sortOrder or Enum.SortOrder.LayoutOrder,
    })
end
local function tween(obj, time, props, style, dir)
    local ti = TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, ti, props); t:Play(); return t
end
local function dropShadow(parent, opacity, expand)
    expand = expand or 60
    return new("ImageLabel", {
        Parent=parent, BackgroundTransparency=1,
        Image="rbxassetid://6014261993", ImageColor3=PALETTE.SHADOW,
        ImageTransparency=opacity or 0.5, ScaleType=Enum.ScaleType.Slice,
        SliceCenter=Rect.new(49,49,450,450),
        Size=UDim2.new(1,expand,1,expand), Position=UDim2.new(0,-expand/2,0,-expand/2), ZIndex=-1,
    })
end
local function makeDraggable(handle, target)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
end

local CATEGORY_ICONS = {
    Combat    = "rbxassetid://10709810948",
    Blatant   = "rbxassetid://10723415903",
    Render    = "rbxassetid://10709769240",
    Utility   = "rbxassetid://10723345544",
    World     = "rbxassetid://10723408988",
    Inventory = "rbxassetid://10723417149",
    Minigames = "rbxassetid://10723405292",
    Kits      = "rbxassetid://10747384394",
}

local screenGui = new("ScreenGui", {
    Name="NovaV2", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    DisplayOrder=999, IgnoreGuiInset=true,
})
local parented = false
pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(screenGui) end
    if (protectgui or PROTECT_GUI) then (protectgui or PROTECT_GUI)(screenGui) end
    screenGui.Parent = CoreGui; parented = true
end)
if not parented then screenGui.Parent = lplr:WaitForChild("PlayerGui") end

local blur = new("BlurEffect", {Parent=Lighting, Size=0, Enabled=true})

local WINDOW_W, WINDOW_H = 920, 580
local mainFrame = new("Frame", {
    Name="Main", Parent=screenGui,
    Size=UDim2.fromOffset(WINDOW_W, WINDOW_H),
    Position=UDim2.new(0.5, -WINDOW_W/2, 0.5, -WINDOW_H/2),
    BackgroundColor3=PALETTE.BG_PRIMARY, BorderSizePixel=0, Visible=false,
})
corner(mainFrame, 14)
strokeOf(mainFrame, PALETTE.BORDER, 1, 0.3)
dropShadow(mainFrame, 0.55, 80)
new("UIGradient", {
    Parent=mainFrame, Rotation=135,
    Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0, PALETTE.BG_PRIMARY),
        ColorSequenceKeypoint.new(0.5, PALETTE.BG_DEEP),
        ColorSequenceKeypoint.new(1, PALETTE.BG_VOID),
    }),
})
local scaler = new("UIScale", {Parent=mainFrame, Scale=1})

local TOPBAR_H = 76
local topBar = new("Frame", {
    Parent=mainFrame, Size=UDim2.new(1,0,0,TOPBAR_H),
    BackgroundColor3=PALETTE.BG_SECONDARY, BorderSizePixel=0,
})
corner(topBar, 14)
new("Frame", {
    Parent=topBar, Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,1,-14),
    BackgroundColor3=PALETTE.BG_SECONDARY, BorderSizePixel=0,
})
new("UIGradient", {
    Parent=topBar, Rotation=180,
    Color=ColorSequence.new(PALETTE.BG_SECONDARY, PALETTE.BG_PRIMARY),
})
local accentStrip = new("Frame", {
    Parent=topBar, Size=UDim2.new(1,0,0,2), BorderSizePixel=0,
    BackgroundColor3=PALETTE.ACCENT,
})
new("UIGradient", {
    Parent=accentStrip, Rotation=0,
    Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0, PALETTE.ACCENT_2),
        ColorSequenceKeypoint.new(0.5, PALETTE.ACCENT_BRIGHT),
        ColorSequenceKeypoint.new(1, PALETTE.ACCENT_2),
    }),
})

local logoArea = new("Frame", {
    Parent=topBar, Size=UDim2.fromOffset(240, TOPBAR_H),
    Position=UDim2.new(0,0,0,0), BackgroundTransparency=1,
})
local logoText = new("TextLabel", {
    Parent=logoArea, Size=UDim2.new(0,200,0,38),
    Position=UDim2.new(0,24,0,16), BackgroundTransparency=1,
    Font=FONT_BLACK, TextSize=30,
    TextColor3=PALETTE.TEXT_PRIMARY,
    TextXAlignment=Enum.TextXAlignment.Left,
    TextYAlignment=Enum.TextYAlignment.Top, Text="NOVA",
})
new("UIGradient", {
    Parent=logoText, Rotation=90,
    Color=ColorSequence.new(PALETTE.TEXT_PRIMARY, PALETTE.ACCENT_BRIGHT),
})
new("TextLabel", {
    Parent=logoArea, Size=UDim2.new(0,200,0,16),
    Position=UDim2.new(0,26,0,48), BackgroundTransparency=1,
    Font=FONT_MED, TextSize=10,
    TextColor3=PALETTE.TEXT_GHOST,
    TextXAlignment=Enum.TextXAlignment.Left, Text="ROBLOX CLIENT • v2.0",
})

local statsArea = new("Frame", {
    Parent=topBar, Size=UDim2.fromOffset(360, TOPBAR_H),
    Position=UDim2.new(0.5,-180,0,0), BackgroundTransparency=1,
})
local function makeStatCard(parent, xOff, label, getValue)
    local card = new("Frame", {
        Parent=parent, Size=UDim2.fromOffset(108, 50),
        Position=UDim2.new(0,xOff,0.5,-25),
        BackgroundColor3=PALETTE.BG_TERTIARY, BorderSizePixel=0,
    })
    corner(card, 8)
    new("UIGradient", {
        Parent=card, Rotation=90,
        Color=ColorSequence.new(PALETTE.BG_TERTIARY, PALETTE.BG_SECONDARY),
    })
    strokeOf(card, PALETTE.BORDER_SOFT, 1, 0.4)
    local accent = new("Frame", {
        Parent=card, Size=UDim2.new(0,3,1,-14),
        Position=UDim2.new(0,6,0,7), BorderSizePixel=0,
        BackgroundColor3=PALETTE.ACCENT,
    })
    corner(accent, 2)
    new("TextLabel", {
        Parent=card, Size=UDim2.new(1,-20,0,12),
        Position=UDim2.new(0,14,0,8), BackgroundTransparency=1,
        Font=FONT, TextSize=9, TextColor3=PALETTE.TEXT_GHOST,
        TextXAlignment=Enum.TextXAlignment.Left, Text=label:upper(),
    })
    local val = new("TextLabel", {
        Parent=card, Size=UDim2.new(1,-20,0,22),
        Position=UDim2.new(0,14,0,24), BackgroundTransparency=1,
        Font=FONT_BOLD, TextSize=18, TextColor3=PALETTE.TEXT_PRIMARY,
        TextXAlignment=Enum.TextXAlignment.Left, Text="--",
    })
    task.spawn(function()
        while card.Parent do
            val.Text = tostring(getValue() or "--")
            task.wait(1)
        end
    end)
    return card
end

local fpsCount, fpsAcc = 0, 0
RunService.RenderStepped:Connect(function() fpsAcc = fpsAcc + 1 end)
task.spawn(function()
    while true do
        task.wait(1)
        fpsCount = fpsAcc; fpsAcc = 0
    end
end)

local mainapi
makeStatCard(statsArea, 0, "FPS", function() return fpsCount end)
makeStatCard(statsArea, 122, "PING", function()
    local ok, ms = pcall(function()
        return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    if ok then return ms .. "ms" end
    return "--"
end)
makeStatCard(statsArea, 244, "MODULES", function()
    if not mainapi then return 0 end
    local n = 0
    for _, m in pairs(mainapi.Modules) do if m.Enabled then n = n + 1 end end
    return n
end)

local profileArea = new("Frame", {
    Parent=topBar, Size=UDim2.fromOffset(260, TOPBAR_H),
    Position=UDim2.new(1,-260,0,0), BackgroundTransparency=1,
})
local avatarFrame = new("Frame", {
    Parent=profileArea, Size=UDim2.fromOffset(44,44),
    Position=UDim2.new(1,-58,0.5,-22),
    BackgroundColor3=PALETTE.BG_TERTIARY, BorderSizePixel=0,
})
corner(avatarFrame, 22)
strokeOf(avatarFrame, PALETTE.ACCENT, 2, 0)
local avatarImg = new("ImageLabel", {
    Parent=avatarFrame, Size=UDim2.new(1,-4,1,-4),
    Position=UDim2.new(0,2,0,2), BackgroundTransparency=1,
    Image="rbxthumb://type=AvatarHeadShot&id=" .. tostring(lplr.UserId) .. "&w=150&h=150",
})
corner(avatarImg, 20)
local statusDot = new("Frame", {
    Parent=avatarFrame, Size=UDim2.fromOffset(12,12),
    Position=UDim2.new(1,-12,1,-12),
    BackgroundColor3=PALETTE.SUCCESS, BorderSizePixel=0,
})
corner(statusDot, 6)
strokeOf(statusDot, PALETTE.BG_SECONDARY, 2, 0)

local nameLabel = new("TextLabel", {
    Parent=profileArea, Size=UDim2.new(0,180,0,18),
    Position=UDim2.new(1,-242,0,18), BackgroundTransparency=1,
    Font=FONT_BOLD, TextSize=14, TextColor3=PALETTE.TEXT_PRIMARY,
    TextXAlignment=Enum.TextXAlignment.Right, Text=lplr.DisplayName or lplr.Name,
})
local handleLabel = new("TextLabel", {
    Parent=profileArea, Size=UDim2.new(0,180,0,14),
    Position=UDim2.new(1,-242,0,36), BackgroundTransparency=1,
    Font=FONT, TextSize=11, TextColor3=PALETTE.TEXT_DIM,
    TextXAlignment=Enum.TextXAlignment.Right, Text="@" .. lplr.Name,
})
local subInfo = new("TextLabel", {
    Parent=profileArea, Size=UDim2.new(0,180,0,12),
    Position=UDim2.new(1,-242,0,52), BackgroundTransparency=1,
    Font=FONT, TextSize=10, TextColor3=PALETTE.TEXT_GHOST,
    TextXAlignment=Enum.TextXAlignment.Right,
    Text=string.format("%d days  •  ID: %s", lplr.AccountAge or 0, tostring(lplr.UserId)),
})

makeDraggable(topBar, mainFrame)

local SIDEBAR_W = 200
local sidebar = new("Frame", {
    Parent=mainFrame, Size=UDim2.new(0,SIDEBAR_W,1,-TOPBAR_H),
    Position=UDim2.new(0,0,0,TOPBAR_H),
    BackgroundColor3=PALETTE.BG_DEEP, BorderSizePixel=0,
})
new("UIGradient", {
    Parent=sidebar, Rotation=90,
    Color=ColorSequence.new(PALETTE.BG_DEEP, PALETTE.BG_VOID),
})
local sidebarBorder = new("Frame", {
    Parent=sidebar, Size=UDim2.new(0,1,1,0),
    Position=UDim2.new(1,-1,0,0), BorderSizePixel=0,
    BackgroundColor3=PALETTE.BORDER_SOFT,
})

new("TextLabel", {
    Parent=sidebar, Size=UDim2.new(1,-32,0,14),
    Position=UDim2.new(0,16,0,16), BackgroundTransparency=1,
    Font=FONT, TextSize=10, TextColor3=PALETTE.TEXT_GHOST,
    TextXAlignment=Enum.TextXAlignment.Left, Text="CATEGORIES",
})

local catList = new("ScrollingFrame", {
    Parent=sidebar, Size=UDim2.new(1,0,1,-44),
    Position=UDim2.new(0,0,0,40),
    BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=0,
    AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new(0,0,0,0),
})
listLayout(catList, 6)
pad(catList, 4, 12, 12, 12)

local PANEL_W = 280
local mainContent = new("Frame", {
    Parent=mainFrame, Size=UDim2.new(1,-SIDEBAR_W-PANEL_W,1,-TOPBAR_H),
    Position=UDim2.new(0,SIDEBAR_W,0,TOPBAR_H), BackgroundTransparency=1,
})

local contentHeader = new("Frame", {
    Parent=mainContent, Size=UDim2.new(1,0,0,68),
    BackgroundTransparency=1,
})
local pageTitle = new("TextLabel", {
    Parent=contentHeader, Size=UDim2.new(0,400,0,28),
    Position=UDim2.new(0,24,0,18), BackgroundTransparency=1,
    Font=FONT_BOLD, TextSize=22, TextColor3=PALETTE.TEXT_PRIMARY,
    TextXAlignment=Enum.TextXAlignment.Left, Text="Combat",
})
local pageSubtitle = new("TextLabel", {
    Parent=contentHeader, Size=UDim2.new(0,400,0,16),
    Position=UDim2.new(0,24,0,44), BackgroundTransparency=1,
    Font=FONT, TextSize=12, TextColor3=PALETTE.TEXT_GHOST,
    TextXAlignment=Enum.TextXAlignment.Left, Text="0 modules • 0 active",
})

local searchBg = new("Frame", {
    Parent=contentHeader, Size=UDim2.fromOffset(200,32),
    Position=UDim2.new(1,-220,0,18),
    BackgroundColor3=PALETTE.BG_SECONDARY, BorderSizePixel=0,
})
corner(searchBg, 8)
strokeOf(searchBg, PALETTE.BORDER_SOFT, 1, 0)
new("ImageLabel", {
    Parent=searchBg, Size=UDim2.fromOffset(14,14),
    Position=UDim2.new(0,10,0.5,-7), BackgroundTransparency=1,
    Image="rbxassetid://10734898355", ImageColor3=PALETTE.TEXT_GHOST,
})
local searchBox = new("TextBox", {
    Parent=searchBg, Size=UDim2.new(1,-34,1,0),
    Position=UDim2.new(0,30,0,0), BackgroundTransparency=1,
    Font=FONT, TextSize=12, TextColor3=PALETTE.TEXT_PRIMARY,
    PlaceholderColor3=PALETTE.TEXT_GHOST, PlaceholderText="Search...",
    Text="", TextXAlignment=Enum.TextXAlignment.Left, ClearTextOnFocus=false,
})

local moduleList = new("ScrollingFrame", {
    Parent=mainContent, Size=UDim2.new(1,0,1,-68),
    Position=UDim2.new(0,0,0,68),
    BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4,
    ScrollBarImageColor3=PALETTE.ACCENT, ScrollBarImageTransparency=0.3,
    AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new(0,0,0,0),
})
listLayout(moduleList, 8)
pad(moduleList, 4, 24, 24, 24)

local emptyState = new("Frame", {
    Parent=mainContent, Size=UDim2.new(1,-40,0,140),
    Position=UDim2.new(0,20,0,140), BackgroundTransparency=1, Visible=false,
})
new("ImageLabel", {
    Parent=emptyState, Size=UDim2.fromOffset(60,60),
    Position=UDim2.new(0.5,-30,0,0), BackgroundTransparency=1,
    Image="rbxassetid://10723345544",
    ImageColor3=PALETTE.TEXT_GHOST, ImageTransparency=0.5,
})
new("TextLabel", {
    Parent=emptyState, Size=UDim2.new(1,0,0,18),
    Position=UDim2.new(0,0,0,72), BackgroundTransparency=1,
    Font=FONT_BOLD, TextSize=14, TextColor3=PALETTE.TEXT_DIM,
    Text="Nothing here yet",
})
new("TextLabel", {
    Parent=emptyState, Size=UDim2.new(1,0,0,16),
    Position=UDim2.new(0,0,0,94), BackgroundTransparency=1,
    Font=FONT, TextSize=11, TextColor3=PALETTE.TEXT_GHOST,
    Text="More modules coming in v0.5+",
})

local rightPanel = new("Frame", {
    Parent=mainFrame, Size=UDim2.new(0,PANEL_W,1,-TOPBAR_H),
    Position=UDim2.new(1,-PANEL_W,0,TOPBAR_H),
    BackgroundColor3=PALETTE.BG_DEEP, BorderSizePixel=0,
})
new("UIGradient", {
    Parent=rightPanel, Rotation=90,
    Color=ColorSequence.new(PALETTE.BG_DEEP, PALETTE.BG_VOID),
})
new("Frame", {
    Parent=rightPanel, Size=UDim2.new(0,1,1,0), BorderSizePixel=0,
    BackgroundColor3=PALETTE.BORDER_SOFT,
})

local panelHeader = new("Frame", {
    Parent=rightPanel, Size=UDim2.new(1,0,0,52), BackgroundTransparency=1,
})
new("TextLabel", {
    Parent=panelHeader, Size=UDim2.new(1,-32,0,14),
    Position=UDim2.new(0,20,0,18), BackgroundTransparency=1,
    Font=FONT, TextSize=10, TextColor3=PALETTE.TEXT_GHOST,
    TextXAlignment=Enum.TextXAlignment.Left, Text="MODULE DETAILS",
})
local panelModuleName = new("TextLabel", {
    Parent=panelHeader, Size=UDim2.new(1,-32,0,20),
    Position=UDim2.new(0,20,0,34), BackgroundTransparency=1,
    Font=FONT_BOLD, TextSize=14, TextColor3=PALETTE.TEXT_PRIMARY,
    TextXAlignment=Enum.TextXAlignment.Left, Text="Select a module",
})

local panelBody = new("ScrollingFrame", {
    Parent=rightPanel, Size=UDim2.new(1,0,1,-52),
    Position=UDim2.new(0,0,0,52),
    BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=3,
    ScrollBarImageColor3=PALETTE.ACCENT, ScrollBarImageTransparency=0.4,
    AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new(0,0,0,0),
})
listLayout(panelBody, 4)
pad(panelBody, 4, 20, 20, 20)

local panelEmpty = new("TextLabel", {
    Parent=rightPanel, Size=UDim2.new(1,-40,0,32),
    Position=UDim2.new(0,20,0,90), BackgroundTransparency=1,
    Font=FONT, TextSize=11, TextColor3=PALETTE.TEXT_GHOST,
    TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left,
    Text="Click a module's settings icon to view its options here.",
})

local notifStack = new("Frame", {
    Parent=screenGui, Size=UDim2.new(0,340,1,-40),
    Position=UDim2.new(1,-360,0,20), BackgroundTransparency=1,
})
local notifLayout = listLayout(notifStack, 8)
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right

local function createNotification(title, content, duration)
    duration = duration or 4
    local f = new("Frame", {
        Parent=notifStack, Size=UDim2.new(1,0,0,62),
        BackgroundColor3=PALETTE.BG_PRIMARY, BorderSizePixel=0,
        BackgroundTransparency=1,
    })
    corner(f, 10)
    strokeOf(f, PALETTE.BORDER, 1, 0.3)
    new("UIGradient", {
        Parent=f, Rotation=135,
        Color=ColorSequence.new(PALETTE.BG_PRIMARY, PALETTE.BG_DEEP),
    })
    local strip = new("Frame", {
        Parent=f, Size=UDim2.new(0,4,1,-20),
        Position=UDim2.new(0,8,0,10),
        BackgroundColor3=PALETTE.ACCENT, BorderSizePixel=0,
    })
    corner(strip, 2)
    new("TextLabel", {
        Parent=f, Size=UDim2.new(1,-28,0,18),
        Position=UDim2.new(0,22,0,10), BackgroundTransparency=1,
        Font=FONT_BOLD, TextSize=13, TextColor3=PALETTE.TEXT_PRIMARY,
        TextXAlignment=Enum.TextXAlignment.Left, Text=tostring(title),
    })
    new("TextLabel", {
        Parent=f, Size=UDim2.new(1,-28,1,-32),
        Position=UDim2.new(0,22,0,28), BackgroundTransparency=1,
        Font=FONT, TextSize=11, TextColor3=PALETTE.TEXT_DIM,
        TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
        TextWrapped=true, Text=tostring(content),
    })
    f.Position = UDim2.new(1,60,0,0)
    tween(f, 0.3, {BackgroundTransparency=0, Position=UDim2.new(0,0,0,0)})
    task.delay(duration, function()
        if f.Parent then
            tween(f, 0.25, {BackgroundTransparency=1, Position=UDim2.new(1,60,0,0)})
            task.wait(0.3); f:Destroy()
        end
    end)
    return f
end

local categories = {}
local currentCategoryName
local focusedModule

local function updatePageHeader()
    if not currentCategoryName then return end
    pageTitle.Text = currentCategoryName
    local cat
    for _, c in ipairs(categories) do if c.Name == currentCategoryName then cat = c; break end end
    if not cat then return end
    local total = #(cat.ModuleOrder or {})
    local active = 0
    for _, m in ipairs(cat.ModuleOrder or {}) do if m.Enabled then active = active + 1 end end
    pageSubtitle.Text = string.format("%d module%s • %d active", total, total == 1 and "" or "s", active)
    emptyState.Visible = (total == 0)
end

local function refreshModuleList()
    for _, child in ipairs(moduleList:GetChildren()) do
        if child:IsA("Frame") then child.Visible = false end
    end
    if not currentCategoryName then updatePageHeader(); return end
    local cat
    for _, c in ipairs(categories) do if c.Name == currentCategoryName then cat = c; break end end
    if not cat then updatePageHeader(); return end
    local q = (searchBox.Text or ""):lower()
    for _, mod in ipairs(cat.ModuleOrder or {}) do
        if mod.Frame then
            mod.Frame.Visible = (q == "") or string.find(mod.Name:lower(), q, 1, true) ~= nil
        end
    end
    updatePageHeader()
end

searchBox:GetPropertyChangedSignal("Text"):Connect(refreshModuleList)

local function selectCategory(name)
    currentCategoryName = name
    for _, c in ipairs(categories) do
        if c.Row then
            local selected = (c.Name == name)
            tween(c.Row, 0.18, {BackgroundTransparency = selected and 0 or 1})
            tween(c.Text, 0.15, {TextColor3 = selected and PALETTE.TEXT_PRIMARY or PALETTE.TEXT_DIM})
            tween(c.IconImg, 0.15, {ImageColor3 = selected and PALETTE.ACCENT_BRIGHT or PALETTE.TEXT_DIM})
            tween(c.Indicator, 0.2, {Size = selected and UDim2.new(0,3,0,28) or UDim2.new(0,3,0,0)})
        end
    end
    refreshModuleList()
end

local function focusModule(mod)
    focusedModule = mod
    for _, c in ipairs(panelBody:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
    end
    if not mod then
        panelModuleName.Text = "Select a module"
        panelEmpty.Visible = true
        return
    end
    panelModuleName.Text = mod.Name
    panelEmpty.Visible = false
    if mod.Tooltip then
        local tt = new("TextLabel", {
            Parent=panelBody, Size=UDim2.new(1,0,0,32),
            BackgroundTransparency=1, Font=FONT, TextSize=11,
            TextColor3=PALETTE.TEXT_GHOST, TextWrapped=true,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextYAlignment=Enum.TextYAlignment.Top, Text=mod.Tooltip,
        })
    end
    if mod._OptionContainer then
        mod._OptionContainer.Parent = panelBody
        mod._OptionContainer.Visible = true
        mod._OptionContainer.Size = UDim2.new(1,0,0,0)
    end
end

local function makeToggleVisual(moduleApi, optSettings)
    local row = new("Frame", {
        Parent=moduleApi._OptionContainer, Size=UDim2.new(1,0,0,34), BackgroundTransparency=1,
    })
    local label = new("TextLabel", {
        Parent=row, Size=UDim2.new(1,-50,1,0), BackgroundTransparency=1,
        Font=FONT_MED, TextSize=12, TextColor3=PALETTE.TEXT_DIM,
        TextXAlignment=Enum.TextXAlignment.Left, Text=tostring(optSettings.Name),
    })
    local pill = new("Frame", {
        Parent=row, Size=UDim2.fromOffset(38,20),
        Position=UDim2.new(1,-42,0.5,-10),
        BackgroundColor3=PALETTE.BG_TERTIARY, BorderSizePixel=0,
    })
    corner(pill, 10)
    strokeOf(pill, PALETTE.BORDER_SOFT, 1, 0.5)
    local dot = new("Frame", {
        Parent=pill, Size=UDim2.fromOffset(14,14),
        Position=UDim2.new(0,3,0.5,-7),
        BackgroundColor3=PALETTE.TEXT_DIM, BorderSizePixel=0,
    })
    corner(dot, 7)
    local glow = new("ImageLabel", {
        Parent=pill, BackgroundTransparency=1, ZIndex=0,
        Image="rbxassetid://6014261993", ScaleType=Enum.ScaleType.Slice,
        SliceCenter=Rect.new(49,49,450,450),
        Size=UDim2.new(1,40,1,40), Position=UDim2.new(0,-20,0,-20),
        ImageColor3=PALETTE.ACCENT_GLOW, ImageTransparency=1,
    })
    local optApi = {
        Type="Toggle", Name=optSettings.Name,
        Enabled=optSettings.Default==true,
        Function=optSettings.Function or function() end,
    }
    local function render(animate)
        local on = optApi.Enabled
        local pillCol = on and PALETTE.ACCENT or PALETTE.BG_TERTIARY
        local dotCol = on and PALETTE.TEXT_PRIMARY or PALETTE.TEXT_DIM
        local dotPos = on and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
        local glowT = on and 0.4 or 1
        if animate then
            tween(pill, 0.18, {BackgroundColor3=pillCol})
            tween(dot, 0.22, {BackgroundColor3=dotCol, Position=dotPos}, Enum.EasingStyle.Back)
            tween(glow, 0.25, {ImageTransparency=glowT})
        else
            pill.BackgroundColor3=pillCol; dot.BackgroundColor3=dotCol
            dot.Position=dotPos; glow.ImageTransparency=glowT
        end
    end
    optApi.SetEnabled = function(_, v) optApi.Enabled=v and true or false; render(true); pcall(optApi.Function, optApi.Enabled) end
    optApi.Refresh = function() render(false) end
    local btn = new("TextButton", {Parent=row, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text=""})
    btn.Activated:Connect(function() optApi:SetEnabled(not optApi.Enabled) end)
    render(false)
    return optApi
end

local function makeSliderVisual(moduleApi, optSettings)
    local row = new("Frame", {
        Parent=moduleApi._OptionContainer, Size=UDim2.new(1,0,0,48), BackgroundTransparency=1,
    })
    local label = new("TextLabel", {
        Parent=row, Size=UDim2.new(1,-80,0,18),
        Position=UDim2.new(0,0,0,2), BackgroundTransparency=1,
        Font=FONT_MED, TextSize=12, TextColor3=PALETTE.TEXT_DIM,
        TextXAlignment=Enum.TextXAlignment.Left, Text=tostring(optSettings.Name),
    })
    local valueLabel = new("TextLabel", {
        Parent=row, Size=UDim2.fromOffset(80,18),
        Position=UDim2.new(1,-80,0,2), BackgroundTransparency=1,
        Font=FONT_BOLD, TextSize=12, TextColor3=PALETTE.ACCENT_BRIGHT,
        TextXAlignment=Enum.TextXAlignment.Right, Text="",
    })
    local track = new("Frame", {
        Parent=row, Size=UDim2.new(1,0,0,6),
        Position=UDim2.new(0,0,0,28),
        BackgroundColor3=PALETTE.BG_TERTIARY, BorderSizePixel=0,
    })
    corner(track, 3)
    local fill = new("Frame", {
        Parent=track, Size=UDim2.new(0,0,1,0),
        BorderSizePixel=0, BackgroundColor3=PALETTE.ACCENT,
    })
    corner(fill, 3)
    new("UIGradient", {
        Parent=fill, Rotation=0,
        Color=ColorSequence.new(PALETTE.ACCENT, PALETTE.ACCENT_BRIGHT),
    })
    local knob = new("Frame", {
        Parent=track, Size=UDim2.fromOffset(16,16),
        Position=UDim2.new(0,-8,0.5,-8),
        BackgroundColor3=PALETTE.ACCENT_BRIGHT, BorderSizePixel=0,
    })
    corner(knob, 8)
    strokeOf(knob, PALETTE.TEXT_PRIMARY, 2, 0)
    local min = optSettings.Min or 0
    local max = optSettings.Max or 100
    local decimals = optSettings.Decimal or 0
    local suffix = optSettings.Suffix
    local optApi = {
        Type="Slider", Name=optSettings.Name,
        Min=min, Max=max, Value=optSettings.Default or min,
        Function=optSettings.Function or function() end,
    }
    local function formatVal(v)
        local rounded
        if decimals <= 0 then rounded = math.floor(v + 0.5)
        else local p = 10^decimals; rounded = math.floor(v*p + 0.5)/p end
        local sfx = ""
        if type(suffix) == "function" then sfx = " " .. tostring(suffix(rounded) or "")
        elseif type(suffix) == "string" then sfx = " " .. suffix end
        return tostring(rounded) .. sfx, rounded
    end
    local function render()
        local pct = math.clamp((optApi.Value - min) / (max - min), 0, 1)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -8, 0.5, -8)
        valueLabel.Text = formatVal(optApi.Value)
    end
    optApi.SetValue = function(_, v)
        v = math.clamp(v, min, max)
        local _, rounded = formatVal(v)
        optApi.Value = rounded or v
        render(); pcall(optApi.Function, optApi.Value)
    end
    optApi.Refresh = render
    local trackBtn = new("TextButton", {
        Parent=track, Size=UDim2.new(1,0,3,0),
        Position=UDim2.new(0,0,-1,0), BackgroundTransparency=1, Text="",
    })
    local dragging = false
    local function setFromX(mouseX)
        local abs = track.AbsolutePosition.X
        local w = track.AbsoluteSize.X
        local pct = math.clamp((mouseX - abs) / w, 0, 1)
        optApi:SetValue(min + (max - min) * pct)
    end
    trackBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; setFromX(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    optApi:SetValue(optApi.Value)
    return optApi
end

local function makeDropdownVisual(moduleApi, optSettings)
    local row = new("Frame", {
        Parent=moduleApi._OptionContainer, Size=UDim2.new(1,0,0,34), BackgroundTransparency=1,
    })
    new("TextLabel", {
        Parent=row, Size=UDim2.new(0.45,-4,1,0), BackgroundTransparency=1,
        Font=FONT_MED, TextSize=12, TextColor3=PALETTE.TEXT_DIM,
        TextXAlignment=Enum.TextXAlignment.Left, Text=tostring(optSettings.Name),
    })
    local selector = new("TextButton", {
        Parent=row, Size=UDim2.new(0.55,-4,0,28),
        Position=UDim2.new(0.45,4,0.5,-14), AutoButtonColor=false,
        BackgroundColor3=PALETTE.BG_TERTIARY, BorderSizePixel=0,
        Font=FONT_MED, TextSize=11, TextColor3=PALETTE.TEXT_PRIMARY,
        TextXAlignment=Enum.TextXAlignment.Left, Text="",
    })
    corner(selector, 6)
    pad(selector, 0, 22, 0, 10)
    strokeOf(selector, PALETTE.BORDER_SOFT, 1, 0.4)
    new("TextLabel", {
        Parent=selector, Size=UDim2.fromOffset(14,14),
        Position=UDim2.new(1,-16,0.5,-7), BackgroundTransparency=1,
        Font=FONT_BOLD, TextSize=10, TextColor3=PALETTE.TEXT_DIM, Text="▾",
    })
    local list = optSettings.List or {}
    local optApi = {
        Type="Dropdown", Name=optSettings.Name,
        Value=optSettings.Default or list[1] or "", List=list,
        Function=optSettings.Function or function() end,
    }
    local dd = new("Frame", {
        Parent=rightPanel, Size=UDim2.fromOffset(0,0),
        BackgroundColor3=PALETTE.BG_TERTIARY, BorderSizePixel=0,
        Visible=false, ZIndex=20,
    })
    corner(dd, 6)
    strokeOf(dd, PALETTE.BORDER, 1, 0)
    local ddList = new("ScrollingFrame", {
        Parent=dd, Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=2,
        ScrollBarImageColor3=PALETTE.ACCENT,
        AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new(0,0,0,0),
        ZIndex=21,
    })
    listLayout(ddList, 2)
    pad(ddList, 4, 4, 4, 4)
    local function refreshList()
        for _, c in ipairs(ddList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for _, item in ipairs(optApi.List) do
            local b = new("TextButton", {
                Parent=ddList, Size=UDim2.new(1,0,0,24),
                AutoButtonColor=false, BorderSizePixel=0,
                BackgroundColor3 = item == optApi.Value and PALETTE.ACCENT_DIM or PALETTE.BG_TERTIARY,
                Font=FONT, TextSize=11,
                TextColor3 = item == optApi.Value and PALETTE.TEXT_PRIMARY or PALETTE.TEXT_DIM,
                TextXAlignment=Enum.TextXAlignment.Left, Text=tostring(item),
                ZIndex=22,
            })
            corner(b, 4)
            pad(b, 0, 8, 0, 10)
            b.Activated:Connect(function()
                optApi.Value = item; selector.Text = tostring(item)
                dd.Visible = false; refreshList()
                pcall(optApi.Function, optApi.Value)
            end)
        end
    end
    optApi.SetValue = function(_, v) optApi.Value = v; selector.Text = tostring(v); refreshList(); pcall(optApi.Function, optApi.Value) end
    optApi.SetList = function(_, l) optApi.List = l; refreshList() end
    optApi.Refresh = function() selector.Text = tostring(optApi.Value); refreshList() end
    selector.Text = tostring(optApi.Value)
    selector.Activated:Connect(function()
        if dd.Visible then dd.Visible = false; return end
        local abs = selector.AbsolutePosition; local sz = selector.AbsoluteSize
        local mp = mainFrame.AbsolutePosition
        local items = math.min(#optApi.List, 6)
        dd.Size = UDim2.fromOffset(sz.X, math.max(items * 26 + 8, 30))
        dd.Position = UDim2.fromOffset(abs.X - mp.X, abs.Y - mp.Y + sz.Y + 4)
        dd.Visible = true; refreshList()
    end)
    UserInputService.InputBegan:Connect(function(input)
        if dd.Visible and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            local mp = UserInputService:GetMouseLocation()
            local da = dd.AbsolutePosition; local ds = dd.AbsoluteSize
            local sa = selector.AbsolutePosition; local ss = selector.AbsoluteSize
            local inDD = mp.X >= da.X and mp.X <= da.X+ds.X and mp.Y >= da.Y and mp.Y <= da.Y+ds.Y
            local inSec = mp.X >= sa.X and mp.X <= sa.X+ss.X and mp.Y >= sa.Y and mp.Y <= sa.Y+ss.Y
            if not inDD and not inSec then dd.Visible = false end
        end
    end)
    refreshList()
    return optApi
end

local function makeColorSliderVisual(moduleApi, optSettings)
    local row = new("Frame", {
        Parent=moduleApi._OptionContainer, Size=UDim2.new(1,0,0,34), BackgroundTransparency=1,
    })
    new("TextLabel", {
        Parent=row, Size=UDim2.new(1,-48,1,0), BackgroundTransparency=1,
        Font=FONT_MED, TextSize=12, TextColor3=PALETTE.TEXT_DIM,
        TextXAlignment=Enum.TextXAlignment.Left, Text=tostring(optSettings.Name),
    })
    local swatch = new("TextButton", {
        Parent=row, Size=UDim2.fromOffset(40,22),
        Position=UDim2.new(1,-44,0.5,-11), AutoButtonColor=false,
        BorderSizePixel=0, Text="",
    })
    corner(swatch, 5)
    strokeOf(swatch, PALETTE.BORDER_SOFT, 1, 0)
    local optApi = {
        Type="ColorSlider", Name=optSettings.Name,
        Hue=optSettings.DefaultHue or 0, Sat=optSettings.DefaultSat or 1,
        Value=optSettings.DefaultValue or 1, Opacity=optSettings.DefaultOpacity or 1,
        Function=optSettings.Function or function() end,
    }
    local picker = new("Frame", {
        Parent=rightPanel, Size=UDim2.fromOffset(240,200),
        BackgroundColor3=PALETTE.BG_TERTIARY, BorderSizePixel=0,
        Visible=false, ZIndex=20,
    })
    corner(picker, 8)
    strokeOf(picker, PALETTE.BORDER, 1, 0)
    pad(picker, 10, 10, 10, 10)
    local svBox = new("ImageButton", {
        Parent=picker, Size=UDim2.new(1,-26,0,150),
        AutoButtonColor=false, BackgroundColor3=Color3.new(1,0,0),
        BorderSizePixel=0, ZIndex=21, Image="",
    })
    corner(svBox, 4)
    new("UIGradient", {
        Parent=svBox, Rotation=0,
        Color=ColorSequence.new(Color3.new(1,1,1), Color3.new(1,0,0)),
    })
    local svDark = new("Frame", {
        Parent=svBox, Size=UDim2.new(1,0,1,0),
        BorderSizePixel=0, BackgroundColor3=Color3.new(0,0,0), ZIndex=22,
    })
    new("UIGradient", {
        Parent=svDark, Rotation=90,
        Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0),
        }),
    })
    local svCursor = new("Frame", {
        Parent=svBox, Size=UDim2.fromOffset(10,10),
        BackgroundTransparency=1, BorderSizePixel=0, ZIndex=23,
    })
    new("UIStroke", {Parent=svCursor, Color=Color3.new(1,1,1), Thickness=2})
    corner(svCursor, 5)
    local hueBar = new("ImageButton", {
        Parent=picker, Size=UDim2.fromOffset(18,150),
        Position=UDim2.new(1,-18,0,0), AutoButtonColor=false,
        BorderSizePixel=0, BackgroundColor3=Color3.new(1,1,1), Image="", ZIndex=21,
    })
    corner(hueBar, 4)
    new("UIGradient", {
        Parent=hueBar, Rotation=90,
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0/6, Color3.new(1,0,0)),
            ColorSequenceKeypoint.new(1/6, Color3.new(1,1,0)),
            ColorSequenceKeypoint.new(2/6, Color3.new(0,1,0)),
            ColorSequenceKeypoint.new(3/6, Color3.new(0,1,1)),
            ColorSequenceKeypoint.new(4/6, Color3.new(0,0,1)),
            ColorSequenceKeypoint.new(5/6, Color3.new(1,0,1)),
            ColorSequenceKeypoint.new(6/6, Color3.new(1,0,0)),
        }),
    })
    local hueCursor = new("Frame", {
        Parent=hueBar, Size=UDim2.new(1,4,0,4),
        Position=UDim2.new(0,-2,0,0),
        BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0, ZIndex=22,
    })
    local function render()
        local h, s, v = optApi.Hue, optApi.Sat, optApi.Value
        svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        swatch.BackgroundColor3 = Color3.fromHSV(h, s, v)
        svCursor.Position = UDim2.new(s, -5, 1-v, -5)
        hueCursor.Position = UDim2.new(0, -2, h, -2)
    end
    optApi.SetHSV = function(_, h, s, v, o)
        optApi.Hue = h or optApi.Hue; optApi.Sat = s or optApi.Sat
        optApi.Value = v or optApi.Value
        if o ~= nil then optApi.Opacity = o end
        render(); pcall(optApi.Function, optApi.Hue, optApi.Sat, optApi.Value, optApi.Opacity)
    end
    optApi.Refresh = render
    local svDrag, hueDrag = false, false
    svBox.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then svDrag = true end end)
    hueBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then hueDrag = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then svDrag = false; hueDrag = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
        if svDrag then
            local abs = svBox.AbsolutePosition; local sz = svBox.AbsoluteSize
            local s = math.clamp((i.Position.X - abs.X) / sz.X, 0, 1)
            local v = 1 - math.clamp((i.Position.Y - abs.Y) / sz.Y, 0, 1)
            optApi:SetHSV(nil, s, v, nil)
        end
        if hueDrag then
            local abs = hueBar.AbsolutePosition; local sz = hueBar.AbsoluteSize
            local h = math.clamp((i.Position.Y - abs.Y) / sz.Y, 0, 1)
            optApi:SetHSV(h, nil, nil, nil)
        end
    end)
    swatch.Activated:Connect(function()
        if picker.Visible then picker.Visible = false; return end
        local abs = swatch.AbsolutePosition; local sz = swatch.AbsoluteSize
        local mp = mainFrame.AbsolutePosition
        picker.Position = UDim2.fromOffset(abs.X - mp.X - 220, abs.Y - mp.Y + sz.Y + 4)
        picker.Visible = true
    end)
    UserInputService.InputBegan:Connect(function(input)
        if picker.Visible and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            local mp = UserInputService:GetMouseLocation()
            local pa = picker.AbsolutePosition; local ps = picker.AbsoluteSize
            local sa = swatch.AbsolutePosition; local ss = swatch.AbsoluteSize
            local inPick = mp.X >= pa.X and mp.X <= pa.X+ps.X and mp.Y >= pa.Y and mp.Y <= pa.Y+ps.Y
            local inSw = mp.X >= sa.X and mp.X <= sa.X+ss.X and mp.Y >= sa.Y and mp.Y <= sa.Y+ss.Y
            if not inPick and not inSw then picker.Visible = false end
        end
    end)
    render()
    return optApi
end

local function makeBindVisual(moduleApi, optSettings)
    local row = new("Frame", {
        Parent=moduleApi._OptionContainer, Size=UDim2.new(1,0,0,34), BackgroundTransparency=1,
    })
    new("TextLabel", {
        Parent=row, Size=UDim2.new(1,-90,1,0), BackgroundTransparency=1,
        Font=FONT_MED, TextSize=12, TextColor3=PALETTE.TEXT_DIM,
        TextXAlignment=Enum.TextXAlignment.Left, Text=tostring(optSettings.Name),
    })
    local btn = new("TextButton", {
        Parent=row, Size=UDim2.fromOffset(80,22),
        Position=UDim2.new(1,-84,0.5,-11), AutoButtonColor=false,
        BackgroundColor3=PALETTE.BG_TERTIARY, BorderSizePixel=0,
        Font=FONT_BOLD, TextSize=11, TextColor3=PALETTE.TEXT_PRIMARY, Text="",
    })
    corner(btn, 5)
    strokeOf(btn, PALETTE.BORDER_SOFT, 1, 0)
    local optApi = {
        Type="Bind", Name=optSettings.Name,
        Value=optSettings.Default or "",
        Function=optSettings.Function or function() end,
    }
    local listening = false
    local function render()
        if listening then btn.Text = "..."; btn.BackgroundColor3 = PALETTE.ACCENT_DIM
        else btn.Text = optApi.Value == "" and "None" or tostring(optApi.Value); btn.BackgroundColor3 = PALETTE.BG_TERTIARY end
    end
    optApi.SetValue = function(_, v) optApi.Value = v or ""; render(); pcall(optApi.Function, optApi.Value) end
    optApi.Refresh = render
    btn.Activated:Connect(function() listening = not listening; render() end)
    UserInputService.InputBegan:Connect(function(input)
        if not listening then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local k = input.KeyCode.Name
            if k == "Escape" or k == "Backspace" then optApi:SetValue("")
            else optApi:SetValue(k) end
            listening = false; render()
        end
    end)
    render()
    return optApi
end

local function makeTextListVisual(moduleApi, optSettings)
    local row = new("Frame", {
        Parent=moduleApi._OptionContainer, Size=UDim2.new(1,0,0,34), BackgroundTransparency=1,
    })
    new("TextLabel", {
        Parent=row, Size=UDim2.new(1,-80,1,0), BackgroundTransparency=1,
        Font=FONT_MED, TextSize=12, TextColor3=PALETTE.TEXT_DIM,
        TextXAlignment=Enum.TextXAlignment.Left, Text=tostring(optSettings.Name),
    })
    local btn = new("TextButton", {
        Parent=row, Size=UDim2.fromOffset(72,22),
        Position=UDim2.new(1,-76,0.5,-11), AutoButtonColor=false,
        BackgroundColor3=PALETTE.BG_TERTIARY, BorderSizePixel=0,
        Font=FONT_MED, TextSize=11, TextColor3=PALETTE.TEXT_DIM, Text="Open List",
    })
    corner(btn, 5)
    local optApi = {
        Type="TextList", Name=optSettings.Name,
        ListEnabled=optSettings.ListEnabled or {},
        Function=optSettings.Function or function() end,
    }
    optApi.Refresh = function() end
    btn.Activated:Connect(function() createNotification(optSettings.Name, "TextList UI coming v0.5", 3) end)
    return optApi
end

local function makeButtonVisual(moduleApi, optSettings)
    local row = new("Frame", {
        Parent=moduleApi._OptionContainer, Size=UDim2.new(1,0,0,36), BackgroundTransparency=1,
    })
    local btn = new("TextButton", {
        Parent=row, Size=UDim2.new(1,0,1,-4),
        AutoButtonColor=false, BorderSizePixel=0,
        BackgroundColor3=PALETTE.BG_TERTIARY,
        Font=FONT_MED, TextSize=12, TextColor3=PALETTE.TEXT_PRIMARY,
        Text=tostring(optSettings.Name),
    })
    corner(btn, 6)
    strokeOf(btn, PALETTE.BORDER_SOFT, 1, 0)
    btn.MouseEnter:Connect(function() tween(btn, 0.12, {BackgroundColor3 = PALETTE.ACCENT_DIM}) end)
    btn.MouseLeave:Connect(function() tween(btn, 0.12, {BackgroundColor3 = PALETTE.BG_TERTIARY}) end)
    local optApi = {
        Type="Button", Name=optSettings.Name,
        Function=optSettings.Function or function() end,
    }
    optApi.Activate = function() pcall(optApi.Function) end
    optApi.Refresh = function() end
    btn.Activated:Connect(function() optApi.Activate() end)
    return optApi
end

mainapi = {}
mainapi.Categories = {}
mainapi.Modules = {}
mainapi.Libraries = {}
mainapi.Loaded = false
mainapi.Keybind = {"RightShift"}
mainapi.Cleanups = {}

function mainapi:CreateNotification(t, c, d) return createNotification(t, c, d) end
function mainapi:Clean(t) table.insert(self.Cleanups, t); return t end
function mainapi:ApplyCurrentLayout() end
function mainapi:Uninject()
    mainapi.Loaded = false
    for _, t in ipairs(mainapi.Cleanups) do
        pcall(function()
            if type(t) == "function" then t()
            elseif type(t) == "table" and t.Disconnect then t:Disconnect()
            elseif type(t) == "userdata" and t.Disconnect then t:Disconnect()
            elseif type(t) == "thread" then task.cancel(t)
            elseif type(t) == "userdata" and t.Destroy then t:Destroy()
            end
        end)
    end
    if screenGui then screenGui:Destroy() end
    if blur then blur:Destroy() end
    shared.nova = nil
end
function mainapi:Serialize()
    local out = {}
    for _, m in pairs(self.Modules) do
        local entry = {Enabled = m.Enabled}
        if m.Options then
            entry.Options = {}
            for n, o in pairs(m.Options) do
                if o.Type == "Toggle" then entry.Options[n] = {Enabled = o.Enabled}
                elseif o.Type == "Slider" then entry.Options[n] = {Value = o.Value}
                elseif o.Type == "ColorSlider" then entry.Options[n] = {Hue=o.Hue, Sat=o.Sat, Value=o.Value, Opacity=o.Opacity}
                elseif o.Type == "Dropdown" then entry.Options[n] = {Value = o.Value}
                elseif o.Type == "Bind" then entry.Options[n] = {Value = o.Value}
                elseif o.Type == "TextList" then entry.Options[n] = {ListEnabled = o.ListEnabled}
                end
            end
        end
        out[m.Name] = entry
    end
    return out
end
function mainapi:Load()
    local saved = profile or {}
    for name, entry in pairs(saved) do
        if type(entry) == "table" and entry.Enabled ~= nil or entry.Options then
            local mod = mainapi.Modules[name]
            if mod then
                if entry.Options then
                    for optName, optState in pairs(entry.Options) do
                        local opt = mod.Options and mod.Options[optName]
                        if opt then
                            if opt.Type == "Toggle" and optState.Enabled ~= nil then opt:SetEnabled(optState.Enabled) end
                            if opt.Type == "Slider" and optState.Value ~= nil then opt:SetValue(optState.Value) end
                            if opt.Type == "ColorSlider" then opt:SetHSV(optState.Hue, optState.Sat, optState.Value, optState.Opacity) end
                            if opt.Type == "Dropdown" and optState.Value ~= nil then opt:SetValue(optState.Value) end
                            if opt.Type == "Bind" and optState.Value ~= nil then opt:SetValue(optState.Value) end
                            if opt.Type == "TextList" and optState.ListEnabled then opt.ListEnabled = optState.ListEnabled; pcall(opt.Function, opt.ListEnabled); opt.Refresh() end
                        end
                    end
                end
                if entry.Enabled ~= nil then mod:SetEnabled(entry.Enabled) end
            end
        end
    end
    mainapi.Loaded = true
end
function mainapi:Save() saveProfile(self:Serialize()) end

function mainapi:CreateCategory(catSettings)
    local catApi = {Name = catSettings.Name, Modules = {}, ModuleOrder = {}}
    local row = new("Frame", {
        Parent=catList, Size=UDim2.new(1,0,0,44),
        BackgroundColor3=PALETTE.BG_TERTIARY, BackgroundTransparency=1, BorderSizePixel=0,
    })
    corner(row, 8)
    new("UIGradient", {
        Parent=row, Rotation=45,
        Color=ColorSequence.new(PALETTE.ACCENT_DIM, PALETTE.ACCENT_2),
        Transparency=NumberSequence.new(0.4),
    })
    local indicator = new("Frame", {
        Parent=row, Size=UDim2.new(0,3,0,0),
        Position=UDim2.new(0,0,0.5,0), AnchorPoint=Vector2.new(0,0.5),
        BackgroundColor3=PALETTE.ACCENT_BRIGHT, BorderSizePixel=0,
    })
    corner(indicator, 2)
    local icon = new("ImageLabel", {
        Parent=row, Size=UDim2.fromOffset(20,20),
        Position=UDim2.new(0,16,0.5,-10), BackgroundTransparency=1,
        Image=CATEGORY_ICONS[catApi.Name] or "rbxassetid://10723345544",
        ImageColor3=PALETTE.TEXT_DIM,
    })
    local label = new("TextLabel", {
        Parent=row, Size=UDim2.new(1,-50,1,0),
        Position=UDim2.new(0,46,0,0), BackgroundTransparency=1,
        Font=FONT_MED, TextSize=13, TextColor3=PALETTE.TEXT_DIM,
        TextXAlignment=Enum.TextXAlignment.Left, Text=catApi.Name,
    })
    local btn = new("TextButton", {
        Parent=row, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="",
    })
    btn.Activated:Connect(function() selectCategory(catApi.Name) end)
    btn.MouseEnter:Connect(function()
        if currentCategoryName ~= catApi.Name then
            tween(label, 0.12, {TextColor3=PALETTE.TEXT_PRIMARY})
            tween(icon, 0.12, {ImageColor3=PALETTE.TEXT_PRIMARY})
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentCategoryName ~= catApi.Name then
            tween(label, 0.12, {TextColor3=PALETTE.TEXT_DIM})
            tween(icon, 0.12, {ImageColor3=PALETTE.TEXT_DIM})
        end
    end)
    catApi.Row = row; catApi.Text = label
    catApi.IconImg = icon; catApi.Indicator = indicator

    function catApi:CreateModule(modSettings)
        local moduleApi = {
            Name=modSettings.Name, Tooltip=modSettings.Tooltip,
            Enabled=false, Function=modSettings.Function or function() end,
            Options={}, OptionOrder={}, Cleanups={},
        }
        local card = new("Frame", {
            Parent=moduleList, Size=UDim2.new(1,0,0,68),
            BackgroundColor3=PALETTE.BG_SECONDARY, BorderSizePixel=0, Visible=false,
        })
        corner(card, 10)
        strokeOf(card, PALETTE.BORDER_SOFT, 1, 0.4)
        new("UIGradient", {
            Parent=card, Rotation=90,
            Color=ColorSequence.new(PALETTE.BG_SECONDARY, PALETTE.BG_PRIMARY),
        })
        local accentBar = new("Frame", {
            Parent=card, Size=UDim2.new(0,4,0,40),
            Position=UDim2.new(0,0,0,14), BorderSizePixel=0,
            BackgroundColor3=PALETTE.BG_TERTIARY,
        })
        corner(accentBar, 2)
        local nameLabel = new("TextLabel", {
            Parent=card, Size=UDim2.new(1,-120,0,18),
            Position=UDim2.new(0,18,0,12), BackgroundTransparency=1,
            Font=FONT_BOLD, TextSize=14, TextColor3=PALETTE.TEXT_DIM,
            TextXAlignment=Enum.TextXAlignment.Left, Text=moduleApi.Name,
        })
        local descLabel = new("TextLabel", {
            Parent=card, Size=UDim2.new(1,-120,0,14),
            Position=UDim2.new(0,18,0,32), BackgroundTransparency=1,
            Font=FONT, TextSize=11, TextColor3=PALETTE.TEXT_GHOST,
            TextXAlignment=Enum.TextXAlignment.Left, Text=moduleApi.Tooltip or "",
        })
        local statusBadge = new("Frame", {
            Parent=card, Size=UDim2.fromOffset(48,20),
            Position=UDim2.new(1,-60,0,12),
            BackgroundColor3=PALETTE.BG_TERTIARY, BorderSizePixel=0,
        })
        corner(statusBadge, 10)
        local statusText = new("TextLabel", {
            Parent=statusBadge, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
            Font=FONT_BOLD, TextSize=9, TextColor3=PALETTE.TEXT_DIM, Text="OFF",
        })
        local settingsBtn = new("ImageButton", {
            Parent=card, Size=UDim2.fromOffset(18,18),
            Position=UDim2.new(1,-30,0,36), BackgroundTransparency=1,
            Image="rbxassetid://10723345544", ImageColor3=PALETTE.TEXT_GHOST,
            AutoButtonColor=false,
        })
        local hitArea = new("TextButton", {
            Parent=card, Size=UDim2.new(1,-32,1,0),
            BackgroundTransparency=1, AutoButtonColor=false, Text="",
        })
        local optContainer = new("Frame", {
            Parent=card, Size=UDim2.new(1,0,0,0),
            BackgroundTransparency=1, Visible=false,
            AutomaticSize=Enum.AutomaticSize.Y, LayoutOrder=2,
        })
        listLayout(optContainer, 4)
        pad(optContainer, 4, 12, 12, 12)
        moduleApi.Frame = card
        moduleApi._OptionContainer = optContainer

        local function renderState(animate)
            local on = moduleApi.Enabled
            local barCol = on and PALETTE.ACCENT or PALETTE.BG_TERTIARY
            local nameCol = on and PALETTE.TEXT_PRIMARY or PALETTE.TEXT_DIM
            local badgeCol = on and PALETTE.ACCENT_DIM or PALETTE.BG_TERTIARY
            local badgeTextCol = on and PALETTE.TEXT_PRIMARY or PALETTE.TEXT_DIM
            if animate then
                tween(accentBar, 0.18, {BackgroundColor3=barCol, Size = on and UDim2.new(0,4,0,52) or UDim2.new(0,4,0,40), Position = on and UDim2.new(0,0,0,8) or UDim2.new(0,0,0,14)})
                tween(nameLabel, 0.15, {TextColor3=nameCol})
                tween(statusBadge, 0.15, {BackgroundColor3=badgeCol})
                tween(statusText, 0.15, {TextColor3=badgeTextCol})
            else
                accentBar.BackgroundColor3 = barCol
                nameLabel.TextColor3 = nameCol
                statusBadge.BackgroundColor3 = badgeCol
                statusText.TextColor3 = badgeTextCol
            end
            statusText.Text = on and "ON" or "OFF"
            settingsBtn.Visible = #moduleApi.OptionOrder > 0
            updatePageHeader()
        end

        hitArea.Activated:Connect(function() moduleApi:SetEnabled(not moduleApi.Enabled) end)
        settingsBtn.Activated:Connect(function() focusModule(moduleApi) end)
        settingsBtn.MouseEnter:Connect(function() tween(settingsBtn, 0.12, {ImageColor3 = PALETTE.ACCENT_BRIGHT}) end)
        settingsBtn.MouseLeave:Connect(function() tween(settingsBtn, 0.12, {ImageColor3 = PALETTE.TEXT_GHOST}) end)
        card.MouseEnter = nil

        local hover = new("TextButton", {
            Parent=card, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, AutoButtonColor=false, Text="", ZIndex=0,
        })
        hover.MouseEnter:Connect(function() tween(card, 0.12, {BackgroundColor3 = PALETTE.BG_TERTIARY}) end)
        hover.MouseLeave:Connect(function() tween(card, 0.12, {BackgroundColor3 = PALETTE.BG_SECONDARY}) end)
        hover.Activated:Connect(function() moduleApi:SetEnabled(not moduleApi.Enabled) end)

        function moduleApi:SetEnabled(v)
            v = v and true or false
            if self.Enabled == v then return end
            self.Enabled = v
            renderState(true)
            pcall(self.Function, v)
            if not v then
                for _, t in ipairs(self.Cleanups) do
                    pcall(function()
                        if type(t) == "function" then t()
                        elseif type(t) == "table" and t.Disconnect then t:Disconnect()
                        elseif type(t) == "userdata" and t.Disconnect then t:Disconnect()
                        elseif type(t) == "thread" then task.cancel(t)
                        end
                    end)
                end
                self.Cleanups = {}
            end
        end
        function moduleApi:Clean(t) table.insert(self.Cleanups, t); return t end
        function moduleApi:CreateToggle(s) local a=makeToggleVisual(self,s); self.Options[s.Name]=a; table.insert(self.OptionOrder,a); renderState(false); return a end
        function moduleApi:CreateSlider(s) local a=makeSliderVisual(self,s); self.Options[s.Name]=a; table.insert(self.OptionOrder,a); renderState(false); return a end
        function moduleApi:CreateColorSlider(s) local a=makeColorSliderVisual(self,s); self.Options[s.Name]=a; table.insert(self.OptionOrder,a); renderState(false); return a end
        function moduleApi:CreateDropdown(s) local a=makeDropdownVisual(self,s); self.Options[s.Name]=a; table.insert(self.OptionOrder,a); renderState(false); return a end
        function moduleApi:CreateBind(s) local a=makeBindVisual(self,s); self.Options[s.Name]=a; table.insert(self.OptionOrder,a); renderState(false); return a end
        function moduleApi:CreateTextList(s) local a=makeTextListVisual(self,s); self.Options[s.Name]=a; table.insert(self.OptionOrder,a); renderState(false); return a end
        function moduleApi:CreateButton(s) local a=makeButtonVisual(self,s); self.Options[s.Name]=a; table.insert(self.OptionOrder,a); renderState(false); return a end

        self.Modules[modSettings.Name] = moduleApi
        table.insert(self.ModuleOrder, moduleApi)
        mainapi.Modules[modSettings.Name] = moduleApi
        renderState(false)
        if currentCategoryName == self.Name then refreshModuleList() end
        return moduleApi
    end
    mainapi.Categories[catApi.Name] = catApi
    table.insert(categories, catApi)
    if not currentCategoryName then selectCategory(catApi.Name) end
    return catApi
end

for _, n in ipairs({"Combat", "Blatant", "Render", "Utility", "World", "Inventory", "Minigames", "Kits"}) do
    mainapi:CreateCategory({Name = n})
end

local function setOpen(open)
    if open then
        mainFrame.Visible = true
        scaler.Scale = 0.94
        mainFrame.BackgroundTransparency = 1
        tween(scaler, 0.24, {Scale=1}, Enum.EasingStyle.Back)
        tween(mainFrame, 0.2, {BackgroundTransparency=0})
        tween(blur, 0.25, {Size=10})
    else
        tween(mainFrame, 0.15, {BackgroundTransparency=1})
        tween(scaler, 0.18, {Scale=0.94})
        tween(blur, 0.2, {Size=0})
        task.delay(0.18, function() mainFrame.Visible = false end)
    end
end
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        for _, k in ipairs(mainapi.Keybind) do
            if input.KeyCode == Enum.KeyCode[k] then setOpen(not mainFrame.Visible); return end
        end
    end
end)

return mainapi
