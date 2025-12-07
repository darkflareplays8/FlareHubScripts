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
    if not createParty then return end

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
            task.wait(0.02) -- spam delay; lower = more aggressive
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

    local info = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.E
