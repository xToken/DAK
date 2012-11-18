//unstuck config

kDAKRevisions["Unstuck"] = 1.0
local function SetupDefaultConfig(Save)
	if kDAKConfig.Unstuck == nil then
		kDAKConfig.Unstuck = { }
	end
	kDAKConfig.Unstuck.kEnabled = true
	kDAKConfig.Unstuck.kMinimumWaitTime = 5
	kDAKConfig.Unstuck.kTimeBetweenUntucks = 30
	if Save then
		SaveDAKConfig()
	end
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "Unstuck", DefaultConfig = function(Save) SetupDefaultConfig(Save) end })

if kDAKConfig.Unstuck == nil then
	SetupDefaultConfig(false)
end
