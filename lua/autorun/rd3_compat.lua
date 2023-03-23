timer.Simple(1, function() --Wait to load or it will load before RD3 and fail!

function IsRD3() 
	if(CAF and CAF.GetAddon("Resource Distribution")) then
		return true
	end
	return false
end
   
if !IsRD3() then 
	Msg("\n\n".."====================================\n")
	Msg("== RD2 to RD3 Conversion INACTIVE ==\n") 
	Msg("====================================\n\n")
	return false  
end --Stop here if not RD3

--Did we load? Message
Msg("\n\n".."==================================\n")
Msg("== RD2 to RD3 Conversion ACTIVE ==\n") 
Msg("==================================\n\n")

/*---------------------------------------------------------
	Begin Converting RD2 to RD3
---------------------------------------------------------*/

local RD = CAF.GetAddon("Resource Distribution")

function Dev_Unlink_All(ent)
	RD.RemoveRDEntity(ent)	
end

function RD_AddResource(ent, resource, maximum, default)
	if resource == "air" then resource = "oxygen" end
	if resource == "coolant" then resource = "liquid nitrogen" end
	RD.AddResource(ent, resource, maximum or 0, default or 0)
end

function RD_GetResourceAmount(ent, resource)
	if resource == "air" then resource = "oxygen" end
	if resource == "coolant" then resource = "liquid nitrogen" end
 	return RD.GetResourceAmount(ent, resource) or 0
end

function RD_ConsumeResource(ent, resource, ammount)
	if resource == "air" then resource = "oxygen" end
	if resource == "coolant" then resource = "liquid nitrogen" end
	return RD.ConsumeResource(ent, resource, ammount or 0)
end

function RD_SupplyResource(ent, resource, ammount)
	if resource == "air" then resource = "oxygen" end
	if resource == "coolant" then resource = "liquid nitrogen" end
	RD.SupplyResource(ent, resource, ammount or 0)
end

function RD_GetUnitCapacity(ent, resource)
	if resource == "air" then resource = "oxygen" end
	if resource == "coolant" then resource = "liquid nitrogen" end
	return RD.GetUnitCapacity(ent, resource) or 0
end

function RD_GetNetworkCapacity(ent, resource)
	if resource == "air" then resource = "oxygen" end
	if resource == "coolant" then resource = "liquid nitrogen" end
	return RD.GetNetworkCapacity(ent, resource) or 0
end

function RD_BuildDupeInfo(ent)
	return RD.BuildDupeInfo(ent)	
end

function RD_ApplyDupeInfo(Ent, CreatedEntities)
	return RD.ApplyDupeInfo(Ent, CreatedEntities) 
end

/*---------------------------------------------------------
	RD2 Stools
---------------------------------------------------------*/

function LS_RegisterEnt(ent, name) --?
	return false
end

/*---------------------------------------------------------
	RD2 Stools - More
	I couldn't get a decent stool convert working so..
	In your RD2 stools use 	
	
	if (CLIENT and GetConVarNumber("CAF_UseTab") == 1) then 	
		TOOL.Tab = "Custom Addon Framework" 
	elseif (CLIENT and GetConVarNumber("RD_UseLSTab") == 1) then 
		TOOL.Tab = "Life Support" 	
	end
	
	and remove (normally line 1)
	
	if not ( RES_DISTRIB == 2 ) then Error("Please Install Resource Distribution 2 Addon.'" ) return end  	
	
---------------------------------------------------------*/


end) --The Timers end >_>

