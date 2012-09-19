This collection of plugins (and loader) make up what I started calling the DAK (Duck Admin Kit?)

DAKLoader.lua would need to be called instead of Server.lua in your game_setup.xml file.  Alternatively you can setup a mod that starts DAKLoader.lua.
Generally lua files will not need to be edited (hopefully), but depending on your server hosting setup there is one main standout.  Due to the way NS2 
currently loads/saves files, many servers operators with servers hosted by GSP's will not have access to APPDATA, which is where NS2 loads files from.  
Because of this, there is a kCheckGameDirectory variable in the DAKLoader.lua file.  Changing this to true will have the mod check the game directory for 
the DAKConfig.json file, DAKServerAdmin.json file, the mapcycle.txt, and the ReservedPlayers.json files.  Note that the DAKSettings.json file will still be stored in appdata, 
as the game prevents writing to files in the game directory.  

This mod now attempts to override the default admin system completely, and uses a different ServerAdmin.json file to accomplish this best. 
You will get messages about not having access to commands, but this can also corrected by removing/commenting the line below:
Line 25 in Server.lua
Script.Load("lua/ServerAdminCommands.lua")
change to or remove-
//Script.Load("lua/ServerAdminCommands.lua")

A note about the config files,  and their directories.  Using the -adminpath command line argument is recommended.  When used, both the config files in 
the user (appdata) folder, and the config files in the game directory (if kCheckGameDirectory is enabled).  So if using -adminpath NS2Server1, the game 
will look in %APPDATA%\Natural Selection 2\NS2Server1 for user:\\ load statements, and in the ServerFolder\%GAMEMOD%\NS2Server1 for game:\\ load statements.
By default %GAMEMOD% would be ns2, but if you created a mod called DAK it would be in the DAK folder.

All mods can be enabled/disabled via the DAKconfig.json file.  Any variable starting with _ is a boolean for if that plugin should be loaded.  Also that 
generally starts the configuration section for that plugin.  Below is a sample config file with the values ommited, and descriptions in their place.  
A sample usable config file is included with the mod, which uses the recommended values.

 "GlobalConfig": Just a header for the config file.
 "kDelayedClientConnect": This controls the delay after connect that the DelayedClientConnect event is triggered.
 "kDelayedServerUpdate": This controls the delay between updates of anything running on ServerUpdate (per server frame, default 1 second)
 "_OverrideInterp": This is a boolean for if the Interp override should be enabled. (default false)
 "kInterp": this is the amount of MS the interp will be set to on client connect. (default 100)
 "_VoteRandom": This is a boolean for if the Vote Random Teams plugin should be loaded.
 "kVoteRandomInstantly": This boolean controls how the random teams plugin works.  If true, the teams are randomed instantly for one round.  If false, 
	the teams are randomed each round starting with the next new round for kVoteRandomDuration.
 "kVoteRandomDuration": The duration that the random team vote stays enabled for (if kVoteRandomInstantly is false).
 "kVoteRandomMinimumPercentage": The percentage of votes required to turn on random teams.
 "kVoteRandomEnabled": The message displayed when random teams are enabled with kVoteRandomInstantly set to true.
 "kVoteRandomEnabledDuration": The message displayed when random teams are enabled with kVoteRandomInstantly set to false.
 "kVoteRandomConnectAlert": The message displayed when a client connects and random teams are on.
 "kVoteRandomVoteCountAlert": The message displayed when a client votes to enable random teams.
 "_TournamentMode": This boolean controls if tournamentmode is enabled.
 "kTournamentModePubMode": This boolean controls if the tournamentmode will run in pub mode, which automatically starts the game once both teams
	have kTournamentModePubMinPlayers.
 "kTournamentModePubMinPlayers": This minimum number of players needed per team to start the round in pub mode.
 "kTournamentModePubPlayerWarning": Message displayed to clients when waiting for enough players in pub mode.
 "kTournamentModePubAlertDelay": Frequency of message displayed to clients waiting for round start in pub mode.
 "kTournamentModeReadyDelay": This delay prevents ready/unready spam.
 "kTournamentModeGameStartDelay": Delay between round starting after both teams are ready.
 "kEnableFriendlyFireWithTournamentMode": If true, friendlyfire will automatically be enabled when tournamentmode is enabled.
 "kTournamentModeCountdown": Message displayed when counting down till round start.
 "kTournamentModeWaiting": "Game will start in %s seconds!",
 "_ReservedSlots": This boolean control if reserve slot plugin is enabled.
 "kMaximumSlots": This is the server's maximum number of slots.
 "kReservedSlots": This is the amount of slots that will be reserved for reserve slot players.  This should be kMinimumSlots more than the amount of slots 
	you wish to have.
 "kMinimumSlots": This is the amount of slots the server will always keep free (unless completely full of reserve slot players).  Should most likely always 
	be 1.
 "kDelayedSyncTime": Delay in which the server will wait after most recent connect/disconnect to update cached player list against server list.
 "kDelayedKickTime": Delay before kicking a player due to a reserve slot.
 "kReserveSlotServerFull": Message displayed to client connected to full server without reserve slot.
 "kReserveSlotServerFullDisconnectReason": Message logged when client is kicked because server is full.
 "kReserveSlotKickedForRoom": Message displayed to client kicked to make room for reserve slot player.
 "kReserveSlotKickedDisconnectReason": Message logged when client is kicked to make room for reserve slot player.
 "_MOTD": This boolean controls if the MOTD plugin is loaded.
 "kMOTDMessage": [ Messages displayed on player connect. ]
 "kMOTDMessageDelay": Delay in seconds between blocks of messages sent to client.
 "kMOTDMessageRevision": The revision of the MOTD used to track accepted clients.
 "kMOTDMessagesPerTick": How many messages to send per block.
 "_MapVote": This boolean controls if the map vote plugin is loaded.
 "kVoteStartDelay": Delay in seconds after round end before the map vote starts.
 "kVotingDuration": Duration of the map vote.
 "kMapsToSelect": Maximum number of maps to select for vote.
 "kDontRepeatFor": How long to store a map and not repeat.
 "kVoteNotifyDelay": How often to display current vote status.
 "kVoteChangeDelay": Delay after successful vote before map change.
 "kVoteMinimumPercentage": Minimum Percentage of votes required for a single map for it to succeed.
 "kRTVMinimumPercentage": Minimum Percentage of rtv votes (rock the vote) to start a map vote at any time.
 "kVoteMapBeginning": Message displayed to clients when map vote is about to start.
 "kVoteMapHowToVote": Information message displayed when map vote is about to start.
 "kVoteMapStarted": Message displayed when map vote starts.
 "kVoteMapMapListing": Message displayed detailing each map and how to vote for it.
 "kVoteMapNoWinner": Message displayed if no map wins a vote.
 "kVoteMapTie": Message displayed if a tie is encountered.
 "kVoteMapWinner": Message displayed if a map wins the vote.
 "kVoteMapMinimumNotMet": Message displayed if a map wins the vote but doesnt make the minimum requirement.
 "kVoteMapTimeLeft": Message displayed during map vote with time remaining.
 "kVoteMapCurrentMapVotes": Message displayed during map vote with maps current vote total, and how to vote for it.
 "kVoteMapRockTheVote": Message displayed when player rocks the vote.
 "kVoteMapCancelled": Message displayed if map vote is cancelled.
 "kVoteMapInsufficientMaps": Message displayed if there is insufficient maps for a map vote.
 "_AFKKicker": This boolean controls if the AFK Kicker plugin is loaded.
 "kAFKKickDelay": Delay in seconds before a AFK user will be kicked.
 "kAFKKickCheckDelay": Delay between checks of users position and view angles.
 "kAFKKickMinimumPlayers": Amount of players required before people will be kicked for being AFK.
 "kAFKKickReturnMessage": Message shown to user that recieved warning messages but then moved.
 "kAFKKickMessage": Message logged to console when a user is kicked.
 "kAFKKickDisconnectReason": Message logged when user is disconnected because of idling.
 "kAFKKickClientMessage": Message shown to users the cycle before they are kicked (they will be kicked unless they move in kAFKKickCheckDelay seconds)
 "kAFKKickWarning1": time before being kicked that the first warning message will be shown (best to use number cleanly divisible by your CheckDelay)
 "kAFKKickWarningMessage1": First warning message shown to AFK users.
 "kAFKKickWarning2": time before being kicked that the second warning message will be shown (best to use number cleanly divisible by your CheckDelay)
 "kAFKKickWarningMessage2": Second warning message shown to AFK users.
 "_EnhancedLogging": Boolean which controls if the Enhanced logging plugin is enabled.
 "kEnhancedLoggingSubDir": Subdirectory under the adminpath in which log files should be stored.
 "_VoteSurrender": Boolean which controls if the Surrender Vote plugin is loaded.
 "kVoteSurrenderMinimumPercentage": Minimum Percentage of votes needed for surrender to pass
 "kVoteSurrenderVotingTime": Time that a surrender vote will run for.
 "kVoteSurrenderAlertDelay": Delay between alert messages regarding the surrender vote.
 Generally the default configuration should work for most instances, if you do customize the messages be sure to maintain the same amount of regex strings (%s, %f, %d).
 
 Server Admin commands added:
 sv_rcon - allows an admin to execute a command on the servers console.
 sv_reloadconfig - reloads the DAKConfig.json file.
 sv_plugins - displays all loaded plugins, their revisions and if they are enabled/disabled.
 sv_maps - lists all maps currently available on the server
 sv_randomon - will turn on random teams
 sv_randomoff - will turn off random teams
 sv_tournamentmode - will enable/disable tournamentmode - The current state of the tournamentmode is saved in the DAKSettings.json file, so this will 
	persist between map changes.
 sv_forceroundstart - Used in tournamentmode to force the round start as an Admin.
 sv_cancelroundstart - Used in tournamentmode to cancel the round start as an Admin.
 sv_friendlyfire - will enable/disable friendlyfire
 sv_votemap - starts a mapvote at anytime
 sv_cancelmapvote - cancels any in progress map votes.
 sv_listadmins - will list all groups and admins configured in the DAKServerAdmin.json file
 sv_killserver - Does exactly what it says - This is not a clean closing of the server, it uses a bug which causes a crash.
 sv_hasreserve - Will grant this admin a reserve slot that does not expire.
 sv_surrendervote - Will start a surrender vote for the team provided.
 sv_cancelsurrendervote - Will cancel a in progress surrender vote for the team provided.

 All server admin commands will also print to any other admins consoles when used (admins that also have access to that command)
 
 General console commands added:
 timeleft - displays time left till next map vote.
 acceptmotd - supresses motd messages unless the kMOTDMessageRevision is changed.  This is saved in DAKSettings.json and persists between map changes.
 printmotd - will print the motd out.
 voterandom - will vote to enable random teams.
 ready - marks your team as ready if tournamentmode is enabled.
 vote - used to vote for a map during map vote, needs to have a number as a paramater.
 rtv or rockthevote - used to vote for a map vote (can be started anytime)
 surrender - used to start or vote in an active surrender vote.
 
 Breakdown of current 'Plugins' system and the standard 'Plugins'
 DAK extends various events from the engine, and creates a couple of its own.
 kDAKOnClientConnect
 kDAKOnClientDisconnect
 kDAKOnServerUpdate
 kDAKOnClientDelayedConnect
 kDAKOnTeamJoin
 kDAKOnGameEnd
 kDAKOnEntityKilled
 
 Functions can be added to these variables which will be run when these events occur, sample shown below:
 table.insert(kDAKOnClientDisconnect, function(client) return LogOnClientDisconnect(client) end)
 
 Please note that errors caused in functions added are systemic, meaning they will affect the execution of NS2 gamecode, so some care must be taken.
 
 OverrideInterp Plugin
 - This is mainly for testing, however it overrides the default interpolation value of 100ms on each clients connect, making sure that
 the value is correct set client/server side.
 
 VoteRandom Plugin
 - This plugin enables players to vote to enable random teams, and supports either randoming the teams instantly, or enabling random teams for a set duration,
 where the next game and all games for a set duration have random teams.
 
 TournamentMode Plugin
 - This plugin is more or less obsolete now, the NS2stats system has a tournament plugin now which is superior to this one.
 May still have some utility for turning on friendlyfire.
 
 ReservedSlots Plugin
 - Basic Reserve slots plugin, however is more a proof of concept and does not have the ability to work in a way that provides a good user experience.
 Basic framework may prove useful should the ability arise to reject clients connection earlier or modify query response.
 
 MOTD Plugin
 - This plugin provides a MOTD system that could be more accurately described as a rules system, which allows clients to accept and have the messages
 not always appear on connect.  Should be loaded as last plugin so that other plugins can stop the messages if needed.  Messages are also sent in groups
 so that they can all be viewed onscreen.
 
 MapVote Plugin
 - This plugin provides a map voting system, which will read the mapcycle.txt for cycle time and the list of maps.  On round end a map vote is triggered
 if enough time has elapsed, with a randomly selected list of maps which excludes some of the map last played.  Since NS2 only has 4 offical maps currently
 the plugin will automatically add back in maps if there is not enough to make the minimum.  Almost all parts are configurable in the configs.
 
 AFKKicker Plugin
 - This plugin checks if a player is idle by caching their viewangles and origin, and displays messages to alert them if they are going to be kicked.
 May in the future be improved to use idle parameter on the player.
 
 EnhancedLogging Plugin
 - This plugin enables alot of extra logging, which is done to a seperate directory within the configured server admin path.
 Sample log file below with some information omitted:
 
 L 9/16/2012 - 12:55:53 - <AAA><10><STEAMID><0> joined team 2.
 L 9/16/2012 - 12:55:59 - <[Mi7] JumpinJackFlas><13><STEAMID><0> changed name to [Mi7] JumpinJackFlash.
 L 9/16/2012 - 12:56:01 - <[Mi7] JumpinJackFlas><13><STEAMID><0> connected, address IPADDRESS
 L 9/16/2012 - 12:56:06 - <FatherTime><6><STEAMID><2> killed <Sphen><4><STEAMID><1> with BiteLeap at (attacker_position 38.560000 3.970000 -2.400000) (victim_position 39.510000 2.750000 -4.130000)
 L 9/16/2012 - 12:56:20 - <FatherTime><6><STEAMID><2> killed <Siylenia><12><STEAMID><1> with BiteLeap at (attacker_position 62.810000 0.330000 19.350000) (victim_position 63.350000 -0.160000 20.500000)
 L 9/16/2012 - 12:56:47 - <Siylenia><12><STEAMID><1> killed <FatherTime><6><STEAMID><2> with Rifle at (attacker_position 81.250000 0.390000 30.740000) (victim_position 83.000000 1.180000 30.890000)
 L 9/16/2012 - 12:56:53 - <Siylenia><12><STEAMID><1> killed <AAA><10><STEAMID><2> with Rifle at (attacker_position 75.930000 -0.100000 35.140000) (victim_position 68.780000 4.880000 36.570000)
 L 9/16/2012 - 12:57:00 - <Teh_Prodigy><2><STEAMID><1> killed Hydra with Shotgun at (attacker_position 69.100000 0.010000 33.650000) (victim_position 64.600000 -0.000000 30.490000)
 
 VoteSurrender Plugin
 - This plugin provides a surrender vote system for each team, which can be used to vote for the game to end if a set percentage of the team votes.
 
 //Config
 
 Reserve Slot config

 -Name is just a friendly name for the user, is not checked in game.
 -ID is the steamID for the user, which is what is used to authenticate them in game.
 -Reason is the reason for why the user has a reserve slot
 -Time is the unix system time of when the reserve slot will expire, 0 will set it to not expire.

 Sample file below:

 {
 	{ "name": "dragon", "id": 5176141, "reason": "meh", "time": 0 }
 }
 
 DAKServerAdmin config
 
 This files works identically to the base admin system's configuration file.
 
 Sample file below:
 
 {
    "groups":
    {
        "admin_group": { "type": "disallowed", "commands": [ ] },
        "mod_group": { "type": "disallowed", "commands": [ "sv_ban", "sv_reset" ] },
        "clan_group": { "type": "allowed", "commands": [ "sv_kick", "sv_say" ] }
    }
    
    "users":
    {
        "dragon": { "id": 5176141, "groups": [ "clan_group" ] },
    }
}