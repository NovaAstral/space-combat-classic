--[[

	Developed By Dubby

	Copyright (c) Dubby 2010

	*Includes target-leading formula when only target input is given
	*Not complete.
]]--
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )

util.PrecacheSound( "sound/ship_weapons/wpn_plasma_blaster.wav" )

local ENERGY = 30000 //energy needed to fire weapon
local FIRE_DELAY = 2 //seconds that must elapse after a beam decays before a new beam can be created
local BEAM_OFFSET = -40 //where the beam starts on the model
local BEAM = { //information about the beam that we send to the beam entity
	range = 15000, //how long the beam can be
	lifespan = 5, //how many seconds the beam lasts
	decays_at = 0.5, //how many second(s) must remain before the beam begins to decay
	stretch_time = 1, //how many second(s) the beam needs to reach maximum length
	width = 25, //how wide the beam is (how spread out the traces are)
	density = 5, //controls how the beam can impact targets, and how resource intensive the beam is *for the server only*
	max_hits_per_second = 1, //limits how many times per second the beam can deal damage or push something
	damage_per_second = 5000, //damage to ships is this / hitspersecond, damage to shields is the same, but also times power^2
	power = 4 //500 ^ this = how much the beam 'can' push someing away when it strikes --was 4
	--there's also a color param, but that's set in wire trigger input.
}

function ENT:Initialize()
	--self:SetModel( "models/XQM/cylinderx1huge.mdl" )
	self:SetModel( "models/Slyfo/sat_rfg.mdl" )
	self:SetName( "Phaser" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )

	local inNames = {"Fire","X","Y","Z","Vector","Target","Color"}
	local inTypes = {"NORMAL","NORMAL","NORMAL","NORMAL","VECTOR","ENTITY","VECTOR"}
	self.Inputs = WireLib.CreateSpecialInputs( self,inNames,inTypes)
	self.Outputs = Wire_CreateOutputs( self, { "CanFire", "Firing" })

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass( 500 )
	end

	self.NextFire = 0
	self.SB_Ignore = true
	self.SB_Ignore = true
	self.SC_Immune = true
	self.Firing = false
	self.color = nil
	self.beam = nil
	self.vector = vector_origin

	RD_AddResource( self.Entity, "energy", ENERGY*2-20000)

	self.vector = vector_origin
end

function ENT:SpawnFunction( ply, tr )
	if ( not tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 40
	local ent = ents.Create( "phaser" )
	ent:SetAngles( tr.HitNormal:Angle() + Angle( 180, 0, 0 ) )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.Owner = ply
	return ent
end

function ENT:OnRemove()
	Dev_Unlink_All(self.Entity)
	if not (WireAddon == nil) then Wire_Remove(self.Entity) end
end

function ENT:Use( ply )
	if self.Owner ~= ply and not ply:IsAdmin() then
		ply:PrintMessage(HUD_PRINTCENTER,"You must own this [Phaser] to view its detailed information!" )
		return false
	end
	ply:PrintMessage(HUD_PRINTCONSOLE,"[Phaser] Information:")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Time delay between firing a beam = "..FIRE_DELAY.." second(s)")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Minimum Energy needed to fire = "..ENERGY.." energy")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Energy used per second while firing = "..tostring( ENERGY / BEAM.lifespan ).." energy")
	ply:PrintMessage(HUD_PRINTCONSOLE,"[Phaser Beam] Information:")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Beam Duration = "..BEAM.lifespan.." second(s)")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Maximum Range = "..BEAM.range)
	ply:PrintMessage(HUD_PRINTCONSOLE,"Damage per second vs Shields = "..tostring( BEAM.damage_per_second * BEAM.power / 2 ).."-"..tostring( BEAM.damage_per_second * BEAM.power ))
	ply:PrintMessage(HUD_PRINTCONSOLE,"Damage per second vs Ships = "..tostring( BEAM.damage_per_second / 2 ).."-"..tostring( BEAM.damage_per_second ))
	ply:PrintMessage(HUD_PRINTCONSOLE,"Damage Type = EM/Thermal")
	ply:PrintMessage(HUD_PRINTTALK,"Detailed information about [Phaser] has been posted to your console.")
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
			self.color = Vector( 50, 100, 300 )
			self.color.x = math.Clamp( value.x, 100, 255 )
			self.color.y = math.Clamp( value.y, 100, 255 )
			self.color.z = math.Clamp( value.z, 100, 255 )
		else
			self.color = nil
		end
	end
end

function ENT:HPFire()
	self.Firing = true
end

function ENT:GetTargetData() --phaser_beam asks the launcher what to point at
	if IsValid( self.target ) then
		return true, self.target
	elseif self.vector and self.vector ~= vector_origin then
		return false, self.vector
	else
		return nil, false
	end
end

function ENT:SetNextFire() --phaser_beam calls this so the launcher can react the instant the beam dies
	self.beam = nil
	self.NextFire = CurTime() + FIRE_DELAY
end

function ENT:DoWireOutput( a, b ) --just for convenience
	Wire_TriggerOutput( self, "CanFire", a )
	Wire_TriggerOutput( self, "Firing", b )
end

function ENT:Think()
	local ct, clk = CurTime(), 0.25
	if self.beam then
		local lifeleft, lastlife, lifespan = self.beam:GetLifeStats()
		self:Consume( ( lastlife - lifeleft ) / lifespan )
		self:DoWireOutput( 0, 1 )
	else
		if ct >= self.NextFire then
			if RD_GetResourceAmount( self.Entity, "energy" ) >= ENERGY then
				if self.Firing then
					self:Launch()
					self:DoWireOutput( 0, 1 )
				else
					self:DoWireOutput( 1, 0 )
				end
			else
				self:DoWireOutput( 0, 0 )
			end
		else
			self:DoWireOutput( 0, 0 )
		end
	end

	self.Entity:NextThink( ct + FrameTime() + clk )
	return true
end

function ENT:Touch( ent )
	if ent.HasHardpoints then
		if ent.Cont && ent.Cont:IsValid() then HPLink( ent.Cont, ent.Entity, self ) end
	end
end

function ENT:Consume( mul )
	RD_ConsumeResource( self, "energy", math.floor( ENERGY * mul ) )
end

function RealNormal(vec)

	return vec/math.sqrt(vec[1]^2 + vec[2]^2 + vec[3]^2)

end

function ENT:Launch()
	local dir = self:GetForward() * -1
	local shootpos = self:GetPos() + self:GetForward() * BEAM_OFFSET
	if IsValid( self.target ) then
		dir = RealNormal( self.target:GetPos() - shootpos )
	elseif self.vector and self.vector ~= vector_origin then
		dir = RealNormal( self.vector - shootpos)
	end

	local beam = ents.Create( "phaser_beam" )
		beam:SetPos( shootpos )
		beam:SetAngles( dir:Angle() )
		beam:SetOwner( self.Entity )
		beam:Spawn()
		beam:Setup( self.Entity, self.Owner, BEAM, ( self.color or Vector( 50, 100, 300 ) ) )
		beam:Activate()

	self.beam = beam

	// some beam charge/fire sound effect
	self:EmitSound( "ship_weapons/wpn_plasma_blaster.wav", 395, math.random(5)+60 )
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
