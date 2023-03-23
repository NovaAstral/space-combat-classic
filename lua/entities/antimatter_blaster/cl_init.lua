include('shared.lua')     

function ENT:DrawEntityOutline( n )
	return
end

function ENT:Draw() 
	self:DrawModel()
	Wire_Render( self.Entity )
end  