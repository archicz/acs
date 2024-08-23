AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.VehicleSeats = {}

function ENT:VehicleCreateSeats()
    for i = 1, #self.VehicleSeatsConfig do
        local seatInfo = self.VehicleSeatsConfig[i]

        local seat = vehicleseat.CreateSeat(
            self, 
            self:LocalToWorld(seatInfo["pos"]), 
            self:LocalToWorldAngles(seatInfo["ang"]), 
            seatInfo["name"]
        )

        local seatWps = seatInfo.weapons
        if seatWps then
            for j = 1, #seatWps do
                local wpnName = seatWps[j]
                local wpn = vehicleweapon.CreateWeapon(self, seat, wpnName)
            end
        end
        
        self.VehicleSeats[i] = seat
    end
end

function ENT:VehicleRemoveSeats()
    for i = 1, #self.VehicleSeats do
        local seat = self.VehicleSeats[i]
        if IsValid(seat) then
            SafeRemoveEntity(seat)
        end
    end
end

function ENT:VehicleEnterSeat(ply, seatId)
    if not seatId then
        for i = 1, #self.VehicleSeats do
            local seat = self.VehicleSeats[i]
    
            if IsValid(seat) and not seat:SeatOccupied() then
                seatId = i
                break
            end
        end
    end

    local seatEnt = self.VehicleSeats[seatId]
    if not IsValid(seatEnt) then return end

    seatEnt:SeatEnter(ply)
end

function ENT:OnRemove()
    self:VehicleRemoveSeats()
end