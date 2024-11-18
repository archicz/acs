local HeliList = {}
local BaseHeli =
{
    mdl = "models/weapons/w_missile_closed.mdl"
}

helisystem = {}
helisystem.ClassName = "acs_helicopter"

function helisystem.GetList()
    return HeliList
end

function helisystem.Get(name)
    return HeliList[name] or nil
end

function helisystem.Call(name, fn, ...)
    local heliTbl = helisystem.Get(name)
    if not heliTbl then return end

    local tblFn = heliTbl[fn]
    if not tblFn then return end

    local succ, data = pcall(tblFn, ...)
    if not succ then
        print(string.format("Heli [%s:%s] Error: %s", name, fn, data))
        return 
    end

    return data
end

function helisystem.Register(name, heliTbl)
    setmetatable(heliTbl, {__index = BaseHeli})
    HeliList[name] = heliTbl
end