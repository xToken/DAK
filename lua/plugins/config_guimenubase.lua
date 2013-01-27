//GUIMenuBase config

kDAKRevisions["guimenubase"] = "0.1.126a"

local function SetupDefaultConfig()
	kDAKConfig.GUIMenuBase = { }
	kDAKConfig.GUIMenuBase.kMenuUpdateRate = 2
end

DAKRegisterEventHook("kDAKPluginDefaultConfigs", {PluginName = "guimenubase", DefaultConfig = SetupDefaultConfig })