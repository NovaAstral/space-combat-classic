--[[
	
	Developed By Dubby
		
	Copyright (c) Dubby 2010
	
]]--
ENT.RenderGroup    = RENDERGROUP_BOTH
include('shared.lua')     
local glow = StarGate.MaterialFromVMT(
	"LaserBlasterBolt",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/light_glow01"
		"$nocull" 1
		"$additive" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
)
local shaft = Material("effects/ar2ground2")

local color = Vector( 255, 80, 40 )
function ENT:Think()
	color = self.Entity:GetNetworkedVector( "color", color )
	if not color then
		color = Vector( 255, 80, 40 )
	end
end

function RealNormal(vec)
	
	return vec/math.sqrt(vec[1]^2 + vec[2]^2 + vec[3]^2)

end

function ENT:Draw()
	local size, pos, dir = math.random(25,50), self:GetPos(), RealNormal(self:GetVelocity())
	local r, g, b = color.x, color.y, color.z

	render.SetMaterial( shaft )
	render.DrawBeam( pos, pos + dir * math.random(-300,-200), 12.5, 1, 0, Color( r, g, b, 255 ) )
	render.SetMaterial( glow )
	render.DrawSprite( pos, size/2, size/2, Color( r, g, b, 255 ) )

	if r > g and r > b then
		r, g, b = r, 0, 0
	elseif g > r and g > b then
		r, g, b = 0, g, 0
	elseif b > r and b > g then
		r, g, b = 0, 0, b
	else
		r, g, b = r - 10, g + 5, b + 70
	end

	render.SetMaterial( shaft )
	render.DrawBeam( pos, pos + dir * math.random(-300,-200), 25, 1, 0, Color( r, g, b, 255 ) )
	render.SetMaterial( glow )
	render.DrawSprite( pos, size, size, Color( r, g, b, 255 ) )
end