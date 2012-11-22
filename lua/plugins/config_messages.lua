//Messages config

kDAKRevisions["Messages"] = 1.0
local function SetupDefaultConfig(Save)
	local MessageTable = { }
	table.insert(MessageTable, "********************************************************************")
	table.insert(MessageTable, "****************** Welcome to the XYZ NS2 Servers ******************")
	table.insert(MessageTable, "*********** You can also visit our forums at 123.NS2.COM ***********")
	table.insert(MessageTable, "********************************************************************")
	if kDAKConfig.Messages == nil then
		kDAKConfig.Messages = { }
	end
	kDAKConfig.Messages.kMessage = MessageTable
	kDAKConfig.Messages.kMessagesPerTick = 5
	kDAKConfig.Messages.kMessageTickDelay = 6
	kDAKConfig.Messages.kMessageInterval = 10
	if Save then
		SaveDAKConfig()
	end
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "Messages", DefaultConfig = function(Save) SetupDefaultConfig(Save) end })

if kDAKConfig.Messages == nil then
	SetupDefaultConfig(false)
end