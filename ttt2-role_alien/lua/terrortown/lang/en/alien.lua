local L = LANG.GetLanguageTableReference("en")

-- GENERAL ROLE LANGUAGE STRINGS
L[ALIEN.name] = "Alien"
L[ALIEN.defaultTeam] = "Team Alien"
L["hilite_win_" .. ALIEN.defaultTeam] = "TEAM ALIEN WON"
L["info_popup_" .. ALIEN.name] = [[You are the Alien! Probe enough players and you will win.]]
L["body_found_" .. ALIEN.abbr] = "They were an Alien."
L["search_role_" .. ALIEN.abbr] = "This person was an Alien!"
L["target_" .. ALIEN.name] = "Alien"
L["ttt2_desc_" .. ALIEN.name] = [[The Alien can probe people to win and heal players.]]

-- ALIEN SPECIFIC ROLE STRINGS
L["alien_probe_name"] = "Alien Probe"
L["alien_probe_help"] = "Probe players & bodies to win. This also heals players."
L["alien_probe_desc"] = "Probe enough players to win."
L["label_alien_new_probe"] = "'{playername}' has been probed. Probing data uploaded!"
L["label_alien_new_probe_other_players"] = "ALERT! {currProbe} out of {maxProbe} players have been probed!"
L["label_alien_already_probed"] = "You already probed this player. Find a new specimen."
L["label_alien_probed_players_win_threshold"] = "How many players need to be probed for Alien Victory:"
L["label_alien_probe_healing"] = "How much healing the probe gives:"