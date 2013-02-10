//DAK loader/Base Config

DAK.settings = nil 							//Global variable storing all settings for mods

local SettingsFileName = "config://DAKSettings.json"

local function LoadDAKSettings()
	local SettingsFile
	SettingsFile = io.open(SettingsFileName, "r")
	if SettingsFile then
		Shared.Message("Loading DAK settings.")
		DAK.settings = json.decode(SettingsFile:read("*all"))
		SettingsFile:close()
	end
	if DAK.settings == nil then
		DAK.settings = { }
	end
end

LoadDAKSettings()

function DAK:SaveSettings()

	local SettingsFile = io.open(SettingsFileName, "w+")
	if SettingsFile then
		SettingsFile:write(json.encode(DAK.settings, { indent = true, level = 1 }))
		SettingsFile:close()
	end

end

//Reset Settings file
local function ResetDAKSetting(client, setting)

	if setting ~= nil then
		DAK.settings[setting] = nil
	else
		setting = "All"
		for k, v in pairs(DAK.settings) do
			if (type(v) == "table") then
				DAK.settings[k] = { }
			else
				DAK.settings[k] = nil
			end
		end
	end
	
	DAK:SaveSettings()

	if client ~= nil then 
		ServerAdminPrint(client, string.format("Setting %s cleared.", setting))
		local player = client:GetControllingPlayer()
		if player ~= nil then
			PrintToAllAdmins("sv_resetsettings", client, " " .. setting)
		end
	end
end

DAK:CreateServerAdminCommand("Console_sv_resetsettings", ResetDAKSetting, "<optional setting name> Resets specified setting, or all DAK settings.")