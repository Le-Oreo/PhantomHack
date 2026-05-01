--[===[ PHANTOM HACK V1.0 - BY OREO ]===]--
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Phantom Hack V1.0 | Made by Oreo",
    LoadingTitle = "Phantom Hack",
    LoadingSubtitle = "by Oreo - V1.0",
    ConfigurationSaving = {Enabled = true, FolderName = "Phantom", FileName = "Settings"}
})

local Tab = Window:CreateTab("Main", 4483362458)

Tab:CreateParagraph({Title = "Welcome", Content = "Phantom Hack by Oreo\nVersion 1.0"})

local KeyInput = Tab:CreateInput({
    Name = "Enter Key",
    PlaceholderText = "PHANTOM-XXXXXX",
    Callback = function(Text) _G.Key = Text end
})

Tab:CreateButton({
    Name = "Submit Key & Load",
    Callback = function()
        if not _G.Key or not _G.Key:find("^PHANTOM%-") then
            Rayfield:Notify({Title = "Error", Content = "Invalid Key", Duration = 5})
            return
        end

        Rayfield:Notify({Title = "Success", Content = "Key Accepted - Phantom Hack by Oreo Loaded", Duration = 4})

        -- Log Player + Executor
        print("PHANTOM EXECUTION LOG")
        print("Player: " .. game.Players.LocalPlayer.Name)
        print("UserId: " .. game.Players.LocalPlayer.UserId)
        print("Executor: " .. (identifyexecutor and identifyexecutor() or "Unknown"))
        print("Version: V1.0")

        -- Features
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
    end
})

Tab:CreateToggle({
    Name = "Dark / Light Mode",
    CurrentValue = true,
    Callback = function(Value)
        if Value then Window:ChangeTheme("Dark") else Window:ChangeTheme("Light") end
    end
})

Rayfield:Notify({Title = "Phantom Hack by Oreo", Content = "V1.0 Loaded - Enter key", Duration = 6})
