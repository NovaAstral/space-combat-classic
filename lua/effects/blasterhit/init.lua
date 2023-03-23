local mats = {}
mats.g1 = StarGate.MaterialFromVMT(
	"sc_blue_ball02",
	[["UnLitGeneric"
	{
		"$basetexture"		"effects/blueflare1"
		"$nocull" 1
		"$additive" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
)
mats.g2 = StarGate.MaterialFromVMT(
	"sc_blue_ball03",
	[["UnLitGeneric"
	{
		"$basetexture"		"effects/blueflare1"
		"$nocull" 1
		"$additive" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
)

function RealNormal(vec)
	return vec/math.sqrt(vec[1]^2 + vec[2]^2 + vec[3]^2)
end

function EFFECT:Init( data )

	local pos, scl, nrm, col = data:GetOrigin(), data:GetScale(), data:GetNormal(), data:GetAngles()
	
	self.Fade = 1
	self.Life = math.random(1) + scl / 2 + CurTime()
	self.Pos = pos
	self.Size = scl * 50 + 50
	self.ColorVec = { r = col.x or 0, g = col.y or 0, b = col.z or 0, a = 255 }
	self.Emitter = ParticleEmitter( pos )
	
	local n = 4 * scl + 10
	for i=1,n do
		local dir = RealNormal(( VectorRand() + nrm )) * ( scl * 500 + math.random(250) )
		local p = self.Emitter:Add( "effects/energysplash", pos )
		  p:SetVelocity( dir )
		  p:SetDieTime( ( math.random(1) + scl ) / 3 )
		  p:SetStartLength( scl * 10 + 20 )
		  p:SetEndLength( scl * 80 + 80 )
		  p:SetStartAlpha( 255 )
		  p:SetEndAlpha( 0 )
		  p:SetStartSize( scl / 2 * 10 + 10 )
		  p:SetEndSize( math.max( scl / 2, 1 ) )
		  p:SetColor( Color(col.p, col.y, col.r) )
		  //p:VelocityDecay( true )
		  p:SetCollide( true )
	end
end

function EFFECT:Think()
	local t = self.Life - CurTime()
	if t > 0 then
		self.Fade = t / 3
		return true
	else
		self.Emitter:Finish()
		return false
	end
end

function EFFECT:Render()
	render.SetMaterial( mats.g1 )
   	render.DrawSprite( self.Pos, self.Size * 2, self.Size * 2, Color( self.ColorVec.r, self.ColorVec.g, self.ColorVec.b, 255 * self.Fade ) ) 
	
	render.SetMaterial( mats.g2 )
   	render.DrawSprite( self.Pos, self.Size, self.Size, Color( self.ColorVec.r, self.ColorVec.g, self.ColorVec.b, 255 * self.Fade ) ) 
	
	return false
end
