-- ItemSpy UI: Scan toàn map, list items, copy teleport code / copy all names
-- Dán vào executor (hoặc LocalScript trong PlayerGui nếu được)
-- LƯU Ý: Use executor functions (setclipboard / toclipboard) nếu muốn copy tự động.

-- ===== Services & player =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

-- ===== Helpers =====
local function safeClipboardSet(text)
    -- thử một số hàm clipboard phổ biến trên executors
    local ok
    if setclipboard then
        pcall(function() setclipboard(text) end)
        return true
    elseif toclipboard then
        pcall(function() toclipboard(text) end)
        return true
    elseif syn and syn.set_clipboard then
        pcall(function() syn.set_clipboard(text) end)
        return true
    else
        return false
    end
end

local function getRepresentativePart(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        if obj.PrimaryPart and obj.PrimaryPart:IsA("BasePart") then return obj.PrimaryPart end
        local hrp = obj:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:IsA("BasePart") then return hrp end
        local first = obj:FindFirstChildWhichIsA("BasePart", true)
        if first then return first end
    end
    return nil
end

-- Lấy full path (string) của 1 instance
local function getFullPath(inst)
    local parts = {}
    local cur = inst
    while cur and cur.Parent do
        table.insert(parts, 1, cur.Name)
        cur = cur.Parent
        if cur:IsA("DataModel") then break end
    end
    return table.concat(parts, ".")
end

-- ===== GUI Build =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ItemSpyGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 480, 0, 520)
main.Position = UDim2.new(0, 20, 0, 50)
main.BackgroundColor3 = Color3.fromRGB(28,28,30)
main.BorderSizePixel = 0
main.ClipsDescendants = true

local UICorner = Instance.new("UICorner", main)
UICorner.CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -20, 0, 34)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Text = "Item Spy — Scan map & Copy Code"

-- search box
local input = Instance.new("TextBox", main)
input.Size = UDim2.new(0, 280, 0, 30)
input.Position = UDim2.new(0, 10, 0, 50)
input.PlaceholderText = "Filter by name (press Enter to apply)"
input.Text = ""

local btnScan = Instance.new("TextButton", main)
btnScan.Size = UDim2.new(0, 100, 0, 30)
btnScan.Position = UDim2.new(0, 300, 0, 50)
btnScan.Text = "Scan"
btnScan.Font = Enum.Font.Gotham
btnScan.TextSize = 14

local btnCopyAll = Instance.new("TextButton", main)
btnCopyAll.Size = UDim2.new(0, 150, 0, 30)
btnCopyAll.Position = UDim2.new(0, 410, 0, 50)
btnCopyAll.Text = "Copy All Names"
btnCopyAll.Font = Enum.Font.Gotham
btnCopyAll.TextSize = 14

-- results list
local listFrame = Instance.new("ScrollingFrame", main)
listFrame.Size = UDim2.new(1, -20, 1, -110)
listFrame.Position = UDim2.new(0, 10, 0, 92)
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
listFrame.ScrollBarThickness = 8
listFrame.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", listFrame)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)

-- helper update canvas
local function updateCanvas()
    task.wait()
    local total = 0
    for _,child in ipairs(listFrame:GetChildren()) do
        if child:IsA("Frame") then
            total = total + child.Size.Y.Offset + layout.Padding.Offset
        end
    end
    listFrame.CanvasSize = UDim2.new(0, 0, 0, total)
end

-- ===== scanning logic =====
local lastResults = {}

local function scanMap(filter)
    filter = (filter or ""):lower()
    local found = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local ok, name = pcall(function() return obj.Name end)
        if ok and name and type(name) == "string" then
            if filter == "" or string.find(name:lower(), filter, 1, true) then
                local part = getRepresentativePart(obj)
                if part and part.Parent then
                    local pos = nil
                    pcall(function() pos = part.Position end)
                    table.insert(found, {
                        root = obj,
                        part = part,
                        name = name,
                        class = obj.ClassName,
                        path = getFullPath(obj),
                        position = pos
                    })
                end
            end
        end
    end
    return found
end

-- clear UI list
local function clearList()
    for _, c in ipairs(listFrame:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    lastResults = {}
    updateCanvas()
end

-- make one result row
local function makeRow(data, index)
    local row = Instance.new("Frame", listFrame)
    row.Size = UDim2.new(1, -10, 0, 48)
    row.Position = UDim2.new(0, 5, 0, 0)
    row.BackgroundColor3 = Color3.fromRGB(40,40,40)
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -220, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(230,230,230)
    lbl.Text = string.format("[%s] %s", data.class, data.path)

    local posLabel = Instance.new("TextLabel", row)
    posLabel.Size = UDim2.new(0, 200, 0, 16)
    posLabel.Position = UDim2.new(1, -210, 0, 6)
    posLabel.BackgroundTransparency = 1
    posLabel.Font = Enum.Font.Gotham
    posLabel.TextSize = 12
    posLabel.TextColor3 = Color3.fromRGB(200,200,200)
    if data.position then
        posLabel.Text = ("Pos: %.2f, %.2f, %.2f"):format(data.position.X, data.position.Y, data.position.Z)
    else
        posLabel.Text = "Pos: (unknown)"
    end

    local btnTP = Instance.new("TextButton", row)
    btnTP.Size = UDim2.new(0, 90, 0, 28)
    btnTP.Position = UDim2.new(1, -100, 0, 10)
    btnTP.Text = "Teleport"
    btnTP.Font = Enum.Font.Gotham
    btnTP.TextSize = 14

    local btnCopy = Instance.new("TextButton", row)
    btnCopy.Size = UDim2.new(0, 90, 0, 28)
    btnCopy.Position = UDim2.new(1, -200, 0, 10)
    btnCopy.Text = "Copy Code"
    btnCopy.Font = Enum.Font.Gotham
    btnCopy.TextSize = 14

    -- hành động Teleport (di chuyển HRP)
    btnTP.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
        if hrp and data.position then
            pcall(function()
                hrp.CFrame = CFrame.new(data.position + Vector3.new(0, 3, 0))
                StarterGui:SetCore("SendNotification", {Title="ItemSpy", Text="Teleported to "..data.name, Duration=3})
            end)
        else
            StarterGui:SetCore("SendNotification", {Title="ItemSpy", Text="Cannot teleport (no HRP or unknown pos)", Duration=3})
        end
    end)

    -- hành động Copy Code: copy snippet Lua để teleport tới vị trí (useful)
    btnCopy.MouseButton1Click:Connect(function()
        local snippet
        if data.position then
            snippet = ("-- Teleport snippet to item '%s' (position)\nlocal player = game.Players.LocalPlayer\nlocal char = player.Character or player.CharacterAdded:Wait()\nlocal hrp = char:WaitForChild('HumanoidRootPart')\nhrp.CFrame = CFrame.new(%.6f, %.6f, %.6f)\n"):format(data.name, data.position.X, data.position.Y + 3, data.position.Z)
        else
            snippet = ("-- Find by path (may need to adjust)\nlocal item = game:GetService('Workspace')%s\nprint(item)\n"):format("['"..data.path:gsub("'", "\\'").."']")
        end

        local ok = safeClipboardSet(snippet)
        if ok then
            StarterGui:SetCore("SendNotification", {Title="ItemSpy", Text="Code copied to clipboard", Duration=2})
        else
            -- fallback: tạo TextBox tạm để người dùng copy thủ công
            local box = Instance.new("TextBox", screenGui)
            box.Size = UDim2.new(0, 600, 0, 200)
            box.Position = UDim2.new(0.5, -300, 0.5, -100)
            box.Text = snippet
            box.TextWrapped = true
            box.ClearTextOnFocus = false
            box.MultiLine = true
            box.Font = Enum.Font.SourceSans
            box.TextSize = 14
            box.Selectable = true
            box.Active = true
            box.BackgroundColor3 = Color3.fromRGB(20,20,20)
            Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)
            box:CaptureFocus()
            StarterGui:SetCore("SendNotification", {Title="ItemSpy", Text="Copy manually: textbox opened", Duration=4})
            -- đóng khi click ra ngoài hoặc sau 20s
            spawn(function()
                task.wait(20)
                if box and box.Parent then pcall(function() box:Destroy() end) end
            end)
        end
    end)
end

-- show found list
local function showFound(found)
    clearList()
    for i, data in ipairs(found) do
        makeRow(data, i)
    end
    updateCanvas()
    lastResults = found
end

-- copy all names as Lua table
btnCopyAll.MouseButton1Click:Connect(function()
    local names = {}
    for _, d in ipairs(lastResults) do
        table.insert(names, d.name)
    end
    local luaTable = "local items = {\n"
    for _, n in ipairs(names) do
        luaTable = luaTable .. ("    %q,\n"):format(n)
    end
    luaTable = luaTable .. "}\n"
    local ok = safeClipboardSet(luaTable)
    if ok then
        StarterGui:SetCore("SendNotification", {Title="ItemSpy", Text="Copied all names as Lua table", Duration=3})
    else
        -- fallback textbox
        local box = Instance.new("TextBox", screenGui)
        box.Size = UDim2.new(0, 600, 0, 200)
        box.Position = UDim2.new(0.5, -300, 0.5, -100)
        box.Text = luaTable
        box.TextWrapped = true
        box.ClearTextOnFocus = false
        box.MultiLine = true
        box.Font = Enum.Font.SourceSans
        box.TextSize = 14
        box.Selectable = true
        box.Active = true
        box.BackgroundColor3 = Color3.fromRGB(20,20,20)
        Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)
        box:CaptureFocus()
        StarterGui:SetCore("SendNotification", {Title="ItemSpy", Text="Copy manually: textbox opened", Duration=4})
        spawn(function()
            task.wait(20)
            if box and box.Parent then pcall(function() box:Destroy() end) end
        end)
    end
end)

-- Scan button action
btnScan.MouseButton1Click:Connect(function()
    local kw = input.Text or ""
    local found = scanMap(kw)
    showFound(found)
end)

-- Allow Enter key in TextBox to scan
input.FocusLost:Connect(function(enter)
    if enter then
        local kw = input.Text or ""
        local found = scanMap(kw)
        showFound(found)
    end
end)

-- Auto initial scan on load
do
    local found = scanMap("")
    showFound(found)
end

-- Cleanup when player leaves (optional)
Players.PlayerRemoving:Connect(function(p)
    if p == LocalPlayer then
        pcall(function() screenGui:Destroy() end)
    end
end)

-- End of script