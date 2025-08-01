local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local placeId = game.PlaceId
local jobId = game.JobId

-- 🎯 Danh sách Brainrot theo độ hiếm
local brainrotList = {
	["cocofanto elefanto"] = "God",
	["gattatino nyanino"] = "God",
	["girafa celestre"] = "God",
	["matteo"] = "God",
	["tralalero tralala"] = "God",
	["odin din din dun"] = "God",
	["unclito samito"] = "God",
	["trenostruzzo turbo 3000"] = "God",
	["tigroligre frutonni"] = "God",
	["orcalero orcala"] = "God",
	["la vacca saturno saturnita"] = "Secret",
	["sammyni spiderini"] = "Secret",
	["torrtuginni dragonfrutini"] = "Secret",
	["los tralaleritos"] = "Secret",
	["las tralaleritas"] = "Secret",
	["graipuss medussi"] = "Secret",
	["pot hotspot"] = "Secret",
	["la grande combinazione"] = "Secret",
	["garama and madundung"] = "Secret"
}

-- 🧠 Ghi lại những con đã gửi rồi
local alreadySent = {}

-- 🧠 Hàm scan toàn map và lọc brainrot mới
local function getNewBrainrots()
	local newFound = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		local objName = obj.Name:lower()
		for brainrotName, rarity in pairs(brainrotList) do
			if objName:find(brainrotName) and not alreadySent[brainrotName] then
				newFound[brainrotName] = rarity
				alreadySent[brainrotName] = true -- đánh dấu là đã gửi rồi
			end
		end
	end
	return newFound
end

-- 📨 Hàm gửi webhook
local function sendWebhook(brainrots)
	local lines = {}
	for name, rarity in pairs(brainrots) do
		table.insert(lines, "**" .. name .. "** → `" .. rarity .. "`")
	end

	local embedText = table.concat(lines, "\n")
	local playerCount = tostring(#Players:GetPlayers()) .. "/8"

	local Data = {
		["username"] = "Notify Brainrot | phucmax",
		["avatar_url"] = "https://tr.rbxcdn.com/5a5518be29e2a5b499d4c36eeb1f11b0/150/150/Image/Png",
		["embeds"] = {{
			["title"] = "🧠 New Brainrot(s) Detected!",
			["color"] = tonumber("0xff00ff"),
			["fields"] = {
				{["name"] = "🧠 Name(s)", ["value"] = embedText, ["inline"] = false},
				{["name"] = "👥 Players", ["value"] = "**" .. playerCount .. "**", ["inline"] = true},
				{["name"] = "🌍 Job ID", ["value"] = "`" .. jobId .. "`", ["inline"] = true},
				{
					["name"] = "📦 Join Script",
					["value"] = "```lua\ngame:GetService(\"TeleportService\"):TeleportToPlaceInstance("..placeId..", \""..jobId.."\", game.Players.LocalPlayer)```",
					["inline"] = false
				}
			},
			["footer"] = {
				["text"] = "✅ Script by phucmax | " .. os.date("%d/%m/%Y • %H:%M:%S"),
				["icon_url"] = "https://cdn-icons-png.flaticon.com/512/921/921347.png"
			},
			["thumbnail"] = {
				["url"] = "https://cdn3.emoji.gg/emojis/5667-brainrot.gif"
			}
		}}
	}

	local Headers = {["Content-Type"] = "application/json"}
	local Encoded = HttpService:JSONEncode(Data)
	local WebhookURL = "https://discord.com/api/webhooks/1400888059796521016/TFLq9bMDbAOhhgjo8pAXfl3CifoW0rVmGx9p3fIbj0uAWM58Q1yvxv2_nWjJNvR_RI0e"
	local Request = http_request or request or syn and syn.request

	if Request then
		pcall(function()
			Request({
				Url = WebhookURL,
				Body = Encoded,
				Method = "POST",
				Headers = Headers
			})
		end)
	end
end

-- 🔁 Theo dõi liên tục mỗi 1 giây
while true do
	local newOnes = getNewBrainrots()
	if next(newOnes) then
		sendWebhook(newOnes)
	end
	task.wait(10)
end
