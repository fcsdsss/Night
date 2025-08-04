if not game:IsLoaded() then
    game.Loaded:Wait()
end

local NightInit = getgenv().NightInit :: {}

if getgenv().Night then
    return error("Night is already loaded.")
end

local Night = {
    Version = "",
    Dev = false,
    Connections = {},
    Pages = {},
    Tabs = {Tabs = {}},
    Corners = {},
    Load = os.clock(),
    Notifications = {Objects = {}, Active = {}},
    ArrayList = {Objects = {}, Loaded = false},
    ControlsVisible = true,
    Mobile = false,
    CurrentOpenTab = nil,
    GameSave = game.PlaceId,
    CheckOtherConfig = true,
    Assets = {},
    Teleporting = false,
    InitSave = nil,
    Config = {
        UI = {
            Position = {X = 0.5, Y = 0.5},
            Size = {X = 0.37294304370880129, Y = 0.683131217956543},
            FullScreen = false,
            ToggleKeyCode = "LeftAlt",
            Scale = 1,
            Notifications = true,
            Anim = true,
            ArrayList = false,
            TabColor = {value1 = 25, value2 = 25, value3 = 25},
            TabTransparency = 0.03,
            KeybindTransparency = 0.7,
            KeybindColor = {value1 = 0, value2 = 0, value3 = 0},
        },
        Game = {
            Modules = {},
            Keybinds = {},
            Sliders = {},
            TextBoxes = {},
            MiniToggles = {},
            Dropdowns = {},
            ModuleKeybinds = {},
            Other = {}
        },
    },
    Directories = {
        "Night",
        "Night/Config",
        "Night/Assets",
        "Night/Assets/Fonts"
    }
}

getgenv().Night = Night

for i,v: string in Night.Directories do 
    if not isfolder(v) then
        makefolder(v)
    end
end

if NightInit then
    for i,v in NightInit do
        Night[i] = v 
    end

    Night.InitSave = NightInit
    getgenv().NightInit = nil
end

-- 这里是关键的改动部分
if Night.Premium then
    if Night.Dev and isfile("Night/Premium/Init.lua") then
        loadstring(readfile("Night/Premium/Init.lua"))()
    else
        -- 如果您有Premium版本，也需要修改这里的URL
        loadstring(game:HttpGet("https://raw.githubusercontent.com/fcsdsss/Night/refs/heads/main/Night/Premium/Init.lua"))()
    end
else
    if Night.Dev and isfile("Night/Library/Init.lua") then
        loadstring(readfile("Night/Library/Init.lua"))()
    else
        -- 主要改动：下面的 URL 已被替换为您自己 Fork 仓库的地址。
        -- 原地址是：.../null-wtf/Night/...
        -- 新地址是：.../fcsdsss/Night/...
        loadstring(game:HttpGet("https://raw.githubusercontent.com/fcsdsss/Night/refs/heads/main/Night/Library/Init.lua"))()
    end
end

local Assets = getgenv().Night.Assets
if not Assets or typeof(Assets) ~= "table" or (Assets and not Assets.Functions) then
    table.clear(Night)
    return warn("Failed to load Functions, Night uninjected")
end

local UserInputService = Assets.Functions.cloneref(game:GetService("UserInputService")) :: UserInputService
local Workspace = Assets.Functions.cloneref(game:GetService("Workspace")) :: Workspace
local Players = Assets.Functions.cloneref(game:GetService("Players")) :: Players
local Camera = Workspace:FindFirstChildWhichIsA("Camera") :: Camera

if not UserInputService.KeyboardEnabled and UserInputService.TouchEnabled then
    Night.Mobile = true
    Night.Config.UI.Size = {X = 0.7, Y = 0.9}
end

local GameData = Assets.Functions.GetGameInfo()
local UIConfig = Assets.Config.Load("UI", "UI")
local GameConfig = Assets.Config.Load(tostring(Night.GameSave), "Game")

if typeof(GameData) == "table" then
    Night.GameRootId = GameData.rootPlaceId 
    if Night.GameSave == "root" then
        Night.GameSave = tostring(Night.GameRootId)
    end
end

if UIConfig == "no file" then
    Assets.Config.Save("UI", Night.Config.UI)
end

if GameConfig == "no file" and Night.CheckOtherConfig then
    if Night.GameRootId == Night.GameSave then
        GameConfig = Assets.Config.Load(tostring(game.PlaceId), "Game")
    else
        GameConfig = Assets.Config.Load(tostring(Night.GameRootId), "Game")
    end
end

if GameConfig == "no file" then
    Assets.Config.Save(tostring(Night.GameSave), getgenv().Night.Config.Game)
end

-- Assets.Main.Load("Universal")
Assets.Main.Load(getgenv().Night.GameSave)
Assets.Main.ToggleVisibility(true)

if queue_on_teleport then
    table.insert(Night.Connections, Players.LocalPlayer.OnTeleport:Connect(function(state)
        if not Night.Teleporting then
            Night.Teleporting = true
            
            local TeleportData = ""
            if Night.InitSave then
                TeleportData = "getgenv().NightInit = {"
                for i, v in Night.InitSave do
                    if i ~= #Night.InitSave then
                        if typeof(v) == "string" then
                            TeleportData = TeleportData..tostring(i)..' = "'..tostring(v)..'" , '
                        else
                            TeleportData = TeleportData..tostring(i).." = "..tostring(v).." , "
                        end
                    end
                end

                TeleportData = string.sub(TeleportData, 0, #TeleportData-2).."}\n"
            end

            -- 这里的传送重载逻辑也已更新
            if Night.Premium then
                TeleportData = TeleportData..[[
                    if not game:IsLoaded() then
                        game.Loaded:Wait()
                    end

                    if getgenv().NightInit and getgenv().NightInit.Dev and isfile("Night/Premium/Loader.lua") then
                        loadstring(readfile("Night/Premium/Loader.lua"))()
                    else
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/fcsdsss/Night/refs/heads/main/Night/Premium/Loader.lua"))()
                    end
                ]]
            else
                TeleportData = TeleportData..[[
                    if not game:IsLoaded() then
                        game.Loaded:Wait()
                    end

                    if getgenv().NightInit and getgenv().NightInit.Dev and isfile("Night/Loader.lua") then
                        loadstring(readfile("Night/Loader.lua"))()
                    else
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/fcsdsss/Night/refs/heads/main/Night/Loader.luau"))()
                    end
                ]]
            end

            queue_on_teleport(TeleportData)
        end
    end))
end

if Night.Mobile then
    if Camera then
        if 0.4 >= (Camera.ViewportSize.X / 1000) - 0.1 then
            Night.Config.UI.Scale = 0.4
        else
            Night.Config.UI.Scale = (Camera.ViewportSize.X / 1000) - 0.1
        end
    end
end

Night.Main = Assets.Main
Night.LoadTime = os.clock() - Night.Load
Assets.Notifications.Send({
    Description = "Loaded in " .. string.format("%.1f", getgenv().Night.LoadTime) .. " seconds",
    Duration = 5
})

task.delay(0.2, function()
    if not isfile("Night/Version.txt") then
        writefile("Night/Version.txt", "Current version: " .. Night.Version)
        Assets.Notifications.Send({
            Description = "Night has been updated to " .. Night.Version,
            Duration = 15
        })
    else
        local BuildData = readfile("Night/Version.txt")
        if BuildData ~= "Current version: " .. Night.Version then
            Assets.Notifications.Send({
                Description = "Night has been updated to " .. Night.Version,
                Duration = 15
            })
            writefile("Night/Version.txt", "Current version: " .. Night.Version)
        end
    end
end)

Night.Loaded = true
return Assets.Main

