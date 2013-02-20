//badges

DAK.revisions["badges"] = "0.1.219a"

local function SetupDefaultConfig()
	//DAK.config.Badges = { }
end

DAK:RegisterEventHook("PluginDefaultConfigs", {PluginName = "badges", DefaultConfig = SetupDefaultConfig })