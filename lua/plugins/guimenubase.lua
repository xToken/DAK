//NS2 Menu Base GUI Implementation

local kRunningMenus = { }
local ActiveModdedClients = { }

//GUIMenuBase
//MenuFunction(client, OptionSelected)
//MenuUpdateFunction(ClientGameID, kMenuBaseUpdateMessage)

//Would need a reasonable amount of additional dev time to update voting related plugins to optionally use the GUI.  Need to make sure consistency is maintained with text commands still working.

local function UpdateMenus(deltatime)

	for i = #kRunningMenus, 1, -1 do
		if kRunningMenus[i] ~= nil and kRunningMenus[i].UpdateTime ~= nil then
			if (Shared.GetTime() - kRunningMenus[i].UpdateTime) >= DAK.config.guimenubase.kMenuUpdateRate then
				local newMenuBaseUpdateMessage = kRunningMenus[i].MenuUpdateFunction(kRunningMenus[i].clientSteamId, kRunningMenus[i].MenuBaseUpdateMessage)
				//Check to see if message is updated, if not then send term message and clear
				if newMenuBaseUpdateMessage == kRunningMenus[i].MenuBaseUpdateMessage then
					newMenuBaseUpdateMessage.menutime = 0
				end
				Server.SendNetworkMessage(DAK:GetPlayerMatchingSteamId(kRunningMenus[i].clientSteamId), "GUIMenuBase", newMenuBaseUpdateMessage, false)						
				kRunningMenus[i].MenuBaseUpdateMessage = newMenuBaseUpdateMessage
				if newMenuBaseUpdateMessage ~= nil and  newMenuBaseUpdateMessage.menutime ~= nil and newMenuBaseUpdateMessage.menutime ~= 0 then
					kRunningMenus[i].UpdateTime = Shared.GetTime()
				else
					kRunningMenus[i] = nil
				end
			end
		else
			kRunningMenus[i] = nil
		end
	end
	if #kRunningMenus == 0 then
		DAK:DeregisterEventHook("OnServerUpdate", UpdateMenus)
	end

end

function CreateGUIMenuBase(id, OnMenuFunction, OnMenuUpdateFunction)

	if id == nil or id == 0 or tonumber(id) == nil then return false end
	for i = #kRunningMenus, 1, -1 do
		if kRunningMenus[i] ~= nil and kRunningMenus[i].clientSteamId == id then
			return false
		end
	end
	
	local GameMenu = {UpdateTime = math.max(Shared.GetTime() - DAK.config.guimenubase.kMenuUpdateRate, 0), MenuFunction = OnMenuFunction, MenuUpdateFunction = OnMenuUpdateFunction, MenuBaseUpdateMessage = nil, clientSteamId = id}
	if #kRunningMenus == 0 then
		DAK:RegisterEventHook("OnServerUpdate", UpdateMenus, 7)
		//Want increased pri on this to make sure it runs before other events that may use information from it...
	end
	table.insert(kRunningMenus, GameMenu)
	return true
	
end

function CreateMenuBaseNetworkMessage()
	local kVoteUpdateMessage = { }
	kVoteUpdateMessage.header = ""
	kVoteUpdateMessage.option1 = ""
	kVoteUpdateMessage.option2 = ""
	kVoteUpdateMessage.option3 = ""
	kVoteUpdateMessage.option4 = ""
	kVoteUpdateMessage.option5 = ""
	kVoteUpdateMessage.option6 = ""
	kVoteUpdateMessage.option7 = ""
	kVoteUpdateMessage.option8 = ""
	kVoteUpdateMessage.option9 = ""
	kVoteUpdateMessage.option10 = ""
	kVoteUpdateMessage.footer = ""
	kVoteUpdateMessage.inputallowed = false
	kVoteUpdateMessage.menutime = Shared.GetTime()
	return kVoteUpdateMessage
end

local function EnableClientMenus(client)
	if client ~= nil then
		local steamid = client:GetUserId()
		if steamid ~= nil and tonumber(steamid) ~= nil then
			ActiveModdedClients[tonumber(steamid)] = true
			Print("Hello Sir!")
		end
	end
end

Event.Hook("Console_RegisterClientMenus", EnableClientMenus)

local function OnMessageBaseMenu(client, menuMessage)

	if menuMessage ~= nil and client ~= nil then
		local steamId = client:GetUserId()
		if steamId ~= nil and tonumber(steamId) ~= nil then
			for i = #kRunningMenus, 1, -1 do
				if kRunningMenus[i].clientSteamId == steamId then
					if kRunningMenus[i].MenuFunction(client, menuMessage.optionselected) then
						kRunningMenus[i] = nil
					end
					break
				end
			end
		end
		//Shared.Message(string.format("Recieved selection %s", menuMessage.optionselected))
	end
	
end

Server.HookNetworkMessage("GUIMenuBaseSelected", OnMessageBaseMenu)