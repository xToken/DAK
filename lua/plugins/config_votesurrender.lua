//votesurrender config

kDAKRevisions["VoteSurrender"] = 1.2
local function SetupDefaultConfig(Save)
	if kDAKConfig.VoteSurrender == nil then
		kDAKConfig.VoteSurrender = { }
	end
	kDAKConfig.VoteSurrender.kEnabled = true
	kDAKConfig.VoteSurrender.kVoteSurrenderMinimumPercentage = 60
	kDAKConfig.VoteSurrender.kVoteSurrenderVotingTime = 120
	kDAKConfig.VoteSurrender.kVoteSurrenderAlertDelay = 20
	if Save then
		SaveDAKConfig()
	end
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "VoteSurrender", DefaultConfig = function(Save) SetupDefaultConfig(Save) end })

if kDAKConfig.VoteSurrender == nil then
	SetupDefaultConfig(false)
end
