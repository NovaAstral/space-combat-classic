TOOL.Category		= "Ship Cores"
TOOL.Name			= "#Armor Hardening"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.ClientConVar[ "sc_armor_hardener" ] = "EM"

if ( CLIENT ) then
    language.Add( "Tool.sc_armor_hardener.name", "Armor Hardener Creation Tool" )
    language.Add( "Tool.sc_armor_hardener.desc", "Spawns An Armor Hardener." )
    language.Add( "Tool.sc_armor_hardener.0", "Primary: Create/Update Armor Hardener" )
	language.Add( "sboxlimit_sc_armor_hardener", "You've hit the Armor Hardener limit!" )
	language.Add( "undone_sc_armor_hardener", "Undone Armor Hardener" )
end

if (SERVER) then
  CreateConVar('sbox_maxsc_armor_hardener',99)
end

cleanup.Register( "sc_armor_hardener" )

function TOOL:LeftClick(trace)
    local type	= self:GetClientInfo( "sc_armor_hardener" )
	Msg("Type: "..tostring(type).."\n")
    Msg("STOOL Trace hit: "..tostring(trace.Entity).."\n")
	if (!trace.HitPos) then Msg("FAIL STOOL\n") return false end
	if (trace.Entity:IsPlayer()) then Msg("FAIL STOOL2\n") return false end
	if ( CLIENT ) then Msg("FAIL STOOL3\n") return true end
	if (!trace.Entity:IsValid()) then Msg("FAIL STOOL4\n") return false end
	--if (trace.Entity:GetClass() != "prop_physics") then
	if trace.Entity:GetClass() == "sc_armor_hardener" then
		local ent =  trace.Entity
		ent:Setup(type,self:GetOwner())
		return true --Stop it from going on to stuff below and making new ent
	end

	
	local ply = self:GetOwner()
	
	if ( trace.Entity:IsValid() && string.find(trace.Entity:GetClass(), "sc_armor_hardener") && trace.Entity.pl == ply ) then
		return true
	end	

	if ( !self:GetSWEP():CheckLimit( "sc_armor_hardener" ) ) then return false end

	--local Ang = trace.Entity:GetAngles()
	--local Pos =	trace.Entity:GetPos()
	local Ang = trace.HitNormal:Angle() + Angle(90,0,0)
	local Pos = trace.HitPos + trace.HitNormal * 4
	
	Msg("\n"..tostring(trace.Entity).."\n")
	local Core = Make_sc_armor_hardener( ply, Pos, Ang, type, trace)
	
	local phys = Core:GetPhysicsObject()
	if (phys:IsValid() and trace.Entity:IsValid() ) then
		local weld = constraint.Weld(Core, trace.Entity, 0, trace.PhysicsBone, 0)
		local nocollide = constraint.NoCollide(Core, trace.Entity, 0, trace.PhysicsBone)
	end

	undo.Create("sc_armor_hardener")
		undo.AddEntity( Core )
		undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "sc_armor_hardener", Core )

	return true
	
end


function TOOL:Think()

end

list.Add( "sc_armor_hardener_Types", "Armor Hardener: EM" )
list.Add( "sc_armor_hardener_Types", "Armor Hardener: EXP" )
list.Add( "sc_armor_hardener_Types", "Armor Hardener: KIN" )
list.Add( "sc_armor_hardener_Types", "Armor Hardener: THERM" )
list.Add( "sc_armor_hardener_Types", "Energized Plating: EM" )
list.Add( "sc_armor_hardener_Types", "Energized Plating: EXP" )
list.Add( "sc_armor_hardener_Types", "Energized Plating: KIN" )
list.Add( "sc_armor_hardener_Types", "Energized Plating: THERM" )
list.Add( "sc_armor_hardener_Types", "Energized Plating: Adaptive" )
list.Add( "sc_armor_hardener_Types", "Energized Plating: Addition" )
list.Add( "sc_armor_hardener_Types", "Plating: EM" )
list.Add( "sc_armor_hardener_Types", "Plating: EXP" )
list.Add( "sc_armor_hardener_Types", "Plating: KIN" )
list.Add( "sc_armor_hardener_Types", "Plating: THERM" )
list.Add( "sc_armor_hardener_Types", "Plating: Adaptive" )
list.Add( "sc_armor_hardener_Types", "Plating: Addition" )
--list.Add( "sc_armor_hardener_Types", "JOVE" )
--list.Add( "sc_armor_hardener_Types", "POLARIS" )


function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", { Text = "#Tool_sc_armor_hardener_name", Description = "#Tool_sc_armor_hardener_desc" })
	
	local Options = list.Get( "sc_armor_hardener_Types" )
	
	local RealOptions = {}

	for k, v in pairs( Options ) do
		RealOptions[ v ] = { sc_armor_hardener_sc_armor_hardener = v }
	end
	
	CPanel:AddControl( "ListBox", { Label = "#Tool_sc_armor_hardener_name", Height = "400", Options = RealOptions} )
end
	
