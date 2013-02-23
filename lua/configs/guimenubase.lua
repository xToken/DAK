//GUIMenuBase config

DAK.revisions["guimenubase"] = "0.1.223a"

local function SetupDefaultConfig()
	local DefaultConfig = { }
	DefaultConfig.kMenuUpdateRate = 5
	return DefaultConfig
end

DAK:RegisterEventHook("PluginDefaultConfigs", {PluginName = "guimenubase", DefaultConfig = SetupDefaultConfig })