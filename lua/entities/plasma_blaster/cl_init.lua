--[[
	
	Developed By Dubby
		
	Copyright (c) Dubby 2010
	
]]--
include('shared.lua')
glow = StarGate.MaterialFromVMT(
	"plasma_blaster_ball01",
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
	"plasma_blaster_beam01",
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


function ENT:Think()
	color = self.Entity:GetNetworkedVector( "color", color )
	if not color or color == Vector( 100, 100, 100 ) then
		color = Vector( 255, 80, 40 )
	end
end

function ENT:Draw() 
	local a, p, f, m = self:GetAngles(), self:GetPos(), self:GetForward(), self:GetMaterial()
	--local color = self:GetNetworkedAngle( "glow" )
	local r, g, b = color.x, color.y, color.z

	self:SetModelScale( 2 , 0 )
	self:SetModel( "models/Slyfo/searchlight.mdl" )
	self:SetMaterial( "" )
	self:SetPos( p )
	self:DrawModel()
	
	self:SetModelScale(  2.35 , 0 )
	self:SetModel( "models/XQM/cylinderx1.mdl" )
	self:SetMaterial( "spacebuild/fusion3" )
	self:SetPos( p + f * -3 )
	self:DrawModel()
	
	self:SetModelScale( 1 , 0 )
	self:SetModel( "models/Slyfo/sat_rtankengine.mdl" )
	self:SetMaterial( m )
	self:SetPos( p + f * -2 )
	self:DrawModel()

	self:SetPos( p )
	Wire_Render( self.Entity )
end  
