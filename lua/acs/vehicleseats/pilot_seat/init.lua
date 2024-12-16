local Seat = {}

function Seat:StartCommand(cmd)
    if vehicleseat.IsFreelooking(self) then return end

    local heliEnt = self:GetParent()
    if not IsValid(heliEnt) then return end

    helisystem.ControlHeli(heliEnt, cmd)
    vehicleseat.ControlWeapon(self, cmd)
end

function Seat:OnEnter(ply)
    local heliEnt = self:GetParent()
    if not IsValid(heliEnt) then return end

    heliEnt:HeliStart()
end

function Seat:OnExit(ply)
    local heliEnt = self:GetParent()
    if not IsValid(heliEnt) then return end

    heliEnt:HeliStop()
end

return Seat