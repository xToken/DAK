//badges

kDAKRevisions["badges"] = "0.1.126a"

local function SetupDefaultConfig()
	//kDAKConfig.Badges = { }
end

DAKRegisterEventHook("kDAKPluginDefaultConfigs", {PluginName = "badges", DefaultConfig = SetupDefaultConfig })