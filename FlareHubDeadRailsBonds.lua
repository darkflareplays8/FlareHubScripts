getgenv().SecureMode = true

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Dead Rails • Master Farm",
    LoadingTitle = "FlareHub",
    LoadingSubtitle = "Automation System",
    ConfigurationSaving = {Enabled = false},
})

local MainTab = Window:CreateTab("Main", 4483362458)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer

local PAD_POSITION = Vector3.new(64.50, 7.60, 130.75)
local MAX_BONDS_PER_RUN = 100

local LOBBY_PLACE_ID = 116495829188952
local GAME_PLACE_ID = 70876832253163

local MasterRunning = false
local BondsThisRun = 0
local OverlayGui
local CreatePartySpamming = false

local function isPrivateServer()
    local psId = game.PrivateServerId
    local job = game.JobId
    return (psId and psId ~= "") or (job and job ~= "")
end

local function fireCreateParty()
    local createParty = ReplicatedStorage.Shared.Network.RemoteEvent:FindFirstChild("CreateParty")
    if not createParty then
        return
    end

    createParty:FireServer({
        isPrivate = true,
        trainId = "default",
        maxMembers = 4,
        gameMode = "Normal",
    })
end

-- spam CreateParty while in lobby and farm is on
local function startCreatePartySpam()
    if CreatePartySpamming then return end
    CreatePartySpamming = true

    task.spawn(function()
        while CreatePartySpamming do
            if MasterRunning and game.PlaceId == LOBBY_PLACE_ID and isPrivateServer() then
                fireCreateParty()
            end
            task.wait(0.02) -- spam delay; adjust if needed
        end
    end)
end

local function stopCreatePartySpam()
    CreatePartySpamming = false
end

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
    frame.Parent = OverlayGui

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

local function tweenToPad()
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local info = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(hrp, info, {CFrame = CFrame.new(PAD_POSITION + Vector3.new(0, 3, 0))})
    tween:Play()
    tween.Completed:Wait()
end

local function farmBonds(bondsLabel)
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    if hum then
        for _, tool in ipairs(localPlayer.Backpack:GetChildren()) do
            local name = tool.Name:lower()
            if tool:IsA("Tool") and (name:find("gun") or name:find("revolver")) then
                hum:EquipTool(tool)
                break
            end
        end
    end

    local found = false
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("bond") then
            found = true
            pcall(function()
                hrp.CFrame = obj.CFrame * CFrame.new(0, 5, 0)
                task.wait(0.15)
                local cd = obj:FindFirstChildOfClass("ClickDetector")
                if cd then
                    fireclickdetector(cd)
                    BondsThisRun += 1
                    bondsLabel.Text = ("Bonds: %d / %d"):format(BondsThisRun, MAX_BONDS_PER_RUN)
                end
            end)
        end
    end

    return found
end

local function masterLoop()
    BondsThisRun = 0
    local statusLabel, bondsLabel = createOverlay()
    startCreatePartySpam()

    while MasterRunning do
        if game.PlaceId == LOBBY_PLACE_ID then
            if not isPrivateServer() then
                statusLabel.Text = "Status: Join a private server."
                MasterRunning = false
                break
            end

            statusLabel.Text = "1️⃣ Moving to pad..."
            tweenToPad()

            statusLabel.Text = "Waiting for teleport..."
            local start = tick()
            repeat
                task.wait(0.5)
            until not MasterRunning or game.PlaceId == GAME_PLACE_ID or tick() - start > 15

        elseif game.PlaceId == GAME_PLACE_ID then
            statusLabel.Text = "3️⃣ Farming bonds..."
            local any = farmBonds(bondsLabel)

            if not any or BondsThisRun >= MAX_BONDS_PER_RUN then
                statusLabel.Text = "Run finished."
                MasterRunning = false
                break
            end

        else
            statusLabel.Text = "Go to Dead Rails lobby."
            task.wait(1)
        end
    end

    stopCreatePartySpam()

    if OverlayGui then
        OverlayGui:Destroy()
        OverlayGui = nil
    end
end

getgenv().StartDeadRailsMaster = function()
    if MasterRunning then return end
    MasterRunning = true
    task.spawn(masterLoop)
end

getgenv().StopDeadRailsMaster = function()
    MasterRunning = false
    stopCreatePartySpam()
end

MainTab:CreateToggle({
    Name = "Start DeadRails Master Farm",
    CurrentValue = false,
    Flag = "MasterFarmToggle",
    Callback = function(state)
        if state then
            if getgenv().StartDeadRailsMaster then
                getgenv().StartDeadRailsMaster()
            end
        else
            if getgenv().StopDeadRailsMaster then
                getgenv().StopDeadRailsMaster()
            end
        end
    end,
})
