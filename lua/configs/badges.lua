//badges

DAK.revisions["badges"] = "0.1.306a"

local function SetupDefaultConfig()
	//DAK.config.Badges = { }
end

DAK:RegisterEventHook("PluginDefaultConfigs", {PluginName = "badges", DefaultConfig = SetupDefaultConfig })