//DAK Loader Client

//No sync of plugins active to clients currently, may be useful to have at some point.
//Used to load client side scripts, may be expanded if plugin sync seems useful.
//Would allow help menus and such to be generated.
//Dont think that plugins need to be syncd, menu system designed is almost fully server side so client needs very little information. - Client should always load shared defs.

Script.Load("lua/Client.lua")
/*Script.Load("lua/DAKLoader_Shared.lua")
Script.Load("lua/DAKLoader_Class.lua")

local originalNS2PlayerOnInit
	
originalNS2PlayerOnInit = Class_ReplaceMethod("Player", "OnInitLocalClient", 
	function(self)
	
		originalNS2PlayerOnInit(self)
		if self.guivotebase == nil then
            self.guivotebase = GetGUIManager():CreateGUIScriptSingle("gui/GUIMenuBase")
        end
		
		
	end
)

local function OnClientDisconnected()
	GetGUIManager():DestroyGUIScriptSingle("gui/GUIMenuBase")
end

Event.Hook("ClientDisconnected", OnClientDisconnected)
*/