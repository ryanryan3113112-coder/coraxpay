local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "CrowScript",
    Icon = 0,
    LoadingTitle = "載入中...",
    LoadingSubtitle = "製作者 | 開發團隊",
    ShowText = "Rayfield", -- for mobile users to unhide Rayfield, change if you'd like
    Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes
 
    ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)
 
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false, -- Prevents Rayfield from emitting warnings when the script has a version mismatch with the interface.
 
    ConfigurationSaving = {
       Enabled = true,
       FolderName = RivalsUniversalUI, -- Create a custom folder for your hub/game
       FileName = "Config"
    },
 
    Discord = {
       Enabled = true, -- Prompt the user to join your Discord server if their executor supports it
       Invite = "VDCeKw5DKm", -- The Discord invite code, do not include Discord.gg/. E.g. Discord.gg/ABCD would be ABCD
       RememberJoins = false -- Set this to false to make them join the Discord every time they load it up
    },
 })

 local CombatTab = Window:CreateTab("Combat", "swords")
 local VisualsTab = Window:CreateTab("Visuals", "eye")
 local MovementTab = Window:CreateTab("Movement", "footprints")
 local MiscTab = Window:CreateTab("Misc", "menu")
 local SettingsTab = Window:CreateTab("Settings", "settings")

Rayfield:LoadConfiguration()
