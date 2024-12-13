include("shared.lua")

function ENT:Initialize()
    self:HeliCall("Initialize")
end

function ENT:Think()
    self:HeliCall("Think")
end

function ENT:Draw()
    self:HeliCall("Draw")
end

function ENT:OnRemove()
    self:HeliCall("OnRemove")
end