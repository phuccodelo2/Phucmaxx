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

local function createTabWithIcon(name, assetId)
	local btn = Instance.new("TextButton", tabBar)
	btn.Size = UDim2.new(0, 100, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	-- Logo ảnh bên trái
	local icon = Instance.new("ImageLabel", btn)
	icon.Size = UDim2.new(0, 24, 0, 24)
	icon.Position = UDim2.new(0, 6, 0.5, -12)
	icon.Image = assetId or ""
	icon.BackgroundTransparency = 1

	-- Text bên phải icon
	local lbl = Instance.new("TextLabel", btn)
	lbl.Size = UDim2.new(1, -36, 1, 0)
	lbl.Position = UDim2.new(0, 36, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 14
	lbl.TextColor3 = Color3.new(1,1,1)
	lbl.TextXAlignment = Enum.TextXAlignment.Left

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

-- TẠO TAB MỚI VỚI ICON
local tabMain = createTabWithIcon("INFO", "rbxassetid://131027676437850")
local tabMain2 = createTabWithIcon("Main", "rbxassetid://131027676437850")
local tabPVP = createTabWithIcon("PVP", "rbxassetid://131027676437850")
local tabfixlag = createTabWithIcon("FIXLAG", "rbxassetid://131027676437850")
game.StarterGui:SetCore("SendNotification", {
    Title = "PHUCMAX",
    Text = "chào anh em nha",
    Duration = 5,
    Icon = "rbxassetid://131027676437850" -- thay bằng asset ID logo của mày
})
--------------------------------------------------------------------
createButton("📋 COPY LINK DISCORD", tabs["INFO"], function()
    local setClipboard = setclipboard or toclipboard or function() end
    setClipboard("https://discord.gg/A25WZXtRSG") 
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

-- Ví dụ script sẽ chạy khi nhấn
local function runScript()
    -- Thay đoạn này bằng script của mày
    print("Script đang chạy...")
    -- Ví dụ loadstring từ URL
    local url = "https://raw.githubusercontent.com/phuccodelo2/Phucmaxdepzai/refs/heads/main/phucdepzai.lua"
    pcall(function()
        loadstring(game:HttpGet(url))()
    end)
end
-- Tạo nút chạy script trong tab Main
createButton(" RUN SCRIPT FARM BOSS", tabs["Main"], runScript)

-- Ví dụ script sẽ chạy khi nhấn
local function runScript()
    -- Thay đoạn này bằng script của mày
    print("Script đang chạy...")
    -- Ví dụ loadstring từ URL
    local url = "https://raw.githubusercontent.com/phuccodelo2/Phucmaxx/refs/heads/main/CityNPC.lua"
    pcall(function()
        loadstring(game:HttpGet(url))()
    end)
end
-- Tạo nút chạy script trong tab Main
createButton(" RUN SCRIPT FARM NPC City", tabs["Main"], runScript)

-- Ví dụ script sẽ chạy khi nhấn
local function runScript()
    -- Thay đoạn này bằng script của mày
    print("Script đang chạy...")
    -- Ví dụ loadstring từ URL
    local url = "https://raw.githubusercontent.com/phuccodelo2/Phucmaxx/refs/heads/main/antiafk.lua"
    pcall(function()
        loadstring(game:HttpGet(url))()
    end)
end
-- Tạo nút chạy script trong tab Main
createButton(" RUN SCRIPT TREO MUSU", tabs["Main"], runScript)
    
-- Biến trạng thái tele
local teleEnabled = false

-- Hàm thực hiện tele
local function doTele()
    if teleEnabled then
        -- Thay đoạn này bằng code tele của mày
        print("Tele đang bật!")
        -- Ví dụ teleport tới vị trí nào đó
        local targetPos = Vector3.new(-2573.9, 278.3, -1535.8)
        LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(targetPos))
    end
end

-- Tạo nút toggle trong tab Main
createToggle("TELEPORT khu boss", tabs["Main"], function(state)
    teleEnabled = state
    if state then
        print("✅ Tele bật")
    else
        print("❌ Tele tắt")
    end
end)

-- Nếu muốn auto tele liên tục khi bật
RunService.RenderStepped:Connect(function()
    if teleEnabled then
        doTele()
    end
end)


-- Biến lưu FPS và Ping
local fpsLabel, pingLabel
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Nút FixLag X1
createButton("FixLag X1", tabfixlag, function()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Color = Color3.fromRGB(150,150,150)
            obj.Reflectance = 0
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Enabled = false
        end
    end
    print("✅ FixLag X1 applied")
end)

-- Nút FixLag X2
createButton("FixLag X2", tabfixlag, function()
    -- X1 trước
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Color = Color3.fromRGB(150,150,150)
            obj.Reflectance = 0
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Enabled = false
        end
    end
    -- Thêm X2
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:match("Leaf") or obj.Name:match("Tree") then
            obj:Destroy()
        elseif obj:IsA("UnionOperation") or obj:IsA("MeshPart") then
            obj.Transparency = 0.9
        end
    end
    -- Giảm ánh sáng
    local Lighting = game:GetService("Lighting")
    Lighting.GlobalShadows = false
    Lighting.Brightness = Lighting.Brightness * 0.3
    print("✅ FixLag X2 applied")
end)

-- Nút FixLag X3
createButton("FixLag X3", tabfixlag, function()
    -- X2 trước
    local Lighting = game:GetService("Lighting")
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Color = Color3.fromRGB(150,150,150)
            obj.Reflectance = 0
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Enabled = false
        end
        if obj.Name:match("Leaf") or obj.Name:match("Tree") then
            obj:Destroy()
        elseif obj:IsA("UnionOperation") or obj:IsA("MeshPart") then
            obj.Transparency = 0.9
        end
    end
    -- Tàng hình các vật thể đứng
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Anchored then
            obj.Transparency = 1
        end
    end
    Lighting.Brightness = Lighting.Brightness * 0.3
    print("✅ FixLag X3 applied")
end)

-- Nút FixLag Max
createButton(" FixLag MAX", tabfixlag, function()
    -- X3 trước
    local Lighting = game:GetService("Lighting")
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Color = Color3.fromRGB(150,150,150)
            obj.Reflectance = 0
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Enabled = false
        elseif obj:IsA("UnionOperation") or obj:IsA("MeshPart") then
            obj.Transparency = 1
        elseif obj.Name:match("Leaf") or obj.Name:match("Tree") then
            obj:Destroy()
        end
    end
    -- Giảm 80% ánh sáng
    Lighting.GlobalShadows = false
    Lighting.Brightness = Lighting.Brightness * 0.2
    -- Hiển thị FPS
    print("✅ FixLag MAX applied")
end)

local espPlayersEnabled = false
local espNPCsEnabled = false
local ESPFolder = workspace:FindFirstChild("PHUCMAX_ESP") or Instance.new("Folder", workspace)
ESPFolder.Name = "PHUCMAX_ESP"

-- Rainbow Color
local function rainbowColor()
    local hue = tick() % 5 / 5
    return Color3.fromHSV(hue, 1, 1)
end

-- Tạo ESP cho Humanoid
local function createHPESP(character)
    if not character or not character:FindFirstChild("Humanoid") or not character:FindFirstChild("HumanoidRootPart") then return end
    if ESPFolder:FindFirstChild(character.Name.."_ESP") then return end

    local hrp = character.HumanoidRootPart
    local humanoid = character.Humanoid

    local billboard = Instance.new("BillboardGui")
    billboard.Name = character.Name.."_ESP"
    billboard.Adornee = hrp
    billboard.Size = UDim2.new(0,120,0,30)
    billboard.StudsOffset = Vector3.new(0,3,0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = rainbowColor()
    label.TextScaled = true

    -- Update HP liên tục
    task.spawn(function()
        while label.Parent and humanoid.Parent do
            label.Text = math.floor(humanoid.Health).."/"..math.floor(humanoid.MaxHealth).." HP"
            label.TextColor3 = rainbowColor()
            task.wait(0.1)
        end
        if label.Parent then
            label.Parent:Destroy()
        end
    end)

    billboard.Parent = ESPFolder
end

-- Toggle ESP Player
createToggle("ESP MAU PLAYER", tabs["PVP"], function(state)
    espPlayersEnabled = state
    -- Xóa ESP cũ
    for _, v in pairs(ESPFolder:GetChildren()) do
        if Players:FindFirstChild(v.Adornee.Parent.Name) then
            v:Destroy()
        end
    end
    if state then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                createHPESP(plr.Character)
            end
        end
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local autoInventoryEnabled = false
local inventoryOpen = false

-- Toggle UI
createToggle("AUTO BAT TUIDO <60HP", tabs["Main"], function(state)
    autoInventoryEnabled = state
end)

local inventoryGUI = nil
local humanoid = nil

-- Lấy GUI inventory thật
local function updateInventoryGUI()
    inventoryGUI = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Inventory")
end

-- Lấy humanoid khi respawn
local function updateHumanoid(char)
    humanoid = char:WaitForChild("Humanoid")
end

-- Khi Character respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    updateHumanoid(char)
    updateInventoryGUI()
end)

-- Nếu đã có Character lúc script chạy
if LocalPlayer.Character then
    updateHumanoid(LocalPlayer.Character)
    updateInventoryGUI()
end

-- RenderStepped loop
RunService.RenderStepped:Connect(function()
    if not autoInventoryEnabled then return end
    if not humanoid or not inventoryGUI then return end

    -- Chỉ bật khi HP < 60 và GUI chưa bật
    if humanoid.Health < 60 and not inventoryOpen then
        inventoryGUI.Enabled = true
        inventoryOpen = true
        task.delay(3, function()
            if inventoryGUI then
                inventoryGUI.Enabled = false
                inventoryOpen = false
            end
        end)
    end
end)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Toggle rotation
local rotateEnabled = false
local gyro = nil
local angle = 0
local rotationSpeed = math.rad(1440) -- 1440 độ/giây

-- Nút bật/tắt SPIN
createToggle("SPIN", tabs["PVP"], function(state)
    rotateEnabled = state

    if state then
        -- Tạo BodyGyro khi bật
        if not gyro then
            gyro = Instance.new("BodyGyro")
            gyro.MaxTorque = Vector3.new(0, math.huge, 0)
            gyro.P = 10000
            gyro.D = 100 -- damping để mượt
            gyro.CFrame = HumanoidRootPart.CFrame
            gyro.Parent = HumanoidRootPart
        end
    else
        -- Xóa BodyGyro khi tắt để trả lại điều khiển
        if gyro then
            gyro:Destroy()
            gyro = nil
        end
    end
end)

-- Cập nhật xoay khi SPIN bật
RunService.RenderStepped:Connect(function(dt)
    if rotateEnabled and gyro and HumanoidRootPart then
        angle = angle + rotationSpeed * dt
        local pos = HumanoidRootPart.Position
        gyro.CFrame = CFrame.new(pos) * CFrame.Angles(0, angle, 0)
    end
end)


-- AUTO ATTACK (không ảnh hưởng màn hình)
local VirtualUser = game:GetService("VirtualUser")
local autoAttack = false

createToggle("AUTO ATTACK", tabs["PVP"], function(state)
    autoAttack = state
    if state then
        task.spawn(function()
            while autoAttack do
                pcall(function()
                    VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(0.05)
                    VirtualUser:Button1Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
                task.wait(0.1) -- delay giữa các click
            end
        end)
    end
end)

-- Luôn hướng mặt về player gần nhất & ít máu nhất
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local faceTarget = false
local gyro = nil

createToggle("LOCK LOWEST HP", tabs["PVP"], function(state)
    faceTarget = state

    if state then
        -- Tạo BodyGyro giữ hướng
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        gyro = Instance.new("BodyGyro")
        gyro.MaxTorque = Vector3.new(0, math.huge, 0)
        gyro.P = 10000
        gyro.D = 100
        gyro.Parent = hrp

        task.spawn(function()
            while faceTarget and gyro and hrp do
                pcall(function()
                    local closest, lowestHp = nil, math.huge
                    for _, plr in pairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") then
                            local hp = plr.Character.Humanoid.Health
                            local dist = (plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                            if hp > 0 and hp < lowestHp and dist < 500 then
                                lowestHp = hp
                                closest = plr
                            end
                        end
                    end

                    if closest and closest.Character and closest.Character:FindFirstChild("HumanoidRootPart") then
                        local targetPos = closest.Character.HumanoidRootPart.Position
                        -- Giữ nguyên vị trí, chỉ xoay hướng mặt
                        gyro.CFrame = CFrame.new(hrp.Position, Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z))
                    end
                end)
                task.wait(0.05)
            end
        end)
    else
        -- Tắt → xóa BodyGyro
        if gyro then
            gyro:Destroy()
            gyro = nil
        end
    end
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local humanoid = nil
local normalSpeed = 16 -- mặc định

-- Khi nhân vật respawn thì cập nhật lại humanoid
local function setupChar(char)
    humanoid = char:WaitForChild("Humanoid")
    if humanoid then
        normalSpeed = humanoid.WalkSpeed
    end
end

setupChar(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
LocalPlayer.CharacterAdded:Connect(setupChar)

-- Nút bật/tắt
createToggle("SPEED ", tabs["PVP"], function(state)
    if humanoid then
        if state then
            humanoid.WalkSpeed = 32
        else
            humanoid.WalkSpeed = normalSpeed
        end
    end
end)

toggleMenu()
