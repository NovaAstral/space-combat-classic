--[[

	Developed By Dubby

	Copyright (c) Dubby 2009

]]--
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

util.PrecacheSound( "sound/ship_weapons/wpn_plasma_blaster.wav" )

function ENT:Initialize()
	self.Entity:SetModel( "models/Items/AR2_Grenade.mdl" )
	self.Entity:SetName( "Antimatter Ball" )
	self.Entity:PhysicsInit( SOLID_BBOX )
	self.Entity:SetMoveType( MOVETYPE_FLY )
	self.Entity:SetSolid( SOLID_BBOX )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )

	self.SB_Ignore = true --make spacebuild ignore me
	self.warhead = true
	self.Untouchable = true
	self.Unconstrainable = true
	self.PhysgunDisabled = true
	self.CanTool = function( ply, trace, mode )
		return false
	end

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity( true )
		phys:EnableDrag( false ) --we simulate drag ourselves, to help control movement better
		phys:EnableCollisions( true )
		phys:EnableMotion( true )
		phys:SetMass( 20 )
	end
end

function ENT:Setup( src, ply )
	self.launcher = src --even though we have no targeting data, we need this in order to prevent an error from happening.
	self.Owner = ply --used to tell the damage function who is hurting who/what
	self:Fire( "kill", "", 5 )
end

function ENT:Think()
	if not self.launcher then
		--illegally spawned. apply velocity in random direction
		self:SetAngles( VectorRand():Angle() )
		self:SetVelocity( self:GetForward() * 3333 ) --was 5000, that probly borke it
		self:Fire( "kill", "", 5 )
	end
	self.Think = function() end
	return false
end

function ENT:PassesTriggerFilters( ent )
	return true
end

function ENT:StartTouch( ent )
	if IsValid( self.launcher ) and ent == self.launcher then
		--extremely bizarre error. when shells from different launchers bump into each other, they think they're bumping into the launcher - even though they are obviously not.
		return
	else
		if(IsValid(ent)) then
			if ent:IsWorld() then
				self:Explode( self )
			else
				self:Explode( ent )
			end
		else
			self:Explode( self )
		end
	end
end

function ENT:Explode(e)
	--local pos, extra = self:GetPos(), math.random(10) * 30
	local pos, extra = self:GetPos(), math.random(0,15)*100

	local damage = 1500+extra -- 1500-3000

	--cbt_nrgexplode( pos, 250, extra/2, extra/2, self.Owner )
	local expdmg = damage/10 -- 150-300

	util.BlastDamage(self,self.Owner,pos,250,math.random(150,300))

	if (e:GetClass() == "shield") then
		e:Hit( self, pos, damage*4, -1*self.Entity:GetForward():Normalize() )
	end

	self:EmitSound( "ship_weapons/wpn_plasma_blaster.wav", 400, 25+math.random(50) )

	local effectdata = EffectData()
	effectdata:SetOrigin( pos )
	effectdata:SetStart( pos )
	effectdata:SetScale( 200 )
	util.Effect( "AntimatterSplode", effectdata )

	self:Remove()
end
