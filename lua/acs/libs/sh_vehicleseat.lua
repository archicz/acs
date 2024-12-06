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

vehicleseat = baseregistry.Create(BaseSeat, "Vehicleseat", "vehicleseats")
vehicleseat.ClassName = "acs_vehicleseat"
vehicleseat.NetworkString = "VehicleSeat"
vehicleseat.FreelookKey = IN_WALK

VEHICLESEAT_NET_ENTER = 0
VEHICLESEAT_NET_EXIT = 1
VEHICLESEAT_NET_CMD = 2
VEHICLESEAT_NET_FREELOOK = 3