local function ClientsideScript(path)
    local absPath = "acs/" .. path

    if CLIENT then include(absPath) end
    if SERVER then AddCSLuaFile(absPath) end
end

local function SharedScript(path)
    local absPath = "acs/" .. path

    if CLIENT then include(absPath) end
    if SERVER then AddCSLuaFile(absPath) include(absPath) end
end

local function ServersideScript(path)
    local absPath = "acs/" .. path

    if SERVER then include(absPath) end
end

-- Libraries
SharedScript("libs/sh_entlist.lua")
SharedScript("libs/sh_vischeck.lua")
SharedScript("libs/sh_analogmapper.lua")

SharedScript("libs/sh_json.lua")
SharedScript("libs/sh_wavfile.lua")
ClientsideScript("libs/cl_soundreverse.lua")
ClientsideScript("libs/cl_3dui.lua")
ClientsideScript("libs/cl_bloomrt.lua")
-- ClientsideScript("libs/cl_yolox.lua")
ServersideScript("libs/sv_discord.lua")

ServersideScript("libs/sh_ownerwrapper.lua")
ServersideScript("libs/sv_angforce.lua")

ServersideScript("libs/sv_damagesystem.lua")

SharedScript("libs/sh_vehicleseat.lua")
ClientsideScript("libs/cl_vehicleseat.lua")
ServersideScript("libs/sv_vehicleseat.lua")

SharedScript("libs/sh_projectilesystem.lua")
ClientsideScript("libs/cl_projectilesystem.lua")
ServersideScript("libs/sv_projectilesystem.lua")

SharedScript("libs/sh_vehicleweapon.lua")
ClientsideScript("libs/cl_vehicleweapon.lua")
ServersideScript("libs/sv_vehicleweapon.lua")

SharedScript("libs/sh_missilesystem.lua")
ClientsideScript("libs/cl_missilesystem.lua")
ServersideScript("libs/sv_missilesystem.lua")

SharedScript("libs/sh_helisystem.lua")
ClientsideScript("libs/cl_helisystem.lua")
ServersideScript("libs/sv_helisystem.lua")

-- Modules
SharedScript("modules/sh_missiles.lua")
SharedScript("modules/sh_combine_heli.lua")