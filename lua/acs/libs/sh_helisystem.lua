local BaseHeli =
{
}

helisystem = baseregistry.Create(BaseHeli, "Heli", "helicopters")
helisystem.ClassName = "acs_helicopter"

if not pacmodel then return end

local function ParseHeli(name, tbl)
    if name != "heli" then return end

    local parts = tbl["children"]
    local heliCfg = {}

    for i = 1, #parts do
        local part = parts[i]
        local partInfo = part["self"]
        local partName = partInfo["Name"]

        if partName == "main_rotor" then
            heliCfg["main_rotor"] =
            {
                pos = partInfo["Position"],
                radius = partInfo["Scale"].x * 6
            }
        elseif partName == "tail_rotor" then
            heliCfg["tail_rotor"] =
            {
                pos = partInfo["Position"],
                radius = partInfo["Scale"].x * 6
            }
        end
    end

    return heliCfg
end

local function CreateHeli(ent, name, heliCfg)
    if name != "heli" then return end

    function ent:HeliMainRotorOrigin()
        return heliCfg["main_rotor"]
    end

    function ent:HeliTailRotorOrigin()
        return heliCfg["tail_rotor"]
    end
end

hook.Add("OnPACModelParse", "PACModelParseHeli", ParseHeli)
hook.Add("OnPACModelCreate", "PACModelCreateHeli", CreateHeli)