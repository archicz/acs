local Heli = {}

function Heli:Initialize()
	self:SetModel("models/Combine_Helicopter.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end

    self:SetSubMaterial(1, "models/effects/vol_light001")
end

function Heli:Use(activator, caller)
    self:VehicleEnterSeat(activator)
end

return Heli