-- [Nova v2 UI lib] - Brand-new fresh-design GUI framework.
-- v0.1 scope: working Toggle visuals + functional stubs for Slider/ColorSlider/
-- Dropdown/Bind/TextList/Button so modules can port unchanged. Visuals for the
-- stubs come in v0.2-0.3. The module API matches Vape's signature so source code
-- from Vape/poopparty/CatV6 pastes in.

local boot = ...  -- {profile, saveProfile, httpReq, downloadFile, getcustomasset, ...}
local profile      = boot.profile or {}
local saveProfile  = boot.saveProfile or function() end
local fireWebhook  = boot.fireWebhook or function() end
local downloadFile = boot.downloadFile or function() return "" end

-- ============================================================================
-- Services + locals
-- ============================================================================
local cloneref = cloneref or function(o) return o end
local Players          = cloneref(game:GetService("Players"))
local CoreGui          = cloneref(game:GetService("CoreGui"))
local TweenService     = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService       = cloneref(game:GetService("RunService"))
local lplr             = Players.LocalPlayer

-- ============================================================================
-- Theme
-- ============================================================================
local theme = {
    BG_PRIMARY   = Color3.fromRGB(20, 22, 36),    -- main panel
    BG_SECONDARY = Color3.fromRGB(28, 30, 48),    -- list rows
    BG_TERTIARY  = Color3.fromRGB(36, 39, 60),    -- hover
    ACCENT       = Color3.fromRGB(123, 104, 238), -- purple
    ACCENT_DIM   = Color3.fromRGB(80, 68, 160),
    TEXT_PRIMARY = Color3.fromRGB(230, 232, 240),
    TEXT_DIM     = Color3.fromRGB(140, 145, 165),
    SUCCESS      = Color3.fromRGB(110, 230, 130),
    DANGER       = Color3.fromRGB(230, 110, 110),
    BORDER       = Color3.fromRGB(50, 54, 78),
}

local FONT = Enum.Font.Gotham
local FONT_BOLD = Enum.Font.GothamBold

-- ============================================================================
-- UI helpers
-- ============================================================================
local function new(class, props, children)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            if k ~= "Parent" then inst[k] = v end
        end
    end
    if children then
        for _, c in ipairs(children) do c.Parent = inst end
    end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function corner(parent, radius)
    return new("UICorner", {Parent = parent, CornerRadius = UDim.new(0, radius or 6)})
end

local function stroke(parent, color, thickness)
    return new("UIStroke", {
        Parent = parent,
        Color = color or theme.BORDER,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function padding(parent, t, r, b, l)
    return new("UIPadding", {
        Parent = parent,
        PaddingTop    = UDim.new(0, t or 0),
        PaddingRight  = UDim.new(0, r or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0),
    })
end

local function listLayout(parent, padding, sortOrder)
    return new("UIListLayout", {
        Parent = parent,
        Padding = UDim.new(0, padding or 4),
        SortOrder = sortOrder or Enum.SortOrder.LayoutOrder,
    })
end

local function makeDraggable(handle, target)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- ============================================================================
-- ScreenGui setup (with executor-fallback parent)
-- ============================================================================
local screenGui = new("ScreenGui", {
    Name = "NovaV2",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
})
-- Try CoreGui (most executors expose protectgui); fall back to PlayerGui.
local parented = false
pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(screenGui) end
    if (protectgui or PROTECT_GUI) then (protectgui or PROTECT_GUI)(screenGui) end
    screenGui.Parent = CoreGui
    parented = true
end)
if not parented then screenGui.Parent = lplr:WaitForChild("PlayerGui") end

-- ============================================================================
-- Main window
-- ============================================================================
local WINDOW_W, WINDOW_H = 540, 380
local mainFrame = new("Frame", {
    Name = "Main",
    Parent = screenGui,
    Size = UDim2.fromOffset(WINDOW_W, WINDOW_H),
    Position = UDim2.new(0.5, -WINDOW_W/2, 0.5, -WINDOW_H/2),
    BackgroundColor3 = theme.BG_PRIMARY,
    BorderSizePixel = 0,
    Visible = false,
})
corner(mainFrame, 10)
stroke(mainFrame, theme.BORDER)

-- Title bar
local titleBar = new("Frame", {
    Parent = mainFrame,
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = theme.BG_SECONDARY,
    BorderSizePixel = 0,
})
corner(titleBar, 10)
-- Bottom edge of title bar shouldn't round
new("Frame", {
    Parent = titleBar,
    Size = UDim2.new(1, 0, 0, 10),
    Position = UDim2.new(0, 0, 1, -10),
    BackgroundColor3 = theme.BG_SECONDARY,
    BorderSizePixel = 0,
})
local title = new("TextLabel", {
    Parent = titleBar,
    Size = UDim2.new(1, -50, 1, 0),
    Position = UDim2.new(0, 14, 0, 0),
    BackgroundTransparency = 1,
    Font = FONT_BOLD,
    TextSize = 16,
    TextColor3 = theme.TEXT_PRIMARY,
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = "Nova v2",
})
local subtitle = new("TextLabel", {
    Parent = titleBar,
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0, 80, 0, 0),
    BackgroundTransparency = 1,
    Font = FONT,
    TextSize = 12,
    TextColor3 = theme.TEXT_DIM,
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = lplr.Name,
})

makeDraggable(titleBar, mainFrame)

-- Left: category strip
local catStrip = new("Frame", {
    Parent = mainFrame,
    Size = UDim2.new(0, 130, 1, -40),
    Position = UDim2.new(0, 0, 0, 40),
    BackgroundColor3 = theme.BG_SECONDARY,
    BorderSizePixel = 0,
})
local catList = new("ScrollingFrame", {
    Parent = catStrip,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = theme.ACCENT,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(0, 0, 0, 0),
})
listLayout(catList, 2)
padding(catList, 8, 6, 8, 6)

-- Right: module page
local modulePage = new("Frame", {
    Parent = mainFrame,
    Size = UDim2.new(1, -130, 1, -40),
    Position = UDim2.new(0, 130, 0, 40),
    BackgroundTransparency = 1,
})

-- (single shared scrolling module list inside the page; categories swap its contents)
local moduleList = new("ScrollingFrame", {
    Parent = modulePage,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = theme.ACCENT,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(0, 0, 0, 0),
})
listLayout(moduleList, 6)
padding(moduleList, 10, 10, 10, 10)

-- ============================================================================
-- Notification stack (top-right)
-- ============================================================================
local notifStack = new("Frame", {
    Parent = screenGui,
    Size = UDim2.new(0, 320, 1, -20),
    Position = UDim2.new(1, -330, 0, 10),
    BackgroundTransparency = 1,
})
listLayout(notifStack, 6, Enum.SortOrder.LayoutOrder)
-- Bottom-up stacking
notifStack.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifStack.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right

local function createNotification(title, content, duration)
    duration = duration or 4
    local frame = new("Frame", {
        Parent = notifStack,
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = theme.BG_PRIMARY,
        BorderSizePixel = 0,
    })
    corner(frame, 8)
    stroke(frame, theme.BORDER)
    new("Frame", {
        Parent = frame,
        Size = UDim2.new(0, 3, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundColor3 = theme.ACCENT,
        BorderSizePixel = 0,
    })
    new("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 14, 0, 6),
        BackgroundTransparency = 1,
        Font = FONT_BOLD,
        TextSize = 13,
        TextColor3 = theme.TEXT_PRIMARY,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = tostring(title),
    })
    new("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -20, 1, -26),
        Position = UDim2.new(0, 14, 0, 26),
        BackgroundTransparency = 1,
        Font = FONT,
        TextSize = 12,
        TextColor3 = theme.TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Text = tostring(content),
    })
    task.delay(duration, function()
        if frame.Parent then
            TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            task.wait(0.3)
            frame:Destroy()
        end
    end)
    return frame
end

-- ============================================================================
-- Categories + modules + options registry
-- ============================================================================
local categories = {}         -- ordered list of category api objects
local currentCategoryName  -- selected category (string)

local function refreshModuleList()
    -- Hide everything, then show modules in the current category
    for _, child in ipairs(moduleList:GetChildren()) do
        if child:IsA("Frame") then child.Visible = false end
    end
    if not currentCategoryName then return end
    local cat
    for _, c in ipairs(categories) do
        if c.Name == currentCategoryName then cat = c; break end
    end
    if not cat then return end
    for _, mod in ipairs(cat.ModuleOrder or {}) do
        if mod.Frame then mod.Frame.Visible = true end
    end
end

local function selectCategory(name)
    currentCategoryName = name
    -- Update visuals of category buttons
    for _, c in ipairs(categories) do
        if c.Button then
            local selected = (c.Name == name)
            c.Button.BackgroundColor3 = selected and theme.ACCENT_DIM or theme.BG_SECONDARY
            c.Button.TextColor3 = selected and theme.TEXT_PRIMARY or theme.TEXT_DIM
        end
    end
    refreshModuleList()
end

-- ============================================================================
-- Toggle / Slider / etc. constructors (attached to a module's option frame)
-- ============================================================================
local function makeToggleVisual(moduleApi, optSettings)
    -- Inserts a small row in the module's expanded sub-options section.
    local row = new("Frame", {
        Parent = moduleApi._OptionContainer,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
    })
    new("TextLabel", {
        Parent = row,
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Font = FONT,
        TextSize = 12,
        TextColor3 = theme.TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = tostring(optSettings.Name),
    })
    local pill = new("Frame", {
        Parent = row,
        Size = UDim2.new(0, 36, 0, 18),
        Position = UDim2.new(1, -40, 0.5, -9),
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
        Type = "Toggle",
        Name = optSettings.Name,
        Enabled = optSettings.Default == true,
        Object = row,
        Function = optSettings.Function or function() end,
    }
    local function render()
        local on = optApi.Enabled
        pill.BackgroundColor3 = on and theme.ACCENT or theme.BG_TERTIARY
        dot.BackgroundColor3 = on and theme.TEXT_PRIMARY or theme.TEXT_DIM
        TweenService:Create(dot, TweenInfo.new(0.15), {
            Position = on and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
        }):Play()
    end
    optApi.SetEnabled = function(_, v) optApi.Enabled = v and true or false; render(); pcall(optApi.Function, optApi.Enabled) end
    optApi.Refresh = render
    -- Click toggle
    local btn = new("TextButton", {
        Parent = row,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
    })
    btn.Activated:Connect(function() optApi:SetEnabled(not optApi.Enabled) end)
    render()
    return optApi
end

-- Functional-no-visual stubs for the rest. Modules can read/write .Value/.Enabled
-- and the saved profile picks up the state; visuals come in v0.2.
local function makeStub(type_, defaultGetter, optSettings)
    local api = {
        Type = type_,
        Name = optSettings.Name,
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
-- mainapi / categoryapi / moduleapi construction
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
    table.insert(self.Cleanups, thingOrFn)
    return thingOrFn
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
    shared.nova = nil
end

function mainapi:Serialize()
    local out = {}
    for _, m in pairs(self.Modules) do
        local entry = { Enabled = m.Enabled }
        if m.Options then
            entry.Options = {}
            for n, o in pairs(m.Options) do
                if o.Type == "Toggle" then entry.Options[n] = { Enabled = o.Enabled }
                elseif o.Type == "Slider" then entry.Options[n] = { Value = o.Value }
                elseif o.Type == "ColorSlider" then entry.Options[n] = { Hue = o.Hue, Sat = o.Sat, Value = o.Value, Opacity = o.Opacity }
                elseif o.Type == "Dropdown" then entry.Options[n] = { Value = o.Value }
                elseif o.Type == "Bind" then entry.Options[n] = { Value = o.Value }
                elseif o.Type == "TextList" then entry.Options[n] = { ListEnabled = o.ListEnabled }
                end
            end
        end
        out[m.Name] = entry
    end
    return out
end

function mainapi:Load()
    -- Re-apply saved state from profile.
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
            -- Toggle the module itself last, after sub-options are set
            if entry.Enabled ~= nil then mod:SetEnabled(entry.Enabled) end
        end
    end
    mainapi.Loaded = true
end

function mainapi:Save()
    saveProfile(self:Serialize())
end

function mainapi:CreateCategory(catSettings)
    local catApi = {
        Name = catSettings.Name,
        Modules = {},
        ModuleOrder = {},
    }
    -- Button in the left strip
    local btn = new("TextButton", {
        Parent = catList,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = theme.BG_SECONDARY,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = FONT,
        TextSize = 13,
        TextColor3 = theme.TEXT_DIM,
        Text = catApi.Name,
    })
    corner(btn, 4)
    catApi.Button = btn
    btn.Activated:Connect(function() selectCategory(catApi.Name) end)

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

        -- Module row (collapsed) + expanded options container
        local row = new("Frame", {
            Parent = moduleList,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = theme.BG_SECONDARY,
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            ClipsDescendants = true,
            Visible = false, -- shown when category is selected
        })
        corner(row, 6)
        local header = new("TextButton", {
            Parent = row,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
            Font = FONT,
            TextSize = 13,
            TextColor3 = theme.TEXT_DIM,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "    " .. moduleApi.Name,
        })
        local indicator = new("Frame", {
            Parent = row,
            Size = UDim2.new(0, 4, 0, 18),
            Position = UDim2.new(0, 0, 0, 9),
            BackgroundColor3 = theme.BG_TERTIARY,
            BorderSizePixel = 0,
        })

        local optContainer = new("Frame", {
            Parent = row,
            Size = UDim2.new(1, -16, 0, 0),
            Position = UDim2.new(0, 16, 0, 36),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = false,
        })
        padding(optContainer, 4, 8, 8, 0)
        listLayout(optContainer, 2)
        moduleApi.Frame = row
        moduleApi.Header = header
        moduleApi.Indicator = indicator
        moduleApi._OptionContainer = optContainer

        -- Click header: shift-click = expand options; regular click = toggle module
        local expanded = false
        local function setExpanded(v)
            expanded = v
            optContainer.Visible = v
        end
        header.Activated:Connect(function()
            local sh = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
            if sh then
                setExpanded(not expanded)
            else
                moduleApi:SetEnabled(not moduleApi.Enabled)
            end
        end)

        local function renderState()
            local on = moduleApi.Enabled
            indicator.BackgroundColor3 = on and theme.ACCENT or theme.BG_TERTIARY
            header.TextColor3 = on and theme.TEXT_PRIMARY or theme.TEXT_DIM
        end

        function moduleApi:SetEnabled(v)
            v = v and true or false
            if self.Enabled == v then return end
            self.Enabled = v
            renderState()
            -- Fire the module's Function callback (safe — modules expect this).
            pcall(self.Function, v)
            -- If turning off, run cleanups (Connection-style).
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

        function moduleApi:Clean(thingOrFn)
            table.insert(self.Cleanups, thingOrFn)
            return thingOrFn
        end

        function moduleApi:CreateToggle(s)
            local optApi = makeToggleVisual(self, s)
            self.Options[s.Name] = optApi
            table.insert(self.OptionOrder, optApi)
            return optApi
        end

        -- Functional stubs (no visual yet, but state + .Function fire correctly so modules port)
        function moduleApi:CreateSlider(s) local a = makeStub("Slider", nil, s); self.Options[s.Name] = a; return a end
        function moduleApi:CreateColorSlider(s) local a = makeStub("ColorSlider", nil, s); self.Options[s.Name] = a; return a end
        function moduleApi:CreateDropdown(s) local a = makeStub("Dropdown", nil, s); self.Options[s.Name] = a; return a end
        function moduleApi:CreateBind(s) local a = makeStub("Bind", nil, s); self.Options[s.Name] = a; return a end
        function moduleApi:CreateTextList(s) local a = makeStub("TextList", nil, s); self.Options[s.Name] = a; return a end
        function moduleApi:CreateButton(s) local a = makeStub("Button", nil, s); self.Options[s.Name] = a; return a end

        -- Register
        self.Modules[modSettings.Name] = moduleApi
        table.insert(self.ModuleOrder, moduleApi)
        mainapi.Modules[modSettings.Name] = moduleApi
        renderState()
        return moduleApi
    end

    -- Register category
    mainapi.Categories[catApi.Name] = catApi
    table.insert(categories, catApi)
    if not currentCategoryName then selectCategory(catApi.Name) end
    return catApi
end

-- Make sure category names map alphabetically to consistent buttons
local defaultCategories = {"Combat", "Blatant", "Render", "Utility", "World", "Inventory", "Minigames", "Kits"}
for _, n in ipairs(defaultCategories) do mainapi:CreateCategory({Name = n}) end

-- ============================================================================
-- Open/close via keybind
-- ============================================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        for _, k in ipairs(mainapi.Keybind) do
            if input.KeyCode == Enum.KeyCode[k] then
                mainFrame.Visible = not mainFrame.Visible
                return
            end
        end
    end
end)

return mainapi
