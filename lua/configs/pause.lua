//afkkick default config

DAK.revisions["pause"] = "0.1.211a"

local function SetupDefaultConfig()
	local DefaultConfig = { }
	DefaultConfig.kPauseChangeDelay = 5
	DefaultConfig.kPauseMaxPauses = 3
	DefaultConfig.kPausedReadyNotificationDelay = 10
	DefaultConfig.kPausedMaxDuration = 0
	return DefaultConfig
end

DAK:RegisterEventHook("PluginDefaultConfigs", {PluginName = "pause", DefaultConfig = SetupDefaultConfig })

local function SetupDefaultLanguageStrings()
	local DefaultLangStrings = { }
	DefaultLangStrings["PauseResumeMessage"] 					= "Game Resumed.  Team %s has %s pauses remaining"
	DefaultLangStrings["PausePausedMessage"] 					= "Game Paused."
	DefaultLangStrings["PauseWarningMessage"] 					= "Game will %s in %.1f seconds."
	DefaultLangStrings["PauseResumeWarningMessage"] 			= "Game will automatically resume in %.1f seconds."
	DefaultLangStrings["PausePlayerMessage"] 					= "%s executed a game pause."
	DefaultLangStrings["PauseTeamReadiedMessage"] 				= "%s readied for Team %s, resuming game."
	DefaultLangStrings["PauseTeamReadyMessage"] 				= "%s readied for Team %s, waiting for Team %s."
	DefaultLangStrings["PauseTeamReadyPeriodicMessage"] 		= "Team %s is ready, waiting for Team %s."
	DefaultLangStrings["PauseNoTeamReadyMessage"] 				= "No team is ready to resume, type unpause in console to ready for your team."
	DefaultLangStrings["PauseCancelledMessage"] 				= "Game Pause Cancelled."
	DefaultLangStrings["PauseTooManyPausesMessage"] 			= "Your team is out of pauses."
	return DefaultLangStrings
end

DAK:RegisterEventHook("PluginDefaultLanguageDefinitions", SetupDefaultLanguageStrings)