pacmodel = {}

-- OnPACModelParse (string groupName, tbl groupTbl)

function pacmodel.DecodePAC(data)
    local func = CompileString(string.format("return { %s }", data), "luadata_decode", false)
    return func()
end

function pacmodel.DecodePACFile(path, gamePath)
    local data = file.Read(path, gamePath)
    return pacmodel.DecodePAC(data)
end

function pacmodel.Parse(tbl)
    if not tbl[1] then return end

    local groups = {}
    
    for i = 1, #tbl[1]["children"] do
        local groupTbl = tbl[1]["children"][i]
        local groupInfo = groupTbl["self"]
        local groupName = groupInfo["Name"]

        groups[groupName] = hook.Run("OnPACModelParse", groupName, groupTbl)
    end

    return groups
end

function pacmodel.SetupEntity(ent)
    
end

function pacmodel.ParsePhysics(name, tbl)
    if name != "physics" then return end

    local physicsBodies = tbl["children"]
    local meshes = {}

    for i = 1, #physicsBodies do
        local physBody = physicsBodies[i]["self"]
        local pos = physBody["Position"]
        local scale = physBody["Scale"]

        local mins = Vector(-6, -6, -6)
        local maxs = Vector(6, 6, 6)
        local scaledMins = Vector(mins.x * scale.x, mins.y * scale.y, mins.z * scale.z)
        local scaledMaxs = Vector(maxs.x * scale.x, maxs.y * scale.y, maxs.z * scale.z)

        local vertices =
        {
            pos + Vector(scaledMins.x, scaledMins.y, scaledMins.z),
            pos + Vector(scaledMins.x, scaledMins.y, scaledMaxs.z),
            pos + Vector(scaledMins.x, scaledMaxs.y, scaledMins.z), 
            pos + Vector(scaledMins.x, scaledMaxs.y, scaledMaxs.z),
            pos + Vector(scaledMaxs.x, scaledMins.y, scaledMins.z),
            pos + Vector(scaledMaxs.x, scaledMins.y, scaledMaxs.z),
            pos + Vector(scaledMaxs.x, scaledMaxs.y, scaledMins.z),
            pos + Vector(scaledMaxs.x, scaledMaxs.y, scaledMaxs.z)
        }

        table.insert(meshes, vertices)
    end

    return meshes
end

function pacmodel.ParseVisual(name, tbl)
    if name != "visual" then return end

    return tbl
end

hook.Add("OnPACModelParse", "PACModelParsePhysics", pacmodel.ParsePhysics)
hook.Add("OnPACModelParse", "PACModelParseVisual", pacmodel.ParseVisual)