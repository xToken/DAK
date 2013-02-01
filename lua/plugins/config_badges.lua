//badges

kDAKRevisions["badges"] = "0.1.131a"

local function SetupDefaultConfig()
	//kDAKConfig.Badges = { }
end

DAKRegisterEventHook("kDAKPluginDefaultConfigs", {PluginName = "badges", DefaultConfig = SetupDefaultConfig })