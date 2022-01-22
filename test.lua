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
local target
local function Chat (event, player, message, type, language)
	player:SendBroadcastMessage("Chating")
	if (message == "#sex") then --test change model
		player:SetDisplayId(1)
		player:SendBroadcastMessage("You have been sexed up!")
		return 0
	end
	--get target
	if(message == "t") then
		target=player:GetSelection()--得到玩家选中对象
		player:SendBroadcastMessage("get target:"..target:GetName().." type:"..target:GetTypeId())
	end
	-- test move 
	if(message =="a") then
		local slave = player:GetSelection()--得到玩家选中对象
		if(slave)then
			if(slave:GetTypeId()==3)then--目标是生物
				--slave:MoveFollow(target)
			end
		end
	end
	if(message == "k") then
		player:SetHealth(0)
		player:KillPlayer()
		--player:SetLuaCooldown(0, 3)
		--player:RemoveEvents()
		player:SendBroadcastMessage("player:"..player:GetName().." killed")

	end
end
RegisterPlayerEvent(18, Chat)
--RegisterPlayerEvent(42,Chat)

-- 让闪金镇的马克能够对话
local creatureEntry = 795
local function OnGossipHello(event, player, unit)
    player:GossipMenuAddItem(0, "Test Weather", 1, 1)
    player:GossipMenuAddItem(0, "Nevermind..", 1, 2)
    player:GossipSendMenu(1, unit)
end

local function OnGossipSelect(event, plr, unit, sender, action, code)
    if (action == 1) then
        plr:GetMap():SetWeather(plr:GetZoneId(), math.random(0, 3), 1) -- random weather
        plr:GossipComplete()
	unit:MoveFollow(plr)
    elseif (action == 2) then
        plr:GossipComplete()
	plr:SendBroadcastMessage("player:"..plr:GetName().." hello?")
	--unit:MoveTo(0, plr:GetX()+50,plr:GetY(),plr:GetZ())
	unit:MoveClear()
    end
end


RegisterCreatureGossipEvent(creatureEntry, 1, OnGossipHello)
RegisterCreatureGossipEvent(creatureEntry, 2, OnGossipSelect)
