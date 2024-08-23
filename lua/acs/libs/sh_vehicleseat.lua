local SeatList = {}
local BaseSeat =
{
    mdl = "models/nova/jeep_seat.mdl",
    solid = true,
    visible = true,

    animatedEntrance = true,
    entranceDuration = 0.75,

    viewPos = Vector(-0.0002, 2.0001, 37.2230),
    viewAng = Angle(0, 90, 0),

    freelook = true,
    freelookKey = false,
    freelookYawMin = -180,
    freelookYawMax = 180,
    freelookPitchMix = -90,
    freelookPitchMax = 90
}

vehicleseat = {}
vehicleseat.ClassName = "acs_vehicleseat"
vehicleseat.NetworkString = "VehicleSeat"
vehicleseat.FreelookKey = IN_WALK

VEHICLESEAT_NET_ENTER = 0
VEHICLESEAT_NET_EXIT = 1
VEHICLESEAT_NET_CMD = 2
VEHICLESEAT_NET_FREELOOK = 3

function vehicleseat.GetList()
    return SeatList
end

function vehicleseat.Get(name)
    return SeatList[name] or nil
end

function vehicleseat.Call(name, fn, ...)
    local seatTbl = vehicleseat.Get(name)
    if not seatTbl then return end

    local tblFn = seatTbl[fn]
    if not tblFn then return end

    return tblFn(...)
end

function vehicleseat.Register(name, seatTbl)
    setmetatable(seatTbl, {__index = BaseSeat})
    SeatList[name] = seatTbl
end