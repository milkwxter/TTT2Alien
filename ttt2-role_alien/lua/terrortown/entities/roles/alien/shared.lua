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
    self.preventWin                 = false -- Can he win on his own? true means NO, false means YES
    self.unknownTeam                = false

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
		self.alienOriginalModel = ply:GetModel()
		ply:SetModel( "models/player/howardalien.mdl" )
	end

	-- Remove Loadout on death and rolechange
	function ROLE:RemoveRoleLoadout(ply, isRoleChange)
		ply:SetModel( self.alienOriginalModel )
	end
end