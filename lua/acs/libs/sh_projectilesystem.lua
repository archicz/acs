local ProjectileList = {}
local BaseProjectile =
{
}

projectilesystem = {}
projectilesystem.NetworkString = "ProjectileSystem"

PROJECTILESYSTEM_NET_CREATE = 0

function projectilesystem.GetList()
    return ProjectileList
end

function projectilesystem.Get(name)
    return ProjectileList[name] or nil
end

function projectilesystem.Call(name, fn, ...)
    local projTbl = projectilesystem.Get(name)
    if not projTbl then return end

    local tblFn = projTbl[fn]
    if not tblFn then return end

    return tblFn(...)
end

function projectilesystem.Register(name, projTbl)
    setmetatable(projTbl, {__index = BaseProjectile})
    ProjectileList[name] = projTbl
end