//unstuck config

kDAKRevisions["unstuck"] = "0.1.119a"

local function SetupDefaultConfig()
	kDAKConfig.Unstuck = { }
	kDAKConfig.Unstuck.kMinimumWaitTime = 5
	kDAKConfig.Unstuck.kTimeBetweenUntucks = 30
	kDAKConfig.Unstuck.kUnstuckAmount = 0.5
	kDAKConfig.Unstuck.kUnstuckChatCommands = { "stuck", "unstuck", "/stuck", "/unstuck" }
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "unstuck", DefaultConfig = SetupDefaultConfig })