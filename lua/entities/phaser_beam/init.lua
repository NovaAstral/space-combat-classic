--[[

	Developed By Dubby

	Copyright (c) Dubby 2010

	*Not complete.
]]--
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

util.PrecacheSound( "sound/ship_weapons/wpn_plasma_blaster_hit.wav" )

function ENT:Initialize()
	self.Entity:SetModel( "models/dav0r/hoverball.mdl" )
	self.Entity:SetName( "Phaser Beam" )
	self.Entity:PhysicsInit( SOLID_BBOX )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_NONE )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableCollisions( false )
		phys:EnableMotion( true )
		phys:EnableDrag( false )
		phys:EnableGravity( false )
		phys:SetMass( 1 )
	end

	self.SC_Immune = true --make weapons ignore me
	self.SB_Ignore = true --make spacebuild ignore me
	self.warhead = false --
	self.Untouchable = true
	self.PhysgunDisabled = true
	self.CanTool = function( ply, trace, mode )
		return false
	end

	// encase someone spawns this from a box or the console, we make sure the below values already exist! otherwise we'll probably wig out and cause problems.
	self.range = 5000
	self.reach = 0
	self.lifespan = 3
	self.lifeleft = self.lifespan
	self.lastlife = self.lifespan
	self.decays_at = 0.5
	self.stretch_time = 1
	self.width = 25
	self.density = 1
	self.max_hits_per_second = 3
	self.damage_per_second = 1000
	self.color = Vector( 50, 100, 300 )
	self.power = 2
	self.victims = {}
end

function ENT:Setup( src, ply, data, color )
	self.launcher = src
	self.Owner = ply
	table.Merge( self.Entity:GetTable(), data )
	self.lifeleft = data.lifespan
	self.lastlife = data.lifespan
	self.color = color
	constraint.Ballsocket( self.launcher, self.Entity, 0, 0, self:OBBCenter(), 0, 0, 1 )
	self.Unconstrainable = true --if this was in initialize, we wouldnt of been able to make a ballsocket.

	self:SetNetworkedVector( "color", Vector( self.color.x, self.color.y, self.color.z ) )
	self:SetNetworkedFloat( "power", self.power )
	self:SetNetworkedFloat( "width", self.width )
	self:SetNetworkedFloat( "range", self.reach )
	self:SetNetworkedFloat( "decays_at", self.decays_at )
	self:SetNetworkedFloat( "stretch_time", self.stretch_time )
	self:SetNetworkedFloat( "life", self.lifeleft )
end

function ENT:GetLifeStats() --launcher asks the beam how it's doing when consuming resources
	return self.lifeleft, self.lastlife, self.lifespan
end

function RealNormal(vec)

	return vec/math.sqrt(vec[1]^2 + vec[2]^2 + vec[3]^2)

end

function ENT:GetPointingDirection()
	if IsValid( self.launcher ) then
		local prevdir, newdir = self:GetForward(), self.launcher:GetForward() * -1
		local b, val = self.launcher:GetTargetData()
		if b then --entity
			newdir = self:GetTargetVector( val )
		elseif b == false then --vector
			newdir = RealNormal( val - self:GetPos() - self:OBBCenter() )
		--else --nil
			// don't need to do anything.
		end

		--newdir = ( prevdir * 0.874 + newdir * 0.120 + VectorRand() * 0.006 ):Normalize()
		newdir = RealNormal( prevdir * 0.874 + newdir * 0.120 + VectorRand() * 0.018 )

		return newdir
	else
		return self:GetForward()
	end
end

function ENT:UpdateDirection( dir )
	self:SetAngles( dir:Angle() ) --this tells the client what direction to render the beam.

	local reach = math.max( 1 - math.max( self.lifeleft - ( self.lifespan - self.stretch_time ), 0 ), 0.05 ) * ( self.range - 25 ) + 25
	local offset = math.min( ( 1 - math.min( self.lifeleft / self.decays_at, 1 ) ) * self.range, reach )
	local pos, x, y = self:GetPos() + self:OBBCenter() + dir * offset, self:GetRight(), self:GetUp()
	local hit, hits, locs, loc = 0, 0, vector_origin, vector_origin

	for i=1,self.density do
		local vec = ( math.cos( i ) * self.width / 2 ) * x + ( math.sin( i ) * self.width / 2 ) * y + pos
		hit, loc = self:BeamTrace( StarGate.Trace:New( pos, dir * reach, self.Entity ) )
		hits = hits + hit
		locs = locs + loc
	end

	if hits > self.density / 2 then
		self.reach = ( locs / hits ):Distance( self:GetPos() + self:OBBCenter() )
	else
		self.reach = reach
	end

	self:SetNetworkedFloat( "range", self.reach )
end

function ENT:StartBeamDecay()
	self:SetNetworkedBool( "decaying", true )
	self.decaying = true
	self:Fire( "kill", "", self.decays_at )
end

function ENT:Think()
	local ct, clk = CurTime(), 0.05

	if not self.decaying and self.lifeleft <= self.decays_at then
		self:StartBeamDecay()
		return false
	end

	local dir = self:GetPointingDirection()

	if not self:ValidDirection( dir ) then
		print( "oh noes" )
		self:StartBeamDecay()
		return false
	end

	self:UpdateDirection( dir )

	local time = FrameTime() + clk
	self.lastlife = self.lifeleft
	self.lifeleft = self.lifeleft - time
	self.Entity:NextThink( ct + time )
	return true
end

function ENT:BeamTrace( tr )
	if not tr.Hit then return 0, vector_origin end

	local scale = self.power

	if tr.HitNonWorld then
		if IsValid( tr.Entity ) and tr.Entity ~= self.launcher then
			local hit = tr.Entity
			local mult = 1
			/*
			if ValidEntity( hit.SC_CoreEnt ) then
				hit = hit.SC_CoreEnt
				mult = 0.1
			end
			*/
			local ct, id = CurTime(), hit:EntIndex()

			--limit how frequently this object can be damaged by me
			if self.victims[ id ] == nil or ct > self.victims[ id ] then
				self.victims[ id ] = ct + 1 / self.max_hits_per_second
				local dmg = self.damage_per_second / self.max_hits_per_second

				dmg = math.Round( dmg*(1-(((tr.HitPos - tr.StartPos):Length()/self.range)^2)) ) --Lets stop overpowered sniping

				local multi = 1
				if hit.SC_CoreEnt and hit.SC_CoreEnt.sigrad then
					multi = math.Clamp( ((hit.SC_CoreEnt.sigrad/39.3700787)/72) ,0.2,1)
				end


				if hit:GetClass() == "shield" then
					dmg = dmg * scale
					hit:Hit( self.Entity, tr.StartPos, math.random( dmg / 2, dmg ), tr.HitNormal )
					scale = scale / 2
				else
					dmg = dmg*multi
					--cbt_dealdevhit( hit, math.random( dmg / 2, dmg )*multi, 0, tr.HitPos, tr.StartPos, self.Owner )
					SC_ApplyDamage(hit, {EM=dmg*0.6,EXP=0,KIN=0,THERM=dmg*0.4}, self.Owner, self, self:GetPos())
				end
			end

			if IsValid( hit:GetParent() ) then hit = hit:GetParent() end
			local vel = RealNormal( tr.HitNormal * 0.25 + RealNormal( tr.HitPos - tr.StartPos ) * 0.75 ) * math.pow( 8, scale )
			local phys = tr.Entity:GetPhysicsObject()
			/*
			if phys:IsValid() then
				phys:Wake() --necessary?
				phys:ApplyForceOffset( hit:GetVelocity() + ( vel * phys:GetMass() / 4 ) * mult*0.25, tr.HitPos - hit:GetPos() )
			else
				tr.Entity:SetVelocity( hit:GetVelocity() + vel * mult )
			end
			*/
		end
	end

	if math.floor( CurTime() * 10 ) % 3 == 0 then
		local effectdata = EffectData()
			effectdata:SetOrigin( tr.HitPos )
			effectdata:SetScale( scale )
			effectdata:SetStart( tr.HitNormal )
			effectdata:SetNormal( tr.HitNormal )
			effectdata:SetAngles( Angle( self.color.x, self.color.y, self.color.z ) ) --effect color
		util.Effect( "plasmasplash", effectdata )
		if tr.HitNonWorld then
			tr.Entity:EmitSound( "ship_weapons/wpn_plasma_blaster_hit.wav", math.random(20)+350, math.random(5)+20 )
		end
	end

	return 1, tr.HitPos
end

function ENT:ValidDirection( dir ) --used to make sure we are not out of [angular] bounds with our launcher
	if IsValid( self.launcher ) then
		return math.deg( math.acos( ( self.launcher:GetForward() * -1 ):DotProduct( dir ) ) ) < 88
	else
		return true
	end
end

function ENT:GetTargetVector( target ) --calculate target leading for our rotation
	local shootpos = self:GetPos() + self:OBBCenter()
	local tvel, tpos = target:GetVelocity() + target:GetVelocity() / target:GetPhysicsObject():GetMass(), ( target:GetPos() + target:OBBCenter() + target:NearestPoint(shootpos) ) / 2 --+ target:OBBCenter()
	local distance = shootpos:Distance( tpos + tvel )
	local aimdir = RealNormal( ( distance / self.range * tvel + tpos ) - shootpos )
	return aimdir
	--( self:GetTargetVector() * 0.976 + VectorRand() * 0.024 ):Normalize()
end

function ENT:OnRemove() --let our launcher know we've died
	if IsValid( self.launcher ) then
		self.launcher:SetNextFire()
	end
end
