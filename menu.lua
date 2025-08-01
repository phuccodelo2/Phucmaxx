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
logo.Image = "rbxassetid://113632547593752"
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

local function espAlreadyExists(lbl)
	for _, data in ipairs(timerESPParts) do
		if data.label == lbl then
			return true
		end
	end
	return false
end

local function createTimerESP()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return end

	for _, plot in ipairs(plots:GetChildren()) do
		if plot:IsA("Model") then
			for _, gui in ipairs(plot:GetDescendants()) do
				if gui:IsA("BillboardGui") and gui:FindFirstChild("RemainingTime") then
					local lbl = gui.RemainingTime
					if espAlreadyExists(lbl) then continue end

					local cf, size = plot:GetBoundingBox()
					local topPos = cf.Position + Vector3.new(0, size.Y / 2 + 5, 0)

					local part = Instance.new("Part", workspace)
					part.Anchored = true
					part.CanCollide = false
					part.Transparency = 1
					part.Size = Vector3.new(1, 1, 1)
					part.CFrame = CFrame.new(topPos)

					local espGui = Instance.new("BillboardGui", workspace)
					espGui.Name = "TimerESP"
					espGui.Adornee = part
					espGui.Size = UDim2.new(0, 120, 0, 30)
					espGui.AlwaysOnTop = true

					local txt = Instance.new("TextLabel", espGui)
					txt.Size = UDim2.new(1, 0, 1, 0)
					txt.BackgroundTransparency = 1
					txt.TextScaled = true
					txt.Font = Enum.Font.GothamBold
					txt.TextStrokeTransparency = 1
					txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

					local lastText = ""
					local tickCount = 0
					local hue = 0

					local conn = game:GetService("RunService").RenderStepped:Connect(function()
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
						conn = conn,
						label = lbl
					})
					break
				end
			end
		end
	end
end

-- Toggle để bật/tắt
createToggle("ESP Time Lock", tabESP, function(state)
	timerESPEnabled = state
	if state then
		createTimerESP()
	else
		for _, data in ipairs(timerESPParts) do
			pcall(function()
				if data.conn then data.conn:Disconnect() end
				if data.gui then data.gui:Destroy() end
				if data.part then data.part:Destroy() end
			end)
		end
		timerESPParts = {}
	end
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

-- ESP PET VIP
local petESPEnabled = false
local petVIPList = {
	"cocofanto elefanto", "gattatino nyanino", "girafa celestre", "matteo", "tralalero tralala",
	"odin din din dun", "unclito samito", "trenostruzzo turbo 3000", "tigroligre frutonni", "orcalero orcala",
	"la vacca saturno saturnita", "sammyni spiderini", "torrtuginni dragonfrutini", "los tralaleritos",
	"las tralaleritas", "graipuss medussi", "pot hotspot", "la grande combinazione", "garama and madundung"
}
local petESPList = {}

local function getRainbow(tickVal)
	local r = math.sin(tickVal) * 127 + 128
	local g = math.sin(tickVal + 2) * 127 + 128
	local b = math.sin(tickVal + 4) * 127 + 128
	return Color3.fromRGB(r, g, b)
end

local function createPetESP(part, text)
	if part:FindFirstChild("PhucPetESP") then return end
	local gui = Instance.new("BillboardGui", part)
	gui.Name = "PhucPetESP"
	gui.Size = UDim2.new(0, 200, 0, 40)
	gui.StudsOffset = Vector3.new(0, 3, 0)
	gui.AlwaysOnTop = true
	gui.Adornee = part

	local lbl = Instance.new("TextLabel", gui)
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBold
	lbl.TextScaled = true
	lbl.Text = "🎯 " 
	lbl.Name = "Rainbow"
	lbl.TextStrokeTransparency = 0.2

	table.insert(petESPList, gui)
end

local function clearPetESP()
	for _, gui in ipairs(petESPList) do
		if gui and gui.Parent then
			pcall(function() gui:Destroy() end)
		end
	end
	petESPList = {}
end

local function scanPET()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") or obj:IsA("Part") then
			local name = obj.Name:lower()
			for _, pet in ipairs(petVIPList) do
				if name:find(pet:lower()) then
					local target = obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") or obj
					if target then
						createPetESP(target, obj.Name)
					end
					break
				end
			end
		end
	end
end

-- ESP PET Rainbow update
task.spawn(function()
	while true do
		local t = tick()
		for _, gui in ipairs(petESPList) do
			if gui:IsA("BillboardGui") and gui:FindFirstChild("Rainbow") then
				gui.Rainbow.TextColor3 = getRainbow(t)
			end
		end
		task.wait(0.1)
	end
end)

-- Tạo Toggle trong Tab ESP
createToggle("ESP brainrot VIP", tabs["ESP"], function(state)
	petESPEnabled = state
	if state then
		clearPetESP()
		scanPET()
	else
		clearPetESP()
	end
end)

createButton("new Server", tabMain, function()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local placeId = game.PlaceId

    local function serverHop()
        local lowestCount = math.huge
        local selectedServer = nil
        local nextPageCursor = ""

        repeat
            local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
            if nextPageCursor ~= "" then
                url = url .. "&cursor=" .. nextPageCursor
            end

            local success, response = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(url))
            end)

            if success and response and response.data then
                for _, server in ipairs(response.data) do
                    if server.id ~= game.JobId and server.playing < server.maxPlayers then
                        if server.playing < lowestCount then
                            lowestCount = server.playing
                            selectedServer = server
                        end
                    end
                end
                nextPageCursor = response.nextPageCursor or ""
            else
                break
            end
        until not nextPageCursor

        if selectedServer then
            TeleportService:TeleportToPlaceInstance(placeId, selectedServer.id, player)
        else
            warn("Không tìm thấy server khả dụng.")
        end
    end

    serverHop()
end)

createButton("Rejoin Server", tabMain, function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
end)

createButton("TELEPORT", tabMain, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/phuccodelo2/Phucmaxx/refs/heads/main/xxx%20(1).txt"))()
end)

-- NÚT NHẢY CAO 300

createToggle("ESP Player", tabESP, function(state)
    local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")

    if state then
        hum.UseJumpPower = true
        hum.JumpPower = 300
    else
        hum.JumpPower = 40 -- hoặc JumpHeight mặc định bạn muốn
    end
end)

-- High Jump Toggle


createButton("FIXLAG", tabMain, function()
    -- Xoá toàn bộ hiệu ứng, particles, trails, smoke, fire, sparkles...
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Explosion") then
            v:Destroy()
        end
    end

    -- Xoá toàn bộ Decals & Textures
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        end
    end

    -- Xoá tất cả Lighting Effects (bóng đổ, blur, color correction...)
    local lighting = game:GetService("Lighting")
    for _, v in pairs(lighting:GetChildren()) do
        if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") then
            v:Destroy()
        end
    end

    -- Giảm tối đa chất lượng vật thể
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            v.CastShadow = false
        end
    end

    -- Xoá tất cả các tường (Wall = Part lớn đứng thẳng)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Part") and v.Size.Y > v.Size.X and v.Size.Y > v.Size.Z and v.Anchored and v.Position.Y > 10 then
            v:Destroy()
        end
    end

    -- Tắt các chi tiết phụ của bản đồ (Meshes & các part trang trí nhỏ)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("MeshPart") or v:IsA("UnionOperation") then
            v:Destroy()
        end
    end

    -- Tắt Terrain nếu có
    if workspace:FindFirstChildOfClass("Terrain") then
        workspace.Terrain:Clear()
    end

    -- Tắt Water nếu có
    workspace.FallenPartsDestroyHeight = -50000
    if lighting:FindFirstChild("Atmosphere") then
        lighting.Atmosphere:Destroy()
    end

    -- Bật FPS cao nhất (nếu dùng Trigon hoặc Synapse có thể dùng setfpscap)
    pcall(function()
        setfpscap(999999)
    end)

    -- Tắt Shadows và Global Shadows
    lighting.GlobalShadows = false
    lighting.FogEnd = 1000000000

    -- Xoá Sky nếu có
    for _, v in pairs(lighting:GetChildren()) do
        if v:IsA("Sky") then
            v:Destroy()
        end
    end

    print("✅ Đã fix lag tối đa.")
end)

-- GIÁ TRỊ NHẢY CAO
local UserInputService = game:GetService("UserInputService")

local function createSlider(text, parent, min, max, default, callback)
	local holder = Instance.new("Frame", parent)
	holder.Size = UDim2.new(0.9, 0, 0, 70)
	holder.BackgroundTransparency = 1

	local label = Instance.new("TextLabel", holder)
	label.Size = UDim2.new(1, 0, 0, 20)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text .. ": " .. tostring(default)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left

	local sliderBar = Instance.new("Frame", holder)
	sliderBar.Size = UDim2.new(1, 0, 0, 10)
	sliderBar.Position = UDim2.new(0, 0, 0, 30)
	sliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	sliderBar.BorderSizePixel = 0
	Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame", sliderBar)
	fill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BorderSizePixel = 0
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("TextButton", sliderBar)
	knob.Size = UDim2.new(0, 24, 0, 24) -- Lớn hơn cho dễ chạm
	knob.Position = UDim2.new((default - min) / (max - min), -12, 0.5, -12)
	knob.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	knob.Text = ""
	knob.AutoButtonColor = false
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local dragging = false

	local function update(input)
		local pos = input.Position.X - sliderBar.AbsolutePosition.X
		local percent = math.clamp(pos / sliderBar.AbsoluteSize.X, 0, 1)
		local value = math.floor(min + (max - min) * percent)
		fill.Size = UDim2.new(percent, 0, 1, 0)
		knob.Position = UDim2.new(percent, -12, 0.5, -12)
		label.Text = text .. ": " .. tostring(value)
		callback(value)
	end

	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)

	knob.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end)
end

createToggle("Speed", tabMain, function(state)
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")

	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local hrp = character:WaitForChild("HumanoidRootPart")

	local speed = 49

	if state then
		-- Nếu bật toggle
		_G._speedConnection = RunService.RenderStepped:Connect(function()
			if humanoid and humanoid.MoveDirection.Magnitude > 0 then
				hrp.Velocity = humanoid.MoveDirection * speed + Vector3.new(0, hrp.Velocity.Y, 0)
			end
		end)
	else
		-- Nếu tắt toggle
		if _G._speedConnection then
			_G._speedConnection:Disconnect()
			_G._speedConnection = nil
		end
		if humanoid then
			humanoid.WalkSpeed = 49 -- Trả lại tốc độ bình thường
		end
	end
end)

createToggle("Infinite Jump", tabMain, function(state)
    local UIS = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    if state then
        _G._infiniteJumpConnection = UIS.JumpRequest:Connect(function()
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(0, 50, 0)
            end
        end)
    else
        if _G._infiniteJumpConnection then
            _G._infiniteJumpConnection:Disconnect()
            _G._infiniteJumpConnection = nil
        end
    end
end)

toggleMenu()
