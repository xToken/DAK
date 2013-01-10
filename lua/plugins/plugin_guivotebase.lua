//NS2 Vote Base GUI Implementation

local kRunningVotes = { }

//GUIVoteBase
//OnVoteFunction(client, OptionSelected)
//OnVoteUpdateFunction(kVoteBaseUpdateMessage)

if kDAKConfig and kDAKConfig.GUIVoteBase then
	
	function CreateGUIVoteBase(client, VoteFunction, VoteUpdateFunction, Relevancy)
		local Id = GetGameIdMatchingClient(client)
		if Id == nil or Id == 0 then return false
		for i = #kRunningVotes, 1, -1 do
			if kRunningVotes[i] ~= nil and kRunningVotes[i].clientId == Id then
				return false
			end		
		end
		local GameVote = {UpdateTime = 0, OnVoteFunction = VoteFunction, OnVoteUpdateFunction = VoteUpdateFunction, VoteBaseUpdateMessage = nil, clientId = Id}
		table.insert(kRunningVotes, GameVote)
		return true
	end
	
	local function UpdateVotes(deltatime)
	
		for i = #kRunningVotes, 1, -1 do
			if kRunningVotes[i] and kRunningVotes[i].UpdateTime ~= nil then
				if kRunningVotes[i].UpdateTime >= kDAKConfig.GUIVoteBase.kVoteUpdateRate then
					local newVoteBaseUpdateMessage = kRunningVotes[i].OnVoteUpdateFunction(kRunningVotes[i].VoteBaseUpdateMessage)
					Server.SendNetworkMessage(GetPlayerMatchingGameId(kRunningVotes.clientId), "GUIVoteBase", newVoteBaseUpdateMessage, false)						
					kRunningVotes[i].VoteBaseUpdateMessage = newVoteBaseUpdateMessage
					if newVoteBaseUpdateMessage.votetime == 0 or newVoteBaseUpdateMessage.votetime == nil then
						kRunningVotes[i] = nil
					else
						kRunningVotes[i].UpdateTime = 0
					end
				else
					kRunningVotes[i].UpdateTime = kRunningVotes[i].UpdateTime + deltatime
				end
			end
		end
	
	end
	
	DAKRegisterEventHook(kDAKOnServerUpdate, UpdateVotes, 5)
	
	local function OnMessageBaseVote(client, voteMessage)
		for i = #kRunningVotes, 1, -1 do
			if kRunningVotes[i].clientId == GetGameIdMatchingClient(client) then
				kRunningVotes[i].OnVoteFunction(client, voteMessage.optionselected)
				break
			end
		end
		Shared.Message(string.format("Recieved vote %s", voteMessage.optionselected))
		
	end

	Server.HookNetworkMessage("GUIVoteBaseRecieved", OnMessageBaseVote)

end

Shared.Message("GUIVoteBase Loading Complete")