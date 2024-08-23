AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.SeatPod = nil

function ENT:Initialize()
	self:SetModel(self:SeatData("mdl"))
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(self:SeatData("solid") and SOLID_VPHYSICS or SOLID_NONE)
    self:DrawShadow(self:SeatData("visible"))

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end

    local pod = self:PodCreate()
    if not IsValid(pod) then
        SafeRemoveEntity(self)
    end

    self.SeatPod = pod
    self:SetActive(false)
    self:SetController(nil)

    if not self:SeatData("visible") then
        self:SetRenderMode(RENDERMODE_TRANSCOLOR)
        self:SetColor(Color(255, 255, 255, 0))    
    end
end

function ENT:PodCreate()
	local seat = ents.Create("prop_vehicle_prisoner_pod")

	if IsValid(seat) then
        seat:SetModel(self:GetModel())
        seat:SetPos(self:GetPos())
        seat:SetAngles(self:GetAngles())
        seat:SetParent(self)
        seat:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
        seat:SetKeyValue("limitview", "0")

        if not self:SeatData("visible") then
            seat:SetRenderMode(RENDERMODE_TRANSCOLOR)
            seat:SetColor(Color(255, 255, 255, 0))
        end

        seat:Spawn()
        seat:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
        seat:SetSolid(SOLID_NONE)
	end

    return seat
end

function ENT:OnEnter(ply)
    vehicleseat.NotifyEnter(self, ply)
end

function ENT:OnExit()
    local controller = self:GetController()
    if IsValid(controller) then
        vehicleseat.NotifyExit(self, controller)
    end
end

function ENT:SeatSetup(seatName)
    self:SetSeatName(seatName)
end

function ENT:SeatEnter(ply)
    local pod = self.SeatPod
    if not IsValid(pod) then return end

    local controller = self:GetController()
    if IsValid(controller) then return end
    
    pod:Use(ply, ply)
    self:SetActive(true)
    self:SetController(ply)
    self:OnEnter(ply)
end

function ENT:SeatExit()
    self:OnExit()
    self:SetActive(false)
    self:SetController(nil)
end

function ENT:SeatOccupied()
    return self:GetActive()
end

function ENT:SeatHandleExit()
    local pod = self.SeatPod
    if not IsValid(pod) then return end

    local active = self:GetActive()
    if not active then return end

    local controller = self:GetController()
    if not IsValid(controller) then return end

    local podDriver = pod:GetDriver()
    if not IsValid(podDriver) or not podDriver:Alive() or podDriver != controller then
        self:SeatExit()
    end
end

function ENT:Think()
    self:SeatHandleExit()
    self:NextThink(CurTime())
    return true
end

function ENT:OnRemove()
    local active = self:GetActive()
    if active then
        self:SeatExit()
    end

    local pod = self.SeatPod
    if IsValid(pod) then
        SafeRemoveEntity(pod)
    end
end