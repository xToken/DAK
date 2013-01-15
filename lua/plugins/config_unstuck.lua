//unstuck config

kDAKRevisions["Unstuck"] = "0.1.114a"

local function SetupDefaultConfig(Save)
	if kDAKConfig.Unstuck == nil then
		kDAKConfig.Unstuck = { }
	end
	kDAKConfig.Unstuck.kMinimumWaitTime = 5
	kDAKConfig.Unstuck.kTimeBetweenUntucks = 30
	kDAKConfig.Unstuck.kUnstuckAmount = 0.5
	kDAKConfig.Unstuck.kUnstuckChatCommands = { "stuck", "unstuck", "/stuck", "/unstuck" }
	if Save then
		SaveDAKConfig()
	end
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "Unstuck", DefaultConfig = SetupDefaultConfig })