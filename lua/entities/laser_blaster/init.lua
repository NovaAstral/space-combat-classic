--[[

	Developed By Dubby

	Copyright (c) Dubby 2010

	*Includes target-leading formula when only target input is given
]]--
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

util.PrecacheSound( "sound/ship_weapons/wpn_laser_blaster.wav" )

local ENERGY = 150 //energy needed to fire weapon

function ENT:Initialize()
	self.Entity:SetModel( "models/Slyfo_2/rocketpod_bigrocket.mdl" )
	self.Entity:SetName( "Laser Blaster" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetUseType( SIMPLE_USE )

	local inNames = {"Fire","Vector","Target","Color"}
	local inTypes = {"NORMAL","VECTOR","ENTITY","VECTOR"}
	self.Inputs = WireLib.CreateSpecialInputs( self.Entity,inNames,inTypes)
	self.Outputs = Wire_CreateOutputs( self.Entity, { "CanFire" })

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end

	self.SB_Ignore = true
	self.Magazine = 0
	self.Firing = false

	RD_AddResource(self.Entity, "energy", ENERGY*5)

	self.vector = vector_origin
end

function ENT:SpawnFunction( ply, tr )
	if ( not tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 23
	local ent = ents.Create( "laser_blaster" )
	ent:SetAngles( tr.HitNormal:Angle() + Angle( 90, 0, 0 ) )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.Owner = ply
	ent:GetPhysicsObject():Sleep()
	return ent
end

function ENT:OnRemove()
	Dev_Unlink_All(self.Entity)
	if not (WireAddon == nil) then Wire_Remove(self.Entity) end
end

function ENT:Use( ply )
	if self.Owner ~= ply and not ply:IsAdmin() then
		ply:PrintMessage(HUD_PRINTCENTER,"You must own this [Laser Blaster] to view its detailed information!" )
		return false
	end
	ply:PrintMessage(HUD_PRINTCONSOLE,"[Laser Blaster] Information:")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Time delay between firing each round = 1/4 second")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Energy needed to fire a round = "..ENERGY.." energy")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Built-in Energy Storage capacity = "..tostring(ENERGY*5).." energy")
	ply:PrintMessage(HUD_PRINTCONSOLE,"[Laser Bolt] Information:")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Projectile Velocity = 4,000")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Projectile Range = 21,000~")
	ply:PrintMessage(HUD_PRINTTALK,"Detailed information about [Laser Blaster] has been posted to your console.")
	return false
end

function ENT:TriggerInput(iname, value)
	if (iname == "Fire") then
		if (value > 0) then
			self.Firing = true
		else
			self.Firing = false
		end
	elseif (iname == "Vector") then
		self.vector = value
	elseif (iname == "Target") then
		if (value:IsValid()) then
			self.target = value
		else
			self.target = nil
		end
	elseif (iname == "Color") then
		if value then
			self.color = Vector( 255, 80, 40 )
			self.color.x = math.Clamp( value.x, 0, 255 )
			self.color.y = math.Clamp( value.y, 0, 255 )
			self.color.z = math.Clamp( value.z, 0, 255 )
		else
			self.color = nil --Vector( 255, 80, 40 )
		end
		self:SetNetworkedVector( "color", self.color )
	end
end

function ENT:HPFire()
	self.Firing = true
end

function ENT:Think()
	if self.Firing then
		if RD_GetResourceAmount( self, "energy" ) >= ENERGY then
			RD_ConsumeResource( self, "energy", ENERGY )
			self:Launch()
		else
			self.Firing = false
			Wire_TriggerOutput(self.Entity, "CanFire", 0)
		end
	else
		if RD_GetResourceAmount( self, "energy" ) >= ENERGY then
			Wire_TriggerOutput(self.Entity, "CanFire", 1)
		else
			Wire_TriggerOutput(self.Entity, "CanFire", 0)
		end
	end

	self.Entity:NextThink( CurTime() + FrameTime() + 0.25 )
	return true
end

function ENT:Touch( ent )
	if ent.HasHardpoints then
		if ent.Cont && ent.Cont:IsValid() then HPLink( ent.Cont, ent.Entity, self.Entity ) end
	end
end

function ENT:Refund()
	RD_SupplyResource( self, "energy", ENERGY )
end


function RealNormal(vec)

	return vec/math.sqrt(vec[1]^2 + vec[2]^2 + vec[3]^2)

end

function ENT:Launch()
	local length = self:GetVelocity():Length()
	local aimdir, speed = self:GetUp(), 4000
	--local offset = math.floor( length / speed * length / 10 )
	--local shootpos = self:GetPos() + aimdir * ( 50 + offset )
	local offset = math.floor( length / speed * 100 )
	local shootpos = self:GetPos() + aimdir * ( 50 + offset ) -- was 50
	if IsValid( self.target ) then
		--do target leading calculations
		local tvel, tpos = self.target:GetVelocity(), self.target:GetPos()
		local distance = shootpos:Distance( tpos + tvel )
		aimdir = RealNormal( ( distance / speed * tvel + tpos ) - shootpos )
		if math.deg( math.acos( self:GetUp():DotProduct( aimdir ) ) ) > 60 then
			self:Refund()
			return
		end
	elseif self.vector and self.vector ~= vector_origin then
		--use given coords
		aimdir = RealNormal( self.vector - shootpos )
		if math.deg( math.acos( self:GetUp():DotProduct( aimdir ) ) ) > 60 then
			self:Refund()
			return
		end
	end

	--aimdir = ( aimdir * 0.987 + VectorRand() * 0.013 ):Normalize()
	aimdir = RealNormal( aimdir * 0.993 + VectorRand() * 0.014 )

	local bolt = ents.Create( "laser_blaster_bolt" )
		bolt:SetPos( shootpos + (aimdir*120) )
		bolt:SetAngles( aimdir:Angle() )
		if IsValid( self:GetParent() ) then
			bolt:SetOwner( self:GetParent() )
		else
			bolt:SetOwner( self.Entity )
		end
		bolt:Spawn()
		bolt:Setup( self.Entity, self.Owner, self.color )
		bolt:Activate()
		--bolt:SetVelocity( aimdir * ( speed + offset ) + self:GetVelocity() )
		bolt:SetVelocity( aimdir * speed )
		--bolt:Activate()

	self:EmitSound( "ship_weapons/wpn_laser_blaster.wav", 380, math.random(7)+73 )
end

function ENT:PreEntityCopy()
	RD_BuildDupeInfo(self.Entity)
	if not (WireAddon == nil) then
		local DupeInfo = WireLib.BuildDupeInfo(self.Entity)
		if DupeInfo then
			duplicator.StoreEntityModifier( self.Entity, "WireDupeInfo", DupeInfo )
		end
	end
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	RD_ApplyDupeInfo(Ent, CreatedEntities)
	if not (WireAddon == nil) and (Ent.EntityMods) and (Ent.EntityMods.WireDupeInfo) then
		WireLib.ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
	end
end
