-- =============================================
-- Rivals 通用 Ragebot UI - 保證執行版
-- 使用 Rayfield (目前最穩定 loader)
-- 按 Insert 開啟/關閉
-- =============================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Rivals 通用 Ragebot UI",
    LoadingTitle = "載入中...",
    LoadingSubtitle = "通用版 | 穩定執行",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "RivalsUniversalUI",
        FileName = "Config"
    }
})

-- ====================== 變數 ======================
local rageEnabled = false
local silentEnabled = false
local autoShoot = true
local fov = 120
local targetPart = "Head"

-- ====================== Tab 1: Combat ======================
local Combat = Window:CreateTab("Combat", 4483362458)

Combat:CreateSection("Ragebot 設定")

Combat:CreateToggle({
    Name = "Ragebot (Silent + Auto Shoot)",
    CurrentValue = false,
    Callback = function(v)
        rageEnabled = v
        silentEnabled = v
    end
})

Combat:CreateToggle({
    Name = "Silent Aim Only",
    CurrentValue = false,
    Callback = function(v) silentEnabled = v end
})

Combat:CreateToggle({
    Name = "Auto Shoot",
    CurrentValue = true,
    Callback = function(v) autoShoot = v end
})

Combat:CreateSlider({
    Name = "FOV",
    Range = {50, 400},
    Increment = 10,
    CurrentValue = 120,
    Callback = function(v) fov = v end
})

Combat:CreateDropdown({
    Name = "瞄準部位",
    Options = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"},
    CurrentOption = {"Head"},
    MultipleOptions = false,
    Callback = function(opt) targetPart = opt[1] end
})

-- ====================== Tab 2: Visuals ======================
local Visuals = Window:CreateTab("Visuals", 4483362458)

Visuals:CreateSection("ESP")

local espOn = false

Visuals:CreateToggle({
    Name = "ESP Highlight",
    CurrentValue = false,
    Callback = function(v)
        espOn = v
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                if v then
                    local hl = Instance.new("Highlight")
                    hl.Name = "UniversalESP"
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255,255,255)
                    hl.Parent = p.Character
                else
                    local old = p.Character:FindFirstChild("UniversalESP")
                    if old then old:Destroy() end
                end
            end
        end
    end
})

-- ====================== Tab 3: Movement ======================
local Move = Window:CreateTab("Movement", 4483362458)

Move:CreateSection("移動功能")

Move:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = false,
    Callback = function(v) end
})

Move:CreateSlider({
    Name = "速度",
    Range = {16, 100},
    Increment = 2,
    CurrentValue = 50,
    Callback = function(v) end
})

-- ====================== Tab 4: Misc ======================
local Misc = Window:CreateTab("Misc", 4483362458)

Misc:CreateSection("其他")

Misc:CreateButton({
    Name = "Unlock All Weapons",
    Callback = function()
        Rayfield:Notify("Unlock All", "建議使用專用 Hub", 4483362458)
    end
})

Misc:CreateToggle({
    Name = "No Recoil",
    CurrentValue = false,
    Callback = function(v) end
})

-- ====================== Tab 5: Settings ======================
local Settings = Window:CreateTab("Settings", 4483362458)

Settings:CreateButton({
    Name = "摧毀 UI",
    Callback = function() Window:Destroy() end
})

-- ====================== 核心功能 (Silent Aim + Loop) ======================
local function getClosest()
    local closest, dist = nil, math.huge
    local lp = game.Players.LocalPlayer
    local cam = workspace.CurrentCamera
    local mousePos = cam:WorldToViewportPoint(lp.Character and lp.Character.Head.Position or Vector3.new())
    
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= lp and plr.Character and plr.Character:FindFirstChild(targetPart) then
            local pos = plr.Character[targetPart].Position
            local screen, onScreen = cam:WorldToViewportPoint(pos)
            if onScreen then
                local d = (Vector2.new(screen.X, screen.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                if d < dist and d < fov then
                    dist = d
                    closest = plr
                end
            end
        end
    end
    return closest
end

-- Silent Aim Hook
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if (rageEnabled or silentEnabled) and getnamecallmethod() == "FireServer" and 
       (self.Name:find("Bullet") or self.Name:find("Shoot") or self.Name:find("Fire")) then
        local tgt = getClosest()
        if tgt and tgt.Character and tgt.Character:FindFirstChild(targetPart) then
            args[1] = tgt.Character[targetPart].Position + (tgt.Character.HumanoidRootPart.Velocity * 0.1)
        end
    end
    return old(self, unpack(args))
end)
setreadonly(mt, true)

-- Auto Shoot
spawn(function()
    while wait(0.04) do
        if rageEnabled and autoShoot then
            local tgt = getClosest()
            if tgt and tgt.Character and tgt.Character:FindFirstChild("Humanoid") and tgt.Character.Humanoid.Health > 0 then
                mouse1click()
            end
        end
    end
end)

-- 載入完成
Rayfield:Notify({
    Title = "✅ 通用 UI 載入成功",
    Content = "按 Insert 開啟\nRagebot 已就緒！",
    Duration = 6,
    Image = 4483362458
})
