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

local function startamb(name)
  stopamb()
  amb_name = name
  if sp_mute == 1 or name == "none" then return end
  local f = findsound(name)
  if f then
    amb_id = snd_play(f, 1, 0, sp_ambvol)
  end
end

-- Trigger: ^#\$#sp (\w+) ?(.*)$
function sp_tag(name, line, wc)
  local kind, arg = wc[1], wc[2]
  if kind == "play" then
    if sp_mute == 1 then return end
    local f = findsound(arg)
    if f then snd_play(f, 0, 0, sp_vol) end
  elseif kind == "amb" then
    if arg ~= amb_name then startamb(arg) end
  elseif kind == "hello" then
    amb_name = nil
  end
end

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
  Note("  spvol <0-100>   sound effects volume")
  Note("  ambvol <0-100>  background volume")
  Note("  spmute          all sounds off or on")
  Note("  spcheck         see if there's an update")
  Note("  spupdate        get the newest sounds")
end

-- Alias: spvol <0-100>
function sp_setvol(name, line, wc)
  sp_vol = math.max(0, math.min(100, tonumber(wc[1]) or sp_vol))
  SetVariable("sp_vol", tostring(sp_vol))
  Note("Sound volume is " .. sp_vol .. ".")
end

-- Alias: ambvol <0-100>
function sp_setambvol(name, line, wc)
  sp_ambvol = math.max(0, math.min(100, tonumber(wc[1]) or sp_ambvol))
  SetVariable("sp_ambvol", tostring(sp_ambvol))
  local cur = amb_name
  if cur then startamb(cur) end
  Note("Background volume is " .. sp_ambvol .. ".")
end

-- Alias: spmute
function sp_togglemute(name, line, wc)
  if sp_mute == 1 then sp_mute = 0 else sp_mute = 1 end
  SetVariable("sp_mute", tostring(sp_mute))
  if sp_mute == 1 then
    stopamb()
    Note("Sounds are muted. Type spmute again to turn them back on.")
  else
    local cur = amb_name
    if cur then startamb(cur) end
    Note("Sounds are on.")
  end
end
