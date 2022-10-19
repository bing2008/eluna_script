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
        player:GossipSetText(string.format("��� %s ����Ҫ�ﵽ���� %s", PlayerName, BountyHunter.Settings.HunterMinLevel))
    else
        player:GossipMenuAddItem(0, "���� "..BountyHunter.Settings.BountyMoney.." ͭ�һ�ɱĳ�ˣ����ڵ�����������ĳ���", 1, 1, true, nil)
        player:GossipMenuAddItem(0, "�����б�", 0, 2)
        player:GossipSetText(string.format("��� %s", PlayerName))
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
                player:SendBroadcastMessage(string.format("%s �㲻���������Լ�", BountyHunter.Settings.Name))
                player:GossipComplete()
            else
                if result ~= nil and result1 ~= nil then
                    if BountyName == result1:GetString(1) then
                        player:SendBroadcastMessage(string.format("%s On |CFFFF0000%s|r �Ѿ�������", BountyHunter.Settings.Name, BountyName))
                        player:GossipComplete()
                    else
                        if player:GetCoinage() >= BountyHunter.Settings.BountyMoney then
                            player:SendBroadcastMessage(string.format("%s �������ͻ�ɱ |CFFFF0000%s|r", BountyHunter.Settings.Name, BountyName))
                            CharDBQuery(string.format("INSERT INTO `character_bounty` (`bounty_name`, `hunter_name`) VALUES('%s','%s')", BountyName, HunterName))
                            Bounty:SendBroadcastMessage(string.format("%s |CFFFF0000%s|r �����ͽ��ɱ��", BountyHunter.Settings.Name, HunterName))
                            player:ModifyMoney(-BountyHunter.Settings.BountyMoney)
                            player:GossipComplete()
                        else
                            player:SendBroadcastMessage(string.format("%s ��û���㹻�Ľ��", BountyHunter.Settings.Name))
                        end
                    end
                else
                    if player:GetCoinage() >= BountyHunter.Settings.BountyMoney then
                        player:SendBroadcastMessage(string.format("%s Set a bounty on |CFFFF0000%s|r", BountyHunter.Settings.Name, BountyName))
                        CharDBQuery(string.format("INSERT INTO `character_bounty` `bounty_name`, `hunter_name` VALUES('%s','%s')", BountyName, HunterName))
                        Bounty:SendBroadcastMessage(string.format("%s |CFFFF0000%s|r �����ͽ��ɱ��", BountyHunter.Settings.Name, HunterName))
                        player:ModifyMoney(-BountyHunter.Settings.BountyMoney)
                        player:GossipComplete()
                    else
                        player:SendBroadcastMessage(string.format("%s ��û���㹻�Ľ��", BountyHunter.Settings.Name))
                    end 
                end
            end
        else
            player:SendBroadcastMessage(string.format("%s Player with name |CFFFF0000%s|r û�ҵ����߼��𲻹� |CFFFF0000%s|r.", BountyHunter.Settings.Name, BountyName, BountyHunter.Settings.BountyMinLevel))
            player:GossipComplete()
        end
    end

    if (intid == 2) then
        if result ~= nil then
            repeat
                player:SendBroadcastMessage(string.format("%s ����: = |CFFFF0000%s|r  / ����: = |CFFFF0000%s|r", BountyHunter.Settings.Name, result:GetString(1), result:GetString(2)))
            until not result:NextRow()
        else
            player:SendBroadcastMessage(string.format("%s û���ҵ�����", BountyHunter.Settings.Name))
        end
    end
    player:GossipComplete()
end

function BountyHunter.OnChatCommand(event, player, msg, _, lang)
    local result = CharDBQuery("SELECT * FROM character_bounty ORDER BY id ASC")

    if (msg == BountyHunter.Settings.BountyCommand) then
        if result ~= nil then
            repeat
                player:SendBroadcastMessage(string.format("%s ����: = |CFFFF0000%s|r  / ����: = |CFFFF0000%s|r", BountyHunter.Settings.Name, result:GetString(1), result:GetString(2)))
            until not result:NextRow()
        else
            player:SendBroadcastMessage(string.format("%s û���ҵ�����", BountyHunter.Settings.Name))
        end
        return false
   end
end

function BountyHunter.OnPlayerKill(event, killer, killed)
    local result = CharDBQuery(string.format("SELECT * FROM character_bounty WHERE bounty_name = ('%s')", killed:GetName()))
    local BountyName = killed:GetName()
 
    if result ~= nil then
        if BountyName == result:GetString(1) then
            killed:SendBroadcastMessage(string.format("%s ��������б��Ƴ�", BountyHunter.Settings.Name))
            killer:SendBroadcastMessage(string.format("%s �� |CFFFF0000%s|r ��һ�����ͣ� ���� |CFFFF0000%s|r ͭ��", BountyHunter.Settings.Name, BountyName, BountyHunter.Settings.BountyMoney))
            CharDBQuery(string.format("DELETE FROM `character_bounty` WHERE bounty_name = '%s'", BountyName))
            killer:ModifyMoney(BountyHunter.Settings.BountyMoney)
        end
    end
end

RegisterPlayerEvent(6, BountyHunter.OnPlayerKill)
RegisterPlayerEvent(18, BountyHunter.OnChatCommand)
RegisterCreatureGossipEvent(BountyHunter.Settings.NpcEntry, 1, BountyHunter.OnGossipHello)
RegisterCreatureGossipEvent(BountyHunter.Settings.NpcEntry, 2, BountyHunter.OnGossipSelect)