//Messages config

kDAKRevisions["Messages"] = "0.1.114a"

local function SetupDefaultConfig(Save)
	if kDAKConfig.Messages == nil then
		kDAKConfig.Messages = { }
	end
	kDAKConfig.Messages.kMessagesPerTick = 5
	kDAKConfig.Messages.kMessageTickDelay = 6
	kDAKConfig.Messages.kMessageInterval = 10
	kDAKConfig.Messages.kMessageStartDelay = 1
	if Save then
		SaveDAKConfig()
	end
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "Messages", DefaultConfig = SetupDefaultConfig })