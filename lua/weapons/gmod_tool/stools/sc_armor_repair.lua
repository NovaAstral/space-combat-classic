TOOL.Category		= "Ship Cores"
TOOL.Name			= "#Armor Repair"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.ClientConVar[ "sc_armor_repair" ] = "EM"

if ( CLIENT ) then
    language.Add( "Tool.sc_armor_repair.name", "Armor Repair Creation Tool" )
    language.Add( "Tool.sc_armor_repair.desc", "Spawns An Armor Repair." )
    language.Add( "Tool.sc_armor_repair.0", "Primary: Create/Update Armor Repair" )
	language.Add( "sboxlimit_sc_armor_repair", "You've hit the Armor Repair limit!" )
	language.Add( "undone_sc_armor_repair", "Undone Armor Repair" )
end

if (SERVER) then
  CreateConVar('sbox_maxsc_armor_repair',99)
end

cleanup.Register( "sc_armor_repair" )

function TOOL:LeftClick(trace)
    local type	= self:GetClientInfo( "sc_armor_repair" )
	Msg("Type: "..tostring(type).."\n")
    Msg("STOOL Trace hit: "..tostring(trace.Entity).."\n")
	if (!trace.HitPos) then Msg("FAIL STOOL\n") return false end
	if (trace.Entity:IsPlayer()) then Msg("FAIL STOOL2\n") return false end
	if ( CLIENT ) then Msg("FAIL STOOL3\n") return true end
	if (!trace.Entity:IsValid()) then Msg("FAIL STOOL4\n") return false end
	--if (trace.Entity:GetClass() != "prop_physics") then
	if trace.Entity:GetClass() == "sc_armor_repair" then
		local ent =  trace.Entity
		ent:Setup(type,self:GetOwner())
		return true --Stop it from going on to stuff below and making new ent
	end

	
	local ply = self:GetOwner()
	
	if ( trace.Entity:IsValid() && string.find(trace.Entity:GetClass(), "sc_armor_repair") && trace.Entity.pl == ply ) then
		return true
	end	

	if ( !self:GetSWEP():CheckLimit( "sc_armor_repair" ) ) then return false end

	--local Ang = trace.Entity:GetAngles()
	--local Pos =	trace.Entity:GetPos()
	local Ang = trace.HitNormal:Angle() + Angle(90,0,0)
	local Pos = trace.HitPos + trace.HitNormal * 4
	
	Msg("\n"..tostring(trace.Entity).."\n")
	local Core = Make_sc_armor_repair( ply, Pos, Ang, type, trace)
	
	local phys = Core:GetPhysicsObject()
	if (phys:IsValid() and trace.Entity:IsValid() ) then
		local weld = constraint.Weld(Core, trace.Entity, 0, trace.PhysicsBone, 0)
		local nocollide = constraint.NoCollide(Core, trace.Entity, 0, trace.PhysicsBone)
	end

	undo.Create("sc_armor_repair")
		undo.AddEntity( Core )
		undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "sc_armor_repair", Core )

	return true
	
end


function TOOL:Think()

end

list.Add( "sc_armor_repair_Types", "Civilian Armor Repair" )
list.Add( "sc_armor_repair_Types", "Micro Armor Repair" )
list.Add( "sc_armor_repair_Types", "Small Armor Repair" )
list.Add( "sc_armor_repair_Types", "Medium Armor Repair" )
list.Add( "sc_armor_repair_Types", "Large Armor Repair" )
list.Add( "sc_armor_repair_Types", "Capital Armor Repair" )

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", { Text = "#Tool_sc_armor_repair_name", Description = "#Tool_sc_armor_repair_desc" })
	
	local Options = list.Get( "sc_armor_repair_Types" )
	
	local RealOptions = {}

	for k, v in pairs( Options ) do
		RealOptions[ v ] = { sc_armor_repair_sc_armor_repair = v }
	end
	
	CPanel:AddControl( "ListBox", { Label = "#Tool_sc_armor_repair_name", Height = "400", Options = RealOptions} )
end
	
