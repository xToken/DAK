//NS2 Base GUI Implementation

if kDAKConfig and kDAKConfig.GUIBase and kDAKConfig.GUIBase.kEnabled then

	
elseif kDAKConfig and not kDAKConfig.GUIBase then
	
	DAKGenerateDefaultDAKConfig("GUIBase")

end

Shared.Message("GUIBase Loading Complete")