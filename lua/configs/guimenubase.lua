//GUIMenuBase config

local function SetupDefaultConfig()
	local DefaultConfig = { }
	DefaultConfig.kMenuUpdateRate = 5
	return DefaultConfig
end

DAK:RegisterEventHook("PluginDefaultConfigs", {PluginName = "guimenubase", DefaultConfig = SetupDefaultConfig })