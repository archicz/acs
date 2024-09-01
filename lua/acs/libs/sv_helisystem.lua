if not helisystem then return end

local MouseSensitivity = 0.1

function helisystem.CreateHeli(owner, pos, ang, heliName)
    if not helisystem.Get(heliName) then return nil end
    local heliEnt = ents.Create(helisystem.ClassName)

    if IsValid(heliEnt) then
        heliEnt:HeliSetup(heliName)
        heliEnt:SetRealOwner(owner)
        heliEnt:SetPos(pos)
        heliEnt:SetAngles(ang)
        heliEnt:Spawn()
    end

    return heliEnt
end

function helisystem.ControlHeli(heliEnt, cmd)
    if not IsValid(heliEnt) then return end

    local forward = cmd:KeyDown(IN_FORWARD) and 1 or 0
    local back = cmd:KeyDown(IN_BACK) and 1 or 0

    local left = cmd:KeyDown(IN_MOVELEFT) and 1 or 0
    local right = cmd:KeyDown(IN_MOVERIGHT) and 1 or 0

    local mouseX = cmd:GetMouseX() * MouseSensitivity
    local mouseY = cmd:GetMouseY() * MouseSensitivity

    local collective = forward - back
    heliEnt:HeliApplyCollective(collective)

    local pitch = math.Clamp(mouseY, -1, 1)
    local yaw = left - right
    local roll = math.Clamp(mouseX, -1, 1)
    local cyclic = Angle(pitch, yaw, roll)
    heliEnt:HeliApplyCyclic(cyclic)
end