//reservedslots config

kDAKRevisions["reservedslots"] = "0.1.118a"

local function SetupDefaultConfig()
	kDAKConfig.ReservedSlots = { }
	kDAKConfig.ReservedSlots.kReservedSlots = 2
	kDAKConfig.ReservedSlots.kMinimumSlots = 1
	kDAKConfig.ReservedSlots.kDelayedSyncTime = 3
	kDAKConfig.ReservedSlots.kDelayedKickTime = 2
	kDAKConfig.ReservedSlots.kReservePassword = ""
	kDAKConfig.ReservedSlots.kReserveSlotKickedDisconnectReason = "Kicked due to a reserved slot."
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "reservedslots", DefaultConfig = SetupDefaultConfig })