local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- 📦 UI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "PHUCMAX_UI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 80)
frame.Position = UDim2.new(0, 60, 0.5, -40)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Color = Color3.new(1, 1, 1)

local gradient = Instance.new("UIGradient", stroke)
gradient.Rotation = 0
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 170, 0)),
	ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
	ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
	ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 0, 255))
}
task.spawn(function()
	while frame.Parent do
		gradient.Rotation += 1
		task.wait(0.03)
	end
end)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.Text = "PHUCMAX"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true

local textGradient = Instance.new("UIGradient", title)
textGradient.Rotation = 0
textGradient.Color = gradient.Color
task.spawn(function()
	while title.Parent do
		textGradient.Rotation += 1
		task.wait(0.03)
	end
end)

local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(0.8, 0, 0, 30)
button.Position = UDim2.new(0.1, 0, 0, 40)
button.Text = "TELEPORT"
button.Font = Enum.Font.GothamBold
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

-- 🧠 CHỨC NĂNG
local speed = 49
local flying = false

local function getESPPart()
	for _, obj in ipairs(Workspace:GetChildren()) do
		if obj:IsA("Part") and obj.Name == "PhucBaseESPPart" then
			return obj
		end
	end
	return nil
end

local function getGroundHeight(position)
	local ray = RaycastParams.new()
	ray.FilterType = Enum.RaycastFilterType.Blacklist
	ray.FilterDescendantsInstances = {LocalPlayer.Character}
	local result = Workspace:Raycast(position, Vector3.new(0, -500, 0), ray)
	if result then return result.Position.Y else return 0 end
end

button.MouseButton1Click:Connect(function()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	if flying then return end
	flying = true

	local espPart = getESPPart()
	if not espPart then
		warn("⚠️ Không tìm thấy ESP part!")
		flying = false
		return
	end

	-- Tele lên trời
	local startY = 200
	hrp.CFrame = CFrame.new(hrp.Position.X, startY, hrp.Position.Z)

	local destination = espPart.Position + Vector3.new(0, 6, 0)
	local arrived = false

	-- Bay đến ESP
	local conn
	conn = RunService.RenderStepped:Connect(function()
		if not flying then conn:Disconnect() return end
		local direction = (destination - hrp.Position).Unit
		hrp.Velocity = direction * speed
		if (hrp.Position - destination).Magnitude <= 7 then
			arrived = true
			conn:Disconnect()
		end
	end)

	-- Chờ bay xong rồi rớt xuống
	while not arrived and flying do task.wait() end

	if flying then
		-- Tele xuống gần mặt đất
		local groundY = getGroundHeight(destination)
		hrp.CFrame = CFrame.new(destination.X, groundY + 3, destination.Z)
	end

	flying = false
end)


local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- 📦 UI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "PHUCMAX_TeleUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 80)
frame.Position = UDim2.new(0, 60, 0.5, -40)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(255, 0, 0)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.Text = "PHUCMAX TELE"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true

local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(0.8, 0, 0, 30)
button.Position = UDim2.new(0.1, 0, 0, 40)
button.Text = "TELEPORT"
button.Font = Enum.Font.GothamBold
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

-- 🧠 Hàm xử lý
local totalDuration = 4
local teleportDelay = 0.4
local farTeleportDelay = 0.7
local farPosition = Vector3.new(0.0, -340282346638528859811704183484516925440.0, 0.0)

local function getESPPart()
	for _, obj in ipairs(Workspace:GetChildren()) do
		if obj:IsA("Part") and obj.Name == "ESPBlock" then
			return obj
		end
	end
	return nil
end

local function startTeleportSequence()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	
	local startTime = tick()
	local lastFarTeleport = 0
	local running = true

	RunService.Heartbeat:Connect(function()
		if not running then return end
		local now = tick()
		if now - startTime > totalDuration then
			running = false
			return
		end

		if now - lastFarTeleport >= farTeleportDelay then
			hrp.CFrame = CFrame.new(farPosition)
			lastFarTeleport = now
		end
	end)

	task.spawn(function()
		while running do
			local esp = getESPPart()
			if esp then
				hrp.CFrame = CFrame.new(esp.Position + Vector3.new(0, 3, 0))
			end
			task.wait(teleportDelay)
		end
	end)
end

-- 🎮 Bắt đầu khi click nút
button.MouseButton1Click:Connect(function()
	startTeleportSequence()
end)
