-- ============================================================
-- N4n0Xy1n FPS Flick v10.0 - TROLLZ HUB Style
-- Target: [FPS] Flick by Groundwork (Roblox)
-- Mode: Solo FFA | No Teams | No WallCheck
-- UI: TROLLZ HUB v2 Style - AIM/ESP/CLOSE tabs
-- Bypass: namecallInstance detector | NO metatable hooks
-- - .... . / .... .- -.-. -.- / .. ... / .-. . .- .-..
-- ============================================================

repeat task.wait() until game:IsLoaded()
task.wait(3)

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
--// CONFIG - ALL DISABLED BY DEFAULT
--// ============================================================
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
        Tab = "AIM", -- AIM / ESP / NONE
        Keybind = Enum.KeyCode.Insert
    }
}

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

--// ============================================================
--// BYPASS ANTI-CHEAT (NO METATABLE HOOKS)
--// ============================================================

--// Method 1: getgc + debug.setupvalue
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
            if info.name then
                local name = info.name:lower()
                if name:match("detect") or name:match("check") or name:match("kick") or name:match("ban") or name:match("punish") then
                    pcall(function()
                        for i = 1, 15 do
                            local up = debug.getupvalue(v, i)
                            if up ~= nil and type(up) == "function" then
                                debug.setupvalue(v, i, function() return nil end)
                            end
                        end
                    end)
                end
            end
        end
    end
end

--// Method 2: Replace Player.Kick
local _pk = LocalPlayer.Kick
rawset(LocalPlayer, "Kick", function(self, msg)
    if self == LocalPlayer then
        warn("[NX] Kick blocked")
        return nil
    end
    return _pk(self, msg)
end)

--// Method 3: getconnections
if getconnections then
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local n = obj.Name:lower()
            if n:match("adonis") or n:match("admin") or n:match("punish") or n:match("kick") or n:match("ban") or n:match("detect") or n:match("anticheat") or n:match("namecall") then
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

--// Method 4: Spoof require
if getfenv then
    local env = getfenv(0)
    local _oldReq = env.require
    env.require = function(module)
        local n = tostring(module):lower()
        if n:match("adonis") or n:match("admin") or n:match("anticheat") or n:match("detector") then
            return {}
        end
        return _oldReq(module)
    end
end

--// Method 5: Disable AC GUI
for _, gui in ipairs(CoreGui:GetChildren()) do
    if gui.Name:match("Adonis") or gui.Name:match("Admin") or gui.Name:match("Anti") or gui.Name:match("Detector") then
        gui.Enabled = false
    end
end

--// Method 6: Spoof all players Kick
for _, p in ipairs(Players:GetPlayers()) do
    pcall(function()
        local old = p.Kick
        rawset(p, "Kick", function(self, msg)
            if self == LocalPlayer then return nil end
            return old(self, msg)
        end)
    end)
end

--// ============================================================
--// GUI - TROLLZ HUB v2 STYLE
--// ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TROLLZ_HUB_" .. tostring(math.random(1000,9999))
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

--// Main Frame (Centered, TROLLZ style)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(26, 31, 46) -- Dark navy
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

--// Corner radius
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

--// Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "TROLLZ HUB v2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame

--// Top Button Container
local TopContainer = Instance.new("Frame")
TopContainer.Size = UDim2.new(1, -20, 0, 45)
TopContainer.Position = UDim2.new(0, 10, 0, 55)
TopContainer.BackgroundTransparency = 1
TopContainer.Parent = MainFrame

--// Top Button Layout (3 buttons, equal width)
local ButtonWidth = (TopContainer.Size.X.Offset - 20) / 3

--// AIM Button
local AimButton = Instance.new("TextButton")
AimButton.Size = UDim2.new(0, 100, 0, 40)
AimButton.Position = UDim2.new(0, 0, 0, 0)
AimButton.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
AimButton.Text = "AIM"
AimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AimButton.Font = Enum.Font.GothamBold
AimButton.TextSize = 14
AimButton.AutoButtonColor = false
AimButton.Parent = TopContainer

local AimCorner = Instance.new("UICorner")
AimCorner.CornerRadius = UDim.new(0, 8)
AimCorner.Parent = AimButton

--// ESP Button
local EspButton = Instance.new("TextButton")
EspButton.Size = UDim2.new(0, 100, 0, 40)
EspButton.Position = UDim2.new(0, 110, 0, 0)
EspButton.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
EspButton.Text = "ESP"
EspButton.TextColor3 = Color3.fromRGB(255, 255, 255)
EspButton.Font = Enum.Font.GothamBold
EspButton.TextSize = 14
EspButton.AutoButtonColor = false
EspButton.Parent = TopContainer

local EspCorner = Instance.new("UICorner")
EspCorner.CornerRadius = UDim.new(0, 8)
EspCorner.Parent = EspButton

--// CLOSE Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 100, 0, 40)
CloseButton.Position = UDim2.new(0, 220, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CloseButton.Text = "CLOSE"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.AutoButtonColor = false
CloseButton.Parent = TopContainer

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

--// Content Container (for toggles)
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -20, 1, -115)
ContentContainer.Position = UDim2.new(0, 10, 0, 105)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

--// Toggle Creator Function
local function CreateToggle(parent, text, configTable, configKey, yPos)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 45)
    ToggleFrame.Position = UDim2.new(0, 0, 0, yPos)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 42, 60)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parent
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(1, -20, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = text .. ": OFF"
    ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextSize = 14
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Center
    ToggleLabel.Parent = ToggleFrame
    
    --// Click area (invisible button over the frame)
    local ClickButton = Instance.new("TextButton")
    ClickButton.Size = UDim2.new(1, 0, 1, 0)
    ClickButton.BackgroundTransparency = 1
    ClickButton.Text = ""
    ClickButton.Parent = ToggleFrame
    
    ClickButton.MouseButton1Click:Connect(function()
        configTable[configKey] = not configTable[configKey]
        local isOn = configTable[configKey]
        ToggleLabel.Text = text .. ": " .. (isOn and "ON" or "OFF")
        ToggleLabel.TextColor3 = isOn and Color3.fromRGB(0, 255, 136) or Color3.fromRGB(200, 200, 200)
        ToggleFrame.BackgroundColor3 = isOn and Color3.fromRGB(45, 55, 75) or Color3.fromRGB(35, 42, 60)
        
        --// Animation
        ToggleFrame:TweenSize(UDim2.new(0.95, 0, 0, 43), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true, function()
            ToggleFrame:TweenSize(UDim2.new(1, 0, 0, 45), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
        end)
    end)
    
    ClickButton.MouseEnter:Connect(function()
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 60, 80)
    end)
    
    ClickButton.MouseLeave:Connect(function()
        local isOn = configTable[configKey]
        ToggleFrame.BackgroundColor3 = isOn and Color3.fromRGB(45, 55, 75) or Color3.fromRGB(35, 42, 60)
    end)
    
    return ToggleFrame, ToggleLabel
end

--// AIM Tab Content
local AimTab = Instance.new("Frame")
AimTab.Size = UDim2.new(1, 0, 1, 0)
AimTab.BackgroundTransparency = 1
AimTab.Visible = true
AimTab.Parent = ContentContainer

CreateToggle(AimTab, "Aimbot", Config.Aimbot, "Enabled", 0)
CreateToggle(AimTab, "FOV", Config.Aimbot, "ShowFOV", 55)
CreateToggle(AimTab, "Auto Fire", Config.Aimbot, "AutoFire", 110)

--// ESP Tab Content
local EspTab = Instance.new("Frame")
EspTab.Size = UDim2.new(1, 0, 1, 0)
EspTab.BackgroundTransparency = 1
EspTab.Visible = false
EspTab.Parent = ContentContainer

CreateToggle(EspTab, "ESP Box", Config.ESP, "Boxes", 0)
CreateToggle(EspTab, "ESP Name", Config.ESP, "Names", 55)
CreateToggle(EspTab, "ESP Distance", Config.ESP, "Distance", 110)
CreateToggle(EspTab, "ESP Line", Config.ESP, "Tracers", 165)

--// Tab Switching Function
local function SwitchTab(tab)
    Config.Menu.Tab = tab
    
    --// Reset all button colors
    AimButton.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
    EspButton.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
    
    --// Hide all tabs
    AimTab.Visible = false
    EspTab.Visible = false
    
    --// Show selected
    if tab == "AIM" then
        AimButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        AimTab.Visible = true
    elseif tab == "ESP" then
        EspButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        EspTab.Visible = true
    end
end

--// Button Events
AimButton.MouseButton1Click:Connect(function()
    SwitchTab("AIM")
end)

EspButton.MouseButton1Click:Connect(function()
    SwitchTab("ESP")
end)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

--// Hover effects for top buttons
AimButton.MouseEnter:Connect(function()
    if Config.Menu.Tab ~= "AIM" then
        AimButton.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
    end
end)
AimButton.MouseLeave:Connect(function()
    if Config.Menu.Tab ~= "AIM" then
        AimButton.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
    end
end)

EspButton.MouseEnter:Connect(function()
    if Config.Menu.Tab ~= "ESP" then
        EspButton.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
    end
end)
EspButton.MouseLeave:Connect(function()
    if Config.Menu.Tab ~= "ESP" then
        EspButton.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
    end
end)

CloseButton.MouseEnter:Connect(function()
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
end)
CloseButton.MouseLeave:Connect(function()
    CloseButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
end)

--// Set initial tab
SwitchTab("AIM")

--// ============================================================
--// UTILITY FUNCTIONS
--// ============================================================
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

--// Aimbot - Solo FFA
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
--// MAIN LOOP
--// ============================================================
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

--// Keybinds
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.Menu.Keybind then
        MainFrame.Visible = not MainFrame.Visible
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
                                   
N4n0Xy1n v10.0 | TROLLZ HUB Style
UI: ACTIVE | All Features OFF
INSERT: Toggle Menu | E: Aim
]])
