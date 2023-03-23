local bMats = {}
bMats.Glow1 = StarGate.MaterialFromVMT(
	"sc_blue_ball01",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/physcannon_bluecore2b"
		"$nocull" 1
		"$additive" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
)

bMats.Glow2 = StarGate.MaterialFromVMT(
	"sc_blue_ball02",
	[["UnLitGeneric"
	{
		"$basetexture"		"effects/bluemuzzle"
		"$nocull" 1
		"$additive" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
)

local lMats = {}
lMats.Glow1 = StarGate.MaterialFromVMT(
	"sc_blue_beam01",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/bluelight1"
		"$nocull" 1
		"$additive" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
)

lMats.Glow2 = StarGate.MaterialFromVMT(
	"sc_blue_beam02",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/physbeam"
		"$nocull" 1
		"$additive" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
)

/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )

	self.StartPos 	= data:GetStart()	
	self.EndPos 	= data:GetOrigin()
	self.Multi 		= data:GetMagnitude( )
	self.rad 		= 16
	self.MultiBeam	= data:GetScale()
	
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos )
	
	self.emitter = ParticleEmitter(self.EndPos)  	
	
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
    	return false 
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )
	
	render.SetMaterial( Material(  "effects/blueblacklargebeam"  ) )
   	render.DrawBeam( self.StartPos, self.EndPos, 64, 0, 0, Color( 255, 255, 255, 255 ) )
   	
   	render.SetMaterial( bMats.Glow2 )
   	render.DrawSprite(self.StartPos, 144, 144, Color(255, 255, 255, 255)) 
   	
	render.SetMaterial( lMats.Glow1 )		
   	render.DrawBeam( self.EndPos, self.StartPos, 128, (1)*((2*CurTime())-(0.0005*self.MultiBeam)), (1)*(2*CurTime()), Color( 255, 255, 255, 255 ) )
   	
	render.SetMaterial( lMats.Glow2 )	
   	render.DrawBeam( self.EndPos, self.StartPos, 96, (1)*((2*CurTime())-(0.001*self.MultiBeam)), (1)*(2*CurTime()), Color( 255, 255, 255, 255 ) )
   	
	return false
					 
end
