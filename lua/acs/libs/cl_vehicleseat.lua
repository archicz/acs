if not vehicleseat then return end
vehicleseat.ActiveSeat = nil
vehicleseat.ActiveSeatName = nil

local entranceEyePos = EyePos()
local entranceEyeAng = EyeAngles()
local entranceAnimEnd = 0

local m_yaw = GetConVar("m_yaw")
local m_pitch = GetConVar("m_pitch")
local freelookEnabled = false
local freelookPitch = 0
local freelookYaw = 0

function vehicleseat.HUDPaint()
    local seatEnt = vehicleseat.ActiveSeat
    if not IsValid(seatEnt) then return end

    local seatName = vehicleseat.ActiveSeatName
    if not seatName then return end

    return vehicleseat.Call(seatName, "HUDPaint", seatEnt)
end

function vehicleseat.PostProcess()
    local seatEnt = vehicleseat.ActiveSeat
    if not IsValid(seatEnt) then return end

    local seatName = vehicleseat.ActiveSeatName
    if not seatName then return end

    return vehicleseat.Call(seatName, "RenderScreenspaceEffects", seatEnt)
end

function vehicleseat.HUDPaint3D()
    local seatEnt = vehicleseat.ActiveSeat
    if not IsValid(seatEnt) then return end

    local seatName = vehicleseat.ActiveSeatName
    if not seatName then return end

    return vehicleseat.Call(seatName, "PostDrawOpaqueRenderables", seatEnt)
end

function vehicleseat.CalcView(_, pos, angles, fov)
    local seatEnt = vehicleseat.ActiveSeat
    if not IsValid(seatEnt) then return end

    local seatName = vehicleseat.ActiveSeatName
    if not seatName then return end
    
    local seatTbl = vehicleseat.Get(seatName)
    if not seatTbl then return end

    local viewPos = seatEnt:LocalToWorld(seatTbl.viewPos)
    local viewAng = seatEnt:LocalToWorldAngles(seatTbl.viewAng + vehicleseat.GetFreelookAngles())

    if seatTbl.animatedEntrance and CurTime() < entranceAnimEnd then
        local endDelta = entranceAnimEnd - CurTime()
        local frac = 1 - math.Clamp(endDelta / seatTbl.entranceDuration, 0, 1)

        viewPos = LerpVector(frac, entranceEyePos, viewPos)
        viewAng = LerpAngle(frac, entranceEyeAng, viewAng)
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
    local seatEnt = vehicleseat.ActiveSeat
    if not IsValid(seatEnt) then return end

    local seatName = vehicleseat.ActiveSeatName
    if not seatName then return end

    local seatTbl = vehicleseat.Get(seatName)
    if not seatTbl then return end

    if seatTbl.freelook and vehicleseat.CanFreelook() then
        local oldFreelookEnabled = freelookEnabled
        local newFreelookEnabled = false

        if not seatTbl.freelookKey or (seatTbl.freelookKey and cmd:KeyDown(vehicleseat.FreelookKey)) then
            freelookPitch = math.Clamp(freelookPitch + m_pitch:GetFloat() * cmd:GetMouseY(), seatTbl.freelookPitchMix, seatTbl.freelookPitchMax)
            freelookYaw = math.Clamp(freelookYaw - m_yaw:GetFloat() * cmd:GetMouseX(), seatTbl.freelookYawMin, seatTbl.freelookYawMax)
            newFreelookEnabled = true
        else
            freelookPitch = Lerp(FrameTime() * 5, freelookPitch, 0)
            freelookYaw = Lerp(FrameTime() * 5, freelookYaw, 0)
            newFreelookEnabled = false
        end

        freelookEnabled = newFreelookEnabled

        if oldFreelookEnabled != newFreelookEnabled then
            vehicleseat.NotifyFreelook()
        end
    end

    return vehicleseat.Call(seatName, "CreateMove", seatEnt, cmd)
end

function vehicleseat.CanFreelook()
    local seatName = vehicleseat.ActiveSeatName
    if not seatName then return end

    local seatTbl = vehicleseat.Get(seatName)
    if not seatTbl then return end

    if seatTbl.animatedEntrance then
        return (CurTime() > entranceAnimEnd)
    end

    return true
end

function vehicleseat.GetFreelookAngles()
    return Angle(freelookPitch, freelookYaw, 0)
end

function vehicleseat.GetLookPos()
    local seatName = vehicleseat.ActiveSeatName
    if not seatName then return end

    local seatTbl = vehicleseat.Get(seatName)
    if not seatTbl then return end
    
    return seatTbl.viewPos
end

function vehicleseat.IsFreelooking()
    return freelookEnabled
end

function vehicleseat.NotifyFreelook()
    net.Start(vehicleseat.NetworkString)
    net.WriteUInt(VEHICLESEAT_NET_FREELOOK, 4)
    net.WriteBit(freelookEnabled)
    net.SendToServer()
end

function vehicleseat.OnSeatEnter(seatEnt, name)
    local seatTbl = vehicleseat.Get(name)
    if not seatTbl then return end

    if seatTbl.animatedEntrance then
        entranceEyePos = EyePos()
        entranceEyeAng = EyeAngles()
        entranceAnimEnd = CurTime() + seatTbl.entranceDuration
    end

    if seatTbl.freelook then
        freelookPitch = 0
        freelookYaw = 0
        freelookEnabled = false
    end
    
    vehicleseat.Call(name, "OnEnter", seat)
    vehicleseat.ActiveSeat = seatEnt
    vehicleseat.ActiveSeatName = name
end

function vehicleseat.OnSeatExit()
    local seatName = vehicleseat.ActiveSeatName
    if not seatName then return end

    vehicleseat.Call(seatName, "OnExit")
    vehicleseat.ActiveSeat = nil
    vehicleseat.ActiveSeatName = nil
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

hook.Add("HUDPaint", "VehicleSeatHUD", vehicleseat.HUDPaint)
hook.Add("RenderScreenspaceEffects", "VehicleSeatPP", vehicleseat.PostProcess)
hook.Add("PostDrawOpaqueRenderables", "VehicleSeatHUD3D", vehicleseat.HUDPaint3D)
hook.Add("CalcView", "VehicleSeatView", vehicleseat.CalcView)
hook.Add("CreateMove", "VehicleSeatControl", vehicleseat.CreateMove)
net.Receive(vehicleseat.NetworkString, vehicleseat.ServerNetwork)