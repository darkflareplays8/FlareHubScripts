-- 🔥 FlareHub V2 - Noclip • Godmode • Walkspeed • Hitbox Desync(OP)
getgenv().SecureMode = true

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
Rayfield:LoadConfiguration()

-- MAIN WINDOW
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

-- SERVICES / PLAYER
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

task.wait(1)

-- ========= WALKSPEED (SAFE) =========
local function safeSetWalkspeed(humanoid, speed)
    local targetSpeed = math.clamp(speed, 16, 60)
    task.spawn(function()
        while humanoid and humanoid.Parent and math.abs(humanoid.WalkSpeed - targetSpeed) > 0.1 do
            local newSpeed = humanoid.WalkSpeed + (targetSpeed - humanoid.WalkSpeed) * 0.03
            newSpeed = newSpeed + math.random(-1, 1) * 0.03
            humanoid.WalkSpeed = math.clamp(newSpeed, 16, 60)
            task.wait(0.4)
        end
    end)
end

-- ========= TRUE GODMODE =========
local godmodeConnection
local function toggleGodmode(Value)
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if Value then
        if godmodeConnection then
            godmodeConnection:Disconnect()
        end
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

-- ========= HITBOX DESYNC =========
local hitboxDesyncConnection
local fakeHitbox = nil
local DESYNC_OFFSET = Vector3.new(math.random(-2,2), 2, 6)

local function createFakeHitbox()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

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
        if not fakeHitbox then
            createFakeHitbox()
        end
        if hitboxDesyncConnection then
            hitboxDesyncConnection:Disconnect()
        end
        hitboxDesyncConnection = RunService.Heartbeat:Connect(function()
            if fakeHitbox and fakeHitbox.Parent and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local jitter = Vector3.new(
                        math.random(-1,1) * 0.3, 
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

-- ========= HOVER NOCLIP (NEVER SINKS) =========
local noclip = false
local noclipConn
local character = player.Character or player.CharacterAdded:Wait()
local HOVER_HEIGHT = 2.5 -- studs above ground

local function getCharacterParts()
    local char = character
    if not char then return {} end
    local parts = {}
    for _, inst in ipairs(char:GetDescendants()) do
        if inst:IsA("BasePart") and inst.Name ~= "HumanoidRootPart" then
            table.insert(parts, inst)
        end
    end
    return parts
end

local function enableNoclipLoop()
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end

    noclipConn = RunService.Stepped:Connect(function()
        if not character then return end
        local hum = character:FindFirstChildOfClass("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end

        -- Disable all collisions
        for _, p in ipairs(getCharacterParts()) do
            p.CanCollide = false
        end

        -- HOVER: Force root part to stay at perfect height above ground
        local rayOrigin = root.Position
        local rayDirection = Vector3.new(0, -50, 0) -- cast down
        
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {character}
        params.FilterType = RaycastFilterType.Blacklist
        
        local raycastResult = workspace:Raycast(rayOrigin, rayDirection, params)
        
        local targetY
        if raycastResult then
            -- Ground detected: hover 2.5 studs above it
            targetY = raycastResult.Position.Y + HOVER_HEIGHT
        else
            -- No ground: hover at safe height
            targetY = workspace.FallenPartsDestroyHeight + 10
        end
        
        -- Smoothly move to hover height
        local currentY = root.Position.Y
        local newY = currentY + (targetY - currentY) * 0.3
        root.CFrame = CFrame.new(root.Position.X, newY, root.Position.Z) * CFrame.fromOrientation(0, root.CFrame:ToOrientation())
    end)
end

local function disableNoclipLoop()
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
    if character then
        for _, p in ipairs(getCharacterParts()) do
            p.CanCollide = true
        end
        local hum = character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
end

local function toggleNoclip(Value)
    noclip = Value
    if noclip then
        enableNoclipLoop()
    else
        disableNoclipLoop()
    end
end

-- keep noclip behavior across respawns
player.CharacterAdded:Connect(function(char)
    character = char
    task.wait(0.1)
    if noclip then
        enableNoclipLoop()
    else
        disableNoclipLoop()
    end
end)

-- ========= MAIN TAB UI =========
MainTab:CreateButton({ 
    Name = "✅ Test GUI", 
    Callback = function() 
        print("🔥 FlareHub V2 READY! (Hover Noclip)") 
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
    Name = "✨ Noclip (Hover)",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value)
        toggleNoclip(Value)
    end,
})

MainTab:CreateSlider({
    Name = "Walkspeed (Safe)",
    Range = {16, 60},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkspeedSlider",
    Callback = function(Value)
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
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

-- ========= CREDITS =========
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

print("🔥 FlareHub V2 - Noclip(Hover 2.5) • Godmode • Walkspeed(60) • Hitbox Desync(OP) LOADED!")
