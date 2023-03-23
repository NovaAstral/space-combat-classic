--[[
	
	Developed By Dubby
		
	Copyright (c) Dubby 2010
	
]]--
ENT.RenderGroup    = RENDERGROUP_BOTH
include('shared.lua')
glow = StarGate.MaterialFromVMT(
	"laser_blaster_ball01",
	[["UnLitGeneric"
	{
		"$basetexture"		"effects/blueflare1"
		"$nocull" 1
		"$additive" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
)
beam = StarGate.MaterialFromVMT(
	"laser_blaster_beam01",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/laserbeam"
		"$nocull" 1
		"$additive" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
)

function ENT:DrawEntityOutline( n )
	return
end

local color = Vector( 255, 80, 40 )
function ENT:Think()
	color = self:GetNetworkedVector( "color", color )
	if not color or color == Vector( 100, 100, 100 ) then
		color = Vector( 255, 80, 40 )
	end
end

function ENT:Draw() 
	local a, p, u, s, m = self:GetAngles(), self:GetPos(), self:GetUp(), math.random(5), self:GetMaterial()
	local r, g, b = color.x, color.y, color.z

	self:SetModelScale( 0.8, 0 )
	self:SetModel( "models/Slyfo/powercrystal.mdl" )
	self:SetMaterial( "" )
	self:SetPos( p + u * -5 )
	self:DrawModel()
	
	self:SetModelScale( 0.5 , 0)
	self:SetModel( "models/Slyfo_2/mortarsys_incen.mdl" )
	self:SetMaterial( "" )
	self:SetPos( p + u * -9 )
	self:DrawModel()
	
	self:SetModelScale(  1, 0 )
	self:SetModel( "models/Slyfo_2/rocketpod_bigrocket.mdl" )
	self:SetMaterial( m )
	self:SetPos( p )
	self:DrawModel()
	
	render.SetMaterial( glow )
   	render.DrawSprite( p + u * 2, 10+s, 10+s, Color( r, g, b, 255 ) ) 
	render.DrawSprite( p + u * 2, 5, 5, Color( r, g, b, 255 ) ) 
	
	Wire_Render( self.Entity )
end  
