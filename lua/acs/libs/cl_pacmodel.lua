if not pacmodel then return end

local function ParseVisual(name, tbl)
    if name != "visual" then return end
    return tbl
end

local function CreateVisual(ent, name, outfit)
    if name != "visual" then return end

    pac.SetupENT(ent)
    ent:AttachPACPart(outfit)
    ent:SetPACDrawDistance(PACMODEL_VISUAL_DISTANCE)

    function ent:PACModelGetOutfit()
        return outfit
    end

    function ent:PACModelRemoveOutfit()
        ent:RemovePACPart(outfit)
    end
end

hook.Add("OnPACModelParse", "PACModelParseVisual", ParseVisual)
hook.Add("OnPACModelCreate", "PACModelCreateVisuals", CreateVisual)