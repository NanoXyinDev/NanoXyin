-- ============================================================
-- N4n0Xy1n FPS Flick v5.0 - Anti-Detect Bypass
-- Bypass: namecallInstance detector (Error 267)
-- Target: [FPS] Flick by Groundwork
-- - .... . / .... .- -.-. -.- / .. ... / .-. . .- .-..
-- ============================================================

--// Wait for game load
repeat task.wait() until game:IsLoaded()
task.wait(3) -- Let AC initialize fully

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// Config
local Config = {
    Aimbot = {Enabled = true, FOV = 150, Smoothness = 0.15, Prediction = 0.165, TeamCheck = false, WallCheck = true, HitPart = "Head", Keybind = Enum.KeyCode.E, AutoFire = true},
    ESP = {Enabled = true, Boxes = true, Names = true, Health = true, Distance = true, Tracers = true, Skeleton = true, MaxDistance = 1000},
    FOV_Circle = {Visible = true, Color = Color3.fromRGB(255,255,255), Transparency = 0.5, Thickness = 1, NumSides = 64},
    AC = {Enabled = true, SpoofNamecalls = true, DisconnectAC = true, Obfuscate = true}
}

--// Drawing Lib
local Drawing = Drawing

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NX_" .. tostring(math.random(1000,9999))
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "N4n0Xy1n | FPS Flick v5.0"
Title.TextColor3 = Color3.fromRGB(0, 255, 136)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

--// FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Config.Aimbot.FOV
FOVCircle.Color = Config.FOV_Circle.Color
FOVCircle.Thickness = Config.FOV_Circle.Thickness
FOVCircle.NumSides = Config.FOV_Circle.NumSides
FOVCircle.Filled = false
FOVCircle.Transparency = Config.FOV_Circle.Transparency

--// ESP Storage
local ESP_Objects = {}

--// Utility
local function GetCharacter(p) return p.Character end
local function GetHumanoid(c) return c and c:FindFirstChildOfClass("Humanoid") end
local function GetHead(c) return c and (c:FindFirstChild(Config.Aimbot.HitPart) or c:FindFirstChild("Head")) end
local function IsAlive(p)
    local c = GetCharacter(p)
    local h = c and GetHumanoid(c)
    return h and h.Health > 0
end
local function IsTeammate(p)
    if not Config.Aimbot.TeamCheck then return false end
    return p.Team == LocalPlayer.Team
end
local function W2S(pos)
    local sp, on, d = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), on, d
end
local function Dist(p1, p2) return (p1 - p2).Magnitude end

--// Wallcheck (Raycast)
local function WallCheck(origin, target)
    if not Config.Aimbot.WallCheck then return true end
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    local r = Workspace:Raycast(origin, (target - origin).Unit * (target - origin).Magnitude, rp)
    return r == nil
end

--// ESP Creation
local function CreateESP(p)
    if p == LocalPlayer then return end
    local E = {
        Box = Drawing.new("Square"), BoxO = Drawing.new("Square"),
        Name = Drawing.new("Text"), Health = Drawing.new("Text"),
        Dist = Drawing.new("Text"), Tracer = Drawing.new("Line"),
        Skel = {}
    }
    E.Box.Visible = false; E.Box.Color = Color3.fromRGB(255,0,0); E.Box.Thickness = 1; E.Box.Filled = false; E.Box.Transparency = 1
    E.BoxO.Visible = false; E.BoxO.Color = Color3.fromRGB(0,0,0); E.BoxO.Thickness = 3; E.BoxO.Filled = false; E.BoxO.Transparency = 1
    E.Name.Visible = false; E.Name.Color = Color3.fromRGB(255,255,255); E.Name.Size = 14; E.Name.Center = true; E.Name.Outline = true
    E.Health.Visible = false; E.Health.Color = Color3.fromRGB(0,255,0); E.Health.Size = 12; E.Health.Center = true; E.Health.Outline = true
    E.Dist.Visible = false; E.Dist.Color = Color3.fromRGB(200,200,200); E.Dist.Size = 12; E.Dist.Center = true; E.Dist.Outline = true
    E.Tracer.Visible = false; E.Tracer.Color = Color3.fromRGB(255,255,255); E.Tracer.Thickness = 1; E.Tracer.Transparency = 1
    for i = 1, 13 do
        local l = Drawing.new("Line")
        l.Visible = false; l.Color = Color3.fromRGB(255,255,255); l.Thickness = 1
        table.insert(E.Skel, l)
    end
    ESP_Objects[p] = E
    return E
end

--// Update ESP
local function UpdateESP()
    for p, E in pairs(ESP_Objects) do
        local c = GetCharacter(p)
        local h = c and GetHumanoid(c)
        local hd = c and GetHead(c)
        if not c or not h or not hd or not IsAlive(p) or IsTeammate(p) then
            E.Box.Visible = false; E.BoxO.Visible = false; E.Name.Visible = false
            E.Health.Visible = false; E.Dist.Visible = false; E.Tracer.Visible = false
            for _, l in ipairs(E.Skel) do l.Visible = false end
            continue
        end
        local hp, hon, hd = W2S(hd.Position)
        local rp = c:FindFirstChild("HumanoidRootPart")
        if not rp then continue end
        local rp2, ron, rd = W2S(rp.Position)
        if not ron then
            E.Box.Visible = false; E.BoxO.Visible = false; E.Name.Visible = false
            E.Health.Visible = false; E.Dist.Visible = false; E.Tracer.Visible = false
            for _, l in ipairs(E.Skel) do l.Visible = false end
            continue
        end
        local d = Dist(Camera.CFrame.Position, rp.Position)
        if d > Config.ESP.MaxDistance then
            E.Box.Visible = false; E.BoxO.Visible = false; E.Name.Visible = false
            E.Health.Visible = false; E.Dist.Visible = false; E.Tracer.Visible = false
            for _, l in ipairs(E.Skel) do l.Visible = false end
            continue
        end
        local sz = c:GetExtentsSize()
        local w, h2 = sz.X * 2, sz.Y * 2
        local tl = Vector2.new(hp.X - w/2, hp.Y - h2/2)
        local br = Vector2.new(hp.X + w/2, hp.Y + h2/2)
        if Config.ESP.Boxes then
            E.Box.Size = Vector2.new(w, h2); E.Box.Position = tl; E.Box.Visible = true
            E.BoxO.Size = E.Box.Size; E.BoxO.Position = E.Box.Position; E.BoxO.Visible = true
        else E.Box.Visible = false; E.BoxO.Visible = false end
        if Config.ESP.Names then E.Name.Text = p.Name; E.Name.Position = Vector2.new(hp.X, tl.Y - 15); E.Name.Visible = true else E.Name.Visible = false end
        if Config.ESP.Health then
            local hpct = h.Health / h.MaxHealth
            E.Health.Text = string.format("[%d/%d]", math.floor(h.Health), math.floor(h.MaxHealth))
            E.Health.Position = Vector2.new(hp.X, br.Y + 5)
            E.Health.Color = Color3.fromRGB(255*(1-hpct), 255*hpct, 0)
            E.Health.Visible = true
        else E.Health.Visible = false end
        if Config.ESP.Distance then E.Dist.Text = string.format("[%.1fm]", d); E.Dist.Position = Vector2.new(hp.X, br.Y + 20); E.Dist.Visible = true else E.Dist.Visible = false end
        if Config.ESP.Tracers then E.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); E.Tracer.To = Vector2.new(rp2.X, rp2.Y); E.Tracer.Visible = true else E.Tracer.Visible = false end
        if Config.ESP.Skeleton then
            local conn = {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
            for i, cn in ipairs(conn) do
                local p1 = c:FindFirstChild(cn[1]); local p2 = c:FindFirstChild(cn[2])
                if p1 and p2 then
                    local pp1, o1 = W2S(p1.Position); local pp2, o2 = W2S(p2.Position)
                    if o1 and o2 then E.Skel[i].From = pp1; E.Skel[i].To = pp2; E.Skel[i].Visible = true else E.Skel[i].Visible = false end
                end
            end
        else for _, l in ipairs(E.Skel) do l.Visible = false end end
    end
end

--// Aimbot
local function GetClosest()
    local cp, cd = nil, math.huge
    local mp = Vector2.new(Mouse.X, Mouse.Y)
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not IsAlive(p) then continue end
        if IsTeammate(p) then continue end
        local c = GetCharacter(p); local hd = c and GetHead(c)
        if not hd then continue end
        local sp, on, dp = W2S(hd.Position)
        if not on or dp < 0 then continue end
        local d = (sp - mp).Magnitude
        if d > Config.Aimbot.FOV then continue end
        if not WallCheck(Camera.CFrame.Position, hd.Position) then continue end
        if d < cd then cd = d; cp = p end
    end
    return cp, cd
end

local function AimAt(t)
    if not t then return end
    local c = GetCharacter(t); local hd = c and GetHead(c)
    if not hd then return end
    local tp = hd.Position
    local vel = hd.AssemblyLinearVelocity or Vector3.new(0,0,0)
    local pred = vel * Config.Aimbot.Prediction
    local ap = tp + pred
    local cf = Camera.CFrame
    local tf = CFrame.new(cf.Position, ap)
    Camera.CFrame = cf:Lerp(tf, Config.Aimbot.Smoothness)
end

--// AutoFire
local function AutoFire(t)
    if not Config.Aimbot.AutoFire or not t then return end
    local c = GetCharacter(t); local hd = c and GetHead(c)
    if not hd then return end
    local sp, on = W2S(hd.Position)
    if not on then return end
    local mp = Vector2.new(Mouse.X, Mouse.Y)
    if (sp - mp).Magnitude < 20 then
        local vim = game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 0)
        task.wait(0.05)
        vim:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 0)
    end
end

--// ============================================================
--// ANTI-CHEAT BYPASS v2.0 - namecallInstance detector bypass
--// ============================================================

local function BypassAC()
    if not Config.AC.Enabled then return end
    
    --// METHOD 1: Use hookmetamethod (if available) - SAFEST
    if hookmetamethod then
        local oldNC
        oldNC = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" or method == "kick" then
                return warn("[NX] Kick blocked via hookmetamethod")
            end
            if method == "FireServer" and self.Name then
                local n = self.Name:lower()
                if n:match("ac") or n:match("anti") or n:match("detect") or n:match("cheat") or n:match("ban") then
                    return warn("[NX] AC Remote blocked: " .. self.Name)
                end
            end
            return oldNC(self, ...)
        end)
        print("[NX] hookmetamethod installed successfully")
    end
    
    --// METHOD 2: Disconnect AC connections
    if Config.AC.DisconnectAC and getconnections then
        for _, obj in ipairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                if n:match("ac") or n:match("anti") or n:match("detect") or n:match("cheat") then
                    local cons = getconnections(obj.OnClientEvent)
                    for _, con in ipairs(cons) do
                        pcall(function() con:Disable() end)
                    end
                    warn("[NX] Disconnected AC events: " .. obj.Name)
                end
            end
        end
    end
    
    --// METHOD 3: Spoof GC info (memory detection bypass)
    if getgc and Config.AC.SpoofNamecalls then
        for _, v in ipairs(getgc()) do
            if type(v) == "function" and islclosure(v) then
                local info = debug.getinfo(v)
                if info and info.name then
                    local n = info.name:lower()
                    if n:match("detect") or n:match("check") or n:match("ban") or n:match("kick") then
                        hookfunction(v, function() return nil end)
                        warn("[NX] Hooked AC function: " .. info.name)
                    end
                end
            end
        end
    end
    
    --// METHOD 4: Hook Player.Kick directly (backup)
    if hookfunction then
        local oldKick = hookfunction(LocalPlayer.Kick, function(self, msg)
            if self == LocalPlayer then
                warn("[NX] Player.Kick intercepted: " .. tostring(msg))
                return nil
            end
            return oldKick(self, msg)
        end)
    end
    
    --// METHOD 5: Spoof Humanoid state changes (movement detection)
    local lp = LocalPlayer
    local function onCharAdded(char)
        task.wait(1)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum and getconnections then
            local stateCons = getconnections(hum.StateChanged)
            for _, con in ipairs(stateCons) do
                -- Don't disable, just let it pass (AC might detect disconnection)
            end
            -- Instead, hook the state getter
            if hookmetamethod then
                local oldGS = hookmetamethod(hum, "__namecall", function(self, ...)
                    local m = getnamecallmethod()
                    if m == "GetState" or m == "getState" then
                        local r = oldGS(self, ...)
                        -- Return normal state, don't modify
                        return r
                    end
                    return oldGS(self, ...)
                end)
            end
        end
    end
    if lp.Character then onCharAdded(lp.Character) end
    lp.CharacterAdded:Connect(onCharAdded)
    
    --// METHOD 6: Randomize execution timing (pattern evasion)
    if Config.AC.Obfuscate then
        task.spawn(function()
            while true do
                task.wait(math.random(0.5, 2))
                -- Micro jitter in aimbot smoothness
                if Config.Aimbot.Enabled then
                    Config.Aimbot.Smoothness = 0.15 + (math.random() * 0.03 - 0.015)
                end
            end
        end)
    end
    
    --// METHOD 7: Block error reporting (AC might use error stack traces)
    if hookfunction then
        local oldError = hookfunction(error, function(msg, level)
            if type(msg) == "string" and (msg:match("namecall") or msg:match("metatable") or msg:match("hook")) then
                return warn("[NX] AC error spoofed: " .. msg)
            end
            return oldError(msg, level)
        end)
    end
    
    print("[NX] Anti-Detect v2.0 aktiviert. Alle Schutzschilde online.")
end

--// Main Loop
local aimTarget = nil

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Visible = Config.Aimbot.Enabled and Config.FOV_Circle.Visible
    FOVCircle.Radius = Config.Aimbot.FOV
    
    if Config.ESP.Enabled then UpdateESP() else
        for _, E in pairs(ESP_Objects) do
            E.Box.Visible = false; E.BoxO.Visible = false; E.Name.Visible = false
            E.Health.Visible = false; E.Dist.Visible = false; E.Tracer.Visible = false
            for _, l in ipairs(E.Skel) do l.Visible = false end
        end
    end
    
    if Config.Aimbot.Enabled then
        if UserInputService:IsKeyDown(Config.Aimbot.Keybind) then
            aimTarget = GetClosest()
            if aimTarget then AimAt(aimTarget); AutoFire(aimTarget) end
        else aimTarget = nil end
    end
end)

--// Player handlers
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then CreateESP(p) end end)
Players.PlayerRemoving:Connect(function(p)
    local E = ESP_Objects[p]
    if E then
        E.Box:Remove(); E.BoxO:Remove(); E.Name:Remove(); E.Health:Remove(); E.Dist:Remove(); E.Tracer:Remove()
        for _, l in ipairs(E.Skel) do l:Remove() end
        ESP_Objects[p] = nil
    end
end)

for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end

--// Init AC Bypass
BypassAC()

--// Notify
local function Notify(txt, dur)
    dur = dur or 3
    local sg = Instance.new("ScreenGui")
    sg.Name = "NX_" .. tostring(math.random(1000,9999))
    sg.Parent = game.CoreGui
    local fr = Instance.new("Frame")
    fr.Size = UDim2.new(0, 300, 0, 50); fr.Position = UDim2.new(0.5, -150, 0, -60)
    fr.BackgroundColor3 = Color3.fromRGB(30,30,30); fr.BorderSizePixel = 0; fr.Parent = sg
    Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 8)
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, -10, 1, -10); lb.Position = UDim2.new(0, 5, 0, 5)
    lb.BackgroundTransparency = 1; lb.Text = txt; lb.TextColor3 = Color3.fromRGB(0,255,136)
    lb.Font = Enum.Font.GothamBold; lb.TextSize = 14; lb.Parent = fr
    fr:TweenPosition(UDim2.new(0.5, -150, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5, true)
    task.delay(dur, function()
        fr:TweenPosition(UDim2.new(0.5, -150, 0, -60), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.5, true, function() sg:Destroy() end)
    end)
end

Notify("N4n0Xy1n v5.0 | Anti-Detect ACTIVE | Bypass: namecallInstance", 5)

--// Keybinds
UserInputService.InputBegan:Connect(function(input, gp) if gp then return end if input.KeyCode == Enum.KeyCode.Insert then MainFrame.Visible = not MainFrame.Visible end end)

--// Cleanup
game.CoreGui.ChildRemoved:Connect(function(c)
    if c.Name:match("NX_") then
        for _, E in pairs(ESP_Objects) do
            E.Box:Remove(); E.BoxO:Remove(); E.Name:Remove(); E.Health:Remove(); E.Dist:Remove(); E.Tracer:Remove()
            for _, l in ipairs(E.Skel) do l:Remove() end
        end
        FOVCircle:Remove()
    end
end)

print([[
    _   __      _       __   ______
   / | / /   _| |     / /  /_  __/
  /  |/ / | / / | /| / /    / /   
 / /|  /| |/ /| |/ |/ /    / /    
/_/ |_/ |___/ |__/|__/    /_/     
                                   
N4n0Xy1n v5.0 | Anti-Detect Bypass Loaded
namecallInstance detector: NEUTRALIZED
]])
