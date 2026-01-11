task.wait(1)
-- =========================
-- CAMERA ZOOM + LOOK DOWN
-- =========================
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

-- camera settings
local minZoom = 0.5
local zoomStep = 1
local zoomDelay = 0.02
local tiltDegrees = -89

-- allow closest zoom
player.CameraMinZoomDistance = minZoom

-- smooth scroll-style zoom in
for z = player.CameraMaxZoomDistance, minZoom, -zoomStep do
	player.CameraMaxZoomDistance = z
	task.wait(zoomDelay)
end
player.CameraMaxZoomDistance = minZoom

-- slight pause so zoom finishes
task.wait(0.05)

-- tilt camera downward
camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(tiltDegrees), 0, 0)

-- =========================
-- SETTINGS
-- =========================
local cooldown = 0.1
local uiBuffer = 0.15
local containerFolder = workspace:WaitForChild("Containers")

local targetNames = {
	"Bronze",
	"Gold",
	"Wood"
}

-- FINAL TELEPORT POSITION (AFTER LAST WOOD)
local finalTeleportPosition = Vector3.new(77.567, 764, -449.749)

-- PLAYER
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- =========================
-- STEP 1: INSTANT PROMPTS
-- =========================
for _, obj in ipairs(workspace:GetDescendants()) do
	if obj:IsA("ProximityPrompt") then
		obj.HoldDuration = 0
	end
end

workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("ProximityPrompt") then
		obj.HoldDuration = 0
	end
end)

-- =========================
-- UTILITY
-- =========================
local function getCFrame(obj)
	if obj:IsA("Model") then
		return obj:GetPivot()
	elseif obj:IsA("BasePart") then
		return obj.CFrame
	end
end

-- =========================
-- COUNT TOTAL WOOD
-- =========================
local totalWood = 0
for _, container in ipairs(containerFolder:GetDescendants()) do
	if container.Name == "Wood" then
		totalWood += 1
	end
end

local processedWood = 0

-- =========================
-- TELEPORT + PRESS E
-- =========================
for _, targetName in ipairs(targetNames) do
	for _, container in ipairs(containerFolder:GetDescendants()) do
		if container.Name == targetName and (container:IsA("Model") or container:IsA("BasePart")) then
			local cf = getCFrame(container)
			if cf then
				-- teleport to container
				hrp.CFrame = cf + Vector3.new(0, 3, 0)

				task.wait(uiBuffer)

				-- trigger prompt
				for _, prompt in ipairs(container:GetDescendants()) do
					if prompt:IsA("ProximityPrompt") then
						prompt:InputHoldBegin()
						prompt:InputHoldEnd()
					end
				end

				task.wait(cooldown)

				-- ✅ TELEPORT AFTER LAST WOOD
				if targetName == "Wood" then
					processedWood += 1
					if processedWood == totalWood then
						hrp.CFrame = CFrame.new(finalTeleportPosition)
					end
				end
			end
		end
	end
end
