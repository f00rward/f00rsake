repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function runScript()
	-- wait for fresh character
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")
	local camera = workspace.CurrentCamera

	-- =========================
	-- CAMERA
	-- =========================
	local minZoom = 0.5
	local zoomStep = 1
	local zoomDelay = 0.02
	local tiltDegrees = -89

	player.CameraMinZoomDistance = minZoom

	for z = player.CameraMaxZoomDistance, minZoom, -zoomStep do
		player.CameraMaxZoomDistance = z
		task.wait(zoomDelay)
	end

	player.CameraMaxZoomDistance = minZoom
	task.wait(0.08)

	camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(tiltDegrees), 0, 0)

	-- =========================
	-- SETTINGS
	-- =========================
	local cooldown = 0.1
	local uiBuffer = 0.15
	local containerFolder = workspace:WaitForChild("Containers")

	local targetNames = {"Bronze","Gold","Wood"}

	local finalTeleportPosition = Vector3.new(119.551, 763.407, -431.9)

	-- =========================
	-- INSTANT PROMPTS
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
	-- UTIL
	-- =========================
	local function getCFrame(obj)
		if obj:IsA("Model") then
			return obj:GetPivot()
		elseif obj:IsA("BasePart") then
			return obj.CFrame
		end
	end

	-- =========================
	-- COUNT WOOD
	-- =========================
	local totalWood = 0
	for _, container in ipairs(containerFolder:GetDescendants()) do
		if container.Name == "Wood" then
			totalWood += 1
		end
	end

	local processedWood = 0

	-- =========================
	-- MAIN LOOP
	-- =========================
	for _, targetName in ipairs(targetNames) do
		for _, container in ipairs(containerFolder:GetDescendants()) do
			if container.Name == targetName then
				local cf = getCFrame(container)
				if cf then
					hrp.CFrame = cf + Vector3.new(0, 3, 0)
					task.wait(uiBuffer)

					for _, prompt in ipairs(container:GetDescendants()) do
						if prompt:IsA("ProximityPrompt") then
							prompt:InputHoldBegin()
							prompt:InputHoldEnd()
						end
					end

					task.wait(cooldown)

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
end

-- 🔁 run first time
runScript()

-- 🔁 run again on respawn
player.CharacterAdded:Connect(function()
	task.wait(1)
	runScript()
end)
