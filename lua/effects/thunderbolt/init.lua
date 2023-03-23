local tbolt1 = StarGate.MaterialFromVMT(
	"MjolnirThunderBolt-1",
	[["UnLitGeneric"
	{
		"$basetexture"		"effects/tool_tracer"
		"$nocull" 1
		"$additive" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
)

function EFFECT:Init( data )
	self.life = 0.2 + math.Rand(0,0.2)
	self.maxlife = self.life
	self.start = data:GetOrigin()
	self.endpos = data:GetStart()
	self.normal = data:GetNormal()
	self.width = data:GetMagnitude() * 2
	local color = data:GetAngle()
	self.color = {}
		self.color.r = color.p
		self.color.g = math.max( color.y - 80, 0 )
		self.color.b = math.max( color.r / 2 - 40 ) // math.max( color.r - 80, 0 )
end

function EFFECT:Think()
	if self.life <= 0 then
		return false
	end
	self.life = self.life - FrameTime()
	return true
end

function EFFECT:Render()
	local points = 8
	local dir, nrm = self.normal, ( self.endpos - self.start ):GetNormal()
	local increment = ( self.endpos - self.start ):Length() / 2
	
	local alpha = math.min( math.random( 50 ) + ( 100 * self.life ) + 100, 255 ) --math.min( ( self.life * math.random(1) * 2 ) / self.maxlife * 255, 255 )
	
	render.SetMaterial( tbolt1 )
	
	render.StartBeam( points + 2 )
	
	render.AddBeam( self.start, self.width, 0, Color( self.color.r, self.color.g, self.color.b, alpha ) )
	
	local pos = self.start
	for i=1,points do
		dir = ( dir + nrm ):Normalize() 
		pos = ( dir + VectorRand() ):Normalize() * ( increment / i + 1 ) + pos
		local tcoord = ( 1 / points ) * i
		render.AddBeam( pos, self.width, tcoord / 1, Color( self.color.r, self.color.g, self.color.b, alpha ) )
	end
	
	render.AddBeam( self.endpos, self.width, 1, Color( self.color.r, self.color.g, self.color.b, alpha ) )
	
	render.EndBeam()
	
	--shock sparks/etc. at end position
end
