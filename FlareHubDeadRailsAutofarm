-- 🔥 FlareHub V2 - FIXED MASTER TOGGLE (No Errors)
getgenv().SecureMode = true

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
Rayfield:LoadConfiguration()

local Window = Rayfield:CreateWindow({
   Name = "🔥 FlareHub V2",
   LoadingTitle = "Dead Rails PERFECT Farm",
   LoadingSubtitle = "PAD → CREATE → BONDS",
   ConfigurationSaving = { Enabled = true, FolderName = "FlareHub", FileName = "FixedMaster" },
   Discord = { Enabled = false },
   KeySystem = false
})

local FarmTab = Window:CreateTab("🚂 Dead Rails", 4483362458)
local player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")

local PAD_POSITION = Vector3.new(64.50, 7.60, 130.75)
local farming = false
local bondsCount = 0
local overlayGui = nil
local step = "START"

-- **OVERLAY FUNCTION**
local function createOverlay()
   if overlayGui then overlayGui:Destroy() end
   
   overlayGui = Instance.new("ScreenGui")
   overlayGui.Name = "MasterOverlay"
   overlayGui.Parent = game.CoreGui
   overlayGui.ResetOnSpawn = false
   overlayGui.IgnoreGuiInset = true

   local frame = Instance.new("Frame")
   frame.Size = UDim2.new(1, 0, 1, 0)
   frame.BackgroundColor3 = Color3.fromRGB(0, 0, 20)
   frame.BackgroundTransparency = 0.15
   frame.BorderSizePixel = 0
   frame.Parent = overlayGui

   local title = Instance.new("TextLabel")
   title.Size = UDim2.new(1, 0, 0.15, 0)
   title.Position = UDim2.new(0, 0, 0.05, 0)
   title.BackgroundTransparency = 1
   title.Text = "🔥 MASTER FARM ACTIVE"
   title.TextColor3 = Color3.fromRGB(255, 255, 0)
   title.TextScaled = true
   title.Font = Enum.Font.GothamBold
   title.Parent = frame

   local bondsLabel = Instance.new("TextLabel")
   bondsLabel.Size = UDim2.new(0.9, 0, 0.12, 0)
   bondsLabel.Position = UDim2.new(0.05, 0, 0.25, 0)
   bondsLabel.BackgroundTransparency = 1
   bondsLabel.Text = "Bonds: 0"
   bondsLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
   bondsLabel.TextScaled = true
   bondsLabel.Font = Enum.Font.GothamBold
   bondsLabel.Parent = frame

   local statusLabel = Instance.new("TextLabel")
   statusLabel.Size = UDim2.new(0.9, 0, 0.12, 0)
   statusLabel.Position = UDim2.new(0.05, 0, 0.4, 0)
   statusLabel.BackgroundTransparency = 1
   statusLabel.Text = "Status: Starting..."
   statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
   statusLabel.TextScaled = true
   statusLabel.Font = Enum.Font.Gotham
   statusLabel.Parent = frame
   
   return bondsLabel, statusLabel
end

-- **TWEEN TO PAD**
local function tweenToPad()
   local character = player.Character
   if not character then return end
   local hrp = character:FindFirstChild("HumanoidRootPart")
   if not hrp then return end
   
   local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad)
   local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(PAD_POSITION + Vector3.new(0, 3, 0))})
   tween:Play()
   tween.Completed:Wait()
end

-- **CLICK CREATE**
local function clickCreate()
   print("🔍 Scanning for CREATE button...")
   
   for _, gui in pairs(PlayerGui:GetDescendants()) do
      if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible then
         local name = (gui.Name .. gui.Parent.Name .. (gui.Text or "")):lower()
         if name:find("create") or name:find("party") or name:find("solo") or name:find("1") or name:find("start") then
            print("✅ CLICKING:", gui:GetFullName())
            pcall(function()
               firesignal(gui.MouseButton1Click)
               gui:Activate()
            end)
            break
         end
      end
   end
   
   -- REMOTE BACKUP
   pcall(function()
      local shared = ReplicatedStorage:FindFirstChild("Shared")
      if shared then
         local createParty = shared:FindFirstChild("CreatePartyClient")
         if createParty then
            createParty:FireServer({maxPlayers = 1})
         end
      end
   end)
end

-- **FARM BONDS**
local function farmBonds(bondsLabel, statusLabel)
   local character = player.Character
   if not character then return false end
   local hrp = character:FindFirstChild("HumanoidRootPart")
   if not hrp then return false end

   local collected = 0
   for _, obj in pairs(Workspace:GetDescendants()) do
      if obj.Name:lower():find("bond") and obj:IsA("BasePart") then
         pcall(function()
            hrp.CFrame = obj.CFrame * CFrame.new(0, 5, 0)
            wait(0.2)
            local clickDetector = obj:FindFirstChildOfClass("ClickDetector")
            if clickDetector then
               fireclickdetector(clickDetector)
               bondsCount = bondsCount + 1
               collected = collected + 1
            end
         end)
      end
   end
   
   bondsLabel.Text = "Bonds: " .. bondsCount
   return collected > 0
end

-- **MASTER FARM LOOP**
local function startMasterFarm()
   bondsCount = 0
   step = "PAD"
   local bondsLabel, statusLabel = createOverlay()
   
   spawn(function()
      while farming do
         pcall(function()
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then 
               wait(1) 
               return 
            end
            
            if step == "PAD" then
               statusLabel.Text = "1️⃣ Moving to PAD..."
               tweenToPad()
               step = "CREATE"
               
            elseif step == "CREATE" then
               statusLabel.Text = "2️⃣ Clicking CREATE..."
               clickCreate()
               step = "FARM"
               wait(8) -- Wait countdown + teleport
               
            elseif step == "FARM" then
               statusLabel.Text = "3️⃣ Farming bonds..."
               local found = farmBonds(bondsLabel, statusLabel)
               
               if bondsCount >= 100 or not found then
                  statusLabel.Text = "✅ COMPLETE - Toggle off/on to restart"
                  farming = false
               end
            end
         end)
         wait(1)
      end
      
      if overlayGui then overlayGui:Destroy() end
   end)
end

-- **FIXED TOGGLE - NO ERRORS**
FarmTab:CreateToggle({
   Name = "🔥 MASTER FARM (PAD → CREATE → BONDS)",
   CurrentValue = false,
   Flag = "MasterFarm",
   Callback = function(Value)
      farming = Value
      if Value then
         spawn(startMasterFarm)
      end
   end,
})

FarmTab:CreateButton({
   Name = "📍 Test PAD TP",
   Callback = function()
      tweenToPad()
   end
})

print("🔥 FIXED MASTER TOGGLE - NO ERRORS! [web:226]")
