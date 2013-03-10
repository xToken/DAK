//NS2 GUI Menu Base

Script.Load("lua/GUIScript.lua")

class 'GUIMenuBase' (GUIScript)

local kFontName = "fonts/AgencyFB_medium.fnt"
local kFontScale = GUIScale(Vector(1,1,0)) * 0.7
local kTextYOffset = GUIScale(-150)
local kTextYIncrement = GUIScale(30)
local kTextXOffset = GUIScale(75)
local kDescriptionTextXOffset = GUIScale(110)
local kUpdateLifetime = 10

local function OnCommandMenuUpdate(MenuBaseUpdateMessage)
	local GUIMenuBase = GetGUIManager():GetGUIScriptSingle("gui/GUIMenuBase")
	if GUIMenuBase then
		GUIMenuBase:MenuUpdate(MenuBaseUpdateMessage)
	end
end

Client.HookNetworkMessage("GUIMenuBase", OnCommandMenuUpdate)

local function OnCommandMenuBase(parm1)
	local idNum = tonumber(parm1)
	if idNum ~= nil then
		Client.SendNetworkMessage("GUIMenuBaseSelected", { optionselected = idNum }, true)
	end
end

Event.Hook("Console_menubase", OnCommandMenuBase)

function GUIMenuBase:Initialize()
	self.headerText = GUIManager:CreateTextItem()
    self.headerText:SetAnchor(GUIItem.Left, GUIItem.Middle)
    self.headerText:SetTextAlignmentX(GUIItem.Align_Min)
    self.headerText:SetTextAlignmentY(GUIItem.Align_Center)
    self.headerText:SetPosition(Vector(kTextXOffset, kTextYOffset + (kTextYIncrement * 1), 0))
    self.headerText:SetInheritsParentAlpha(true)
    self.headerText:SetFontName(kFontName)
    self.headerText:SetScale(kFontScale)
    self.headerText:SetColor(Color(1,1,1,1))
	
	self.option1text = GUIManager:CreateTextItem()
    self.option1text:SetAnchor(GUIItem.Left, GUIItem.Middle)
    self.option1text:SetTextAlignmentX(GUIItem.Align_Center)
    self.option1text:SetTextAlignmentY(GUIItem.Align_Center)
    self.option1text:SetPosition(Vector(kTextXOffset, kTextYOffset + (kTextYIncrement * 2), 0))
    self.option1text:SetInheritsParentAlpha(true)
    self.option1text:SetFontName(kFontName)
    self.option1text:SetScale(kFontScale)
    self.option1text:SetColor(Color(1,1,1,1))
	
	self.option1desctext = GUIManager:CreateTextItem()
    self.option1desctext:SetAnchor(GUIItem.Left, GUIItem.Middle)
    self.option1desctext:SetTextAlignmentX(GUIItem.Align_Min)
    self.option1desctext:SetTextAlignmentY(GUIItem.Align_Center)
    self.option1desctext:SetPosition(Vector(kDescriptionTextXOffset, kTextYOffset + (kTextYIncrement * 2), 0))
    self.option1desctext:SetInheritsParentAlpha(true)
    self.option1desctext:SetFontName(kFontName)
    self.option1desctext:SetScale(kFontScale)
    self.option1desctext:SetColor(Color(1,1,1,1))
	
	self.option2text = GUIManager:CreateTextItem()
    self.option2text:SetAnchor(GUIItem.Left, GUIItem.Middle)
    self.option2text:SetTextAlignmentX(GUIItem.Align_Center)
    self.option2text:SetTextAlignmentY(GUIItem.Align_Center)
    self.option2text:SetPosition(Vector(kTextXOffset, kTextYOffset + (kTextYIncrement * 3), 0))
    self.option2text:SetInheritsParentAlpha(true)
    self.option2text:SetFontName(kFontName)
    self.option2text:SetScale(kFontScale)
    self.option2text:SetColor(Color(1,1,1,1))
	
	self.option2desctext = GUIManager:CreateTextItem()
    self.option2desctext:SetAnchor(GUIItem.Left, GUIItem.Middle)
    self.option2desctext:SetTextAlignmentX(GUIItem.Align_Min)
    self.option2desctext:SetTextAlignmentY(GUIItem.Align_Center)
    self.option2desctext:SetPosition(Vector(kDescriptionTextXOffset, kTextYOffset + (kTextYIncrement * 3), 0))
    self.option2desctext:SetInheritsParentAlpha(true)
    self.option2desctext:SetFontName(kFontName)
    self.option2desctext:SetScale(kFontScale)
    self.option2desctext:SetColor(Color(1,1,1,1))
	
	self.option3text = GUIManager:CreateTextItem()
    self.option3text:SetAnchor(GUIItem.Left, GUIItem.Middle)
    self.option3text:SetTextAlignmentX(GUIItem.Align_Center)
    self.option3text:SetTextAlignmentY(GUIItem.Align_Center)
    self.option3text:SetPosition(Vector(kTextXOffset, kTextYOffset + (kTextYIncrement * 4), 0))
    self.option3text:SetInheritsParentAlpha(true)
    self.option3text:SetFontName(kFontName)
    self.option3text:SetScale(kFontScale)
    self.option3text:SetColor(Color(1,1,1,1))
	
	self.option3desctext = GUIManager:CreateTextItem()
    self.option3desctext:SetAnchor(GUIItem.Left, GUIItem.Middle)
    self.option3desctext:SetTextAlignmentX(GUIItem.Align_Min)
    self.option3desctext:SetTextAlignmentY(GUIItem.Align_Center)
    self.option3desctext:SetPosition(Vector(kDescriptionTextXOffset, kTextYOffset + (kTextYIncrement * 4), 0))
    self.option3desctext:SetInheritsParentAlpha(true)
    self.option3desctext:SetFontName(kFontName)
    self.option3desctext:SetScale(kFontScale)
    self.option3desctext:SetColor(Color(1,1,1,1))
	
	self.option4text = GUIManager:CreateTextItem()
    self.option4text:SetAnchor(GUIItem.Left, GUIItem.Middle)
    self.option4text:SetTextAlignmentX(GUIItem.Align_Center)
    self.option4text:SetTextAlignmentY(GUIItem.Align_Center)
    self.option4text:SetPosition(Vector(kTextXOffset, kTextYOffset + (kTextYIncrement * 5), 0))
    self.option4text:SetInheritsParentAlpha(true)
    self.option4text:SetFontName(kFontName)
    self.option4text:SetScale(kFontScale)
    self.option4text:SetColor(Color(1,1,1,1))
	
	self.option4desctext = GUIManager:CreateTextItem()
    self.option4desctext:SetAnchor(GUIItem.Left, GUIItem.Middle)
    self.option4desctext:SetTextAlignmentX(GUIItem.Align_Min)
    self.option4desctext:SetTextAlignmentY(GUIItem.Align_Center)
    self.option4desctext:SetPosition(Vector(kDescriptionTextXOffset, kTextYOffset + (kTextYIncrement * 5), 0))
    self.option4desctext:SetInheritsParentAlpha(true)
    self.option4desctext:SetFontName(kFontName)
    self.option4desctext:SetScale(kFontScale)
    self.option4desctext:SetColor(Color(1,1,1,1))
	
	self.option5text = GUIManager:CreateTextItem()
    self.option5text:SetAnchor(GUIItem.Left, GUIItem.Middle)
    self.option5text:SetTextAlignmentX(GUIItem.Align_Center)
    self.option5text:SetTextAlignmentY(GUIItem.Align_Center)
    self.option5text:SetPosition(Vector(kTextXOffset, kTextYOffset + (kTextYIncrement * 6), 0))
    self.option5text:SetInheritsParentAlpha(true)
    self.option5text:SetFontName(kFontName)
    self.option5text:SetScale(kFontScale)
    self.option5text:SetColor(Color(1,1,1,1))
	
	self.option5desctext = GUIManager:CreateTextItem()
    self.option5desctext:SetAnchor(GUIItem.Left, GUIItem.Middle)
    self.option5desctext:SetTextAlignmentX(GUIItem.Align_Min)
    self.option5desctext:SetTextAlignmentY(GUIItem.Align_Center)
    self.option5desctext:SetPosition(Vector(kDescriptionTextXOffset, kTextYOffset + (kTextYIncrement * 6), 0))
    self.option5desctext:SetInheritsParentAlpha(true)
    self.option5desctext:SetFontName(kFontName)
    self.option5desctext:SetScale(kFontScale)
    self.option5desctext:SetColor(Color(1,1,1,1))
	
	self.footerText = GUIManager:CreateTextItem()
    self.footerText:SetAnchor(GUIItem.Left, GUIItem.Middle)
    self.footerText:SetTextAlignmentX(GUIItem.Align_Min)
    self.footerText:SetTextAlignmentY(GUIItem.Align_Center)
    self.footerText:SetPosition(Vector(kTextXOffset, kTextYOffset + (kTextYIncrement * 7), 0))
    self.footerText:SetInheritsParentAlpha(true)
    self.footerText:SetFontName(kFontName)
    self.footerText:SetScale(kFontScale)
    self.footerText:SetColor(Color(1,1,1,1))
	
	self.option1text:SetText("1: = ")
	self.option2text:SetText("2: = ")
	self.option3text:SetText("3: = ")
	self.option4text:SetText("4: = ")
	self.option5text:SetText("5: = ")
	
	self.headerText:SetIsVisible(false)
	self.option1text:SetIsVisible(false)
	self.option2text:SetIsVisible(false)
	self.option3text:SetIsVisible(false)
	self.option4text:SetIsVisible(false)
	self.option5text:SetIsVisible(false)
	self.option1desctext:SetIsVisible(false)
	self.option2desctext:SetIsVisible(false)
	self.option3desctext:SetIsVisible(false)
	self.option4desctext:SetIsVisible(false)
	self.option5desctext:SetIsVisible(false)
	self.footerText:SetIsVisible(false)
	
	self.lastupdate = nil
	self.lastupdatetime = 0
end

function GUIMenuBase:MenuUpdate(MenuBaseUpdateMessage)
	if MenuBaseUpdateMessage == nil or MenuBaseUpdateMessage.menutime == 0 then
		self:OnClose()
	else
		self.headerText:SetText(MenuBaseUpdateMessage.header)
		self.option1desctext:SetText(MenuBaseUpdateMessage.option1)
		self.option2desctext:SetText(MenuBaseUpdateMessage.option2)
		self.option3desctext:SetText(MenuBaseUpdateMessage.option3)
		self.option4desctext:SetText(MenuBaseUpdateMessage.option4)
		self.option5desctext:SetText(MenuBaseUpdateMessage.option5)
		self.footerText:SetText(MenuBaseUpdateMessage.footer)
		self.lastupdatetime = MenuBaseUpdateMessage.menutime
		self.lastupdate = MenuBaseUpdateMessage
		self:DisplayUpdate()
	end
end

function GUIMenuBase:Uninitialize()
    if self.headerText then
        GUI.DestroyItem(self.headerText)
        self.headerText = nil
    end
	if self.option1text then
        GUI.DestroyItem(self.option1text)
        self.option1text = nil
    end
	if self.option2text then
        GUI.DestroyItem(self.option2text)
        self.option2text = nil
    end
	if self.option3text then
        GUI.DestroyItem(self.option3text)
        self.option3text = nil
    end
	if self.option4text then
        GUI.DestroyItem(self.option4text)
        self.option4text = nil
    end
	if self.option5text then
        GUI.DestroyItem(self.option5text)
        self.option5text = nil
    end
	if self.option1desctext then
        GUI.DestroyItem(self.option1desctext)
        self.option1desctext = nil
    end
	if self.option2desctext then
        GUI.DestroyItem(self.option2desctext)
        self.option2desctext = nil
    end
	if self.option3desctext then
        GUI.DestroyItem(self.option3desctext)
        self.option3desctext = nil
    end
	if self.option4desctext then
        GUI.DestroyItem(self.option4desctext)
        self.option4desctext = nil
    end
	if self.option5desctext then
        GUI.DestroyItem(self.option5desctext)
        self.option5desctext = nil
    end
	if self.footerText then
        GUI.DestroyItem(self.footerText)
        self.footerText = nil
    end
end

function GUIMenuBase:DisplayUpdate()
    if self.lastupdate ~= nil then
		self.headerText:SetIsVisible(true)
		self.option1text:SetIsVisible(true)
		self.option2text:SetIsVisible(true)
		self.option3text:SetIsVisible(true)
		self.option4text:SetIsVisible(true)
		self.option5text:SetIsVisible(true)
		self.option1desctext:SetIsVisible(true)
		self.option2desctext:SetIsVisible(true)
		self.option3desctext:SetIsVisible(true)
		self.option4desctext:SetIsVisible(true)
		self.option5desctext:SetIsVisible(true)
		self.footerText:SetIsVisible(true)
    end
end

function GUIMenuBase:OnClose()
	self.headerText:SetIsVisible(false)
	self.option1text:SetIsVisible(false)
	self.option2text:SetIsVisible(false)
	self.option3text:SetIsVisible(false)
	self.option4text:SetIsVisible(false)
	self.option5text:SetIsVisible(false)
	self.option1desctext:SetIsVisible(false)
	self.option2desctext:SetIsVisible(false)
	self.option3desctext:SetIsVisible(false)
	self.option4desctext:SetIsVisible(false)
	self.option5desctext:SetIsVisible(false)
	self.footerText:SetIsVisible(false)
	self.lastupdate = nil
end

function GUIMenuBase:Update(deltaTime)
	if self.lastupdate ~= nil and self.lastupdate.menutime + kUpdateLifetime < Shared.GetTime() then
		self:OnClose()
	end
end

function GUIMenuBase:SendKeyEvent(key, down)
	
	if self.lastupdate ~= nil and self.lastupdate.inputallowed and down then
		local optselect
		if GetIsBinding(key, "Weapon1") then
			optselect = 1
		elseif GetIsBinding(key, "Weapon2") then
			optselect = 2
		elseif GetIsBinding(key, "Weapon3") then
			optselect = 3
		elseif GetIsBinding(key, "Weapon4") then
			optselect = 4
		elseif GetIsBinding(key, "Weapon5") then
			optselect = 5
		end
		if optselect then
			OnCommandMenuBase(optselect)
			self.lastupdate.inputallowed = false
			self:OnClose()
			return true
		end
	end
	
end    

//GUIMenuBase
//local kMenuBaseUpdateMessage = 
//{
//	header         		= string.format("string (%d)", kMaxMenuStringLength),
//	option1         	= string.format("string (%d)", kMaxMenuStringLength),
//	option2        		= string.format("string (%d)", kMaxMenuStringLength),
//	option3        		= string.format("string (%d)", kMaxMenuStringLength),
//	option4        		= string.format("string (%d)", kMaxMenuStringLength),
//	option5         	= string.format("string (%d)", kMaxMenuStringLength),
//	footer         		= string.format("string (%d)", kMaxMenuStringLength),
//  inputallowed		= "boolean",
//	menutime   	  		= "time"
//}