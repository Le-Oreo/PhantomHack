--[[
    Phantom Hack — Loader.lua
    Universal loader — detects which game you're in and
    loads the correct custom script automatically.
    If no custom script exists, loads Core.lua (universal).

    Players run ONLY this one line:
        loadstring(game:HttpGet("RAW_URL_OF_Loader.lua"))()

    To add a new game:
        1. Create a script file for it (e.g. MyGame.lua)
        2. Push it to GitHub
        3. Add the Place ID and raw URL to GAMES below
    by Oreo
]]

local RAW = "https://raw.githubusercontent.com/Le-Oreo/PhantomHack/main/"

-- ── Game registry ─────────────────────────────────────────────
-- Add more games here as you make custom scripts for them
local GAMES = {
    -- Booga Booga
    [11729688377] = RAW .. "BoogaBooga.lua",

    -- Add more below:
    -- [PLACE_ID] = RAW .. "YourGame.lua",
}

-- ── Detect and load ───────────────────────────────────────────
local placeId   = game.PlaceId
local scriptURL = GAMES[placeId] or (RAW .. "Core.lua")
local gameName  = GAMES[placeId] and ("Custom ["..placeId.."]") or "Universal"

print("[Phantom Hack] Place ID: " .. placeId)
print("[Phantom Hack] Loading: " .. gameName)
print("[Phantom Hack] URL: " .. scriptURL)

-- Small notification before menu loads so player knows what's happening
-- (menu loads async after key entry so this just shows in output)

local ok, err = pcall(function()
    loadstring(game:HttpGet(scriptURL, true))()
end)

if not ok then
    -- Fallback to universal Core if custom script fails
    warn("[Phantom Hack] Custom script failed: " .. tostring(err))
    warn("[Phantom Hack] Falling back to Core.lua...")
    pcall(function()
        loadstring(game:HttpGet(RAW .. "Core.lua", true))()
    end)
end
