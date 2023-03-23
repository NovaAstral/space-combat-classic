EFFECT.Material2 = StarGate.MaterialCopy("ShieldGlow","models/roller/rollermine_glow")
function EFFECT:Init(data)
self.HitPos =	data:GetOrigin()
self.StartPos = data:GetStart()
self.Scale =	data:GetMagnitude()
self.Ent =		data:GetEntity()
self.TimeLeft = CurTime() + 3
self.Fade = 1
self.LastPos = self.Ent:GetPos()
end

function EFFECT:Think()
self:SetParent(self.Ent)
 local timeleft = self.TimeLeft - CurTime()
	if timeleft > 0 then 
		local ftime = FrameTime()
		self.Fade = (timeleft / 3)
		
		return true
	else
		return false	
	end
		return false	
end
	
	
function EFFECT:Render()
	if self.Ent and self.Ent:IsValid() then
		local HitPos = self.HitPos
		local StartPos = self.StartPos
		local normal = (StartPos - HitPos):Angle():Forward()
		local DeltaP = self.LastPos - self.Ent:GetPos()
		render.SetMaterial(self.Material2)
		render.DrawQuadEasy((HitPos + (StartPos - HitPos):Angle():Forward() * 100) - DeltaP , normal,500 * self.Fade,500 * self.Fade,Color( 100,100,255,255 * self.Fade ))
		render.DrawQuadEasy((HitPos + (StartPos - HitPos):Angle():Forward() * 100) - DeltaP , -1*normal,500 * self.Fade,500 * self.Fade,Color( 100,100,255,255 * self.Fade ))
	end
end


