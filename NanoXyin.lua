--// N4n0Xy1n MM2 Loader
--// Raw URL: https://raw.githubusercontent.com/NanoXyinDev/NanoXyin/main/Mm2/Mm2.lua

local rawURL = "https://raw.githubusercontent.com/NanoXyinDev/NanoXyin/main/Mm2/Mm2.lua"

--// Method 1: Direct Execution
local success, result = pcall(function()
    return loadstring(game:HttpGet(rawURL))()
end)

if not success then
    warn("[N4n0Xy1n] Primary load failed: " .. tostring(result))
    
    --// Method 2: Fallback URL
    local fallbackURL = "https://raw.githubusercontent.com/NanoXyinDev/NanoXyin/refs/heads/main/Mm2/Mm2.lua"
    local success2, result2 = pcall(function()
        return loadstring(game:HttpGet(fallbackURL))()
    end)
    
    if not success2 then
        warn("[N4n0Xy1n] Fallback failed: " .. tostring(result2))
        
        --// Method 3: Alternative domain
        local altURL = "https://raw.githubusercontent.com/NanoXyinDev/NanoXyin/HEAD/Mm2/Mm2.lua"
        loadstring(game:HttpGet(altURL))()
    end
end
