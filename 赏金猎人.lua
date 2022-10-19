--[==[
]==]

--Include sc_default
--require "base/sc_default"

local BountyHunter = {}

BountyHunter.Settings = {
    Name = "|CFF18E7BD[BountyHunter]|r",
    NpcEntry = 90059,
    BountyMoney = 100000,
    HunterMinLevel = 60,
    BountyMinLevel = 60,
    BountyCommand = "#bounty list",
};

function BountyHunter.OnGossipHello(event, player, unit)
    local PlayerLevel = player:GetLevel()
    local PlayerName = player:GetName()

    if PlayerLevel < BountyHunter.Settings.HunterMinLevel then
        player:GossipSetText(string.format("你好 %s 你需要达到级别 %s", PlayerName, BountyHunter.Settings.HunterMinLevel))
    else
        player:GossipMenuAddItem(0, "悬赏 "..BountyHunter.Settings.BountyMoney.." 铜币击杀某人，请在弹出框输入你的仇人", 1, 1, true, nil)
        player:GossipMenuAddItem(0, "悬赏列表", 0, 2)
        player:GossipSetText(string.format("你好 %s", PlayerName))
    end
    player:GossipSendMenu(0x7FFFFFFF, unit)
end

function BountyHunter.OnGossipSelect(event, player, unit, sender, intid, code)
    local result = CharDBQuery("SELECT * FROM character_bounty ORDER BY id ASC")

    if (intid == 1) then
        local result1 = CharDBQuery(string.format("SELECT * FROM character_bounty WHERE bounty_name = ('%s')", code))
        local Bounty = GetPlayerByName(code)
        local BountyName = code
        local HunterName = player:GetName()

        if Bounty and Bounty:GetLevel() >= BountyHunter.Settings.BountyMinLevel then
            print(Bounty:GetLevel())
            if BountyName == HunterName then
                player:SendBroadcastMessage(string.format("%s 你不能悬赏你自己", BountyHunter.Settings.Name))
                player:GossipComplete()
            else
                if result ~= nil and result1 ~= nil then
                    if BountyName == result1:GetString(1) then
                        player:SendBroadcastMessage(string.format("%s On |CFFFF0000%s|r 已经被悬赏", BountyHunter.Settings.Name, BountyName))
                        player:GossipComplete()
                    else
                        if player:GetCoinage() >= BountyHunter.Settings.BountyMoney then
                            player:SendBroadcastMessage(string.format("%s 设置悬赏击杀 |CFFFF0000%s|r", BountyHunter.Settings.Name, BountyName))
                            CharDBQuery(string.format("INSERT INTO `character_bounty` (`bounty_name`, `hunter_name`) VALUES('%s','%s')", BountyName, HunterName))
                            Bounty:SendBroadcastMessage(string.format("%s |CFFFF0000%s|r 设置赏金击杀你", BountyHunter.Settings.Name, HunterName))
                            player:ModifyMoney(-BountyHunter.Settings.BountyMoney)
                            player:GossipComplete()
                        else
                            player:SendBroadcastMessage(string.format("%s 你没有足够的金币", BountyHunter.Settings.Name))
                        end
                    end
                else
                    if player:GetCoinage() >= BountyHunter.Settings.BountyMoney then
                        player:SendBroadcastMessage(string.format("%s Set a bounty on |CFFFF0000%s|r", BountyHunter.Settings.Name, BountyName))
                        CharDBQuery(string.format("INSERT INTO `character_bounty` `bounty_name`, `hunter_name` VALUES('%s','%s')", BountyName, HunterName))
                        Bounty:SendBroadcastMessage(string.format("%s |CFFFF0000%s|r 设置赏金击杀你", BountyHunter.Settings.Name, HunterName))
                        player:ModifyMoney(-BountyHunter.Settings.BountyMoney)
                        player:GossipComplete()
                    else
                        player:SendBroadcastMessage(string.format("%s 你没有足够的金币", BountyHunter.Settings.Name))
                    end 
                end
            end
        else
            player:SendBroadcastMessage(string.format("%s Player with name |CFFFF0000%s|r 没找到或者级别不够 |CFFFF0000%s|r.", BountyHunter.Settings.Name, BountyName, BountyHunter.Settings.BountyMinLevel))
            player:GossipComplete()
        end
    end

    if (intid == 2) then
        if result ~= nil then
            repeat
                player:SendBroadcastMessage(string.format("%s 悬赏: = |CFFFF0000%s|r  / 猎手: = |CFFFF0000%s|r", BountyHunter.Settings.Name, result:GetString(1), result:GetString(2)))
            until not result:NextRow()
        else
            player:SendBroadcastMessage(string.format("%s 没有找到悬赏", BountyHunter.Settings.Name))
        end
    end
    player:GossipComplete()
end

function BountyHunter.OnChatCommand(event, player, msg, _, lang)
    local result = CharDBQuery("SELECT * FROM character_bounty ORDER BY id ASC")

    if (msg == BountyHunter.Settings.BountyCommand) then
        if result ~= nil then
            repeat
                player:SendBroadcastMessage(string.format("%s 悬赏: = |CFFFF0000%s|r  / 猎手: = |CFFFF0000%s|r", BountyHunter.Settings.Name, result:GetString(1), result:GetString(2)))
            until not result:NextRow()
        else
            player:SendBroadcastMessage(string.format("%s 没有找到悬赏", BountyHunter.Settings.Name))
        end
        return false
   end
end

function BountyHunter.OnPlayerKill(event, killer, killed)
    local result = CharDBQuery(string.format("SELECT * FROM character_bounty WHERE bounty_name = ('%s')", killed:GetName()))
    local BountyName = killed:GetName()
 
    if result ~= nil then
        if BountyName == result:GetString(1) then
            killed:SendBroadcastMessage(string.format("%s 你从悬赏列表移除", BountyHunter.Settings.Name))
            killer:SendBroadcastMessage(string.format("%s 在 |CFFFF0000%s|r 是一个悬赏， 你获得 |CFFFF0000%s|r 铜币", BountyHunter.Settings.Name, BountyName, BountyHunter.Settings.BountyMoney))
            CharDBQuery(string.format("DELETE FROM `character_bounty` WHERE bounty_name = '%s'", BountyName))
            killer:ModifyMoney(BountyHunter.Settings.BountyMoney)
        end
    end
end

RegisterPlayerEvent(6, BountyHunter.OnPlayerKill)
RegisterPlayerEvent(18, BountyHunter.OnChatCommand)
RegisterCreatureGossipEvent(BountyHunter.Settings.NpcEntry, 1, BountyHunter.OnGossipHello)
RegisterCreatureGossipEvent(BountyHunter.Settings.NpcEntry, 2, BountyHunter.OnGossipSelect)