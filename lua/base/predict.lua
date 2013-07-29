//DAK loader Predict

/*
DAK = { }
DAK.__index = DAK
Script.Load("lua/base/class.lua")

local init
local originalNS2SharedGetTime

originalNS2SharedGetTime = DAK:Class_ReplaceMethod("Shared", "GetTime", 
	function()
		local localPlayer = Client.GetLocalPlayer()
		return (originalNS2SharedGetTime() - (localPlayer.timeadjustment or 0))	
	end
)

local function OnPredictLoaded()
	if not init then
		Shared.LinkClassToMap("Player", Player.kMapName, {timeadjustment = "time", gamepaused = "boolean"})
		init = true
	end
end

Event.Hook("MapLoadEntity", OnPredictLoaded)
*/