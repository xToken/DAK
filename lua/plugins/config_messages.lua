//Messages config

kDAKRevisions["messages"] = "0.1.118a"

local function SetupDefaultConfig()
	kDAKConfig.Messages = { }
	kDAKConfig.Messages.kMessagesPerTick = 5
	kDAKConfig.Messages.kMessageTickDelay = 6
	kDAKConfig.Messages.kMessageInterval = 10
	kDAKConfig.Messages.kMessageStartDelay = 1
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "messages", DefaultConfig = SetupDefaultConfig })