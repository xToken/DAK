//GUIMenuBase config

kDAKRevisions["guimenubase"] = "0.1.131a"

local function SetupDefaultConfig()
	kDAKConfig.GUIMenuBase = { }
	kDAKConfig.GUIMenuBase.kMenuUpdateRate = 5
end

DAKRegisterEventHook("kDAKPluginDefaultConfigs", {PluginName = "guimenubase", DefaultConfig = SetupDefaultConfig })