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

-- SMALL POPOUT WINDOW (for quick noclip)
local PopoutWindow = Rayfield:CreateWindow({
    Name = "🔥 FlareHub V2 - Popout",
    LoadingTitle = "FlareHub V2",
    LoadingSubtitle = "Quick Noclip",
    ConfigurationSaving = { 
        Enabled = false,
    },
    Discord = { Enabled = false },
    KeySystem = false
})

local PopoutTab = PopoutWindow:CreateTab("⚡ Quick", 4483362458)

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

-- ========= NOCLIP (WALL ONLY + SHARED) =========
local noclipEnabled = false
local noclipConn

local function getCharacterParts()
    local char = player.Character
    if not char then return {} end
    local parts = {}
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            table.insert(parts, part)
        end
    end
    return parts
end

local function isFloorSurface(normal)
    -- Upwards normal = floor
    return normal.Y > 0.7
end

local function toggleNoclip(Value)
    noclipEnabled = Value

    if noclipEnabled then
        if noclipConn then
            noclipConn:Disconnect()
        end

        noclipConn = RunService.Stepped:Connect(function()
            local char = player.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not root or not humanoid then return end

            -- more stable movement while messing with collisions
            humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)

            local dir = root.CFrame.LookVector * 3
            local rayOrigin = root.Position
            local rayDirection = dir

            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {char}
            params.FilterType = Enum.RaycastFilterType.Blacklist

            local result = workspace:Raycast(rayOrigin, rayDirection, params)
            local parts = getCharacterParts()

            if result and result.Instance then
                local normal = result.Normal
                if not isFloorSurface(normal) then
                    -- wall: go through
                    for _, part in ipairs(parts) do
                        part.CanCollide = false
                    end
                else
                    -- floor: keep collisions so you don't fall
                    for _, part in ipairs(parts) do
                        part.CanCollide = true
                    end
                end
            else
                -- nothing in front: normal collisions
                for _, part in ipairs(parts) do
                    part.CanCollide = true
                end
            end
        end)
    else
        if noclipConn then
            noclipConn:Disconnect()
            noclipConn = nil
        end

        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end
end

-- ========= MAIN TAB UI =========
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

-- MAIN NOCLIP TOGGLE
MainTab:CreateToggle({
    Name = "✨ Noclip (Wall only)",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value)
        toggleNoclip(Value)
        -- sync popout
        if Rayfield.Flags and Rayfield.Flags.PopoutNoclipToggle then
            Rayfield.Flags.PopoutNoclipToggle:Set(Value)
        end
    end,
})

-- POPOUT BUTTON (UNDER MAIN NOCLIP)
MainTab:CreateButton({
    Name = "📤 Pop Out Noclip",
    Callback = function()
        -- open the popout window
        if PopoutWindow and PopoutWindow.Open then
            PopoutWindow:Open()
        end
    end
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

-- ========= POPOUT TAB UI =========
PopoutTab:CreateToggle({
    Name = "✨ Noclip",
    CurrentValue = false,
    Flag = "PopoutNoclipToggle",
    Callback = function(Value)
        toggleNoclip(Value)
        -- sync main
        if Rayfield.Flags and Rayfield.Flags.NoclipToggle then
            Rayfield.Flags.NoclipToggle:Set(Value)
        end
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

print("🔥 FlareHub V2 - Noclip(Wall Only + Popout) • Godmode • Walkspeed(60) • Hitbox Desync(OP) LOADED!")
