--[[

	Developed By Dubby

	Copyright (c) Dubby 2009

	*Includes target-leading formula when only target input is given
]]--
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )

util.PrecacheSound( "sound/ship_weapons/wpn_missile.wav" )

local ENERGY = 4000 //energy used to create ammo during reload phase
local CLIP = 8 //total capacity of ammo
local RELOAD = 0.5 //seconds it takes to make each ammo

function ENT:Initialize()
	self:SetModel( "models/Spacebuild/Nova/laser.mdl" )
	self:SetName( "Antimatter Blaster" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )

	local inNames = {"Fire","X","Y","Z","Vector","Target"}
	local inTypes = {"NORMAL","NORMAL","NORMAL","NORMAL","VECTOR","ENTITY"}
	self.Inputs = WireLib.CreateSpecialInputs( self,inNames,inTypes)
	self.Outputs = Wire_CreateOutputs( self, { "CanFire", "ShotsLeft" })

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end

	self.SB_Ignore = true
	self.Magazine = 0
	self.Firing = false
	self.ArmDelay = CurTime()

	RD_AddResource(self, "energy", 0)

	self.vector = vector_origin
end

function ENT:SpawnFunction( ply, tr )
	if ( not tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 240
	local ent = ents.Create( "antimatter_blaster" )
	ent:SetAngles( tr.HitNormal:Angle() + Angle( 90, 0, 90 ) )
	ent:SetPos( SpawnPos + ent:GetForward() * -52.6 + ent:GetUp() * 31.5 )
	ent:Spawn()
	ent:Activate()
	ent.Owner = ply
	ent:GetPhysicsObject():Sleep()
	return ent
end

function ENT:Use( ply )
	if self.Owner ~= ply and not ply:IsAdmin() then
		ply:PrintMessage(HUD_PRINTCENTER,"You must own this [Antimatter Blaster] to view its detailed information!" )
		return false
	end
	ply:PrintMessage(HUD_PRINTCONSOLE,"[Antimatter Blaster] Information:")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Time needed for constructing each round = "..RELOAD.." seconds")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Number of rounds which can be stored = "..CLIP)
	ply:PrintMessage(HUD_PRINTCONSOLE,"Time delay between firing each round = 1/2 second")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Energy needed for each round = "..ENERGY.." Energy")
	ply:PrintMessage(HUD_PRINTCONSOLE,"[Antimatter Bolt] Information:")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Projectile Velocity = 3,333")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Projectile Range = 25,000~")
	--ply:PrintMessage(HUD_PRINTCONSOLE,"*Half of impact damage ignores resistances!")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Explosion Radius = 250")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Explosion Damage at Epicenter = 150-300")
	--ply:PrintMessage(HUD_PRINTCONSOLE,"*Half of explosion damage ignores resistances!")
	ply:PrintMessage(HUD_PRINTTALK,"Detailed information about [Antimatter Blaster] has been posted to your console.")
	return false
end

function ENT:OnRemove()
	Dev_Unlink_All(self.Entity)
	if not (WireAddon == nil) then Wire_Remove(self.Entity) end
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
	end
end

function ENT:HPFire()
	self.Firing = true
end

function ENT:Think()
	if self.Firing then
		if (self.Magazine > 0) then
			self.Magazine = self.Magazine - 1
			self:Launch()
		else
			self.Firing = false
		end
	else
		if self.Magazine < CLIP then
			if CurTime() > self.ArmDelay then
				if RD_GetResourceAmount(self, "energy") > ENERGY then
					RD_ConsumeResource(self, "energy", ENERGY)
					self.Magazine = self.Magazine + 1
					self.ArmDelay = CurTime() + RELOAD
					self:EmitSound("Buttons.snd26")
				end
			end
		end
	end

	Wire_TriggerOutput(self, "ShotsLeft", self.Magazine)
	if (self.Magazine > 0) then
		Wire_TriggerOutput(self, "CanFire", 1)
	else
		Wire_TriggerOutput(self, "CanFire", 0)
	end

	self.Entity:NextThink( CurTime() + 0.25 )
	return true
end

function ENT:Touch( ent )
	if ent.HasHardpoints then
		if ent.Cont && ent.Cont:IsValid() then HPLink( ent.Cont, ent.Entity, self ) end
	end
end

function ENT:Refund()
	RD_SupplyResource(self, "energy", ENERGY)
	self.Magazine = self.Magazine + 1
end

function RealNormal(vec)
	return vec/math.sqrt(vec[1]^2 + vec[2]^2 + vec[3]^2)
end

function ENT:Launch()
	--local shootpos, aimdir, speed = self:GetPos() + self:GetForward() * 60 + self:GetUp() * -30, self:GetRight() * -1, 4000
	local length = self:GetVelocity():Length()
	local speed = 3333
	local aimdir = self:GetRight() * -1
	local offset = math.floor( length / speed * 200 )
	local shootpos = self:GetPos() + self:GetForward() * 60 + self:GetUp() * -30 + (aimdir * (16+offset))

	if IsValid( self.target ) then
		--do target leading calculations
		local mvel, tvel, tpos = self:GetVelocity(), self.target:GetVelocity(), self.target:GetPos()
		local distance = shootpos:Distance( tpos + tvel )
		print(distance)
		aimdir = RealNormal( ( distance / speed * tvel + tpos ) - shootpos )
		if math.deg( math.acos( self:GetRight():DotProduct( aimdir ) ) ) < 45 then
			self:Refund()
			return
		end
	elseif self.vector and self.vector ~= vector_origin then
		--use given coords
		aimdir = ( self.vector - shootpos )
		if math.deg( math.acos( self:GetRight():DotProduct( aimdir ) ) ) < 45 then
			self:Refund()
			return
		end
	end

	--aimdir = ( aimdir * 0.965 + VectorRand() * 0.035 ):Normalize()
	aimdir = RealNormal( aimdir * 0.982 + VectorRand() * 0.036 )
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

	local bolt = ents.Create( "antimatter_bolt" )
		bolt:SetPos( shootpos + (aimdir*120) )
		bolt:SetAngles( aimdir:Angle() )
		bolt:Setup( self.Entity, self.Owner )
		if IsValid( self:GetParent() ) then
			bolt:SetOwner( self:GetParent() )
		else
			bolt:SetOwner( self.Entity )
		end
		bolt:Spawn()
		--bolt:SetVelocity( aimdir * ( speed + self:GetVelocity():Length() ) )
		bolt:SetVelocity( aimdir * speed )
		bolt:Activate()

	self:EmitSound( "ship_weapons/wpn_missile.wav", 350+math.random(100), 175-math.random(25) )
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
