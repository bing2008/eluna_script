local PLAYER_EVENT_ON_LOGIN = 3

local function OnLogin(event, player)
    player:SendBroadcastMessage("Hello world")
end

RegisterPlayerEvent(PLAYER_EVENT_ON_LOGIN, OnLogin)
--
--print(">>Script: TeleportStone loading...OK")
--
----菜单所有者 --默认炉石
--local itemEntry	=6948
--local Stone={}
--function Stone.ShowGossip(event, player, item)
--	player:SendBroadcastMessage("ShowGossip")
--	return false
--end
--
--function Stone.SelectGossip(event, player, item, sender, intid, code, menu_id)
--	player:SendBroadcastMessage("SelectGossip")
--	return false
--end
--
--
--RegisterItemGossipEvent(itemEntry, 1, Stone.ShowGossip)
--RegisterItemGossipEvent(itemEntry, 2, Stone.SelectGossip)
