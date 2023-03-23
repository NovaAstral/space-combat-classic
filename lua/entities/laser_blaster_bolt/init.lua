--[[

	Developed By Dubby

	Copyright (c) Dubby 2010

]]--
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

util.PrecacheSound( "sound/ship_weapons/wpn_laser_blaster_hit.wav" )

function ENT:Initialize()
	self.Entity:SetModel( "models/Items/AR2_Grenade.mdl" )
	self.Entity:SetName( "Laser Bolt" )

	self.Entity:PhysicsInit( SOLID_BBOX )
	self.Entity:SetMoveType( MOVETYPE_FLY )
	self.Entity:SetSolid( SOLID_BBOX )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )

	--self.Entity:PhysicsInitSphere(10,"metal")
	--self.Entity:SetCollisionBounds(Vector()*-5,Vector()*5)
	--self.Entity:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	--self.Entity:SetMoveType(MOVETYPE_FLY)

	self.SB_Ignore = true --make spacebuild ignore me
	self.warhead = true
	self.Untouchable = true
	self.Unconstrainable = true
	self.PhysgunDisabled = true
	self.CanTool = function( ply, trace, mode )
		return false
	end

	self.color = Vector( 255, 80, 40 )
end

function ENT:Setup( src, ply, col )
	self.launcher = src --even though we have no targeting data, we need this in order to prevent an error from happening.
	self.Owner = ply --used to tell the damage function who is hurting who/what
	self.color = col or self.color
	self:SetNetworkedVector( "color", col )
	self:Fire( "kill", "", 3.6 )
end

function ENT:Think()
	if not self.launcher then
		--illegally spawned. apply velocity in random direction
		self:SetAngles( VectorRand():Angle() )
		self:SetVelocity( self:GetForward() * 4000 ) --was 6000, that probly borke it
		self:Fire( "kill", "", 3.6 )
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
	return true
end

function ENT:StartTouch( ent )
	if IsValid( self.launcher ) and ent == self.launcher then
		// extremely bizarre error. when shells from different launchers bump into each other, they think they're bumping into the launcher - even though they are obviously not.
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


function RealNormal(vec)

	return vec/math.sqrt(vec[1]^2 + vec[2]^2 + vec[3]^2)

end

function ENT:Explode( e )
	--local pos, extra = self:GetPos(), math.random(90)+10
	local pos, extra = self:GetPos(), math.random(0,12)*10
	local damage = 120+extra -- 120-240

	--cbt_nrgexplode( pos, 50, extra, 0, self.Owner )

	if e:GetClass() == "shield" then
		--e:Hit( self, pos, (extra*4)*2, -1*self:GetForward():Normalize() )
		e:Hit( self, pos, 120+(extra*4), -1*RealNormal(self:GetForward()))  -- 160-600
	else
		e:TakeDamage(math.random(120,240),self.Owner,self)
	end

	self:EmitSound( "ship_weapons/wpn_laser_blaster_hit.wav", math.random(20)+340, math.random(30)+60 )

	local effectdata = EffectData()
		  effectdata:SetOrigin( pos ) --effect center
		  effectdata:SetScale( 1 ) --effect size
		  effectdata:SetNormal( -1 * RealNormal(self:GetVelocity()) ) --effect range
		  effectdata:SetAngles( Angle( self.color.x, self.color.y, self.color.z ) ) --effect color
	util.Effect( "BlasterHit", effectdata )

	self:Remove()
end
