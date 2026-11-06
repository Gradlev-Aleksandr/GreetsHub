# GreetsHub
felesvoa pastersoft
-- ==========================================
-- GreetsHub | All-in-One by [felesvoa]
-- ==========================================

local Plr = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Plr.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==========================================
-- FLUENT UI
-- ==========================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title = "GreetsHub | felesvoa",
    SubTitle = "All-in-One",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 350),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Movement = Window:AddTab({ Title = "Movement", Icon = "wind" }),
    Utility = Window:AddTab({ Title = "Utility", Icon = "settings" })
}

-- ==========================================
-- MAIN (Auto Farm & Game)
-- ==========================================
local cfg_autoFarm = false
Tabs.Main:AddToggle("AutoFarm", { Title = "Auto Farm Coins", Default = false }):OnChanged(function(v)
    cfg_autoFarm = v
    if v then
        task.spawn(function()
            while cfg_autoFarm do
                task.wait(0.5)
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj.Name == "Coin" and obj:FindFirstChild("Handle") then
                        LP.Character.HumanoidRootPart.CFrame = obj.Handle.CFrame
                        task.wait(0.1)
                    end
                end
            end
        end)
    end
end)

Tabs.Main:AddButton({ Title = "Rejoin Server", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end })
Tabs.Main:AddButton({ Title = "Server Hop", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end })

-- ==========================================
-- COMBAT (Aim & Kill)
-- ==========================================
local cfg_aim, cfg_killAll = false, false

Tabs.Combat:AddToggle("SilentAim", { Title = "Silent Aim", Default = false }):OnChanged(function(v)
    cfg_aim = v
    task.spawn(function()
        while cfg_aim do
            task.wait(0.1)
            local char = LP.Character
            if char then
                local w = char:FindFirstChild("Gun") or char:FindFirstChild("Knife")
                if w then
                    local closest, minDist = nil, 150
                    for _, p in pairs(Plr:GetPlayers()) do
                        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                            if onScreen then
                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                                if dist < minDist then minDist = dist; closest = p end
                            end
                        end
                    end
                    if closest then
                        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closest.Character.HumanoidRootPart.Position), 0.5)
                        w:Activate()
                    end
                end
            end
        end
    end)
end)

Tabs.Combat:AddToggle("KillAll", { Title = "Kill All (Murderer)", Default = false }):OnChanged(function(v)
    cfg_killAll = v
    if v then
        task.spawn(function()
            while cfg_killAll do
                task.wait(0.2)
                local char = LP.Character
                if char then
                    local knife = char:FindFirstChild("Knife")
                    if knife then
                        for _, p in pairs(Plr:GetPlayers()) do
                            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                if (p.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude < 5 then
                                    knife:Activate()
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- ==========================================
-- VISUALS (ESP & Chams)
-- ==========================================
local cfg_esp, cfg_tracer, cfg_gunEsp = false, false, false
local tracers = {}

Tabs.Visuals:AddToggle("ESP", { Title = "Player ESP (Roles)", Default = false }):OnChanged(function(v)
    cfg_esp = v
    for _, p in pairs(Plr:GetPlayers()) do
        if p ~= LP and p.Character then
            local hl = p.Character:FindFirstChild("Highlight") or Instance.new("Highlight", p.Character)
            hl.Enabled = v
            hl.FillColor = Color3.fromRGB(255, 0, 0)
        end
    end
end)

Tabs.Visuals:AddToggle("Tracers", { Title = "Tracers", Default = false }):OnChanged(function(v)
    cfg_tracer = v
    if not v then 
        for _, line in pairs(tracers) do line:Remove() end 
        tracers = {} 
    end
end)

Tabs.Visuals:AddToggle("GunESP", { Title = "Gun ESP", Default = false }):OnChanged(function(v) cfg_gunEsp = v end)

RS.RenderStepped:Connect(function()
    if cfg_tracer then
        for _, p in pairs(Plr:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local screenPos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if not tracers[p] then
                    local l = Drawing.new("Line")
                    l.Thickness = 1
                    l.Transparency = 1
                    l.Color = Color3.fromRGB(255, 255, 255)
                    tracers[p] = l
                end
                if onScreen then
                    tracers[p].Visible = true
                    tracers[p].From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    tracers[p].To = Vector2.new(screenPos.X, screenPos.Y)
                else 
                    tracers[p].Visible = false 
                end
            end
        end
    end
    
    if cfg_gunEsp then
        for _, obj in pairs(workspace:GetChildren()) do
            if obj.Name == "Gun" and obj:IsA("Tool") and not obj:FindFirstChild("Highlight") then
                local hl = Instance.new("Highlight")
                hl.Parent = obj
                hl.FillColor = Color3.fromRGB(255, 255, 0)
            end
        end
    end
end)

-- ==========================================
-- MOVEMENT (Fly, Noclip, Speed)
-- ==========================================
local cfg_fly, cfg_noclip = false, false

Tabs.Movement:AddSlider("Speed", { Title = "WalkSpeed", Default = 16, Min = 16, Max = 200, Rounding = 0 }):OnChanged(function(v)
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then 
        LP.Character.Humanoid.WalkSpeed = v 
    end
end)

Tabs.Movement:AddSlider("Jump", { Title = "JumpPower", Default = 50, Min = 50, Max = 300, Rounding = 0 }):OnChanged(function(v)
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then 
        LP.Character.Humanoid.JumpPower = v 
    end
end)

Tabs.Movement:AddToggle("Fly", { Title = "Fly", Default = false }):OnChanged(function(v)
    cfg_fly = v
    if v then
        local bg = Instance.new("BodyVelocity", LP.Character.HumanoidRootPart)
        bg.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bg.Velocity = Vector3.new(0, 0, 0)
        
        UIS.InputBegan:Connect(function(input)
            if not cfg_fly then bg:Destroy() return end
            if input.KeyCode == Enum.KeyCode.Space then bg.Velocity = Vector3.new(0, 50, 0) end
            if input.KeyCode == Enum.KeyCode.LeftShift then bg.Velocity = Vector3.new(0, -50, 0) end
        end)
    else
        if LP.Character and LP.Character.HumanoidRootPart:FindFirstChild("BodyVelocity") then
            LP.Character.HumanoidRootPart.BodyVelocity:Destroy()
        end
    end
end)

Tabs.Movement:AddToggle("Noclip", { Title = "Noclip", Default = false }):OnChanged(function(v) cfg_noclip = v end)

RS.Stepped:Connect(function()
    if cfg_noclip and LP.Character then
        for _, v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- ==========================================
-- UTILITY (Misc)
-- ==========================================
Tabs.Utility:AddButton({ Title = "Fullbright", Callback = function() game:GetService("Lighting").Brightness = 5 end })
