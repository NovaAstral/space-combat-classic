ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Ion Beam Cannon"
ENT.Author			= "Zup"

ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.damagebase	= 15
ENT.energybase 	= 20 --was 25 (10x for 1 second)
ENT.coolantbase = 5 --was 10 then was 7.5  (10x for 1 second)
if (CAF and CAF.GetAddon("Resource Distribution")) then
	ENT.coolantbase = ENT.coolantbase / 2
end
ENT.HeatHP 		= 2000
ENT.HeatDamage 	= 0

ENT.energytofire = true

ENT.chargetime = CurTime()

