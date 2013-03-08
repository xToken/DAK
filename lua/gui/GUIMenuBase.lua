//NS2 GUI Menu Base

Script.Load("lua/GUIScript.lua")

class 'GUIMenuBase' (GUIScript)

local kFontName = "fonts/AgencyFB_medium.fnt"
local kFontScale = GUIScale(Vector(1,1,0)) * 0.7
local kBgSize = GUIScale(Vector(450, 150, 0))
local kTextYOffset = GUIScale(10)
local kTextYIncrement = GUIScale(5)
local kTextXOffset = GUIScale(0)
local kDescriptionTextXOffset = GUIScale(15)
local kUpdateLifetime = 10
local kBgPosition = Vector(kBgSize.x, kBgSize.y, 0)
local kTexture = "ui/readyroomorders.dds"
local kBackgroundPixelCoords = { 0, 0, 230, 50 }

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
    self.mainmenu = GUIManager:CreateGraphicItem()
    self.mainmenu:SetSize(kBgSize)
    self.mainmenu:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.mainmenu:SetPosition(kBgPosition)
    self.mainmenu:SetTexture(kTexture)
    self.mainmenu:SetTexturePixelCoordinates(unpack(kBackgroundPixelCoords))
    self.mainmenu:SetColor(Color(1,1,1,0))
	
	self.headerText = GUIManager:CreateTextItem()
    self.headerText:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.headerText:SetTextAlignmentX(GUIItem.Align_Center)
    self.headerText:SetTextAlignmentY(GUIItem.Align_Min)
    self.headerText:SetPosition(Vector(kTextXOffset, kTextYOffset + (kTextYIncrement * 1), 0))
    self.headerText:SetInheritsParentAlpha(true)
    self.headerText:SetFontName(kFontName)
    self.headerText:SetScale(kFontScale)
    self.headerText:SetColor(Color(1,1,1,1))
	
	self.option1text = GUIManager:CreateTextItem()
    self.option1text:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.option1text:SetTextAlignmentX(GUIItem.Align_Center)
    self.option1text:SetTextAlignmentY(GUIItem.Align_Min)
    self.option1text:SetPosition(Vector(kTextXOffset, kTextYOffset + (kTextYIncrement * 2), 0))
    self.option1text:SetInheritsParentAlpha(true)
    self.option1text:SetFontName(kFontName)
    self.option1text:SetScale(kFontScale)
    self.option1text:SetColor(Color(1,1,1,1))
	
	self.option1desctext = GUIManager:CreateTextItem()
    self.option1desctext:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.option1desctext:SetTextAlignmentX(GUIItem.Align_Center)
    self.option1desctext:SetTextAlignmentY(GUIItem.Align_Min)
    self.option1desctext:SetPosition(Vector(kDescriptionTextXOffset, kTextYOffset + (kTextYIncrement * 2), 0))
    self.option1desctext:SetInheritsParentAlpha(true)
    self.option1desctext:SetFontName(kFontName)
    self.option1desctext:SetScale(kFontScale)
    self.option1desctext:SetColor(Color(1,1,1,1))
	
	self.option2text = GUIManager:CreateTextItem()
    self.option2text:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.option2text:SetTextAlignmentX(GUIItem.Align_Center)
    self.option2text:SetTextAlignmentY(GUIItem.Align_Min)
    self.option2text:SetPosition(Vector(kTextXOffset, kTextYOffset + (kTextYIncrement * 3), 0))
    self.option2text:SetInheritsParentAlpha(true)
    self.option2text:SetFontName(kFontName)
    self.option2text:SetScale(kFontScale)
    self.option2text:SetColor(Color(1,1,1,1))
	
	self.option2desctext = GUIManager:CreateTextItem()
    self.option2desctext:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.option2desctext:SetTextAlignmentX(GUIItem.Align_Center)
    self.option2desctext:SetTextAlignmentY(GUIItem.Align_Min)
    self.option2desctext:SetPosition(Vector(kDescriptionTextXOffset, kTextYOffset + (kTextYIncrement * 3), 0))
    self.option2desctext:SetInheritsParentAlpha(true)
    self.option2desctext:SetFontName(kFontName)
    self.option2desctext:SetScale(kFontScale)
    self.option2desctext:SetColor(Color(1,1,1,1))
	
	self.option3text = GUIManager:CreateTextItem()
    self.option3text:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.option3text:SetTextAlignmentX(GUIItem.Align_Center)
    self.option3text:SetTextAlignmentY(GUIItem.Align_Min)
    self.option3text:SetPosition(Vector(0, kTextYOffset + (kTextYIncrement * 4), 0))
    self.option3text:SetInheritsParentAlpha(true)
    self.option3text:SetFontName(kFontName)
    self.option3text:SetScale(kFontScale)
    self.option3text:SetColor(Color(1,1,1,1))
	
	self.option3desctext = GUIManager:CreateTextItem()
    self.option3desctext:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.option3desctext:SetTextAlignmentX(GUIItem.Align_Center)
    self.option3desctext:SetTextAlignmentY(GUIItem.Align_Min)
    self.option3desctext:SetPosition(Vector(0, kDescriptionTextXOffset + (kTextYIncrement * 4), 0))
    self.option3desctext:SetInheritsParentAlpha(true)
    self.option3desctext:SetFontName(kFontName)
    self.option3desctext:SetScale(kFontScale)
    self.option3desctext:SetColor(Color(1,1,1,1))
	
	self.option4text = GUIManager:CreateTextItem()
    self.option4text:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.option4text:SetTextAlignmentX(GUIItem.Align_Center)
    self.option4text:SetTextAlignmentY(GUIItem.Align_Min)
    self.option4text:SetPosition(Vector(0, kTextYOffset + (kTextYIncrement * 5), 0))
    self.option4text:SetInheritsParentAlpha(true)
    self.option4text:SetFontName(kFontName)
    self.option4text:SetScale(kFontScale)
    self.option4text:SetColor(Color(1,1,1,1))
	
	self.option4desctext = GUIManager:CreateTextItem()
    self.option4desctext:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.option4desctext:SetTextAlignmentX(GUIItem.Align_Center)
    self.option4desctext:SetTextAlignmentY(GUIItem.Align_Min)
    self.option4desctext:SetPosition(Vector(0, kDescriptionTextXOffset + (kTextYIncrement * 5), 0))
    self.option4desctext:SetInheritsParentAlpha(true)
    self.option4desctext:SetFontName(kFontName)
    self.option4desctext:SetScale(kFontScale)
    self.option4desctext:SetColor(Color(1,1,1,1))
	
	self.option5text = GUIManager:CreateTextItem()
    self.option5text:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.option5text:SetTextAlignmentX(GUIItem.Align_Center)
    self.option5text:SetTextAlignmentY(GUIItem.Align_Min)
    self.option5text:SetPosition(Vector(0, kTextYOffset + (kTextYIncrement * 6), 0))
    self.option5text:SetInheritsParentAlpha(true)
    self.option5text:SetFontName(kFontName)
    self.option5text:SetScale(kFontScale)
    self.option5text:SetColor(Color(1,1,1,1))
	
	self.option5desctext = GUIManager:CreateTextItem()
    self.option5desctext:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.option5desctext:SetTextAlignmentX(GUIItem.Align_Center)
    self.option5desctext:SetTextAlignmentY(GUIItem.Align_Min)
    self.option5desctext:SetPosition(Vector(0, kDescriptionTextXOffset + (kTextYIncrement * 6), 0))
    self.option5desctext:SetInheritsParentAlpha(true)
    self.option5desctext:SetFontName(kFontName)
    self.option5desctext:SetScale(kFontScale)
    self.option5desctext:SetColor(Color(1,1,1,1))
	
	self.footerText = GUIManager:CreateTextItem()
    self.footerText:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.footerText:SetTextAlignmentX(GUIItem.Align_Center)
    self.footerText:SetTextAlignmentY(GUIItem.Align_Min)
    self.footerText:SetPosition(Vector(0, kTextYOffset + (kTextYIncrement * 7), 0))
    self.footerText:SetInheritsParentAlpha(true)
    self.footerText:SetFontName(kFontName)
    self.footerText:SetScale(kFontScale)
    self.footerText:SetColor(Color(1,1,1,1))
	
    self.mainmenu:AddChild(self.headerText)
	self.mainmenu:AddChild(self.option1text)
	self.mainmenu:AddChild(self.option2text)
	self.mainmenu:AddChild(self.option3text)
	self.mainmenu:AddChild(self.option4text)
	self.mainmenu:AddChild(self.option5text)
	self.mainmenu:AddChild(self.option1desctext)
	self.mainmenu:AddChild(self.option2desctext)
	self.mainmenu:AddChild(self.option3desctext)
	self.mainmenu:AddChild(self.option4desctext)
	self.mainmenu:AddChild(self.option5desctext)
	self.mainmenu:AddChild(self.footerText)
	
	self.mainmenu:SetIsVisible(false)
	self.lastupdate = nil
	self.lastupdatetime = 0
end

function GUIMenuBase:MenuUpdate(MenuBaseUpdateMessage)
	if MenuBaseUpdateMessage == nil then
		self:OnClose()
	else
		self.headerText:SetText(MenuBaseUpdateMessage.header)
		self.option1text:SetText(MenuBaseUpdateMessage.option1)
		self.option2text:SetText(MenuBaseUpdateMessage.option2)
		self.option3text:SetText(MenuBaseUpdateMessage.option3)
		self.option4text:SetText(MenuBaseUpdateMessage.option4)
		self.option5text:SetText(MenuBaseUpdateMessage.option5)
		self.option1desctext:SetText(MenuBaseUpdateMessage.option1desc)
		self.option2desctext:SetText(MenuBaseUpdateMessage.option2desc)
		self.option3desctext:SetText(MenuBaseUpdateMessage.option3desc)
		self.option4desctext:SetText(MenuBaseUpdateMessage.option4desc)
		self.option5desctext:SetText(MenuBaseUpdateMessage.option5desc)
		self.footerText:SetText(MenuBaseUpdateMessage.footer)
		self.lastupdatetime = MenuBaseUpdateMessage.menutime
		self.lastupdate = MenuBaseUpdateMessage
		Print(ToString(self.lastupdatetime .. " - " .. MenuBaseUpdateMessage.option1))
		self:DisplayUpdate()
	end
end

function GUIMenuBase:Uninitialize()
    if self.mainmenu then
        GUI.DestroyItem(self.mainmenu)
        self.mainmenu = nil
    end
end

function GUIMenuBase:DisplayUpdate()
    if self.lastupdate ~= nil then
        self.mainmenu:SetIsVisible(true)
		Print("Displayed")
    end
end

function GUIMenuBase:OnClose()
	self.mainmenu:SetIsVisible(false)
	Print("Hidden")
	self.lastupdate = nil
end

function GUIMenuBase:Update(deltaTime)
	if self.lastupdate ~= nil and self.lastupdate.menutime + kUpdateLifetime < Shared.GetTime() then
		self:OnClose()
	end
end

function GUIMenuBase:SendKeyEvent(key, down)
	
	Print("Override Test")
	if self.lastupdate ~= nil then
		Print(ToString(self.lastupdate.inputallowed))
	end
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
			return true
		end
	end
	
end    

//GUIMenuBase
//local kMenuBaseUpdateMessage = 
//{
//	header         		= string.format("string (%d)", kMaxMenuStringLength),
//	option1         	= string.format("string (%d)", kMaxMenuStringLength),
//	option1desc         = string.format("string (%d)", kMaxMenuStringLength),
//	option2        		= string.format("string (%d)", kMaxMenuStringLength),
//	option2desc         = string.format("string (%d)", kMaxMenuStringLength),
//	option3        		= string.format("string (%d)", kMaxMenuStringLength),
//	option3desc         = string.format("string (%d)", kMaxMenuStringLength),
//	option4        		= string.format("string (%d)", kMaxMenuStringLength),
//	option4desc         = string.format("string (%d)", kMaxMenuStringLength),
//	option5         	= string.format("string (%d)", kMaxMenuStringLength),
//	option5desc         = string.format("string (%d)", kMaxMenuStringLength),
//	footer         		= string.format("string (%d)", kMaxMenuStringLength),
//  inputallowed		= "boolean",
//	menutime   	  		= "time"
//}

