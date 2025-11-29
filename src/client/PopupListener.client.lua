-- PopupListener.lua (LocalScript)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local showPopupEvent = ReplicatedStorage:WaitForChild("ShowPopup")

-- This function runs ONLY when the server tells it to
showPopupEvent.OnClientEvent:Connect(function(text)
	-- Create ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PopupGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- Random position on screen
	local randomX = math.random(100, 1200)
	local randomY = math.random(100, 600)

	-- Create TextLabel
	local textLabel = Instance.new("TextLabel")
	textLabel.Text = text
	textLabel.Size = UDim2.new(0, 150, 0, 50)
	textLabel.Position = UDim2.new(0, randomX, 0, randomY)
	textLabel.BackgroundTransparency = 1
	textLabel.TextStrokeTransparency = 0
	textLabel.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold
	textLabel.TextSize = 28
	textLabel.Font = Enum.Font.GothamBlack
	textLabel.Parent = screenGui

	-- Animate
	local tween = TweenService:Create(textLabel, TweenInfo.new(1), {
		Position = UDim2.new(0, randomX, 0, randomY - 100),
		TextTransparency = 1,
		TextStrokeTransparency = 1
	})

	tween:Play()
	Debris:AddItem(screenGui, 1.1)
end)
