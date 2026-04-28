-- [[ 載入 Rayfield UI ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- [[ 基礎服務宣告 ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 核心變數 ]]
local ESP_ENABLED = false
local ESP_OBJECTS = {}
local MAX_DISTANCE = 1000
local TEAM_CHECK = true
local TargetLevel = 999999 -- 預設等級

-- [[ 創建視窗 ]]
local Window = Rayfield:CreateWindow({
    Name = "CrowScript",
    Icon = 0,
    LoadingTitle = "CrowScript 載入中...",
    LoadingSubtitle = "製作者 | 開發團隊",
    Theme = "Default",
    ToggleUIKeybind = Enum.KeyCode.K,
    ConfigurationSaving = { Enabled = true, FolderName = "RivalsUniversalUI", FileName = "Config" }
})

-- [[ 所有的分頁 - 嚴格保留 ]]
local CombatTab = Window:CreateTab("Combat", "swords")
local VisualsTab = Window:CreateTab("Visuals", "eye")
local MovementTab = Window:CreateTab("Movement", "footprints")
local MiscTab = Window:CreateTab("Misc", "menu")
local SettingsTab = Window:CreateTab("Settings", "settings")

---------------------------------------------------------
-- [ ESP 邏輯函式 ]
---------------------------------------------------------
local function isTeammate(player)
    if not TEAM_CHECK then return false end
    if not lp.Team then return false end
    return player.Team == lp.Team
end

local function removeESP(player)
    if ESP_OBJECTS[player] then
        if ESP_OBJECTS[player].charConn then ESP_OBJECTS[player].charConn:Disconnect() end
        if ESP_OBJECTS[player].highlight then ESP_OBJECTS[player].highlight:Destroy() end
        if ESP_OBJECTS[player].bb then ESP_OBJECTS[player].bb:Destroy() end
        ESP_OBJECTS[player] = nil
    end
end

local function createESP(player)
    if player == lp then return end
    local function onCharacterAdded(char)
        removeESP(player)
        task.wait(0.3)
        local root = char:WaitForChild("HumanoidRootPart", 8)
        local humanoid = char:WaitForChild("Humanoid", 8)
        local head = char:WaitForChild("Head", 8)
        if not (root and humanoid and head) then return end

        local highlight = Instance.new("Highlight")
        highlight.Adornee = char
        highlight.DepthMode = Enum.HighlightDepthMode.Occluded
        highlight.FillColor = Color3.fromRGB(0, 255, 100)
        highlight.FillTransparency = 0.6
        highlight.Enabled = ESP_ENABLED
        highlight.Parent = char

        local bb = Instance.new("BillboardGui", head)
        bb.Size = UDim2.new(0, 150, 0, 50)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        bb.Enabled = ESP_ENABLED

        local infoLabel = Instance.new("TextLabel", bb)
        infoLabel.Size = UDim2.new(1, 0, 1, 0)
        infoLabel.BackgroundTransparency = 1
        infoLabel.TextColor3 = Color3.new(1, 1, 1)
        infoLabel.TextStrokeTransparency = 0.5
        infoLabel.Font = Enum.Font.SourceSansBold
        infoLabel.TextSize = 14

        ESP_OBJECTS[player] = {
            highlight = highlight,
            bb = bb,
            charConn = RunService.Heartbeat:Connect(function()
                if not ESP_ENABLED or not char.Parent or humanoid.Health <= 0 or isTeammate(player) then
                    highlight.Enabled = false
                    bb.Enabled = false
                    return
                end
                local dist = (root.Position - Camera.CFrame.Position).Magnitude
                if dist < MAX_DISTANCE then
                    highlight.Enabled = true
                    bb.Enabled = true
                    infoLabel.Text = string.format("%s\nHP: %.0f | %.0f", player.DisplayName, humanoid.Health, dist)
                else
                    highlight.Enabled = false
                    bb.Enabled = false
                end
            end)
        }
    end
    player.CharacterAdded:Connect(onCharacterAdded)
    if player.Character then onCharacterAdded(player.Character) end
end

---------------------------------------------------------
-- [ 各分頁功能內容 ]
---------------------------------------------------------

-- Visuals 分頁
VisualsTab:CreateToggle({
    Name = "高級 ESP (骨架+血量)",
    CurrentValue = false,
    Flag = "ESP_Master",
    Callback = function(v) ESP_ENABLED = v end,
})

-- Misc 分頁 (等級修改 + 名字修改)
MiscTab:CreateInput({
    Name = "設定等級 (Level)",
    PlaceholderText = "輸入數字...",
    Callback = function(Text)
        local num = tonumber(Text)
        if num then 
            TargetLevel = num 
            lp:SetAttribute("Level", TargetLevel)
            Rayfield:Notify({Title = "成功", Content = "等級鎖定: " .. num, Duration = 2})
        end
    end,
})

-- Settings 分頁 (DC 邀請)
SettingsTab:CreateButton({
    Name = "加入 Discord 邀請",
    Callback = function()
        local url = "https://discord.gg/VDCeKw5DKm"
        setclipboard(url)
        -- 優化後的通知：文字變短，視覺上不會顯得太寬
        Rayfield:Notify({
            Title = "Discord",
            Content = "連結已複製！請至瀏覽器貼上。",
            Duration = 3
        })
    end,
})

---------------------------------------------------------
-- [ 背景鎖定邏輯 ]
---------------------------------------------------------
task.spawn(function()
    while task.wait(1) do
        if lp:GetAttribute("Level") ~= TargetLevel then
            lp:SetAttribute("Level", TargetLevel)
        end
    end
end)

lp.CharacterAdded:Connect(function()--穿牆
    task.wait(0.5)
    if noclipEnabled then
        updateNoclip() -- 重生後若開關是開的，重新啟動循環
    end
end)

-- 等級鎖定循環
task.spawn(function()
    while task.wait(1) do
        if lp:GetAttribute("Level") ~= TargetLevel then
            lp:SetAttribute("Level", TargetLevel)
        end
    end
end)


-- 初始化
for _, plr in ipairs(Players:GetPlayers()) do task.spawn(createESP, plr) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)


Rayfield:LoadConfiguration()
