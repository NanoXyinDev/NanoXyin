-- ============================================================
-- N4n0Xy1n Murder Mystery 2 v12.0
-- Target: Murder Mystery 2 by Nikilis (Roblox)
-- Mode: Social Deduction / Murder Mystery
-- Features: Role ESP + Auto Shoot/Throw + Coin/Gun ESP + Alert
-- - .... . / .... .- -.-. -.- / .. ... / .-. . .- .-..
-- ============================================================

repeat task.wait() until game:IsLoaded()
task.wait(3)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--// ============================================================
--// CONFIG - ALL DISABLED BY DEFAULT
--// ============================================================
local Config = {
    RoleESP = {
        Enabled = false,
        Murderer = true,      -- Red highlight
        Sheriff = true,       -- Blue highlight
        Innocent = false,     -- Green highlight (optional)
        ShowRole = true,      -- Show role text
        ShowDistance = true
    },
    ItemESP = {
        Enabled = false,
        Coins = true,         -- Yellow
        GunDrop = true,       -- Cyan (when sheriff dies)
        Knife = false         -- Murderer knife
    },
    Auto = {
        Enabled = false,
        AutoShoot = false,    -- Sheriff auto aim murderer
        AutoThrow = false,    -- Murderer auto aim innocent
        FOV = 200,
        Smoothness = 0.12,
        Prediction = 0.1
    },
    Alert = {
        Enabled = false,
        MurdererNear = true,  -- Warning when murderer close
        Distance = 50
    },
    Menu = {
        Visible = true,
        Tab = "ROLE",
        Keybind = Enum.KeyCode.Insert
    }
}

--// Drawing Lib
local D = Drawing

--// ESP Storage
local PlayerESP = {}
local ItemESP = {}

--// Role Detection
local Roles = {
    Murderer = nil,
    Sheriff = nil,
    Innocents = {}
}

--// ============================================================
--// BYPASS ANTI-CHEAT (MM2 uses basic client-side AC)
--// ============================================================

if getgc then
    for _, v in ipairs(getgc()) do
        if type(v) == "function" and islclosure(v) then
            local info = debug.getinfo(v)
            if info and info.source then
                local src = info.source:lower()
                if src:match("anticheat") or src:match("detect") or src:match("kick") or src:match("ban") then
                    pcall(function()
                        for i = 1, 10 do
                            local up = debug.getupvalue(v, i)
                            if up ~= nil then
                                if type(up) == "function" then
                                    debug.setupvalue(v, i, function() return nil end)
                                elseif type(up) == "boolean" and up == true then
                                    debug.setupvalue(v, i, false)
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
end

local _pk = LocalPlayer.Kick
rawset(LocalPlayer, "Kick", function(self, msg)
    if self == LocalPlayer then return nil end
    return _pk(self, msg)
end)

if getconnections then
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local n = obj.Name:lower()
            if n:match("kick") or n:match("ban") or n:match("detect") then
                pcall(function()
                    for _, con in ipairs(getconnections(obj.OnClientEvent)) do
                        con:Disable()
                    end
                end)
            end
        end
    end
end

--// ============================================================
--// ROLE DETECTION SYSTEM
--// ============================================================

local function DetectRoles()
    Roles.Murderer = nil
    Roles.Sheriff = nil
    Roles.Innocents = {}
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        
        local backpack = p:FindFirstChild("Backpack")
        local character = p.Character
        
        --// Check backpack for knife/gun
        if backpack then
            if backpack:FindFirstChild("Knife") then
                Roles.Murderer = p
            elseif backpack:FindFirstChild("Gun") then
                Roles.Sheriff = p
            else
                table.insert(Roles.Innocents, p)
            end
        end
        
        --// Check character for holding knife/gun
        if character then
            if character:FindFirstChild("Knife") then
                Roles.Murderer = p
            elseif character:FindFirstChild("Gun") then
                Roles.Sheriff = p
            end
        end
    end
    
    --// Check local player role
    local myBackpack = LocalPlayer:FindFirstChild("Backpack")
    local myChar = LocalPlayer.Character
    Config.MyRole = "Innocent"
    
    if myBackpack then
        if myBackpack:FindFirstChild("Knife") then Config.MyRole = "Murderer"
        elseif myBackpack:FindFirstChild("Gun") then Config.MyRole = "Sheriff" end
    end
    if myChar then
        if myChar:FindFirstChild("Knife") then Config.MyRole = "Murderer"
        elseif myChar:FindFirstChild("Gun") then Config.MyRole = "Sheriff" end
    end
end

--// Detect roles every 2 seconds
task.spawn(function()
    while true do
        DetectRoles()
        task.wait(2)
    end
end)

--// ============================================================
--// LOADING SCREEN
--// ============================================================

local LoadGui = Instance.new("ScreenGui")
LoadGui.Name = "NX_MM2_Load"
LoadGui.Parent = CoreGui
LoadGui.ResetOnSpawn = false
LoadGui.DisplayOrder = 99999
LoadGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local LoadBg = Instance.new("Frame")
LoadBg.Size = UDim2.new(1, 0, 1, 0)
LoadBg.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
LoadBg.BorderSizePixel = 0
LoadBg.ZIndex = 100
LoadBg.Parent = LoadGui

local LoadCenter = Instance.new("Frame")
LoadCenter.Size = UDim2.new(0, 400, 0, 300)
LoadCenter.Position = UDim2.new(0.5, -200, 0.5, -150)
LoadCenter.BackgroundTransparency = 1
LoadCenter.ZIndex = 101
LoadCenter.Parent = LoadBg

local LoadTitle = Instance.new("TextLabel")
LoadTitle.Size = UDim2.new(1, 0, 0, 50)
LoadTitle.Position = UDim2.new(0, 0, 0, 0)
LoadTitle.BackgroundTransparency = 1
LoadTitle.Text = "MURDER MYSTERY 2"
LoadTitle.TextColor3 = Color3.fromRGB(255, 50, 50)
LoadTitle.Font = Enum.Font.GothamBlack
LoadTitle.TextSize = 32
LoadTitle.TextXAlignment = Enum.TextXAlignment.Center
LoadTitle.ZIndex = 102
LoadCenter.Parent = LoadCenter

local LoadSub = Instance.new("TextLabel")
LoadSub.Size = UDim2.new(1, 0, 0, 25)
LoadSub.Position = UDim2.new(0, 0, 0, 50)
LoadSub.BackgroundTransparency = 1
LoadSub.Text = "N4n0Xy1n v12.0"
LoadSub.TextColor3 = Color3.fromRGB(0, 255, 136)
LoadSub.Font = Enum.Font.GothamBold
LoadSub.TextSize = 16
LoadSub.TextXAlignment = Enum.TextXAlignment.Center
LoadSub.ZIndex = 102
LoadSub.Parent = LoadCenter

local StatusContainer = Instance.new("Frame")
StatusContainer.Size = UDim2.new(1, -40, 0, 120)
StatusContainer.Position = UDim2.new(0, 20, 0, 100)
StatusContainer.BackgroundTransparency = 1
StatusContainer.ZIndex = 102
StatusContainer.Parent = LoadCenter

local StatusLines = {}
for i = 1, 5 do
    local line = Instance.new("TextLabel")
    line.Size = UDim2.new(1, 0, 0, 22)
    line.Position = UDim2.new(0, 0, 0, (i-1) * 24)
    line.BackgroundTransparency = 1
    line.Text = ""
    line.TextColor3 = Color3.fromRGB(150, 150, 150)
    line.Font = Enum.Font.Code
    line.TextSize = 13
    line.TextXAlignment = Enum.TextXAlignment.Center
    line.ZIndex = 102
    line.Parent = StatusContainer
    StatusLines[i] = line
end

local ProgressBg = Instance.new("Frame")
ProgressBg.Size = UDim2.new(1, -40, 0, 6)
ProgressBg.Position = UDim2.new(0, 20, 0, 240)
ProgressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ProgressBg.BorderSizePixel = 0
ProgressBg.ZIndex = 102
ProgressBg.Parent = LoadCenter

local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ProgressFill.BorderSizePixel = 0
ProgressFill.ZIndex = 103
ProgressFill.Parent = ProgressBg

local PercentText = Instance.new("TextLabel")
PercentText.Size = UDim2.new(1, 0, 0, 20)
PercentText.Position = UDim2.new(0, 0, 0, 255)
PercentText.BackgroundTransparency = 1
PercentText.Text = "0%"
PercentText.TextColor3 = Color3.fromRGB(255, 50, 50)
PercentText.Font = Enum.Font.GothamBold
PercentText.TextSize = 14
PercentText.TextXAlignment = Enum.TextXAlignment.Center
PercentText.ZIndex = 102
PercentText.Parent = LoadCenter

local function UpdateStatus(text, lineNum, color)
    lineNum = lineNum or 1
    color = color or Color3.fromRGB(150, 150, 150)
    if StatusLines[lineNum] then
        StatusLines[lineNum].Text = text
        StatusLines[lineNum].TextColor3 = color
    end
end

local function UpdateProgress(percent)
    ProgressFill:TweenSize(UDim2.new(percent / 100, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    PercentText.Text = tostring(math.floor(percent)) .. "%"
end

--// Live Loading
task.spawn(function()
    UpdateStatus("> DETECTING ROLES...", 1, Color3.fromRGB(255, 50, 50))
    UpdateProgress(15)
    task.wait(0.8)
    
    UpdateStatus("> BYPASS ANTI-CHEAT", 2, Color3.fromRGB(255, 50, 50))
    UpdateProgress(30)
    task.wait(0.6)
    
    UpdateStatus("> SCANNING ITEMS...", 3, Color3.fromRGB(200, 200, 200))
    UpdateProgress(50)
    task.wait(0.8)
    
    UpdateStatus("> UNLOCKING FEATURES...", 4, Color3.fromRGB(255, 50, 50))
    UpdateProgress(70)
    task.wait(0.6)
    
    UpdateStatus("> INITIALIZING ESP...", 5, Color3.fromRGB(200, 200, 200))
    UpdateProgress(85)
    task.wait(0.8)
    
    UpdateStatus("> READY!", 1, Color3.fromRGB(0, 255, 136))
    UpdateStatus("> BYPASS ANTI-CHEAT", 2, Color3.fromRGB(0, 200, 100))
    UpdateStatus("> SCANNING ITEMS...", 3, Color3.fromRGB(0, 200, 100))
    UpdateStatus("> UNLOCKING FEATURES...", 4, Color3.fromRGB(0, 200, 100))
    UpdateStatus("> INITIALIZING ESP...", 5, Color3.fromRGB(0, 200, 100))
    UpdateProgress(100)
    task.wait(0.8)
    
    LoadBg:TweenPosition(UDim2.new(0, 0, -1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.6, true, function()
        LoadGui:Destroy()
    end)
end)

--// ============================================================
--// GUI - MM2 STYLE MENU
--// ============================================================

local MenuGui = Instance.new("ScreenGui")
MenuGui.Name = "MM2_HUB_" .. tostring(math.random(1000,9999))
MenuGui.Parent = CoreGui
MenuGui.ResetOnSpawn = false
MenuGui.DisplayOrder = 1000
MenuGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 360, 0, 420)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = MenuGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "MM2 HUB"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 24
Title.Parent = MainFrame

local RoleText = Instance.new("TextLabel")
RoleText.Size = UDim2.new(1, 0, 0, 20)
RoleText.Position = UDim2.new(0, 0, 0, 45)
RoleText.BackgroundTransparency = 1
RoleText.Text = "Role: Detecting..."
RoleText.TextColor3 = Color3.fromRGB(200, 200, 200)
RoleText.Font = Enum.Font.Gotham
RoleText.TextSize = 12
RoleText.Parent = MainFrame

--// Update role text
task.spawn(function()
    while true do
        if Config.MyRole then
            local color = Color3.fromRGB(200, 200, 200)
            if Config.MyRole == "Murderer" then color = Color3.fromRGB(255, 50, 50)
            elseif Config.MyRole == "Sheriff" then color = Color3.fromRGB(0, 150, 255)
            else color = Color3.fromRGB(0, 255, 100) end
            RoleText.Text = "Your Role: " .. Config.MyRole
            RoleText.TextColor3 = color
        end
        task.wait(1)
    end
end)

--// Top Buttons
local TopContainer = Instance.new("Frame")
TopContainer.Size = UDim2.new(1, -20, 0, 40)
TopContainer.Position = UDim2.new(0, 10, 0, 70)
TopContainer.BackgroundTransparency = 1
TopContainer.Parent = MainFrame

local RoleButton = Instance.new("TextButton")
RoleButton.Size = UDim2.new(0, 80, 0, 36)
RoleButton.Position = UDim2.new(0, 0, 0, 0)
RoleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
RoleButton.Text = "ROLE"
RoleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RoleButton.Font = Enum.Font.GothamBold
RoleButton.TextSize = 13
RoleButton.AutoButtonColor = false
RoleButton.Parent = TopContainer

local ItemButton = Instance.new("TextButton")
ItemButton.Size = UDim2.new(0, 80, 0, 36)
ItemButton.Position = UDim2.new(0, 90, 0, 0)
ItemButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
ItemButton.Text = "ITEMS"
ItemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ItemButton.Font = Enum.Font.GothamBold
ItemButton.TextSize = 13
ItemButton.AutoButtonColor = false
ItemButton.Parent = TopContainer

local AutoButton = Instance.new("TextButton")
AutoButton.Size = UDim2.new(0, 80, 0, 36)
AutoButton.Position = UDim2.new(0, 180, 0, 0)
AutoButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
AutoButton.Text = "AUTO"
AutoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoButton.Font = Enum.Font.GothamBold
AutoButton.TextSize = 13
AutoButton.AutoButtonColor = false
AutoButton.Parent = TopContainer

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 70, 0, 36)
CloseButton.Position = UDim2.new(0, 270, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CloseButton.Text = "CLOSE"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 13
CloseButton.AutoButtonColor = false
CloseButton.Parent = TopContainer

for _, btn in ipairs({RoleButton, ItemButton, AutoButton, CloseButton}) do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn
end

--// Content
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -20, 1, -125)
ContentContainer.Position = UDim2.new(0, 10, 0, 118)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

--// Toggle Creator
local function CreateToggle(parent, text, configTable, configKey, yPos, onColor)
    onColor = onColor or Color3.fromRGB(255, 50, 50)
    
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 42)
    ToggleFrame.Position = UDim2.new(0, 0, 0, yPos)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
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
    ToggleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextSize = 13
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Center
    ToggleLabel.Parent = ToggleFrame
    
    local ClickButton = Instance.new("TextButton")
    ClickButton.Size = UDim2.new(1, 0, 1, 0)
    ClickButton.BackgroundTransparency = 1
    ClickButton.Text = ""
    ClickButton.Parent = ToggleFrame
    
    ClickButton.MouseButton1Click:Connect(function()
        configTable[configKey] = not configTable[configKey]
        local isOn = configTable[configKey]
        ToggleLabel.Text = text .. ": " .. (isOn and "ON" or "OFF")
        ToggleLabel.TextColor3 = isOn and onColor or Color3.fromRGB(180, 180, 180)
        ToggleFrame.BackgroundColor3 = isOn and Color3.fromRGB(45, 45, 55) or Color3.fromRGB(30, 30, 35)
    end)
    
    ClickButton.MouseEnter:Connect(function()
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    end)
    ClickButton.MouseLeave:Connect(function()
        local isOn = configTable[configKey]
        ToggleFrame.BackgroundColor3 = isOn and Color3.fromRGB(45, 45, 55) or Color3.fromRGB(30, 30, 35)
    end)
    
    return ToggleFrame
end

--// ROLE Tab
local RoleTab = Instance.new("Frame")
RoleTab.Size = UDim2.new(1, 0, 1, 0)
RoleTab.BackgroundTransparency = 1
RoleTab.Visible = true
RoleTab.Parent = ContentContainer

CreateToggle(RoleTab, "Role ESP", Config.RoleESP, "Enabled", 0, Color3.fromRGB(255, 50, 50))
CreateToggle(RoleTab, "Murderer Highlight", Config.RoleESP, "Murderer", 50, Color3.fromRGB(255, 0, 0))
CreateToggle(RoleTab, "Sheriff Highlight", Config.RoleESP, "Sheriff", 100, Color3.fromRGB(0, 150, 255))
CreateToggle(RoleTab, "Show Role Text", Config.RoleESP, "ShowRole", 150, Color3.fromRGB(255, 255, 255))
CreateToggle(RoleTab, "Show Distance", Config.RoleESP, "ShowDistance", 200, Color3.fromRGB(200, 200, 200))

--// ITEM Tab
local ItemTab = Instance.new("Frame")
ItemTab.Size = UDim2.new(1, 0, 1, 0)
ItemTab.BackgroundTransparency = 1
ItemTab.Visible = false
ItemTab.Parent = ContentContainer

CreateToggle(ItemTab, "Item ESP", Config.ItemESP, "Enabled", 0, Color3.fromRGB(255, 200, 0))
CreateToggle(ItemTab, "Coin ESP", Config.ItemESP, "Coins", 50, Color3.fromRGB(255, 200, 0))
CreateToggle(ItemTab, "Gun Drop ESP", Config.ItemESP, "GunDrop", 100, Color3.fromRGB(0, 255, 255))
CreateToggle(ItemTab, "Murderer Alert", Config.Alert, "Enabled", 150, Color3.fromRGB(255, 0, 0))

--// AUTO Tab
local AutoTab = Instance.new("Frame")
AutoTab.Size = UDim2.new(1, 0, 1, 0)
AutoTab.BackgroundTransparency = 1
AutoTab.Visible = false
AutoTab.Parent = ContentContainer

CreateToggle(AutoTab, "Auto Aim", Config.Auto, "Enabled", 0, Color3.fromRGB(255, 50, 50))
CreateToggle(AutoTab, "Auto Shoot (Sheriff)", Config.Auto, "AutoShoot", 50, Color3.fromRGB(0, 150, 255))
CreateToggle(AutoTab, "Auto Throw (Murderer)", Config.Auto, "AutoThrow", 100, Color3.fromRGB(255, 0, 0))
CreateToggle(AutoTab, "Show FOV", Config.Auto, "ShowFOV", 150, Color3.fromRGB(200, 200, 200))

--// Tab Switching
local function SwitchTab(tab)
    Config.Menu.Tab = tab
    RoleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    ItemButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    AutoButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    RoleTab.Visible = false
    ItemTab.Visible = false
    AutoTab.Visible = false
    
    if tab == "ROLE" then
        RoleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        RoleTab.Visible = true
    elseif tab == "ITEM" then
        ItemButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        ItemTab.Visible = true
    elseif tab == "AUTO" then
        AutoButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        AutoTab.Visible = true
    end
end

RoleButton.MouseButton1Click:Connect(function() SwitchTab("ROLE") end)
ItemButton.MouseButton1Click:Connect(function() SwitchTab("ITEM") end)
AutoButton.MouseButton1Click:Connect(function() SwitchTab("AUTO") end)
CloseButton.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

--// Hover effects
RoleButton.MouseEnter:Connect(function() if Config.Menu.Tab ~= "ROLE" then RoleButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40) end end)
RoleButton.MouseLeave:Connect(function() if Config.Menu.Tab ~= "ROLE" then RoleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55) end end)
ItemButton.MouseEnter:Connect(function() if Config.Menu.Tab ~= "ITEM" then ItemButton.BackgroundColor3 = Color3.fromRGB(200, 180, 0) end end)
ItemButton.MouseLeave:Connect(function() if Config.Menu.Tab ~= "ITEM" then ItemButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55) end end)
AutoButton.MouseEnter:Connect(function() if Config.Menu.Tab ~= "AUTO" then AutoButton.BackgroundColor3 = Color3.fromRGB(0, 200, 80) end end)
AutoButton.MouseLeave:Connect(function() if Config.Menu.Tab ~= "AUTO" then AutoButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55) end end)
CloseButton.MouseEnter:Connect(function() CloseButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60) end)
CloseButton.MouseLeave:Connect(function() CloseButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50) end)

SwitchTab("ROLE")

--// ============================================================
--// ESP SYSTEM
--// ============================================================

local function _w2s(p)
    local s, o, d = Camera:WorldToViewportPoint(p)
    return Vector2.new(s.X, s.Y), o, d
end
local function _dst(a, b) return (a - b).Magnitude end

--// Get player role
local function GetPlayerRole(p)
    if p == Roles.Murderer then return "Murderer", Color3.fromRGB(255, 0, 0)
    elseif p == Roles.Sheriff then return "Sheriff", Color3.fromRGB(0, 150, 255)
    else return "Innocent", Color3.fromRGB(0, 255, 100) end
end

--// Create Player ESP
local function CreatePlayerESP(p)
    if p == LocalPlayer then return end
    local e = {
        box = D.new("Square"),
        name = D.new("Text"),
        role = D.new("Text"),
        dist = D.new("Text"),
        tracer = D.new("Line")
    }
    e.box.Visible = false; e.box.Thickness = 1; e.box.Filled = false; e.box.Transparency = 1
    e.name.Visible = false; e.name.Size = 12; e.name.Center = true; e.name.Outline = true
    e.role.Visible = false; e.role.Size = 11; e.role.Center = true; e.role.Outline = true
    e.dist.Visible = false; e.dist.Size = 10; e.dist.Center = true; e.dist.Outline = true
    e.tracer.Visible = false; e.tracer.Thickness = 1; e.tracer.Transparency = 1
    PlayerESP[p] = e
    return e
end

--// Update Player ESP
local function UpdatePlayerESP()
    for p, e in pairs(PlayerESP) do
        local c = p.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local hd = c and (c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart"))
        
        if not c or not h or not hd or h.Health <= 0 then
            e.box.Visible = false; e.name.Visible = false; e.role.Visible = false
            e.dist.Visible = false; e.tracer.Visible = false
            continue
        end
        
        local roleName, roleColor = GetPlayerRole(p)
        
        --// Only show if role is enabled
        if roleName == "Murderer" and not Config.RoleESP.Murderer then
            e.box.Visible = false; e.name.Visible = false; e.role.Visible = false
            e.dist.Visible = false; e.tracer.Visible = false
            continue
        end
        if roleName == "Sheriff" and not Config.RoleESP.Sheriff then
            e.box.Visible = false; e.name.Visible = false; e.role.Visible = false
            e.dist.Visible = false; e.tracer.Visible = false
            continue
        end
        if roleName == "Innocent" and not Config.RoleESP.Innocent then
            e.box.Visible = false; e.name.Visible = false; e.role.Visible = false
            e.dist.Visible = false; e.tracer.Visible = false
            continue
        end
        
        local hp, on, dp = _w2s(hd.Position)
        if not on then
            e.box.Visible = false; e.name.Visible = false; e.role.Visible = false
            e.dist.Visible = false; e.tracer.Visible = false
            continue
        end
        
        local rp = c:FindFirstChild("HumanoidRootPart")
        if not rp then continue end
        local rp2, ron, rd = _w2s(rp.Position)
        
        local d = _dst(Camera.CFrame.Position, rp.Position)
        local sz = c:GetExtentsSize()
        local w, h2 = sz.X * 1.5, sz.Y * 1.5
        local tl = Vector2.new(hp.X - w/2, hp.Y - h2/2)
        
        --// Box
        if Config.RoleESP.Enabled then
            e.box.Size = Vector2.new(w, h2)
            e.box.Position = tl
            e.box.Color = roleColor
            e.box.Visible = true
        else e.box.Visible = false end
        
        --// Name
        if Config.RoleESP.Enabled then
            e.name.Text = p.Name
            e.name.Position = Vector2.new(hp.X, tl.Y - 15)
            e.name.Color = Color3.fromRGB(255,255,255)
            e.name.Visible = true
        else e.name.Visible = false end
        
        --// Role
        if Config.RoleESP.Enabled and Config.RoleESP.ShowRole then
            e.role.Text = "[" .. roleName .. "]"
            e.role.Position = Vector2.new(hp.X, tl.Y - 28)
            e.role.Color = roleColor
            e.role.Visible = true
        else e.role.Visible = false end
        
        --// Distance
        if Config.RoleESP.Enabled and Config.RoleESP.ShowDistance then
            e.dist.Text = string.format("[%.1fm]", d)
            e.dist.Position = Vector2.new(hp.X, tl.Y + h2 + 5)
            e.dist.Color = Color3.fromRGB(200,200,200)
            e.dist.Visible = true
        else e.dist.Visible = false end
        
        --// Tracer
        if Config.RoleESP.Enabled then
            e.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            e.tracer.To = Vector2.new(rp2.X, rp2.Y)
            e.tracer.Color = roleColor
            e.tracer.Visible = true
        else e.tracer.Visible = false end
    end
end

--// Item ESP
local function UpdateItemESP()
    --// Coins
    if Config.ItemESP.Enabled and Config.ItemESP.Coins then
        local coinContainer = Workspace:FindFirstChild("CoinContainer")
        if coinContainer then
            for _, coin in ipairs(coinContainer:GetChildren()) do
                if not ItemESP[coin] then
                    local e = D.new("Text")
                    e.Size = 14; e.Center = true; e.Outline = true
                    e.Color = Color3.fromRGB(255, 200, 0)
                    ItemESP[coin] = e
                end
                local pos, on = _w2s(coin.Position)
                if on then
                    ItemESP[coin].Text = "[COIN]"
                    ItemESP[coin].Position = pos
                    ItemESP[coin].Visible = true
                else
                    ItemESP[coin].Visible = false
                end
            end
        end
    end
    
    --// Gun Drop
    if Config.ItemESP.Enabled and Config.ItemESP.GunDrop then
        local gunDrop = Workspace:FindFirstChild("GunDrop")
        if gunDrop then
            if not ItemESP[gunDrop] then
                local e = D.new("Text")
                e.Size = 16; e.Center = true; e.Outline = true
                e.Color = Color3.fromRGB(0, 255, 255)
                ItemESP[gunDrop] = e
            end
            local pos, on = _w2s(gunDrop.Position)
            if on then
                ItemESP[gunDrop].Text = "[GUN DROP]"
                ItemESP[gunDrop].Position = pos
                ItemESP[gunDrop].Visible = true
            else
                ItemESP[gunDrop].Visible = false
            end
        end
    end
end

--// Alert System
local AlertGui = Instance.new("ScreenGui")
AlertGui.Name = "NX_Alert_" .. tostring(math.random(1000,9999))
AlertGui.Parent = CoreGui
AlertGui.ResetOnSpawn = false
AlertGui.DisplayOrder = 9999

local AlertFrame = Instance.new("Frame")
AlertFrame.Size = UDim2.new(0, 300, 0, 60)
AlertFrame.Position = UDim2.new(0.5, -150, 0, -70)
AlertFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
AlertFrame.BorderSizePixel = 0
AlertFrame.Visible = false
AlertFrame.Parent = AlertGui

local AlertCorner = Instance.new("UICorner")
AlertCorner.CornerRadius = UDim.new(0, 10)
AlertCorner.Parent = AlertFrame

local AlertText = Instance.new("TextLabel")
AlertText.Size = UDim2.new(1, -20, 1, -10)
AlertText.Position = UDim2.new(0, 10, 0, 5)
AlertText.BackgroundTransparency = 1
AlertText.Text = "MURDERER NEAR!"
AlertText.TextColor3 = Color3.fromRGB(255, 255, 255)
AlertText.Font = Enum.Font.GothamBlack
AlertText.TextSize = 20
AlertText.Parent = AlertFrame

local function ShowAlert()
    AlertFrame.Visible = true
    AlertFrame:TweenPosition(UDim2.new(0.5, -150, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Bounce, 0.5, true)
    task.delay(2, function()
        AlertFrame:TweenPosition(UDim2.new(0.5, -150, 0, -70), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.5, true, function()
            AlertFrame.Visible = false
        end)
    end)
end

--// Auto Aim System
local function GetTargetForRole()
    if Config.MyRole == "Sheriff" and Config.Auto.AutoShoot then
        --// Target murderer
        if Roles.Murderer and Roles.Murderer.Character then
            local hd = Roles.Murderer.Character:FindFirstChild("Head")
            if hd then return hd.Position, Roles.Murderer end
        end
    elseif Config.MyRole == "Murderer" and Config.Auto.AutoThrow then
        --// Target closest innocent
        local closest, cd = nil, math.huge
        local mp = Vector2.new(Mouse.X, Mouse.Y)
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer or p == Roles.Murderer then continue end
            local c = p.Character; local hd = c and c:FindFirstChild("Head")
            if not hd then continue end
            local sp, on, dp = _w2s(hd.Position)
            if not on then continue end
            local d = (sp - mp).Magnitude
            if d < Config.Auto.FOV and d < cd then
                cd = d; closest = p
            end
        end
        if closest and closest.Character then
            return closest.Character.Head.Position, closest
        end
    end
    return nil, nil
end

local function AutoAim()
    if not Config.Auto.Enabled then return end
    local targetPos, target = GetTargetForRole()
    if not targetPos then return end
    
    local vel = Vector3.new(0, 0, 0)
    if target and target.Character and target.Character:FindFirstChild("Head") then
        vel = target.Character.Head.AssemblyLinearVelocity or Vector3.new(0,0,0)
    end
    
    local ap = targetPos + (vel * Config.Auto.Prediction)
    local cf = Camera.CFrame
    Camera.CFrame = cf:Lerp(CFrame.new(cf.Position, ap), Config.Auto.Smoothness)
end

--// FOV Circle for Auto
local AutoFOV = D.new("Circle")
AutoFOV.Visible = false
AutoFOV.Radius = Config.Auto.FOV
AutoFOV.Color = Color3.fromRGB(255, 50, 50)
AutoFOV.Thickness = 1
AutoFOV.NumSides = 32
AutoFOV.Filled = false
AutoFOV.Transparency = 0.5

--// ============================================================
--// MAIN LOOP
--// ============================================================

RunService.Heartbeat:Connect(function()
    --// Update FOV
    AutoFOV.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    AutoFOV.Visible = Config.Auto.Enabled and Config.Auto.ShowFOV and true or false
    AutoFOV.Radius = Config.Auto.FOV
    
    --// Player ESP
    if Config.RoleESP.Enabled then
        UpdatePlayerESP()
    else
        for _, e in pairs(PlayerESP) do
            e.box.Visible = false; e.name.Visible = false; e.role.Visible = false
            e.dist.Visible = false; e.tracer.Visible = false
        end
    end
    
    --// Item ESP
    if Config.ItemESP.Enabled then
        UpdateItemESP()
    else
        for _, e in pairs(ItemESP) do
            if e then e.Visible = false end
        end
    end
    
    --// Auto Aim
    if Config.Auto.Enabled then
        AutoAim()
    end
    
    --// Murderer Alert
    if Config.Alert.Enabled and Config.Alert.MurdererNear and Roles.Murderer and Roles.Murderer.Character then
        local rp = Roles.Murderer.Character:FindFirstChild("HumanoidRootPart")
        local myRp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rp and myRp then
            local d = _dst(rp.Position, myRp.Position)
            if d < Config.Alert.Distance then
                ShowAlert()
            end
        end
    end
end)

--// Player handlers
Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then CreatePlayerESP(p) end
end)
Players.PlayerRemoving:Connect(function(p)
    local e = PlayerESP[p]
    if e then
        e.box:Remove(); e.name:Remove(); e.role:Remove()
        e.dist:Remove(); e.tracer:Remove()
        PlayerESP[p] = nil
    end
end)

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreatePlayerESP(p) end
end

--// Keybinds
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.Menu.Keybind then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

--// Cleanup
CoreGui.ChildRemoved:Connect(function(c)
    if c == MenuGui then
        for _, e in pairs(PlayerESP) do
            e.box:Remove(); e.name:Remove(); e.role:Remove()
            e.dist:Remove(); e.tracer:Remove()
        end
        for _, e in pairs(ItemESP) do
            if e then e:Remove() end
        end
        AutoFOV:Remove()
    end
end)

print([[
    _   __      _       __   ______
   / | / /   _| |     / /  /_  __/
  /  |/ / | / / | /| / /    / /   
 / /|  /| |/ /| |/ |/ /    / /    
/_/ |_/ |___/ |__/|__/    /_/     
                                   
N4n0Xy1n v12.0 | Murder Mystery 2
Role ESP | Auto Shoot/Throw | Coin/Gun ESP
INSERT: Menu | All Features OFF
]])
