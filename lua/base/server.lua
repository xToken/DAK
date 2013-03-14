//DAK loader/Base Config

if Server then

	//Going to finally move to a single global variable DAK, with functions being nested under that.  Should have done this originally TBH.
	DAK = { }

	DAK.events = { }							//List used to track events, used by event hook system.
	DAK.scriptoverrides = { }					//List used to track script replacements/blocks.
	DAK.timedcalledbacks = { }					//List used to track timed calledbacks.
	DAK.activemoddedclients = { }				//Tracks what clients have ack'd that they have the client side workshop mod.
	DAK.runningmenus = { }						//List of currently open client menus.
	DAK.networkmessagefunctions = { }			//List used to track network message functions, can be used to replace functions raised on network message recieving.
	DAK.registerednetworkmessages = { }			//List used to track network messages to their corresponding functions.
	DAK.chatcommands = { }						//List of chat commands.
	DAK.gameid = { }							//Used to track client joins for game IDs
	DAK.gaggedplayers = { }						//Used to track gagged clients

	DAK.version = "0.1.313b"
	
	Script.Load("lua/dkjson.lua")
	Script.Load("lua/base/class.lua")
	Script.Load("lua/base/globals.lua")
	Script.Load("lua/base/configfileutility.lua")
	Script.Load("lua/base/serveradmin.lua")
	Script.Load("lua/base/config.lua")
	Script.Load("lua/base/settings.lua")
	Script.Load("lua/base/eventhooks.lua")
	Script.Load("lua/base/serveradmincommands.lua")
	Script.Load("lua/base/language.lua")
	Script.Load("lua/base/pluginloader.lua")
	
end