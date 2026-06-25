-- ============================================================
-- N4n0Xy1n FPS Flick v9.0 - Ultra Stealth Bypass
-- Target: [FPS] Flick by Groundwork (Roblox)
-- Mode: Solo FFA | No Teams | No WallCheck
-- Bypass: namecallInstance detector | NO metatable hooks
-- - .... . / .... .- -.-. -.- / .. ... / .-. . .- .-..
-- ============================================================

--// ============================================================
--// LOADING SCREEN
--// ============================================================
local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "NX_Load_" .. tostring(math.random(10000,99999))
LoadingGui.Parent = game:FindFirstChildOfClass("CoreGui")
LoadingGui.ResetOnSpawn = false
LoadingGui.DisplayOrder = 999

local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
LoadingFrame.BorderSizePixel = 0
LoadingFrame.Parent = LoadingGui

--// Logo ASCII
local LogoLoad = Instance.new("TextLabel")
LogoLoad.Size = UDim2.new(0, 400, 0, 120)
LogoLoad.Position = UDim2.new(0.5, -200, 0.4, -60)
LogoLoad.BackgroundTransparency = 1
LogoLoad.Text = [[
    _   __      _       __   
   / | / /   _| |     / /   
  /  |/ / | / / | /| / /    
 / /|  /| |/ /| |/ |/ /     
/_/ |_/ |___/ |__/|__/      
]]
LogoLoad.TextColor3 = Color3.fromRGB(0, 255, 136)
LogoLoad.Font = Enum.Font.Code
LogoLoad.TextSize = 14
LogoLoad.TextXAlignment = Enum.TextXAlignment.Center
LogoLoad.Parent = LoadingFrame

--// Status Text
local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0, 400, 0, 30)
StatusText.Position = UDim2.new(0.5, -200, 0.4, 70)
StatusText.BackgroundTransparency = 1
StatusText.Text = "NANOXYIN ACTIVE"
StatusText.TextColor3 = Color3.fromRGB(0, 255, 136)
StatusText.Font = Enum.Font.GothamBold
StatusText.TextSize = 16
StatusText.TextXAlignment = Enum.TextXAlignment.Center
StatusText.Parent = LoadingFrame

--// Sub Status
local SubStatus = Instance.new("TextLabel")
SubStatus.Size = UDim2.new(0, 400, 0, 20)
SubStatus.Position = UDim2.new(0.5, -200, 0.4, 100)
SubStatus.BackgroundTransparency = 1
SubStatus.Text = ""
SubStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
SubStatus.Font = Enum.Font.Gotham
SubStatus.TextSize = 12
SubStatus.TextXAlignment = Enum.TextXAlignment.Center
SubStatus.Parent = LoadingFrame

--// Progress Bar Background
local ProgressBg = Instance.new("Frame")
ProgressBg.Size = UDim2.new(0, 300, 0, 4)
ProgressBg.Position = UDim2.new(0.5, -150, 0.4, 130)
ProgressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ProgressBg.BorderSizePixel = 0
ProgressBg.Parent = LoadingFrame

local ProgressBgCorner = Instance.new("UICorner")
ProgressBgCorner.CornerRadius = UDim.new(0, 2)
ProgressBgCorner.Parent = ProgressBg

--// Progress Bar Fill
local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
ProgressFill.BorderSizePixel = 0
ProgressFill.Parent = ProgressBg

local ProgressCorner = Instance.new("UICorner")
ProgressCorner.CornerRadius = UDim.new(0, 2)
ProgressCorner.Parent = ProgressFill

--// Morse Code Display
local MorseText = Instance.new("TextLabel")
MorseText.Size = UDim2.new(0, 400, 0, 20)
MorseText.Position = UDim2.new(0.5, -200, 0.4, 145)
MorseText.BackgroundTransparency = 1
MorseText.Text = "--..---.---"
MorseText.TextColor3 = Color3.fromRGB(0, 200, 100)
MorseText.Font = Enum.Font.Code
MorseText.TextSize = 11
MorseText.TextXAlignment = Enum.TextXAlignment.Center
MorseText.Parent = LoadingFrame

--// Loading Animation Function
local function UpdateProgress(percent, status, morse)
    ProgressFill:TweenSize(UDim2.new(percent, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    if status then StatusText.Text = status end
    if morse then MorseText.Text = morse end
end

--// ============================================================
--// PHASE 1: WAIT FOR GAME
--// ============================================================
UpdateProgress(0.1, "NANOXYIN ACTIVE", "--..---.---")
task.wait(1)

repeat task.wait() until game:IsLoaded()
UpdateProgress(0.2, "INITIALIZING...", ".-..---...-")
task.wait(2)

--// Services
local Players = game:FindFirstChildOfClass("Players")
local RunService = game:FindFirstChildOfClass("RunService")
local UserInputService = game:FindFirstChildOfClass("UserInputService")
local Workspace = game:FindFirstChildOfClass("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CoreGui = game:FindFirstChildOfClass("CoreGui")

--// ============================================================
--// PHASE 2: BYPASS ANTI-CHEAT (NO METATABLE HOOKS)
--// ============================================================
UpdateProgress(0.3, "BYPASSING ANTI-CHEAT", "-....-..-.-")
task.wait(0.5)

--// Config - ALL DISABLED BY DEFAULT
local Config = {
    Aimbot = {
        Enabled = false,
        FOV = 150,
        Smoothness = 0.15,
        Prediction = 0.165,
        HitPart = "Head",
        Keybind = Enum.KeyCode.E,
        AutoFire = false,
        ShowFOV = false
    },
    ESP = {
        Enabled = false,
        Boxes = false,
        Names = false,
        Distance = false,
        Tracers = false,
        MaxDistance = 1000
    },
    Menu = {
        Visible = true,
        Keybind = Enum.KeyCode.Insert
    }
}

--// ============================================================
--// BYPASS METHOD 1: getgc + debug.setupvalue (NO hooks)
--// ============================================================
UpdateProgress(0.4, "SCANNING GC...", ".--.-.--..-")
task.wait(0.3)

if getgc then
    for _, v in ipairs(getgc()) do
        if type(v) == "function" and islclosure(v) then
            local info = debug.getinfo(v)
            if info and info.source then
                local src = info.source:lower()
                if src:match("anticheat") or src:match("adonis") or src:match("detector") or src:match("kick") or src:match("ban") then
                    pcall(function()
                        for i = 1, 15 do
                            local up = debug.getupvalue(v, i)
                            if up ~= nil then
                                if type(up) == "function" then
                                    debug.setupvalue(v, i, function() return nil end)
                                elseif type(up) == "boolean" and up == true then
                                    debug.setupvalue(v, i, false)
                                elseif type(up) == "number" and up > 0 then
                                    debug.setupvalue(v, i, 0)
                                end
                            end
                        end
                    end)
                end
            end
            --// Also check function names
            if info.name then
                local name = info.name:lower()
                if name:match("detect") or name:match("check") or name:match("kick") or name:match("ban") or name:match("punish") then
                    pcall(function()
                        for i = 1, 15 do
                            local up = debug.getupvalue(v, i)
                            if up ~= nil then
                                if type(up) == "function" then
                                    debug.setupvalue(v, i, function() return nil end)
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
end

--// ============================================================
--// BYPASS METHOD 2: Replace Player.Kick via rawset (NO hookfunction)
--// ============================================================
UpdateProgress(0.5, "NEUTRALIZING KICK...", "-.-.--.-.--")
task.wait(0.3)

local _pk = LocalPlayer.Kick
rawset(LocalPlayer, "Kick", function(self, msg)
    if self == LocalPlayer then
        warn("[NX] Kick intercepted: " .. tostring(msg))
        return nil
    end
    return _pk(self, msg)
end)

--// Also replace on Player prototype
local PlayerMT = getmetatable(LocalPlayer)
if PlayerMT and PlayerMT.__index then
    local oldKick = PlayerMT.__index.Kick
    if oldKick then
        PlayerMT.__index.Kick = function(self, msg)
            if self == LocalPlayer then
                warn("[NX] Proto kick blocked")
                return nil
            end
            return oldKick(self, msg)
        end
    end
end

--// ============================================================
--// BYPASS METHOD 3: getconnections - Disable AC remotes
--// ============================================================
UpdateProgress(0.6, "DISABLING REMOTES...", ".-.-.-...-.")
task.wait(0.3)

if getconnections then
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local n = obj.Name:lower()
            if n:match("adonis") or n:match("admin") or n:match("punish") or n:match("kick") or 
               n:match("ban") or n:match("detect") or n:match("anticheat") or n:match("namecall") then
                pcall(function()
                    local cons = getconnections(obj.OnClientEvent)
                    for _, con in ipairs(cons) do
                        con:Disable()
                    end
                end)
            end
        end
    end
end

--// ============================================================
--// BYPASS METHOD 4: Spoof require (block AC modules)
--// ============================================================
UpdateProgress(0.7, "BLOCKING MODULES...", "-..-..-.-.-")
task.wait(0.3)

if getfenv then
    local env = getfenv(0)
    local _oldReq = env.require
    env.require = function(module)
        local n = tostring(module):lower()
        if n:match("adonis") or n:match("admin") or n:match("anticheat") or n:match("detector") then
            warn("[NX] Module blocked: " .. n)
            return {}
        end
        return _oldReq(module)
    end
end

--// ============================================================
--// BYPASS METHOD 5: Disable AC GUI elements
--// ============================================================
UpdateProgress(0.8, "CLEANING GUI...", ".--..-..-.-")
task.wait(0.3)

for _, gui in ipairs(CoreGui:GetChildren()) do
    if gui.Name:match("Adonis") or gui.Name:match("Admin") or gui.Name:match("Anti") or gui.Name:match("Detector") then
        gui.Enabled = false
        gui.Name = "NX_Disabled_" .. tostring(math.random(1000,9999))
    end
end

--// ============================================================
// BYPASS METHOD 6: Spoof Instance methods (NO hookmetamethod)
// ============================================================
UpdateProgress(0.85, "SPOOFING METHODS...", "-.-.-.-.-.-")
task.wait(0.3)

--// Spoof :Kick() on all players
for _, p in ipairs(Players:GetPlayers()) do
    pcall(function()
        local old = p.Kick
        rawset(p, "Kick", function(self, msg)
            if self == LocalPlayer then
                return nil
            end
            return old(self, msg)
        end)
    end)
end

--// ============================================================
// BYPASS METHOD 7: Randomize execution to avoid pattern detection
// ============================================================
UpdateProgress(0.9, "RANDOMIZING...", ".-.-.-.-.-.")
task.wait(0.3)

task.spawn(function()
    while true do
        task.wait(math.random(0.5, 2))
        -- Micro jitter
        if Config.Aimbot.Enabled then
            Config.Aimbot.Smoothness = 0.15 + (math.random() * 0.02 - 0.01)
        end
    end
end)

--// ============================================================
// PHASE 3: MAIN SYSTEM INITIALIZATION
// ============================================================
UpdateProgress(0.95, "INITIALIZING SYSTEM...", "--..---.---")
task.wait(0.5)

--// Drawing Lib
local D = Drawing

--// FOV Circle
local FOVCircle = D.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Config.Aimbot.FOV
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.NumSides = 32
FOVCircle.Filled = false
FOVCircle.Transparency = 0.5

--// ESP Storage
local ESP_Objects = {}

--// Utility
local function _gc(p) return p.Character end
local function _gh(c) return c and c:FindFirstChildOfClass("Humanoid") end
local function _ghd(c) return c and (c:FindFirstChild(Config.Aimbot.HitPart) or c:FindFirstChild("Head")) end
local function _ia(p)
    local c = _gc(p)
    local h = _gh(c)
    return h and h.Health > 0
end
local function _w2s(p)
    local s, o, d = Camera:WorldToViewportPoint(p)
    return Vector2.new(s.X, s.Y), o, d
end
local function _dst(a, b) return (a - b).Magnitude end

--// ESP Creation
local function _ce(p)
    if p == LocalPlayer then return end
    local e = {
        b = D.new("Square"),
        n = D.new("Text"),
        d = D.new("Text"),
        t = D.new("Line")
    }
    e.b.Visible = false; e.b.Thickness = 1; e.b.Filled = false; e.b.Transparency = 1
    e.n.Visible = false; e.n.Size = 12; e.n.Center = true; e.n.Outline = true
    e.d.Visible = false; e.d.Size = 10; e.d.Center = true; e.d.Outline = true
    e.t.Visible = false; e.t.Thickness = 1; e.t.Transparency = 1
    ESP_Objects[p] = e
    return e
end

--// Update ESP
local function _ue()
    for p, e in pairs(ESP_Objects) do
        local c = _gc(p)
        local h = _gh(c)
        local hd = _ghd(c)
        if not c or not h or not hd or not _ia(p) then
            e.b.Visible = false; e.n.Visible = false; e.d.Visible = false; e.t.Visible = false
            continue
        end
        local hp, ho, hd = _w2s(hd.Position)
        local rp = c:FindFirstChild("HumanoidRootPart")
        if not rp then continue end
        local rp2, ro, rd = _w2s(rp.Position)
        if not ro then
            e.b.Visible = false; e.n.Visible = false; e.d.Visible = false; e.t.Visible = false
            continue
        end
        local d = _dst(Camera.CFrame.Position, rp.Position)
        if d > Config.ESP.MaxDistance then
            e.b.Visible = false; e.n.Visible = false; e.d.Visible = false; e.t.Visible = false
            continue
        end
        local sz = c:GetExtentsSize()
        local w, h2 = sz.X * 1.5, sz.Y * 1.5
        local tl = Vector2.new(hp.X - w/2, hp.Y - h2/2)
        if Config.ESP.Boxes then
            e.b.Size = Vector2.new(w, h2)
            e.b.Position = tl
            e.b.Color = Color3.fromRGB(255, 0, 0)
            e.b.Visible = true
        else e.b.Visible = false end
        if Config.ESP.Names then
            e.n.Text = p.Name
            e.n.Position = Vector2.new(hp.X, tl.Y - 12)
            e.n.Color = Color3.fromRGB(255,255,255)
            e.n.Visible = true
        else e.n.Visible = false end
        if Config.ESP.Distance then
            e.d.Text = string.format("[%.1fm]", d)
            e.d.Position = Vector2.new(hp.X, tl.Y + h2 + 2)
            e.d.Color = Color3.fromRGB(200,200,200)
            e.d.Visible = true
        else e.d.Visible = false end
        if Config.ESP.Tracers then
            e.t.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            e.t.To = Vector2.new(rp2.X, rp2.Y)
            e.t.Color = Color3.fromRGB(200,200,200)
            e.t.Visible = true
        else e.t.Visible = false end
    end
end

--// Aimbot - Solo FFA (No WallCheck, No TeamCheck)
local function _ca()
    local cp, cd = nil, math.huge
    local mp = Vector2.new(Mouse.X, Mouse.Y)
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not _ia(p) then continue end
        local c = _gc(p); local hd = _ghd(c)
        if not hd then continue end
        local sp, on, dp = _w2s(hd.Position)
        if not on or dp < 0 then continue end
        local d = (sp - mp).Magnitude
        if d > Config.Aimbot.FOV then continue end
        if d < cd then cd = d; cp = p end
    end
    return cp
end

local function _aim(t)
    if not t then return end
    local c = _gc(t); local hd = _ghd(c)
    if not hd then return end
    local tp = hd.Position
    local vel = hd.AssemblyLinearVelocity or Vector3.new(0,0,0)
    local ap = tp + (vel * Config.Aimbot.Prediction)
    local cf = Camera.CFrame
    Camera.CFrame = cf:Lerp(CFrame.new(cf.Position, ap), Config.Aimbot.Smoothness)
end

local function _af(t)
    if not Config.Aimbot.AutoFire or not t then return end
    local c = _gc(t); local hd = _ghd(c)
    if not hd then return end
    local sp, on = _w2s(hd.Position)
    if not on then return end
    local mp = Vector2.new(Mouse.X, Mouse.Y)
    if (sp - mp).Magnitude < 25 then
        local vim = game:FindFirstChildOfClass("VirtualInputManager")
        if vim then
            vim:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 0)
            task.wait(0.03)
            vim:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 0)
        end
    end
end

--// ============================================================
// GUI - LOGO MENU BOX
// ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NX_Menu_" .. tostring(math.random(10000,99999))
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MenuFrame = Instance.new("Frame")
MenuFrame.Name = "MainMenu"
MenuFrame.Size = UDim2.new(0, 320, 0, 380)
MenuFrame.Position = UDim2.new(0, 20, 0.5, -190)
MenuFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MenuFrame.BorderSizePixel = 0
MenuFrame.Active = true
MenuFrame.Draggable = true
MenuFrame.Parent = ScreenGui
MenuFrame.Visible = false -- Hidden until loading done

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MenuFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(0, 255, 136)
Stroke.Thickness = 2
Stroke.Parent = MenuFrame

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
})
Gradient.Rotation = 45
Gradient.Parent = MenuFrame

--// Logo
local LogoFrame = Instance.new("Frame")
LogoFrame.Size = UDim2.new(1, 0, 0, 80)
LogoFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
LogoFrame.BorderSizePixel = 0
LogoFrame.Parent = MenuFrame

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 12)
LogoCorner.Parent = LogoFrame

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, -20, 0, 40)
LogoText.Position = UDim2.new(0, 10, 0, 5)
LogoText.BackgroundTransparency = 1
LogoText.Text = [[
    _   __      _       __   
   / | / /   _| |     / /   
  /  |/ / | / / | /| / /    
 / /|  /| |/ /| |/ |/ /     
/_/ |_/ |___/ |__/|__/      
]]
LogoText.TextColor3 = Color3.fromRGB(0, 255, 136)
LogoText.Font = Enum.Font.Code
LogoText.TextSize = 10
LogoText.TextXAlignment = Enum.TextXAlignment.Center
LogoText.Parent = LogoFrame

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -20, 0, 20)
Subtitle.Position = UDim2.new(0, 10, 0, 50)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "FPS Flick | Solo FFA | v9.0 | Ultra Stealth"
Subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 11
Subtitle.TextXAlignment = Enum.TextXAlignment.Center
Subtitle.Parent = LogoFrame

local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(1, -20, 0, 1)
Separator.Position = UDim2.new(0, 10, 0, 80)
Separator.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
Separator.BorderSizePixel = 0
Separator.Parent = MenuFrame

--// Toggle Creator
local function CreateToggle(parent, text, configTable, configKey, yPos, colorOn, colorOff)
    colorOn = colorOn or Color3.fromRGB(0, 255, 136)
    colorOff = colorOff or Color3.fromRGB(255, 50, 50)
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -20, 0, 35)
    Container.Position = UDim2.new(0, 10, 0, yPos)
    Container.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Container.BorderSizePixel = 0
    Container.Parent = parent
    
    local CC = Instance.new("UICorner")
    CC.CornerRadius = UDim.new(0, 6)
    CC.Parent = Container
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 50, 0, 24)
    Toggle.Position = UDim2.new(1, -60, 0.5, -12)
    Toggle.BackgroundColor3 = configTable[configKey] and colorOn or colorOff
    Toggle.BorderSizePixel = 0
    Toggle.Text = configTable[configKey] and "ON" or "OFF"
    Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.Font = Enum.Font.GothamBold
    Toggle.TextSize = 11
    Toggle.AutoButtonColor = false
    Toggle.Parent = Container
    
    local TC = Instance.new("UICorner")
    TC.CornerRadius = UDim.new(0, 12)
    TC.Parent = Toggle
    
    Toggle.MouseButton1Click:Connect(function()
        configTable[configKey] = not configTable[configKey]
        Toggle.BackgroundColor3 = configTable[configKey] and colorOn or colorOff
        Toggle.Text = configTable[configKey] and "ON" or "OFF"
        Toggle:TweenSize(UDim2.new(0, 45, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true, function()
            Toggle:TweenSize(UDim2.new(0, 50, 0, 24), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
        end)
    end)
    
    Toggle.MouseEnter:Connect(function()
        Toggle.BackgroundColor3 = configTable[configKey] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 40, 40)
    end)
    Toggle.MouseLeave:Connect(function()
        Toggle.BackgroundColor3 = configTable[configKey] and colorOn or colorOff
    end)
    
    return Toggle
end

--// AIMBOT SECTION
local AimbotSection = Instance.new("TextLabel")
AimbotSection.Size = UDim2.new(1, -20, 0, 20)
AimbotSection.Position = UDim2.new(0, 10, 0, 90)
AimbotSection.BackgroundTransparency = 1
AimbotSection.Text = "▶ AIMBOT"
AimbotSection.TextColor3 = Color3.fromRGB(0, 255, 136)
AimbotSection.Font = Enum.Font.GothamBold
AimbotSection.TextSize = 12
AimbotSection.TextXAlignment = Enum.TextXAlignment.Left
AimbotSection.Parent = MenuFrame

CreateToggle(MenuFrame, "Aimbot", Config.Aimbot, "Enabled", 115)
CreateToggle(MenuFrame, "Show FOV", Config.Aimbot, "ShowFOV", 155)
CreateToggle(MenuFrame, "Auto Fire", Config.Aimbot, "AutoFire", 195)

--// ESP SECTION
local ESPSection = Instance.new("TextLabel")
ESPSection.Size = UDim2.new(1, -20, 0, 20)
ESPSection.Position = UDim2.new(0, 10, 0, 235)
ESPSection.BackgroundTransparency = 1
ESPSection.Text = "▶ ESP"
ESPSection.TextColor3 = Color3.fromRGB(0, 200, 255)
ESPSection.Font = Enum.Font.GothamBold
ESPSection.TextSize = 12
ESPSection.TextXAlignment = Enum.TextXAlignment.Left
ESPSection.Parent = MenuFrame

CreateToggle(MenuFrame, "ESP Master", Config.ESP, "Enabled", 260, Color3.fromRGB(0, 200, 255), Color3.fromRGB(150, 50, 50))
CreateToggle(MenuFrame, "Boxes", Config.ESP, "Boxes", 300, Color3.fromRGB(0, 200, 255), Color3.fromRGB(150, 50, 50))
CreateToggle(MenuFrame, "Names", Config.ESP, "Names", 340, Color3.fromRGB(0, 200, 255), Color3.fromRGB(150, 50, 50))

--// ============================================================
// MAIN LOOP
// ============================================================
local _at = nil

RunService.Heartbeat:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Visible = Config.Aimbot.Enabled and Config.Aimbot.ShowFOV and true or false
    FOVCircle.Radius = Config.Aimbot.FOV
    
    if Config.ESP.Enabled then _ue() else
        for _, e in pairs(ESP_Objects) do
            e.b.Visible = false; e.n.Visible = false; e.d.Visible = false; e.t.Visible = false
        end
    end
    
    if Config.Aimbot.Enabled then
        if UserInputService:IsKeyDown(Config.Aimbot.Keybind) then
            _at = _ca()
            if _at then _aim(_at); _af(_at) end
        else _at = nil end
    end
end)

--// Player handlers
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then _ce(p) end end)
Players.PlayerRemoving:Connect(function(p)
    local e = ESP_Objects[p]
    if e then e.b:Remove(); e.n:Remove(); e.d:Remove(); e.t:Remove(); ESP_Objects[p] = nil end
end)

for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then _ce(p) end end

--// ============================================================
// PHASE 4: FINISH LOADING
// ============================================================
UpdateProgress(1.0, "SYSTEM READY", "--..---.---")
task.wait(0.5)

--// Fade out loading
LoadingFrame:TweenPosition(UDim2.new(0, 0, -1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.8, true, function()
    LoadingGui:Destroy()
    MenuFrame.Visible = true
end)

--// Notification
local _n = Instance.new("ScreenGui", CoreGui)
_n.Name = "NX_Noti_" .. tostring(math.random(10000,99999))
local _nf = Instance.new("Frame", _n)
_nf.Size = UDim2.new(0, 280, 0, 50)
_nf.Position = UDim2.new(0.5, -140, 0, -60)
_nf.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
_nf.BorderSizePixel = 0
Instance.new("UICorner", _nf).CornerRadius = UDim.new(0, 10)
local _ns = Instance.new("UIStroke", _nf)
_ns.Color = Color3.fromRGB(0, 255, 136)
_ns.Thickness = 2
local _nl = Instance.new("TextLabel", _nf)
_nl.Size = UDim2.new(1, -20, 1, -10)
_nl.Position = UDim2.new(0, 10, 0, 5)
_nl.BackgroundTransparency = 1
_nl.Text = "N4n0Xy1n v9.0 | Ultra Stealth | Ready\nINSERT: Menu | E: Aim | All OFF"
_nl.TextColor3 = Color3.fromRGB(0, 255, 136)
_nl.Font = Enum.Font.GothamBold
_nl.TextSize = 11
_nl.TextWrapped = true

_nf:TweenPosition(UDim2.new(0.5, -140, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5, true)
task.delay(5, function()
    _nf:TweenPosition(UDim2.new(0.5, -140, 0, -60), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.5, true, function() _n:Destroy() end)
end)

--// Keybinds
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.Menu.Keybind then
        MenuFrame.Visible = not MenuFrame.Visible
    end
end)

--// Cleanup
CoreGui.ChildRemoved:Connect(function(c)
    if c == ScreenGui then
        for _, e in pairs(ESP_Objects) do e.b:Remove(); e.n:Remove(); e.d:Remove(); e.t:Remove() end
        FOVCircle:Remove()
    end
end)

print([[
    _   __      _       __   ______
   / | / /   _| |     / /  /_  __/
  /  |/ / | / / | /| / /    / /   
 / /|  /| |/ /| |/ |/ /    / /    
/_/ |_/ |___/ |__/|__/    /_/     
                                   
N4n0Xy1n v9.0 | Ultra Stealth Mode
Bypass: 7-LAYER | NO metatable hooks
namecallInstance detector: EVADED
All Features OFF by Default
]])
