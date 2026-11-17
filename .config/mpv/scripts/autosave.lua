-- autosave.lua: resume YouTube/network streams across mov-cli launches.
-- Native mpv watch-later fails here: the entry is keyed on the resolved
-- googlevideo URL which contains expiring tokens, so a new launch resolves
-- a different URL and never matches. Instead we key on the original URL
-- (property `path`, stable) and seek on load ourselves.
local interval = 10
local dir = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state"))
dir = dir .. "/mpv/mov-cli-resume"
os.execute("mkdir -p " .. dir)

local function key_of(s)
    if not s or s == "" then return nil end
    local k = s:gsub("[^%w]", "_")
    if #k > 150 then k = k:sub(-150) end
    return k
end

local function file_for(key) return dir .. "/" .. key end

local current = nil      -- resume file path for current media

mp.register_event("file-loaded", function()
    current = nil
    -- mov-cli always passes --force-media-title="Title ~ Uploader" (stable).
    -- The raw `path` is the signed googlevideo URL, which changes per launch.
    local stable = mp.get_property("force-media-title") or mp.get_property("path")
    local key = key_of(stable)
    if not key then return end
    current = file_for(key)
    local f = io.open(current, "r")
    if not f then return end
    local pos = tonumber(f:read("*l") or "")
    f:close()
    if pos and pos > 5 then
        local done = false
        local function try_seek()
            if done then return end
            if mp.get_property("percent-pos") then
                done = true
                mp.commandv("seek", pos, "absolute")
                mp.msg.info("resumed at " .. pos)
                mp.osd_message("Resumed at " ..
                    math.floor(pos / 60) .. ":" ..
                    string.format("%02d", math.floor(pos) % 60))
            else
                mp.add_timeout(1.0, try_seek)  -- stream still buffering, retry
            end
        end
        local started = function() mp.add_timeout(0.5, try_seek) end
        mp.register_event("playback-restart", started)
        mp.add_timeout(3.0, try_seek)
    end
end)

mp.add_periodic_timer(interval, function()
    if not current then return end
    local pos = mp.get_property("time-pos")
    if not pos then return end
    -- treat near-end as finished: drop the resume point
    local pct = tonumber(mp.get_property("percent-pos") or 0)
    if pct > 98 then
        os.remove(current)
        return
    end
    local f = io.open(current, "w")
    if f then f:write(pos) f:close() end
end)

mp.register_event("end-file", function(ev)
    if ev.reason == "eof" and current then
        os.remove(current)
    end
    current = nil
end)
