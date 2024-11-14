if not vehicleseat then return end
local ActiveSeat = false
local ActiveSeatName = false

local EntranceEyePos = EyePos()
local EntranceEyeAng = EyeAngles()
local EntranceAnimEnd = 0

local m_yaw = GetConVar("m_yaw")
local m_pitch = GetConVar("m_pitch")
local FreelookEnabled = false
local FreelookKey = IN_WALK
local FreelookPitch = 0
local FreelookYaw = 0

function vehicleseat.IsValid()
    local seatEnt = ActiveSeat
    if not IsValid(seatEnt) then return false end

    local seatName = ActiveSeatName
    if not seatName then return false end

    return true
end

function vehicleseat.GetSeat()
    return ActiveSeat
end

function vehicleseat.CanFreelook()
    local seatName = ActiveSeatName
    if not seatName then return end

    local seatTbl = vehicleseat.Get(seatName)
    if not seatTbl then return end

    if seatTbl.animatedEntrance then
        return (CurTime() > EntranceAnimEnd)
    end

    return true
end

function vehicleseat.GetEntraceAnimFraction()
    local seatName = ActiveSeatName
    if not seatName then return 0 end

    local seatTbl = vehicleseat.Get(seatName)
    if not seatTbl then return 0 end

    if seatTbl.animatedEntrance then
        local totalAnimDuration = seatTbl.entranceDuration
        local remainingDuration = EntranceAnimEnd - CurTime()

        if remainingDuration > 0 then
            local remainingPercent = 1 - (remainingDuration / totalAnimDuration)
            return remainingPercent
        end
    end

    return 1
end

function vehicleseat.GetFreelookAngles()
    return Angle(FreelookPitch, FreelookYaw, 0)
end

function vehicleseat.GetLookPos()
    local seatName = ActiveSeatName
    if not seatName then return end

    local seatTbl = vehicleseat.Get(seatName)
    if not seatTbl then return end
    
    return seatTbl.viewPos
end

function vehicleseat.IsFreelooking()
    return FreelookEnabled
end

function vehicleseat.NotifyFreelook()
    net.Start(vehicleseat.NetworkString)
    net.WriteUInt(VEHICLESEAT_NET_FREELOOK, 4)
    net.WriteBit(FreelookEnabled)
    net.SendToServer()
end

function vehicleseat.OnSeatEnter(seatEnt, name)
    local seatTbl = vehicleseat.Get(name)
    if not seatTbl then return end

    if seatTbl.animatedEntrance then
        EntranceEyePos = EyePos()
        EntranceEyeAng = EyeAngles()
        EntranceAnimEnd = CurTime() + seatTbl.entranceDuration
    end

    if seatTbl.freelook then
        FreelookPitch = 0
        FreelookYaw = 0
        FreelookEnabled = false
    end
    
    vehicleseat.Call(name, "OnEnter", seat)
    ActiveSeat = seatEnt
    ActiveSeatName = name
end

function vehicleseat.OnSeatExit()
    local seatName = ActiveSeatName
    if not seatName then return end

    vehicleseat.Call(seatName, "OnExit")
    ActiveSeat = false
    ActiveSeatName = false
end

function vehicleseat.DrawHUD()
    local seatEnt = ActiveSeat
    if not IsValid(seatEnt) then return end

    local seatName = ActiveSeatName
    if not seatName then return end

    return vehicleseat.Call(seatName, "DrawHUD", seatEnt)
end

function vehicleseat.CalcView(_, pos, angles, fov)
    local seatEnt = ActiveSeat
    if not IsValid(seatEnt) then return end

    local seatName = ActiveSeatName
    if not seatName then return end
    
    local seatTbl = vehicleseat.Get(seatName)
    if not seatTbl then return end

    local viewPos = seatEnt:LocalToWorld(seatTbl.viewPos)
    local viewAng = seatEnt:LocalToWorldAngles(seatTbl.viewAng + vehicleseat.GetFreelookAngles())

    if seatTbl.animatedEntrance and CurTime() < EntranceAnimEnd then
        local frac = vehicleseat.GetEntraceAnimFraction()

        viewPos = LerpVector(frac, EntranceEyePos, viewPos)
        viewAng = LerpAngle(frac, EntranceEyeAng, viewAng)
    end

    local view =
    {
        origin = viewPos,
        angles = viewAng,
        fov = fov,
        drawviewer = false
    }

    local overridenView = vehicleseat.Call(seatName, "CalcView", seatEnt, viewPos, viewAng, fov)
    return overridenView and overridenView or view
end

function vehicleseat.CreateMove(cmd)
    local seatEnt = ActiveSeat
    if not IsValid(seatEnt) then return end

    local seatName = ActiveSeatName
    if not seatName then return end

    local seatTbl = vehicleseat.Get(seatName)
    if not seatTbl then return end

    if seatTbl.freelook and vehicleseat.CanFreelook() then
        local oldFreelookEnabled = FreelookEnabled
        local newFreelookEnabled = false

        if not seatTbl.freelookKey or (seatTbl.freelookKey and cmd:KeyDown(FreelookKey)) then
            FreelookPitch = math.Clamp(FreelookPitch + m_pitch:GetFloat() * cmd:GetMouseY(), seatTbl.freelookPitchMix, seatTbl.freelookPitchMax)
            FreelookYaw = math.Clamp(FreelookYaw - m_yaw:GetFloat() * cmd:GetMouseX(), seatTbl.freelookYawMin, seatTbl.freelookYawMax)
            newFreelookEnabled = true
        else
            FreelookPitch = Lerp(FrameTime() * 5, FreelookPitch, 0)
            FreelookYaw = Lerp(FrameTime() * 5, FreelookYaw, 0)
            newFreelookEnabled = false
        end

        FreelookEnabled = newFreelookEnabled

        if oldFreelookEnabled != newFreelookEnabled then
            vehicleseat.NotifyFreelook()
        end
    end

    return vehicleseat.Call(seatName, "CreateMove", seatEnt, cmd)
end

function vehicleseat.PlayerButtonDown(ply, button)
    local seatEnt = ActiveSeat
    if not IsValid(seatEnt) then return end

    local seatName = ActiveSeatName
    if not seatName then return end

    return vehicleseat.Call(seatName, "ButtonPressed", seatEnt, button)
end

function vehicleseat.Think()
    local seatEnt = ActiveSeat
    if not IsValid(seatEnt) then return end

    local seatName = ActiveSeatName
    if not seatName then return end

    vehicleseat.Call(seatName, "Think", seatEnt)
end

function vehicleseat.ServerNetwork()
    local state = net.ReadUInt(4)
    local stateHandlers =
    {
        [VEHICLESEAT_NET_ENTER] = function()
            local seatEnt = net.ReadEntity()
            if not IsValid(seatEnt) then return end
            
            local seatName = seatEnt:GetSeatName()
            vehicleseat.OnSeatEnter(seatEnt, seatName)
        end,

        [VEHICLESEAT_NET_EXIT] = function()
            vehicleseat.OnSeatExit()
        end,
    }

    local stateFn = stateHandlers[state]
    if stateFn then
        pcall(stateFn)
    end
end

hook.Add("PreDrawEffects", "VehicleSeatDrawHUD", vehicleseat.DrawHUD)
hook.Add("CalcView", "VehicleSeatView", vehicleseat.CalcView)
hook.Add("CreateMove", "VehicleSeatControl", vehicleseat.CreateMove)
hook.Add("PlayerButtonDown", "VehicleSeatControl+", vehicleseat.PlayerButtonDown)
hook.Add("Think", "VehicleSeatThink", vehicleseat.Think)
net.Receive(vehicleseat.NetworkString, vehicleseat.ServerNetwork)