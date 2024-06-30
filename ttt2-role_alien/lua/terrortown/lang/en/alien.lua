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
L["alien_probe_name"]    = "Alien's Probe"

-- TODO: ADD MORE FUCKING STRINGS FOR CONVARS