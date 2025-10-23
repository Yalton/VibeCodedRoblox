-- Remote Events for Client-Server Communication
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = {}

-- Create folder for remote events if it doesn't exist
local RemoteFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not RemoteFolder then
	RemoteFolder = Instance.new("Folder")
	RemoteFolder.Name = "RemoteEvents"
	RemoteFolder.Parent = ReplicatedStorage
end

-- Function to create or get a RemoteEvent
local function getOrCreateEvent(name)
	local event = RemoteFolder:FindFirstChild(name)
	if not event then
		event = Instance.new("RemoteEvent")
		event.Name = name
		event.Parent = RemoteFolder
	end
	return event
end

-- Function to create or get a RemoteFunction
local function getOrCreateFunction(name)
	local func = RemoteFolder:FindFirstChild(name)
	if not func then
		func = Instance.new("RemoteFunction")
		func.Name = name
		func.Parent = RemoteFolder
	end
	return func
end

-- Define all remote events
RemoteEvents.UpdateMoney = getOrCreateEvent("UpdateMoney")
RemoteEvents.PurchaseUpgrade = getOrCreateEvent("PurchaseUpgrade")
RemoteEvents.UpgradePurchased = getOrCreateEvent("UpgradePurchased")

-- Define remote functions
RemoteEvents.GetPlayerData = getOrCreateFunction("GetPlayerData")

return RemoteEvents
