TOOL.Category		= "Ship Cores"
TOOL.Name			= "#Shield Repair"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.ClientConVar[ "sc_shield_repair" ] = "EM"

if ( CLIENT ) then
    language.Add( "Tool.sc_shield_repair.name", "Shield Booster Creation Tool" )
    language.Add( "Tool.sc_shield_repair.desc", "Spawns A Shield Booster." )
    language.Add( "Tool.sc_shield_repair.0", "Primary: Create/Update Shield Booster" )
	language.Add( "sboxlimit_sc_Shield_repair", "You've hit the Shield Booster limit!" )
	language.Add( "undone_sc_shield_repair", "Undone Shield Booster" )
end

if (SERVER) then
  CreateConVar('sbox_maxsc_shield_repair',99)
end

cleanup.Register( "sc_Shield_repair" )

function TOOL:LeftClick(trace)
    local type	= self:GetClientInfo( "sc_Shield_repair" )
	Msg("Type: "..tostring(type).."\n")
    Msg("STOOL Trace hit: "..tostring(trace.Entity).."\n")
	if (!trace.HitPos) then Msg("FAIL STOOL\n") return false end
	if (trace.Entity:IsPlayer()) then Msg("FAIL STOOL2\n") return false end
	if ( CLIENT ) then Msg("FAIL STOOL3\n") return true end
	if (!trace.Entity:IsValid()) then Msg("FAIL STOOL4\n") return false end
	--if (trace.Entity:GetClass() != "prop_physics") then
	if trace.Entity:GetClass() == "sc_shield_repair" then
		local ent =  trace.Entity
		ent:Setup(type,self:GetOwner())
		return true --Stop it from going on to stuff below and making new ent
	end

	
	local ply = self:GetOwner()
	
	if ( trace.Entity:IsValid() && string.find(trace.Entity:GetClass(), "sc_shield_repair") && trace.Entity.pl == ply ) then
		return true
	end	

	if ( !self:GetSWEP():CheckLimit( "sc_shield_repair" ) ) then return false end

	--local Ang = trace.Entity:GetAngles()
	--local Pos =	trace.Entity:GetPos()
	local Ang = trace.HitNormal:Angle() + Angle(90,0,0)
	local Pos = trace.HitPos + trace.HitNormal * 4
	
	Msg("\n"..tostring(trace.Entity).."\n")
	local Core = Make_sc_shield_repair( ply, Pos, Ang, type, trace)
	
	local phys = Core:GetPhysicsObject()
	if (phys:IsValid() and trace.Entity:IsValid() ) then
		local weld = constraint.Weld(Core, trace.Entity, 0, trace.PhysicsBone, 0)
		local nocollide = constraint.NoCollide(Core, trace.Entity, 0, trace.PhysicsBone)
	end

	undo.Create("sc_shield_repair")
		undo.AddEntity( Core )
		undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "sc_shield_repair", Core )

	return true
	
end


function TOOL:Think()

end

list.Add( "sc_Shield_repair_Types", "Civilian Shield Booster" )
list.Add( "sc_Shield_repair_Types", "Micro Shield Booster" )
list.Add( "sc_Shield_repair_Types", "Small Shield Booster" )
list.Add( "sc_Shield_repair_Types", "Medium Shield Booster" )
list.Add( "sc_Shield_repair_Types", "Large Shield Booster" )
list.Add( "sc_Shield_repair_Types", "Capital Shield Booster" )

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", { Text = "#Tool_sc_shield_repair_name", Description = "#Tool_sc_Shield_repair_desc" })
	
	local Options = list.Get( "sc_Shield_repair_Types" )
	
	local RealOptions = {}

	for k, v in pairs( Options ) do
		RealOptions[ v ] = { sc_Shield_repair_sc_Shield_repair = v }
	end
	
	CPanel:AddControl( "ListBox", { Label = "#Tool_sc_shield_repair_name", Height = "400", Options = RealOptions} )
end
	
