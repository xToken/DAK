// Main menu functions
//These define what is displayed in the main DAK menu.  Other plugins can still create and manage their own menus outside this.
//This menu is more for basic configuration, issuing of basic commands and functions.
//.name = 
//.validforclient
//.selectionfunction

function DAK:GetMainMenuItemByName(friendlyname, list)
	for i, menuitem in pairs(list or DAK.activemenuitems) do
		if menuitem.fname == friendlyname then
			return menuitem
		end
	end
	return nil
end

function DAK:RegisterMainMenuItem(friendlyname, clientvalidation, selectfunction)
	if friendlyname ~= nil and DAK:GetMainMenuItemByName(friendlyname) == nil then
		local menuitem = {fname = friendlyname, validate = clientvalidation, selectfunc = selectfunction}
		table.insert(DAK.activemenuitems, menuitem)
		return true
	else
		return false
	end
end

function DAK:ValidateMenuOptionForClient(menuitem, client)
	if type(menuitem.validate) == "function" then
		return menuitem.validate(client)
	else
		return menuitem.validate == true
	end
end

function DAK:GetMenuItemsList(client)
	local relevantitems = { }
	for i, menuitem in pairs(DAK.activemenuitems) do
		if DAK:ValidateMenuOptionForClient(menuitem, client) then
			table.insert(relevantitems, menuitem)
		end
	end
	return relevantitems
end

function DAK:UpdateClientMainMenu(ns2id, LastUpdateMessage, page)
	local MenuUpdateMessage = DAK:CreateMenuBaseNetworkMessage()
	if MenuUpdateMessage == nil then
		MenuUpdateMessage = { }
	end
	local client = DAK:GetClientMatchingNS2Id(ns2id)
	if client == nil then
		return LastUpdateMessage
	end
	MenuUpdateMessage.header = string.format("DAK Mod Menu")
	i = 1
	for i, menuitem in pairs(DAK:GetMenuItemsList(client)) do
		local ci = i - (page * 8)
		if ci > 0 and ci < 9 then
			MenuUpdateMessage.option[ci] = menuitem.fname
		end
		i = i + 1
	end
	MenuUpdateMessage.footer = "Press a number key to select that option."
	MenuUpdateMessage.inputallowed = true
	return MenuUpdateMessage
end

function DAK:SelectMainMenuItem(client, selecteditem, page)
	//Validate selection to prevent BS
	local menuitem = DAK:GetMenuItemsList(client)[selecteditem + (page * 8)]
	if menuitem ~= nil then
		menuitem.selectfunc(client)
		return true
	else
		Shared.Message("Nil menu selection?")
	end
end
/// End Menu Functions

/// Confirmation Menu Functions
// These are really just a small extension to allow easy confirm/deny menus

function DAK:UpdateConfirmationMenu(ns2id, LastUpdateMessage, page)
	if DAK.confirmationmenus[ns2id] ~= nil then
		local MenuUpdateMessage = DAK:CreateMenuBaseNetworkMessage()
		if MenuUpdateMessage == nil then
			MenuUpdateMessage = { }
		end
		MenuUpdateMessage.header = DAK.confirmationmenus[ns2id].heading
		MenuUpdateMessage.option[1] = "Confirm"
		MenuUpdateMessage.option[2] = "Deny"
		MenuUpdateMessage.footer = "Press a number key to select that option."
		MenuUpdateMessage.inputallowed = true
		return MenuUpdateMessage
	else
		return LastUpdateMessage
	end
end

function DAK:SelectConfirmationMenuItem(client, selecteditem, page)
	if client ~= nil then
		local ns2id = client:GetUserId()
		if DAK.confirmationmenus[ns2id] ~= nil then
			if selecteditem == 1 and DAK.confirmationmenus[ns2id].confirmfunc ~= nil and type(DAK.confirmationmenus[ns2id].confirmfunc) == "function" then
				DAK.confirmationmenus[ns2id].confirmfunc(client, unpack(DAK.confirmationmenus[ns2id].args or { }))
			elseif selecteditem == 2 and DAK.confirmationmenus[ns2id].denyfunc ~= nil and type(DAK.confirmationmenus[ns2id].denyfunc) == "function" then
				DAK.confirmationmenus[ns2id].denyfunc(client, unpack(DAK.confirmationmenus[ns2id].args or { }))
			end
			DAK.confirmationmenus[ns2id] = nil
		end
		return true
	end
end

local function UpdateConfirmationMenuHook(ns2id, LastUpdateMessage, page)
	return DAK:UpdateConfirmationMenu(ns2id, LastUpdateMessage, page)
end

local function UpdateConfirmationMenuSelectItemHook(client, selecteditem, page)
	return DAK:SelectConfirmationMenuItem(client, selecteditem, page)
end

function DAK:DisplayConfirmationMenuItem(ns2id, HeadingText, ConfirmationFunction, DenyFunction, ...)
	if ns2id ~= nil then
		local menuitem = {heading = HeadingText, confirmfunc = ConfirmationFunction, denyfunc = DenyFunction, args = arg}
		DAK.confirmationmenus[ns2id] = menuitem
		DAK:CreateGUIMenuBase(ns2id, UpdateConfirmationMenuSelectItemHook, UpdateConfirmationMenuHook, true)
	end
end
/// End Confirmation Menus

function DAK:DoesNS2IDHaveClientSideMenus(ns2id)
	if ns2id ~= nil and tonumber(ns2id) ~= nil then
		return DAK.activemoddedclients[tonumber(ns2id)]
	end
	return false
end

function DAK:DoesClientHaveClientSideMenus(client)
	if client ~= nil then
		return DAK:DoesNS2IDHaveClientSideMenus(client:GetUserId())
	end
	return false
end

function DAK:DoesPlayerHaveClientSideMenus(client)
	if player ~= nil then
		return DAK:DoesClientHaveClientSideMenus(Server.GetOwner(player))
	end
end

function DAK:CreateGUIMenuBase(id, OnMenuFunction, OnMenuUpdateFunction, override)

	if id == nil or id == 0 or tonumber(id) == nil or not DAK:DoesNS2IDHaveClientSideMenus(id) or not DAK.config.loader.AllowClientMenus then return false end
	for i = #DAK.runningmenus, 1, -1 do
		if DAK.runningmenus[i] ~= nil and DAK.runningmenus[i].clientNS2Id == id then
			if override then
				table.remove(DAK.runningmenus, i)
			else
				return false
			end
		end
	end
	
	local GameMenu = {UpdateTime = math.max(Shared.GetTime() - 2, 0), MenuFunction = OnMenuFunction, MenuUpdateFunction = OnMenuUpdateFunction,
						MenuBaseUpdateMessage = nil, clientNS2Id = id, activepage = 0}
	table.insert(DAK.runningmenus, GameMenu)
	return true
	
end

function DAK:CreateMenuBaseNetworkMessage()
	local kVoteUpdateMessage = { }
	kVoteUpdateMessage.header = ""
	kVoteUpdateMessage.option = { }
	kVoteUpdateMessage.option[1] = ""
	kVoteUpdateMessage.option[2] = ""
	kVoteUpdateMessage.option[3] = ""
	kVoteUpdateMessage.option[4] = ""
	kVoteUpdateMessage.option[5] = ""
	kVoteUpdateMessage.option[6] = ""
	kVoteUpdateMessage.option[7] = ""
	kVoteUpdateMessage.option[8] = ""
	kVoteUpdateMessage.option[9] = ""
	kVoteUpdateMessage.option[10] = ""
	kVoteUpdateMessage.footer = ""
	kVoteUpdateMessage.inputallowed = false
	kVoteUpdateMessage.menutime = Shared.GetTime()
	return kVoteUpdateMessage
end

function DAK:PopulateClientMenuItemWithClientList(VoteUpdateMessage, page)
	local clientlist = DAK:GetClientList()
	for p = 1, #clientlist do
		local ci = p - (page * 8)
		if ci > 0 and ci < 9 then
			VoteUpdateMessage.option[ci] = string.format(DAK:GetClientUIDString(clientlist[p]))
		end
	end
end