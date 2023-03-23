--[[

	Developed By Dubby

	Copyright (c) Dubby 2009

	*Rapid-fire template
]]--
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheSound( "sound/ship_weapons/wpn_autocannon.wav" )

local ENERGY = 25 //energy used to create single round
local CLIP = 20 //total capacity of ammo
local RELOAD = 2 //total time needed to completely refill an empty clip
local RPM = 400 //rounds per minute [rate of fire]

function ENT:Initialize()
	self:SetModel( "models/Slyfo/rover1_sidegun.mdl" )
	self:SetName( "Autocannon" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )

	self.Inputs = Wire_CreateInputs( self, { "Fire" } )
	self.Outputs = Wire_CreateOutputs( self, { "CanFire", "ShotsLeft" })

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end

	self.Magazine = 0
	self.Firing = false
	self.NextFire = CurTime()
	self.LastThink = CurTime()

	RD_AddResource(self, "energy", 0)
end

function ENT:SpawnFunction( ply, tr )
	if ( not tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 24
	local ent = ents.Create( "autocannon" )
	ent:SetAngles( tr.HitNormal:Angle() )
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
		ply:PrintMessage(HUD_PRINTCENTER,"You must own this [Autocannon] to view its detailed information!" )
		return false
	end
	ply:PrintMessage(HUD_PRINTCONSOLE,"[Autocannon] Information:" )
	ply:PrintMessage(HUD_PRINTCONSOLE,"Time needed for constructing each round = "..tostring( RELOAD / CLIP ).." seconds" )
	ply:PrintMessage(HUD_PRINTCONSOLE,"Energy used to create one round = "..ENERGY.." Energy" )
	ply:PrintMessage(HUD_PRINTCONSOLE,"Number of rounds which can be stored = "..CLIP.." Rounds" )
	ply:PrintMessage(HUD_PRINTCONSOLE,"Energy needed to create entire clip = "..tostring( ENERGY * CLIP ).." Energy" )
	ply:PrintMessage(HUD_PRINTCONSOLE,"Maximum Rate of Fire = "..RPM.." Rounds per Minute" )
	ply:PrintMessage(HUD_PRINTCONSOLE,"[50mm Autocannon Shell] Information:" )
	ply:PrintMessage(HUD_PRINTCONSOLE,"Projectile Velocity = 4,000" )
	ply:PrintMessage(HUD_PRINTCONSOLE,"Projectile Range = 14,000~")
	ply:PrintMessage(HUD_PRINTTALK,"Detailed information about [Autocannon] has been posted to your console. Press [`] to open your console." )
	return false
end

function ENT:TriggerInput(iname, value)
	if (iname == "Fire") then
		if (value > 0) then
			self.Firing = true
		else
			self.Firing = false
		end
	end
end

function ENT:HPFire()
	self.Firing = true
end

function ENT:Think()
	local ct, clk = CurTime(), 0.1
	if self.Firing then
		if tobool( math.floor(self.Magazine) ) then
			--if ct >= self.NextFire then
				clk = 1 / ( RPM / 60 )
			--	self.NextFire = ct + nf
				self.Magazine = self.Magazine - 1
				self:Launch()
			--end
		else
			self.Firing = false
		end
	else
		if self.Magazine < CLIP then
			local mult, give = ( ct - self.LastThink ) / clk, math.min( CLIP - self.Magazine, CLIP / RELOAD * clk )
			local cost = math.floor( ENERGY * give )
			if RD_GetResourceAmount( self, "energy" ) >= cost then
				RD_ConsumeResource( self, "energy", cost )
				self.Magazine = math.min( self.Magazine + give, CLIP )
			end
		end
	end

	if tobool( self.Magazine ) then
		Wire_TriggerOutput( self, "CanFire", 1 )
	else
		Wire_TriggerOutput( self, "CanFire", 0 )
	end
	Wire_TriggerOutput( self, "ShotsLeft", self.Magazine )

	self.LastThink = ct + FrameTime()
	--print( clk )
	self.Entity:NextThink( self.LastThink + clk )
	return true
end

function ENT:Touch( ent )
	if ent.HasHardpoints then
		if ent.Cont && ent.Cont:IsValid() then HPLink( ent.Cont, ent.Entity, self ) end
	end
end

function ENT:Refund()
	self.Magazine = self.Magazine + 1
	RD_SupplyResource( self, "energy", ENERGY )
end

local function RealNormal(vec)
	return vec/math.sqrt(vec[1]^2 + vec[2]^2 + vec[3]^3)
end

function ENT:Launch()
	local length = self:GetVelocity():Length()
	local aimdir, speed = self:GetForward(), 4000
	--local offset = math.floor( length / speed * length / 10 )
	--local shootpos = self:GetPos() + aimdir * ( 42 + offset )
	local offset = math.floor( length / speed * 200 )
	local shootpos = self:GetPos() + aimdir * ( 52 + offset )

	--aimdir = ( aimdir * 0.995 + VectorRand() * 0.005 ):Normalize()
	aimdir = RealNormal(( aimdir * 0.995 + VectorRand() * 0.01 ))

	local bullet = ents.Create( "autocannon_shell" )
		bullet:SetPos( shootpos )
		bullet:SetAngles( aimdir:Angle() + Angle(90,0,0) )
		bullet:Setup( self.Entity, self.Owner )
		if IsValid( self:GetParent() ) then
			bullet:SetOwner( self:GetParent() )
		else
			bullet:SetOwner( self.Entity )
		end
		bullet:Spawn()
		--bullet:SetVelocity( aimdir * ( speed + offset ) + self:GetVelocity() )
		bullet:SetVelocity( aimdir * speed )
		bullet:Activate()

	local effectdata = EffectData()
		effectdata:SetOrigin( shootpos - aimdir * 15 )
		effectdata:SetAngles( aimdir:Angle() )
		effectdata:SetScale( 2 )
	util.Effect( "MuzzleEffect", effectdata )

	self:EmitSound( "ship_weapons/wpn_autocannon.wav", math.random(325,350), math.random(5)+110 )
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
