ALIEN_DATA = {}
ALIEN_DATA.amount_probed = 0
ALIEN_DATA.amount_to_win = GetConVar("ttt2_alien_probed_players_win_threshold"):GetInt()

if CLIENT then
	net.Receive("ttt2_role_alien_update", function()
		ALIEN_DATA.amount_probed = net.ReadUInt(16)
		ALIEN_DATA.amount_to_win = net.ReadUInt(16)
	end)
else
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

-- Function that increases probed players
local function incAlienCounter()
    ALIEN_DATA:AddProbed()

	-- if alien has probed enough, then he wins
	if(ALIEN_DATA:GetProbedAmount() >= ALIEN_DATA:GetAmountToWin()) then
        roles.ALIEN.shouldWin = true
        ALIEN_DATA.amount_probed = 0
    end
end

-- reset stuff at round end AND start
hook.Add("TTTEndRound", "AlienEndRound", function()
	roles.ALIEN.shouldWin = false
    ALIEN_DATA.amount_probed = 0
end)

hook.Add("TTTBeginRound", "AlienBeginRound", function()
	roles.ALIEN.shouldWin = false
    ALIEN_DATA.amount_probed = 0
end)

--hook that will attempt to increase players probed by 1
if SERVER then
    hook.Add("EVENT_ALIEN_PROBE", "ttt_increase_alien_counter", incAlienCounter)
end