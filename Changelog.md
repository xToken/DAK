//Going to start tracking changes made better here - GitHub offers all the code tracking needed, just need to track what those changes are supposed to fix, along with better versioning.

## v0.2.0813a
- Added support for new server side rates.
- Also included fix for afk players being randomed.

## v0.2.0216a
- Fixed rare error with menus system.

## v0.1.1105a
- Added support for webadmin reserve slots, fixed error.

## v0.1.1014a
- Had to add replaced file to account for changes made in B258.

## v0.1.921a
- Added support for official reserve slot system, complete with tags and also new connection event.
- Fixed potential issue with ban reasons being lost.

## v0.1.729a
- Fixed issues with variadic function changes when LuaJIT was introduced.
- Added sv_reserveslots command to list number of reserve slots configured on server.

## v0.1.621a
- Fixed some timing bugs and start cancellation bugs with tournamentmode plugin.
- Added ability to set spawn locations in tournamentmode plugin.

## v0.1.617b
- Removed all instances of player:GetClient() as it may no longer be working as intended

## v0.1.617a
- Another attempt at fixing player in client list.

## v0.1.616b
- Fixed issue preventing client checks from working.

## v0.1.616a
- Fixed issue with logging dates being incorrect.
- Added code to prevent errors with invalid clients.
- Fixed issue with code change in base NS2 mod loading which prevented menus from functioning.

## v0.1.610a
- Fixed issue with language escape characters on beta NS2 build.
- Hopefully fixed some issues with randomvotes, added in basic GUI to random vote.

## v0.1.524a
- Fixed issue with mapvote menu
- Added menu option to random vote
- Added mapchange menu to DAK menu
- Added adminsNS2ID to ban commands
- Added some config options for randomvotes
- Not released.

## v0.1.507a
- Fixed up some issues with webbans, cleaned up code.
- Fixed some issues with random plugin.
- Tested some client side code for webpage MOTD, still needs work.
- Removed config setting for client side menus.

## v0.1.430a
- Fixed issue with scores resetting.

## v0.1.427a
- Removed Duplicate TimeStamp in DAK:ForAllAdmins.
- Corrected issues with surrender vote cancellation/starting.
- Reworked random plugin slightly to clean it up and hopefully resolve an issue with map changes breaking it.
- Removed block on RTV automatic map change.

## v0.1.423a
- Fixed error in DAK:ForAllPlayers.
- Changed enhanced logging to use global function.
- Removed debug assert from mapcycle.

## v0.1.420a
- Switched back from table.remove where applicable.
- Fixed issue with GetClientList
- Changed client side load method.
- Logging fixes for structure creation and researches.

## v0.1.417a
- Corrected issue with bans, now also allow for bans by steamID.
- Corrected issue with VerifyClient function.
- Corrected issue with GUIMenus.
- Corrected issue with confirmation menus.

## v0.1.416a
- Renamed many key functions to align with recent changes regarding NS2 and Steam IDs.
- Added new functions for NS2IDs, left original functions in place to maintain compatibility.
- Plan to adjust SteamID functions to only check for SteamID - there are times where these checks need to be seperate, and its important for more correct obtaining of players.
	There are many possible exploits currently regarding names and IDs and bans - want to make sure to minimize this via careful player lookups.
- Renamed many local and function level variables to be more correct regarding what they contain (NS2 vs Player vs Steam IDs).
- Added block to hopefully prevent reloading looping in pause plugin.
- Added valid teams config option to afk plugin.

## v0.1.415a
- Split Globals.lua into smaller files.
- Corrected issue with pause plugin preventing medpacks.
- Added saftey to eventhook execution.
- Corrected issue with Random plugin.
- Updated tournamentmode messages.

## v0.1.408a
- Fixed an issue with GetPlayerMatchingSteamId.

## v0.1.407a
- Fixed an issue with GetPlayerMatching.

## v0.1.406a
- Added in use of GetReadableSteamID function to sv_status.
- Added check of real steamID when looking for a player by ID, also changed SDK functions for Get*BySteamID to Get*ByNS2ID, and added ones for the real SteamID also.

## v0.1.404a
- Corrected issues with commbans plugin
- Corrected missing then statement in serverredirect plugin.

## v0.1.331a
- Corrected issues with multiple pauses at once.
- Corrected issues with pages for menu system.
- Corrected issues with inputallowed for menu system.

## v0.1.328a
- Removed unneeded hook.

## v0.1.325a
- Created global mainmenu system for all plugins.
- Added simple confirmation menu extension.
- Added dakmodmenu command.
- Adjusted some of the voterandom functions to be clearer.
- Lowered update rate of Reserveslot password.
- Fixes to pause plugin logic

## v0.1.320a
- Fixed issue with scores not resetting on round start.

## v0.1.314a
- Fixed issue with webadmin bans.

## v0.1.313b
- Removed remaining parts of old GUI system (GUIMenuBase plugin).  
- Integrated GUI system into the core of DAK.
- Removed custom network message for GUI, instead uses client side mod (or workshop DAK) which lets server know its installed on a per client basis.
- Moved menu system response to console command instead of network message.
- Corrected possible issue which could allow automapcycle to register multiple events.
- Added sv_debugplayershuffle which will print information about why players were not shuffled.

## v0.1.313a
- Corrected issues with client connection time tracking causing asserts for reserve slots and sv_status.
- Added binds to GUI for slots 6-10
- Disabled config file loading/unloading messages.
- Added DAK:GetSteamIdMatchingClient and DAK:GetSteamIdMatchingPlayer.
- Changed mapvote to take full advantage of GUI if enabled.
- Changed GUI system to use steamID for tracking instead of gameIds.
- Added slots 6-10 for GUI network message.

## v0.1.311a
- Added timed callbacks to API - will be called each interval passed if true is returned.  A number can be returned to adjust interval, and false/nil can be returned to stop execution.  The callback args can also be updated.

## v0.1.309a
- Adjusted AFK Plugin to only flag players as afk after 30 seconds (instead of instantly)
- Corrected assert from ShuffledPlayerList function
- Removed experimental MOTD command.
- Removed parts of Revision code.
- Finalized basic GUI implementation, now it actually works!
- Corrected issues with predict VM.

## v0.1.307a
- Updated tournamentmode plugin to allow restarts of round in the first 2 minutes (configurable).
- Corrected issue with ban reasons being lost, and also with ids sometimes being indexed as strings.

## v0.1.306a
- Changed bans back to using old file (BannedPlayers.json).  DAK will still convert the list to the ID indexed format, but then converts it back to save.  Will revisit this 
in the future if the additional properties get added/are requested.
- Corrected issue with unban indexing on a string and not a number.

## v0.1.305b
- Hotfix to prevent first time config generation assert message.

## v0.1.305a
- Added new DAKBannedPlayers.json file, will automatically convert old file and leave intact to prevent issues.
- Adjusted reserveslot plugin to use server functions to determine max and current players, hoping for greater accuracy from these.
- Changed reserveslot plugin to reapply the password each periodic scan or when the player count changes.
- Added the ability to block or replace the loading of a script file with another file.

## v0.1.302a
- Updated bans and many other playerID arrays to be NS2ID indexed.  Included conversion function for old arrays.
- Added some events to pause plugin for new features.
- Added descent to default mapcycle
- Added config utility file to simply config saves/loads.
- Corrected issues with default and custom languages 

## v0.1.223a
- Corrected issue with FriendlyFire override not working, also issue with friendlyfire % not working.
- Updated pause plugin to correct all remaining known issues.
- Adjusted reserveslot plugin to work better with new, earlier event hooks. 
- Corrected issues with reserveslot player calculations.
- Added logging messages when server lock status is changed.
- Added a periodic check to the reserve slot lock status.

## v0.1.219a
- Added ability to hook network messages, simply register an eventhook with the network messages name, and it will be executed before the network message function is.
- Added option to set move rate via config on client connect.
- Added option to set client update rate (if added as configurable) on client connect.
- Changed reserveslot plugin back to using playerlist instead of Server.GetNumPlayers().
- Fixed issue with sv_status command run on serverconsole.
- Added kMaxGameNotStartedTime to mapvote plugin, which when changed from 0 will automatically start the game after X seconds even without a commander for both sides.

## v0.1.211a
- Corrected a couple depreciated calls to functions that have been moved under globals.
- Cleaned up calls to PrintToAllAdmins function, and also replaced default ServerAdminPrint with a slightly modified one.  Am considering using PrintToAllAdmins to replace ServerAdminPrint in functions, but
sometimes it is preferrable to print a slightly different message to client executing the command.

## v0.1.210a
- Added connection time caching.
- Updated reserveslot plugin to use connection time instead of score.
- Re-added MaximumSlot setting for reserveslot plugin, only used if changed from 0.

## v0.1.209a
- Completed network message function replacement system.
- Fixed bugs with gameIDs and gagged players.
- Added DAK:ExecutePluginGlobalFunction for any cross plugin calls to insure safety.
- Removed a couple globals which can be replaced by the above.

## v0.1.207a
- Moved many functions under a global DAK variable, offers greater unity and cohesion
- Added ability to replace network message functions
- Added ability to remove server admin commands, and to re-register them.
- Added events for plugin initialization OnPluginInitialized (occurs on first server update event), OnPluginUnloaded (occurs when plugins are reloaded) and OnConfigReloaded (occurs when config is reloaded).
- Changed default config setup functions to expect an array to be returned with the config values.

## v0.1.203a
- Added ability for custom event hooks to be created - Automatically created on register of non-existing hook.

## v0.1.131a
- Fixed assert regarding missing function for logging certain sv_ actions.
- Fixed possible exploit regarding player names.
- Corrected logging issue with commander eject votes.

## v0.1.130a
- Added VoteRandomOnGameStart flag to voterandom plugin - will random any players left in RR on round start.
- Added DAKIsPlayerAFK global function to check if players are AFK, uses afkkick plugin.  As a failback it will also check the default NS2's afk variables.  Updated random functions to check for non-afk players.

## v0.1.128a
- Corrected send team message issues with language plugin causing issues with surrendervote.
- Corrected issue with the AFKKick plugin causing asserts.
- Corrected issue with disconnects and AFK plugin not being cleaned up.

## v0.1.126a
- Corrected MapCycle using EventHooks incorrectly.
- Corrected issue with available anguages not being echoed back.
- Corrected issue with mapvote trying to use a function instead of an array.

## v0.1.125a
- Added some additional blocks to Pause plugin.
- Added some team balance checks to Random plugin.
- Corrected issue causing arrays in config files to always be updated when having less than the default # of entries.
- Added some additional safety to sv_ commands, and also updated certain command to use logging directly rather than through hooks (commands that modified clients).

## v0.1.124a
- Corrected some additional issues with Pause plugin.

## v0.1.123a
- Added sv_nick command to change players name.
- Updated return messages and added additional checks on most sv_ commands to prevent asserts from server console.
- Updated plugin load function to re-run until successful in loading all plugins.
- Setting no longer matters between map changes, plugin settings are cleared before load events.
- Moved GetTournamentMode and GetFriendlyFire checks to DAKLoader_Server for global use.
- Added basic TournamentMode Override checks for NS2Stats.
- Added override for GameRules GetFriendlyFire checks.
- Added override for FriendlyFire damage percent.
- Updated Reserveslot and SurrenderVote plugins to sleep.
- Removed any remaining PROFILE events.
- Not Released.

## v0.1.122a
- Updated EventHooks to function correctly again.
- Corrected issue with deltaTime variable passed to kDAKOnServerUpdate functions.
- Updated language plugin logic and functionality.  Automatically creates Default.json language file, should be sorted by key names now for ease of reading/editing, and also have better spacing/line breaks.
- Default.json is never loaded by DAK, it is mearly generated anew each map change.  The Default.json file can be used to create new language definitions.
- Updated sv_killserver command with newly discovered server crash (meh).
- Updated sv_status command to better handle any usage cases.
- Updated setlanguage command to echo back valid languages when used without a language or with an invalid one.
- Updated pause plugin with additional overrides to adjust more game events for pauses.
- Not Released.

## v0.1.121a
- Updated and simplified tournamentmode game state monitoring, should make for easier debugging and hopefully will resolve any current issues.
- Updates to Language system to allow plugins to register and create their own default message strings, which will be updated in the Default.json langauge definition.  This file should not be edited, and
is the file that any custom languages should be created from.
- Adjusted function events to be locals.
- Not Released.

## v0.1.119a
- Corrected missing config variables for tournamentmode plugin.

## v0.1.118a
- Updated chat command checks to be case insensitive.
- Adjusted loading order for menu system functions.
- Adjusted and corrected many bugs with the base menu system functions - still not complete, mainly just needs a working GUI.
- Broke pause command out into its own plugin.
- Additional improvements to pause plugin, still has quite a few missing events.
- Simplified config_ files and config generation steps.
- Added version checks to PluginLoader, will print alert if there is mismatch.
- Corrected issues with resetsettings and setlanguage admin commands.
- Added failure detection to plugin loader - if plugin fails to load, DAK will not load the plugin again until the version number changes - ideally would use file timestamps - this is tracked in DAKSettings.
	IE if plugin afkkick failed, you could use sv_resetsettings afkkick and then it would attempt to load again next server restart.
- Updated readme courtesy of Whosat.
- Corrected scoreboard issue and added some configuration options to tournamentmode plugin courtesy of kormendi.

## v0.1.117a
- Updated some overrides in sv_pause plugin

## v0.1.116a
- Added basics for a sv_pause plugin - Currently still missing or broken or untested parts are - Maturity Rate,FireDamage,Comm Abilities - Looking into blocking reloads and energy regain.
- Corrected issue with mapvote triggering too often (on any gamestate change).
- Commented out sv_cheats command as NS2 has one now.
- Added server update event hook that triggers every frame (use very sparingly!).
- Added notification to autoconcede plugin.
- Removed MaxSlots configuration option from ReservedSlots plugin as it can now be read directly from the Server.
- Corrected logic issue with SurrenderVote plugin that could cause the first alien on the team to be missed (and the surrender array not cleared).

## v0.1.115a
- Merged pull request from Lance including config option to disable tournament mode team join override.
- Added option to random plugin to have random always turned on.
- Added some additional safety to language table merging.
- Switched load order for language files to check config_path/lang folder first, then lua/lang.
- Updated MOTD and Messages plugins to use Language functions to get language specific messages.
- Added some redundancy to MOTD and Language client settings to insure clientID is save as a number and not a string.  This may cause existing MOTD acceptances to be invalid.
- Added sv_setlanguage command for admins to set change language for clients.
- Changed sv_cheats command to be a toggle.
- Never Released

## v0.1.114a
- Corrected issue with public play setting for tournamentmode allowing any team to be joined.
- Corrected mapvote plugin issue where RTVs would still trigger automatic map cycle.
- Added maximum amount of ties to mapvote plugin to prevent endless voting loops.
- Added Default.json file to language configuration, this file should not be modified as this will contain the defaults that DAK will fall back on if no others are valid.
	You can create a copy to use as your default if desired, like EN.json etc..
- Corrected logic issues with random plugin that would cause it to not enable after map change easily.
- Removed some depreciated config options from messages and motd plugins.
- Updated functions set on DefaultConfigs generation.
- Corrected issue causing admins ip address to be printed to any user that did sv_status, instead of only admins being able to see the IP.
- Updated ReserveSlot plugin to get ready for SDK additions in B236
- Attempted to correct issue where random would not re-enable correctly after map change
