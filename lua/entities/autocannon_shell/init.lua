--[[

	Developed By Dubby

	Copyright (c) Dubby 2009

]]--
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

util.PrecacheSound( "sound/ship_weapons/wpn_autocannon_hit.wav" )

function ENT:Initialize()
	self.Entity:SetModel( "models/combatmodels/tankshell_40mm.mdl" )
	self.Entity:SetName( "50mm Shell" )
	self.Entity:PhysicsInit( SOLID_BBOX )
	self.Entity:SetMoveType( MOVETYPE_FLY )
	self.Entity:SetSolid( SOLID_BBOX )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )

	self.SC_Immune = true --make weapons ignore me
	self.SB_Ignore = true --make spacebuild ignore me
	self.warhead = true
	self.Untouchable = true
	self.Unconstrainable = true
	self.PhysgunDisabled = true
	self.CanTool = function( ply, trace, mode )
		return false
	end
end

function ENT:Setup( src, ply )
	self.launcher = src --even though we have no targeting data, we need this in order to prevent an error from happening.
	self.Owner = ply --used to tell the damage function who is hurting who/what
	self:Fire( "kill", "", 6 )
end

function ENT:Think()
	if not self.launcher then
		--illegally spawned. apply velocity in random direction
		self:SetAngles( VectorRand():Angle() )
		self:SetVelocity( self:GetForward() * 4000 )
		self:Fire( "kill", "", 6 )
	end
	self.Think = function() end
	return false
end

function ENT:PassesTriggerFilters( ent )
	if IsValid( self.launcher ) then
		local core = self.launcher.SC_CoreEnt
		if IsValid( core ) then
			if core == ent.SC_CoreEnt then
				return false
			end
		end
	end
	return true
end

function ENT:PhysicsCollide()
end

function ENT:Touch()
end

function ENT:StartTouch( ent )
	if IsValid( self.launcher ) and ent == self.launcher then
		// extremely bizarre error. when shells from different launchers bump into each other, they think they're bumping into the launcher - even though they are obviously not.
		return
	else
		if IsValid( ent ) and ((ent.SC_CoreEnt != self.launcher.SC_CoreEnt) or (self.launcher.SC_CoreEnt == nil)) then
			if ent:IsWorld() then
				self:Explode( self )
			else
				self:Explode( ent )
			end
		elseif (ent.SC_CoreEnt != self.launcher.SC_CoreEnt) or (self.launcher.SC_CoreEnt == nil) then
			self:Explode( self )
		end
	end
end

function ENT:OnTakeDamage()
end

function ENT:EndTouch()
end

local function RealNormal(vec)
	return vec/math.sqrt(vec[1]^2 + vec[2]^2 + vec[3]^2)
end

function ENT:Explode( e )
	--local pos, extra = self:GetPos(), math.random(15,75)*2 -- was 15,75
	local pos, extra = self:GetPos(), math.random(0,20)*5

	util.BlastDamage(self,self.Owner,pos,72,math.random(25,50))

	if e:GetClass() == "shield" then
		--e:Hit( self, pos, 150+extra*2, -1*self:GetForward():Normalize() )
		e:Hit( self, pos, damage*2, RealNormal(-1*self:GetForward()) )
	end

	self:EmitSound( "ship_weapons/wpn_autocannon_hit.wav", math.random(20)+320, math.random(30)+60 )

	local effectdata = EffectData()
		  effectdata:SetOrigin( pos )
		  effectdata:SetStart( pos )
	util.Effect( "TinyWhomphSplode", effectdata )

	self:Remove()
end
