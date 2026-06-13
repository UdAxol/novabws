local nova = ...

local Sample = nova.Categories.Combat:CreateModule({
    Name = "Sample Module",
    Tooltip = "All component types — shift+click to expand and try them",
    Function = function(callback)
        nova:CreateNotification("Sample Module", callback and "Toggle is ON" or "Toggle is OFF", 2)
    end,
})

Sample:CreateToggle({
    Name = "Sub-toggle",
    Default = false,
    Function = function(v) warn("[Sample] Sub-toggle ->", v) end,
})

Sample:CreateSlider({
    Name = "Range",
    Min = 0, Max = 30, Default = 14, Decimal = 0,
    Suffix = function(v) return v == 1 and "stud" or "studs" end,
    Function = function(v) warn("[Sample] Range ->", v) end,
})

Sample:CreateSlider({
    Name = "Speed",
    Min = 0, Max = 5, Default = 1.25, Decimal = 2,
    Suffix = "x",
    Function = function(v) warn("[Sample] Speed ->", v) end,
})

Sample:CreateDropdown({
    Name = "Mode",
    List = {"Normal", "Aggressive", "Stealth", "Burst"},
    Default = "Normal",
    Function = function(v) warn("[Sample] Mode ->", v) end,
})

Sample:CreateColorSlider({
    Name = "Color",
    DefaultHue = 0.7, DefaultSat = 0.8, DefaultValue = 1.0,
    Function = function(h, s, v, o) warn("[Sample] Color HSV ->", h, s, v) end,
})

Sample:CreateBind({
    Name = "Hotkey",
    Default = "",
    Function = function(k) warn("[Sample] Hotkey ->", k) end,
})

Sample:CreateButton({
    Name = "Test Notification",
    Function = function() nova:CreateNotification("Test", "Button works!", 3) end,
})

local Demo2 = nova.Categories.Render:CreateModule({
    Name = "Visual Demo",
    Tooltip = "Try the color picker + sliders",
    Function = function(callback)
        nova:CreateNotification("Visual Demo", callback and "ON" or "OFF", 2)
    end,
})

Demo2:CreateSlider({Name = "Opacity", Min = 0, Max = 1, Default = 0.5, Decimal = 2, Function = function() end})
Demo2:CreateColorSlider({Name = "Tint", DefaultHue = 0.55, DefaultSat = 0.9, DefaultValue = 1.0, Function = function() end})
Demo2:CreateDropdown({Name = "Style", List = {"Solid", "Gradient", "Pulse", "Rainbow"}, Default = "Solid", Function = function() end})
