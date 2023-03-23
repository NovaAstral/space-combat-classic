--[[
	
	Developed By Dubby
		
	Copyright (c) Dubby 2010
	
]]--
include('shared.lua')
ENT.RenderGroup    = RENDERGROUP_OPAQUE

function ENT:DrawEntityOutline( n )
	return
end


function ENT:Think()

end

/*function RealAngNormal(ang)
	
	ang = ang % 360
	ang = (ang + 360) % 360
	return ang

end*/

function ENT:DrawModels()
	local a, p, f, m, d = self:GetAngles(), self:GetPos(), self:GetForward(), self:GetMaterial(), self:GetModel()
	
	self:SetModelScale( 0.75 , 0  )
	self:SetModel( "models/Slyfo/goldfish.mdl" )
	self:SetPos( p + f * -30 )
	self:SetAngles( Angle( a.p * -1, a.y + 180, a.r * -1 ) )
	self:DrawModel()
	self:SetAngles( Angle( a.p * -1, a.y + 180, a.r * -1 + 180 ) )
	self:SetModelScale( 0.75, 0 )
	self:DrawModel()
	
	self:SetAngles( a )
	self:SetPos( p + f * -15 ) 
	self:SetModel( "models/XQM/cylinderx1.mdl" )
	self:SetMaterial( "spacebuild/fusion2" )
	self:SetModelScale( 3.7 , 0)
	self:DrawModel()
	
	self:SetAngles( a + Angle( 0, 0, (CurTime() % 360) * 100 ))
	self:SetPos( p + f * 13 )
	self:SetMaterial( m )
	self:SetModel( "models/Slyfo/searchlight.mdl" )
	self:SetMaterial( "" )
	self:SetModelScale( 1.5, 0 ) 
	self:DrawModel()
	
	self:SetModelScale( 1,0 )
	self:SetModel( d )
	self:SetMaterial( m )
	self:SetAngles( a )
	self:SetPos( p + f * -2 )
	self:DrawModel()
	
	self:SetPos( p )
	return
end
	
/*	
	self:SetModel( "models/XQM/cylinderx1.mdl" )
	self:SetMaterial( "spacebuild/fusion2" )
	self:SetModelScale( Vector( 1, 2.9, 2.9 ) )
	self:SetPos( p + f * -15 )
	self:DrawModel()

	self:SetAngles( a + Angle( 0, 0, CurTime() * 50 ) )
	self:SetModelScale( Vector( 0.6, 1.4, 1.4 ) )
	self:SetModel( "models/Slyfo/sat_grappler.mdl" )
	self:SetMaterial( m )
	self:SetPos( p + f * -2 )
	self:DrawModel()

	self:SetAngles( a )
	self:SetModelScale( Vector( 1, 3.6, 3.6 ) )
	self:SetModel( "models/XQM/cylinderx1.mdl" )
	self:SetMaterial( "spacebuild/fusion2" )
	self:DrawModel()
	
	self:SetPos( p + f * -14 )
	self:SetModel( "models/Slyfo/goldfish.mdl" )
	self:SetMaterial( m )
		self:SetAngles( Angle( a.p * -1, a.y + 180, a.r * -1 ) )
		self:SetModelScale( Vector( 0.5, 0.75, 0.75 ) )
			self:DrawModel()
		self:SetAngles( Angle( a.p * -1, a.y + 180, a.r * -1 + 180 ) )
		self:SetModelScale( Vector( 0.5, 0.75, 0.75 ) )
			self:DrawModel()
	
	self:SetAngles( a + Angle( 0, 0, 180 ) )
	self:SetModelScale( Vector( 2, 1, 1 ) )
	self:SetModel( "models/Slyfo/sat_rtankengine.mdl" )
	self:SetPos( p )
	self:DrawModel()
	
	self:SetAngles( a )
	self:SetModelScale( Vector( 2, 1, 1 ) )
	self:SetModel( "models/Slyfo/sat_rtankengine.mdl" )
	self:DrawModel()
	return
	
end
*/
function ENT:Draw() 
	self:DrawModels()
	Wire_Render( self.Entity )
end