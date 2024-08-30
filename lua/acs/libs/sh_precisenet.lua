if not net then return end

function net.WritePreciseVector(vec)
    net.WriteDouble(vec.x)
    net.WriteDouble(vec.y)
    net.WriteDouble(vec.z)
end

function net.ReadPreciseVector()
    local x = net.ReadDouble()
    local y = net.ReadDouble()
    local z = net.ReadDouble()

    return Vector(x, y, z)
end