-- InventorySystem.server.lua
-- Parent: ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("🔧 Inventory System starting...")

-- 1. Setup Remotes (Fixes Infinite Yields)
local showPopupEvent = ReplicatedStorage:FindFirstChild("ShowPopup")
if not showPopupEvent then
	showPopupEvent = Instance.new("RemoteEvent")
	showPopupEvent.Name = "ShowPopup"
	showPopupEvent.Parent = ReplicatedStorage
	print("✅ Created ShowPopup RemoteEvent")
end

local getInventoryFunc = ReplicatedStorage:FindFirstChild("GetInventory")
if not getInventoryFunc then
	getInventoryFunc = Instance.new("RemoteFunction")
	getInventoryFunc.Name = "GetInventory"
	getInventoryFunc.Parent = ReplicatedStorage
	print("✅ Created GetInventory RemoteFunction")
end

-- 2. Inventory Logic
local playerInventories = {}

local function initializeInventory(player)
	if playerInventories[player.UserId] then return end

	playerInventories[player.UserId] = {
		iron = 0,
		gold = 0,
		crystal = 0,
		capacity = 50,
		coins = 0
	}
	print("📦 Inventory created for:", player.Name)
end

-- Add Ore
local function addOre(player, oreType, amount)
	local inv = playerInventories[player.UserId]
	if not inv then initializeInventory(player); inv = playerInventories[player.UserId] end

	oreType = string.lower(oreType)
	if inv[oreType] ~= nil then
		inv[oreType] = inv[oreType] + amount
		print("✅ Added", amount, oreType, "to", player.Name)

		-- Trigger the Popup for the player
		showPopupEvent:FireClient(player, "+" .. amount .. " " .. oreType)
		return true
	end
	return false
end

-- Remove Ore (For Forge)
local function removeOre(player, oreType, amount)
	local inv = playerInventories[player.UserId]
	if not inv then return false end

	oreType = string.lower(oreType)
	if inv[oreType] and inv[oreType] >= amount then
		inv[oreType] = inv[oreType] - amount
		return true
	end
	return false
end

-- Get Inventory
local function getInventory(player)
	if not playerInventories[player.UserId] then
		initializeInventory(player)
	end
	return playerInventories[player.UserId]
end

-- 3. Connections
Players.PlayerAdded:Connect(initializeInventory)
Players.PlayerRemoving:Connect(function(player)
	playerInventories[player.UserId] = nil
end)

-- Connect RemoteFunction for Client UI
getInventoryFunc.OnServerInvoke = function(player)
	return getInventory(player)
end

-- Export to _G for other Server Scripts
_G.Inventory = {
	addOre = addOre,
	removeOre = removeOre,
	getInventory = getInventory
}

print("✅ Inventory System fully loaded (Remotes Ready)")
