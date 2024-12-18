include("shared.lua")

function ENT:Initialize()
    pacmodel.SetupEntity(self)
    self:PACModelCreate(self:HeliData("pacMdl"))
    
    self:HeliCall("Initialize")
end

function ENT:Think()
    if self:IsDormant() then return end

    self:HeliUpdateRotors()
    self:HeliCall("Think")
end

function ENT:Draw()
    self:HeliCall("Draw")
end

function ENT:OnRemove()
    self:HeliCall("OnRemove")
end