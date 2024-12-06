baseregistry = {}
baseregistry.Directory = "acs"

function baseregistry.Create(baseTbl, printName, dir)
    local registrySystem = {}
    local registryEntries = {}

    function registrySystem.GetList()
        return registryEntries
    end

    function registrySystem.Get(name)
        return registryEntries[name] or nil
    end

    function registrySystem.Register(name, tbl)
        local existingTbl = registrySystem.Get(name)
        if existingTbl then
            table.Merge(existingTbl, tbl)
            return existingTbl
        end

        setmetatable(tbl, __index = tbl.Base or baseTbl)
        registryEntries[name] = tbl
        return tbl
    end

    function registrySystem.Call(name, fn, ...)
        local tbl = registrySystem.Get(name)
        if not tbl then return end
    
        local tblFn = tbl[fn]
        if not tblFn then return end
    
        local succ, data = pcall(tblFn, ...)
        if not succ then
            print(string.format("%s [%s:%s] Error: %s", printName, name, fn, data))
            return 
        end
    
        return data
    end

    function registrySystem.Reload()
        local _, registryDirs = file.Find(baseregistry.Directory .. "/" .. , "LUA")

        for i = 1, #registryDirs do
            local dir = registryDirs[i]
            
            local sharedScript = string.format("%s/%s/shared.lua", baseregistry.Directory, dir)
            if file.Exists(sharedScript, "LUA") then
                if SERVER then
                    AddCSLuaFile(sharedScript)
                end
    
                local tbl = include(sharedScript)
                registrySystem.Register(dir, tbl)
            end
    
            if SERVER then
                local serverScript = string.format("%s/%s/init.lua", baseregistry.Directory, dir)
                if file.Exists(serverScript, "LUA") then
                    local tbl = include(serverScript)
                    registrySystem.Register(dir, tbl)
                end
            end
    
            local clientScript = string.format("%s/%s/cl_init.lua", baseregistry.Directory, dir)
            if file.Exists(clientScript, "LUA") then
                if SERVER then
                    AddCSLuaFile(clientScript)
                end
    
                if CLIENT then
                    local tbl = include(clientScript)
                    registrySystem.Register(dir, tbl)
                end
            end
        end
    end

    registrySystem.Reload()
    
    return registrySystem
end