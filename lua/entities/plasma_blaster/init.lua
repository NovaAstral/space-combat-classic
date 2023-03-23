--[[

	Developed By Dubby

	Copyright (c) Dubby 2010

	*Includes target-leading formula when only target input is given
]]--
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )

util.PrecacheSound( "sound/ship_weapons/wpn_plasma_blaster.wav" )

local ENERGY = 2000 //energy needed to fire weapon --was 2000

function ENT:Initialize()
	self:SetModel( "models/Slyfo/sat_rtankengine.mdl" )
	self:SetName( "Plasma Blaster" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )

	local inNames = {"Fire","X","Y","Z","Vector","Target","Color"}
	local inTypes = {"NORMAL","NORMAL","NORMAL","NORMAL","VECTOR","ENTITY","VECTOR"}
	self.Inputs = WireLib.CreateSpecialInputs( self,inNames,inTypes)
	self.Outputs = Wire_CreateOutputs( self, { "CanFire" })

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end

	self.SB_Ignore = true
	self.SC_Immune = true
	self.Magazine = 0
	self.Firing = false

	RD_AddResource(self, "energy", ENERGY*3)

	self.vector = vector_origin
end

function ENT:SpawnFunction( ply, tr )
	if ( not tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 12
	local ent = ents.Create( "plasma_blaster" )
	ent:SetAngles( tr.HitNormal:Angle() + Angle( 180, 0, 0 ) )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent:GetPhysicsObject():Sleep()
	ent.Owner = ply
	return ent
end

function ENT:OnRemove()
	Dev_Unlink_All(self.Entity)
	if not (WireAddon == nil) then Wire_Remove(self.Entity) end
end

function ENT:Use( ply )
	if self.Owner ~= ply and not ply:IsAdmin() then
		ply:PrintMessage(HUD_PRINTCENTER,"You must own this [Plasma Blaster] to view its detailed information!" )
		return false
	end
	ply:PrintMessage(HUD_PRINTCONSOLE,"[Plasma Blaster] Information:")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Time delay between firing each round = 1/2 second")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Energy needed to fire a round = "..ENERGY.." energy")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Built-in Energy Storage capacity = "..tostring(ENERGY*3).." energy")
	ply:PrintMessage(HUD_PRINTCONSOLE,"[Plasma Bolt] Information:")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Projectile Velocity = 4,000~")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Projectile Range = 13,000~")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Impact Damage vs Shields = 1200-2400") --was 1500-2400
	ply:PrintMessage(HUD_PRINTCONSOLE,"Impact Damage vs Ships = 300-600") --+25 Piercing Damage --was 550-600
	ply:PrintMessage(HUD_PRINTCONSOLE,"Impact Damage Type = Thermal/Kinetic")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Explosion Radius = 50-90")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Explosion Damage Type = Thermal/Explosive")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Explosion Damage at Epicenter = 200-300") --was 250-400
	ply:PrintMessage(HUD_PRINTTALK,"Detailed information about [Plasma Blaster] has been posted to your console.")
	return false
end

function ENT:TriggerInput(iname, value)
	if (iname == "Fire") then
		if (value > 0) then
			self.Firing = true
		else
			self.Firing = false
		end
	elseif (iname == "X") then
		self.vector.x = value
	elseif (iname == "Y") then
		self.vector.y = value
	elseif (iname == "Z") then
		self.vector.z = value
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
			self.color = Vector( 40, 255, 80 )
			self.color.x = math.Clamp( value.x, 100, 255 )
			self.color.y = math.Clamp( value.y, 100, 255 )
			self.color.z = math.Clamp( value.z, 100, 255 )
		else
			self.color = nil --Vector( 40, 255, 80 )
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
			Wire_TriggerOutput(self, "CanFire", 0)
		end
	else
		if RD_GetResourceAmount( self, "energy" ) >= ENERGY then
			Wire_TriggerOutput(self, "CanFire", 1)
		else
			Wire_TriggerOutput(self, "CanFire", 0)
		end
	end

	self.Entity:NextThink( CurTime() + FrameTime() + 0.5 ) --was 0.25
	return true
end

function ENT:Touch( ent )
	if ent.HasHardpoints then
		if ent.Cont && ent.Cont:IsValid() then HPLink( ent.Cont, ent.Entity, self ) end
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
	local aimdir, speed = self:GetForward() * -1, 4000
	--local offset = math.floor( length / speed * length / 10 )
	--local shootpos = self:GetPos() + aimdir * ( 60 - offset ) + self:GetUp() * 2
	local offset = math.floor( length / speed * 200 )
	local shootpos = self:GetPos() + aimdir * ( 50 + offset ) + self:GetUp() * 2

	if IsValid( self.target ) then
		--do target leading calculations
		local tvel, tpos = self.target:GetVelocity(), self.target:GetPos()
		local distance = shootpos:Distance( tpos + tvel )
		aimdir = RealNormal( ( distance / speed * tvel + tpos ) - shootpos )
		if math.deg( math.acos( ( self:GetForward() * -1 ):DotProduct( aimdir ) ) ) > 90 then --was 60
			self:Refund()
			return
		end
	elseif self.vector and self.vector ~= vector_origin then
		--use given coords
		aimdir = RealNormal( self.vector - shootpos )
		if math.deg( math.acos( ( self:GetForward() * -1 ):DotProduct( aimdir ) ) ) > 90 then --was 60
			self:Refund()
			return
		end
	end

	--aimdir = ( aimdir * 0.982 + VectorRand() * 0.018 ):Normalize()
	aimdir = RealNormal( aimdir * 0.990 + VectorRand() * 0.020 )

	if IsValid( self.SC_CoreEnt ) then
		--check to see if the aimdir will hit something welded to the same ship, and if so, prevent it from firing!
		local tr = {}
		  tr.start = shootpos
		  tr.endpos = shootpos + aimdir * 1000
		  tr = util.TraceLine( tr )

		if tr.HitNonWorld then
			if IsValid( tr.HitEntity ) and IsValid( tr.HitEntity.SC_CoreEnt ) and self.SC_CoreEnt == tr.HitEntity.SC_CoreEnt then
				self:Refund()
				return
			end
		end
	end

	local bolt = ents.Create( "plasma_blaster_bolt" )
		bolt:SetPos( shootpos + (aimdir * 120) )
		bolt:SetAngles( aimdir:Angle() )
		if IsValid( self:GetParent() ) then
			bolt:SetOwner( self:GetParent() )
		else
			bolt:SetOwner( self.Entity )
		end
		bolt:Spawn()
		bolt:Setup( self.Entity, self.Owner, self.color )
		--bolt:SetVelocity( aimdir * ( speed + self:GetVelocity():Length() ) )
		bolt:SetVelocity( aimdir * speed )
		bolt:Activate()

	self:EmitSound( "ship_weapons/wpn_plasma_blaster.wav", 395, math.random(7)+93 )
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
