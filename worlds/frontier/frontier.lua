-- Frontier MOO soundpack for MUSHclient.
-- The game sends hidden lines like "#$#sp play ship/launch" or "#$#sp amb amb/lake".
-- This script hides them and plays the matching sound from the sounds folder.
-- Needs the LuaAudio plugin (LuaAudio.xml), which this bundle loads for every world.

-- The LuaAudio plugin can load AFTER this one, so we look for it each time we need it.
PPI = require("ppi")
AUDIO_ID = "aedf0cb0be5bf045860d54b7"
ppi = nil

local function audio()
  if not ppi then ppi = PPI.Load(AUDIO_ID) end
  return ppi
end

-- MUSHclient calls this when plugins are added or reloaded.
function OnPluginListChanged()
  ppi = PPI.Load(AUDIO_ID)
end

local function snd_play(file, loop, pan, vol)
  local a = audio()
  if not a then return nil end
  local ok, id = pcall(a.play, file, loop, pan, vol)
  if ok then return id end
  return nil
end

local function snd_stop(id)
  local a = audio()
  if a and id then pcall(a.stop, id) end
end

local function snd_fade(id, ms)
  local a = audio()
  if a and id then
    if not pcall(a.fadeout, id, ms) then pcall(a.stop, id) end
  end
end

local function getnum(name, default)
  local v = tonumber(GetVariable(name) or "")
  if v == nil then return default end
  return v
end

sp_vol = getnum("sp_vol", 100)      -- sound effects volume, 0 to 100
sp_ambvol = getnum("sp_ambvol", 40) -- background (ambience) volume, 0 to 100
sp_mute = getnum("sp_mute", 0)      -- 1 = all sounds off
amb_id = nil
amb_name = nil

local function packdir()
  return string.gsub(GetInfo(56), "[\\/]+$", "") .. "\\worlds\\frontier\\"
end

local function sounddir()
  return packdir() .. "sounds\\"
end

local function exists(p)
  local f = io.open(p, "rb")
  if f then f:close() return true end
  return false
end

-- Load the sound map (soundmap.lua next to this file).
spmap = {}
pcall(dofile, packdir() .. "soundmap.lua")
math.randomseed(os.time())

-- Finds the file for a game sound: first from soundmap.lua, then sounds\group\name.ogg/.wav/.mp3.
-- Returns nil if there's no file, so that sound just stays quiet.
local function findsound(name)
  local m = spmap[name]
  if type(m) == "table" then m = m[math.random(#m)] end
  if type(m) == "string" then
    local p = sounddir() .. m:gsub("/", "\\")
    if exists(p) then return p end
    -- same name with another file type (.ogg, .wav or .mp3)
    local b = p:gsub("%.%w+$", "")
    for _, ext in ipairs({".ogg", ".wav", ".mp3"}) do
      if exists(b .. ext) then return b .. ext end
    end
  end
  local base = sounddir() .. name:gsub("/", "\\")
  for _, ext in ipairs({".ogg", ".wav", ".mp3"}) do
    if exists(base .. ext) then return base .. ext end
  end
  return nil
end

local function stopamb()
  if amb_id then
    snd_stop(amb_id)
  end
  amb_id = nil
end

amb_vol = nil

local function startamb(name, vol)
  stopamb()
  amb_name = name
  amb_vol = vol or sp_ambvol
  if sp_mute == 1 or name == "none" then return end
  local f = findsound(name)
  if f then
    amb_id = snd_play(f, 1, 0, amb_vol)
  end
end

-- The game adds your volume (0-100) at the end of each tag: "ship/launch 80".
-- You set the volumes in the game's sound settings (F2, or type spsettings).
local function splitvol(arg)
  local n, v = arg:match("^(.-)%s+(%d+)$")
  if n then return n, tonumber(v) end
  return arg, nil
end

-- Trigger: ^#\$#sp (\w+) ?(.*)$
function sp_tag(name, line, wc)
  local kind, arg = wc[1], wc[2]
  if kind == "play" then
    if sp_mute == 1 then return end
    local n, v = splitvol(arg)
    local f = findsound(n)
    if f then snd_play(f, 0, 0, v or sp_vol) end
  elseif kind == "amb" then
    local n, v = splitvol(arg)
    if n ~= amb_name then
      startamb(n, v)
    elseif v and v ~= amb_vol then
      -- same background, new volume: change it without restarting
      amb_vol = v
      local a = audio()
      if not (amb_id and a and pcall(a.setVol, v, amb_id)) then startamb(n, v) end
    end
  elseif kind == "loop" then
    -- "#$#sp loop <id> <name> <vol>": a looping sound besides the background, like a siren.
    local id, rest = arg:match("^(%S+)%s+(.+)$")
    if not id then return end
    local n, v = splitvol(rest)
    if sp_loops[id] then snd_stop(sp_loops[id]) end
    sp_loops[id] = nil
    if sp_mute == 1 then return end
    local f = findsound(n)
    if f then sp_loops[id] = snd_play(f, 1, 0, v or sp_vol) end
  elseif kind == "stoploop" then
    -- "#$#sp stoploop <id>": stop it right away.
    local id = arg:match("^(%S+)")
    if id and sp_loops[id] then snd_stop(sp_loops[id]) end
    if id then sp_loops[id] = nil end
  elseif kind == "hello" then
    amb_name = nil
  end
end

sp_loops = {}

local function stoploops()
  for id, h in pairs(sp_loops) do snd_stop(h) end
  sp_loops = {}
end

-- Hotkeys, like Cosmic Rage's. They open the game's sound settings.
local sp_keys = {
  {"F2", "spsettings"},
  {"F4", "spsettings master"},
  {"F5", "spsettings general"},
  {"F6", "spsettings ambience"},
  {"F7", "spsettings comms"},
  {"Shift+F5", "spsettings combat"},
  {"Shift+F6", "spsettings ship"},
  {"Shift+F7", "spsettings movement"},
  {"Shift+F8", "spsettings vehicles"},
  {"Alt+F6", "spsettings activities"},
  {"Ctrl+F7", "spsettings socials"},
  {"Ctrl+F8", "spsettings menus"},
}
for _, k in ipairs(sp_keys) do Accelerator(k[1], k[2]) end

-- Trigger: the game's welcome line after you log in. Turns the game's sound tags on.
function sp_login(name, line, wc)
  if intro_id then
    snd_fade(intro_id, 2000)
    intro_id = nil
  end
  if sp_sent then return end
  sp_sent = true
  Send("soundpack on")
end

-- Intro music when you connect. It fades out when you log in.
-- Also checks (hidden) if there's a soundpack update.
function OnPluginConnect()
  sp_sent = false
  if not audio() then
    Note("Frontier soundpack: the LuaAudio plugin isn't loaded, so sounds can't play.")
  end
  local f = findsound("music/intromusic/defaultintro")
  if f and sp_mute ~= 1 then intro_id = snd_play(f, 0, 0, sp_vol) end
  sp_runupdater("check", true)
end

function OnPluginDisconnect()
  stopamb()
  stoploops()
  amb_name = nil
  if intro_id then snd_stop(intro_id) intro_id = nil end
end

Note("Frontier soundpack loaded. Type sphelp for its commands.")

------------------------------------------------------------------
-- Updates. The updater (updater\update.ps1) gets new files from GitHub
-- and writes updater\status.txt when it's done; we wait for that file.
------------------------------------------------------------------
local function updir()
  return string.gsub(GetInfo(56), "[\\/]+$", "") .. "\\updater\\"
end

sp_upmode = nil
sp_upwait = 0
sp_upquiet = false

function sp_runupdater(mode, quiet)
  if sp_upmode then
    if not quiet then Note("The updater is already running. Please wait.") end
    return
  end
  local script = updir() .. "update.ps1"
  if not exists(script) then
    if not quiet then Note("The updater is missing (updater\\update.ps1).") end
    return
  end
  os.remove(updir() .. "status.txt")
  sp_upmode = mode
  sp_upwait = 0
  sp_upquiet = quiet
  local show = 1
  if mode == "check" then show = 0 end
  utils.shellexecute("powershell.exe",
    '-NoProfile -ExecutionPolicy Bypass -File "' .. script .. '" -Mode ' .. mode,
    updir(), "open", show)
  DoAfterSpecial(2, "sp_uppoll()", sendto.script)
end

function sp_uppoll()
  local f = io.open(updir() .. "status.txt", "r")
  if not f then
    sp_upwait = sp_upwait + 2
    if sp_upwait > 1800 then
      sp_upmode = nil
      if not sp_upquiet then Note("The updater is taking too long. Try spupdate again later.") end
      return
    end
    DoAfterSpecial(2, "sp_uppoll()", sendto.script)
    return
  end
  local lines = {}
  for l in f:lines() do table.insert(lines, l) end
  f:close()
  local mode, state = sp_upmode, lines[1] or "error"
  sp_upmode = nil
  if mode == "check" then
    if state == "available" then
      local s = findsound("general/notify")
      if s and sp_mute ~= 1 then snd_play(s, 0, 0, sp_vol) end
      Note("A soundpack update is ready. Type spupdate to get it.")
      for i = 2, math.min(#lines, 16) do Note(lines[i]) end
    elseif state == "uptodate" then
      if not sp_upquiet then Note("Your soundpack is up to date.") end
    elseif not sp_upquiet then
      Note(lines[2] or "Couldn't check for updates.")
    end
    return
  end
  -- finished spupdate
  for i = 2, math.min(#lines, 30) do Note(lines[i]) end
  if state == "done" then
    Note("Reloading the soundpack...")
    DoAfterSpecial(1, 'ReloadPlugin("' .. GetPluginID() .. '")', sendto.script)
  end
end

-- Alias: spupdate
function sp_update(name, line, wc)
  Note("Updating the soundpack. A window will show what it's downloading.")
  stopamb()
  sp_runupdater("update", false)
end

-- Alias: spcheck
function sp_check(name, line, wc)
  Note("Checking for a soundpack update...")
  sp_runupdater("check", false)
end

-- Alias: sphelp
function sp_help(name, line, wc)
  Note("Soundpack commands:")
  Note("  F2 (or spsettings)  sound settings menu: volume for each kind of sound")
  Note("  F4 master, F5 general, F6 ambience, F7 radio and phone")
  Note("  Shift+F5 combat, Shift+F6 ship, Shift+F7 ship movement, Shift+F8 vehicles")
  Note("  Alt+F6 jobs, Ctrl+F7 says and socials, Ctrl+F8 menu sounds")
  Note("  spvol <0-100>   master volume       ambvol <0-100>  background volume")
  Note("  spmute          all sounds off or on")
  Note("  spcheck         see if there's an update")
  Note("  spupdate        get the newest sounds")
end

-- Alias: spvol <0-100>. The game keeps your volumes, so this just asks it.
function sp_setvol(name, line, wc)
  Send("spsettings master " .. wc[1])
end

-- Alias: ambvol <0-100>
function sp_setambvol(name, line, wc)
  Send("spsettings ambience " .. wc[1])
end

-- Alias: spmute
function sp_togglemute(name, line, wc)
  if sp_mute == 1 then sp_mute = 0 else sp_mute = 1 end
  SetVariable("sp_mute", tostring(sp_mute))
  if sp_mute == 1 then
    stopamb()
    stoploops()
    Note("Sounds are muted. Type spmute again to turn them back on.")
  else
    local cur = amb_name
    if cur then startamb(cur, amb_vol) end
    Note("Sounds are on.")
  end
end
