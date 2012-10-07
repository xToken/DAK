//GUIbase config

kDAKRevisions["GUIBase"] = 1.0
local function SetupDefaultConfig()
	kDAKConfig.GUIBase = { }
	kDAKConfig.GUIBase.kEnabled = true
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "GUIBase", DefaultConfig = function() SetupDefaultConfig() end })