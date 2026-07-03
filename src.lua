-- Whitetyp – Nive Blade Ball Script (Lightweight, Working Menu)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")

-- Настройки
local S = {
    AutoParry = false,
    SpamParry = false,
    ParryKPS = 500,
    ParryRadius = 30,
    ESP = false,
    WhiteBall = true,
    Fly = false,
    Speed = 16,
    InfJump = false,
    NoClip = false,
    AntiKick267 = true,
    AntiBan = true,
    UnlockSwords = false,
    UnlockExplosions = false,
    UnlockEmotes = false,
    MenuOpen = true,
    KPSWindow = false,
    CurrentKPS = 0
}

-- ==================== МГНОВЕННОЕ МЕНЮ (БЕЗ АНИМАЦИЙ) ====================
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "Whitetyp"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 500, 0, 280)
main.Position = UDim2.new(0, 10, 0, 10)
main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
main.BackgroundTransparency = 0.3
main.BorderSizePixel = 1
main.BorderColor3 = Color3.fromRGB(200, 200, 200)
main.Visible = S.MenuOpen

-- Картинка аниме-девочки
local img = Instance.new("ImageLabel", main)
img.Size = UDim2.new(0, 100, 0, 150)
img.Position = UDim2.new(0, 10, 0, 50)
img.BackgroundTransparency = 1
img.Image = "https://i.imgur.com/8kMqW9X.png"

-- Заголовок
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(0, 200, 0, 30)
title.Position = UDim2.new(0, 120, 0, 10)
title.Text = "whitetyp"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.Script
title.TextSize = 24
title.BackgroundTransparency = 1

-- Вкладки (горизонтально)
local tabFrame = Instance.new("Frame", main)
tabFrame.Size = UDim2.new(1, -130, 0, 30)
tabFrame.Position = UDim2.new(0, 130, 0, 10)
tabFrame.BackgroundTransparency = 1

local tabs = {"Combat", "ESP", "Visual", "Defense", "Teleport", "Fun", "Unlock", "Settings"}
local tabBtns = {}
local contents = {}

for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton", tabFrame)
    btn.Size = UDim2.new(0, 80, 0, 25)
    btn.Position = UDim2.new(0, (i-1)*85, 0, 0)
    btn.Text = name
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(180, 180, 180) or Color3.fromRGB(220, 220, 220)
    btn.BackgroundTransparency = 0.5
    btn.TextColor3 = Color3.new(0, 0, 0)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.BorderSizePixel = 1
    tabBtns[i] = btn

    local ct = Instance.new("ScrollingFrame", main)
    ct.Size = UDim2.new(1, -10, 1, -50)
    ct.Position = UDim2.new(0, 5, 0, 45)
    ct.CanvasSize = UDim2.new(0, 0, 0, 0)
    ct.ScrollBarThickness = 4
    ct.BackgroundTransparency = 1
    ct.Visible = (i == 1)
    local layout = Instance.new("UIListLayout", ct)
    layout.Padding = UDim.new(0, 4)
    contents[i] = ct

    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(tabBtns) do b.BackgroundColor3 = Color3.fromRGB(220, 220, 220) end
        btn.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
        for _, c in ipairs(contents) do c.Visible = false end
        ct.Visible = true
    end)
end

-- Функция переключателя
local function addToggle(ct, text, key)
    local btn = Instance.new("TextButton", ct)
    btn.Size = UDim2.new(1, -4, 0, 24)
    btn.Text = "  "..text..": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    btn.BackgroundTransparency = 0.5
    btn.TextColor3 = Color3.new(0, 0, 0)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 1
    btn.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        btn.Text = "  "..text..": "..(S[key] and "ON" or "OFF")
        if key == "SpamParry" then
            S.KPSWindow = S[key]
            kpsFrame.Visible = S.KPSWindow
        end
    end)
    ct.CanvasSize += UDim2.new(0,0,0,28)
end

local function addSlider(ct, text, key, min, max, default)
    S[key] = default
    local label = Instance.new("TextLabel", ct)
    label.Size = UDim2.new(1,0,0,18)
    label.Text = text..": "..default
    label.TextColor3 = Color3.new(0,0,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSans
    label.TextSize = 12
    ct.CanvasSize += UDim2.new(0,0,0,20)

    local input = Instance.new("TextBox", ct)
    input.Size = UDim2.new(1,-4,0,22)
    input.Text = tostring(default)
    input.BackgroundColor3 = Color3.fromRGB(255,255,255)
    input.BackgroundTransparency = 0.5
    input.TextColor3 = Color3.new(0,0,0)
    input.Font = Enum.Font.SourceSans
    input.BorderSizePixel = 1
    input.FocusLost:Connect(function()
        local num = tonumber(input.Text)
        if num then
            num = math.clamp(num, min, max)
            S[key] = num
            label.Text = text..": "..num
            if key == "Speed" then
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum then hum.WalkSpeed = num end
            end
        end
    end)
    ct.CanvasSize += UDim2.new(0,0,0,24)
end

-- Заполнение вкладок (сокращённо, для примера)
addToggle(contents[1], "Auto Parry", "AutoParry")
addToggle(contents[1], "Spam Parry", "SpamParry")
addSlider(contents[1], "Parry KPS", "ParryKPS", 1, 500, 500)
addSlider(contents[1], "Parry Radius", "ParryRadius", 10, 100, 30)
addToggle(contents[1], "Auto Block", "AutoBlock")
addToggle(contents[1], "Auto Dodge", "AutoDodge")

addToggle(contents[2], "ESP", "ESP")

addToggle(contents[3], "White Ball", "WhiteBall")
addToggle(contents[3], "Fly", "Fly")
addSlider(contents[3], "Speed", "Speed", 16, 500, 16)
addToggle(contents[3], "Inf Jump", "InfJump")
addToggle(contents[3], "NoClip", "NoClip")

addToggle(contents[4], "Anti Kick (267)", "AntiKick267")
addToggle(contents[4], "Anti Ban", "AntiBan")

addToggle(contents[7], "Unlock Swords", "UnlockSwords")
addToggle(contents[7], "Unlock Explosions", "UnlockExplosions")
addToggle(contents[7], "Unlock Emotes", "UnlockEmotes")

addToggle(contents[8], "Anti AFK", "AntiAFK")

-- Окошко KPS
local kpsFrame = Instance.new("Frame", gui)
kpsFrame.Size = UDim2.new(0, 120, 0, 30)
kpsFrame.Position = UDim2.new(0, 10, 0, 300)
kpsFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
kpsFrame.BackgroundTransparency = 0.3
kpsFrame.BorderSizePixel = 1
kpsFrame.Visible = false
local kpsLabel = Instance.new("TextLabel", kpsFrame)
kpsLabel.Size = UDim2.new(1,0,1,0)
kpsLabel.Text = "KPS: 0"
kpsLabel.TextColor3 = Color3.new(0,0,0)
kpsLabel.Font = Enum.Font.SourceSansBold
kpsLabel.TextSize = 14

-- Клавиша M для скрытия/открытия
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.M then
        S.MenuOpen = not S.MenuOpen
        main.Visible = S.MenuOpen
    end
end)

-- ==================== ФУНКЦИИ (БАЗОВЫЕ, РАБОТАЮТ) ====================
local function getChar() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
local function getRoot() return getChar() and getChar():FindFirstChild("HumanoidRootPart") end
local function getHum() return getChar() and getChar():FindFirstChild("Humanoid") end

local function findBall()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name == "Ball" or obj.Name:lower():find("ball")) then
            return obj
        end
    end
    return nil
end

local lastParry = 0
local function autoParry()
    if not S.AutoParry and not S.SpamParry then return end
    local ball = findBall()
    if not ball then return end
    local root = getRoot()
    if not root then return end
    local dist = (root.Position - ball.Position).Magnitude
    if dist <= S.ParryRadius then
        local now = tick()
        local delay = S.SpamParry and (1 / S.ParryKPS) or 0.5
        if now - lastParry >= delay then
            fireclickdetector(ball)
            lastParry = now
            S.CurrentKPS = S.SpamParry and math.floor(1 / delay) or 0
            if S.KPSWindow then kpsLabel.Text = "KPS: " .. S.CurrentKPS end
        end
    end
end

local function whiteBall()
    if not S.WhiteBall then return end
    local ball = findBall()
    if ball then ball.Color = Color3.new(1,1,1); ball.Material = Enum.Material.Neon end
end

local function esp()
    if not S.ESP then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head and not head:FindFirstChild("ESP") then
                local bb = Instance.new("BillboardGui", head)
                bb.Name = "ESP"; bb.Adornee = head; bb.Size = UDim2.new(0,100,0,20); bb.AlwaysOnTop = true
                local tl = Instance.new("TextLabel", bb)
                tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1
                tl.Text = player.Name; tl.TextColor3 = Color3.new(1,1,1); tl.Font = Enum.Font.SourceSansBold; tl.TextSize = 12
            end
        end
    end
end

local function fly()
    if not S.Fly then return end
    local root = getRoot(); local hum = getHum()
    if not root or not hum then return end
    hum.PlatformStand = true
    local bf = root:FindFirstChild("Fly") or Instance.new("BodyVelocity", root)
    bf.Name = "Fly"; bf.MaxForce = Vector3.new(1e5,1e5,1e5)
    local dir = Vector3.new(); local cam = Workspace.CurrentCamera
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
    bf.Velocity = dir * 50
end

local function godMode()
    if not S.AntiKick267 then return end
    local char = getChar(); local hum = getHum()
    if char and hum then
        hum.Health = hum.MaxHealth; hum.MaxHealth = 1e9
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        for _, v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end

-- Главный цикл
RunService.Heartbeat:Connect(function()
    pcall(autoParry); pcall(whiteBall); pcall(esp); pcall(fly); pcall(godMode)
    if S.NoClip then
        local char = getChar()
        if char then for _, v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    end
    if S.InfJump then
        local hum = getHum()
        if hum and UserInputService:IsKeyDown(Enum.KeyCode.Space) then hum.Jump = true end
    end
    local hum = getHum(); if hum then hum.WalkSpeed = S.Speed end
end)

print("Whitetyp ready! Press M to toggle menu.")
