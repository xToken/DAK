//Trying something wierd here - Load original EventTester.lua file
//Well this sucks, need to include old EventTester file now because of B258 change.

if Server then
	Script.Load("lua/base/server.lua")
elseif Client then
	Script.Load("lua/base/client.lua")
elseif Predict then
	Script.Load("lua/base/predict.lua")
end

Script.Load("lua/base/EventTester.lua")