//GUIMenuBase config

local function SetupDefaultConfig()
	local DefaultConfig = { }
	DefaultConfig.kMenuUpdateRate = 2
	return DefaultConfig
end

DAK:RegisterEventHook("PluginDefaultConfigs", {PluginName = "guimenubase", DefaultConfig = SetupDefaultConfig })