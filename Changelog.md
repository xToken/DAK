//Going to start tracking changes made better here - GitHub offers all the code tracking needed, just need to track what those changes are supposed to fix, along with better  versioning.

Initial Version - Plugin versions invidually all over - normalizing for this update, along with loader version
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
