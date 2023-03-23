--[[

	Developed By Dubby

	Copyright (c) Dubby 2010

]]--
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

util.PrecacheSound( "sound/ship_weapons/wpn_plasma_blaster_hit.wav" )

function ENT:Initialize()
	self.Entity:SetModel( "models/Items/AR2_Grenade.mdl" )
	self.Entity:SetName( "Laser Bolt" )
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

	self.color = Vector(100,100,100)
end

function ENT:Setup( src, ply, col )
	self.launcher = src --even though we have no targeting data, we need this in order to prevent an error from happening.
	self.Owner = ply --used to tell the damage function who is hurting who/what
	if not col or col == Vector(100,100,100) then
		col = Vector( 100, 255, 80 )
	end
	self:SetNetworkedVector( "color", col )
	self:Fire( "kill", "", 3.4 ) --effective range of 10,000 units
	self.color = col
end



function ENT:Think()
	if not self.launcher then
		--illegally spawned. apply velocity in random direction
		self:SetAngles( VectorRand():Angle() )
		self:SetVelocity( self:GetForward() * 4000 )
		self:Fire( "kill", "", 3.4 )
	end
	self.Think = function()
		self:SetNetworkedVector( "color", self.color )
		self.Entity:NextThink( CurTime() + 1 )
		return true
	end
	self.Entity:NextThink( CurTime() )
	return true
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

function RealNormal(vec)

	return vec/math.sqrt(vec[1]^2 + vec[2]^2 + vec[3]^2)

end


function ENT:Explode( e )
	--local pos, extra = self:GetPos(), (math.random(75)+125)*2 --was math.random(75)+125
	local pos, extra = self:GetPos(), math.random(0,10)*30
	local damage = 300+extra -- 300-600

	--cbt_nrgexplode( pos, 50, extra, 5, self.Owner )
	--cbt_hcgexplode( pos, 90, extra, 0, self.Owner )
	local expdmg = 150+(extra/2)
	SC_Explode(pos, 100, {EM=0,EXP=expdmg*0.2,KIN=0,THERM=expdmg*0.8}, self.Owner, self )

	if e:GetClass() == "shield" then
		--e:Hit( self, pos, extra*12, -1*self:GetForward():Normalize() ) --Was *6
		e:Hit( self, pos, damage*4, -1*RealNormal(self:GetForward()) )
	else
		--cbt_dealnrghit( e, 300+extra, 25, e:GetPos(), pos, self.Owner ) --was 150+extra
		SC_ApplyDamage(e, {EM=0,EXP=0,KIN=damage*0.4,THERM=damage*0.6}, self.Owner, self, self:GetPos())
	end

	self:EmitSound( "ship_weapons/wpn_plasma_blaster_hit.wav", math.random(20)+340, math.random(10)+90 )

	local effectdata = EffectData()
		  effectdata:SetOrigin( pos ) --effect center
		  effectdata:SetScale( 3 ) --effect size
		  local tr = util.TraceLine( { start = pos, endpos = pos + self:GetVelocity(), filter = self } )
		  effectdata:SetStart( RealNormal(tr.HitNormal) ) --shockwave ring
		  effectdata:SetNormal( -1 * RealNormal(self:GetVelocity()) ) --effect range
		  effectdata:SetAngles( Angle( self.color.x, self.color.y, self.color.z ) ) --effect color
	util.Effect( "BlasterHit", effectdata )

	self:Remove()
end
