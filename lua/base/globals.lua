//DAK loader/Base Config

local FunctionMessageTag = "#*DAK"

function DAK:GetDateTimeString(fileformat)

	local DATESTRING = Shared.GetGMTString(false)
	if fileformat then
		DATESTRING = string.gsub(DATESTRING, ":","-")
	end
	return DATESTRING
	
end

function DAK:GetTimeStamp()
	return string.format("L " .. string.format(self:GetDateTimeString(false)) .. " - ")
end

function DAK:IsPluginEnabled(CheckPlugin)
	for index, plugin in pairs(self.config.loader.PluginsList) do
		if CheckPlugin == plugin then
			return true
		end
	end
	return false
end

function DAK:ExecutePluginGlobalFunction(plugin, func, ...)
	if self:IsPluginEnabled(plugin) then
		return func(...)
	end
	return nil
end

function DAK:GetTournamentMode()
	local OverrideTournamentModes = false
	if RBPSconfig then
		//Gonna do some basic NS2Stats detection here
		OverrideTournamentModes = RBPSconfig.tournamentMode
	end
	if self.settings.TournamentMode == nil then
		self.settings.TournamentMode = false
	end
	return self.settings.TournamentMode or OverrideTournamentModes
end

function DAK:GetFriendlyFire()
	if self.settings.FriendlyFire == nil then
		self.settings.FriendlyFire = false
	end
	return self.settings.FriendlyFire
end

//Old/New Database conversion formulas.  'New' format uses a NS2ID indexed system, for faster lookups.  Currently the 'New' format is only used in memory, Bans are still saved in old format
//to preserve backwards compatibility.
function DAK:ConvertFromOldBansFormat(bandata)
	local newdata = { }
	if bandata ~= nil then
		for id, entry in pairs(bandata) do
			if entry ~= nil then
				if entry.id ~= nil then
					newdata[tonumber(entry.id)] = { name = entry.name or "Unknown", reason = entry.reason or "NotProvided", time = entry.time or 0 }
				elseif id ~= nil then
					newdata[tonumber(id)] = { name = entry.name or "Unknown", reason = entry.reason or "NotProvided", time = entry.time or 0 }
				end			
			end
		end
	end
	return newdata
end

function DAK:ConvertToOldBansFormat(bandata)
	local newdata = { }
	if bandata ~= nil then
		for id, entry in pairs(bandata) do
			if entry ~= nil then
				if entry.id ~= nil then
					entry.id = tonumber(entry.id)
					table.insert(newdata, entry)
				elseif id ~= nil then
					local bentry = { id = tonumber(id), name = entry.name or "Unknown", reason = entry.reason or "NotProvided", time = entry.time or 0 }
					table.insert(newdata, bentry)
				end			
			end
		end
	end
	return newdata
end

//Executes a function on the client
function DAK:ExecuteFunctionOnClient(client, functionstring)
	local kMaxPrintLength = 128
	if string.len(FunctionMessageTag .. functionstring) > kMaxPrintLength then
		//Message too long.
		return false
	elseif not DAK:DoesClientHaveClientSideMenus(client) then
		//Client doesnt have client side portion
		return false
	else
		Server.SendNetworkMessage(client, "ServerAdminPrint", { message = string.sub(FunctionMessageTag .. functionstring, 0, kMaxPrintLength) }, true)	
		return true
	end
end