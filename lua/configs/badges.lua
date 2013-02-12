//badges

DAK.revisions["badges"] = "0.1.211a"

local function SetupDefaultConfig()
	//DAK.config.Badges = { }
end

DAK:RegisterEventHook("PluginDefaultConfigs", {PluginName = "badges", DefaultConfig = SetupDefaultConfig })