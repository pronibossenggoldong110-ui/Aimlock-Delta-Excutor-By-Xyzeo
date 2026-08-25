-- Aim Assist GUI
-- Untuk game Roblox milik sendiri

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local enabled = false
local maxDistance = 150
local target = nil

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AimAssistGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 230, 0, 170)
main.Position = UDim2.new(0, 20, 0.5, -85)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

-- Judul
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "🎯 AIM ASSIST"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = main

-- Tombol ON/OFF
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -30, 0, 40)
toggle.Position = UDim2.new(0, 15, 0, 50)
toggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
toggle.Text = "AIM ASSIST: OFF"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.TextSize = 15
toggle.Font = Enum.Font.GothamBold
toggle.Parent = main

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggle

-- Jarak
local distanceText = Instance.new("TextLabel")
distanceText.Size = UDim2.new(1, -30, 0, 25)
distanceText.Position = UDim2.new(0, 15, 0, 100)
distanceText.BackgroundTransparency = 1
distanceText.Text = "Jarak: 150"
distanceText.TextColor3 = Color3.new(1,1,1)
distanceText.TextSize = 14
distanceText.Font = Enum.Font.Gotham
distanceText.Parent = main

-- Slider
local slider = Instance.new("TextButton")
slider.Size = UDim2.new(1, -30, 0, 10)
slider.Position = UDim2.new(0, 15, 0, 130)
slider.BackgroundColor3 = Color3.fromRGB(70,70,75)
slider.Text = ""
slider.AutoButtonColor = false
slider.Parent = main

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1,0)
sliderCorner.Parent = slider

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 14, 0, 14)
knob.Position = UDim2.new(1, -7, 0.5, -7)
knob.BackgroundColor3 = Color3.new(1,1,1)
knob.BorderSizePixel = 0
knob.Parent = slider

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1,0)
knobCorner.Parent = knob

-- Cari target terdekat
local function getNearestTarget()
	local character = player.Character
	if not character then
		return nil
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end

	local nearest = nil
	local nearestDistance = maxDistance

	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player and other.Character then
			local humanoid = other.Character:FindFirstChildOfClass("Humanoid")
			local otherRoot = other.Character:FindFirstChild("HumanoidRootPart")

			if humanoid and otherRoot and humanoid.Health > 0 then
				local distance = (root.Position - otherRoot.Position).Magnitude

				if distance < nearestDistance then
					nearestDistance = distance
					nearest = other
				end
			end
		end
	end

	return nearest
end

-- Toggle
toggle.MouseButton1Click:Connect(function()
	enabled = not enabled
	target = nil

	if enabled then
		toggle.Text = "AIM ASSIST: ON"
		toggle.BackgroundColor3 = Color3.fromRGB(50, 170, 80)
	else
		toggle.Text = "AIM ASSIST: OFF"
		toggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	end
end)

-- Slider jarak
slider.MouseButton1Down:Connect(function()
	local connection

	connection = RunService.RenderStepped:Connect(function()
		local mouse = UserInputService:GetMouseLocation()
		local absolute = slider.AbsolutePosition
		local size = slider.AbsoluteSize

		local percent = math.clamp(
			(mouse.X - absolute.X) / size.X,
			0,
			1
		)

		maxDistance = math.floor(25 + (percent * 275))

		distanceText.Text = "Jarak: " .. maxDistance

		knob.Position = UDim2.new(
			percent,
			-7,
			0.5,
			-7
		)
	end)

	UserInputService.InputEnded:Wait()
	connection:Disconnect()
end)

-- Tombol Q
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.Q then
		enabled = not enabled
		target = nil

		if enabled then
			toggle.Text = "AIM ASSIST: ON"
			toggle.BackgroundColor3 = Color3.fromRGB(50, 170, 80)
		else
			toggle.Text = "AIM ASSIST: OFF"
			toggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
		end
	end
end)

-- Aim Assist
RunService.RenderStepped:Connect(function()
	if not enabled then
		return
	end

	if not target
		or not target.Character
		or not target.Character:FindFirstChild("HumanoidRootPart")
		or not target.Character:FindFirstChildOfClass("Humanoid")
		or target.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then

		target = getNearestTarget()
	end

	if target and target.Character then
		local head = target.Character:FindFirstChild("Head")
		local humanoid = target.Character:FindFirstChildOfClass("Humanoid")

		if head and humanoid and humanoid.Health > 0 then
			local myCharacter = player.Character
			local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")

			if myRoot then
				local distance = (myRoot.Position - head.Position).Magnitude

				if distance <= maxDistance then
					camera.CFrame = CFrame.lookAt(
						camera.CFrame.Position,
						head.Position
					)
				else
					target = nil
				end
			end
		end
	end
end)

-- Drag GUI
local dragging = false
local dragStart
local startPos

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPos = main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then

		local delta = input.Position - dragStart

		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)
