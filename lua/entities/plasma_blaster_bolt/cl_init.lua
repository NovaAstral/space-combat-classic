--[[
	
	Developed By Dubby
		
	Copyright (c) Dubby 2010
	
]]--
ENT.RenderGroup    = RENDERGROUP_BOTH
include('shared.lua')     
local glow1 = StarGate.MaterialFromVMT(
	"PlasmaBlasterBolt_Tail",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/orangecore1"
		"$nocull" 1
		"$additive" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
)
local glow2 = StarGate.MaterialFromVMT(
	"PlasmaBlasterBolt_Glow",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/orangecore2"
		"$nocull" 1
		"$additive" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
)
local glow3 = StarGate.MaterialFromVMT(
	"PlasmaBlasterBolt_Flicker1",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/physbeam"
		"$nocull" 1
		"$additive" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
)
local glow4 = StarGate.MaterialFromVMT(
	"PlasmaBlasterBolt_Flicker2",
	[["UnLitGeneric"
	{
		"$basetexture"		"particles/fire_glow"
		"$nocull" 1
		"$additive" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
)

local color = Vector( 100, 255, 80 )
function ENT:Think()
	color = self.Entity:GetNetworkedVector( "color", color )
	if not color or color == Vector( 100, 100, 100 ) then
		color = Vector( 100, 255, 80 )
	end
end

function RealNormal(vec)
	
	return vec/math.sqrt(vec[1]^2 + vec[2]^2 + vec[3]^2)

end
function ENT:Draw()
	local size, pos, dir = math.random(25,50), self:GetPos(), RealNormal(self:GetVelocity())
	local r, g, b = color.x, color.y, color.z

	--render.SetMaterial( glow4 )
	--render.DrawSprite( pos + dir * 10, size*2, size*2, Color( r, g, b, 150+math.random(75) ) )
	render.SetMaterial( glow1 )
	render.DrawBeam( pos + dir * 80, pos + dir * math.random(-300,-250), 10+math.random(5), 1, 0, Color( r/3, g/3, b/3, 50+math.random(200) ) )
	render.DrawBeam( pos + dir * 70, pos + dir * math.random(-200,-150), 20+math.random(5), 1, 0, Color( r/2, g/2, b/2, 100+math.random(150) ) )
	render.DrawBeam( pos + dir * 60, pos + dir * math.random(-150,-25), 30+math.random(5), 1, 0, Color( r, g, b, 150+math.random(100) ) )
		
	if r > g and r > b then
		r, g, b = r, 0, 0
	elseif g > r and g > b then
		r, g, b = 0, g, 0
	elseif b > r and b > g then
		r, g, b = 0, 0, b
	else
		r, g, b = r - 10, g + 5, b + 70
	end

	render.SetMaterial( glow3 )
	render.DrawBeam( pos, pos + dir * math.random(-250,-225), 5+math.random(5), 1, 0, Color( r, g, b, 50+math.random(50) ) )
	render.DrawBeam( pos, pos + dir * math.random(-225,-150), 15+math.random(5), 1, 0, Color( r, g, b, 75+math.random(75) ) )
	render.DrawBeam( pos, pos + dir * math.random(-150,-75), 25+math.random(5), 1, 0, Color( r, g, b, 100+math.random(100) ) )
	render.DrawBeam( pos, pos + dir * math.random(-75,-25), 40+math.random(10), 1, 0, Color( r, g, b, 125+math.random(125) ) )
	render.DrawBeam( pos, pos + dir * math.random(-50,0), 70+math.random(10), 1, 0, Color( r, g, b, 150+math.random(100) ) )
	
	render.SetMaterial( glow2 )
	render.DrawSprite( pos + dir * 5, size*(math.random(1)+1), size*(math.random(1)+1), Color( r, g, b, 150 ) )
	
	
end