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
local lplr             = Players.LocalPlayer

local THEMES = {
    Midnight = {
        BG_DEEP=Color3.fromRGB(13,14,24), BG_PRIMARY=Color3.fromRGB(19,21,35),
        BG_SECONDARY=Color3.fromRGB(26,28,46), BG_TERTIARY=Color3.fromRGB(36,39,60),
        BG_QUARTERY=Color3.fromRGB(44,48,72),
        ACCENT=Color3.fromRGB(138,116,255), ACCENT_2=Color3.fromRGB(96,184,255),
        ACCENT_GLOW=Color3.fromRGB(168,136,255), ACCENT_DIM=Color3.fromRGB(80,68,160),
        TEXT_PRIMARY=Color3.fromRGB(235,237,246), TEXT_DIM=Color3.fromRGB(130,138,165),
        TEXT_GHOST=Color3.fromRGB(85,92,120),
        SUCCESS=Color3.fromRGB(120,230,140), DANGER=Color3.fromRGB(245,100,100),
        BORDER=Color3.fromRGB(48,52,78), BORDER_SOFT=Color3.fromRGB(36,40,60),
    },
    Onyx = {
        BG_DEEP=Color3.fromRGB(8,8,10), BG_PRIMARY=Color3.fromRGB(14,14,18),
        BG_SECONDARY=Color3.fromRGB(20,20,26), BG_TERTIARY=Color3.fromRGB(30,30,38),
        BG_QUARTERY=Color3.fromRGB(40,40,50),
        ACCENT=Color3.fromRGB(180,140,255), ACCENT_2=Color3.fromRGB(220,180,255),
        ACCENT_GLOW=Color3.fromRGB(200,160,255), ACCENT_DIM=Color3.fromRGB(100,80,150),
        TEXT_PRIMARY=Color3.fromRGB(240,240,245), TEXT_DIM=Color3.fromRGB(135,135,150),
        TEXT_GHOST=Color3.fromRGB(80,80,95),
        SUCCESS=Color3.fromRGB(120,230,140), DANGER=Color3.fromRGB(245,100,100),
        BORDER=Color3.fromRGB(50,50,60), BORDER_SOFT=Color3.fromRGB(35,35,45),
    },
    Ocean = {
        BG_DEEP=Color3.fromRGB(8,16,28), BG_PRIMARY=Color3.fromRGB(14,24,38),
        BG_SECONDARY=Color3.fromRGB(20,34,52), BG_TERTIARY=Color3.fromRGB(30,48,72),
        BG_QUARTERY=Color3.fromRGB(40,62,90),
        ACCENT=Color3.fromRGB(80,180,255), ACCENT_2=Color3.fromRGB(120,220,255),
        ACCENT_GLOW=Color3.fromRGB(100,200,255), ACCENT_DIM=Color3.fromRGB(50,110,160),
        TEXT_PRIMARY=Color3.fromRGB(230,240,250), TEXT_DIM=Color3.fromRGB(125,150,180),
        TEXT_GHOST=Color3.fromRGB(75,100,130),
        SUCCESS=Color3.fromRGB(120,230,140), DANGER=Color3.fromRGB(245,100,100),
        BORDER=Color3.fromRGB(45,70,100), BORDER_SOFT=Color3.fromRGB(30,50,75),
    },
    Crimson = {
        BG_DEEP=Color3.fromRGB(16,10,12), BG_PRIMARY=Color3.fromRGB(24,16,18),
        BG_SECONDARY=Color3.fromRGB(34,22,26), BG_TERTIARY=Color3.fromRGB(48,32,36),
        BG_QUARTERY=Color3.fromRGB(62,42,46),
        ACCENT=Color3.fromRGB(255,90,110), ACCENT_2=Color3.fromRGB(255,140,100),
        ACCENT_GLOW=Color3.fromRGB(255,120,130), ACCENT_DIM=Color3.fromRGB(160,60,75),
        TEXT_PRIMARY=Color3.fromRGB(245,235,235), TEXT_DIM=Color3.fromRGB(170,140,140),
        TEXT_GHOST=Color3.fromRGB(110,90,90),
        SUCCESS=Color3.fromRGB(120,230,140), DANGER=Color3.fromRGB(245,100,100),
        BORDER=Color3.fromRGB(70,46,52), BORDER_SOFT=Color3.fromRGB(50,32,38),
    },
    Forest = {
        BG_DEEP=Color3.fromRGB(10,18,14), BG_PRIMARY=Color3.fromRGB(16,26,20),
        BG_SECONDARY=Color3.fromRGB(22,36,28), BG_TERTIARY=Color3.fromRGB(32,50,40),
        BG_QUARTERY=Color3.fromRGB(42,66,52),
        ACCENT=Color3.fromRGB(100,230,150), ACCENT_2=Color3.fromRGB(150,255,180),
        ACCENT_GLOW=Color3.fromRGB(120,240,160), ACCENT_DIM=Color3.fromRGB(60,140,90),
        TEXT_PRIMARY=Color3.fromRGB(235,245,240), TEXT_DIM=Color3.fromRGB(135,165,150),
        TEXT_GHOST=Color3.fromRGB(85,110,95),
        SUCCESS=Color3.fromRGB(120,230,140), DANGER=Color3.fromRGB(245,100,100),
        BORDER=Color3.fromRGB(50,75,60), BORDER_SOFT=Color3.fromRGB(35,55,42),
    },
}
local THEME_ORDER = {"Midnight", "Onyx", "Ocean", "Crimson", "Forest"}
local currentThemeName = profile and profile._theme or "Midnight"
local theme = THEMES[currentThemeName] or THEMES.Midnight

local themed = {}
local function themeBind(instance, property, key)
    table.insert(themed, {instance=instance, property=property, key=key})
    if instance and instance[property] ~= nil then
        instance[property] = theme[key]
    end
end

local FONT = Enum.Font.Gotham
local FONT_MED = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold

local function new(class, props, children)
    local inst = Instance.new(class)
    if props then for k, v in pairs(props) do if k ~= "Parent" then inst[k] = v end end end
    if children then for _, c in ipairs(children) do c.Parent = inst end end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end
local function corner(parent, r) return new("UICorner", {Parent=parent, CornerRadius=UDim.new(0, r or 6)}) end
local function strokeOf(parent, color, t, trans)
    local s = new("UIStroke", {
        Parent=parent, Thickness=t or 1, Transparency=trans or 0,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
    })
    s.Color = color or theme.BORDER
    return s
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

local function dropShadow(parent, opacity)
    return new("ImageLabel", {
        Parent=parent, BackgroundTransparency=1,
        Image="rbxassetid://6014261993", ImageColor3=Color3.new(0,0,0),
        ImageTransparency=opacity or 0.5, ScaleType=Enum.ScaleType.Slice,
        SliceCenter=Rect.new(49,49,450,450),
        Size=UDim2.new(1,60,1,60), Position=UDim2.new(0,-30,0,-30), ZIndex=-1,
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

local function attachHover(button, onEnter, onLeave)
    button.MouseEnter:Connect(onEnter)
    button.MouseLeave:Connect(onLeave)
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

local WINDOW_W, WINDOW_H = 600, 440
local mainFrame = new("Frame", {
    Name="Main", Parent=screenGui,
    Size=UDim2.fromOffset(WINDOW_W, WINDOW_H),
    Position=UDim2.new(0.5, -WINDOW_W/2, 0.5, -WINDOW_H/2),
    BorderSizePixel=0, Visible=false,
})
themeBind(mainFrame, "BackgroundColor3", "BG_PRIMARY")
corner(mainFrame, 12)
local mainStroke = strokeOf(mainFrame, nil, 1, 0.3)
themeBind(mainStroke, "Color", "BORDER")
dropShadow(mainFrame, 0.6)
local mainGrad = new("UIGradient", {
    Parent=mainFrame, Rotation=90,
    Color=ColorSequence.new(theme.BG_PRIMARY, theme.BG_DEEP),
})
local scaler = new("UIScale", {Parent=mainFrame, Scale=1})

local titleBar = new("Frame", {
    Parent=mainFrame, Size=UDim2.new(1,0,0,48), BorderSizePixel=0,
})
themeBind(titleBar, "BackgroundColor3", "BG_SECONDARY")
corner(titleBar, 12)
local titleBarBottom = new("Frame", {
    Parent=titleBar, Size=UDim2.new(1,0,0,12), Position=UDim2.new(0,0,1,-12), BorderSizePixel=0,
})
themeBind(titleBarBottom, "BackgroundColor3", "BG_SECONDARY")

local accentStrip = new("Frame", {
    Parent=titleBar, Size=UDim2.new(1,0,0,2), Position=UDim2.new(0,0,0,0), BorderSizePixel=0,
})
themeBind(accentStrip, "BackgroundColor3", "ACCENT")
local accentStripGrad = new("UIGradient", {
    Parent=accentStrip, Rotation=0,
    Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.ACCENT),
        ColorSequenceKeypoint.new(0.5, theme.ACCENT_2),
        ColorSequenceKeypoint.new(1, theme.ACCENT),
    }),
})

local titleText = new("TextLabel", {
    Parent=titleBar, Size=UDim2.new(0,140,1,-8), Position=UDim2.new(0,18,0,4),
    BackgroundTransparency=1, Font=FONT_BOLD, TextSize=22,
    TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Center,
    Text="Nova",
})
themeBind(titleText, "TextColor3", "TEXT_PRIMARY")
local titleGrad = new("UIGradient", {
    Parent=titleText, Rotation=25,
    Color=ColorSequence.new(theme.TEXT_PRIMARY, theme.ACCENT),
})

local versionChip = new("Frame", {
    Parent=titleBar, Size=UDim2.fromOffset(38,18),
    Position=UDim2.new(0,82,0.5,-9), BorderSizePixel=0,
})
themeBind(versionChip, "BackgroundColor3", "ACCENT_DIM")
corner(versionChip, 9)
local versionLabel = new("TextLabel", {
    Parent=versionChip, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
    Font=FONT_BOLD, TextSize=11, Text="v2",
})
themeBind(versionLabel, "TextColor3", "TEXT_PRIMARY")

local themeBtn = new("TextButton", {
    Parent=titleBar, Size=UDim2.fromOffset(80,24),
    Position=UDim2.new(1,-262,0.5,-12), AutoButtonColor=false,
    BorderSizePixel=0, Font=FONT_MED, TextSize=11,
    Text="● " .. currentThemeName,
})
themeBind(themeBtn, "BackgroundColor3", "ACCENT_DIM")
themeBind(themeBtn, "TextColor3", "TEXT_PRIMARY")
corner(themeBtn, 6)
local themeBtnStroke = strokeOf(themeBtn, nil, 1, 0)
themeBind(themeBtnStroke, "Color", "ACCENT")

local LAYOUT_ORDER = {"Sidebar", "Topbar", "Compact"}
local currentLayoutName = profile and profile._layout or "Sidebar"
local layoutBtn = new("TextButton", {
    Parent=titleBar, Size=UDim2.fromOffset(86,24),
    Position=UDim2.new(1,-354,0.5,-12), AutoButtonColor=false,
    BorderSizePixel=0, Font=FONT_MED, TextSize=11,
    Text="◧ " .. currentLayoutName,
})
themeBind(layoutBtn, "BackgroundColor3", "BG_QUARTERY")
themeBind(layoutBtn, "TextColor3", "TEXT_PRIMARY")
corner(layoutBtn, 6)
local layoutBtnStroke = strokeOf(layoutBtn, nil, 1, 0)
themeBind(layoutBtnStroke, "Color", "ACCENT_DIM")

local userChip = new("TextLabel", {
    Parent=titleBar, Size=UDim2.new(0,160,1,0),
    Position=UDim2.new(1,-176,0,0), BackgroundTransparency=1,
    Font=FONT_MED, TextSize=13,
    TextXAlignment=Enum.TextXAlignment.Right, Text=lplr.Name,
})
themeBind(userChip, "TextColor3", "TEXT_DIM")

makeDraggable(titleBar, mainFrame)

local STRIP_W = 150
local catStrip = new("Frame", {
    Parent=mainFrame, Size=UDim2.new(0,STRIP_W,1,-48),
    Position=UDim2.new(0,0,0,48), BorderSizePixel=0,
})
themeBind(catStrip, "BackgroundColor3", "BG_SECONDARY")
local catStripGrad = new("UIGradient", {
    Parent=catStrip, Rotation=90,
    Color=ColorSequence.new(theme.BG_SECONDARY, Color3.fromRGB(
        math.max(theme.BG_SECONDARY.R*255 - 6, 0),
        math.max(theme.BG_SECONDARY.G*255 - 6, 0),
        math.max(theme.BG_SECONDARY.B*255 - 6, 0))),
})
local catStripBorder = new("Frame", {
    Parent=catStrip, Size=UDim2.new(0,1,1,0), Position=UDim2.new(1,-1,0,0), BorderSizePixel=0,
})
themeBind(catStripBorder, "BackgroundColor3", "BORDER_SOFT")

local catList = new("ScrollingFrame", {
    Parent=catStrip, Size=UDim2.new(1,0,1,0),
    BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=0,
    AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new(0,0,0,0),
})
listLayout(catList, 4)
pad(catList, 10, 10, 10, 10)

local modulePage = new("Frame", {
    Parent=mainFrame, Size=UDim2.new(1,-STRIP_W,1,-48),
    Position=UDim2.new(0,STRIP_W,0,48), BackgroundTransparency=1,
})

local pageHeader = new("Frame", {
    Parent=modulePage, Size=UDim2.new(1,0,0,56), BackgroundTransparency=1,
})
local pageTitle = new("TextLabel", {
    Parent=pageHeader, Size=UDim2.new(0,300,0,24),
    Position=UDim2.new(0,16,0,14), BackgroundTransparency=1,
    Font=FONT_BOLD, TextSize=18,
    TextXAlignment=Enum.TextXAlignment.Left, Text="Combat",
})
themeBind(pageTitle, "TextColor3", "TEXT_PRIMARY")
local pageSubtitle = new("TextLabel", {
    Parent=pageHeader, Size=UDim2.new(0,300,0,14),
    Position=UDim2.new(0,16,0,36), BackgroundTransparency=1,
    Font=FONT, TextSize=11,
    TextXAlignment=Enum.TextXAlignment.Left, Text="0 modules",
})
themeBind(pageSubtitle, "TextColor3", "TEXT_GHOST")

local searchBg = new("Frame", {
    Parent=pageHeader, Size=UDim2.fromOffset(180,30),
    Position=UDim2.new(1,-196,0,13), BorderSizePixel=0,
})
themeBind(searchBg, "BackgroundColor3", "BG_SECONDARY")
corner(searchBg, 6)
local searchStroke = strokeOf(searchBg, nil, 1, 0)
themeBind(searchStroke, "Color", "BORDER_SOFT")
local searchIcon = new("ImageLabel", {
    Parent=searchBg, Size=UDim2.fromOffset(14,14),
    Position=UDim2.new(0,8,0.5,-7), BackgroundTransparency=1,
    Image="rbxassetid://10734898355",
})
themeBind(searchIcon, "ImageColor3", "TEXT_GHOST")
local searchBox = new("TextBox", {
    Parent=searchBg, Size=UDim2.new(1,-32,1,0),
    Position=UDim2.new(0,28,0,0), BackgroundTransparency=1,
    Font=FONT, TextSize=12,
    PlaceholderText="Search modules...",
    Text="", TextXAlignment=Enum.TextXAlignment.Left, ClearTextOnFocus=false,
})
themeBind(searchBox, "TextColor3", "TEXT_PRIMARY")
themeBind(searchBox, "PlaceholderColor3", "TEXT_GHOST")

local moduleList = new("ScrollingFrame", {
    Parent=modulePage, Size=UDim2.new(1,0,1,-56),
    Position=UDim2.new(0,0,0,56),
    BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=3,
    ScrollBarImageTransparency=0.4,
    AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new(0,0,0,0),
})
themeBind(moduleList, "ScrollBarImageColor3", "ACCENT")
listLayout(moduleList, 8)
pad(moduleList, 4, 16, 16, 16)

local emptyState = new("Frame", {
    Parent=modulePage, Size=UDim2.new(1,-32,0,140),
    Position=UDim2.new(0,16,0,100), BackgroundTransparency=1, Visible=false,
})
local emptyIcon = new("ImageLabel", {
    Parent=emptyState, Size=UDim2.fromOffset(48,48),
    Position=UDim2.new(0.5,-24,0,16), BackgroundTransparency=1,
    Image="rbxassetid://10723345544", ImageTransparency=0.6,
})
themeBind(emptyIcon, "ImageColor3", "TEXT_GHOST")
local emptyLabel = new("TextLabel", {
    Parent=emptyState, Size=UDim2.new(1,0,0,40),
    Position=UDim2.new(0,0,0,72), BackgroundTransparency=1,
    Font=FONT_MED, TextSize=13, TextWrapped=true,
    Text="No modules in this category yet.\nv0.4+ adds the real BedWars modules.",
})
themeBind(emptyLabel, "TextColor3", "TEXT_GHOST")

local notifStack = new("Frame", {
    Parent=screenGui, Size=UDim2.new(0,320,1,-40),
    Position=UDim2.new(1,-340,0,20), BackgroundTransparency=1,
})
local notifLayout = listLayout(notifStack, 8, Enum.SortOrder.LayoutOrder)
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right

local function createNotification(title, content, duration)
    duration = duration or 4
    local frame = new("Frame", {
        Parent=notifStack, Size=UDim2.new(1,0,0,62),
        BorderSizePixel=0, BackgroundTransparency=1,
    })
    themeBind(frame, "BackgroundColor3", "BG_PRIMARY")
    corner(frame, 8)
    local s = strokeOf(frame, nil, 1, 0.3)
    themeBind(s, "Color", "BORDER")
    new("UIGradient", {
        Parent=frame, Rotation=90,
        Color=ColorSequence.new(theme.BG_PRIMARY, theme.BG_DEEP),
    })
    local strip = new("Frame", {
        Parent=frame, Size=UDim2.new(0,3,1,-16),
        Position=UDim2.new(0,8,0,8), BorderSizePixel=0,
    })
    themeBind(strip, "BackgroundColor3", "ACCENT")
    corner(strip, 2)
    local t = new("TextLabel", {
        Parent=frame, Size=UDim2.new(1,-28,0,18),
        Position=UDim2.new(0,20,0,10), BackgroundTransparency=1,
        Font=FONT_BOLD, TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Left, Text=tostring(title),
    })
    themeBind(t, "TextColor3", "TEXT_PRIMARY")
    local c = new("TextLabel", {
        Parent=frame, Size=UDim2.new(1,-28,1,-32),
        Position=UDim2.new(0,20,0,28), BackgroundTransparency=1,
        Font=FONT, TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
        TextWrapped=true, Text=tostring(content),
    })
    themeBind(c, "TextColor3", "TEXT_DIM")
    frame.Position = UDim2.new(1,50,0,0)
    tween(frame, 0.3, {BackgroundTransparency=0, Position=UDim2.new(0,0,0,0)}, Enum.EasingStyle.Quint)
    task.delay(duration, function()
        if frame.Parent then
            tween(frame, 0.25, {BackgroundTransparency=1, Position=UDim2.new(1,50,0,0)})
            task.wait(0.3); frame:Destroy()
        end
    end)
    return frame
end

local categories = {}
local currentCategoryName

local function updatePageHeader()
    if not currentCategoryName then return end
    pageTitle.Text = currentCategoryName
    local cat
    for _, c in ipairs(categories) do if c.Name == currentCategoryName then cat = c; break end end
    if not cat then return end
    local count = #(cat.ModuleOrder or {})
    pageSubtitle.Text = string.format("%d module%s", count, count == 1 and "" or "s")
    emptyState.Visible = (count == 0)
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
            tween(c.Row, 0.15, {BackgroundTransparency = selected and 0 or 1})
            tween(c.Text, 0.15, {TextColor3 = selected and theme.TEXT_PRIMARY or theme.TEXT_DIM})
            tween(c.IconImg, 0.15, {ImageColor3 = selected and theme.TEXT_PRIMARY or theme.TEXT_DIM})
            tween(c.Indicator, 0.18, {Size = selected and UDim2.new(0,3,0,22) or UDim2.new(0,3,0,0)})
            c.GradientOverlay.Enabled = selected
        end
    end
    refreshModuleList()
end

local function applyTheme(newName)
    if not THEMES[newName] then return end
    currentThemeName = newName
    theme = THEMES[newName]
    profile._theme = newName
    pcall(saveProfile, profile)
    for _, entry in ipairs(themed) do
        if entry.instance and entry.instance.Parent then
            local ok = pcall(function() tween(entry.instance, 0.25, {[entry.property] = theme[entry.key]}) end)
            if not ok then pcall(function() entry.instance[entry.property] = theme[entry.key] end) end
        end
    end
    mainGrad.Color = ColorSequence.new(theme.BG_PRIMARY, theme.BG_DEEP)
    catStripGrad.Color = ColorSequence.new(theme.BG_SECONDARY, Color3.fromRGB(
        math.max(theme.BG_SECONDARY.R*255 - 6, 0),
        math.max(theme.BG_SECONDARY.G*255 - 6, 0),
        math.max(theme.BG_SECONDARY.B*255 - 6, 0)))
    titleGrad.Color = ColorSequence.new(theme.TEXT_PRIMARY, theme.ACCENT)
    accentStripGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.ACCENT),
        ColorSequenceKeypoint.new(0.5, theme.ACCENT_2),
        ColorSequenceKeypoint.new(1, theme.ACCENT),
    })
    for _, c in ipairs(categories) do
        if c.GradientOverlay then
            c.GradientOverlay.Color = ColorSequence.new(theme.ACCENT, theme.ACCENT_2)
        end
        if c.Indicator then c.Indicator.BackgroundColor3 = theme.ACCENT end
    end
    themeBtn.Text = "● " .. newName
end

themeBtn.Activated:Connect(function()
    local idx = 1
    for i, n in ipairs(THEME_ORDER) do if n == currentThemeName then idx = i; break end end
    local next = THEME_ORDER[(idx % #THEME_ORDER) + 1]
    applyTheme(next)
    createNotification("Theme", "Switched to " .. next, 2)
end)

attachHover(themeBtn,
    function() tween(themeBtn, 0.12, {BackgroundColor3 = theme.ACCENT}) end,
    function() tween(themeBtn, 0.12, {BackgroundColor3 = theme.ACCENT_DIM}) end)
attachHover(layoutBtn,
    function() tween(layoutBtn, 0.12, {BackgroundColor3 = theme.ACCENT_DIM}) end,
    function() tween(layoutBtn, 0.12, {BackgroundColor3 = theme.BG_QUARTERY}) end)

local function applyCatStripVertical()
    catStrip.Size = UDim2.new(0, STRIP_W, 1, -48)
    catStrip.Position = UDim2.new(0, 0, 0, 48)
    catStripBorder.Size = UDim2.new(0, 1, 1, 0)
    catStripBorder.Position = UDim2.new(1, -1, 0, 0)
    catList.ScrollingDirection = Enum.ScrollingDirection.Y
    if catList.UIListLayout then
        catList.UIListLayout.FillDirection = Enum.FillDirection.Vertical
        catList.UIListLayout.Padding = UDim.new(0, 4)
    end
    pad(catList, 10, 10, 10, 10)
    for _, c in ipairs(categories) do
        if c.Row then
            c.Row.Size = UDim2.new(1, 0, 0, 36)
            c.IconImg.Position = UDim2.new(0, 14, 0.5, -9)
            c.IconImg.Size = UDim2.fromOffset(18, 18)
            c.Text.Size = UDim2.new(1, -42, 1, 0)
            c.Text.Position = UDim2.new(0, 40, 0, 0)
            c.Text.TextXAlignment = Enum.TextXAlignment.Left
            c.Indicator.Position = UDim2.new(0, 0, 0.5, 0)
            c.Indicator.AnchorPoint = Vector2.new(0, 0.5)
        end
    end
end

local function applyCatStripHorizontal()
    catStrip.Size = UDim2.new(1, 0, 0, 44)
    catStrip.Position = UDim2.new(0, 0, 0, 48)
    catStripBorder.Size = UDim2.new(1, 0, 0, 1)
    catStripBorder.Position = UDim2.new(0, 0, 1, -1)
    catList.ScrollingDirection = Enum.ScrollingDirection.X
    if catList.UIListLayout then
        catList.UIListLayout.FillDirection = Enum.FillDirection.Horizontal
        catList.UIListLayout.Padding = UDim.new(0, 6)
    end
    pad(catList, 8, 14, 8, 14)
    for _, c in ipairs(categories) do
        if c.Row then
            c.Row.Size = UDim2.fromOffset(96, 28)
            c.IconImg.Position = UDim2.new(0, 8, 0.5, -7)
            c.IconImg.Size = UDim2.fromOffset(14, 14)
            c.Text.Size = UDim2.new(1, -30, 1, 0)
            c.Text.Position = UDim2.new(0, 26, 0, 0)
            c.Text.TextXAlignment = Enum.TextXAlignment.Left
            c.Indicator.Position = UDim2.new(0.5, 0, 1, -2)
            c.Indicator.AnchorPoint = Vector2.new(0.5, 1)
        end
    end
end

local function applyLayout(name)
    if not table.find(LAYOUT_ORDER, name) then name = "Sidebar" end
    currentLayoutName = name
    profile._layout = name
    pcall(saveProfile, profile)
    layoutBtn.Text = "◧ " .. name

    if name == "Sidebar" then
        local W, H = 600, 440
        tween(mainFrame, 0.2, {Size = UDim2.fromOffset(W, H)})
        applyCatStripVertical()
        modulePage.Size = UDim2.new(1, -STRIP_W, 1, -48)
        modulePage.Position = UDim2.new(0, STRIP_W, 0, 48)
        moduleList.Size = UDim2.new(1, 0, 1, -56)
        moduleList.Position = UDim2.new(0, 0, 0, 56)
        pageHeader.Visible = true
        if moduleList.UIListLayout then
            moduleList.UIListLayout.FillDirection = Enum.FillDirection.Vertical
            moduleList.UIGridLayout = nil
        end
        for _, m in pairs(mainapi.Modules) do
            if m.Frame then m.Frame.Size = UDim2.new(1, 0, 0, 46) end
        end
    elseif name == "Topbar" then
        local W, H = 620, 460
        tween(mainFrame, 0.2, {Size = UDim2.fromOffset(W, H)})
        applyCatStripHorizontal()
        modulePage.Size = UDim2.new(1, 0, 1, -92)
        modulePage.Position = UDim2.new(0, 0, 0, 92)
        moduleList.Size = UDim2.new(1, 0, 1, -56)
        moduleList.Position = UDim2.new(0, 0, 0, 56)
        pageHeader.Visible = true
        if moduleList.UIListLayout then
            moduleList.UIListLayout.FillDirection = Enum.FillDirection.Vertical
        end
        for _, m in pairs(mainapi.Modules) do
            if m.Frame then m.Frame.Size = UDim2.new(1, 0, 0, 46) end
        end
    elseif name == "Compact" then
        local W, H = 520, 360
        tween(mainFrame, 0.2, {Size = UDim2.fromOffset(W, H)})
        applyCatStripVertical()
        catStrip.Size = UDim2.new(0, 110, 1, -48)
        modulePage.Size = UDim2.new(1, -110, 1, -48)
        modulePage.Position = UDim2.new(0, 110, 0, 48)
        moduleList.Size = UDim2.new(1, 0, 1, -44)
        moduleList.Position = UDim2.new(0, 0, 0, 44)
        pageHeader.Size = UDim2.new(1, 0, 0, 44)
        pageHeader.Visible = true
        if moduleList.UIListLayout then
            moduleList.UIListLayout.FillDirection = Enum.FillDirection.Vertical
            moduleList.UIListLayout.Padding = UDim.new(0, 4)
        end
        for _, c in ipairs(categories) do
            if c.Row then c.Row.Size = UDim2.new(1, 0, 0, 28) end
        end
        for _, m in pairs(mainapi.Modules) do
            if m.Frame then m.Frame.Size = UDim2.new(1, 0, 0, 36) end
        end
    end
end

layoutBtn.Activated:Connect(function()
    local idx = 1
    for i, n in ipairs(LAYOUT_ORDER) do if n == currentLayoutName then idx = i; break end end
    local next_ = LAYOUT_ORDER[(idx % #LAYOUT_ORDER) + 1]
    applyLayout(next_)
    createNotification("Layout", "Switched to " .. next_, 2)
end)

local function makeToggleVisual(moduleApi, optSettings)
    local row = new("Frame", {
        Parent=moduleApi._OptionContainer, Size=UDim2.new(1,0,0,32), BackgroundTransparency=1,
    })
    local label = new("TextLabel", {
        Parent=row, Size=UDim2.new(1,-50,1,0),
        BackgroundTransparency=1, Font=FONT, TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left, Text=tostring(optSettings.Name),
    })
    themeBind(label, "TextColor3", "TEXT_DIM")
    local pill = new("Frame", {
        Parent=row, Size=UDim2.fromOffset(36,20),
        Position=UDim2.new(1,-40,0.5,-10), BorderSizePixel=0,
    })
    themeBind(pill, "BackgroundColor3", "BG_TERTIARY")
    corner(pill, 10)
    local pillStroke = strokeOf(pill, nil, 1, 0.7)
    themeBind(pillStroke, "Color", "BORDER_SOFT")
    local dot = new("Frame", {
        Parent=pill, Size=UDim2.fromOffset(14,14),
        Position=UDim2.new(0,3,0.5,-7), BorderSizePixel=0,
    })
    themeBind(dot, "BackgroundColor3", "TEXT_DIM")
    corner(dot, 7)
    local glow = new("ImageLabel", {
        Parent=pill, BackgroundTransparency=1, ZIndex=0,
        Image="rbxassetid://6014261993", ScaleType=Enum.ScaleType.Slice,
        SliceCenter=Rect.new(49,49,450,450),
        Size=UDim2.new(1,40,1,40), Position=UDim2.new(0,-20,0,-20),
        ImageTransparency=1,
    })
    themeBind(glow, "ImageColor3", "ACCENT_GLOW")

    local optApi = {
        Type="Toggle", Name=optSettings.Name,
        Enabled=optSettings.Default==true, Object=row,
        Function=optSettings.Function or function() end,
    }
    local function render(animate)
        local on = optApi.Enabled
        local pillCol = on and theme.ACCENT or theme.BG_TERTIARY
        local dotCol = on and theme.TEXT_PRIMARY or theme.TEXT_DIM
        local dotPos = on and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
        local glowT = on and 0.5 or 1
        if animate then
            tween(pill, 0.18, {BackgroundColor3=pillCol})
            tween(dot, 0.22, {BackgroundColor3=dotCol, Position=dotPos}, Enum.EasingStyle.Back)
            tween(glow, 0.25, {ImageTransparency=glowT})
        else
            pill.BackgroundColor3 = pillCol
            dot.BackgroundColor3 = dotCol
            dot.Position = dotPos
            glow.ImageTransparency = glowT
        end
    end
    optApi.SetEnabled = function(_, v) optApi.Enabled = v and true or false; render(true); pcall(optApi.Function, optApi.Enabled) end
    optApi.Refresh = function() render(false) end
    local btn = new("TextButton", {Parent=row, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text=""})
    btn.Activated:Connect(function() optApi:SetEnabled(not optApi.Enabled) end)
    render(false)
    return optApi
end

local function makeSliderVisual(moduleApi, optSettings)
    local row = new("Frame", {
        Parent=moduleApi._OptionContainer, Size=UDim2.new(1,0,0,46), BackgroundTransparency=1,
    })
    local label = new("TextLabel", {
        Parent=row, Size=UDim2.new(1,-80,0,18),
        Position=UDim2.new(0,0,0,2), BackgroundTransparency=1,
        Font=FONT, TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left, Text=tostring(optSettings.Name),
    })
    themeBind(label, "TextColor3", "TEXT_DIM")
    local valueLabel = new("TextLabel", {
        Parent=row, Size=UDim2.fromOffset(80,18),
        Position=UDim2.new(1,-80,0,2), BackgroundTransparency=1,
        Font=FONT_MED, TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Right, Text="",
    })
    themeBind(valueLabel, "TextColor3", "TEXT_PRIMARY")
    local track = new("Frame", {
        Parent=row, Size=UDim2.new(1,0,0,6),
        Position=UDim2.new(0,0,0,28), BorderSizePixel=0,
    })
    themeBind(track, "BackgroundColor3", "BG_TERTIARY")
    corner(track, 3)
    local fill = new("Frame", {
        Parent=track, Size=UDim2.new(0,0,1,0), BorderSizePixel=0,
    })
    themeBind(fill, "BackgroundColor3", "ACCENT")
    corner(fill, 3)
    new("UIGradient", {
        Parent=fill, Rotation=0,
        Color=ColorSequence.new(theme.ACCENT, theme.ACCENT_2),
    })
    local knob = new("Frame", {
        Parent=track, Size=UDim2.fromOffset(14,14),
        Position=UDim2.new(0,-7,0.5,-7), BorderSizePixel=0,
    })
    themeBind(knob, "BackgroundColor3", "ACCENT")
    corner(knob, 7)
    local knobStroke = strokeOf(knob, nil, 2, 0)
    themeBind(knobStroke, "Color", "TEXT_PRIMARY")

    local min = optSettings.Min or 0
    local max = optSettings.Max or 100
    local decimals = optSettings.Decimal or 0
    local suffix = optSettings.Suffix
    local defaultVal = optSettings.Default or min

    local optApi = {
        Type="Slider", Name=optSettings.Name, Object=row,
        Min=min, Max=max, Value=defaultVal,
        Function=optSettings.Function or function() end,
    }
    local function formatVal(v)
        local rounded
        if decimals <= 0 then
            rounded = math.floor(v + 0.5)
        else
            local p = 10 ^ decimals
            rounded = math.floor(v * p + 0.5) / p
        end
        local sfx = ""
        if type(suffix) == "function" then sfx = " " .. tostring(suffix(rounded) or "")
        elseif type(suffix) == "string" then sfx = " " .. suffix end
        return tostring(rounded) .. sfx, rounded
    end
    local function render()
        local pct = (optApi.Value - min) / (max - min)
        pct = math.clamp(pct, 0, 1)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -7, 0.5, -7)
        local txt = formatVal(optApi.Value)
        valueLabel.Text = txt
    end
    optApi.SetValue = function(_, v)
        v = math.clamp(v, min, max)
        local _, rounded = formatVal(v)
        optApi.Value = rounded or v
        render()
        pcall(optApi.Function, optApi.Value)
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
            dragging = true
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    optApi:SetValue(defaultVal)
    return optApi
end

local function makeDropdownVisual(moduleApi, optSettings)
    local row = new("Frame", {
        Parent=moduleApi._OptionContainer, Size=UDim2.new(1,0,0,32),
        BackgroundTransparency=1, ClipsDescendants=false,
    })
    local label = new("TextLabel", {
        Parent=row, Size=UDim2.new(0.5,-4,1,0), BackgroundTransparency=1,
        Font=FONT, TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left, Text=tostring(optSettings.Name),
    })
    themeBind(label, "TextColor3", "TEXT_DIM")
    local selector = new("TextButton", {
        Parent=row, Size=UDim2.new(0.5,-4,0,26),
        Position=UDim2.new(0.5,4,0.5,-13), AutoButtonColor=false,
        BorderSizePixel=0, Font=FONT_MED, TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left, Text="",
    })
    themeBind(selector, "BackgroundColor3", "BG_TERTIARY")
    themeBind(selector, "TextColor3", "TEXT_PRIMARY")
    corner(selector, 5)
    pad(selector, 0, 8, 0, 10)
    local selStroke = strokeOf(selector, nil, 1, 0.6)
    themeBind(selStroke, "Color", "BORDER_SOFT")
    local arrow = new("TextLabel", {
        Parent=selector, Size=UDim2.fromOffset(14,14),
        Position=UDim2.new(1,-18,0.5,-7), BackgroundTransparency=1,
        Font=FONT_BOLD, TextSize=10, Text="▼",
    })
    themeBind(arrow, "TextColor3", "TEXT_DIM")

    local dropdown = new("Frame", {
        Parent=mainFrame, Size=UDim2.fromOffset(0,0),
        BorderSizePixel=0, Visible=false, ZIndex=10,
    })
    themeBind(dropdown, "BackgroundColor3", "BG_TERTIARY")
    corner(dropdown, 5)
    local ddStroke = strokeOf(dropdown, nil, 1, 0)
    themeBind(ddStroke, "Color", "BORDER")
    local ddList = new("ScrollingFrame", {
        Parent=dropdown, Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=2,
        AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new(0,0,0,0),
        ZIndex=11,
    })
    themeBind(ddList, "ScrollBarImageColor3", "ACCENT")
    listLayout(ddList, 2)
    pad(ddList, 4, 4, 4, 4)

    local list = optSettings.List or {}
    local optApi = {
        Type="Dropdown", Name=optSettings.Name, Object=row,
        Value=optSettings.Default or list[1] or "", List=list,
        Function=optSettings.Function or function() end,
    }

    local function refreshList()
        for _, c in ipairs(ddList:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, item in ipairs(optApi.List) do
            local b = new("TextButton", {
                Parent=ddList, Size=UDim2.new(1,0,0,24),
                AutoButtonColor=false, BorderSizePixel=0,
                Font=FONT, TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Left, Text=tostring(item),
                ZIndex=12,
            })
            themeBind(b, "BackgroundColor3", item == optApi.Value and "ACCENT_DIM" or "BG_TERTIARY")
            themeBind(b, "TextColor3", item == optApi.Value and "TEXT_PRIMARY" or "TEXT_DIM")
            corner(b, 4)
            pad(b, 0, 8, 0, 10)
            b.MouseEnter:Connect(function()
                if optApi.Value ~= item then tween(b, 0.1, {BackgroundColor3=theme.BG_QUARTERY}) end
            end)
            b.MouseLeave:Connect(function()
                if optApi.Value ~= item then tween(b, 0.1, {BackgroundColor3=theme.BG_TERTIARY}) end
            end)
            b.Activated:Connect(function()
                optApi.Value = item
                selector.Text = tostring(item)
                dropdown.Visible = false
                refreshList()
                pcall(optApi.Function, optApi.Value)
            end)
        end
    end

    optApi.SetValue = function(_, v)
        optApi.Value = v
        selector.Text = tostring(v)
        refreshList()
        pcall(optApi.Function, optApi.Value)
    end
    optApi.SetList = function(_, l)
        optApi.List = l
        if not table.find(l, optApi.Value) and l[1] then
            optApi.Value = l[1]; selector.Text = tostring(l[1])
        end
        refreshList()
    end
    optApi.Refresh = function()
        selector.Text = tostring(optApi.Value)
        refreshList()
    end

    selector.Text = tostring(optApi.Value)
    selector.Activated:Connect(function()
        if dropdown.Visible then dropdown.Visible = false; return end
        local abs = selector.AbsolutePosition
        local sz = selector.AbsoluteSize
        local mfPos = mainFrame.AbsolutePosition
        local items = math.min(#optApi.List, 6)
        local h = math.max(items * 26 + 8, 30)
        dropdown.Size = UDim2.fromOffset(sz.X, h)
        dropdown.Position = UDim2.fromOffset(abs.X - mfPos.X, abs.Y - mfPos.Y + sz.Y + 4)
        dropdown.Visible = true
        refreshList()
    end)
    refreshList()

    UserInputService.InputBegan:Connect(function(input)
        if dropdown.Visible and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            local mp = UserInputService:GetMouseLocation()
            local abs = dropdown.AbsolutePosition
            local sz = dropdown.AbsoluteSize
            local secAbs = selector.AbsolutePosition
            local secSz = selector.AbsoluteSize
            local inDD = mp.X >= abs.X and mp.X <= abs.X+sz.X and mp.Y >= abs.Y and mp.Y <= abs.Y+sz.Y
            local inSec = mp.X >= secAbs.X and mp.X <= secAbs.X+secSz.X and mp.Y >= secAbs.Y and mp.Y <= secAbs.Y+secSz.Y
            if not inDD and not inSec then dropdown.Visible = false end
        end
    end)

    return optApi
end

local function makeColorSliderVisual(moduleApi, optSettings)
    local row = new("Frame", {
        Parent=moduleApi._OptionContainer, Size=UDim2.new(1,0,0,32), BackgroundTransparency=1,
    })
    local label = new("TextLabel", {
        Parent=row, Size=UDim2.new(1,-48,1,0),
        BackgroundTransparency=1, Font=FONT, TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left, Text=tostring(optSettings.Name),
    })
    themeBind(label, "TextColor3", "TEXT_DIM")
    local swatch = new("TextButton", {
        Parent=row, Size=UDim2.fromOffset(36,20),
        Position=UDim2.new(1,-40,0.5,-10), AutoButtonColor=false,
        BorderSizePixel=0, Text="",
    })
    corner(swatch, 5)
    local swStroke = strokeOf(swatch, nil, 1, 0)
    themeBind(swStroke, "Color", "BORDER_SOFT")

    local picker = new("Frame", {
        Parent=mainFrame, Size=UDim2.fromOffset(220,200),
        BorderSizePixel=0, Visible=false, ZIndex=10,
    })
    themeBind(picker, "BackgroundColor3", "BG_TERTIARY")
    corner(picker, 8)
    local pkStroke = strokeOf(picker, nil, 1, 0)
    themeBind(pkStroke, "Color", "BORDER")
    pad(picker, 8, 8, 8, 8)
    local svBox = new("ImageButton", {
        Parent=picker, Size=UDim2.new(1,-26,0,150),
        Position=UDim2.new(0,0,0,0), AutoButtonColor=false,
        BackgroundColor3=Color3.new(1,0,0), BorderSizePixel=0,
        ZIndex=11, Image="",
    })
    corner(svBox, 4)
    new("UIGradient", {
        Parent=svBox, Rotation=0,
        Color=ColorSequence.new(Color3.new(1,1,1), Color3.new(1,0,0)),
    })
    local svDark = new("Frame", {
        Parent=svBox, Size=UDim2.new(1,0,1,0), BorderSizePixel=0, BackgroundColor3=Color3.new(0,0,0), ZIndex=12,
    })
    new("UIGradient", {
        Parent=svDark, Rotation=90,
        Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        }),
    })
    local svCursor = new("Frame", {
        Parent=svBox, Size=UDim2.fromOffset(10,10),
        BackgroundTransparency=1, BorderSizePixel=0, ZIndex=13,
    })
    new("UIStroke", {Parent=svCursor, Color=Color3.new(1,1,1), Thickness=2})
    corner(svCursor, 5)
    local hueBar = new("ImageButton", {
        Parent=picker, Size=UDim2.fromOffset(18,150),
        Position=UDim2.new(1,-18,0,0), AutoButtonColor=false,
        BorderSizePixel=0, BackgroundColor3=Color3.new(1,1,1), Image="", ZIndex=11,
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
        Position=UDim2.new(0,-2,0,0), BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0, ZIndex=12,
    })

    local optApi = {
        Type="ColorSlider", Name=optSettings.Name, Object=row,
        Hue=optSettings.DefaultHue or 0, Sat=optSettings.DefaultSat or 1,
        Value=optSettings.DefaultValue or 1, Opacity=optSettings.DefaultOpacity or 1,
        Function=optSettings.Function or function() end,
    }
    local function render()
        local h, s, v = optApi.Hue, optApi.Sat, optApi.Value
        local hueColor = Color3.fromHSV(h, 1, 1)
        svBox.BackgroundColor3 = hueColor
        local final = Color3.fromHSV(h, s, v)
        swatch.BackgroundColor3 = final
        svCursor.Position = UDim2.new(s, -5, 1 - v, -5)
        hueCursor.Position = UDim2.new(0, -2, h, -2)
    end
    optApi.SetHSV = function(_, h, s, v, o)
        optApi.Hue = h or optApi.Hue
        optApi.Sat = s or optApi.Sat
        optApi.Value = v or optApi.Value
        if o ~= nil then optApi.Opacity = o end
        render()
        pcall(optApi.Function, optApi.Hue, optApi.Sat, optApi.Value, optApi.Opacity)
    end
    optApi.Refresh = render

    local svDrag = false
    svBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            svDrag = true
        end
    end)
    local hueDrag = false
    hueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            hueDrag = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            svDrag = false; hueDrag = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if svDrag then
            local abs = svBox.AbsolutePosition; local sz = svBox.AbsoluteSize
            local s = math.clamp((input.Position.X - abs.X) / sz.X, 0, 1)
            local v = 1 - math.clamp((input.Position.Y - abs.Y) / sz.Y, 0, 1)
            optApi:SetHSV(nil, s, v, nil)
        end
        if hueDrag then
            local abs = hueBar.AbsolutePosition; local sz = hueBar.AbsoluteSize
            local h = math.clamp((input.Position.Y - abs.Y) / sz.Y, 0, 1)
            optApi:SetHSV(h, nil, nil, nil)
        end
    end)

    swatch.Activated:Connect(function()
        if picker.Visible then picker.Visible = false; return end
        local abs = swatch.AbsolutePosition; local sz = swatch.AbsoluteSize
        local mfPos = mainFrame.AbsolutePosition
        picker.Position = UDim2.fromOffset(abs.X - mfPos.X - 200, abs.Y - mfPos.Y + sz.Y + 4)
        picker.Visible = true
    end)
    UserInputService.InputBegan:Connect(function(input)
        if picker.Visible and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            local mp = UserInputService:GetMouseLocation()
            local abs = picker.AbsolutePosition; local sz = picker.AbsoluteSize
            local swAbs = swatch.AbsolutePosition; local swSz = swatch.AbsoluteSize
            local inPicker = mp.X >= abs.X and mp.X <= abs.X+sz.X and mp.Y >= abs.Y and mp.Y <= abs.Y+sz.Y
            local inSwatch = mp.X >= swAbs.X and mp.X <= swAbs.X+swSz.X and mp.Y >= swAbs.Y and mp.Y <= swAbs.Y+swSz.Y
            if not inPicker and not inSwatch then picker.Visible = false end
        end
    end)
    render()
    return optApi
end

local function makeBindVisual(moduleApi, optSettings)
    local row = new("Frame", {
        Parent=moduleApi._OptionContainer, Size=UDim2.new(1,0,0,32), BackgroundTransparency=1,
    })
    local label = new("TextLabel", {
        Parent=row, Size=UDim2.new(1,-90,1,0),
        BackgroundTransparency=1, Font=FONT, TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left, Text=tostring(optSettings.Name),
    })
    themeBind(label, "TextColor3", "TEXT_DIM")
    local btn = new("TextButton", {
        Parent=row, Size=UDim2.fromOffset(80,22),
        Position=UDim2.new(1,-84,0.5,-11), AutoButtonColor=false,
        BorderSizePixel=0, Font=FONT_MED, TextSize=11, Text="",
    })
    themeBind(btn, "BackgroundColor3", "BG_TERTIARY")
    themeBind(btn, "TextColor3", "TEXT_PRIMARY")
    corner(btn, 5)
    local bs = strokeOf(btn, nil, 1, 0.6)
    themeBind(bs, "Color", "BORDER_SOFT")

    local optApi = {
        Type="Bind", Name=optSettings.Name, Object=row,
        Value=optSettings.Default or "",
        Function=optSettings.Function or function() end,
    }
    local listening = false
    local function render()
        if listening then
            btn.Text = "..."
            btn.BackgroundColor3 = theme.ACCENT_DIM
        else
            btn.Text = optApi.Value == "" and "None" or tostring(optApi.Value)
            btn.BackgroundColor3 = theme.BG_TERTIARY
        end
    end
    optApi.SetValue = function(_, v) optApi.Value = v or ""; render(); pcall(optApi.Function, optApi.Value) end
    optApi.Refresh = render

    btn.Activated:Connect(function()
        listening = not listening; render()
    end)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not listening then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local k = input.KeyCode.Name
            if k == "Escape" or k == "Backspace" then
                optApi:SetValue("")
            else
                optApi:SetValue(k)
            end
            listening = false; render()
        end
    end)
    render()
    return optApi
end

local function makeTextListVisual(moduleApi, optSettings)
    local row = new("Frame", {
        Parent=moduleApi._OptionContainer, Size=UDim2.new(1,0,0,32), BackgroundTransparency=1,
    })
    local label = new("TextLabel", {
        Parent=row, Size=UDim2.new(1,-80,1,0), BackgroundTransparency=1,
        Font=FONT, TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left, Text=tostring(optSettings.Name),
    })
    themeBind(label, "TextColor3", "TEXT_DIM")
    local btn = new("TextButton", {
        Parent=row, Size=UDim2.fromOffset(72,22),
        Position=UDim2.new(1,-76,0.5,-11), AutoButtonColor=false,
        BorderSizePixel=0, Font=FONT_MED, TextSize=11, Text="Open List",
    })
    themeBind(btn, "BackgroundColor3", "BG_TERTIARY")
    themeBind(btn, "TextColor3", "TEXT_DIM")
    corner(btn, 5)
    local optApi = {
        Type="TextList", Name=optSettings.Name, Object=row,
        ListEnabled = optSettings.ListEnabled or {},
        Function=optSettings.Function or function() end,
    }
    optApi.Refresh = function() end
    btn.Activated:Connect(function()
        createNotification(optSettings.Name, "TextList UI coming v0.4 — values save via profile", 3)
    end)
    return optApi
end

local function makeButtonVisual(moduleApi, optSettings)
    local row = new("Frame", {
        Parent=moduleApi._OptionContainer, Size=UDim2.new(1,0,0,32), BackgroundTransparency=1,
    })
    local btn = new("TextButton", {
        Parent=row, Size=UDim2.new(1,0,1,-4),
        AutoButtonColor=false, BorderSizePixel=0,
        Font=FONT_MED, TextSize=12, Text=tostring(optSettings.Name),
    })
    themeBind(btn, "BackgroundColor3", "BG_TERTIARY")
    themeBind(btn, "TextColor3", "TEXT_PRIMARY")
    corner(btn, 6)
    local s = strokeOf(btn, nil, 1, 0.6)
    themeBind(s, "Color", "BORDER_SOFT")
    attachHover(btn,
        function() tween(btn, 0.12, {BackgroundColor3 = theme.ACCENT_DIM}) end,
        function() tween(btn, 0.12, {BackgroundColor3 = theme.BG_TERTIARY}) end)
    local optApi = {
        Type="Button", Name=optSettings.Name, Object=row,
        Function=optSettings.Function or function() end,
    }
    optApi.Activate = function() pcall(optApi.Function) end
    optApi.Refresh = function() end
    btn.Activated:Connect(function() optApi.Activate() end)
    return optApi
end

local mainapi = {}
mainapi.Categories = {}
mainapi.Modules = {}
mainapi.Libraries = {}
mainapi.Loaded = false
mainapi.Keybind = {"RightShift"}
mainapi.Cleanups = {}

function mainapi:CreateNotification(title, content, duration)
    return createNotification(title, content, duration)
end
function mainapi:Clean(thingOrFn) table.insert(self.Cleanups, thingOrFn); return thingOrFn end
function mainapi:ApplyCurrentLayout() applyLayout(currentLayoutName) end
function mainapi:SetLayout(name) applyLayout(name) end
function mainapi:SetTheme(name) applyTheme(name) end

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
    local out = {_theme = currentThemeName}
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
        if name ~= "_theme" and type(entry) == "table" then
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
        Parent=catList, Size=UDim2.new(1,0,0,36),
        BackgroundTransparency=1, BorderSizePixel=0,
    })
    themeBind(row, "BackgroundColor3", "ACCENT_DIM")
    corner(row, 7)
    local gOverlay = new("UIGradient", {
        Parent=row, Enabled=false, Rotation=45,
        Color=ColorSequence.new(theme.ACCENT, theme.ACCENT_2),
        Transparency=NumberSequence.new(0.5),
    })
    local indicator = new("Frame", {
        Parent=row, Size=UDim2.new(0,3,0,0),
        Position=UDim2.new(0,0,0.5,0), AnchorPoint=Vector2.new(0,0.5),
        BorderSizePixel=0,
    })
    themeBind(indicator, "BackgroundColor3", "ACCENT")
    corner(indicator, 2)
    local icon = new("ImageLabel", {
        Parent=row, Size=UDim2.fromOffset(18,18),
        Position=UDim2.new(0,14,0.5,-9), BackgroundTransparency=1,
        Image=CATEGORY_ICONS[catApi.Name] or "rbxassetid://10723345544",
    })
    themeBind(icon, "ImageColor3", "TEXT_DIM")
    local label = new("TextLabel", {
        Parent=row, Size=UDim2.new(1,-42,1,0),
        Position=UDim2.new(0,40,0,0), BackgroundTransparency=1,
        Font=FONT_MED, TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Left, Text=catApi.Name,
    })
    themeBind(label, "TextColor3", "TEXT_DIM")
    local btn = new("TextButton", {
        Parent=row, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="",
    })
    btn.Activated:Connect(function() selectCategory(catApi.Name) end)
    btn.MouseEnter:Connect(function()
        if currentCategoryName ~= catApi.Name then
            tween(label, 0.12, {TextColor3=theme.TEXT_PRIMARY})
            tween(icon, 0.12, {ImageColor3=theme.TEXT_PRIMARY})
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentCategoryName ~= catApi.Name then
            tween(label, 0.12, {TextColor3=theme.TEXT_DIM})
            tween(icon, 0.12, {ImageColor3=theme.TEXT_DIM})
        end
    end)

    catApi.Row = row
    catApi.Text = label
    catApi.IconImg = icon
    catApi.Indicator = indicator
    catApi.GradientOverlay = gOverlay

    function catApi:CreateModule(modSettings)
        local moduleApi = {
            Name=modSettings.Name, Tooltip=modSettings.Tooltip,
            Enabled=false, Function=modSettings.Function or function() end,
            Options={}, OptionOrder={}, Cleanups={},
        }

        local card = new("Frame", {
            Parent=moduleList, Size=UDim2.new(1,0,0,46),
            BorderSizePixel=0, AutomaticSize=Enum.AutomaticSize.Y,
            ClipsDescendants=true, Visible=false,
        })
        themeBind(card, "BackgroundColor3", "BG_SECONDARY")
        corner(card, 8)
        local cardStroke = strokeOf(card, nil, 1, 0.4)
        themeBind(cardStroke, "Color", "BORDER_SOFT")

        local header = new("TextButton", {
            Parent=card, Size=UDim2.new(1,0,0,46),
            BackgroundTransparency=1, AutoButtonColor=false, Text="",
        })
        local accentBar = new("Frame", {
            Parent=card, Size=UDim2.new(0,3,0,24),
            Position=UDim2.new(0,0,0,11), BorderSizePixel=0,
        })
        themeBind(accentBar, "BackgroundColor3", "BG_TERTIARY")
        corner(accentBar, 2)
        local nameLabel = new("TextLabel", {
            Parent=card, Size=UDim2.new(1,-100,0,18),
            Position=UDim2.new(0,14,0,9), BackgroundTransparency=1,
            Font=FONT_MED, TextSize=13,
            TextXAlignment=Enum.TextXAlignment.Left, Text=moduleApi.Name,
        })
        themeBind(nameLabel, "TextColor3", "TEXT_DIM")
        local descLabel = new("TextLabel", {
            Parent=card, Size=UDim2.new(1,-100,0,14),
            Position=UDim2.new(0,14,0,26), BackgroundTransparency=1,
            Font=FONT, TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left, Text=moduleApi.Tooltip or "",
        })
        themeBind(descLabel, "TextColor3", "TEXT_GHOST")
        local statusPill = new("Frame", {
            Parent=card, Size=UDim2.fromOffset(40,18),
            Position=UDim2.new(1,-52,0,14), BorderSizePixel=0,
        })
        themeBind(statusPill, "BackgroundColor3", "BG_TERTIARY")
        corner(statusPill, 9)
        local statusText = new("TextLabel", {
            Parent=statusPill, Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1, Font=FONT_BOLD, TextSize=9, Text="OFF",
        })
        themeBind(statusText, "TextColor3", "TEXT_DIM")
        local expandIcon = new("TextLabel", {
            Parent=card, Size=UDim2.fromOffset(16,16),
            Position=UDim2.new(1,-72,0,15), BackgroundTransparency=1,
            Font=FONT_BOLD, TextSize=10, Text="▶",
            Rotation=0, Visible=false,
        })
        themeBind(expandIcon, "TextColor3", "TEXT_GHOST")

        local optContainer = new("Frame", {
            Parent=card, Size=UDim2.new(1,-16,0,0),
            Position=UDim2.new(0,12,0,46), BackgroundTransparency=1,
            AutomaticSize=Enum.AutomaticSize.Y, Visible=false,
        })
        pad(optContainer, 4, 8, 12, 4)
        listLayout(optContainer, 4)
        local sep = new("Frame", {
            Parent=card, Size=UDim2.new(1,-28,0,1),
            Position=UDim2.new(0,14,0,46), BorderSizePixel=0,
            BackgroundTransparency=0.4, Visible=false,
        })
        themeBind(sep, "BackgroundColor3", "BORDER_SOFT")

        moduleApi.Frame = card
        moduleApi.Header = header
        moduleApi._OptionContainer = optContainer

        local expanded = false
        local function setExpanded(v)
            expanded = v
            optContainer.Visible = v
            sep.Visible = v
            tween(expandIcon, 0.18, {Rotation = v and 90 or 0})
        end
        header.Activated:Connect(function()
            local sh = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
            if sh and #moduleApi.OptionOrder > 0 then
                setExpanded(not expanded)
            else
                moduleApi:SetEnabled(not moduleApi.Enabled)
            end
        end)

        attachHover(header,
            function() tween(card, 0.12, {BackgroundColor3 = theme.BG_TERTIARY}) end,
            function() tween(card, 0.12, {BackgroundColor3 = theme.BG_SECONDARY}) end)

        local function renderState(animate)
            local on = moduleApi.Enabled
            local targetBar = on and theme.ACCENT or theme.BG_TERTIARY
            local targetName = on and theme.TEXT_PRIMARY or theme.TEXT_DIM
            local pillColor = on and theme.ACCENT_DIM or theme.BG_TERTIARY
            local pillTextColor = on and theme.TEXT_PRIMARY or theme.TEXT_DIM
            if animate then
                tween(accentBar, 0.15, {BackgroundColor3=targetBar, Size=on and UDim2.new(0,3,0,30) or UDim2.new(0,3,0,24), Position=on and UDim2.new(0,0,0,8) or UDim2.new(0,0,0,11)})
                tween(nameLabel, 0.15, {TextColor3=targetName})
                tween(statusPill, 0.15, {BackgroundColor3=pillColor})
                tween(statusText, 0.15, {TextColor3=pillTextColor})
            else
                accentBar.BackgroundColor3 = targetBar
                nameLabel.TextColor3 = targetName
                statusPill.BackgroundColor3 = pillColor
                statusText.TextColor3 = pillTextColor
            end
            statusText.Text = on and "ON" or "OFF"
            expandIcon.Visible = #moduleApi.OptionOrder > 0
        end

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

        function moduleApi:Clean(thingOrFn) table.insert(self.Cleanups, thingOrFn); return thingOrFn end

        function moduleApi:CreateToggle(s)
            local a = makeToggleVisual(self, s); self.Options[s.Name] = a; table.insert(self.OptionOrder, a)
            renderState(false); return a
        end
        function moduleApi:CreateSlider(s)
            local a = makeSliderVisual(self, s); self.Options[s.Name] = a; table.insert(self.OptionOrder, a)
            renderState(false); return a
        end
        function moduleApi:CreateColorSlider(s)
            local a = makeColorSliderVisual(self, s); self.Options[s.Name] = a; table.insert(self.OptionOrder, a)
            renderState(false); return a
        end
        function moduleApi:CreateDropdown(s)
            local a = makeDropdownVisual(self, s); self.Options[s.Name] = a; table.insert(self.OptionOrder, a)
            renderState(false); return a
        end
        function moduleApi:CreateBind(s)
            local a = makeBindVisual(self, s); self.Options[s.Name] = a; table.insert(self.OptionOrder, a)
            renderState(false); return a
        end
        function moduleApi:CreateTextList(s)
            local a = makeTextListVisual(self, s); self.Options[s.Name] = a; table.insert(self.OptionOrder, a)
            renderState(false); return a
        end
        function moduleApi:CreateButton(s)
            local a = makeButtonVisual(self, s); self.Options[s.Name] = a; table.insert(self.OptionOrder, a)
            renderState(false); return a
        end

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
        scaler.Scale = 0.92
        mainFrame.BackgroundTransparency = 1
        tween(scaler, 0.22, {Scale=1}, Enum.EasingStyle.Back)
        tween(mainFrame, 0.18, {BackgroundTransparency=0})
        tween(blur, 0.25, {Size=8})
    else
        tween(mainFrame, 0.15, {BackgroundTransparency=1})
        tween(scaler, 0.18, {Scale=0.92}, Enum.EasingStyle.Quint)
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
