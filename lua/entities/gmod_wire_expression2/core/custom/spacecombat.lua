/*
	Space Combat E2 functions
*/

E2Lib.RegisterExtension("spacecombat", false)
local function ValidateCore(entity)
	if IsValid(entity) then
		-- print(string.match(entity:GetClass(), "ship_core_", 0))
		if string.match(entity:GetClass(), "ship_core_", 0)=="ship_core_" then
			return true
		else
			return false
		end
	end
end

__e2setcost(5)

e2function string entity:getCoreName()
	if ValidateCore(this) then
		return this:GetNWString("WireName", this.PrintName)
	else
		return ""
	end
end

e2function string entity:getCoreType()
	if ValidateCore(this) then
		return this.PrintName
	else
		return ""
	end
end

e2function number entity:getCoreHull()
	if ValidateCore(this) then
		return this.Hull.HP
	else
		return 0
	end
end

e2function number entity:getCoreMaxHull()
	if ValidateCore(this) then
		return this.Hull.Max
	else
		return 0
	end
end

e2function number entity:getCoreArmor()
	if ValidateCore(this) then
		return this.Armor.HP
	else
		return 0
	end
end

e2function number entity:getCoreMaxArmor()
	if ValidateCore(this) then
		return this.Armor.Max
	else
		return 0
	end
end

e2function number entity:getCoreShield()
	if ValidateCore(this) then
		return this.Shield.HP
	else
		return 0
	end
end

e2function number entity:getCoreMaxShield()
	if ValidateCore(this) then
		return this.Shield.Max
	else
		return 0
	end
end

e2function number entity:getCoreCap()
	if ValidateCore(this) then
		return this.Cap.CAP
	else
		return 0 
	end
end

e2function number entity:getCoreMaxCap()
	if ValidateCore(this) then
		return this.Cap.Max
	else
		return 0
	end
end