//GUIVoteBase config

kDAKRevisions["GUIVoteBase"] = 1.0

local function SetupDefaultConfig(Save)
	if kDAKConfig.GUIVoteBase == nil then
		kDAKConfig.GUIVoteBase = { }
	end
	kDAKConfig.GUIVoteBase.kVoteUpdateRate = 2
	if Save then
		SaveDAKConfig()
	end
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "GUIVoteBase", DefaultConfig = function(Save) SetupDefaultConfig(Save) end })