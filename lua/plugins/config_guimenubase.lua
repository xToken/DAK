//GUIMenuBase config

kDAKRevisions["guimenubase"] = "0.1.203a"

local function SetupDefaultConfig()
	kDAKConfig.GUIMenuBase = { }
	kDAKConfig.GUIMenuBase.kMenuUpdateRate = 5
end

DAKRegisterEventHook("kDAKPluginDefaultConfigs", {PluginName = "guimenubase", DefaultConfig = SetupDefaultConfig })