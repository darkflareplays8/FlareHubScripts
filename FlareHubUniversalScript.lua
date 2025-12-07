-- 🔥 FlareHub V2 - Noclip • Godmode • Walkspeed • Hitbox Desync(OP)
getgenv().SecureMode = true

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
Rayfield:LoadConfiguration()

local Window = Rayfield:CreateWindow({
    Name = "🔥 FlareHub V2",
    LoadingTitle = "FlareHub V2",
    LoadingSubtitle = "Noclip • Godmode • Walkspeed • Hitbox Desync(OP)",
    ConfigurationSaving = { 
        Enabled = true, 
        FolderName = "FlareHub", 
        FileName = "FlareConfig" 
    },
    Discord = { Enabled = false },
    KeySystem = false
})

local MainTab = Window:CreateTab("🎮 Main", 4483362458)
local CreditsTab = Window:CreateTab("📝 Credits", 4483362458)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

task.wait(1)

-- ULTRA SAFE WALKSPD (updated for 60 max)
local function safeSetWalkspeed(humanoid, speed)
    local targetSpeed = math.clamp(speed, 16, 60)
    spawn(function()
        while math.abs(humanoid.WalkSpeed - targetSpeed) > 0.1 do
            local newSpeed = humanoid.WalkSpeed + (targetSpeed - humanoid.WalkSpeed) * 0.03
            newSpeed = newSpeed + math.random(-1, 1) * 0.03
            humanoid.WalkSpeed = math.clamp(newSpeed, 16, 60)
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
        print("🔥 FlareHub V2 READY! (Hitbox Desync(OP))") 
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
    Name = "✨ Noclip (Anti-Detection)",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value)
        getgenv().NoclipEnabled = Value
        if Value then
            getgenv().NoclipConnection = RunService.Stepped:Connect(function()
                if player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Parent then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            getgenv().NoclipConnection2 = RunService.Heartbeat:Connect(function()
                if player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Parent then
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
            if getgenv().NoclipConnection2 then 
                getgenv().NoclipConnection2:Disconnect() 
                getgenv().NoclipConnection2 = nil
            end
        end
    end,
})

MainTab:CreateSlider({
    Name = "Walkspeed (Safe)",
    Range = {16, 60},
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
    Name = "🎯 Hitbox Desync (OP)",
    CurrentValue = false,
    Flag = "HitboxDesyncToggle",
    Callback = function(Value)
        toggleHitboxDesync(Value)
    end,
})

-- 📝 CREDITS TAB (BIGGEST ProfessionalFlare)
CreditsTab:CreateSection("🔥 FLAREHUB V2 🔥")
CreditsTab:CreateSection("👑 CREATOR 👑")
CreditsTab:CreateParagraph({
    Title = "🌟 PROFESSIONALFLARE 🌟",
    Content = "Script Developer & Designer"
})
CreditsTab:CreateSection("📞 CONTACT INFO")
CreditsTab:CreateParagraph({
    Title = "Roblox",
    Content = "DarealBloxfruiter"
})
CreditsTab:CreateParagraph({
    Title = "Discord",
    Content = "darkflareplays8"
})

print("🔥 FlareHub V2 - Noclip(Anti-Detection) • Godmode • Walkspeed(60) • Hitbox Desync(OP) LOADED!")
