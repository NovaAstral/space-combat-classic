TOOL.Category		= "Ship Cores"
TOOL.Name			= "#Energy Upgrades"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.ClientConVar[ "sc_energy_upgrade" ] = "EM"

if ( CLIENT ) then
    language.Add( "Tool.sc_energy_upgrade.name", "Energy Upgrade Creation Tool" )
    language.Add( "Tool.sc_energy_upgrade.desc", "Spawns An Energy Upgrade." )
    language.Add( "Tool.sc_energy_upgrade.0", "Primary: Create/Update Energy Upgrade" )
	language.Add( "sboxlimit_sc_energy_upgrade", "You've hit the Energy Upgrade limit!" )
	language.Add( "undone_sc_energy_upgrade", "Undone Energy Upgrade" )
end

if (SERVER) then
  CreateConVar('sbox_maxsc_energy_upgrade',99)
end

cleanup.Register( "sc_energy_upgrade" )

function TOOL:LeftClick(trace)
    local type	= self:GetClientInfo( "sc_energy_upgrade" )
	Msg("Type: "..tostring(type).."\n")
    Msg("STOOL Trace hit: "..tostring(trace.Entity).."\n")
	if (!trace.HitPos) then Msg("FAIL STOOL\n") return false end
	if (trace.Entity:IsPlayer()) then Msg("FAIL STOOL2\n") return false end
	if ( CLIENT ) then Msg("FAIL STOOL3\n") return true end
	if (!trace.Entity:IsValid()) then Msg("FAIL STOOL4\n") return false end
	--if (trace.Entity:GetClass() != "prop_physics") then
	if trace.Entity:GetClass() == "sc_energy_upgrade" then
		local ent =  trace.Entity
		ent:Setup(type,self:GetOwner())
		return true --Stop it from going on to stuff below and making new ent
	end

	
	local ply = self:GetOwner()
	
	if ( trace.Entity:IsValid() && string.find(trace.Entity:GetClass(), "sc_energy_upgrade") && trace.Entity.pl == ply ) then
		return true
	end	

	if ( !self:GetSWEP():CheckLimit( "sc_energy_upgrade" ) ) then return false end

	--local Ang = trace.Entity:GetAngles()
	--local Pos =	trace.Entity:GetPos()
	local Ang = trace.HitNormal:Angle() + Angle(90,0,0)
	local Pos = trace.HitPos + trace.HitNormal * 4
	
	Msg("\n"..tostring(trace.Entity).."\n")
	local Core = Make_sc_energy_upgrade( ply, Pos, Ang, type, trace)
	
	local phys = Core:GetPhysicsObject()
	if (phys:IsValid() and trace.Entity:IsValid() ) then
		local weld = constraint.Weld(Core, trace.Entity, 0, trace.PhysicsBone, 0)
		local nocollide = constraint.NoCollide(Core, trace.Entity, 0, trace.PhysicsBone)
	end

	undo.Create("sc_energy_upgrade")
		undo.AddEntity( Core )
		undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "sc_energy_upgrade", Core )

	return true
	
end


function TOOL:Think()

end

list.Add( "sc_energy_upgrade_Types", "Cap Recharger" )
list.Add( "sc_energy_upgrade_Types", "Micro Cap Battery" )
list.Add( "sc_energy_upgrade_Types", "Small Cap Battery" )
list.Add( "sc_energy_upgrade_Types", "Medium Cap Battery" )
list.Add( "sc_energy_upgrade_Types", "Large Cap Battery" )
list.Add( "sc_energy_upgrade_Types", "Cap Power Relay" )
list.Add( "sc_energy_upgrade_Types", "Cap Flux Coil" )
list.Add( "sc_energy_upgrade_Types", "Power Diagnostic" )
list.Add( "sc_energy_upgrade_Types", "Shield Recharger" )
list.Add( "sc_energy_upgrade_Types", "Shield Power Relay" )
list.Add( "sc_energy_upgrade_Types", "Shield Flux Coil" )
list.Add( "sc_energy_upgrade_Types", "Co-Processor" )
list.Add( "sc_energy_upgrade_Types", "Reactor Control" )

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", { Text = "#Tool_sc_energy_upgrade_name", Description = "#Tool_sc_energy_upgrade_desc" })
	
	local Options = list.Get( "sc_energy_upgrade_Types" )
	
	local RealOptions = {}

	for k, v in pairs( Options ) do
		RealOptions[ v ] = { sc_energy_upgrade_sc_energy_upgrade = v }
	end
	
	CPanel:AddControl( "ListBox", { Label = "#Tool_sc_energy_upgrade_name", Height = "400", Options = RealOptions} )
end
	
