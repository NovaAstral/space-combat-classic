--[[
	
	Developed By Dubby
		
	Copyright (c) Dubby 2010
	
]]--

ENT.RenderGroup    = RENDERGROUP_BOTH

include('shared.lua')     
local beam = {}
	beam.fx1 = StarGate.MaterialFromVMT(
	"PhaserBeam_1",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/orangecore1"
		"$nocull" 1
		"$additive" 1
		"$translucent" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
	)
	beam.fx2 = StarGate.MaterialFromVMT(
	"PhaserBeam_2",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/orangecore2"
		"$nocull" 1
		"$additive" 1
		"$translucent" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
	)
	beam.fx3 = StarGate.MaterialFromVMT(
	"PhaserBeam_3",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/physbeam"
		"$nocull" 1
		"$additive" 1
		"$translucent" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
	)
	beam.fx4 = StarGate.MaterialFromVMT(
	"PhaserBeam_4",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/redglow1"
		"$nocull" 1
		"$additive" 1
		"$translucent" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
	)

function ENT:Draw()
--	self.Entity:DrawModel()
	
	if not self.life then 
		self.life = self:GetNetworkedFloat( "life", 5 ) --for some reason this ticks differently here
		self.maxlife = self.life
		self.decays_at = self:GetNetworkedFloat( "decays_at", 1 )
		self.stretch_time = self:GetNetworkedFloat( "stretch_time", 1 )
		self.width = self:GetNetworkedFloat( "width", 25 ) / 2
		self.power = self:GetNetworkedFloat( "power", 3 )
		self.dir_last = self:GetForward()
		self.dir_next = self:GetForward()
	end
	
	local color = self:GetNetworkedVector( "color", Vector( 50, 100, 300 ) )
	local r, g, b = color.x/2, color.y/2, color.z/2
	
	if not self.decaying and self:GetNetworkedBool( "decaying", false ) then
		self.decaying = true
		self.life = math.min( self.decays_at, self.life )
		self.decays_at = self.life
	end
	
	if self.life > 0 then
		
		local range = self:GetNetworkedFloat( "range", 0 )
		local center = self:GetPos() + self:OBBCenter()

		if self.life > ( self.maxlife - self.stretch_time ) then
			range = range * ( 1 - ( self.life - ( self.maxlife - self.stretch_time ) ) )
		end
		
		local forward, right, up = self:GetForward(), self:GetRight(), self:GetUp()
		
		if self.life > self.decays_at then
			for i=1,range,100 do
				render.SetMaterial( beam[ "fx"..tostring(math.random(1,4)) ] )
				local alpha = 50 + math.random(100)
				local startpos = math.Rand( self.width * -1, self.width ) / self.power * up + math.Rand( self.width * -1, self.width ) / self.power * right + center
				local endpos = startpos + range * forward
				local size = ( math.random( self.power ) * self.power + 25 ) * ( i / range ) * 4
				if startpos.x > endpos.x and startpos.y > endpos.y and startpos.z > endpos.z then
					self:SetRenderBoundsWS( endpos, startpos )
				else
					self:SetRenderBoundsWS( startpos, endpos )
				end
				render.DrawBeam( startpos + ( range - i ) * forward, endpos, size, 1, 0, Color( r * math.Rand( 0.8, 1 ), g * math.Rand( 0.8, 1 ), b * math.Rand( 0.8, 1 ), alpha * math.Rand( 0.8, 1 ) ) )
			end
		else
			local n = ( 1 - self.life / self.decays_at ) * range

			for i=n,range,100 do
				render.SetMaterial( beam[ "fx"..tostring(math.random(3,4)) ] )
				local alpha = math.min( 50 + math.random(100) * self.life, 255 )
				local startpos = math.Rand( self.width * -1, self.width ) / self.power * up + math.Rand( self.width * -1, self.width ) / self.power * right + i * forward + center
				local endpos = startpos + ( range - i ) * forward
				if startpos.x > endpos.x and startpos.y > endpos.y and startpos.z > endpos.z then
					self:SetRenderBoundsWS( endpos, startpos )
				else
					self:SetRenderBoundsWS( startpos, endpos )
				end
				local size = ( math.random(self.power) * self.power + 15 ) / self.life * 4
				render.DrawBeam( startpos, endpos, size, 1, 0, Color( r * math.Rand( 0.3 + self.life, 1 ), g * math.Rand( 0.3 + self.life, 1 ), b * math.Rand( 0.3 + self.life, 1 ), alpha ) )
				--render.SetMaterial( beam[ "fx"..tostring(math.random(2,4)) ] )
				--render.DrawSprite( ( startpos + endpos ) / 2, size, size, Color( self.color.r, self.color.g, self.color.b, 150 ) )
			end
		end
		
		for i=1,4 do
			render.SetMaterial( beam[ "fx"..tostring(math.random(1,2)) ] )
			render.DrawSprite( center, math.random(100), math.random(100), Color( r, g, b, math.random(100,200) ) )
		end
		
		render.SetMaterial( Material( "trails/plasma" ) )
		render.DrawBeam( center, center + range * forward, 50, 1, 0, Color( r, g, b, 150 ) )

		self.lastrange = self.range
		self.life = self.life - FrameTime() / 1.88
	end
end
