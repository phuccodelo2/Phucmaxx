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

-- SỬA createTab để hỗ trợ icon
local function createTab(name, iconId)
	local btn = Instance.new("TextButton", tabBar)
	btn.Size = UDim2.new(0, 100, 1, 0)
	btn.Text = ""
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	-- Icon
	if iconId then
		local img = Instance.new("ImageLabel", btn)
		img.Size = UDim2.new(0, 18, 0, 18)
		img.Position = UDim2.new(0, 6, 0.5, -9)
		img.BackgroundTransparency = 1
		img.Image = iconId
	end

	-- Chữ
	local lbl = Instance.new("TextLabel", btn)
	lbl.Size = UDim2.new(1, -26, 1, 0)
	lbl.Position = UDim2.new(0, 26, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 14
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.TextXAlignment = Enum.TextXAlignment.Left

	-- Page
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

-- ICON LIST (mày thay ID khác nếu thích)
local icons = {
	INFO = "rbxassetid://131027676437850",  -- icon info
	Main = "rbxassetid://131027676437850",  -- icon gear
	ESP  = "rbxassetid://131027676437850",  -- icon eye
	Shop = "rbxassetid://131027676437850"   -- icon cart
}

-- TẠO CÁC TAB (không bị trùng tên nữa)
local tabINFO = createTab("INFO", icons.INFO)
local tabMAIN = createTab("Main", icons.Main)
local tabESP  = createTab("ESP", icons.ESP)
local tabSHOP = createTab("Shop", icons.Shop)

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
logo.Image = "rbxassetid://131027676437850"
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
--------------------------------------------------------------------
createButton("📋 COPY LINK DISCORD", tabs["INFO"], function()
    local setClipboard = setclipboard or toclipboard or function() end
    setClipboard("https://discord.gg/ckGyMq2K") 
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

createButton("📋 COPY ID tiktok", tabs["INFO"], function()
    local setClipboard = setclipboard or toclipboard or function() end
    setClipboard("phucmaxxxxxxxxx") 
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "PHUCMAX",
            Text = "✅ copy ID TikTok!",
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
		if espEnabled then task.wait(2) createESP(p) end
	end)
end)

--------------------------------------------------------------------

-- ESP TIME LOCK FIXED
local timerESPEnabled = false
local timerESPParts = {}

local function clearTimerESP()
	for _, data in ipairs(timerESPParts) do
		pcall(function()
			if data.conn then data.conn:Disconnect() end
			if data.gui then data.gui:Destroy() end
			if data.part then data.part:Destroy() end
		end)
	end
	timerESPParts = {}
end

local function createTimerESP()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return end

	for _, plot in ipairs(plots:GetChildren()) do
		if plot:IsA("Model") then
			for _, gui in ipairs(plot:GetDescendants()) do
				if gui:IsA("BillboardGui") and gui:FindFirstChild("RemainingTime") then
					local lbl = gui.RemainingTime

					-- Nếu đã có rồi thì bỏ qua
					local already = false
					for _, data in ipairs(timerESPParts) do
						if data.label == lbl then
							already = true
							break
						end
					end
					if already then continue end

					-- Tạo part ESP
					local part = Instance.new("Part")
					part.Anchored = true
					part.CanCollide = false
					part.Transparency = 1
					part.Size = Vector3.new(1, 1, 1)
					part.Parent = workspace

					-- GUI
					local espGui = Instance.new("BillboardGui")
					espGui.Name = "TimerESP"
					espGui.Adornee = part
					espGui.Size = UDim2.new(0, 120, 0, 30)
					espGui.AlwaysOnTop = true
					espGui.Parent = part

					local txt = Instance.new("TextLabel")
					txt.Size = UDim2.new(1, 0, 1, 0)
					txt.BackgroundTransparency = 1
					txt.TextScaled = true
					txt.Font = Enum.Font.GothamBold
					txt.TextStrokeTransparency = 0.3
					txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
					txt.Parent = espGui

					local lastText = ""
					local tickCount = 0
					local hue = 0

					local conn = game:GetService("RunService").Heartbeat:Connect(function()
						if not timerESPEnabled then return end
						if not plot.Parent then return end

						-- Update vị trí theo plot
						local cf, size = plot:GetBoundingBox()
						part.CFrame = CFrame.new(cf.Position + Vector3.new(0, size.Y / 2 + 5, 0))

						-- Update text
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
						label = lbl,
					})

					break
				end
			end
		end
	end
end

-- Toggle ESP
createToggle("ESP Time ", tabESP, function(state)
	timerESPEnabled = state
	if state then
		clearTimerESP()
		createTimerESP()
	else
		clearTimerESP()
	end
end)

--------------------------------------------------------------------
-- SHOP BUY
local items = {
    "Slap",
    "Speed Coil",
    "Trap",
    "Iron Slap",
    "Gravity Coil",
    "Bee Launcher",
    "Gold Slap",
    "Coil Combo",
    "Rage Table",
    "Diamond Slap",
    "Grapple Hook",
    "Taser Gun",
    "Emerald Slap",
    "Invisibility Cloak",
    "Boogie Bomb",
    "Ruby Slap",
    "Medusa’s Head",
    "Dark Matter Slap",
    "Web Slinger",
    "Flame Slap",
    "Quantum Cloner",
    "All Seeing Sentry",
    "Nuclear Slap",
    "Rainbowrath Sword",
    "Galaxy Slap",
    "Laser Cape",
    "Glitched Slap",
    "Body Swap Potion",
    "Splatter Slap",
    "Paintball Gun",
    "Heart Balloon",
    "Magnet",
    "Megaphone",
    "Beehive",
    "Gummy Bear",
    "Subspace Mine",
    "Heatseeker"
}

for _, name in ipairs(items) do
	createButton("Buy: " .. name, tabSHOP, function()
		local remote = game.ReplicatedStorage:WaitForChild("Packages")
			:WaitForChild("Net")
			:WaitForChild("RF/CoinsShopService/RequestBuy")
		pcall(function() remote:InvokeServer(name) end)
	end)
end

-- 📌 ESP PET VIP FIXED
local petESPEnabled = false
local petVIPList = {
	"cocofanto elefanto", 
"gattatino nyanino",
 "girafa celestre", 
"matteo",
 "tralalero tralala",
	"odin din din dun", 
"unclito samito", 
"trenostruzzo turbo 3000", 
"tigroligre frutonni", 
"orcalero orcala",
	"la vacca saturno saturnita", 
"sammyni spiderini",
 "torrtuginni dragonfrutini", 
"los tralaleritos",
	"las tralaleritas", 
"graipuss medussi",
 "pot hotspot", 
"la grande combinazione", 
"garama and madundung",
	"Trenostruzzo Turbo 4000",
    "Fragola La La La",
    "La Sahur Combinasion",
    "La Karkerkar Combinasion",
    "Las Sis",
    "Celularcini Viciosini",
    "Tralalalaledon",
    "Los Tacoritas",
    "Los Bros",
    "Antonio",
    "Las Capuchinas",
    "Orcalita Orcala",
    "Dug Dug Dug",
    "Piccionetta Macchina",
    "Anpali Babel",
    "Belula Beluga"
}
local petESPList = {}

-- 🌈 Rainbow Color
local function getRainbow(t)
	return Color3.fromHSV((t % 5) / 5, 1, 1)
end

-- 📌 Tạo ESP Pet
local function createPetESP(part, text)
	if part:FindFirstChild("PhucPetESP") then return end -- tránh trùng lặp

	local gui = Instance.new("BillboardGui")
	gui.Name = "PhucPetESP"
	gui.Size = UDim2.new(0, 200, 0, 40)
	gui.StudsOffset = Vector3.new(0, 3, 0)
	gui.AlwaysOnTop = true
	gui.Adornee = part
	gui.Parent = part

	local lbl = Instance.new("TextLabel", gui)
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBold
	lbl.TextScaled = true
	lbl.Text = "🎯 " .. text
	lbl.Name = "Rainbow"
	lbl.TextStrokeTransparency = 0.2

	table.insert(petESPList, gui)
end

-- 📌 Xoá toàn bộ ESP
local function clearPetESP()
	for _, gui in ipairs(petESPList) do
		if gui and gui.Parent then
			pcall(function() gui:Destroy() end)
		end
	end
	petESPList = {}
end

-- 📌 Quét PET VIP
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

-- 🌈 Update Rainbow + Auto Scan
task.spawn(function()
	while true do
		if petESPEnabled then
			local t = tick()
			for _, gui in ipairs(petESPList) do
				if gui:IsA("BillboardGui") and gui:FindFirstChild("Rainbow") then
					gui.Rainbow.TextColor3 = getRainbow(t)
				end
			end
			scanPET() -- liên tục quét pet mới spawn
		end
		task.wait(2) -- quét mỗi 2s, không spam quá nặng
	end
end)

-- 📌 Toggle ESP
createToggle("ESP Brainrot ", tabs["ESP"], function(state)
	petESPEnabled = state
	if state then
		clearPetESP()
		scanPET()
	else
		clearPetESP()
	end
end)

createButton("Rejoin Server", tabMAIN, function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
end)

createButton("AIRWALK", tabMAIN, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/phuccodelo2/server-ids/refs/heads/main/slab.lua"))()
end)

createButton("FLOAT", tabMAIN, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/phuccodelo2/server-ids/refs/heads/main/float.lua"))()
end)
toggleMenu()
-- PetNotifierServer.lua (ServerScriptService)
-- Sends Discord webhook when a VIP pet is detected in workspace

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- CONFIG
local WEBHOOK_URL = " https://discord.com/api/webhooks/1417918916080177233/7gGiv9Wr171HWnuRUqJJDDkmX4MIuq1rjoBmZeheKYOObeF-OEUyUpy4512XpkvWwgg5" -- <-- put your Discord webhook url here
local scanInterval = 5        -- seconds between scans
local cooldownSec = 300       -- cooldown per pet (seconds) to avoid spam

-- Pet list (use the list you provided)
local petVIPList = {
	"cocofanto elefanto", "gattatino nyanino", "girafa celestre", "matteo",
	"tralalero tralala", "odin din din dun", "unclito samito",
	"trenostruzzo turbo 3000", "tigroligre frutonni", "orcalero orcala",
	"la vacca saturno saturnita", "sammyni spiderini", "torrtuginni dragonfrutini",
	"los tralaleritos", "las tralaleritas", "graipuss medussi", "pot hotspot",
	"la grande combinazione", "garama and madundung",
	"Trenostruzzo Turbo 4000","Fragola La La La","La Sahur Combinasion",
	"La Karkerkar Combinasion","Las Sis","Celularcini Viciosini",
	"Tralalalaledon","Los Tacoritas","Los Bros","Antonio","Las Capuchinas",
	"Orcalita Orcala","Dug Dug Dug","Piccionetta Macchina","Anpali Babel","Belula Beluga"
}

-- helper set for faster case-insensitive matching
local petLowerSet = {}
for _, v in ipairs(petVIPList) do
	petLowerSet[string.lower(v)] = true
end

-- keep track of notifications: key = petNameLower, value = lastTickSent (os.time())
local notified = {}

local function isPetNameMatch(name)
	if not name then return false end
	local low = string.lower(name)
	-- check exact match or contains any vip substring
	if petLowerSet[low] then return true end
	for vipNameLower, _ in pairs(petLowerSet) do
		if string.find(low, vipNameLower, 1, true) then
			return true
		end
	end
	return false
end

local function buildJoinInfo()
	-- PlaceId and JobId
	local placeId = tostring(game.PlaceId or 0)
	local jobId = tostring(game.JobId or "unknown")
	-- A simple join "hint" (some clients might not support direct link)
	local joinUrl = ("https://www.roblox.com/games/%s/%s"):format(placeId, jobId)
	return placeId, jobId, joinUrl
end

local function sendDiscordWebhook(petName, petInstance)
	if not WEBHOOK_URL or WEBHOOK_URL == "" then
		warn("Webhook URL not set. Skipping Discord notify.")
		return
	end

	local placeId, jobId, joinUrl = buildJoinInfo()
	local playersCount = #Players:GetPlayers()
	local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- UTC ISO

	-- Compose embed
	local embed = {
		title = "🐾 VIP BRAINROT DETECTED",
		description = ("**Name:** %s\n**PlaceId:** %s\n**JobId:** %s\n**Players:** %d\n**Detected at (UTC):** %s")
			:format(tostring(petName), placeId, jobId, playersCount, timestamp),
		color = 16753920, -- orange
		fields = {
			{
				name = "Join (PlaceId/JobId)",
				value = "`PlaceId:` "..placeId.."  \n`JobId:` "..jobId,
				inline = false
			},
			{
				name = "Join Link (open in browser)",
				value = joinUrl,
				inline = false
			},
			{
				name = "Client join snippet",
				value = "Use this LocalScript snippet to join this server (paste into console / executor for testing):\n```lua\nlocal TeleportService = game:GetService(\"TeleportService\")\nTeleportService:TeleportToPlaceInstance("..placeId..", \""..jobId.."\", game.Players.LocalPlayer)\n```",
				inline = false
			}
		},
		timestamp = timestamp
	}

	local payload = {
		username = "PetNotifier",
		embeds = { embed }
	}

	local ok, result = pcall(function()
		return HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
	end)

	if not ok then
		warn("Failed to POST webhook:", result)
		return false, result
	end

	return true, result
end

-- scan function
local function scanWorkspaceOnce()
	-- collect candidate pet instances (Model or BasePart) that match names
	for _, obj in ipairs(Workspace:GetDescendants()) do
		-- skip if object is destroyed during loop
		if not obj or not obj.Parent then continue end

		local name = obj.Name
		if isPetNameMatch(name) then
			local key = string.lower(name)
			local now = os.time()
			local last = notified[key]
			if last and (now - last) < cooldownSec then
				-- already notified recently
			else
				-- found a pet - send webhook
				local sent, err = pcall(function()
					sendDiscordWebhook(name, obj)
				end)
				if sent then
					notified[key] = now
					print("[PetNotifier] Notified pet:", name)
				else
					warn("[PetNotifier] Error sending webhook for pet:", name, err)
				end
			end
		end
	end
end

-- periodic loop
task.spawn(function()
	while true do
		pcall(scanWorkspaceOnce)
		task.wait(scanInterval)
	end
end)