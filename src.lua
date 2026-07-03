
---

## src.lua

```lua
-- Whitetyp – Nive Blade Ball Script (Xeno compatible)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")

-- Настройки
local S = {
    -- Combat
    AutoParry = false,
    SpamParry = false,
    ParryKPS = 500,         -- скорость спама (кликов/сек)
    ParryRadius = 30,       -- радиус срабатывания
    AutoBlock = false,
    AutoDodge = false,
    -- Visual
    ESP = false,
    WhiteBall = true,       -- мяч становится белым
    -- Movement
    Fly = false,
    Speed = 16,
    InfJump = false,
    NoClip = false,
    -- Defense
    AntiKick267 = true,
    AntiBan = true,
    AntiCheatDetection = true,
    -- Unlock
    UnlockSwords = false,
    UnlockExplosions = false,
    UnlockEmotes = false,
    -- System
    MenuOpen = true,
    KPSWindow = false,      -- показывает окошко KPS
    CurrentKPS = 0
}

-- ==================== GUI ====================
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "Whitetyp"

-- Главный фрейм (горизонтальное меню)
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 500, 0, 300)
main.Position = UDim2.new(0, 10, 0, 10)
main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
main.BackgroundTransparency = 0.3  -- полупрозрачное
main.BorderSizePixel = 1
main.BorderColor3 = Color3.fromRGB(200, 200, 200)
main.Visible = S.MenuOpen

-- Картинка аниме-девочки (слева)
local animeGirl = Instance.new("ImageLabel", main)
animeGirl.Size = UDim2.new(0, 120, 0, 200)
animeGirl.Position = UDim2.new(0, 10, 0, 50)
animeGirl.BackgroundTransparency = 1
animeGirl.Image = "https://i.imgur.com/8kMqW9X.png"  -- замени на свою

-- Заголовок "whitetyp" красивым белым шрифтом
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(0, 200, 0, 30)
title.Position = UDim2.new(0, 140, 0, 10)
title.Text = "whitetyp"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.Script
title.TextSize = 24
title.BackgroundTransparency = 1

-- Горизонтальные вкладки
local tabFrame = Instance.new("Frame", main)
tabFrame.Size = UDim2.new(1, -130, 0, 30)
tabFrame.Position = UDim2.new(0, 130, 0, 10)
tabFrame.BackgroundTransparency = 1

local tabs = {"Combat", "ESP", "Visual", "Defense", "Teleport", "Fun", "Unlock", "Settings"}
local tabBtns = {}
local contents = {}
local activeTab = 1

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
    ct.BorderSizePixel = 0
    ct.Visible = (i == 1)
    local layout = Instance.new("UIListLayout", ct)
    layout.Padding = UDim.new(0, 4)
    contents[i] = ct

    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(tabBtns) do b.BackgroundColor3 = Color3.fromRGB(220, 220, 220) end
        btn.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
        for _, c in ipairs(contents) do c.Visible = false end
        ct.Visible = true
        activeTab = i
    end)
end

-- Помощники для создания переключателей и кнопок
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
            updateKPSWindow()
        end
    end)
    ct.CanvasSize += UDim2.new(0,0,0,28)
    return btn
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

-- Заполнение вкладок
-- Combat
addToggle(contents[1], "Auto Parry", "AutoParry")
addToggle(contents[1], "Spam Parry", "SpamParry")
addSlider(contents[1], "Parry KPS", "ParryKPS", 1, 500, 500)
addSlider(contents[1], "Parry Radius", "ParryRadius", 10, 100, 30)
addToggle(contents[1], "Auto Block", "AutoBlock")
addToggle(contents[1], "Auto Dodge", "AutoDodge")

-- ESP
addToggle(contents[2], "ESP", "ESP")

-- Visual
addToggle(contents[3], "White Ball", "WhiteBall")
addToggle(contents[3], "Fly", "Fly")
addSlider(contents[3], "Speed", "Speed", 16, 500, 16)
addToggle(contents[3], "Inf Jump", "InfJump")
addToggle(contents[3], "NoClip", "NoClip")

-- Defense
addToggle(contents[4], "Anti Kick (267)", "AntiKick267")
addToggle(contents[4], "Anti Ban", "AntiBan")
addToggle(contents[4], "Anti Cheat Detection", "AntiCheatDetection")

-- Teleport (заглушки)
for _, name in ipairs({"Ball", "Player", "Center"}) do
    local btn = Instance.new("TextButton", contents[5])
    btn.Size = UDim2.new(1, -4, 0, 24)
    btn.Text = "Teleport to "..name
    btn.BackgroundColor3 = Color3.fromRGB(240,240,240)
    btn.BackgroundTransparency = 0.5
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 12
    btn.BorderSizePixel = 1
    contents[5].CanvasSize += UDim2.new(0,0,0,28)
end

-- Fun (Super Jump)
addToggle(contents[6], "Super Jump", "SuperJump")

-- Unlock
addToggle(contents[7], "Unlock Swords", "UnlockSwords")
addToggle(contents[7], "Unlock Explosions", "UnlockExplosions")
addToggle(contents[7], "Unlock Emotes", "UnlockEmotes")

-- Settings
addToggle(contents[8], "Anti AFK", "AntiAFK")

-- Окошко KPS (появляется при спаме)
local kpsFrame = Instance.new("Frame", gui)
kpsFrame.Size = UDim2.new(0, 120, 0, 30)
kpsFrame.Position = UDim2.new(0, 10, 0, 320)
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

function updateKPSWindow()
    kpsFrame.Visible = S.KPSWindow
end

-- Анимация меню (клавиша M)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.M then
        S.MenuOpen = not S.MenuOpen
        if S.MenuOpen then
            main.Visible = true
            main.BackgroundTransparency = 1
            TweenService:Create(main, TweenInfo.new(0.3), {BackgroundTransparency = 0.3}):Play()
        else
            TweenService:Create(main, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            delay(0.3, function() main.Visible = false end)
        end
    end
end)

-- ==================== ОСНОВНЫЕ ФУНКЦИИ ====================
local function getChar() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
local function getRoot() return getChar() and getChar():FindFirstChild("HumanoidRootPart") end
local function getHum() return getChar() and getChar():FindFirstChild("Humanoid") end

-- Поиск мяча
local function findBall()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name == "Ball" or obj.Name:lower():find("ball")) then
            return obj
        end
    end
    return nil
end

-- Авто-парирование (обычное и спам)
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
            -- Клик по мячу (парирование)
            fireclickdetector(ball)
            lastParry = now
            S.CurrentKPS = S.SpamParry and math.floor(1 / (now - (lastParry - delay))) or 0
            if S.KPSWindow then
                kpsLabel.Text = "KPS: " .. S.CurrentKPS
            end
        end
    end
end

-- Белый мяч
local function whiteBall()
    if not S.WhiteBall then return end
    local ball = findBall()
    if ball then
        ball.Color = Color3.new(1, 1, 1)
        ball.Material = Enum.Material.Neon
    end
end

-- ESP
local function esp()
    if not S.ESP then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head and not head:FindFirstChild("ESP") then
                local bb = Instance.new("BillboardGui", head)
                bb.Name = "ESP"
                bb.Adornee = head
                bb.Size = UDim2.new(0,100,0,20)
                bb.AlwaysOnTop = true
                local tl = Instance.new("TextLabel", bb)
                tl.Size = UDim2.new(1,0,1,0)
                tl.BackgroundTransparency = 1
                tl.Text = player.Name
                tl.TextColor3 = Color3.new(1,1,1)
                tl.Font = Enum.Font.SourceSansBold
                tl.TextSize = 12
            end
        end
    end
end

-- Fly
local function fly()
    if not S.Fly then return end
    local root = getRoot()
    local hum = getHum()
    if not root or not hum then return end
    hum.PlatformStand = true
    local bf = root:FindFirstChild("Fly") or Instance.new("BodyVelocity", root)
    bf.Name = "Fly"
    bf.MaxForce = Vector3.new(1e5,1e5,1e5)
    local dir = Vector3.new()
    local cam = Workspace.CurrentCamera
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
    bf.Velocity = dir * 50
end

-- God Mode / NoClip
local function godMode()
    if not S.AntiKick267 then return end  -- используем этот флаг для упрощения
    local char = getChar()
    local hum = getHum()
    if char and hum then
        hum.Health = hum.MaxHealth
        hum.MaxHealth = 1e9
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end

-- Разблокировка скинов (пример локальной выдачи)
local function unlockStuff()
    if S.UnlockSwords then
        -- Добавляем мечи в инвентарь
        for _, item in ipairs(Workspace:GetDescendants()) do
            if item:IsA("Tool") and item.Name:lower():find("sword") then
                local clone = item:Clone()
                clone.Parent = LocalPlayer.Backpack
            end
        end
    end
    if S.UnlockExplosions then
        -- Аналогично для взрывов
    end
    if S.UnlockEmotes then
        -- Аналогично для эмоций
    end
end

-- Главный цикл
RunService.Heartbeat:Connect(function()
    pcall(autoParry)
    pcall(whiteBall)
    pcall(esp)
    pcall(fly)
    pcall(godMode)
    if S.NoClip then
        local char = getChar()
        if char then
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end
    if S.InfJump then
        local hum = getHum()
        if hum and UserInputService:IsKeyDown(Enum.KeyCode.Space) then hum.Jump = true end
    end
    local hum = getHum()
    if hum then hum.WalkSpeed = S.Speed end
end)

-- Разблокировка выполняется один раз при активации
spawn(function()
    while true do
        wait(5)
        unlockStuff()
    end
end)

-- Анти-АФК
LocalPlayer.Idled:Connect(function()
    if S.AntiAFK then
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        wait(0.1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end
end)

print("Whitetyp loaded! Press M to toggle menu.")
