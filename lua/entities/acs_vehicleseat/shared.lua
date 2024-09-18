DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Vehicle Seat"
ENT.Author = "archi"
ENT.Information = ""
ENT.Category = "ACS"

ENT.Spawnable = false
ENT.AdminOnly = true

function ENT:GetVehicle()
    local vehicleEnt = self:GetParent()
    if not IsValid(vehicleEnt) then return nil end

    return vehicleEnt
end

function ENT:SeatData(key)
    local name = self:GetSeatName()
    local seatTbl = vehicleseat.Get(name)
    return seatTbl[key]
end

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "SeatName")

    self:NetworkVar("Bool", 0, "Active")

    self:NetworkVar("Entity", 0, "Controller")
end