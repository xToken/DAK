//enhanced logging default config

DAK.revisions["enhancedlogging"] = "0.1.306a"

local function SetupDefaultConfig()
	local DefaultConfig = { }
	DefaultConfig.kEnhancedLoggingSubDir = "Logs"
	DefaultConfig.kLogWriteDelay = 1
	return DefaultConfig
end

DAK:RegisterEventHook("PluginDefaultConfigs", {PluginName = "enhancedlogging", DefaultConfig = SetupDefaultConfig })