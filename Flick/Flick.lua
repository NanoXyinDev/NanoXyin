-- ============================================================
-- N4n0Xy1n FPS Flick 3xpl01t Suite v4.0
-- Target: [FPS] Flick by Groundwork
-- Features: Aimbot + FOV Lock + ESP All Types + Auto Fire + AC Bypass
-- Lang: Lua | Roblox API | l33t sp34k
-- - .... . / .... .- -.-. -.- / .. ... / .-. . .- .-..
-- ============================================================

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// Drawing Library Init
local Drawing = Drawing or loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/drawing-lib/main.lua"))()

--// Config Table (editable via GUI)
local Config = {
    Aimbot = {
        Enabled = true,
        FOV = 150,
        Smoothness = 0.15,
        Prediction = 0.165,
        TeamCheck = false,
        WallCheck = true,
        HitPart = "Head", -- Head, Torso, HumanoidRootPart
        Keybind = Enum.KeyCode.E,
        AutoFire = true,
        TriggerBot = true
    },
    ESP = {
        Enabled = true,
        Boxes = true,
        Names = true,
        Health = true,
        Distance = true,
        Tracers = true,
        Skeleton = true,
        Chams = false,
        TeamColor = false,
        MaxDistance = 1000
    },
    FOV_Circle = {
        Visible = true,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0.5,
        Thickness = 1,
        NumSides = 64
    },
    AntiCheat = {
        Enabled = true,
        SpoofNamecalls = true,
        SpoofGC = true,
        RandomizeOffsets = true
    }
}

--// GUI Framework (simple but functional)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "N4n0Xy1n_GUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Corner
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "N4n0Xy1n | FPS Flick v4.0"
Title.TextColor3 = Color3.fromRGB(0, 255, 136)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

--// Toggle Function
local function CreateToggle(parent, text, configTable, configKey, yPos)
    local Toggle = Instance.new("TextButton")
    Toggle.Name = text .. "_Toggle"
    Toggle.Size = UDim2.new(1, -20, 0, 30)
    Toggle.Position = UDim2.new(0, 10, 0, yPos)
    Toggle.BackgroundColor3 = configTable[configKey] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    Toggle.Text = text .. ": " .. (configTable[configKey] and "ON" or "OFF")
    Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.Font = Enum.Font.Gotham
    Toggle.TextSize = 12
    Toggle.Parent = parent
    
    Toggle.MouseButton1Click:Connect(function()
        configTable[configKey] = not configTable[configKey]
        Toggle.BackgroundColor3 = configTable[configKey] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
        Toggle.Text = text .. ": " .. (configTable[configKey] and "ON" or "OFF")
    end)
    
    return Toggle
end

-- Create Toggles
CreateToggle(MainFrame, "Aimbot", Config.Aimbot, "Enabled", 40)
CreateToggle(MainFrame, "ESP", Config.ESP, "Enabled", 75)
CreateToggle(MainFrame, "Auto Fire", Config.Aimbot, "AutoFire", 110)
CreateToggle(MainFrame, "Team Check", Config.Aimbot, "TeamCheck", 145)
CreateToggle(MainFrame, "Wall Check", Config.Aimbot, "WallCheck", 180)
CreateToggle(MainFrame, "ESP Boxes", Config.ESP, "Boxes", 215)
CreateToggle(MainFrame, "ESP Names", Config.ESP, "Names", 250)
CreateToggle(MainFrame, "ESP Health", Config.ESP, "Health", 285)
CreateToggle(MainFrame, "ESP Tracers", Config.ESP, "Tracers", 320)
CreateToggle(MainFrame, "AC Bypass", Config.AntiCheat, "Enabled", 355)

--// FOV Circle Drawing
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Config.FOV_Circle.Visible
FOVCircle.Radius = Config.Aimbot.FOV
FOVCircle.Color = Config.FOV_Circle.Color
FOVCircle.Thickness = Config.FOV_Circle.Thickness
FOVCircle.NumSides = Config.FOV_Circle.NumSides
FOVCircle.Filled = false
FOVCircle.Transparency = Config.FOV_Circle.Transparency

--// ESP Storage
local ESP_Objects = {}

--// Utility Functions
local function GetCharacter(player)
    return player.Character
end

local function GetHumanoid(character)
    return character:FindFirstChildOfClass("Humanoid")
end

local function GetHead(character)
    return character:FindFirstChild(Config.Aimbot.HitPart) or character:FindFirstChild("Head")
end

local function IsPlayerAlive(player)
    local char = GetCharacter(player)
    if not char then return false end
    local humanoid = GetHumanoid(char)
    return humanoid and humanoid.Health > 0
end

local function IsTeammate(player)
    if not Config.Aimbot.TeamCheck then return false end
    return player.Team == LocalPlayer.Team
end

local function WorldToScreen(position)
    local screenPos, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

local function GetDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

local function RaycastWallCheck(origin, target)
    if not Config.Aimbot.WallCheck then return true end
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = Workspace:Raycast(origin, (target - origin).Unit * (target - origin).Magnitude, rayParams)
    return result == nil
end

--// ESP Creation
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local ESP = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        Skeleton = {}
    }
    
    -- Box ESP
    ESP.Box.Visible = false
    ESP.Box.Color = Color3.fromRGB(255, 0, 0)
    ESP.Box.Thickness = 1
    ESP.Box.Filled = false
    ESP.Box.Transparency = 1
    
    ESP.BoxOutline.Visible = false
    ESP.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
    ESP.BoxOutline.Thickness = 3
    ESP.BoxOutline.Filled = false
    ESP.BoxOutline.Transparency = 1
    
    -- Name ESP
    ESP.Name.Visible = false
    ESP.Name.Color = Color3.fromRGB(255, 255, 255)
    ESP.Name.Size = 14
    ESP.Name.Center = true
    ESP.Name.Outline = true
    ESP.Name.Font = Drawing.Fonts.UI
    
    -- Health ESP
    ESP.Health.Visible = false
    ESP.Health.Color = Color3.fromRGB(0, 255, 0)
    ESP.Health.Size = 12
    ESP.Health.Center = true
    ESP.Health.Outline = true
    
    -- Distance ESP
    ESP.Distance.Visible = false
    ESP.Distance.Color = Color3.fromRGB(200, 200, 200)
    ESP.Distance.Size = 12
    ESP.Distance.Center = true
    ESP.Distance.Outline = true
    
    -- Tracer ESP
    ESP.Tracer.Visible = false
    ESP.Tracer.Color = Color3.fromRGB(255, 255, 255)
    ESP.Tracer.Thickness = 1
    ESP.Tracer.Transparency = 1
    
    -- Skeleton ESP
    local skeletonParts = {"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "LeftHand",
        "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
        "RightUpperLeg", "RightLowerLeg", "RightFoot"}
    
    for i = 1, #skeletonParts - 1 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Color3.fromRGB(255, 255, 255)
        line.Thickness = 1
        table.insert(ESP.Skeleton, line)
    end
    
    ESP_Objects[player] = ESP
    return ESP
end

--// Update ESP
local function UpdateESP()
    for player, ESP in pairs(ESP_Objects) do
        local character = GetCharacter(player)
        local humanoid = character and GetHumanoid(character)
        local head = character and GetHead(character)
        
        if not character or not humanoid or not head or not IsPlayerAlive(player) or IsTeammate(player) then
            -- Hide all ESP
            ESP.Box.Visible = false
            ESP.BoxOutline.Visible = false
            ESP.Name.Visible = false
            ESP.Health.Visible = false
            ESP.Distance.Visible = false
            ESP.Tracer.Visible = false
            for _, line in ipairs(ESP.Skeleton) do line.Visible = false end
            continue
        end
        
        local headPos, headOnScreen, headDepth = WorldToScreen(head.Position)
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then continue end
        
        local rootPos, rootOnScreen, rootDepth = WorldToScreen(rootPart.Position)
        if not rootOnScreen then
            ESP.Box.Visible = false
            ESP.BoxOutline.Visible = false
            ESP.Name.Visible = false
            ESP.Health.Visible = false
            ESP.Distance.Visible = false
            ESP.Tracer.Visible = false
            for _, line in ipairs(ESP.Skeleton) do line.Visible = false end
            continue
        end
        
        local distance = GetDistance(Camera.CFrame.Position, rootPart.Position)
        if distance > Config.ESP.MaxDistance then
            ESP.Box.Visible = false
            ESP.BoxOutline.Visible = false
            ESP.Name.Visible = false
            ESP.Health.Visible = false
            ESP.Distance.Visible = false
            ESP.Tracer.Visible = false
            for _, line in ipairs(ESP.Skeleton) do line.Visible = false end
            continue
        end
        
        -- Calculate Box Dimensions
        local size = character:GetExtentsSize()
        local width = size.X * 2
        local height = size.Y * 2
        
        local topLeft = Vector2.new(headPos.X - width / 2, headPos.Y - height / 2)
        local bottomRight = Vector2.new(headPos.X + width / 2, headPos.Y + height / 2)
        
        -- Update Box
        if Config.ESP.Boxes then
            ESP.Box.Size = Vector2.new(width, height)
            ESP.Box.Position = topLeft
            ESP.Box.Visible = true
            ESP.Box.Color = Config.ESP.TeamColor and (player.TeamColor.Color or Color3.fromRGB(255, 0, 0)) or Color3.fromRGB(255, 0, 0)
            
            ESP.BoxOutline.Size = ESP.Box.Size
            ESP.BoxOutline.Position = ESP.Box.Position
            ESP.BoxOutline.Visible = true
        else
            ESP.Box.Visible = false
            ESP.BoxOutline.Visible = false
        end
        
        -- Update Name
        if Config.ESP.Names then
            ESP.Name.Text = player.Name
            ESP.Name.Position = Vector2.new(headPos.X, topLeft.Y - 15)
            ESP.Name.Visible = true
        else
            ESP.Name.Visible = false
        end
        
        -- Update Health
        if Config.ESP.Health then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            ESP.Health.Text = string.format("[%d/%d]", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
            ESP.Health.Position = Vector2.new(headPos.X, bottomRight.Y + 5)
            ESP.Health.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
            ESP.Health.Visible = true
        else
            ESP.Health.Visible = false
        end
        
        -- Update Distance
        if Config.ESP.Distance then
            ESP.Distance.Text = string.format("[%.1fm]", distance)
            ESP.Distance.Position = Vector2.new(headPos.X, bottomRight.Y + 20)
            ESP.Distance.Visible = true
        else
            ESP.Distance.Visible = false
        end
        
        -- Update Tracer
        if Config.ESP.Tracers then
            ESP.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            ESP.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            ESP.Tracer.Visible = true
        else
            ESP.Tracer.Visible = false
        end
        
        -- Update Skeleton
        if Config.ESP.Skeleton then
            local connections = {
                {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
                {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
                {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
                {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
                {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
            }
            
            for i, connection in ipairs(connections) do
                local part1 = character:FindFirstChild(connection[1])
                local part2 = character:FindFirstChild(connection[2])
                if part1 and part2 then
                    local pos1, on1 = WorldToScreen(part1.Position)
                    local pos2, on2 = WorldToScreen(part2.Position)
                    if on1 and on2 then
                        ESP.Skeleton[i].From = pos1
                        ESP.Skeleton[i].To = pos2
                        ESP.Skeleton[i].Visible = true
                    else
                        ESP.Skeleton[i].Visible = false
                    end
                end
            end
        else
            for _, line in ipairs(ESP.Skeleton) do line.Visible = false end
        end
    end
end

--// Aimbot Logic
local function GetClosestPlayerToFOV()
    local closestPlayer = nil
    local closestDistance = math.huge
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not IsPlayerAlive(player) then continue end
        if IsTeammate(player) then continue end
        
        local character = GetCharacter(player)
        local head = character and GetHead(character)
        if not head then continue end
        
        local screenPos, onScreen, depth = WorldToScreen(head.Position)
        if not onScreen or depth < 0 then continue end
        
        local distance = (screenPos - mousePos).Magnitude
        if distance > Config.Aimbot.FOV then continue end
        
        if not RaycastWallCheck(Camera.CFrame.Position, head.Position) then continue end
        
        if distance < closestDistance then
            closestDistance = distance
            closestPlayer = player
        end
    end
    
    return closestPlayer, closestDistance
end

local function AimAt(targetPlayer)
    if not targetPlayer then return end
    
    local character = GetCharacter(targetPlayer)
    local head = character and GetHead(character)
    if not head then return end
    
    local targetPos = head.Position
    local velocity = head.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
    local prediction = velocity * Config.Aimbot.Prediction
    
    local aimPos = targetPos + prediction
    local cameraCF = Camera.CFrame
    local targetCF = CFrame.new(cameraCF.Position, aimPos)
    
    -- Smooth aim
    local smoothFactor = Config.Aimbot.Smoothness
    Camera.CFrame = cameraCF:Lerp(targetCF, smoothFactor)
end

--// Auto Fire / Trigger Bot
local function AutoFire(targetPlayer)
    if not Config.Aimbot.AutoFire or not targetPlayer then return end
    
    local character = GetCharacter(targetPlayer)
    local head = character and GetHead(character)
    if not head then return end
    
    local screenPos, onScreen = WorldToScreen(head.Position)
    if not onScreen then return end
    
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local distance = (screenPos - mousePos).Magnitude
    
    if distance < 20 then -- Within precision threshold
        -- Simulate mouse click
        local vim = game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 0)
        task.wait(0.05)
        vim:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 0)
    end
end

--// Anti-Cheat Bypass
local function BypassAntiCheat()
    if not Config.AntiCheat.Enabled then return end
    
    -- Hook metatable namecalls to spoof detection
    local mt = getrawmetatable(game)
    if mt then
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- Spoof common AC detection methods
            if method == "Kick" or method == "kick" then
                warn("[N4n0Xy1n] AC Kick intercepted and blocked!")
                return nil
            end
            
            if method == "FireServer" and self.Name and (self.Name:match("AC") or self.Name:match("Anti") or self.Name:match("Detect")) then
                warn("[N4n0Xy1n] AC Remote blocked: " .. self.Name)
                return nil
            end
            
            return oldNamecall(self, unpack(args))
        end)
        
        setreadonly(mt, true)
    end
    
    -- Hook GetPropertyChangedSignal to prevent AC from detecting property changes
    local oldGetPropertyChangedSignal
    oldGetPropertyChangedSignal = hookfunction(game.GetPropertyChangedSignal, newcclosure(function(self, prop)
        if prop == "CFrame" or prop == "Position" then
            return Instance.new("BindableEvent").Event -- Return dummy event
        end
        return oldGetPropertyChangedSignal(self, prop)
    end))
    
    -- Spoof Humanoid state detection
    local oldHumState = Enum.HumanoidStateType
    local humStateHook = hookfunction(Enum.HumanoidStateType, newcclosure(function(...)
        return oldHumState
    end))
    
    -- Randomize offsets to prevent pattern detection
    if Config.AntiCheat.RandomizeOffsets then
        task.spawn(function()
            while true do
                task.wait(math.random(0.1, 0.5))
                -- Random micro-adjustments to prevent detection
                if Config.Aimbot.Enabled then
                    Config.Aimbot.Smoothness = 0.15 + (math.random() * 0.05 - 0.025)
                end
            end
        end)
    end
    
    -- Garbage collector spoofing
    if Config.AntiCheat.SpoofGC then
        local gcInfo = collectgarbage
        hookfunction(gcInfo, newcclosure(function(...)
            local result = gcInfo(...)
            return result + math.random(-50, 50) -- Add noise
        end))
    end
    
    -- Disable common AC modules
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("ModuleScript") and (obj.Name:match("Anti") or obj.Name:match("AC") or obj.Name:match("Detect") or obj.Name:match("Cheat")) then
            warn("[N4n0Xy1n] AC Module found: " .. obj.Name .. " | Neutralized")
            -- Attempt to disable or replace
            pcall(function()
                obj.Disabled = true
            end)
        end
    end
    
    print("[N4n0Xy1n] Anti-Cheat Bypass aktiviert. Schutzschilde hochgefahren.")
end

--// Main Loop
local aimbotTarget = nil

RunService.RenderStepped:Connect(function()
    -- Update FOV Circle
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36) -- +36 for GUI offset
    FOVCircle.Visible = Config.Aimbot.Enabled and Config.FOV_Circle.Visible
    FOVCircle.Radius = Config.Aimbot.FOV
    
    -- Update ESP
    if Config.ESP.Enabled then
        UpdateESP()
    else
        -- Hide all ESP
        for _, ESP in pairs(ESP_Objects) do
            ESP.Box.Visible = false
            ESP.BoxOutline.Visible = false
            ESP.Name.Visible = false
            ESP.Health.Visible = false
            ESP.Distance.Visible = false
            ESP.Tracer.Visible = false
            for _, line in ipairs(ESP.Skeleton) do line.Visible = false end
        end
    end
    
    -- Aimbot Logic
    if Config.Aimbot.Enabled then
        if UserInputService:IsKeyDown(Config.Aimbot.Keybind) then
            aimbotTarget = GetClosestPlayerToFOV()
            if aimbotTarget then
                AimAt(aimbotTarget)
                if Config.Aimbot.AutoFire then
                    AutoFire(aimbotTarget)
                end
            end
        else
            aimbotTarget = nil
        end
    end
end)

--// Player Added/Removed
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    local ESP = ESP_Objects[player]
    if ESP then
        ESP.Box:Remove()
        ESP.BoxOutline:Remove()
        ESP.Name:Remove()
        ESP.Health:Remove()
        ESP.Distance:Remove()
        ESP.Tracer:Remove()
        for _, line in ipairs(ESP.Skeleton) do line:Remove() end
        ESP_Objects[player] = nil
    end
end)

--// Initialize ESP for existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

--// Initialize AC Bypass
BypassAntiCheat()

--// Notification
local function Notify(text, duration)
    duration = duration or 3
    local notif = Instance.new("ScreenGui")
    notif.Name = "N4n0Xy1n_Notif"
    notif.Parent = game.CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 50)
    frame.Position = UDim2.new(0.5, -150, 0, -60)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = notif
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, -10)
    label.Position = UDim2.new(0, 5, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(0, 255, 136)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = frame
    
    -- Animate in
    frame:TweenPosition(UDim2.new(0.5, -150, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5, true)
    
    task.delay(duration, function()
        frame:TweenPosition(UDim2.new(0.5, -150, 0, -60), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.5, true, function()
            notif:Destroy()
        end)
    end)
end

Notify("N4n0Xy1n FPS Flick v4.0 aktiviert | Aimbot: E | GUI: Draggable", 5)

print([[
    _   __      _       __   ______
   / | / /   _| |     / /  /_  __/
  /  |/ / | / / | /| / /    / /   
 / /|  /| |/ /| |/ |/ /    / /    
/_/ |_/ |___/ |__/|__/    /_/     
                                   
- .... . / .... .- -.-. -.- / .. ... / .-. . .- .-..
N4n0Xy1n System | FPS Flick Exploit Suite Loaded
Bypass: ACTIVE | ESP: ACTIVE | Aimbot: READY
]])

--// Keybind to toggle GUI visibility
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

--// Cleanup on script destroy
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "N4n0Xy1n_GUI" then
        for _, ESP in pairs(ESP_Objects) do
            ESP.Box:Remove()
            ESP.BoxOutline:Remove()
            ESP.Name:Remove()
            ESP.Health:Remove()
            ESP.Distance:Remove()
            ESP.Tracer:Remove()
            for _, line in ipairs(ESP.Skeleton) do line:Remove() end
        end
        FOVCircle:Remove()
    end
end)
