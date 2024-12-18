if not vehicleseat then return end
util.AddNetworkString(vehicleseat.NetworkString)

function vehicleseat.CreateSeat(baseEnt, pos, ang, seatName)
    if not vehicleseat.Get(seatName) then return nil end
    local seatEnt = ents.Create(vehicleseat.ClassName)
    local seatOwner = baseEnt:GetRealOwner()

    if IsValid(seatEnt) and IsValid(seatOwner) then
        seatEnt:SeatSetup(seatName)
        seatEnt:SetRealOwner(seatOwner)
        seatEnt:SetPos(pos)
        seatEnt:SetAngles(ang)
        seatEnt:SetParent(baseEnt)
        seatEnt:Spawn()
    end

    return seatEnt
end

function vehicleseat.SetupVehicle(ent)
    ent.VehicleSeats = {}

    function ent:VehicleCreateSeats(seatsCfg)
        for i = 1, #seatsCfg do
            local seatInfo = seatsCfg[i]
    
            local seat = vehicleseat.CreateSeat(
                self, 
                self:LocalToWorld(seatInfo["pos"]), 
                self:LocalToWorldAngles(seatInfo["ang"]), 
                seatInfo["name"]
            )
            
            if vehicleweapon then
                local seatWps = seatInfo.weapons
                if seatWps then
                    for j = 1, #seatWps do
                        local wpnName = seatWps[j]
                        local wpn = vehicleweapon.CreateWeapon(self, seat, wpnName)
                    end
                end
            end
            
            self.VehicleSeats[i] = seat
        end
    end
    
    function ent:VehicleRemoveSeats()
        for i = 1, #self.VehicleSeats do
            local seat = self.VehicleSeats[i]
            if IsValid(seat) then
                SafeRemoveEntity(seat)
            end
        end
    end
    
    function ent:VehicleEnterSeat(ply, seatId)
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
end

function vehicleseat.IsFreelooking(seatEnt)
    return seatEnt.FreelookEnabled
end

function vehicleseat.NotifyEnter(seatEnt, ply)
    if not IsValid(seatEnt) then return end
    if not IsValid(ply) then return end

    local seatName = seatEnt:GetSeatName()
    vehicleseat.Call(seatName, "OnEnter", seatEnt, ply)
    hook.Run("OnVehicleSeatEnter", seatEnt, ply)
    ply:SetVehicleSeat(seatEnt)

    net.Start(vehicleseat.NetworkString)
    net.WriteUInt(VEHICLESEAT_NET_ENTER, 4)
    net.WriteEntity(seatEnt)
    net.Send(ply)
end

function vehicleseat.NotifyExit(seatEnt, ply)
    if not IsValid(seatEnt) then return end
    if not IsValid(ply) then return end

    local seatName = seatEnt:GetSeatName()
    vehicleseat.Call(seatName, "OnExit", seatEnt, ply)
    hook.Run("OnVehicleSeatExit", seatEnt, ply)
    ply:SetVehicleSeat(nil)
    
    net.Start(vehicleseat.NetworkString)
    net.WriteUInt(VEHICLESEAT_NET_EXIT, 4)
    net.Send(ply)
end

function vehicleseat.StartCommand(ply, cmd)
    if not IsValid(ply) then return end

    local seatEnt = ply:GetVehicleSeat()
    if not IsValid(seatEnt) then return end

    local seatName = seatEnt:GetSeatName()
    if not seatName then return end

    vehicleseat.Call(seatName, "StartCommand", seatEnt, cmd)
end

function vehicleseat.PlayerButtonDown(ply, button)
    if not IsValid(ply) then return end

    local seatEnt = ply:GetVehicleSeat()
    if not IsValid(seatEnt) then return end

    local seatName = seatEnt:GetSeatName()
    if not seatName then return end

    vehicleseat.Call(seatName, "ButtonPressed", seatEnt, button)
end

function vehicleseat.ClientNetwork(_, ply)
    local seatEnt = ply:GetVehicleSeat()
    if not IsValid(seatEnt) then return end

    local state = net.ReadUInt(4)
    local stateHandlers =
    {
        [VEHICLESEAT_NET_CMD] = function()
            -- Not used by anything right now
        end,

        [VEHICLESEAT_NET_FREELOOK] = function()
            seatEnt.FreelookEnabled = (net.ReadBit() == 1)
        end,
    }

    local stateFn = stateHandlers[state]
    if stateFn then
        pcall(stateFn)
    end
end

hook.Add("StartCommand", "VehicleSeatControls", vehicleseat.StartCommand)
hook.Add("PlayerButtonDown", "VehicleSeatControls+", vehicleseat.PlayerButtonDown)
net.Receive(vehicleseat.NetworkString, vehicleseat.ClientNetwork)

local PlyMeta = FindMetaTable("Player")

function PlyMeta:GetVehicleSeat()
    return self.VehicleSeat
end

function PlyMeta:SetVehicleSeat(seatEnt)
    self.VehicleSeat = seatEnt
end

if not pacmodel then return end

local function ParseVehicleSeat(name, tbl)
    if name != "vehicleseat" then return end

    local seats = tbl["children"]
    local seatsCfg = {}

    for i = 1, #seats do
        local seat = seats[i]["self"]

        local seatCfg = {}
        seatCfg["name"] = seat["Name"]
        seatCfg["pos"] = seat["Position"]
        seatCfg["ang"] = seat["Angles"]

        if vehicleweapon then -- This will change
            local seatWeapons = {}
            local weaponsList = {}

            if seats[i]["children"] then
                seatWeapons = seats[i]["children"]
            end
            
            for j = 1, #seatWeapons do
                local seatWeapon = seatWeapons[i]["self"]
                table.insert(weaponsList, seatWeapon["Name"])
            end
    
            seatCfg["weapons"] = weaponsList
        end

        table.insert(seatsCfg, seatCfg)
    end

    return seatsCfg
end

local function CreateVehicleSeat(ent, name, seatsCfg)
    if CLIENT then return end
    if name != "vehicleseat" then return end

    vehicleseat.SetupVehicle(ent)
    ent:VehicleCreateSeats(seatsCfg)
end

hook.Add("OnPACModelParse", "PACModelParseVehicleSeat", ParseVehicleSeat)
hook.Add("OnPACModelCreate", "PACModelCreateVehicleSeat", CreateVehicleSeat)