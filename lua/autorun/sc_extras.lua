if !CLIENT then AddCSLuaFile( "autorun/SC_extras.lua" ) end --Load client side
function SC_DigiSpace(num)

    if not num or num == nil then num = 0 end
    
    local dspac = "0"
			
	while num >= 1000 do 
	
		local remainder = math.Round((num/1000 - math.floor(num/1000))*1000)
		if remainder == 0 then remainder = "000" 
		elseif remainder < 100 and remainder > 10 then remainder = "0"..remainder
		elseif remainder < 10 and remainder > 0 then remainder = "00"..remainder end
		
		num = math.floor(num/1000)
		
		if dspac == "0" then		 
			dspac = remainder
		else
			dspac = remainder..","..dspac 
		end	
	end	
	
	if num > 0 then
		if dspac == "0" then dspac = math.Round(num) --The number was to small to go through the loop
		else dspac = math.Round(num)..","..dspac end
	end

	return dspac

end

function sc_ds(num)
	return SC_DigiSpace(num)
end