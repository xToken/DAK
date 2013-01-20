//motd config

kDAKRevisions["motd"] = "0.1.119a"

local function SetupDefaultConfig()
	kDAKConfig.MOTD = { }
	kDAKConfig.MOTD.kMOTDMessageDelay = 6
	kDAKConfig.MOTD.kMOTDMessageRevision = 1
	kDAKConfig.MOTD.kMOTDMessagesPerTick = 5
	kDAKConfig.MOTD.kAcceptMOTDChatCommands = { "acceptmotd" }
	kDAKConfig.MOTD.kPrintMOTDChatCommands = { "printmotd" }
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "motd", DefaultConfig = SetupDefaultConfig })