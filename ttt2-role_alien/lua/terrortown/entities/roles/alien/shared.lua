if SERVER then
	AddCSLuaFile()
end

roles.InitCustomTeam(ROLE.name, {
	icon = "vgui/ttt/dynamic/roles/icon_alien",
	color = Color(129, 144, 162, 255)
})

function ROLE:PreInitialize()
    self.color                      = Color(129, 144, 162, 255)

    self.abbr                       = "alien"
    self.surviveBonus               = 3
    self.score.killsMultiplier      = 2
    self.score.teamKillsMultiplier  = -8
    self.preventFindCredits         = true
    self.preventKillCredits         = true
    self.preventTraitorAloneCredits = true
    self.preventWin                 = true -- Can he win on his own? true means NO, false means YES
    self.unknownTeam                = false
    self.isPublicRole               = true -- Can everyone see his role? true means YES, false means NO

    self.defaultTeam                = TEAM_ALIEN

    self.conVarData = {
        pct          = 0.15, -- necessary: percentage of getting this role selected (per player)
        maximum      = 1, -- maximum amount of roles in a round
        minPlayers   = 7, -- minimum amount of players until this role is able to get selected
        togglable    = true, -- option to toggle a role for a client if possible (F1 menu)
        random       = 33
    }
end

if SERVER then
    -- HANDLE WINNING HOOK
	hook.Add("TTTCheckForWin", "AlienCheckWin", function()
		if roles.ALIEN.shouldWin then
			roles.ALIEN.shouldWin = false
			return TEAM_ALIEN
		end
	end)
	
	-- Give Loadout on respawn and rolechange
	function ROLE:GiveRoleLoadout(ply, isRoleChange)
        -- save original player model
		self.alienOriginalModel = ply:GetModel()
        -- give new alien model
		ply:SetModel( "models/player/howardalien.mdl" )
        -- give alien probe
        ply:GiveEquipmentWeapon( "weapon_ttt2_alien_probe" )
	end

	-- Remove Loadout on death and rolechange
	function ROLE:RemoveRoleLoadout(ply, isRoleChange)
        -- give original model back
		ply:SetModel( self.alienOriginalModel )
        -- strip alien probe
        ply:StripWeapon( "weapon_ttt2_alien_probe" )
	end
end


-- adding convars to the TTT2 menu
if CLIENT then
    function ROLE:AddToSettingsMenu(parent)
        local form = vgui.CreateTTT2Form(parent, "header_roles_additional")
		
        form:MakeSlider({
            serverConvar = "ttt2_alien_probed_players_win_threshold",
            label = "label_alien_probed_players_win_threshold",
            min = 2,
            max = 16,
            decimal = 0,
        })

		form:MakeSlider({
            serverConvar = "ttt2_alien_probe_healing",
            label = "label_alien_probe_healing",
            min = 1,
            max = 100,
            decimal = 0,
        })
    end
end

-- alien deals no damage to other players
hook.Add("PlayerTakeDamage", "AlienNoDamage", function(ply, inflictor, killer, amount, dmginfo)
    if not inflictor:IsPlayer() then return end
    if inflictor:GetSubRole() ~= ROLE_ALIEN then return end
	dmginfo:ScaleDamage(0)
	dmginfo:SetDamage(0)
end)

-- actual wallhacks part DONT TOUCH!!!!!!!!!
if CLIENT then
	local TryT = LANG.TryTranslation
	local ParT = LANG.GetParamTranslation

	local materialAlien = Material("vgui/ttt/dynamic/roles/icon_alien")

	hook.Add("TTT2RenderMarkerVisionInfo", "HUDDrawMarkerVisionAlienTargets", function(mvData)
		local client = LocalPlayer()
		local ent = mvData:GetEntity()
		local mvObject = mvData:GetMarkerVisionObject()

		if not client:IsTerror() or not mvObject:IsObjectFor(ent, "alien_target") then return end

		local distance = math.Round(util.HammerUnitsToMeters(mvData:GetEntityDistance()), 1)

		mvData:EnableText()

		mvData:AddIcon(materialAlien)
		mvData:SetTitle(ent:Nick() .. " needs to be probed still.")

		mvData:AddDescriptionLine(ParT("marker_vision_distance", {distance = distance}))
		mvData:AddDescriptionLine(TryT(mvObject:GetVisibleForTranslationKey()), COLOR_SLATEGRAY)
	end)
end

-- alien revival!!!!!
if SERVER then
  hook.Add("TTT2PostPlayerDeath", "AlienKilled", function(ply, _, attacker)
    if not IsValid(ply) or ply:GetSubRole() ~= ROLE_ALIEN then return end
    if IsValid(attacker) and attacker:IsPlayer() and attacker:GetSubRole() == ROLE_INFECTED then return end

    local spawn_delay = 20

    local spawnpoint = plyspawn.GetRandomSafePlayerSpawnPoint(ply)
    local alien_worldspawn = true

    ply:Revive(
      spawn_delay,
      function()
        if alien_worldspawn and spawnpoint then
          ply:SetPos(spawnpoint.pos)
        end
        ply:SetHealth(100)
        ply:ResetConfirmPlayer()
        SendFullStateUpdate()
      end,
      nil,
      false,
      REVIVAL_BLOCK_NONE
    )
  end)
end