//GUIMenuBase config

kDAKRevisions["GUIMenuBase"] = "0.1.116a"

local function SetupDefaultConfig(Save)
	if kDAKConfig.GUIMenuBase == nil then
		kDAKConfig.GUIMenuBase = { }
	end
	kDAKConfig.GUIMenuBase.kVoteUpdateRate = 2
	if Save then
		SaveDAKConfig()
	end
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "GUIMenuBase", DefaultConfig = SetupDefaultConfig })