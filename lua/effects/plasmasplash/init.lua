local glow1 = StarGate.MaterialFromVMT(
	"PlasmaHitFlare",
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

	local pos, dir, nrm, col = data:GetOrigin(), data:GetNormal(), data:GetStart(), data:GetAngles()
	
	self.Fade = 1
	self.Life = math.Rand(1,2) + CurTime()
	self.Pos = pos
	self.ColorVec = { r = col.x or 0, g = col.y or 0, b = col.z or 0, a = 255 }
	self.Emitter = ParticleEmitter( pos )
	
	local n = 20+math.random(10)
	for i=1,n do
		local vec = RealNormal(( VectorRand() * 0.30 + nrm * 0.50 + dir * 0.20 ))
		local p = self.Emitter:Add( "particle/light01", pos + dir * -35 )
		  p:SetVelocity( vec * ( 15 + math.random(5) ) )
		  p:SetDieTime( math.Rand(0.6,1.8) )
		  p:SetStartLength( 40+math.random(30) )
		  p:SetEndLength( 200+math.random(150) )
		  p:SetStartAlpha( 255 )
		  p:SetEndAlpha( 0 )
		  p:SetStartSize( 20+math.random(5) )
		  p:SetEndSize( 140+math.random(80) )
		  p:SetColor( Color(col.p, col.y, col.r) )
		  //p:VelocityDecay( true )
	end
	// I can't get this stupid wave to align itself with the surface normal (nrm) no matter what I seem to try. So, disabling it for now. ~Dubby
	--print( nrm )
	/*for i=1,36 do
		--nrm:Rotate( Angle( 0, 10, 0 ) )
		--print( nrm )
		local p, a, b = self.Emitter:Add( "effects/hyperspace3", pos + dir * 20 ), 10+math.random(5), 150+math.random(20)
		  p:SetAngles( nrm:Angle() + Angle( 90, i*10-190, 0 ) )
		  p:SetVelocity( p:GetAngles():Right() * 80 )
		  print( p:GetAngles():Right() )
		  p:SetDieTime( math.Rand(1.25,2.50) )
		  p:SetStartLength( a )
		  p:SetEndLength( b )
		  p:SetStartAlpha( 255 )
		  p:SetEndAlpha( 1 )
		  p:SetStartSize( a )
		  p:SetEndSize( b )
		  p:SetColor( col.p, col.y, col.r )
		  p:VelocityDecay( false )
		  p:SetCollide( true )
	end*/
end

function EFFECT:Think()
	local t = self.Life - CurTime()
	if t > 0 then
		self.Fade = t / 3
		//self.Emitter:Finish()
		return true
	else
		self.Emitter:Finish()
		return false
	end
end

function EFFECT:Render()
	render.SetMaterial( glow1 )
	local a, b, c = 1+math.random(7), math.Rand(0.75,1), math.random(4)
   	render.DrawSprite( self.Pos, 50 * a, 50 * a, Color( self.ColorVec.r, self.ColorVec.g, self.ColorVec.b, 200 * self.Fade ) ) 
   	render.DrawSprite( self.Pos, 200 * b, 200 * b, Color( self.ColorVec.r, self.ColorVec.g, self.ColorVec.b, 255 * self.Fade ) ) 
	render.DrawSprite( self.Pos, 150 * b, 150 * b, Color( self.ColorVec.r, self.ColorVec.g, self.ColorVec.b, 255 * math.random(1) ) ) 
	render.DrawSprite( self.Pos, 100 * c, 100 * c, Color( self.ColorVec.r, self.ColorVec.g, self.ColorVec.b, 200 * self.Fade ) ) 
	return false
end
