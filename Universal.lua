-- =========================================================
-- FlareHub v5.0 - Mobile + Executor Safe, Cache-Busting Loader
-- Features:
--  • Linoria UI (clean)
--  • Smooth Fly (F key)
--  • Fly Speed Slider
--  • Automatic fresh load (cache-busting)
--  • Safe for Studio / Mobile / Executors
-- =========================================================

-- =========================
-- SERVICES
-- =========================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(c)
    character = c
    humanoid = c:WaitForChild("Humanoid")
    root = c:WaitForChild("HumanoidRootPart")
end)

-- =========================
-- CACHE + UI CLEANUP
-- =========================
pcall(function()
    for _, gui in pairs(game.CoreGui:GetChildren()) do
        local name = gui.Name:lower()
        if name:find("linoria") or name:find("flarehub") then
            gui:Destroy()
        end
    end
end)

-- Unique session ID for cache-busting
local SESSION_ID = tostring(os.clock()).."_"..math.random(1,1e6)

-- =========================
-- LINORIA LOADER (CACHE-BUST)
-- =========================
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua?cache_bust="..SESSION_ID
))()

-- OPTIONAL ADDONS (ignore if you want simplest)
-- local ThemeManager = loadstring(game:HttpGet(
--     "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua?cache_bust="..SESSION_ID
-- ))()
-- local SaveManager = loadstring(game:HttpGet(
--     "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua?cache_bust="..SESSION_ID
-- ))()

-- =========================
-- CREATE WINDOW
-- =========================
local Window = Library:CreateWindow({
    Title = "FlareHub",
    Center = true,
    AutoShow = false -- manual toggle for mobile stability
})

-- =========================
-- CREATE TABS
-- =========================
local Tabs = {
    Movement = Window:AddTab("Movement"),
}

-- =========================
-- FLY SYSTEM (SMOOTH)
-- =========================
local flying = false
local flySpeed = 60
local flyConn

local function startFly()
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    flyConn = RunService.RenderStepped:Connect(function()
        if not flying then return end
        local cam = workspace.CurrentCamera
        local move = humanoid.MoveDirection

        local vel =
            cam.CFrame.RightVector * move.X +
            cam.CFrame.LookVector * move.Z

        root.AssemblyLinearVelocity = Vector3.new(
            vel.X * flySpeed,
            root.AssemblyLinearVelocity.Y * 0.85,
            vel.Z * flySpeed
        )
    end)
end

local function stopFly()
    if flyConn then flyConn:Disconnect() end
    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

-- =========================
-- MOVEMENT UI
-- =========================
Tabs.Movement:AddToggle("FlyToggle", {
    Text = "Fly (F)",
    Default = false,
    Callback = function(v)
        flying = v
        if v then startFly() else stopFly() end
    end
})

Tabs.Movement:AddSlider("FlySpeed", {
    Text = "Fly Speed",
    Min = 20,
    Max = 200,
    Default = 60,
    Rounding = 0,
    Callback = function(v)
        flySpeed = v
    end
})

-- =========================
-- SHOW UI (mobile-safe)
-- =========================
Library:Toggle()

-- =========================
-- HOTKEYS
-- =========================
UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.F then
        flying = not flying
        Library.Options.FlyToggle:SetValue(flying)
    end
end)

-- =========================
-- DEBUG NOTIFICATIONS (optional)
-- =========================
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "FlareHub Loaded",
        Text = "v5.0 mobile safe",
        Duration = 3
    })
end)
