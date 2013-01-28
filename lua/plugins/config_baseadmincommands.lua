//baseadmincommands default config

kDAKRevisions["baseadmincommands"] = "0.1.128a"
local function SetupDefaultConfig()
	kDAKConfig.BaseAdminCommands = { }
	kDAKConfig.BaseAdminCommands.kMapChangeDelay = 5
	kDAKConfig.BaseAdminCommands.kUpdateDelay = 60
	kDAKConfig.BaseAdminCommands.kBansQueryURL = ""
	kDAKConfig.BaseAdminCommands.kBansQueryTimeout = 10
	kDAKConfig.BaseAdminCommands.kBanSubmissionURL = ""
	kDAKConfig.BaseAdminCommands.kUnBanSubmissionURL = ""
	kDAKConfig.BaseAdminCommands.kCryptographyKey = ""
	kDAKConfig.BaseAdminCommands.kBlacklistedCommands = { "Console_sv_kick", "Console_sv_eject", "Console_sv_switchteam", "Console_sv_randomall", "Console_sv_rrall", "Console_sv_reset",
															"Console_sv_changemap", "Console_sv_statusip", "Console_sv_status", "Console_sv_say", "Console_sv_tsay", "Console_sv_psay", 
															"Console_sv_slay", "Console_sv_password", "Console_sv_ban", "Console_sv_unban", "Console_sv_listbans"  }
end

DAKRegisterEventHook("kDAKPluginDefaultConfigs", {PluginName = "baseadmincommands", DefaultConfig = SetupDefaultConfig })