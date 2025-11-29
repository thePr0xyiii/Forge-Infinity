-- MiningHandler.lua (Server Script)
-- Parent: ServerScriptService

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")

-- 1. Get RemoteEvent
local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 5)
if not remoteFolder then
	warn("❌ Folder 'RemoteEvents' not found in ReplicatedStorage!")
	return
end

local swingEvent = remoteFolder:WaitForChild("swing", 5)
if not swingEvent then
	warn("❌ RemoteEvent 'swing' not found!")
	return
end
print("✅ Swing event found")

-- 2. Find MineSound in Pickaxe
local mineSound = nil
local pickaxe = game.StarterPack:FindFirstChild("Pickaxe")
if pickaxe then
	local handle = pickaxe:FindFirstChild("Handle")
	if handle then
		mineSound = handle:FindFirstChild("MineSound") or handle:FindFirstChild("SwingSound")
		if mineSound then print("✅ MineSound found") end
	end
end

-- 3. Helper: Check Mining Zone
local function isInMiningZone(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	-- Use CollectionService to find zones
	local miningZones = CollectionService:GetTagged("MiningZone")
	if #miningZones == 0 then
		-- Warn if no zones exist (debugging help)
		-- print("⚠️ No parts tagged 'MiningZone' found!") 
		return true -- TEMPORARY BYPASS: Allow mining anywhere if no zones are set up yet
	end

	for _, zone in ipairs(miningZones) do
		-- Simple box check (assumes unrotated zone for simplicity, or use magnitude)
		-- A better check uses spatial query or magnitude if zone is just a marker
		if (hrp.Position - zone.Position).Magnitude < (zone.Size.Magnitude / 2) + 5 then
			return true
		end
	end

	return false
end

-- 4. Handle Mining Logic
local function mineRock(player, rockModel)
	-- print("🎯 mineRock called on:", rockModel.Name) -- Debug off

	if not isInMiningZone(player) then
		print("❌ Not in Mining Zone!")
		return
	end

	-- Play Sound
	if mineSound then
		local soundClone = mineSound:Clone()
		soundClone.Parent = rockModel.PrimaryPart or rockModel:FindFirstChild("Part") or rockModel
		soundClone:Play()
		Debris:AddItem(soundClone, 1.5)
	end

	-- Determine Ore Type
	local oreType = nil
	if rockModel.Name == "IronRock" then
		oreType = "Iron"
	elseif rockModel.Name == "GoldRock" then
		oreType = "Gold"
	elseif rockModel.Name == "CrystalRock" then
		oreType = "Crystal"
	end

	-- Add to Inventory
	if oreType and _G.Inventory then
		_G.Inventory.addOre(player, oreType, 1)
	else
		warn("❌ Inventory System missing or Ore Type unknown (" .. tostring(oreType) .. ")")
	end
end

-- 5. Server Event Listener
swingEvent.OnServerEvent:Connect(function(player, origin, look)
	-- Sanity check parameters
	if not origin or not look then return end

	-- Raycast
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {player.Character}

	-- Raycast 15 studs (match client range)
	local result = workspace:Raycast(origin, look * 15, params)

	if result then
		local hitPart = result.Instance

		-- FIX: Traverse UP to find the Rock Model (Handles MineHitBox)
		local current = hitPart
		while current and current ~= workspace do
			if current.Name == "IronRock" or current.Name == "GoldRock" or current.Name == "CrystalRock" then
				-- Found the valid rock model!
				mineRock(player, current)
				break -- Stop the loop
			end
			current = current.Parent
		end
	end
end)

print("✅ Mining Handler loaded")
