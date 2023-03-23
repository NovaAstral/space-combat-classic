local matRefraction	= Material( "refract_ring" ) 
/*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/
function EFFECT:Init( data ) 
	self.Refract = 0 
 	self.Size = 32 
	self.CScale = 1
	self.Time = 0.5
	self.LifeTime = CurTime() + self.Time 
	self.vOffset = data:GetOrigin()
	self.emitter = ParticleEmitter( self.vOffset )
	local scount = math.random(5,10)

	for i = 0, scount do
		local r, g, b, size = math.random(155)+100, math.random(155)+100, math.random(155)+100, math.random(150,200)
		local particle = self.emitter:Add( "particle/light01", self.vOffset )
		if (particle) then
			particle:SetLifeTime( 0.2+math.random() )
			particle:SetDieTime( math.Rand( 1, 3 ) )
			particle:SetStartAlpha( math.random( 25, 150 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( i*10 + size )
			particle:SetEndSize( size * 4 )
			particle:SetColor( r, g, b )
		end
	end

	self.emitter:Finish()

	--self.Entity:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	--self.Entity:SetAlpha( 0 )
 	--self.Entity:SetMaterial("models/alyx/emptool_glow")
 	self.Entity:SetPos( self.vOffset )  
	self.Entity:SetRenderMode(RENDERMODE_WORLDGLOW)
end

/*--------------------------------------------------------- 
    THINK 
    Returning false makes the entity die 
 ---------------------------------------------------------*/ 
function EFFECT:Think( ) 

 	self.Entity:SetColor(100,100,200,100)
	self.CScale = self.CScale + 0.1

 	self.Refract = self.Refract + 2.0 * FrameTime() 
 	self.Size = 256 * self.Refract^(0.2) 

 	if ( self.Refract >= 200 ) then return false end 

 	self.Entity:NextThink( CurTime() )
 	return ( self.LifeTime > CurTime() )  

end 

/*--------------------------------------------------------- 
    Draw the effect 
 ---------------------------------------------------------*/
function EFFECT:Render()
 	local Distance = EyePos():Distance( self.Entity:GetPos() ) 
 	local Pos = self.Entity:GetPos() + (EyePos()-self.Entity:GetPos()):GetNormal() * Distance * (self.Refract^(0.3)) * 0.8 
   
 	matRefraction:SetFloat( "$refractamount", math.sin( self.Refract * math.pi ) * 0.1 ) 
 	render.SetMaterial( matRefraction ) 
 	render.UpdateRefractTexture() 
 	render.DrawSprite( Pos, self.Size, self.Size )
 	
 	--local v = self.CScale * 10
	--self.Entity:SetModelWorldScale( Vector(v,v,v) )
	--self:DrawModel()
end