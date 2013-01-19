//DAKLoader Plugin Loader

//Load Plugins
local function LoadPlugins()
	
	if kDAKConfig ~= nil and kDAKConfig.DAKLoader ~= nil then
		for i = 1, #kDAKConfig.DAKLoader.kPluginsList do
			if kDAKSettings[kDAKConfig.DAKLoader.kPluginsList[i]] ~= kDAKRevisions[kDAKConfig.DAKLoader.kPluginsList[i]] then
				kDAKSettings[kDAKConfig.DAKLoader.kPluginsList[i]] = kDAKRevisions[kDAKConfig.DAKLoader.kPluginsList[i]]
				local filename = string.format("lua/plugins/plugin_%s.lua", kDAKConfig.DAKLoader.kPluginsList[i])
				Script.Load(filename)
				kDAKSettings[kDAKConfig.DAKLoader.kPluginsList[i]] = true
				if kDAKRevisions["dakloader"] == kDAKRevisions[kDAKConfig.DAKLoader.kPluginsList[i]] then
					Shared.Message(string.format("Plugin %s loaded.",kDAKConfig.DAKLoader.kPluginsList[i]))
				else
					Shared.Message(string.format("Plugin %s loaded, v%s DAKLoader - v%s Plugin version mismatch.", kDAKConfig.DAKLoader.kPluginsList[i], kDAKRevisions["dakloader"], kDAKRevisions[kDAKConfig.DAKLoader.kPluginsList[i]]))
				end
			else
				Shared.Message(string.format("Plugin %s did not load successfully last run, skipping..",kDAKConfig.DAKLoader.kPluginsList[i]))
			end
		end
	else
		Shared.Message("Something may be wrong with your config file.")
	end
end

LoadPlugins()

DAKCreateServerAdminCommand("Console_sv_reloadplugins", LoadPlugins, "Reloads all plugins.")