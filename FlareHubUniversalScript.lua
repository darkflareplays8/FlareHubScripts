-- 🔥 FlareHub V2 - Noclip • Godmode • Invis • Hitbox Desync(OP)
getgenv().SecureMode = true

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
Rayfield:LoadConfiguration()

local Window = Rayfield:CreateWindow({
    Name = "🔥 FlareHub V2",
    LoadingTitle = "FlareHub V2",
    LoadingSubtitle = "Noclip • Godmode • Invis • Hitbox Desync(OP)",
    ConfigurationSaving = { 
        Enabled = true, 
        FolderName = "FlareHub", 
        FileName = "FlareConfig" 
    },
    Discord = { Enabled = false },
    KeySystem = false
})

local MainTab = Window:CreateTab("🎮 Main", 4483362458)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

task.wait(1)

-- ULTRA SAFE WALKSPD
local function safeSetWalkspeed(humanoid, speed)
    local targetSpeed = math.clamp(speed, 16, 24)
    spawn(function()
        while math.abs(humanoid.WalkSpeed - targetSpeed) > 0.1 do
            local newSpeed = humanoid.WalkSpeed + (targetSpeed - humanoid.WalkSpeed) * 0.03
            newSpeed = newSpeed + math.random(-1, 1) * 0.03
            humanoid.WalkSpeed = math.clamp(newSpeed, 16, 24)
            task.wait(0.4)
        end
    end)
end

-- TRUE GODMODE
local godmodeConnection
local function toggleGodmode(Value)
    if not player.Character then return end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid then return end

    if Value then
        godmodeConnection = humanoid.HealthChanged:Connect(function(health)
            if health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    else
        if godmodeConnection then 
            godmodeConnection:Disconnect()
            godmodeConnection = nil
        end
    end
end

-- INVISIBILITY (LOCAL - you can't see yourself)
local invisBackup = nil
local function setTransparencyForCharacter(char, alpha)
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Decal") then
            obj.Transparency = alpha
        end
    end
end

local function toggleInvisibility(enabled)
    local char = player.Character
    if not char then return end

    if enabled then
        invisBackup = {}
        for _, obj in ipairs(char:GetDescendants()) do
            if (obj:IsA("BasePart") or obj:IsA("Decal")) and obj ~= char:FindFirstChild("HumanoidRootPart") then
                invisBackup[obj] = obj.Transparency
            end
        end
        setTransparencyForCharacter(char, 1)
    else
        if invisBackup then
            for inst, oldAlpha in pairs(invisBackup) do
                if inst and inst.Parent then
                    inst.Transparency = oldAlpha
                end
            end
        end
        invisBackup = nil
    end
end

-- HITBOX DESYNC (OP - camera stays normal, hitbox moves behind)
local hitboxDesyncConnection
local fakeHitbox = nil
local DESYNC_OFFSET = Vector3.new(math.random(-2,2), 2, 6)

local function createFakeHitbox()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local root = char.HumanoidRootPart
    
    fakeHitbox = Instance.new("Part")
    fakeHitbox.Name = "FakeHitbox_" .. tick()
    fakeHitbox.Size = Vector3.new(5, 5, 5)
    fakeHitbox.Transparency = 1
    fakeHitbox.CanCollide = false
    fakeHitbox.Anchored = false
    fakeHitbox.Parent = char
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = fakeHitbox
    weld.Parent = fakeHitbox
    
    fakeHitbox.CFrame = root.CFrame * CFrame.new(DESYNC_OFFSET)
end

local function toggleHitboxDesync(Value)
    if Value then
        createFakeHitbox()
        hitboxDesyncConnection = RunService.Heartbeat:Connect(function()
            if fakeHitbox and fakeHitbox.Parent and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local jitter = Vector3.new(
                        math.random(-1,1)*0.3, 
                        math.random(-0.3,0.3), 
                        0
                    )
                    fakeHitbox.CFrame = root.CFrame * CFrame.new(DESYNC_OFFSET + jitter)
                end
            end
        end)
    else
        if hitboxDesyncConnection then
            hitboxDesyncConnection:Disconnect()
            hitboxDesyncConnection = nil
        end
        if fakeHitbox then
            fakeHitbox:Destroy()
            fakeHitbox = nil
        end
    end
end

-- 🎮 MAIN TAB UI
MainTab:CreateButton({ 
    Name = "✅ Test GUI", 
    Callback = function() 
        print("🔥 FlareHub V2 READY! (Hitbox Desync(OP) + More)") 
        Rayfield:Notify({
            Title = "FlareHub V2",
            Content = "All features loaded successfully!",
            Duration = 3
        })
    end 
})

MainTab:CreateToggle({
    Name = "💖 True Godmode",
    CurrentValue = false,
    Flag = "GodmodeToggle",
    Callback = function(Value) 
        toggleGodmode(Value) 
    end,
})

MainTab:CreateToggle({
    Name = "✨ Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value)
        getgenv().NoclipEnabled = Value
        if Value then
            getgenv().NoclipConnection = RunService.Stepped:Connect(function()
                if player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else 
            if getgenv().NoclipConnection then 
                getgenv().NoclipConnection:Disconnect() 
                getgenv().NoclipConnection = nil
            end
        end
    end,
})

MainTab:CreateSlider({
    Name = "Walkspeed (Safe)",
    Range = {16, 24},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkspeedSlider",
    Callback = function(Value)
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then 
            safeSetWalkspeed(humanoid, Value) 
        end
    end,
})

MainTab:CreateToggle({
    Name = "👻 Invisibility (Local)",
    CurrentValue = false,
    Flag = "InvisibilityToggle",
    Callback = function(Value)
        toggleInvisibility(Value)
    end,
})

MainTab:CreateToggle({
    Name = "🎯 Hitbox Desync (OP)",
    CurrentValue = false,
    Flag = "HitboxDesyncToggle",
    Callback = function(Value)
        toggleHitboxDesync(Value)
    end,
})

print("🔥 FlareHub V2 - COMPLETE (Noclip, Godmode, Invis, Hitbox Desync(OP)) LOADED!")
