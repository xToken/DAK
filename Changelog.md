//Going to start tracking changes made better here - GitHub offers all the code tracking needed, just need to track what those changes are supposed to fix, along with better versioning.

Initial Version - Plugin versions invidually all over - normalizing for this update, along with loader version - Need to decide how to track plugin revisions - 
should plugins be updated with each 'build' of DAK, even if there are no changes?  This seems the most logical way to proceed currently, and for the future.

- v0.1.118a
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

- v0.1.117a
- Updated some overrides in sv_pause plugin

- v0.1.118a
- Added basics for a sv_pause plugin - Currently still missing or broken or untested parts are - Maturity Rate,FireDamage,Comm Abilities - Looking into blocking reloads and energy regain.
- Corrected issue with mapvote triggering too often (on any gamestate change).
- Commented out sv_cheats command as NS2 has one now.
- Added server update event hook that triggers every frame (use very sparingly!).
- Added notification to autoconcede plugin.
- Removed MaxSlots configuration option from ReservedSlots plugin as it can now be read directly from the Server.
- Corrected logic issue with SurrenderVote plugin that could cause the first alien on the team to be missed (and the surrender array not cleared).

- v0.1.115a
- Merged pull request from Lance including config option to disable tournament mode team join override.
- Added option to random plugin to have random always turned on.
- Added some additional safety to language table merging.
- Switched load order for language files to check config_path/lang folder first, then lua/lang.
- Updated MOTD and Messages plugins to use Language functions to get language specific messages.
- Added some redundancy to MOTD and Language client settings to insure clientID is save as a number and not a string.  This may cause existing MOTD acceptances to be invalid.
- Added sv_setlanguage command for admins to set change language for clients.
- Changed sv_cheats command to be a toggle.
- Never Released

- v0.1.114a
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
