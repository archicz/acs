local BaseHeli =
{
    mdl = "models/weapons/w_missile_closed.mdl"
}

helisystem = baseregistry.Create(BaseHeli, "Heli", "helicopters")
helisystem.ClassName = "acs_helicopter"