if not vehicleseat then return end
util.AddNetworkString(vehicleseat.NetworkString)

function vehicleseat.CreateSeat(baseEnt, pos, ang, seatName)
    if not vehicleseat.Get(seatName) then return nil end
    local seatEnt = ents.Create(vehicleseat.ClassName)
    local seatOwner = baseEnt:GetRealOwner()

    if IsValid(seatEnt) and not IsValid(seatOwner) then
        print("zasranej NADMOD pico")
        seatOwner = Entity(1)
    end

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

    vehicleseat.Call(seatName, "StartCommand", seatEnt, ply, cmd)
end

function vehicleseat.ClientNetwork(_, ply)
    local seatEnt = ply:GetVehicleSeat()
    if not IsValid(seatEnt) then return end

    local state = net.ReadUInt(4)
    local stateHandlers =
    {
        [VEHICLESEAT_NET_CMD] = function()
            -- TODO, when needed
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
net.Receive(vehicleseat.NetworkString, vehicleseat.ClientNetwork)

local PlyMeta = FindMetaTable("Player")

function PlyMeta:GetVehicleSeat()
    return self.VehicleSeat
end

function PlyMeta:SetVehicleSeat(seatEnt)
    self.VehicleSeat = seatEnt
end