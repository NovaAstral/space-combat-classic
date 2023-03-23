include('shared.lua')     
//[[---------------------------------------------------------     
//Name: Draw     Purpose: Draw the model in-game.     
//Remember, the things you render first will be underneath!  
//-------------------------------------------------------]]  
	ENT.Glow = StarGate.MaterialFromVMT(
		"StaffGlow",
		[["UnLitGeneric"
		{
			"$basetexture"		"sprites/light_glow01"
			"$nocull" 1
			"$additive" 1
			"$vertexalpha" 1
			"$vertexcolor" 1
		}]]
	)
	
	ENT.Shaft = Material("effects/ar2ground2")
ENT.RenderGroup    = RENDERGROUP_BOTH
function ENT:Draw()
	local r, g, b, size = math.random(155)+100, math.random(155)+100, math.random(155)+100, math.random(150,200)
	render.SetMaterial(self.Shaft)
	render.DrawBeam(self.Entity:GetPos(),self.Entity:GetPos() + (self.Entity:GetForward() * -1000),50+math.random(25),1,0,Color(62,g,b,150))
	render.DrawBeam(self.Entity:GetPos(),self.Entity:GetPos() + (self.Entity:GetForward() * -1000),25+math.random(25),1,0,Color(r-25,0,0,255))
	render.SetMaterial(self.Glow)
	render.DrawSprite(self.Entity:GetPos(),size*(math.random(1)+1),size,Color(0,g,b,220))
	render.DrawSprite(self.Entity:GetPos(),size,size*(math.random(1)+1),Color(r,0,50,255))
	render.DrawSprite(self.Entity:GetPos(),size*3,size*3,Color(120,g,0,140))
end  
