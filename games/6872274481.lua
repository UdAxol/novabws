-- [Nova v2 / BedWars] Game-file. Receives nova as ...
-- v0.1 ships one sample Combat module to prove the framework works end-to-end.
-- Real modules (Killaura/Reach/Breaker/etc.) ported in v0.2+.

local nova = ...

local SamplePing = nova.Categories.Combat:CreateModule({
    Name = "Sample Module",
    Tooltip = "v0.1 wiring test — pings F9 when toggled and creates a notification.",
    Function = function(callback)
        if callback then
            warn("[Nova v2 / Sample] Toggle ON")
            nova:CreateNotification("Sample Module", "Toggle is ON", 3)
        else
            warn("[Nova v2 / Sample] Toggle OFF")
            nova:CreateNotification("Sample Module", "Toggle is OFF", 3)
        end
    end,
})

local SubToggle = SamplePing:CreateToggle({
    Name = "Sub-toggle",
    Default = false,
    Function = function(v)
        warn("[Nova v2 / Sample] Sub-toggle ->", v)
    end,
})
