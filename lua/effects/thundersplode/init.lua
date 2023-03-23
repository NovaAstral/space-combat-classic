local matRefraction	= Material( "refract_ring" ) 

local tbolt2 = StarGate.MaterialFromVMT(
	"MjolnirThunderBolt-2",
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
	self.life = 1
	self.maxlife = self.life
	self.start = data:GetOrigin()
	self.entpos = data:GetStart()
	self.normal = data:GetNormal()
	self.width = data:GetMagnitude()
	self.size = data:GetScale()
	local color = data:GetAngle()
	self.color = {}
		self.color.r = color.p
		self.color.g = math.max( color.y - 80, 0 )
		self.color.b = math.max( color.r / 2 - 40 ) // math.max( color.r - 80, 0 )

	self.refract = 0 
	self.dietime = CurTime() + self.life
	self.emitter = ParticleEmitter( self.start )
	local scount = math.random(5,10)

	for i = 0, scount do
		local particle = self.emitter:Add( "sprites/light_glow02", self.start )
		if (particle) then
			particle:SetLifeTime( 0.2+math.random() )
			particle:SetDieTime( math.Rand( 1, 3 ) )
			particle:SetStartAlpha( math.random( 25, 150 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( i*10 + math.random(50,100) )
			particle:SetEndSize( self.size * 4 )
			particle:SetColor( self.color.r, self.color.g, self.color.b )
		end
	end

	self.emitter:Finish()

 	self.Entity:SetPos( self.start )  
end

function EFFECT:Think( ) 
	if self.life <= 0 then
		return false
	end
	self.life = self.life - FrameTime()

	self.refract = self.refract + 2.0 * FrameTime() 
 	self.resize = 128 * self.refract^(0.2) 

	return true
end 

function EFFECT:Render()
	local count = math.floor( self.width )

	for i=1,count do

		local points = 4
		local dir = self.normal
		local nrm = VectorRand()
		local increment = self.size

		local alpha = math.random( 50, 100 ) + ( 100 * self.life ) --math.min( ( self.life * math.random(1) * 2 ) / self.maxlife * 255, 255 )

		render.SetMaterial( tbolt2 )
		
		render.StartBeam( points + 2 )

		render.AddBeam( self.start, 15, 0, Color( self.color.r, self.color.g, self.color.b, alpha ) )

		local pos = self.start
		for i=1,points do
			dir = ( dir + nrm ):Normalize() 
			pos = ( dir + VectorRand() ):Normalize() * ( increment / i + 1 ) + pos
			local tcoord = ( 1 / points ) * i
			render.AddBeam( pos, 15, tcoord / 1, Color( self.color.r, self.color.g, self.color.b, alpha ) )
		end

		render.AddBeam( dir * increment + self.start, 15, 1, Color( self.color.r, self.color.g, self.color.b, alpha ) )

		render.EndBeam()

	end

	matRefraction:SetMaterialFloat( "$refractamount", math.sin( self.refract * math.pi ) * 0.1 ) 
 	render.SetMaterial( matRefraction ) 
 	render.UpdateRefractTexture() 
 	render.DrawSprite( self.start + ( EyePos() - self.start ):GetNormal() * EyePos():Distance( self.start ) * ( self.refract ^ ( 0.3 ) ) * 0.8 , self.resize, self.resize )

end


	/*
	local pos = self.start
	local count = math.floor( self.width * 30 )
	for i=1,count do
		local points = 8
		local dir = ( self.normal * 0.25 + VectorRand() * 0.75 ):Normalize()
		local pos = self.start
		local endpos = self.start + dir * math.random( self.size / 2, self.size * 2 )
		local nrm = ( endpos - self.start ):GetNormal()
		local increment = ( endpos - self.start ):Length() / 3
		local alpha = math.random(15)*10 * self.life
		render.SetMaterial( bolt1 )
		render.StartBeam( points + 2 )
		render.AddBeam( self.start, self.width, 0, Color( self.color.r, self.color.g, self.color.b, alpha ) )
		for i=1,points do
			dir = ( dir + nrm ):Normalize() 
			pos = ( dir + VectorRand() ):Normalize() * ( increment / i + 1 ) + pos
			local tcoord = ( 1 / points ) * i
			render.AddBeam( pos, self.width, tcoord / 1, Color( self.color.r, self.color.g, self.color.b, alpha ) )
		end
		render.AddBeam( endpos, self.width, 1, Color( self.color.r, self.color.g, self.color.b, alpha ) )
		render.EndBeam()
	end
	
	
end*/