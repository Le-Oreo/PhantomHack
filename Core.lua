--[===[ PHANTOM CORE BY OREO ]===]--
local key = _G.Key or ""
if not key:find("^PHANTOM%-") then
    game.Players.LocalPlayer:Kick("Invalid Key")
    return
end

print("PHANTOM CORE LOADED BY OREO")

-- Hacks here
for _, plr in pairs(game.Players:GetPlayers()) do
    if plr ~= game.Players.LocalPlayer and plr.Character then
        local box = Instance.new("BoxHandleAdornment")
        box.Adornee = plr.Character.HumanoidRootPart
        box.Size = Vector3.new(4,6,4)
        box.Transparency = 0.5
        box.Color3 = Color3.new(0,1,1)
        box.AlwaysOnTop = true
        box.Parent = plr.Character
    end
end
