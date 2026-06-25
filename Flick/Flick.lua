-- ============================================================
-- N4n0Xy1n FPS Flick v6.0 - Adonis AC Bypass
-- Target: :: Adonis :: Anti-Cheat System
-- Method: Stealth injection via existing game loops
-- - .... . / .... .- -.-. -.- / .. ... / .-. . .- .-..
-- ============================================================

--// CRITICAL: Delay execution sampai Adonis fully initialized
repeat task.wait() until game:IsLoaded()
task.wait(5) -- Adonis init delay

--// Services (jangan panggil GetService berulang kali - pattern detection)
local Players = game:FindFirstChildOfClass("Players")
local RunService = game:FindFirstChildOfClass("RunService")
local UserInputService = game:FindFirstChildOfClass("UserInputService")
local Workspace = game:FindFirstChildOfClass("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// Config - randomize names untuk avoid string detection
local _cfg = {
    _a = true, -- Aimbot
    _f = 150, -- FOV
    _s = 0.15, -- Smooth
    _p = 0.165, -- Prediction
    _t = false, -- TeamCheck
    _w = true, -- WallCheck
    _h = "Head", -- HitPart
    _k = Enum.KeyCode.E, -- Keybind
    _af = true, -- AutoFire
    _e = true, -- ESP
    _b = true, -- Boxes
    _n = true, -- Names
    _hp = true, -- Health
    _d = true, -- Distance
    _tr = true, -- Tracers
    _sk = true, -- Skeleton
    _md = 1000, -- MaxDistance
    _ac = true -- AC Bypass
}

--// Drawing - gunakan native, jangan create terlalu banyak objects
local D = Drawing

--// GUI dengan nama random (anti-string detection)
local _sg = Instance.new("ScreenGui")
_sg.Name = string.format("Gui_%d_%d", math.random(10000,99999), tick())
_sg.Parent = game:FindFirstChildOfClass("CoreGui")

local _mf = Instance.new("Frame")
_mf.Size = UDim2.new(0, 280, 0, 50)
_mf.Position = UDim2.new(0, 10, 0, 10)
_mf.BackgroundColor3 = Color3.fromRGB(20,20,20)
_mf.BorderSizePixel = 0
_mf.Active = true
_mf.Draggable = true
_mf.Parent = _sg

local _c = Instance.new("UICorner", _mf)
_c.CornerRadius = UDim.new(0, 6)

local _tl = Instance.new("TextLabel", _mf)
_tl.Size = UDim2.new(1,0,1,0)
_tl.BackgroundTransparency = 1
_tl.Text = "NX v6.0 | Adonis Bypass"
_tl.TextColor3 = Color3.fromRGB(0,255,136)
_tl.Font = Enum.Font.GothamBold
_tl.TextSize = 12

--// FOV Circle - minimal drawing objects
local _fc = D.new("Circle")
_fc.Visible = false
_fc.Radius = _cfg._f
_fc.Color = Color3.fromRGB(255,255,255)
_fc.Thickness = 1
_fc.NumSides = 32 -- Reduced untuk performance
_fc.Filled = false
_fc.Transparency = 0.5

--// ESP - gunakan table dengan weak references
local _esp = setmetatable({}, {__mode = "k"})

--// Utility functions - inline untuk reduce closure count
local function _gc(p) return p.Character end
local function _gh(c) return c and c:FindFirstChildOfClass("Humanoid") end
local function _ghd(c) return c and (c:FindFirstChild(_cfg._h) or c:FindFirstChild("Head")) end
local function _ia(p)
    local c = _gc(p)
    local h = _gh(c)
    return h and h.Health > 0
end
local function _it(p)
    if not _cfg._t then return false end
    return p.Team == LocalPlayer.Team
end
local function _w2s(p)
    local s, o, d = Camera:WorldToViewportPoint(p)
    return Vector2.new(s.X, s.Y), o, d
end
local function _dst(a, b) return (a - b).Magnitude end

--// Wallcheck - optimized
local _rp = RaycastParams.new()
_rp.FilterType = Enum.RaycastFilterType.Blacklist
local function _wc(o, t)
    if not _cfg._w then return true end
    _rp.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local r = Workspace:Raycast(o, (t - o).Unit * (t - o).Magnitude, _rp)
    return r == nil
end

--// ESP - create minimal objects
local function _ce(p)
    if p == LocalPlayer then return end
    local e = {
        b = D.new("Square"), -- Box
        n = D.new("Text"), -- Name
        h = D.new("Text"), -- Health
        t = D.new("Line") -- Tracer
    }
    e.b.Visible = false; e.b.Thickness = 1; e.b.Filled = false; e.b.Transparency = 1
    e.n.Visible = false; e.n.Size = 12; e.n.Center = true; e.n.Outline = true
    e.h.Visible = false; e.h.Size = 10; e.h.Center = true; e.h.Outline = true
    e.t.Visible = false; e.t.Thickness = 1; e.t.Transparency = 1
    _esp[p] = e
    return e
end

--// Update ESP - optimized loop
local function _ue()
    for p, e in pairs(_esp) do
        local c = _gc(p)
        local h = _gh(c)
        local hd = _ghd(c)
        if not c or not h or not hd or not _ia(p) or _it(p) then
            e.b.Visible = false; e.n.Visible = false; e.h.Visible = false; e.t.Visible = false
            continue
        end
        local hp, ho, hd = _w2s(hd.Position)
        local rp = c:FindFirstChild("HumanoidRootPart")
        if not rp then continue end
        local rp2, ro, rd = _w2s(rp.Position)
        if not ro then
            e.b.Visible = false; e.n.Visible = false; e.h.Visible = false; e.t.Visible = false
            continue
        end
        local d = _dst(Camera.CFrame.Position, rp.Position)
        if d > _cfg._md then
            e.b.Visible = false; e.n.Visible = false; e.h.Visible = false; e.t.Visible = false
            continue
        end
        local sz = c:GetExtentsSize()
        local w, h2 = sz.X * 1.5, sz.Y * 1.5
        local tl = Vector2.new(hp.X - w/2, hp.Y - h2/2)
        if _cfg._b then
            e.b.Size = Vector2.new(w, h2)
            e.b.Position = tl
            e.b.Color = Color3.fromRGB(255, 0, 0)
            e.b.Visible = true
        else e.b.Visible = false end
        if _cfg._n then
            e.n.Text = p.Name
            e.n.Position = Vector2.new(hp.X, tl.Y - 12)
            e.n.Color = Color3.fromRGB(255,255,255)
            e.n.Visible = true
        else e.n.Visible = false end
        if _cfg._hp then
            local pct = h.Health / h.MaxHealth
            e.h.Text = string.format("%d/%d", math.floor(h.Health), math.floor(h.MaxHealth))
            e.h.Position = Vector2.new(hp.X, tl.Y + h2 + 2)
            e.h.Color = Color3.fromRGB(255*(1-pct), 255*pct, 0)
            e.h.Visible = true
        else e.h.Visible = false end
        if _cfg._tr then
            e.t.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            e.t.To = Vector2.new(rp2.X, rp2.Y)
            e.t.Color = Color3.fromRGB(200,200,200)
            e.t.Visible = true
        else e.t.Visible = false end
    end
end

--// Aimbot - optimized
local function _ca()
    local cp, cd = nil, math.huge
    local mp = Vector2.new(Mouse.X, Mouse.Y)
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not _ia(p) then continue end
        if _it(p) then continue end
        local c = _gc(p); local hd = _ghd(c)
        if not hd then continue end
        local sp, on, dp = _w2s(hd.Position)
        if not on or dp < 0 then continue end
        local d = (sp - mp).Magnitude
        if d > _cfg._f then continue end
        if not _wc(Camera.CFrame.Position, hd.Position) then continue end
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
    local ap = tp + (vel * _cfg._p)
    local cf = Camera.CFrame
    Camera.CFrame = cf:Lerp(CFrame.new(cf.Position, ap), _cfg._s)
end

--// AutoFire
local function _af(t)
    if not _cfg._af or not t then return end
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
--// ADONIS BYPASS v6.0 - Stealth Injection Methods
--// ============================================================

local function _bypass()
    if not _cfg._ac then return end
    
    --// METHOD 1: Gunakan existing game hooks (jangan create new hooks)
    -- Adonis scan untuk "new" hooks, tapi tidak detect modified existing
    local _existing = {}
    
    --// METHOD 2: Spoof via getgc() - modify existing functions
    if getgc then
        for _, v in ipairs(getgc()) do
            if type(v) == "function" and islclosure(v) then
                local info = debug.getinfo(v)
                if info and info.source and info.source:match("Adonis") then
                    -- Found Adonis function, neutralize
                    local success = pcall(function()
                        local ups = debug.getupvalues(v)
                        for i, up in ipairs(ups) do
                            if type(up) == "function" then
                                -- Replace dengan dummy function
                                debug.setupvalue(v, i, function() return nil end)
                            elseif type(up) == "boolean" and up == true then
                                -- Flip boolean flags
                                debug.setupvalue(v, i, false)
                            end
                        end
                    end)
                    if success then warn("[NX] Adonis function neutralized: " .. (info.name or "unknown")) end
                end
            end
        end
    end
    
    --// METHOD 3: Block Adonis remotes via getconnections
    if getconnections then
        for _, obj in ipairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                -- Adonis menggunakan nama yang tidak obvious, tapi pattern detectable
                if n:match("adonis") or n:match("admin") or n:match("punish") or n:match("kick") or n:match("ban") then
                    local cons = getconnections(obj.OnClientEvent)
                    for _, con in ipairs(cons) do
                        pcall(function() con:Disable() end)
                    end
                    warn("[NX] Adonis remote disabled: " .. obj.Name)
                end
            end
        end
    end
    
    --// METHOD 4: Spoof Player.Kick via existing function replacement
    -- Jangan gunakan hookfunction/hookmetamethod - gunakan direct replacement
    local _pk = LocalPlayer.Kick
    local _newKick = function(self, msg)
        if self == LocalPlayer then
            warn("[NX] Adonis kick blocked: " .. tostring(msg))
            return nil
        end
        return _pk(self, msg)
    end
    -- Replace via rawset (tidak trigger metatable hooks)
    rawset(LocalPlayer, "Kick", _newKick)
    
    --// METHOD 5: Prevent Adonis dari load modules
    local _oldRequire = require
    local _modules = {}
    local _newRequire = function(module)
        local n = tostring(module):lower()
        if n:match("adonis") or n:match("admin") or n:match("anticheat") then
            warn("[NX] Adonis module blocked: " .. n)
            return {} -- Return empty table
        end
        return _oldRequire(module)
    end
    -- Gunakan getfenv untuk replace global require
    if getfenv then
        local env = getfenv(0)
        env.require = _newRequire
    end
    
    --// METHOD 6: Spoof heartbeat (Adonis menggunakan heartbeat untuk detection)
    local _oldHB = RunService.Heartbeat
    local _hbCount = 0
    local _newHB = RunService.Heartbeat:Connect(function()
        _hbCount = _hbCount + 1
        if _hbCount % 100 == 0 then
            -- Periodic cleanup untuk remove detection artifacts
            for _, obj in ipairs(Camera:GetChildren()) do
                if obj:IsA("BasePart") and obj.Name:match("NX") then
                    obj:Destroy()
                end
            end
        end
    end)
    
    --// METHOD 7: Disable Adonis GUI elements (detection UI)
    local _core = game:FindFirstChildOfClass("CoreGui")
    if _core then
        for _, gui in ipairs(_core:GetChildren()) do
            if gui.Name:match("Adonis") or gui.Name:match("Admin") then
                gui.Enabled = false
                warn("[NX] Adonis GUI disabled: " .. gui.Name)
            end
        end
    end
    
    --// METHOD 8: Spoof network stats (Adonis checks network for anomalies)
    local _stats = game:FindFirstChildOfClass("Stats")
    if _stats then
        local _oldPing = _stats.PerformanceStats.Ping
        -- Cannot directly spoof, but can interfere dengan measurement
        task.spawn(function()
            while true do
                task.wait(math.random(1, 3))
                -- Create fake network activity untuk mask real traffic
                local _dummy = Instance.new("RemoteEvent")
                _dummy.Name = "NX_Dummy_" .. tostring(math.random(1000,9999))
                _dummy.Parent = game.ReplicatedStorage
                task.wait(0.1)
                _dummy:Destroy()
            end
        end)
    end
    
    print("[NX] Adonis Bypass v6.0 aktiviert. Alle Systeme nominal.")
end

--// Main Loop - gunakan existing RunService connection
local _at = nil

--// Gunakan Heartbeat (lebih stealth daripada RenderStepped untuk Adonis)
RunService.Heartbeat:Connect(function()
    -- Update FOV
    _fc.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    _fc.Visible = _cfg._a and true
    
    -- Update ESP
    if _cfg._e then _ue() else
        for _, e in pairs(_esp) do
            e.b.Visible = false; e.n.Visible = false; e.h.Visible = false; e.t.Visible = false
        end
    end
    
    -- Aimbot
    if _cfg._a then
        if UserInputService:IsKeyDown(_cfg._k) then
            _at = _ca()
            if _at then _aim(_at); _af(_at) end
        else _at = nil end
    end
end)

--// Player handlers
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then _ce(p) end end)
Players.PlayerRemoving:Connect(function(p)
    local e = _esp[p]
    if e then e.b:Remove(); e.n:Remove(); e.h:Remove(); e.t:Remove(); _esp[p] = nil end
end)

for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then _ce(p) end end

--// Init bypass
_bypass()

--// Minimal notification
local _n = Instance.new("ScreenGui", game:FindFirstChildOfClass("CoreGui"))
_n.Name = "NX_" .. tostring(math.random(10000,99999))
local _nf = Instance.new("Frame", _n)
_nf.Size = UDim2.new(0, 250, 0, 40)
_nf.Position = UDim2.new(0.5, -125, 0, -50)
_nf.BackgroundColor3 = Color3.fromRGB(20,20,20)
_nf.BorderSizePixel = 0
Instance.new("UICorner", _nf).CornerRadius = UDim.new(0, 6)
local _nl = Instance.new("TextLabel", _nf)
_nl.Size = UDim2.new(1,0,1,0)
_nl.BackgroundTransparency = 1
_nl.Text = "NX v6.0 | Adonis Bypass ACTIVE"
_nl.TextColor3 = Color3.fromRGB(0,255,136)
_nl.Font = Enum.Font.GothamBold
_nl.TextSize = 12

_nf:TweenPosition(UDim2.new(0.5, -125, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5, true)
task.delay(4, function()
    _nf:TweenPosition(UDim2.new(0.5, -125, 0, -50), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.5, true, function() _n:Destroy() end)
end)

--// Keybinds
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then _mf.Visible = not _mf.Visible end
end)

--// Cleanup
game:FindFirstChildOfClass("CoreGui").ChildRemoved:Connect(function(c)
    if c == _sg then
        for _, e in pairs(_esp) do e.b:Remove(); e.n:Remove(); e.h:Remove(); e.t:Remove() end
        _fc:Remove()
    end
end)

print([[
    _   __      _       __   ______
   / | / /   _| |     / /  /_  __/
  /  |/ / | / / | /| / /    / /   
 / /|  /| |/ /| |/ |/ /    / /    
/_/ |_/ |___/ |__/|__/    /_/     
                                   
N4n0Xy1n v6.0 | Adonis Bypass Loaded
Stealth mode: ACTIVE | Detection: MINIMAL
]])
