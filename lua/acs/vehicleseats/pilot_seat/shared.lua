local Seat = 
{
    mdl = "models/nova/jalopy_seat.mdl",
    solid = false,
    visible = true,

    animatedEntrance = true,
    entranceDuration = 0.75,

    viewPos = Vector(-0.0002, 2.0001, 37.2230),
    viewAng = Angle(0, 90, 0),

    freelook = true,
    freelookKey = true,
    freelookYawMin = -40,
    freelookYawMax = 40,
    freelookPitchMix = -40,
    freelookPitchMax = 20,
}

return Seat