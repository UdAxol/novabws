-- [Nova v2 UI lib v0.2] - Brand-new fresh-design GUI framework with serious polish.
-- Module API matches Vape's so source code from Vape/poopparty/CatV6 pastes in.

local boot = ...
local profile      = boot.profile or {}
local saveProfile  = boot.saveProfile or function() end
local fireWebhook  = boot.fireWebhook or function() end
local downloadFile = boot.downloadFile or function() return "" end

-- ============================================================================
-- Services
-- ============================================================================
local cloneref = cloneref or function(o) return o end
local Players          = cloneref(game:GetService("Players"))
local CoreGui          = cloneref(game:GetService("CoreGui"))
local TweenService     = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService       = cloneref(game:GetService("RunService"))
local Lighting         = cloneref(game:GetService("Lighting"))
local lplr             = Players.LocalPlayer

-- ============================================================================
-- Theme - deeper colors, softer gradients, vibrant accent
-- ============================================================================
local theme = {
    BG_DEEP      = Color3.fromRGB(13, 14, 24),    -- very dark blue-black (window bottom of gradient)
    BG_PRIMARY   = Color3.fromRGB(19, 21, 35),    -- main panel
    BG_SECONDARY = Color3.fromRGB(26, 28, 46),    -- left strip / row bg
    BG_TERTIARY  = Color3.fromRGB(36, 39, 60),    -- hover
    BG_QUARTERY  = Color3.fromRGB(44, 48, 72),    -- raised
    ACCENT       = Color3.fromRGB(138, 116, 255), -- vibrant violet
    ACCENT_2     = Color3.fromRGB(96, 184, 255),  -- cyan for gradient
    ACCENT_GLOW  = Color3.fromRGB(168, 136, 255), -- glow halo
    ACCENT_DIM   = Color3.fromRGB(80, 68, 160),
    TEXT_PRIMARY = Color3.fromRGB(235, 237, 246),
    TEXT_DIM     = Color3.fromRGB(130, 138, 165),
    TEXT_GHOST   = Color3.fromRGB(85, 92, 120),
    SUCCESS      = Color3.fromRGB(120, 230, 140),
    DANGER       = Color3.fromRGB(245, 100, 100),
    BORDER       = Color3.fromRGB(48, 52, 78),
    BORDER_SOFT  = Color3.fromRGB(36, 40, 60),
    OVERLAY      = Color3.fromRGB(0, 0, 0),       -- background dim
}

local FONT = Enum.Font.Gotham
local FONT_MED = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold

-- ============================================================================
-- UI helpers
-- ============================================================================
local function new(class, props, children)
    local inst = Instance.new(class)
    if props then for k, v in pairs(props) do if k ~= "Parent" then inst[k] = v end end end
    if children then for _, c in ipairs(children) do c.Parent = inst end end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end
local function corner(parent, r) return new("UICorner", {Parent=parent, CornerRadius=UDim.new(0, r or 6)}) end
local function stroke(parent, color, t, trans)
    return new("UIStroke", {
        Parent = parent,
        Color = color or theme.BORDER,
        Thickness = t or 1,
        Transparency = trans or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end
local function padding(parent, t, r, b, l)
    return new("UIPadding", {
        Parent = parent,
        PaddingTop=UDim.new(0,t or 0), PaddingRight=UDim.new(0,r or 0),
        PaddingBottom=UDim.new(0,b or 0), PaddingLeft=UDim.new(0,l or 0),
    })
end
local function listLayout(parent, pad, sortOrder, vAlign, hAlign)
    return new("UIListLayout", {
        Parent=parent, Padding=UDim.new(0, pad or 4), SortOrder=sortOrder or Enum.SortOrder.LayoutOrder,
        VerticalAlignment = vAlign or Enum.VerticalAlignment.Top,
        HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Left,
    })
end
local function gradient(parent, color1, color2, rotation)
    return new("UIGradient", {
        Parent = parent,
        Color = ColorSequence.new(color1, color2),
        Rotation = rotation or 90,
    })
end
local function tween(obj, time, props, style, dir)
    local ti = TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, ti, props)
    t:Play()
    return t
end

-- Drop shadow via ImageLabel with shadow asset (Roblox built-in)
local function dropShadow(parent, opacity)
    local s = new("ImageLabel", {
        Parent = parent,
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993", -- 9-slice soft shadow
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = opacity or 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Size = UDim2.new(1, 60, 1, 60),
        Position = UDim2.new(0, -30, 0, -30),
        ZIndex = -1,
    })
    return s
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

-- Hover tween helper: on hover, tween a property; on leave, restore.
local function attachHover(button, hoverProps, restoreProps, time)
    time = time or 0.15
    button.MouseEnter:Connect(function() tween(button, time, hoverProps) end)
    button.MouseLeave:Connect(function() tween(button, time, restoreProps) end)
end

-- ============================================================================
-- Category icons (Roblox built-in / common icon set, indexed by category name)
-- ============================================================================
local CATEGORY_ICONS = {
    Combat    = "rbxassetid://10709810948", -- crosshair-ish
    Blatant   = "rbxassetid://10723415903", -- eye / focus
    Render    = "rbxassetid://10723415903", -- (reuse eye for now)
    Utility   = "rbxassetid://10723345544", -- gear
    World     = "rbxassetid://10709810948", -- globe-ish (reuse)
    Inventory = "rbxassetid://10723417149", -- backpack
    Minigames = "rbxassetid://10723405292", -- joystick / play
    Kits      = "rbxassetid://10723345544", -- (reuse gear for now)
}

-- ============================================================================
-- ScreenGui setup
-- ============================================================================
local screenGui = new("ScreenGui", {
    Name = "NovaV2",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
    IgnoreGuiInset = true,
})
local parented = false
pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(screenGui) end
    if (protectgui or PROTECT_GUI) then (protectgui or PROTECT_GUI)(screenGui) end
    screenGui.Parent = CoreGui; parented = true
end)
if not parented then screenGui.Parent = lplr:WaitForChild("PlayerGui") end

-- ============================================================================
-- Background blur (toggles with window visibility)
-- ============================================================================
local blur = new("BlurEffect", {Parent = Lighting, Size = 0, Enabled = true})

-- ============================================================================
-- Main window
-- ============================================================================
local WINDOW_W, WINDOW_H = 580, 420
local mainFrame = new("Frame", {
    Name = "Main",
    Parent = screenGui,
    Size = UDim2.fromOffset(WINDOW_W, WINDOW_H),
    Position = UDim2.new(0.5, -WINDOW_W/2, 0.5, -WINDOW_H/2),
    BackgroundColor3 = theme.BG_PRIMARY,
    BorderSizePixel = 0,
    Visible = false,
    AnchorPoint = Vector2.new(0, 0),
})
corner(mainFrame, 12)
stroke(mainFrame, theme.BORDER, 1, 0.3)
dropShadow(mainFrame, 0.6)
-- Vertical gradient: slightly lighter at top, darker at bottom (premium depth)
local mainGrad = new("UIGradient", {
    Parent = mainFrame,
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.BG_PRIMARY),
        ColorSequenceKeypoint.new(1, theme.BG_DEEP),
    }),
})

local scaler = new("UIScale", {Parent = mainFrame, Scale = 1})

-- ============================================================================
-- Title bar
-- ============================================================================
local titleBar = new("Frame", {
    Parent = mainFrame,
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = theme.BG_SECONDARY,
    BorderSizePixel = 0,
})
corner(titleBar, 12)
-- Hide bottom corners on title bar (overlay strip)
new("Frame", {
    Parent = titleBar, Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 1, -12),
    BackgroundColor3 = theme.BG_SECONDARY, BorderSizePixel = 0,
})

-- Accent bar at very top (rainbow accent strip)
local accentStrip = new("Frame", {
    Parent = titleBar, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = theme.ACCENT, BorderSizePixel = 0,
})
new("UIGradient", {
    Parent = accentStrip, Rotation = 0,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.ACCENT),
        ColorSequenceKeypoint.new(0.5, theme.ACCENT_2),
        ColorSequenceKeypoint.new(1, theme.ACCENT),
    }),
})

-- Logo / title with gradient
local titleText = new("TextLabel", {
    Parent = titleBar,
    Size = UDim2.new(0, 140, 1, -8),
    Position = UDim2.new(0, 18, 0, 4),
    BackgroundTransparency = 1,
    Font = FONT_BOLD,
    TextSize = 22,
    TextColor3 = theme.TEXT_PRIMARY,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
    Text = "Nova",
})
new("UIGradient", {
    Parent = titleText, Rotation = 25,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.TEXT_PRIMARY),
        ColorSequenceKeypoint.new(1, theme.ACCENT),
    }),
})
-- v2 chip
local versionChip = new("Frame", {
    Parent = titleBar,
    Size = UDim2.fromOffset(38, 18),
    Position = UDim2.new(0, 78, 0.5, -9),
    BackgroundColor3 = theme.ACCENT_DIM,
    BorderSizePixel = 0,
})
corner(versionChip, 9)
new("TextLabel", {
    Parent = versionChip,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Font = FONT_BOLD, TextSize = 11,
    TextColor3 = theme.TEXT_PRIMARY,
    Text = "v2",
})

-- User chip (right side)
local userChip = new("TextLabel", {
    Parent = titleBar,
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(1, -218, 0, 0),
    BackgroundTransparency = 1,
    Font = FONT_MED, TextSize = 13,
    TextColor3 = theme.TEXT_DIM,
    TextXAlignment = Enum.TextXAlignment.Right,
    Text = lplr.Name,
})

makeDraggable(titleBar, mainFrame)

-- ============================================================================
-- Left: category strip with icons
-- ============================================================================
local STRIP_W = 150
local catStrip = new("Frame", {
    Parent = mainFrame,
    Size = UDim2.new(0, STRIP_W, 1, -48),
    Position = UDim2.new(0, 0, 0, 48),
    BackgroundColor3 = theme.BG_SECONDARY,
    BorderSizePixel = 0,
})
new("UIGradient", {
    Parent = catStrip, Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.BG_SECONDARY),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 24, 40)),
    }),
})
-- Subtle right-border accent
new("Frame", {
    Parent = catStrip, Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0),
    BackgroundColor3 = theme.BORDER_SOFT, BorderSizePixel = 0,
})

local catList = new("ScrollingFrame", {
    Parent = catStrip,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 0,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(0, 0, 0, 0),
})
listLayout(catList, 4)
padding(catList, 10, 10, 10, 10)

-- ============================================================================
-- Right: module page
-- ============================================================================
local modulePage = new("Frame", {
    Parent = mainFrame,
    Size = UDim2.new(1, -STRIP_W, 1, -48),
    Position = UDim2.new(0, STRIP_W, 0, 48),
    BackgroundTransparency = 1,
})

-- Page header with category name + search
local pageHeader = new("Frame", {
    Parent = modulePage,
    Size = UDim2.new(1, 0, 0, 56),
    BackgroundTransparency = 1,
})
local pageTitle = new("TextLabel", {
    Parent = pageHeader,
    Size = UDim2.new(0, 200, 0, 24),
    Position = UDim2.new(0, 16, 0, 14),
    BackgroundTransparency = 1,
    Font = FONT_BOLD, TextSize = 18,
    TextColor3 = theme.TEXT_PRIMARY,
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = "Combat",
})
local pageSubtitle = new("TextLabel", {
    Parent = pageHeader,
    Size = UDim2.new(0, 200, 0, 14),
    Position = UDim2.new(0, 16, 0, 36),
    BackgroundTransparency = 1,
    Font = FONT, TextSize = 11,
    TextColor3 = theme.TEXT_GHOST,
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = "0 modules",
})

-- Search box (top-right of header)
local searchBg = new("Frame", {
    Parent = pageHeader,
    Size = UDim2.fromOffset(160, 28),
    Position = UDim2.new(1, -176, 0, 14),
    BackgroundColor3 = theme.BG_SECONDARY,
    BorderSizePixel = 0,
})
corner(searchBg, 6)
stroke(searchBg, theme.BORDER_SOFT, 1)
local searchBox = new("TextBox", {
    Parent = searchBg,
    Size = UDim2.new(1, -16, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Font = FONT, TextSize = 12,
    TextColor3 = theme.TEXT_PRIMARY,
    PlaceholderColor3 = theme.TEXT_GHOST,
    PlaceholderText = "Search...",
    Text = "",
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
})

-- Module list (scrolling)
local moduleList = new("ScrollingFrame", {
    Parent = modulePage,
    Size = UDim2.new(1, 0, 1, -56),
    Position = UDim2.new(0, 0, 0, 56),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = theme.ACCENT,
    ScrollBarImageTransparency = 0.4,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(0, 0, 0, 0),
})
listLayout(moduleList, 6)
padding(moduleList, 4, 16, 16, 16)

-- Empty-state label
local emptyState = new("TextLabel", {
    Parent = modulePage,
    Size = UDim2.new(1, -32, 0, 100),
    Position = UDim2.new(0, 16, 0, 100),
    BackgroundTransparency = 1,
    Font = FONT, TextSize = 13,
    TextColor3 = theme.TEXT_GHOST,
    TextWrapped = true,
    Text = "No modules in this category yet.\nMore coming in v0.3+.",
    Visible = false,
})

-- ============================================================================
-- Notifications (top-right, slide-in)
-- ============================================================================
local notifStack = new("Frame", {
    Parent = screenGui,
    Size = UDim2.new(0, 320, 1, -40),
    Position = UDim2.new(1, -340, 0, 20),
    BackgroundTransparency = 1,
})
local notifLayout = listLayout(notifStack, 8, Enum.SortOrder.LayoutOrder)
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right

local function createNotification(title, content, duration)
    duration = duration or 4
    local frame = new("Frame", {
        Parent = notifStack,
        Size = UDim2.new(1, 0, 0, 62),
        BackgroundColor3 = theme.BG_PRIMARY,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
    })
    corner(frame, 8)
    stroke(frame, theme.BORDER, 1, 0.3)
    new("UIGradient", {
        Parent = frame, Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.BG_PRIMARY),
            ColorSequenceKeypoint.new(1, theme.BG_DEEP),
        }),
    })
    -- Accent strip on left
    local strip = new("Frame", {
        Parent = frame, Size = UDim2.new(0, 3, 1, -16), Position = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = theme.ACCENT, BorderSizePixel = 0,
    })
    corner(strip, 2)
    -- Title
    new("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -28, 0, 18),
        Position = UDim2.new(0, 20, 0, 10),
        BackgroundTransparency = 1,
        Font = FONT_BOLD, TextSize = 13,
        TextColor3 = theme.TEXT_PRIMARY,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = tostring(title),
    })
    -- Content
    new("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -28, 1, -32),
        Position = UDim2.new(0, 20, 0, 28),
        BackgroundTransparency = 1,
        Font = FONT, TextSize = 11,
        TextColor3 = theme.TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Text = tostring(content),
    })
    -- Slide-in
    frame.Position = UDim2.new(1, 50, 0, 0)
    tween(frame, 0.3, {BackgroundTransparency = 0, Position = UDim2.new(0, 0, 0, 0)}, Enum.EasingStyle.Quint)
    task.delay(duration, function()
        if frame.Parent then
            tween(frame, 0.25, {BackgroundTransparency = 1, Position = UDim2.new(1, 50, 0, 0)})
            task.wait(0.3); frame:Destroy()
        end
    end)
    return frame
end

-- ============================================================================
-- Module cards + sub-options
-- ============================================================================

-- Categories + current selection
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
    local searchTxt = (searchBox.Text or ""):lower()
    for _, mod in ipairs(cat.ModuleOrder or {}) do
        if mod.Frame then
            local match = (searchTxt == "") or string.find(mod.Name:lower(), searchTxt, 1, true) ~= nil
            mod.Frame.Visible = match
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
            tween(c.Indicator, 0.18, {Size = selected and UDim2.new(0, 3, 0, 22) or UDim2.new(0, 3, 0, 0)})
            if selected then
                -- Apply gradient to selected
                c.GradientOverlay.Enabled = true
            else
                c.GradientOverlay.Enabled = false
            end
        end
    end
    refreshModuleList()
end

-- ============================================================================
-- Sub-option visuals
-- ============================================================================
local function makeToggleVisual(moduleApi, optSettings)
    local row = new("Frame", {
        Parent = moduleApi._OptionContainer,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
    })
    new("TextLabel", {
        Parent = row,
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Font = FONT, TextSize = 12,
        TextColor3 = theme.TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = tostring(optSettings.Name),
    })
    local pill = new("Frame", {
        Parent = row,
        Size = UDim2.fromOffset(34, 18),
        Position = UDim2.new(1, -38, 0.5, -9),
        BackgroundColor3 = theme.BG_TERTIARY,
        BorderSizePixel = 0,
    })
    corner(pill, 9)
    local dot = new("Frame", {
        Parent = pill,
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(0, 2, 0.5, -7),
        BackgroundColor3 = theme.TEXT_DIM,
        BorderSizePixel = 0,
    })
    corner(dot, 7)

    local optApi = {
        Type = "Toggle", Name = optSettings.Name,
        Enabled = optSettings.Default == true,
        Object = row,
        Function = optSettings.Function or function() end,
    }
    local function render(animate)
        local on = optApi.Enabled
        local pillCol = on and theme.ACCENT or theme.BG_TERTIARY
        local dotCol = on and theme.TEXT_PRIMARY or theme.TEXT_DIM
        local dotPos = on and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        if animate then
            tween(pill, 0.18, {BackgroundColor3 = pillCol})
            tween(dot, 0.18, {BackgroundColor3 = dotCol, Position = dotPos})
        else
            pill.BackgroundColor3 = pillCol; dot.BackgroundColor3 = dotCol; dot.Position = dotPos
        end
    end
    optApi.SetEnabled = function(_, v) optApi.Enabled = v and true or false; render(true); pcall(optApi.Function, optApi.Enabled) end
    optApi.Refresh = function() render(false) end
    local btn = new("TextButton", {Parent = row, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""})
    btn.Activated:Connect(function() optApi:SetEnabled(not optApi.Enabled) end)
    render(false)
    return optApi
end

local function makeStub(type_, optSettings)
    local api = {
        Type = type_, Name = optSettings.Name,
        Function = optSettings.Function or function() end,
    }
    if type_ == "Slider" then
        api.Value = optSettings.Default or optSettings.Min or 0
        api.Min, api.Max = optSettings.Min or 0, optSettings.Max or 100
    elseif type_ == "ColorSlider" then
        api.Hue = optSettings.DefaultHue or 0
        api.Sat = optSettings.DefaultSat or 1
        api.Value = optSettings.DefaultValue or 1
        api.Opacity = optSettings.DefaultOpacity or 1
    elseif type_ == "Dropdown" then
        api.Value = optSettings.Default or (optSettings.List and optSettings.List[1]) or ""
        api.List = optSettings.List or {}
    elseif type_ == "Bind" then
        api.Value = optSettings.Default or ""
    elseif type_ == "TextList" then
        api.ListEnabled = optSettings.ListEnabled or {}
    elseif type_ == "Button" then
        api.Activate = function() pcall(api.Function) end
    end
    return api
end

-- ============================================================================
-- mainapi / categoryapi / moduleapi
-- ============================================================================
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

function mainapi:Clean(thingOrFn)
    table.insert(self.Cleanups, thingOrFn); return thingOrFn
end

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
        local mod = mainapi.Modules[name]
        if mod then
            if entry.Options then
                for optName, optState in pairs(entry.Options) do
                    local opt = mod.Options and mod.Options[optName]
                    if opt then
                        if opt.Type == "Toggle" and optState.Enabled ~= nil then opt:SetEnabled(optState.Enabled) end
                        if opt.Type == "Slider" and optState.Value ~= nil then opt.Value = optState.Value; pcall(opt.Function, opt.Value) end
                        if opt.Type == "ColorSlider" then
                            opt.Hue = optState.Hue or opt.Hue; opt.Sat = optState.Sat or opt.Sat
                            opt.Value = optState.Value or opt.Value; opt.Opacity = optState.Opacity or opt.Opacity
                            pcall(opt.Function, opt.Hue, opt.Sat, opt.Value, opt.Opacity)
                        end
                        if opt.Type == "Dropdown" and optState.Value ~= nil then opt.Value = optState.Value; pcall(opt.Function, opt.Value) end
                        if opt.Type == "Bind" and optState.Value ~= nil then opt.Value = optState.Value end
                        if opt.Type == "TextList" and optState.ListEnabled then opt.ListEnabled = optState.ListEnabled; pcall(opt.Function, opt.ListEnabled) end
                    end
                end
            end
            if entry.Enabled ~= nil then mod:SetEnabled(entry.Enabled) end
        end
    end
    mainapi.Loaded = true
end

function mainapi:Save() saveProfile(self:Serialize()) end

function mainapi:CreateCategory(catSettings)
    local catApi = {Name = catSettings.Name, Modules = {}, ModuleOrder = {}}

    -- Row in left strip
    local row = new("Frame", {
        Parent = catList,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = theme.ACCENT_DIM,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })
    corner(row, 7)
    -- Selected gradient overlay (initially hidden via Enabled=false)
    local gOverlay = new("UIGradient", {
        Parent = row, Enabled = false, Rotation = 45,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.ACCENT),
            ColorSequenceKeypoint.new(1, theme.ACCENT_2),
        }),
        Transparency = NumberSequence.new(0.5),
    })
    -- Left indicator strip (grows when selected)
    local indicator = new("Frame", {
        Parent = row,
        Size = UDim2.new(0, 3, 0, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = theme.ACCENT,
        BorderSizePixel = 0,
    })
    corner(indicator, 2)
    -- Icon (subtle)
    local icon = new("ImageLabel", {
        Parent = row,
        Size = UDim2.fromOffset(18, 18),
        Position = UDim2.new(0, 14, 0.5, -9),
        BackgroundTransparency = 1,
        Image = CATEGORY_ICONS[catApi.Name] or "rbxassetid://10723345544",
        ImageColor3 = theme.TEXT_DIM,
    })
    -- Label
    local label = new("TextLabel", {
        Parent = row,
        Size = UDim2.new(1, -42, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        BackgroundTransparency = 1,
        Font = FONT_MED, TextSize = 13,
        TextColor3 = theme.TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = catApi.Name,
    })
    -- Click target
    local btn = new("TextButton", {
        Parent = row,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
    })
    btn.Activated:Connect(function() selectCategory(catApi.Name) end)
    -- Hover
    btn.MouseEnter:Connect(function()
        if currentCategoryName ~= catApi.Name then
            tween(label, 0.12, {TextColor3 = theme.TEXT_PRIMARY})
            tween(icon, 0.12, {ImageColor3 = theme.TEXT_PRIMARY})
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentCategoryName ~= catApi.Name then
            tween(label, 0.12, {TextColor3 = theme.TEXT_DIM})
            tween(icon, 0.12, {ImageColor3 = theme.TEXT_DIM})
        end
    end)

    catApi.Row = row
    catApi.Text = label
    catApi.IconImg = icon
    catApi.Indicator = indicator
    catApi.GradientOverlay = gOverlay

    function catApi:CreateModule(modSettings)
        local moduleApi = {
            Name = modSettings.Name,
            Tooltip = modSettings.Tooltip,
            Enabled = false,
            Function = modSettings.Function or function() end,
            Options = {},
            OptionOrder = {},
            Cleanups = {},
        }

        -- Card
        local card = new("Frame", {
            Parent = moduleList,
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundColor3 = theme.BG_SECONDARY,
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            ClipsDescendants = true,
            Visible = false,
        })
        corner(card, 8)
        stroke(card, theme.BORDER_SOFT, 1, 0.4)

        -- Header (the clickable row)
        local header = new("TextButton", {
            Parent = card,
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Text = "",
        })
        -- Left accent strip (becomes accent when enabled)
        local accentBar = new("Frame", {
            Parent = card,
            Size = UDim2.new(0, 3, 0, 22),
            Position = UDim2.new(0, 0, 0, 10),
            BackgroundColor3 = theme.BG_TERTIARY,
            BorderSizePixel = 0,
        })
        corner(accentBar, 2)
        -- Name
        local nameLabel = new("TextLabel", {
            Parent = card,
            Size = UDim2.new(1, -100, 0, 18),
            Position = UDim2.new(0, 14, 0, 8),
            BackgroundTransparency = 1,
            Font = FONT_MED, TextSize = 13,
            TextColor3 = theme.TEXT_DIM,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = moduleApi.Name,
        })
        -- Tooltip
        local descLabel = new("TextLabel", {
            Parent = card,
            Size = UDim2.new(1, -100, 0, 14),
            Position = UDim2.new(0, 14, 0, 24),
            BackgroundTransparency = 1,
            Font = FONT, TextSize = 10,
            TextColor3 = theme.TEXT_GHOST,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = moduleApi.Tooltip or "",
        })
        -- Status pill on the right
        local statusPill = new("Frame", {
            Parent = card,
            Size = UDim2.fromOffset(38, 18),
            Position = UDim2.new(1, -50, 0, 12),
            BackgroundColor3 = theme.BG_TERTIARY,
            BorderSizePixel = 0,
        })
        corner(statusPill, 9)
        local statusText = new("TextLabel", {
            Parent = statusPill,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Font = FONT_BOLD, TextSize = 9,
            TextColor3 = theme.TEXT_DIM,
            Text = "OFF",
        })

        -- Option container (expanded view)
        local optContainer = new("Frame", {
            Parent = card,
            Size = UDim2.new(1, -16, 0, 0),
            Position = UDim2.new(0, 12, 0, 42),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = false,
        })
        padding(optContainer, 4, 8, 10, 4)
        listLayout(optContainer, 2)
        -- Separator above the option container
        local sep = new("Frame", {
            Parent = card,
            Size = UDim2.new(1, -28, 0, 1),
            Position = UDim2.new(0, 14, 0, 42),
            BackgroundColor3 = theme.BORDER_SOFT,
            BorderSizePixel = 0,
            BackgroundTransparency = 0.4,
            Visible = false,
        })

        moduleApi.Frame = card
        moduleApi.Header = header
        moduleApi._OptionContainer = optContainer

        -- Click semantics: regular click = toggle module. Shift+click = expand options.
        local expanded = false
        local function setExpanded(v)
            expanded = v
            optContainer.Visible = v
            sep.Visible = v
        end
        header.Activated:Connect(function()
            local sh = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
            if sh and #moduleApi.OptionOrder > 0 then
                setExpanded(not expanded)
            else
                moduleApi:SetEnabled(not moduleApi.Enabled)
            end
        end)

        -- Hover
        attachHover(header, {BackgroundTransparency = 0.85}, {BackgroundTransparency = 1})
        header.BackgroundColor3 = theme.BG_TERTIARY

        local function renderState(animate)
            local on = moduleApi.Enabled
            local targetBar = on and theme.ACCENT or theme.BG_TERTIARY
            local targetName = on and theme.TEXT_PRIMARY or theme.TEXT_DIM
            local pillColor = on and theme.ACCENT_DIM or theme.BG_TERTIARY
            local pillTextColor = on and theme.TEXT_PRIMARY or theme.TEXT_DIM
            if animate then
                tween(accentBar, 0.15, {BackgroundColor3 = targetBar})
                tween(nameLabel, 0.15, {TextColor3 = targetName})
                tween(statusPill, 0.15, {BackgroundColor3 = pillColor})
                tween(statusText, 0.15, {TextColor3 = pillTextColor})
            else
                accentBar.BackgroundColor3 = targetBar
                nameLabel.TextColor3 = targetName
                statusPill.BackgroundColor3 = pillColor
                statusText.TextColor3 = pillTextColor
            end
            statusText.Text = on and "ON" or "OFF"
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
            local optApi = makeToggleVisual(self, s)
            self.Options[s.Name] = optApi
            table.insert(self.OptionOrder, optApi)
            return optApi
        end
        function moduleApi:CreateSlider(s)      local a = makeStub("Slider", s);      self.Options[s.Name] = a; return a end
        function moduleApi:CreateColorSlider(s) local a = makeStub("ColorSlider", s); self.Options[s.Name] = a; return a end
        function moduleApi:CreateDropdown(s)    local a = makeStub("Dropdown", s);    self.Options[s.Name] = a; return a end
        function moduleApi:CreateBind(s)        local a = makeStub("Bind", s);        self.Options[s.Name] = a; return a end
        function moduleApi:CreateTextList(s)    local a = makeStub("TextList", s);    self.Options[s.Name] = a; return a end
        function moduleApi:CreateButton(s)      local a = makeStub("Button", s);      self.Options[s.Name] = a; return a end

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

-- Default categories (canonical order)
for _, n in ipairs({"Combat", "Blatant", "Render", "Utility", "World", "Inventory", "Minigames", "Kits"}) do
    mainapi:CreateCategory({Name = n})
end

-- ============================================================================
-- Open/close with animation + background blur
-- ============================================================================
local function setOpen(open)
    if open then
        mainFrame.Visible = true
        scaler.Scale = 0.92
        mainFrame.BackgroundTransparency = 1
        tween(scaler, 0.22, {Scale = 1}, Enum.EasingStyle.Back)
        tween(mainFrame, 0.18, {BackgroundTransparency = 0})
        tween(blur, 0.25, {Size = 8})
    else
        tween(mainFrame, 0.15, {BackgroundTransparency = 1})
        tween(scaler, 0.18, {Scale = 0.92}, Enum.EasingStyle.Quint)
        tween(blur, 0.2, {Size = 0})
        task.delay(0.18, function() mainFrame.Visible = false end)
    end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        for _, k in ipairs(mainapi.Keybind) do
            if input.KeyCode == Enum.KeyCode[k] then
                setOpen(not mainFrame.Visible)
                return
            end
        end
    end
end)

return mainapi
