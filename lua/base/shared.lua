//DAK loader/Base Config

//Shared Defs

local kMaxMenuStringLength = 75

local kMenuBaseUpdateMessage = 
{
	header         		= string.format("string (%d)", kMaxMenuStringLength),
	option1         	= string.format("string (%d)", kMaxMenuStringLength),
	option2        		= string.format("string (%d)", kMaxMenuStringLength),
	option3        		= string.format("string (%d)", kMaxMenuStringLength),
	option4        		= string.format("string (%d)", kMaxMenuStringLength),
	option5         	= string.format("string (%d)", kMaxMenuStringLength),
	option6         	= string.format("string (%d)", kMaxMenuStringLength),
	option7         	= string.format("string (%d)", kMaxMenuStringLength),
	option8         	= string.format("string (%d)", kMaxMenuStringLength),
	option9         	= string.format("string (%d)", kMaxMenuStringLength),
	option10         	= string.format("string (%d)", kMaxMenuStringLength),
	footer         		= string.format("string (%d)", kMaxMenuStringLength),
	inputallowed		= "boolean",
	menutime   	  		= "time"
}

Shared.RegisterNetworkMessage("GUIMenuBase", kMenuBaseUpdateMessage)

local kMenuBaseMessage =
{
	optionselected = "integer"
}

Shared.RegisterNetworkMessage("GUIMenuBaseSelected", kMenuBaseMessage)