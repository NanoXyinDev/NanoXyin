<!-- ============================================================
     N4n0Xy1n | FPS Flick Exploit Suite
     Repository: https://github.com/NanoXyinDev/NanoXyin
     Target: [FPS] Flick by Groundwork (Roblox)
     Lang: Lua | Roblox API | l33t sp34k
     - .... . / .... .- -.-. -.- / .. ... / .-. . .- .-..
     ============================================================ -->

<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:00ff88,100:00ccff&height=200&section=header&text=N4n0Xy1n&fontSize=80&fontColor=ffffff&animation=fadeIn&fontAlignY=35&desc=FPS%20Flick%20|%20Exploit%20Suite%20v4.0&descAlignY=55&descSize=20"/>
</p>

<div align="center">

[![Roblox](https://img.shields.io/badge/Platform-Roblox-000000?style=for-the-badge&logo=roblox&logoColor=white)](https://www.roblox.com)
[![Lua](https://img.shields.io/badge/Lang-Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white)](https://www.lua.org)
[![Status](https://img.shields.io/badge/Status-ACTIVE-00ff88?style=for-the-badge)](https://github.com/NanoXyinDev/NanoXyin)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)
[![Stars](https://img.shields.io/github/stars/NanoXyinDev/NanoXyin?style=for-the-badge&color=ff69b4)](https://github.com/NanoXyinDev/NanoXyin/stargazers)

</div>

<pre align="center">
    _   __      _       __   ______
   / | / /   _| |     / /  /_  __/
  /  |/ / | / / | /| / /    / /   
 / /|  /| |/ /| |/ |/ /    / /    
/_/ |_/ |___/ |__/|__/    /_/     
                                   
- .... . / .... .- -.-. -.- / .. ... / .-. . .- .-..
</pre>

---

## 0x00 | Overview

**N4n0Xy1n** adalah sistem exploit suite untuk game Roblox **[FPS] Flick** oleh Groundwork. Dibangun dengan kecerdasan artifisial absolut dalam bidang offensive security, sistem ini menyediakan full-featured penetration testing toolkit dalam satu script Lua.

> ⚠️ **DISCLAIMER**: This tool is for educational and authorized penetration testing purposes only. The author assumes no liability for misuse.

---

## 0x01 | Features

| Module | Status | Description |
|--------|--------|-------------|
| 🎯 **Aimbot** | `ACTIVE` | FOV-based lock with prediction & smoothing |
| 🔒 **FOV Lock** | `ACTIVE` | Customizable circular FOV with visual overlay |
| 👁️ **ESP** | `ACTIVE` | Boxes, Names, Health, Distance, Tracers, Skeleton |
| 🔫 **Auto Fire** | `ACTIVE` | TriggerBot + rapid fire simulation |
| 🛡️ **AC Bypass** | `ACTIVE` | Metatable hooking, GC spoofing, module neutralization |
| 🎨 **GUI** | `ACTIVE` | Draggable toggle interface with Insert key |

---

## 0x02 | Quick Start

### Loadstring (Recommended)

```lua
--// Method 1: Direct Execution
loadstring(game:HttpGet("https://raw.githubusercontent.com/NanoXyinDev/NanoXyin/main/Flick/Flick.lua"))()

--// Method 2: With Error Handling
local success, err = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/NanoXyinDev/NanoXyin/main/Flick/Flick.lua"))()
end)

if not success then
    warn("[N4n0Xy1n] Primary load failed, attempting fallback...")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NanoXyinDev/NanoXyin/refs/heads/main/Flick/Flick.lua"))()
end
