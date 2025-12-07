-- 🔥 FlareHub Dead Rails – PAD → CreateParty → Bond Farm (ONE TOGGLE)

getgenv().SecureMode = true

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer

-- === CONFIG ===
local PAD_POSITION      = Vector3.new(64.50, 7.60, 130.75)  -- your pad coords
local MAX_BONDS_PER_RUN = 100

local LOBBY_PLACE_ID    = 116495829188952
local GAME_PLACE_ID     = 70876832253163   -- update if different

-- === STATE ===
local MasterRunning = false
local BondsThisRun  = 0
local OverlayGui

-- === SMALL HELPER ===
local function isPrivateServer()
    local psId = game.PrivateServerId
    local job  = game.JobId
    return (psId and psId ~= "") or (job and job ~= "")
end

-- === UI OVERLAY ===
local function createOverlay()
    if OverlayGui then OverlayGui:Destroy() end

    OverlayGui = Instance.new("ScreenGui")
    OverlayGui.Name = "FlareHubDeadRailsOverlay"
    OverlayGui.IgnoreGuiInset = true
    OverlayGui.ResetOnSpawn = false
    OverlayGui.Parent = game.CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 20)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.15, 0)
    title.Position = UDim2.new(0, 0, 0.03, 0)
    title.BackgroundTransparency = 1
    title.Text = "🔥 PAD → CreateParty → BOND FARM"
    title.TextColor3 = Color3.fromRGB(255, 255, 0)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0.9, 0, 0.12, 0)
    status.Position = UDim2.new(0.05, 0, 0.22, 0)
    status.BackgroundTransparency = 1
    status.Text = "Status: Waiting..."
    status.TextColor3 = Color3.fromRGB(255, 255, 255)
    status.TextScaled = true
    status.Font = Enum.Font.Gotham
    status.Parent = frame

    local bonds = Instance.new("TextLabel")
    bonds.Size = UDim2.new(0.9, 0, 0.12, 0)
    bonds.Position = UDim2.new(0.05, 0, 0.35, 0)
    bonds.BackgroundTransparency = 1
    bonds.Text = "Bonds: 0 / "..MAX_BONDS_PER_RUN
    bonds.TextColor3 = Color3.fromRGB(0, 255, 100)
    bonds.TextScaled = true
    bonds.Font = Enum.Font.GothamBold
    bonds.Parent = frame

    return status, bonds
end

-- === TWEEN TO PAD (do this before CreateParty) ===
local function tweenToPad()
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local hrp  = char:WaitForChild("HumanoidRootPart")

    local info  = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(hrp, info, {CFrame = CFrame.new(PAD_POSITION + Vector3.new(0, 3, 0))})
    tween:Play()
    tween.Completed:Wait()
end

-- === EXACT CreateParty REMOTE (from TurtleSpy capture) ===
local function fireCreateParty()
    local createParty = ReplicatedStorage
        .Shared
        .Network
        .RemoteEvent
        :FindFirstChild("CreateParty")

    if not createParty then
        warn("CreateParty remote not found")
        return
    end

    createParty:FireServer({
        isPrivate  = true,
        trainId    = "default",
        maxMembers = 4,
        gameMode   = "Normal",
    })
end

-- === BOND FARM IN GAME PLACE ===
local function farmBonds(bondsLabel, statusLabel)
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local hrp  = char:WaitForChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")

    -- auto‑equip any gun‑like tool
    if hum then
        for _, tool in ipairs(localPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:lower():find("gun") or tool.Name:lower():find("revolver")) then
                hum:EquipTool(tool)
                break
            end
        end
    end

    local collected = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("bond") then
            pcall(function()
                hrp.CFrame = obj.CFrame * CFrame.new(0, 5, 0)
                task.wait(0.15)
                local cd = obj:FindFirstChildOfClass("ClickDetector")
                if cd then
                    fireclickdetector(cd)
                    BondsThisRun += 1
                    collected += 1
                    bondsLabel.Text = ("Bonds: %d / %d"):format(BondsThisRun, MAX_BONDS_PER_RUN)
                end
            end)
        end
    end

    return collected > 0
end

-- === MASTER LOOP: PAD → CreateParty → FARM ===
local function masterLoop()
    BondsThisRun = 0
    local statusLabel, bondsLabel = createOverlay()

    while MasterRunning do
        -- lobby logic
        if game.PlaceId == LOBBY_PLACE_ID then
            if not isPrivateServer() then
                statusLabel.Text = "Status: Join a private server."
                MasterRunning = false
                break
            end

            statusLabel.Text = "1️⃣ Moving to pad..."
            tweenToPad()

            statusLabel.Text = "2️⃣ Sending CreateParty..."
            fireCreateParty()

            statusLabel.Text = "Waiting for teleport into game..."
            -- wait for place change into game
            local start = tick()
            repeat
                task.wait(0.5)
            until not MasterRunning or game.PlaceId == GAME_PLACE_ID or tick() - start > 15

        -- game logic
        elseif game.PlaceId == GAME_PLACE_ID then
            statusLabel.Text = "3️⃣ Farming bonds..."
            local any = farmBonds(bondsLabel, statusLabel)

            if not any or BondsThisRun >= MAX_BONDS_PER_RUN then
                statusLabel.Text = "✅ Run finished, you can rejoin/retoggle."
                MasterRunning = false
                break
            end

            task.wait(0.5)

        else
            statusLabel.Text = "Status: Go to Dead Rails lobby."
            task.wait(2)
        end
    end

    if OverlayGui then
        OverlayGui:Destroy()
        OverlayGui = nil
    end
end

-- === SIMPLE TOGGLE BIND (no external UI library) ===
-- set getgenv().MasterFarm = true/false from your hub UI, or bind to a key

getgenv().StartDeadRailsMaster = function()
    if MasterRunning then return end
    MasterRunning = true
    task.spawn(masterLoop)
end

getgenv().StopDeadRailsMaster = function()
    MasterRunning = false
end
