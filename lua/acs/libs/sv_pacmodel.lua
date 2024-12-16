if not pacmodel then return end

local pacData = pacmodel.DecodePACFile("pac3/acs_heli/basicheli.txt", "DATA")
PrintTable(pacmodel.Parse(pacData))