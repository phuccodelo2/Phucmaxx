-- KIỂM TRA ĐÃ LOAD UI CHƯA
if getgenv then
	if getgenv()._phucmax_ui_loaded then return end
	getgenv()._phucmax_ui_loaded = true
end

-- DỊCH VỤ
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- GUI CHÍNH
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "PhucmaxRainbowUI"
gui.ResetOnSpawn = false

-- VIỀN RAINBOW
local function createRainbowFrame(parent)
	local stroke = Instance.new("UIStroke", parent)
	stroke.Thickness = 2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Color3.new(1, 0, 0)
	task.spawn(function()
		local hue = 0
		while parent.Parent do
			hue = (hue + 1) % 255
			stroke.Color = Color3.fromHSV(hue / 255, 1, 1)
			task.wait(0.03)
		end
	end)
end

-- FRAME CHÍNH
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 280, 0, 340)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.ClipsDescendants = true
main.Visible = false
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
createRainbowFrame(main)

-- HIỆN MENU (có animation)
local function toggleMenu()
	main.Visible = true
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.Size = UDim2.new(0, 0, 0, 0)
	local tween = TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
		Size = UDim2.new(0, 280, 0, 340)
	})
	tween:Play()
end

-- THANH TAB
local tabBar = Instance.new("ScrollingFrame", main)
tabBar.Size = UDim2.new(1, -20, 0, 36)
tabBar.Position = UDim2.new(0, 10, 0, 10)
tabBar.ScrollBarThickness = 4
tabBar.ScrollingDirection = Enum.ScrollingDirection.X
tabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
tabBar.BackgroundTransparency = 1

local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 5)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- TỰ ĐỘNG CẬP NHẬT TAB SCROLL
local function updateTabCanvas()
	task.wait()
	local totalWidth = 0
	for _, child in pairs(tabBar:GetChildren()) do
		if child:IsA("TextButton") then
			totalWidth += child.Size.X.Offset + tabLayout.Padding.Offset
		end
	end
	tabBar.CanvasSize = UDim2.new(0, totalWidth, 0, 0)
end

-- KHUNG NỘI DUNG TAB
local tabContainer = Instance.new("Frame", main)
tabContainer.Size = UDim2.new(1, -20, 1, -60)
tabContainer.Position = UDim2.new(0, 10, 0, 50)
tabContainer.BackgroundTransparency = 1

-- TẠO TAB
local tabs, currentTab = {}, nil
local function switchTab(name)
	for i, v in pairs(tabs) do
		v.Visible = (i == name)
	end
end

local function createTab(name)
	local btn = Instance.new("TextButton", tabBar)
	btn.Size = UDim2.new(0, 80, 1, 0)
	btn.Text = name
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	local page = Instance.new("ScrollingFrame", tabContainer)
	page.Size = UDim2.new(1, 0, 1, 0)
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.ScrollBarThickness = 4
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.BackgroundTransparency = 1
	local layout = Instance.new("UIListLayout", page)
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	tabs[name] = page
	page.Visible = false

	btn.MouseButton1Click:Connect(function()
		switchTab(name)
	end)

	if not currentTab then
		currentTab = name
		page.Visible = true
	end

	updateTabCanvas()
	return page
end

-- NÚT TOGGLE
local function createToggle(text, parent, callback)
	local holder = Instance.new("Frame", parent)
	holder.Size = UDim2.new(0.9, 0, 0, 32)
	holder.BackgroundTransparency = 1
	local box = Instance.new("TextButton", holder)
	box.Size = UDim2.new(0, 28, 0, 28)
	box.Position = UDim2.new(0, 0, 0.5, -14)
	box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	box.Text = ""
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
	createRainbowFrame(box)
	local lbl = Instance.new("TextLabel", holder)
	lbl.Position = UDim2.new(0, 35, 0, 0)
	lbl.Size = UDim2.new(1, -35, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 14
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.TextXAlignment = Enum.TextXAlignment.Left

	local state = false
	box.MouseButton1Click:Connect(function()
		state = not state
		box.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(40, 40, 40)
		callback(state)
	end)
end

-- NÚT BÌNH THƯỜNG
local function createButton(text, parent, callback)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(0.9, 0, 0, 32)
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.MouseButton1Click:Connect(callback)
end

-- NÚT BẬT/TẮT MENU
local logo = Instance.new("ImageButton", gui)
logo.Size = UDim2.new(0, 48, 0, 48)
logo.Position = UDim2.new(0, 10, 0.5, -24)
logo.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
logo.Image = "rbxassetid://138187620176290"
logo.Draggable = true
Instance.new("UICorner", logo).CornerRadius = UDim.new(1, 0)
createRainbowFrame(logo)

logo.MouseButton1Click:Connect(function()
	if main.Visible then
		local tween = TweenService:Create(main, TweenInfo.new(0.2), {
			Size = UDim2.new(0, 0, 0, 0)
		})
		tween:Play()
		tween.Completed:Wait()
		main.Visible = false
	else
		toggleMenu()
	end
end)

-- TẠO CÁC TAB
local tabMain = createTab("INFO")
local tabMain = createTab("Main")
local tabESP = createTab("ESP")
local tabShop = createTab("Shop")

--------------------------------------------------------------------
createButton("📋 COPY LINK DISCORD", tabs["INFO"], function()
    local setClipboard = setclipboard or toclipboard or function() end
    setClipboard("https://discord.gg/RzN6vzeP") 
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "PHUCMAX",
            Text = "✅ copy link Discord!",
            Duration = 3
        })
    end)
end)

createButton("📋 COPY LINK facebook", tabs["INFO"], function()
    local setClipboard = setclipboard or toclipboard or function() end
    setClipboard("https://www.facebook.com/rHnewp7") 
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "PHUCMAX",
            Text = "✅ copy link Facebook!",
            Duration = 3
        })
    end)
end)

createButton("📋 COPY LINK tiktok", tabs["INFO"], function()
    local setClipboard = setclipboard or toclipboard or function() end
    setClipboard("phucmaxxxxxxxxx") 
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "PHUCMAX",
            Text = "✅ copy link TikTok!",
            Duration = 3
        })
    end)
end)

    

-- ESP PLAYER
local espEnabled = false
local espConnections = {}
local rainbowCycle = 0

local function createESP(player)
	if player == LocalPlayer then return end
	if not player.Character or not player.Character:FindFirstChild("Head") then return end
	if player.Character:FindFirstChild("PhucmaxESP") then return end

	local gui = Instance.new("BillboardGui", player.Character)
	gui.Name = "PhucmaxESP"
	gui.Size = UDim2.new(0, 100, 0, 30)
	gui.Adornee = player.Character:FindFirstChild("Head")
	gui.AlwaysOnTop = true

	local name = Instance.new("TextLabel", gui)
	name.Size = UDim2.new(1, 0, 1, 0)
	name.BackgroundTransparency = 1
	name.Font = Enum.Font.GothamBold
	name.TextScaled = true
	name.TextStrokeTransparency = 0
	name.Text = player.Name

	local hl = Instance.new("Highlight", player.Character)
	hl.Name = "PhucmaxHL"
	hl.FillTransparency = 1
	hl.OutlineTransparency = 0
	hl.OutlineColor = Color3.fromHSV(rainbowCycle, 1, 1)

	local conn = RunService.RenderStepped:Connect(function()
		rainbowCycle = (rainbowCycle + 0.005) % 1
		if name and name.Parent then
			name.TextColor3 = Color3.fromHSV(rainbowCycle, 1, 1)
		end
		if hl and hl.Parent then
			hl.OutlineColor = Color3.fromHSV(rainbowCycle, 1, 1)
		end
	end)

	table.insert(espConnections, conn)
end

local function clearAllESP()
	for _, p in pairs(Players:GetPlayers()) do
		if p.Character and p.Character:FindFirstChild("PhucmaxESP") then
			p.Character:FindFirstChild("PhucmaxESP"):Destroy()
		end
		if p.Character and p.Character:FindFirstChild("PhucmaxHL") then
			p.Character:FindFirstChild("PhucmaxHL"):Destroy()
		end
	end
	for _, c in pairs(espConnections) do
		if c then pcall(function() c:Disconnect() end) end
	end
	espConnections = {}
end

createToggle("ESP Player", tabESP, function(state)
	espEnabled = state
	if state then
		for _, p in pairs(Players:GetPlayers()) do
			createESP(p)
		end
	else
		clearAllESP()
	end
end)

Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function()
		if espEnabled then task.wait(1) createESP(p) end
	end)
end)

--------------------------------------------------------------------
-- ESP TIME LOCK
local timerESPEnabled = false
local timerESPParts = {}

local function clearTimerESP()
	for _, data in ipairs(timerESPParts) do
		if data.gui then pcall(function() data.gui:Destroy() end) end
		if data.part then pcall(function() data.part:Destroy() end) end
		if data.conn then pcall(function() data.conn:Disconnect() end) end
	end
	timerESPParts = {}
end

local function createTimerESP()
	local plots = Workspace:FindFirstChild("Plots")
	if not plots then return end

	for _, plot in ipairs(plots:GetChildren()) do
		if plot:IsA("Model") then
			for _, gui in ipairs(plot:GetDescendants()) do
				if gui:IsA("BillboardGui") and gui:FindFirstChild("RemainingTime") then
					local lbl = gui.RemainingTime
					local cf, size = plot:GetBoundingBox()
					local topPos = cf.Position + Vector3.new(0, size.Y / 2 + 5, 0)

					local part = Instance.new("Part", Workspace)
					part.Anchored = true
					part.CanCollide = false
					part.Transparency = 1
					part.Size = Vector3.new(1, 1, 1)
					part.CFrame = CFrame.new(topPos)

					local espGui = Instance.new("BillboardGui", Workspace)
					espGui.Name = "TimerESP"
					espGui.Adornee = part
					espGui.Size = UDim2.new(0, 120, 0, 30)
					espGui.AlwaysOnTop = true

					local txt = Instance.new("TextLabel", espGui)
					txt.Size = UDim2.new(1, 0, 1, 0)
					txt.BackgroundTransparency = 1
					txt.TextScaled = true
					txt.Font = Enum.Font.GothamBold
					txt.TextStrokeTransparency = 0.3
					txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

					local lastText = ""
					local tickCount = 0
					local hue = 0

					local conn = RunService.RenderStepped:Connect(function()
						if not timerESPEnabled or not espGui.Parent then return end

						local currentText = lbl.Text or ""
						if currentText == lastText then
							tickCount += 1
						else
							lastText = currentText
							tickCount = 0
						end

						if currentText ~= "" and currentText ~= "00:00:00" and tickCount < 300 then
							txt.Text = currentText
							hue = (hue + 0.01) % 1
							txt.TextColor3 = Color3.fromHSV(hue, 1, 1)
						elseif currentText == "00:00:00" then
							txt.Text = "EXPIRED"
							txt.TextColor3 = Color3.fromRGB(255, 0, 0)
						else
							txt.Text = "0"
							txt.TextColor3 = Color3.fromRGB(150, 150, 150)
						end
					end)

					table.insert(timerESPParts, {
						gui = espGui,
						part = part,
						conn = conn
					})
					break
				end
			end
		end
	end
end

createToggle("ESP Time Lock", tabESP, function(state)
	timerESPEnabled = state
	if state then createTimerESP()
	else clearTimerESP() end
end)

--------------------------------------------------------------------
-- SHOP BUY
local items = {
	"Invisibility Cloak",
	"Medusa's Head",
	"Quantum Cloner",
	"All Seeing Sentry",
	"Body Swap Potion",
	"Rainbowrath Sword",
	"Trap",
	"Web Slinger"
}

for _, name in ipairs(items) do
	createButton("Buy: " .. name, tabShop, function()
		local remote = game.ReplicatedStorage:WaitForChild("Packages")
			:WaitForChild("Net")
			:WaitForChild("RF/CoinsShopService/RequestBuy")
		pcall(function() remote:InvokeServer(name) end)
	end)
end

local espBaseLockClicked = false

local lockCoords = {
	Vector3.new(-301.7, -5.0, 220.5), Vector3.new(-302.9, -5.1, 113.5),
	Vector3.new(-301.1, -5.0, 6.1), Vector3.new(-350.6, -6.6, 221.2),
	Vector3.new(-517.7, -5.1, -99.7), Vector3.new(-518.7, -5.0, 6.4),
	Vector3.new(-517.0, -5.1, 112.6), Vector3.new(-301.7, -5.0, 220.5)
}

-- 📌 Tìm 2 toạ độ gần nhất trong 30 studs
local function getNearestTwo(posList, origin)
	local filtered = {}
	for _, pos in ipairs(posList) do
		local dist = (origin - pos).Magnitude
		if dist <= 60 then
			table.insert(filtered, {pos = pos, dist = dist})
		end
	end
	table.sort(filtered, function(a, b) return a.dist < b.dist end)
	return {
		filtered[1] and filtered[1].pos,
		filtered[2] and filtered[2].pos
	}
end

-- 📌 Tạo ESP khối + dòng chữ dưới
local function createESPText(pos, text)
	local part = Instance.new("Part", workspace)
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 0.8
	part.Size = Vector3.new(1.5, 1.5, 1.5)
	part.Position = pos
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 255, 255)
	part.Name = "ESP_"..text

	local gui = Instance.new("BillboardGui", part)
	gui.Size = UDim2.new(0, 100, 0, 30)
	gui.AlwaysOnTop = true
	gui.Adornee = part
	gui.StudsOffset = Vector3.new(0, -2, 0) -- Text nằm dưới Part

	local label = Instance.new("TextLabel", gui)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextStrokeTransparency = 0.3
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.Text = text

	local h = 0
	game:GetService("RunService").RenderStepped:Connect(function()
		if label and label.Parent and label:IsDescendantOf(game) then
			h = (h + 0.01) % 1
			label.TextColor3 = Color3.fromHSV(h, 1, 1)
			part.Color = label.TextColor3
		end
	end)
end

-- 📌 Nút lưu ESP LOCK
createButton("Save LOCK", tabs["ESP"], function()
	if espBaseLockClicked then return end
	espBaseLockClicked = true

	local char = game.Players.LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end

	local origin = char.HumanoidRootPart.Position
	local nearestLock = getNearestTwo(lockCoords, origin)

	for _, pos in ipairs(nearestLock) do
		if pos then createESPText(pos, "LOCK") end
	end
end)

local teleJumpEnabled = false

local function getNearestESPLock()
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local closestPart = nil
	local shortest = math.huge

	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:IsA("Part") and obj.Name == "ESP_LOCK" then
			local dist = (obj.Position - hrp.Position).Magnitude
			if dist < shortest then
				shortest = dist
				closestPart = obj
			end
		end
	end

	return closestPart
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local selectedPlayer = nil
local autoTeleConnection

-- 📦 Frame chứa dropdown
local dropdownFrame = Instance.new("Frame", tabMain)
dropdownFrame.Size = UDim2.new(0.9, 0, 0, 32)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 6)

-- 📌 Nút mở dropdown
local dropdown = Instance.new("TextButton", dropdownFrame)
dropdown.Size = UDim2.new(1, 0, 1, 0)
dropdown.Text = "Chọn người chơi"
dropdown.TextColor3 = Color3.new(1, 1, 1)
dropdown.Font = Enum.Font.GothamBold
dropdown.TextSize = 14
dropdown.BackgroundTransparency = 1

-- 📜 Scrolling danh sách người chơi
local scrollFrame = Instance.new("ScrollingFrame", tabMain)
scrollFrame.Size = UDim2.new(0.9, 0, 0, 100)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 4
scrollFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
scrollFrame.Visible = false
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 6)

local listLayout = Instance.new("UIListLayout", scrollFrame)
listLayout.Padding = UDim.new(0, 2)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- 📂 Mở danh sách
dropdown.MouseButton1Click:Connect(function()
	scrollFrame.Visible = not scrollFrame.Visible
	scrollFrame:ClearAllChildren()
	Instance.new("UIListLayout", scrollFrame).Padding = UDim.new(0, 2)

	local count = 0
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			count += 1
			local btn = Instance.new("TextButton", scrollFrame)
			btn.Size = UDim2.new(1, 0, 0, 24)
			btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.Text = player.Name
			btn.Font = Enum.Font.GothamBold
			btn.TextSize = 12
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

			btn.MouseButton1Click:Connect(function()
				selectedPlayer = player
				dropdown.Text = "🎯 " .. player.Name
				scrollFrame.Visible = false
			end)
		end
	end

	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, count * 26)
end)

-- 🔁 Toggle: Auto Tele + Click
createToggle("teleplayer", tabMain, function(state)
	if autoTeleConnection then
		autoTeleConnection:Disconnect()
		autoTeleConnection = nil
	end

	if state then
		autoTeleConnection = RunService.Heartbeat:Connect(function()
			if not selectedPlayer then return end

			local targetChar = selectedPlayer.Character
			local targetHRP = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
			local myChar = LocalPlayer.Character
			local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
			if not targetHRP or not myHRP then return end

			-- Tính hướng mặt và di chuyển tới phía sau
			local behindOffset = targetHRP.CFrame.LookVector * -3
			myHRP.CFrame = CFrame.new(targetHRP.Position + behindOffset, targetHRP.Position)

			-- Auto click
			VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
			VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
		end)
	end
end)

local flyingToLock = false

local function getNearestESPLock()
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local closestPart = nil
	local shortest = math.huge

	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:IsA("Part") and obj.Name == "ESP_LOCK" then
			local dist = (obj.Position - hrp.Position).Magnitude
			if dist < shortest then
				shortest = dist
				closestPart = obj
			end
		end
	end

	return closestPart
end

local function flySmoothTo(pos, speed)
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	while (hrp.Position - pos).Magnitude > 3 and flyingToLock do
		local dir = (pos - hrp.Position).Unit
		hrp.CFrame = hrp.CFrame + dir * (speed / 60)
		task.wait(1/60)
	end
end

local flyingToLock = false

local function getNearestESPLock()
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local closestPart = nil
	local shortest = math.huge

	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:IsA("Part") and obj.Name == "ESP_LOCK" then
			local dist = (obj.Position - hrp.Position).Magnitude
			if dist < shortest then
				shortest = dist
				closestPart = obj
			end
		end
	end

	return closestPart
end

local function flySmoothTo(pos, speed)
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	while (hrp.Position - pos).Magnitude > 3 and flyingToLock do
		local dir = (pos - hrp.Position).Unit
		hrp.CFrame = hrp.CFrame + dir * (speed / 60)
		task.wait(1/60)
	end
end

createToggle("fly to base ", tabs["Main"], function(state)
	flyingToLock = state
	if state then
		task.spawn(function()
			while flyingToLock do
				local target = getNearestESPLock()
				local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if target and hrp then
					local abovePos = target.Position + Vector3.new(0, 2, 0)
					flySmoothTo(abovePos, 49)
				end
				task.wait(0.1)
			end
		end)
	end
end)

local espBaseClicked = false

local baseCoords = {
	Vector3.new(-346.8, -6.6, -101.2),
	Vector3.new(-345.8, -6.5, 4.1),
	Vector3.new(-346.6, -6.6, 113.4),
	Vector3.new(-345.4, -6.6, 218.9),
	Vector3.new(-471.6, -6.5, 221.9),
	Vector3.new(-472.0, -6.5, 114.9),
	Vector3.new(-471.8, -6.6, 6.6),
	Vector3.new(-474.5, -6.6, -99.6)
}

-- 📌 Tìm toạ độ gần nhất trong 30 studs
local function getNearestBase(posList, origin)
	local closest, minDist = nil, math.huge
	for _, pos in ipairs(posList) do
		local dist = (origin - pos).Magnitude
		if dist <= 60 and dist < minDist then
			minDist = dist
			closest = pos
		end
	end
	return closest
end

-- 📌 Tạo ESP khối + dòng chữ dưới
local function createESPTextBase(pos, text)
	local part = Instance.new("Part", workspace)
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 0.8
	part.Size = Vector3.new(1.5, 1.5, 1.5)
	part.Position = pos
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 255, 255)
	part.Name = "ESP_"..text

	local gui = Instance.new("BillboardGui", part)
	gui.Size = UDim2.new(0, 100, 0, 30)
	gui.AlwaysOnTop = true
	gui.Adornee = part
	gui.StudsOffset = Vector3.new(0, -2, 0)

	local label = Instance.new("TextLabel", gui)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextStrokeTransparency = 0.3
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.Text = text

	local h = 0
	game:GetService("RunService").RenderStepped:Connect(function()
		if label and label.Parent and label:IsDescendantOf(game) then
			h = (h + 0.01) % 1
			label.TextColor3 = Color3.fromHSV(h, 1, 1)
			part.Color = label.TextColor3
		end
	end)
end


-- 📌 UI chọn Player & Tele + AutoClick
local VirtualInputManager = game:GetService("VirtualInputManager")


createButton("Sky Ascend", tabs["Main"], function()
    local link = "https://raw.githubusercontent.com/phuccodelo2/Phucmaxx/refs/heads/main/Tele.lua" -- Thay bằng link raw của bạn
    local success, result = pcall(function()
        loadstring(game:HttpGet(link))()
    end)
    
    if success then
        print("Script chạy thành công!")
    else
        warn("Lỗi chạy script:", result)
    end
end)

toggleMenu()
