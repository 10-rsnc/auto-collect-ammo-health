local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local TELEPORT_KEY = Enum.KeyCode.P
local MIN_DISTANCE = 214748300
local MAX_DISTANCE = 2147483647
local TELEPORT_DELAY = 0.001

local isTeleporting = false
local teleportTask = nil

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportStatusGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0, 200, 0, 50)
statusLabel.Position = UDim2.new(0.5, -100, 0.05, 0)
statusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
statusLabel.BackgroundTransparency = 0.5
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Text = "Teleport: OFF"
statusLabel.Parent = screenGui

local function updateUI()
    if isTeleporting then
        statusLabel.Text = "Teleport: ON"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        statusLabel.Text = "Teleport: OFF"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end

local function teleportOnce()
    if not character or not humanoidRootPart then return end

    local currentPosition = humanoidRootPart.Position
    local randomAngle = math.random() * math.pi * 2
    local randomDistance = math.random(MIN_DISTANCE, MAX_DISTANCE)

    local newX = currentPosition.X + math.cos(randomAngle) * randomDistance
    local newZ = currentPosition.Z + math.sin(randomAngle) * randomDistance
    local newY = currentPosition.Y + 100

    humanoidRootPart.CFrame = CFrame.new(newX, newY, newZ)
end

local function toggleTeleportMode()
    isTeleporting = not isTeleporting
    updateUI()

    if isTeleporting then
        if teleportTask then task.cancel(teleportTask) end
        teleportTask = task.spawn(function()
            while isTeleporting do
                teleportOnce()
                task.wait(TELEPORT_DELAY)
            end
        end)
    else
        if teleportTask then
            task.cancel(teleportTask)
            teleportTask = nil
        end
    end
end

UserInputService.InputBegan:Connect(function(input, isGameProcessed)
    if isGameProcessed then return end
    if input.KeyCode == TELEPORT_KEY then
        toggleTeleportMode()
    end
end)

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
end)

updateUI()
