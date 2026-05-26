local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HideAndSeekScript"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- ==================== 固定橫幅 ====================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "FixedBanner"
mainFrame.Size = UDim2.new(0, 520, 0, 58)
mainFrame.Position = UDim2.new(0.5, -260, 0, 30)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(90, 90, 90)
stroke.Thickness = 1
stroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.45, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "躲貓貓腳本"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 36, 0, 36)
minimizeBtn.Position = UDim2.new(1, -46, 0.5, -18)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "▼"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.Parent = mainFrame

-- ==================== 內容面板 ====================
local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, 0, 0, 365)
contentFrame.Position = UDim2.new(0, 0, 1, 8)
contentFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
contentFrame.BackgroundTransparency = 0
contentFrame.Visible = true
contentFrame.Parent = mainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 6)
contentCorner.Parent = contentFrame

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0, 95, 0, 42)
grid.CellPadding = UDim2.new(0, 8, 0, 8)
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
grid.VerticalAlignment = Enum.VerticalAlignment.Center
grid.Parent = contentFrame

-- ==================== 變數 ====================
local ESP_Enabled = false
local highlights = {}
local flying = false
local noclipEnabled = false
local infJumpEnabled = false
local highSpeedEnabled = false
local collisionHidden = false

-- ==================== 1. 透視 ====================
local function createESP(plr)
    if highlights[plr] then highlights[plr]:Destroy() end
    if nameTags[plr] then nameTags[plr]:Destroy() end
    if not plr.Character then return end
    
    -- Highlight
    local hl = Instance.new("Highlight")
    hl.Adornee = plr.Character
    hl.FillColor = Color3.fromRGB(255, 0, 255)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.Parent = plr.Character
    highlights[plr] = hl
    
    -- 名稱顯示
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
    billboard.Size = UDim2.new(0, 150, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = plr.Character
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = plr.Name
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.Parent = billboard
    
    nameTags[plr] = billboard
end

local function toggleESP(state)
    ESP_Enabled = state
    if state then
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr ~= player then createESP(plr) end
        end
        print("✅ 透視 已開啟（含名稱顯示）")
    else
        for _, v in pairs(highlights) do v:Destroy() end
        for _, v in pairs(nameTags) do v:Destroy() end
        highlights = {}
        nameTags = {}
        print("❌ 透視 已關閉")
    end
end

-- ==================== 2. 起飛 ====================
local bv, bg, flyConn
local function toggleFly(state)
    flying = state
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if flying then
        bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(1e5,1e5,1e5); bv.Parent = root
        bg = Instance.new("BodyGyro"); bg.MaxTorque = Vector3.new(1e5,1e5,1e5); bg.P = 12500; bg.Parent = root
        flyConn = game:GetService("RunService").Heartbeat:Connect(function()
            if not flying then return end
            local cam = workspace.CurrentCamera
            local uis = game:GetService("UserInputService")
            local move = Vector3.new(0,0,0)
            if uis:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if uis:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
            bv.Velocity = move.Magnitude > 0 and move.Unit * 65 or Vector3.new(0,0,0)
            bg.CFrame = cam.CFrame
        end)
        print("✅ 起飛 已開啟")
    else
        if flyConn then flyConn:Disconnect() end
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
        print("❌ 起飛 已關閉")
    end
end

-- ==================== 3. TP隨機 ====================
local function tpRandom()
    local targets = {}
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(targets, plr)
        end
    end
    if #targets == 0 then print("沒有其他玩家") return end
    local target = targets[math.random(#targets)]
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
        print("已傳送到：" .. target.Name)
    end
end

-- ==================== 4. 無限跳躍 ====================
local function toggleInfJump(state)
    infJumpEnabled = state
    print("✅ 無限跳躍 " .. (state and "已開啟" or "已關閉"))
end

-- ==================== 5. 穿牆 ====================
local function toggleNoclip(state)
    noclipEnabled = state
    if state then
        spawn(function()
            while noclipEnabled do
                local char = player.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
                task.wait(0.1)
            end
        end)
        print("✅ 穿牆 已開啟")
    else
        local char = player.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
        print("❌ 穿牆 已關閉")
    end
end

-- ==================== 6. 高空TP ====================
local function highAltitudeTP()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = root.CFrame + Vector3.new(0, 650, 0)
        print("✅ 已傳送到高空")
    end
end

-- ==================== 7. 高速移動 ====================
local function toggleHighSpeed(state)
    highSpeedEnabled = state
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then
        if state then
            hum.WalkSpeed = 45
            hum.JumpPower = 120
            print("✅ 高速移動 已開啟")
        else
            hum.WalkSpeed = 16
            hum.JumpPower = 50
            print("❌ 高速移動 已關閉")
        end
    end
end

-- ==================== 8. 碰撞箱消失 ====================
local function toggleCollisionHide(state)
    collisionHidden = state
    local character = player.Character
    if not character then return end
    
    if state then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 1
                part.CanCollide = false
            end
        end
        print("✅ 碰撞箱消失 已開啟（隱形模式）")
    else
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
                part.CanCollide = true
            end
        end
        print("❌ 碰撞箱消失 已關閉")
    end
end

-- ==================== 建立20個按鈕 ====================
local buttonStates = {}

for i = 1, 20 do
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.SourceSans
    btn.Parent = contentFrame
    
    if i == 1 then btn.Text = "透視"
    elseif i == 2 then btn.Text = "起飛"
    elseif i == 3 then btn.Text = "TP隨機"
    elseif i == 4 then btn.Text = "無限跳躍"
    elseif i == 5 then btn.Text = "穿牆"
    elseif i == 6 then btn.Text = "高空TP"
    elseif i == 7 then btn.Text = "高速移動"
    elseif i == 8 then btn.Text = "碰撞消失"
    else btn.Text = "測試 " .. i
    end
    
    buttonStates[btn] = false
    
    btn.MouseButton1Click:Connect(function()
        if i == 3 or i == 6 then
            -- 單次功能
            if i == 3 then tpRandom()
            elseif i == 6 then highAltitudeTP() end
            btn.BackgroundColor3 = Color3.fromRGB(0, 165, 0)
            task.delay(0.25, function() btn.BackgroundColor3 = Color3.fromRGB(28,28,28) end)
            return
        end
        
        buttonStates[btn] = not buttonStates[btn]
        
        if buttonStates[btn] then
            btn.BackgroundColor3 = Color3.fromRGB(0, 165, 0)
        else
            btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        end
        
        if i == 1 then toggleESP(buttonStates[btn])
        elseif i == 2 then toggleFly(buttonStates[btn])
        elseif i == 4 then toggleInfJump(buttonStates[btn])
        elseif i == 5 then toggleNoclip(buttonStates[btn])
        elseif i == 7 then toggleHighSpeed(buttonStates[btn])
        elseif i == 8 then toggleCollisionHide(buttonStates[btn])
        end
    end)
end

-- ==================== 拖動、縮小、P鍵 ====================
local dragging = false
local dragInput
local dragStart
local startPos

local function onDrag(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input == dragInput then onDrag(input) end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    contentFrame.Visible = not minimized
    minimizeBtn.Text = minimized and "▲" or "▼"
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.P then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

print("躲貓貓腳本已載入 | 按 P 鍵開關 | 第8個按鈕 = 碰撞箱消失")
