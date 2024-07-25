ALIEN_DATA = {}
ALIEN_DATA.amount_probed = 0
ALIEN_DATA.amount_to_win = GetConVar("ttt2_alien_probed_players_win_threshold"):GetInt()
ALIEN_DATA.probedTable = {}

if CLIENT then
	net.Receive("ttt2_role_alien_update", function()
		ALIEN_DATA.amount_probed = net.ReadUInt(16)
		ALIEN_DATA.amount_to_win = net.ReadUInt(16)
	end)
else
	resource.AddWorkshop("3278424620") -- make sure files get downloaded right
    util.AddNetworkString("ttt2_role_alien_update")
end

function ALIEN_DATA:AddProbed()
    self.amount_probed = self.amount_probed + 1
    --sync to client
    net.Start("ttt2_role_alien_update")
    net.WriteUInt(self.amount_probed, 16)
    net.WriteUInt(self.amount_to_win, 16)
    net.Broadcast()
end

function ALIEN_DATA:GetProbedAmount()
    return self.amount_probed
end

function ALIEN_DATA:GetAmountToWin()
	return self.amount_to_win
end

-- Hook that updates the probe win threshold everytime the alien probes someone
if SERVER then
	hook.Add("TTTBeginRound", "ttt_update_alien_threshold", function()
		-- Gets the updated threshold (if it was updated)
		ALIEN_DATA.amount_to_win = GetConVar("ttt2_alien_probed_players_win_threshold"):GetInt()
		--Sends to client
		net.Start("ttt2_role_alien_update")
		net.WriteUInt(ALIEN_DATA.amount_probed, 16)
		net.WriteUInt(ALIEN_DATA.amount_to_win, 16)
		net.Broadcast()
	end)
end

-- reset stuff at round end AND start
hook.Add("TTTEndRound", "AlienEndRound", function()
	roles.ALIEN.shouldWin = false
    ALIEN_DATA.amount_probed = 0
	ALIEN_DATA.probedTable = {}
end)
hook.Add("TTTBeginRound", "AlienBeginRound", function()
	roles.ALIEN.shouldWin = false
    ALIEN_DATA.amount_probed = 0
	ALIEN_DATA.probedTable = {}
end)

-- hook that will attempt to increase players probed by 1
if SERVER then
    hook.Add("EVENT_ALIEN_PROBE", "ttt_increase_alien_counter", function(probedPly)
		-- check if the player has already been probed
		for k, v in pairs(ALIEN_DATA.probedTable) do
			if v == probedPly then
				LANG.Msg(roles.GetTeamMembers(TEAM_ALIEN), "label_alien_already_probed", nil, MSG_MSTACK_WARN)
				return
			end
		end

		-- tell alien he probed em
		LANG.Msg(roles.GetTeamMembers(TEAM_ALIEN), "label_alien_new_probe", {playername = probedPly:Nick()}, MSG_MSTACK_ROLE)

		-- add to counter
		ALIEN_DATA:AddProbed()

		-- tell other players what the probe counter is
		LANG.MsgAll("label_alien_new_probe_other_players", {currProbe = ALIEN_DATA.amount_probed, maxProbe = ALIEN_DATA.amount_to_win} , MSG_MSTACK_WARN)

		-- add player to table, so they cant be probed again
		table.insert(ALIEN_DATA.probedTable, probedPly)

		-- if alien has probed enough, then he wins
		if(ALIEN_DATA:GetProbedAmount() >= ALIEN_DATA:GetAmountToWin()) then
			roles.ALIEN.shouldWin = true
			ALIEN_DATA.amount_probed = 0
			ALIEN_DATA.probedTable = {}
		end
	end)
end