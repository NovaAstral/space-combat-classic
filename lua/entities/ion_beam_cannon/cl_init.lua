include('shared.lua')
 	
function ENT:Think()

	local drawbeam = self:GetNWBool("drawbeam")
	local charging = self:GetNWBool("charging")
	local hit_eh = self:GetNWBool("hit_eh")
	local imp_eh = self:GetNWBool("imp_eh")
	local ent = self:GetNWEntity("ent_eh")
	local multi = self:GetNWFloat( "multiplier")
	local muzzel = self:GetPos() + (self:GetForward() * 147.5) + (self:GetUp() * 9.25) 
	
	if charging == true then
   		local effectdata = EffectData()
			effectdata:SetOrigin(muzzel)
			effectdata:SetMagnitude(multi)
			util.Effect( "ion_charge", effectdata )  	
   	end 	
	if drawbeam == true then
	
		local trace = {}
				trace.start = self:GetPos() + (self:GetForward() * 147.5) + (self:GetUp() * 9.25)
				trace.endpos = self:GetPos() + self.Entity:GetForward() * 100000
				trace.filter = self.Entity
			 
		local tr = nil 
				
		if StarGate.Installed then
				tr = StarGate.Trace:New(trace.start, self:GetForward() * 100000, trace.filter)
		else
				tr = util.TraceLine( trace )
		end
		 
		local dist = (tr.HitPos - trace.start):Length()        
		local effectdata = EffectData()
				effectdata:SetOrigin(tr.HitPos)
				effectdata:SetStart(trace.start)
				effectdata:SetMagnitude(multi)
				effectdata:SetScale(dist)
				util.Effect( "ion_beam", effectdata )
		if imp_eh == false then 			
				util.Effect( "ion_impact", effectdata )		
		end
   	end

	if hit_eh == true then
		local trace = {}
    		trace.start = ent:OBBCenter() + ent:GetPos()
			trace.endpos = ent:GetForward() * 100000
			trace.filter = {ent:GetParent(), ent}

		local tr = StarGate.Trace:New(trace.start, trace.endpos, trace.filter)

		local dist = (tr.HitPos - trace.start):Length()
		local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)
			effectdata:SetStart(trace.start)
			effectdata:SetMagnitude(multi)
			effectdata:SetScale(dist)
			util.Effect( "ion_beam", effectdata )			
			util.Effect( "ion_impact", effectdata )
   	end
end

function ENT:Draw() 
	self.Entity:DrawModel() 
end
