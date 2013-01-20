//GUIMenuBase config

kDAKRevisions["guimenubase"] = "0.1.119a"

local function SetupDefaultConfig()
	kDAKConfig.GUIMenuBase = { }
	kDAKConfig.GUIMenuBase.kMenuUpdateRate = 2
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "guimenubase", DefaultConfig = SetupDefaultConfig })