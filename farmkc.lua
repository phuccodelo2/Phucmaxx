-- Auto Finder + Teleport + Follow + Auto-Interact (GUI + logs + ESP)
-- Dán vào executor (tra giúp) hoặc LocalScript trong PlayerGui (nếu được)
-- Giải thích: các comment bên dưới giải thích từng dòng / khối

-- ===== Services =====
local Players = game:GetService("Players")                 -- lấy service Players
local RunService = game:GetService("RunService")           -- để follow mỗi frame
local Workspace = game:GetService("Workspace")             -- workspace để quét object
local StarterGui = game:GetService("StarterGui")          -- dùng gửi notification
local HttpService = game:GetService("HttpService")         -- dùng nếu cần encode (debug)
local Camera = Workspace.CurrentCamera                     -- lấy camera hiện tại (dùng khi simulate click)

-- ===== Player / GUI root =====
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")    -- parent GUI cho an toàn

-- ===== Config - chỉnh ở đây =====
local DEFAULT_KEYWORD = "diamond"      -- từ khoá mặc định để tìm vật (thay bằng tên vật trang trí)
local SCAN_INTERVAL = 5                -- giây giữa 2 lần scan tự động (nếu bật)
local FOLLOW_OFFSET = Vector3.new(0, 2, 0) -- offset HRP so với part khi follow (đứng trên nó)
local AUTO_SCAN = false                -- nếu true sẽ auto scan định kỳ
local AUTO_COLLECT_AFTER_TELEPORT = false -- nếu true, sau teleport script sẽ cố tương tác

-- ===== Try lấy VirtualInputManager (nếu executor hỗ trợ) =====
local okVIM, VirtualInputManager = pcall(function()
	return game:GetService("VirtualInputManager")
end)
if not okVIM then
	-- một vài executor expose VirtualInputManager ở _G hoặc global, thử lấy
	if _G and _G.VirtualInputManager then
		VirtualInputManager = _G.VirtualInputManager
		okVIM = true
	else
		VirtualInputManager = nil
		okVIM = false
	end
end

-- ===== State =====
local results = {}         -- bảng chứa các vật tìm thấy { part = Part, root = Instance, path = string }
local followConn = nil     -- connection follow (Heartbeat)
local highlightList = {}   -- list highlight / billboard để clear
local uiOpen = true

-- ===== GUI cơ bản để debug và dùng nhanh =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFinderGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 360)
frame.Position = UDim2.new(0, 20, 0, 60)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -20, 0, 30)
title.Position = UDim2.new(0, 10, 0, 8)
title.BackgroundTransparency = 1
title.Text = "Auto Finder"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255,255,255)

-- input từ khoá
local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0, 250, 0, 28)
input.Position = UDim2.new(0, 10, 0, 46)
input.Text = DEFAULT_KEYWORD
input.ClearTextOnFocus = false

local btnScan = Instance.new("TextButton", frame)
btnScan.Size = UDim2.new(0, 80, 0, 28)
btnScan.Position = UDim2.new(0, 270, 0, 46)
btnScan.Text = "Scan"
btnScan.Font = Enum.Font.Gotham
btnScan.TextSize = 14

local btnClear = Instance.new("TextButton", frame)
btnClear.Size = UDim2.new(0, 120, 0, 28)
btnClear.Position = UDim2.new(0, 360, 0, 46)
btnClear.Text = "Clear Results"
btnClear.Font = Enum.Font.Gotham
btnClear.TextSize = 14

-- checkbox auto-scan
local chkAuto = Instance.new("TextButton", frame)
chkAuto.Position = UDim2.new(0, 10, 0, 84)
chkAuto.Size = UDim2.new(0, 140, 0, 26)
chkAuto.Text = "Auto Scan: OFF"
chkAuto.Font = Enum.Font.Gotham
chkAuto.TextSize = 14

-- checkbox auto collect
local chkAutoCollect = Instance.new("TextButton", frame)
chkAutoCollect.Position = UDim2.new(0, 160, 0, 84)
chkAutoCollect.Size = UDim2.new(0, 160, 0, 26)
chkAutoCollect.Text = "Auto Collect: OFF"
chkAutoCollect.Font = Enum.Font.Gotham
chkAutoCollect.TextSize = 14

-- result list container
local listFrame = Instance.new("ScrollingFrame", frame)
listFrame.Position = UDim2.new(0, 10, 0, 120)
listFrame.Size = UDim2.new(1, -20, 1, -130)
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
listFrame.ScrollBarThickness = 6
listFrame.BackgroundTransparency = 1

local listLayout = Instance.new("UIListLayout", listFrame)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 6)

-- helper: update canvas size
local function updateCanvas()
	task.wait()
	local total = 0
	for _, v in ipairs(listFrame:GetChildren()) do
		if v:IsA("TextButton") then
			total = total + v.Size.Y.Offset + listLayout.Padding.Offset
		end
	end
	listFrame.CanvasSize = UDim2.new(0, 0, 0, total)
end

-- helper: clear existing highlights & list
local function clearResults()
	-- dừng follow nếu có
	if followConn then
		pcall(function() followConn:Disconnect() end)
		followConn = nil
	end
	-- xóa highlight
	for _, h in ipairs(highlightList) do
		pcall(function() h:Destroy() end)
	end
	highlightList = {}
	-- dọn list UI
	for _, child in ipairs(listFrame:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	results = {}
	updateCanvas()
end

-- ===== utility: lấy "repPart" (BasePart đại diện) cho một Instance =====
local function getRepresentativePart(obj)
	-- trả BasePart nếu obj chính là BasePart
	if not obj then return nil end
	if obj:IsA("BasePart") then return obj end
	-- nếu là Model, ưu tiên PrimaryPart, rồi HumanoidRootPart, rồi first BasePart
	if obj:IsA("Model") then
		if obj.PrimaryPart and obj.PrimaryPart:IsA("BasePart") then
			return obj.PrimaryPart
		end
		local hrp = obj:FindFirstChild("HumanoidRootPart")
		if hrp and hrp:IsA("BasePart") then return hrp end
		local first = obj:FindFirstChildWhichIsA("BasePart", true)
		if first then return first end
	end
	-- nếu không tìm thấy, trả nil
	return nil
end

-- ===== tạo highlight/ESP đơn giản cho part =====
local function makeHighlightFor(part)
	if not part or not part.Parent then return end
	-- tạo Highlight (outline) nếu chạy client (Highlight tồn tại runtime)
	local ok, hl = pcall(function()
		local h = Instance.new("Highlight")
		h.Adornee = part
		h.Parent = workspace
		h.Name = "AutoFinderHL"
		return h
	end)
	if ok and hl then
		table.insert(highlightList, hl)
	end
	-- tạo BillboardGui nhỏ hiển thị tên
	pcall(function()
		local bg = Instance.new("BillboardGui")
		bg.Adornee = part
		bg.Size = UDim2.new(0, 160, 0, 28)
		bg.AlwaysOnTop = true
		bg.Parent = part

		local lbl = Instance.new("TextLabel", bg)
		lbl.Size = UDim2.new(1,0,1,0)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = Color3.fromRGB(255,255,255)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextScaled = true
		lbl.Text = part.Name
		table.insert(highlightList, bg)
	end)
end

-- ===== scan toàn workspace theo keyword, trả về bảng kết quả =====
local function scanForKeyword(keyword)
	local found = {}
	local low = (keyword or ""):lower()
	if low == "" then return found end

	for _, obj in ipairs(Workspace:GetDescendants()) do
		-- pcall để tránh crash nếu object bị destroy giữa chừng
		local ok, name = pcall(function() return obj.Name end)
		if ok and name and type(name) == "string" then
			if string.find(name:lower(), low, 1, true) then
				-- tìm phần đại diện
				local rep = getRepresentativePart(obj)
				if rep and rep.Parent then
					table.insert(found, {root = obj, part = rep, path = obj:GetFullName(), class = obj.ClassName})
				end
			end
		end
	end
	return found
end

-- ===== show results vào UI =====
local function showResults(found)
	clearResults()
	for i, data in ipairs(found) do
		-- tạo button cho mỗi kết quả
		local b = Instance.new("TextButton", listFrame)
		b.Size = UDim2.new(1, -10, 0, 36)
		b.Position = UDim2.new(0, 5, 0, 0)
		b.TextXAlignment = Enum.TextXAlignment.Left
		b.Font = Enum.Font.Gotham
		b.TextSize = 14
		b.BackgroundColor3 = Color3.fromRGB(40,40,40)
		b.TextColor3 = Color3.fromRGB(255,255,255)
		b.Text = string.format("[%s] %s", data.class, data.path)
		-- khi click button: teleport -> follow -> auto-interact nếu bật
		b.MouseButton1Click:Connect(function()
			-- teleport ngay
			pcall(function()
				LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = data.part.CFrame + FOLLOW_OFFSET
			end)
			-- highlight
			makeHighlightFor(data.part)
			-- follow
			if followConn then pcall(function() followConn:Disconnect() end) end
			followConn = RunService.Heartbeat:Connect(function()
				if not data.part or not data.part.Parent then
					pcall(function() followConn:Disconnect() end)
					followConn = nil
					return
				end
				-- set HRP theo part (bám chặt)
				pcall(function()
					LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = data.part.CFrame + FOLLOW_OFFSET
				end)
			end)
			-- nếu bật auto-collect, cố tương tác
			if chkAutoCollect.Text == "Auto Collect: ON" then
				-- priority 1: ProximityPrompt
				local ancestor = data.part:FindFirstAncestorOfClass("Model") or data.part.Parent
				local prompt = nil
				if ancestor then
					prompt = ancestor:FindFirstChildWhichIsA("ProximityPrompt", true)
				end
				if not prompt then
					prompt = data.part:FindFirstChildWhichIsA("ProximityPrompt", true)
				end

				if prompt then
					-- nếu có VIM, spam phím E, nếu không, thử thông báo
					if okVIM and VirtualInputManager then
						spawn(function()
							while prompt and prompt.Parent and data.part and data.part.Parent do
								-- nhấn E down/up
								pcall(function()
									VirtualInputManager:SendKeyEvent(true, "E", false, game)
									task.wait(0.06)
									VirtualInputManager:SendKeyEvent(false, "E", false, game)
								end)
								task.wait(0.35)
							end
						end)
					else
						warn("[AutoFinder] Found ProximityPrompt but VirtualInputManager unavailable.")
					end
					return
				end

				-- priority 2: ClickDetector -> simulate click on screen position
				local clickDet = nil
				if ancestor then
					clickDet = ancestor:FindFirstChildWhichIsA("ClickDetector", true)
				end
				if not clickDet then
					clickDet = data.part:FindFirstChildWhichIsA("ClickDetector", true)
				end
				if clickDet then
					if okVIM and VirtualInputManager and Camera then
						spawn(function()
							while data.part and data.part.Parent do
								local ok2, screenX, screenY, onScreen = pcall(function()
									local x,y,z = Camera:WorldToViewportPoint(getRepresentativePart(data.root).Position)
									return x,y,z
								end)
								if ok2 and screenX and screenY then
									pcall(function()
										VirtualInputManager:SendMouseButtonEvent(screenX, screenY, true, game)
										task.wait(0.06)
										VirtualInputManager:SendMouseButtonEvent(screenX, screenY, false, game)
									end)
								end
								task.wait(0.5)
							end
						end)
					else
						warn("[AutoFinder] Found ClickDetector but cannot simulate mouse (VIM missing or Camera nil).")
					end
					return
				end

				-- priority 3: cố chạm (touch) HRP vào part - nhiều game pickup khi chạm
				spawn(function()
					while data.part and data.part.Parent do
						pcall(function()
							LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = data.part.CFrame + FOLLOW_OFFSET
						end)
						task.wait(0.25)
					end
				end)
			end
		end)
		table.insert(results, data)
	end
	updateCanvas()
end

-- ===== main scan function (gọi khi nhấn Scan) =====
local function doScan()
	local kw = tostring(input.Text or DEFAULT_KEYWORD)
	local found = scanForKeyword(kw)
	if #found == 0 then
		StarterGui:SetCore("SendNotification", {Title="AutoFinder", Text="No results for: "..kw, Duration=3})
	else
		StarterGui:SetCore("SendNotification", {Title="AutoFinder", Text="Found "..#found.." results for: "..kw, Duration=3})
	end
	showResults(found)
end

-- ===== wire UI buttons =====
btnScan.MouseButton1Click:Connect(function()
	doScan()
end)
btnClear.MouseButton1Click:Connect(function()
	clearResults()
end)

chkAuto.MouseButton1Click:Connect(function()
	AUTO_SCAN = not AUTO_SCAN
	chkAuto.Text = "Auto Scan: " .. (AUTO_SCAN and "ON" or "OFF")
end)

chkAutoCollect.MouseButton1Click:Connect(function()
	AUTO_COLLECT_AFTER_TELEPORT = not AUTO_COLLECT_AFTER_TELEPORT
	chkAutoCollect.Text = "Auto Collect: " .. (AUTO_COLLECT_AFTER_TELEPORT and "ON" or "OFF")
end)

-- ===== optional autop-run loop nếu bật AUTO_SCAN =====
spawn(function()
	while true do
		if AUTO_SCAN then
			pcall(doScan)
		end
		task.wait(SCAN_INTERVAL)
	end
end)

-- ===== quick instructions shown in console =====
print("[AutoFinder] GUI created. Type keyword (e.g. 'diamond') and press Scan.")
print("[AutoFinder] VirtualInputManager available:", okVIM)
print("[AutoFinder] If auto-interact not working, likely VirtualInputManager missing or item requires server-side remote call.")