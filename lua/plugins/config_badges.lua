//badges

kDAKRevisions["Badges"] = "0.1.116a"

local function SetupDefaultConfig(Save)
	if kDAKConfig.Badges == nil then
		kDAKConfig.Badges = { }
	end
	if Save then
		SaveDAKConfig()
	end
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "Badges", DefaultConfig = SetupDefaultConfig })