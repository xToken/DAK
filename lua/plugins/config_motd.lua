//motd config

kDAKRevisions["MOTD"] = "0.1.114a"

local function SetupDefaultConfig(Save)
	if kDAKConfig.MOTD == nil then
		kDAKConfig.MOTD = { }
	end
	kDAKConfig.MOTD.kMOTDMessageDelay = 6
	kDAKConfig.MOTD.kMOTDMessageRevision = 1
	kDAKConfig.MOTD.kMOTDMessagesPerTick = 5
	kDAKConfig.MOTD.kAcceptMOTDChatCommands = { "acceptmotd" }
	kDAKConfig.MOTD.kPrintMOTDChatCommands = { "printmotd" }
	if Save then
		SaveDAKConfig()
	end
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "MOTD", DefaultConfig = SetupDefaultConfig })