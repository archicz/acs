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
    return seatTbl[key] or nil
end

function ENT:SetupDataTables()
    self:NetworkVar("String", "SeatName")
    self:NetworkVar("Bool", "Active")
    self:NetworkVar("Entity", "Controller")
end