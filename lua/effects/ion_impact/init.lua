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

/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )

	self.StartPos 	= data:GetStart()	
	self.EndPos 	= data:GetOrigin()
	self.Multi 		= data:GetMagnitude( )
	self.rad 		= 16
	self.MultiBeam	= data:GetScale()
	
	self.emitter = ParticleEmitter(self.EndPos)  	
	
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
    for i=0,2 do
		local a = math.random(9999)
		local b = math.random(1,180)
		local X = math.sin(b)*math.sin(a)*self.rad
		local Y = math.sin(b)*math.cos(a)*self.rad
		local Z = math.cos(b)*self.rad
		local Pos = Vector(X,Y,Z)
		local bPos = Pos+self.EndPos
		local particle = self.emitter:Add("effects/blueflare1",self.EndPos+Pos)
		if particle then
			particle:SetDieTime(0.2 * (self.Multi^0.2))
			particle:SetStartLength(0)
			particle:SetEndLength(250 * (self.Multi^0.325))
			particle:SetStartAlpha(255 * (self.Multi^0.325))
			particle:SetEndAlpha(0)
			particle:SetStartSize(32 * (self.Multi^0.325))
			particle:SetEndSize(8 * (self.Multi^0.325))
			//particle:SetGravity(((Pos+self.EndPos)-self.EndPos):Normalize())
			particle:SetColor(math.random(200,255),math.random(200,255),255)
		end  
	end 	
	self.emitter:Finish()
	return false 
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( ) 	   	
   	
   	render.SetMaterial(	bMats.Glow1 )
   	render.DrawSprite(self.EndPos, 96 * (self.Multi^0.325), 96 * (self.Multi^0.325), Color(255, 255, 255, 255))
   	
	return false
					 
end
