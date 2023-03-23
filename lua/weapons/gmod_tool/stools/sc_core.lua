TOOL.Category		= "Ship Cores"
TOOL.Name			= "#Ship Cores"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.ClientConVar[ "core" ] = "Civilian Core"

if ( CLIENT ) then
    language.Add( "Tool.sc_core.name", "Ship Core Creation Tool" )
    language.Add( "Tool.sc_core.desc", "Turns a prop into a Ship Core." )
    language.Add( "Tool.sc_core.0", "Primary: Create/Update Ship Core" )
	language.Add( "sboxlimit_sc_core", "You've hit the Ship Core limit!" )
	language.Add( "undone_sc_core", "Undone Ship Core" )
end

if (SERVER) then
  CreateConVar('sbox_maxsc_core',3)
end

cleanup.Register( "sc_core" )

function TOOL:LeftClick(trace)
    local type	= self:GetClientInfo( "core" )
	Msg("Type: "..tostring(type).."\n")
    Msg("STOOL Trace hit: "..tostring(trace.Entity).."\n")
	if (!trace.HitPos) then Msg("FAIL STOOL\n") return false end
	if (trace.Entity:IsPlayer()) then Msg("FAIL STOOL2\n") return false end
	if ( CLIENT ) then Msg("FAIL STOOL3\n") return true end
	if (!trace.Entity:IsValid()) then Msg("FAIL STOOL4\n") return false end
	if (trace.Entity:GetClass() != "prop_physics") then Msg("FAIL STOOL5\n") return false end
	
	local ply = self:GetOwner()
	
	if ( trace.Entity:IsValid() && string.find(trace.Entity:GetClass(), "ship_core") && trace.Entity.pl == ply ) then
		return true
	end	

	if ( !self:GetSWEP():CheckLimit( "sc_core" ) ) then return false end

	local Ang = trace.Entity:GetAngles()
	local Pos =	trace.Entity:GetPos()
	local Mdl =	trace.Entity:GetModel()
	
	Msg("\n"..tostring(trace.Entity).."\n")
	local Core = MakeSCCore( ply, Pos, Ang, Mdl, type)
	trace.Entity:Remove()

	undo.Create("sc_core")
		undo.AddEntity( Core )
		undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "sc_core", Core )

	return true
	
end

if SERVER then

	function MakeSCCore(pl, Pos, Ang, Mdl, type)
		if ( !pl:CheckLimit( "sc_core" ) ) then return nil end
		
		local Core = ents.Create("ship_core_base")

		if type == "Amarr Core" then
  			Core = ents.Create("ship_core_amarr")
  			--Core = ents.Create("ship_core_base_wtf")
		elseif type == "Caldari Core" then
		    Core = ents.Create("ship_core_caldari")
		    --Core = ents.Create("ship_core_base_wtf")
		elseif type == "Gallente Core" then
		    Core = ents.Create("ship_core_gallente")
		    --Core = ents.Create("ship_core_base_wtf")
		elseif type == "Minmatar Core" then
		    Core = ents.Create("ship_core_minmatar")
		elseif type == "Jovian Core" then
		    Core = ents.Create("ship_core_base")
		elseif type == "Civilian Core" then
		    Core = ents.Create("ship_core_civilian")
		elseif type == "Asgard Core" then
		    Core = ents.Create("ship_core_asgard")
		else
		    Core = ents.Create("ship_core_base")
		end
		
		Core:SetPos(Pos)
		Core:SetAngles(Ang)
		Core:SetModel(Mdl)
		Core:Spawn()
		Core:Activate()
		
		Core.ConWeldTable = {}
		Core.Owner = pl

		pl:AddCount( "sc_core", Core )
		
		return Core
	end

	--duplicator.RegisterEntityClass("ship_core_base_wtf", MakeSCCore, "Pos", "Ang", "Mdl","type")

end

function TOOL:Think()



end

list.Add( "SC_Core_Types", "Amarr Core" )
list.Add( "SC_Core_Types", "Caldari Core" )
list.Add( "SC_Core_Types", "Gallente Core" )
list.Add( "SC_Core_Types", "Minmatar Core" )
list.Add( "SC_Core_Types", "Civilian Core" )
--list.Add( "SC_Core_Types", "Asgard Core" )

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", { Text = "#Tool_sc_core_name", Description = "#Tool_sc_core_desc" })
	
	local Options = list.Get( "SC_Core_Types" )
	
	local RealOptions = {}

	for k, v in pairs( Options ) do
		RealOptions[ v ] = { SC_Core_core = v }
	end
	
	CPanel:AddControl( "ListBox", { Label = "#Tool_sc_core_name", Height = "100", Options = RealOptions} )
end
	
