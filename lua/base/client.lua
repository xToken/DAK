//DAK loader Client

//No sync of plugins active to clients currently, may be useful to have at some point.
//Used to load client side scripts, may be expanded if plugin sync seems useful.
//Would allow help menus and such to be generated.
//Dont think that plugins need to be syncd, menu system designed is almost fully server side so client needs very little information. - Client should always load shared defs.

local MenuMessageTag = "#^DAK"
local WebViewMessageTag = "#&DAK"
local MenusRegistered = false
local webView = nil

local function OnClientLoaded()
	if guimenubase == nil then
		guimenubase = GetGUIManager():CreateGUIScriptSingle("gui/GUIMenuBase")
	end
end

Event.Hook("LoadComplete", OnClientLoaded)

local function OnUpdateClient()  
	if not MenusRegistered then  
		Shared.ConsoleCommand("registerclientmenus")  
		MenusRegistered = true  
	end  
end

Event.Hook("UpdateClient", OnUpdateClient)

local function OnClientDisconnected()
	if guimenubase ~= nil then
		GetGUIManager():DestroyGUIScriptSingle("gui/GUIMenuBase")
	end
end

Event.Hook("ClientDisconnected", OnClientDisconnected)

local originalNS2PlayerGetCameraViewCoordsOverride
originalNS2PlayerGetCameraViewCoordsOverride = Class_ReplaceMethod("Player", "GetCameraViewCoordsOverride", 
	function(self, cameraCoords)

		if self.countingDown and self:GetGameStarted() then
			return cameraCoords
		else
			return originalNS2PlayerGetCameraViewCoordsOverride(self, cameraCoords)
		end
		
	end
)
local originalNS2PlayerGetDrawWorld
originalNS2PlayerGetDrawWorld = Class_ReplaceMethod("Player", "GetDrawWorld", 
	function(self, isLocal)

		if self.countingDown and self:GetGameStarted() then
			return not self:GetIsLocalPlayer() or self:GetIsThirdPerson()
		else
			return originalNS2PlayerGetDrawWorld(self, isLocal)
		end
		
	end
)

local originalNS2GUIWebViewSendKeyEvent
originalNS2GUIWebViewSendKeyEvent = Class_ReplaceMethod("GUIWebView", "SendKeyEvent", 
	function(self, key, down, amount)

		if not originalNS2GUIWebViewSendKeyEvent(self, key, down, amount) then
			return Player.SendKeyEvent(self, key, down)
		else
			return true
		end
		
	end
)

local function MenuUpdate(Message)
	local GUIMenuBase = GetGUIManager():GetGUIScriptSingle("gui/GUIMenuBase")
	if GUIMenuBase then
		GUIMenuBase:MenuUpdate(Message)
	end
end

local function OpenWebView(Message)
	if webView then
        GetGUIManager():DestroyGUIScript(webView)
    end
    webView = GetGUIManager():CreateGUIScript("GUIWebView")
    webView:LoadUrl(Message, Client.GetScreenWidth() * 0.8, Client.GetScreenHeight() * 0.8)
    webView:DisableMusic()
    webView:GetBackground():SetAnchor(GUIItem.Middle, GUIItem.Center)
    webView:GetBackground():SetPosition(-webView:GetBackground():GetSize() / 2)
    webView:GetBackground():SetLayer(kGUILayerMainMenuWeb)
    webView:GetBackground():SetIsVisible(true)
end

local function OnServerAdminPrint(messageTable)
	if messageTable ~= nil and messageTable.message ~= nil then
		if string.sub(messageTable.message, 0, string.len(MenuMessageTag)) == MenuMessageTag then
			MenuUpdate(string.sub(messageTable.message, string.len(MenuMessageTag) + 1))
		elseif string.sub(messageTable.message, 0, string.len(WebViewMessageTag)) == WebViewMessageTag then
			//OpenWebView(string.sub(messageTable.message, string.len(WebViewMessageTag) + 1))
		else
			Shared.Message(messageTable.message)
		end
	end
end

Client.HookNetworkMessage("ServerAdminPrint", OnServerAdminPrint)