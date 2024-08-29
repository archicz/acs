if not projectilesystem then return end
util.AddNetworkString(projectilesystem.NetworkString)

local ActiveProjectiles = projectilesystem.GetActive()
local Projectile = projectilesystem.GetProjectileMeta()