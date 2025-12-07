-- SpyFlare - lightweight Remote spy GUI

if getgenv().SpyFlareRunning then
    return
end
getgenv().SpyFlareRunning = true

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local LP = Players.LocalPlayer

-- ========= UI =========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpyFlare"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 500, 0, 260)
Frame.Position = UDim2.new(0, 20, 0, 80)
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 24)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
Title.BorderSizePixel = 0
Title.Text = "SpyFlare - Remote Spy"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextColor3 = Color3.new(1,1,1)
Title.Parent = Frame

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 24, 0, 24)
Close.Position = UDim2.new(1, -24, 0, 0)
Close.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
Close.Text = "X"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14
Close.TextColor3 = Color3.new(1,1,1)
Close.Parent = Frame

local ListFrame = Instance.new("ScrollingFrame")
ListFrame.Size = UDim2.new(0, 260, 1, -28)
ListFrame.Position = UDim2.new(0, 0, 0, 28)
ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ListFrame.ScrollBarThickness = 4
ListFrame.BackgroundTransparency = 1
ListFrame.BorderSizePixel = 0
ListFrame.Parent = Frame

local UIList = Instance.new("UIListLayout")
UIList.Parent = ListFrame
UIList.SortOrder = Enum.SortOrder.LayoutOrder

local Detail = Instance.new("TextBox")
Detail.Size = UDim2.new(1, -270, 1, -28)
Detail.Position = UDim2.new(0, 270, 0, 28)
Detail.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
Detail.TextColor3 = Color3.new(1,1,1)
Detail.Font = Enum.Font.Code
Detail.TextWrapped = true
Detail.TextXAlignment = Enum.TextXAlignment.Left
Detail.TextYAlignment = Enum.TextYAlignment.Top
Detail.TextSize = 14
Detail.Text = "-- select a call on the left"
Detail.ClearTextOnFocus = false
Detail.MultiLine = true
Detail.Parent = Frame

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0, 80, 0, 22)
CopyBtn.Position = UDim2.new(1, -90, 1, -24)
CopyBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 20)
CopyBtn.Text = "Copy"
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 12
CopyBtn.TextColor3 = Color3.new(1,1,1)
CopyBtn.Parent = Frame

local SelectedCode = ""

CopyBtn.MouseButton1Click:Connect(function()
    if setclipboard and SelectedCode ~= "" then
        setclipboard(SelectedCode)
    end
end)

Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    getgenv().SpyFlareRunning = false
end)

local function shortName(path)
    local max = 24
    if #path > max then
        return "..."..string.sub(path, #path-max+3, #path)
    end
    return path
end

-- ========= Serializers =========
local function valToString(v, depth)
    depth = depth or 0
    local t = typeof(v)
    if t == "string" then
        return string.format("%q", v)
    elseif t == "number" or t == "boolean" then
        return tostring(v)
    elseif t == "Vector3" then
        return string.format("Vector3.new(%g,%g,%g)", v.X, v.Y, v.Z)
    elseif t == "CFrame" then
        local cf = {v:GetComponents()}
        return "CFrame.new("..table.concat(cf, ",")..")"
    elseif t == "Instance" then
        return string.format("game.%s", v:GetFullName())
    elseif t == "table" then
        if depth > 2 then return "{...}" end
        local parts = {}
        for k,val in pairs(v) do
            table.insert(parts, "["..valToString(k, depth+1).."]="..valToString(val, depth+1))
        end
        return "{ "..table.concat(parts, ", ").." }"
    else
        return string.format("(%s)", t)
    end
end

local function buildCall(remote, method, args)
    local path = remote:GetFullName()
    local argStrings = {}
    for i,v in ipairs(args) do
        argStrings[i] = valToString(v)
    end
    return string.format("game.%s:%s(%s)", path, method, table.concat(argStrings, ", "))
end

-- ========= Hook remotes =========
local remotes = {}

local function hookInstance(obj)
    if remotes[obj] then return end
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        remotes[obj] = true
        local method = obj:IsA("RemoteEvent") and "FireServer" or "InvokeServer"

        local old
        old = hookfunction(obj[method], function(self, ...)
            local args = {...}
            local lineCode = buildCall(self, method, args)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -4, 0, 20)
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Text = method.." | "..shortName(self:GetFullName())
            btn.Parent = ListFrame

            btn.MouseButton1Click:Connect(function()
                SelectedCode = lineCode
                Detail.Text = lineCode
            end)

            ListFrame.CanvasSize = UDim2.new(0,0,0,UIList.AbsoluteContentSize.Y + 8)

            return old(self, table.unpack(args))
        end)
    end
end

for _,obj in ipairs(game:GetDescendants()) do
    hookInstance(obj)
end

game.DescendantAdded:Connect(hookInstance)

print("[SpyFlare] Remote spy loaded.")
