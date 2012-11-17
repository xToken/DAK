//baseadmincommands default config

kDAKRevisions["BaseAdminCommands"] = 1.1
local function SetupDefaultConfig()
	if kDAKConfig.BaseAdminCommands == nil then
		kDAKConfig.BaseAdminCommands = { }
	end
	kDAKConfig.BaseAdminCommands.kEnabled = true
	if Save then
		SaveDAKConfig()
	end
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "BaseAdminCommands", DefaultConfig = function(Save) SetupDefaultConfig(Save) end })

if kDAKConfig.BaseAdminCommands == nil then
	SetupDefaultConfig()
end
