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

if not pacmodel then return end

function vehicleseat.ParseVehicleSeat(name, tbl)
    if name != "vehicleseat" then return end

    local seats = tbl["children"]
    local seatsCfg = {}

    for i = 1, #seats do
        local seat = seats[i]["self"]

        local seatCfg = {}
        seatCfg["name"] = seat["Name"]
        seatCfg["pos"] = seat["Position"]
        seatCfg["ang"] = seat["Angles"]

        if vehicleweapon then
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

hook.Add("OnPACModelParse", "PACModelParseVehicleSeat", vehicleseat.ParseVehicleSeat)