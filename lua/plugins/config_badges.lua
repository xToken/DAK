//badges

kDAKRevisions["badges"] = "0.1.125a"

local function SetupDefaultConfig()
	//kDAKConfig.Badges = { }
end

DAKRegisterEventHook("kDAKPluginDefaultConfigs", {PluginName = "badges", DefaultConfig = SetupDefaultConfig })