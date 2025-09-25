-- Auto-Teleport + Follow + Auto-Interact (ProximityPrompt / ClickDetector / Touch)
-- YÊU CẦU: môi trường cho phép VirtualInputManager (executor). Nếu không có VIM, script vẫn teleport + follow nhưng không simulate input.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- Cố gắng lấy VirtualInputManager (không bắt buộc nhưng cần cho simulate)
local okVIM, VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end)
if not okVIM then
    -- một số executor expose VirtualInputManager theo global; thử lấy global
    if _G and _G.VirtualInputManager then
        VirtualInputManager = _G.VirtualInputManager
        okVIM = true
    else
        VirtualInputManager = nil
        okVIM = false
    end
end

-- ================== CẤU HÌNH ==================
local targetKeyword = "diamond"          -- <- đổi keyword ở đây (case-insensitive)
local followOffset = Vector3.new(0, 2, 0) -- vị trí HRP so với part khi bám chặt
local scanInterval = 3                    -- giây giữa mỗi lần scan map
-- =================================================

local activeFollowConn = nil

-- Tìm 1 part đại diện cho object có tên chứa keyword (case-insensitive)
local function findTargetPart(keyword)
    local low = string.lower(keyword)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name and type(obj.Name) == "string" then
            if string.find(string.lower(obj.Name), low, 1, true) then
                -- nếu là Part / MeshPart -> trả về nó
                if obj:IsA("BasePart") then
                    return obj
                end
                -- nếu là Model -> ưu tiên PrimaryPart -> HumanoidRootPart -> first BasePart
                if obj:IsA("Model") then
                    if obj.PrimaryPart and obj.PrimaryPart:IsA("BasePart") then
                        return obj.PrimaryPart
                    end
                    local hrpCandidate = obj:FindFirstChild("HumanoidRootPart")
                    if hrpCandidate and hrpCandidate:IsA("BasePart") then
                        return hrpCandidate
                    end
                    local firstPart = obj:FindFirstChildWhichIsA("BasePart", true)
                    if firstPart then return firstPart end
                end
            end
        end
    end
    return nil
end

-- Bám chặt theo part (cập nhật mỗi frame)
local function followPart(part)
    -- hủy connection cũ nếu có
    if activeFollowConn then
        pcall(function() activeFollowConn:Disconnect() end)
        activeFollowConn = nil
    end

    activeFollowConn = RunService.Heartbeat:Connect(function()
        if not part or not part.Parent then
            -- target biến mất -> ngắt follow
            pcall(function() activeFollowConn:Disconnect() end)
            activeFollowConn = nil
            return
        end
        -- Cố gắng set CFrame (bọc pcall để tránh crash)
        pcall(function()
            hrp.CFrame = part.CFrame + followOffset
        end)
    end)
end

-- Simulate pressing 'E' (ProximityPrompt)
local function triggerProximity(prompt)
    if not okVIM or not VirtualInputManager then
        warn("VirtualInputManager unavailable -> cannot auto-press 'E' for ProximityPrompt.")
        return false
    end
    -- Tạo thread để spam key E tới khi prompt biến mất
    spawn(function()
        while prompt and prompt.Parent do
            pcall(function()
                -- nhấn xuống
                VirtualInputManager:SendKeyEvent(true, "E", false, game)
                task.wait(0.08)
                -- nhả phím
                VirtualInputManager:SendKeyEvent(false, "E", false, game)
            end)
            task.wait(0.4)
        end
    end)
    return true
end

-- Simulate mouse click lên vị trí part (ClickDetector)
local function clickAtPartLoop(part)
    if not okVIM or not VirtualInputManager then
        warn("VirtualInputManager unavailable -> cannot simulate mouse clicks.")
        return false
    end
    spawn(function()
        while part and part.Parent do
            local p = part
            -- dùng PrimaryPart position hoặc part.Position
            local worldPos
            if p:IsA("BasePart") then
                worldPos = p.Position
            else
                -- fallback: lấy bounding box center
                local ok, cf, size = pcall(function() return p:GetBoundingBox() end)
                if ok and cf then worldPos = cf.Position end
            end

            if worldPos and Camera then
                local screenX, screenY, onScreen = Camera:WorldToViewportPoint(worldPos)
                if onScreen then
                    pcall(function()
                        VirtualInputManager:SendMouseButtonEvent(screenX, screenY, true, game)
                        task.wait(0.06)
                        VirtualInputManager:SendMouseButtonEvent(screenX, screenY, false, game)
                    end)
                end
            end
            task.wait(0.5)
        end
    end)
    return true
end

-- Hàm chính: tìm, teleport, follow, và thử tương tác
local function teleportAndAttemptCollect(keyword)
    local targetPart = findTargetPart(keyword)
    if not targetPart then
        warn("Không tìm thấy vật có tên chứa: "..tostring(keyword))
        return false
    end

    -- Teleport ngay tới target + bám chặt
    pcall(function() hrp.CFrame = targetPart.CFrame + followOffset end)
    followPart(targetPart)

    -- Tìm ProximityPrompt (ưu tiên)
    local modelAncestor = targetPart:FindFirstAncestorOfClass("Model") or targetPart.Parent
    local prompt = nil
    if modelAncestor then
        prompt = modelAncestor:FindFirstChildWhichIsA("ProximityPrompt", true)
    end
    if not prompt then
        prompt = targetPart:FindFirstChildWhichIsA("ProximityPrompt", true)
    end
    if prompt then
        print("[Auto] Found ProximityPrompt -> trying to trigger via simulated key")
        triggerProximity(prompt)
        return true
    end

    -- Tìm ClickDetector
    local clickDetector = nil
    if modelAncestor then
        clickDetector = modelAncestor:FindFirstChildWhichIsA("ClickDetector", true)
    end
    if not clickDetector then
        clickDetector = targetPart:FindFirstChildWhichIsA("ClickDetector", true)
    end
    if clickDetector then
        print("[Auto] Found ClickDetector -> simulating clicks at part's screen position")
        clickAtPartLoop(targetPart)
        return true
    end

    -- Nếu không có prompt/click -> cố gắng "touch" với HRP (nhiều game trigger pickup khi chạm)
    print("[Auto] No interactable found. Staying at target position so touch-based pickup may trigger.")
    return true
end

-- =================================================
-- Tự chạy: scan map định kỳ, nếu tìm thấy thì thực hiện
-- =================================================
spawn(function()
    while true do
        pcall(function()
            teleportAndAttemptCollect(targetKeyword)
        end)
        task.wait(scanInterval)
    end
end)

-- HẾT SCRIPT