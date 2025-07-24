local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enemies = workspace:WaitForChild("Enemies")
local Lighting = game:GetService("Lighting")

--// Constants
local SEA1_PLACE_ID = 2753915549  -- Fixed: Added SEA1_PLACE_ID
local SEA2_PLACE_ID = 4442272183  -- Fixed: Corrected duplicate assignment
local SEA3_PLACE_ID = 7449423635
local jobId = tostring(game.JobId)
local playerCount = #Players:GetPlayers()
local joinScript = string.format(
    '`game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, "%s", game.Players.LocalPlayer)`',
    jobId
)

local function base64Encode(str)
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	return ((str:gsub('.', function(x)
		local r, b = '', x:byte()
		for i = 8, 1, -1 do
			r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0')
		end
		return r
	end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if (#x < 6) then return '' end
		local c = 0
		for i = 1, 6 do
			c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0)
		end
		return b:sub(c + 1, c + 1)
	end) .. ({ '', '==', '=' })[#str % 3 + 1])
end

-- Hàm giải mã Base64
local function base64Decode(data)
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	data = data:gsub('[^'..b..'=]', '')
	return (data:gsub('.', function(x)
		if x == '=' then return '' end
		local r, f = '', (b:find(x) - 1)
		for i = 6, 1, -1 do
			r = r .. (f % 2^i - f % 2^(i - 1) > 0 and '1' or '0')
		end
		return r
	end):gsub('%d%d%d%d%d%d%d%d', function(x)
		local c = 0
		for i = 1, 8 do
			c = c + (x:sub(i,i) == '1' and 2^(8 - i) or 0)
		end
		return string.char(c)
	end))
end

--// Webhook Configuration
local TuanAnhIOS = {
    ["Mirage Island"] = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTM5NjcwODgyMTEwMzE1MzE5NC94VjNGM0FOVndPREdRazBNaXVfeE9HVW41OUg5Y0Znc2c2WkM2N3JwTHJPekpDVjFVRXQ5d1Y5d2l6U2dWNzVBOW94WQ==",
    ["Kitsune Island"] = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTM5NjcwOTIzMzIzOTUyNzQ4NC9SenZOb0cycGh1eHBrS0FVbnpYYVNMb21oSDdxZVhlQ2hHMXRyMjBBSXU4Vm9VYnVSOTVNY0J2aTAxSEFJa3VhakpfMw==",
    ["Prehistoric Island"] = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTM5NjcwOTc1MjIwNTA4Njc1Mi9wd0tELVZid01lOFJ5S3dSTmpOYzBKLVJZdlNobzhIOHRCaWhIbGFKQWdYZTJoNEhlUHNSdnJIN0J3TlVhMmxjUERJXw==",
    ["Full Moon"] = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTM5NjcwODI5NzIwNTM1NDYzNi9uNkxOeVlmOXo3c0FlcGZ1Y0YzdTFhTERMR2ZLZjBZZURSbkkwM01Jb3dKbVhOcFVLVUEtWVNlT2hoZUw0bDhZTzN6RA==",
    ["Near Full Moon"] = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTM5NjcxMDM2MjE5NTMwMDQwMy9WcmtpS0dMMzQ1dlM4b1NxZlVCbWNTb2hWWTBRU0UzMFJfQ1RjUHBwal9NMkp0MXVOMi1tX3V3SmdoZ1k5TVNVOHVaRw==",
    ["Rip Indra"] = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTM5NjcxMDk2NTUzMzM0Mzc4NS9PTkhGN1kwOGZDYXN5aU9GNkhnYmhJcE42aWhuTFNmbWNTdEx1RGd3aU13T0hNZGJZUTR0ZHlYaWtWc243UGUydmxtVQ==",
    ["Dough King"] = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTM5NjcxMDk3MzAzNjgyMjUzOC8yU3N4NGhEQ1ZQTDVwLVJLUFM1dXRaUHZwRDRUZTQtb3NEaThPNjlTMlFUOUVicGxkem44bkZ3NGxrRjRXRXU5ejV0Vg==",
    ["Cake Prince"] = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTM5NjcxMTYyMjA5NzI0NDMxMi9qU0FIa0RrNlNfMk1NZVgwbjN0VjZMM2pZaTlSekNKTTFPUXV6bHhLR1VNcE0zQ2tRRFdZeUt1NlJmSUtVZmZUdnYzNA==",
    ["Tyrant of the Skies"] = "https://discord.com/api/webhooks/1388163510797861035/TgvUZQlJpxkfb8-i9VJYEL0YRXEwrnuq2qJTBGCIJhvmAr9YlYYKC-FEEtHZR36EDlSD",
    ["Darkbeard"] = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTM5NjcxMTU0NTYxMzg0ODYwNi9leHMtaV9odkNtVG41aU9QQlZZd0d4dW4xcWZxazdjTWlRS1hEd3BmV1JOU2ZLWXNKdW5RM01PWEFIWFduU1ZJbWZsTA==",
    ["Soul Reaper"] = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTM5NjcxMTYyMjA5NzI0NDMxMi9qU0FIa0RrNlNfMk1NZVgwbjN0VjZMM2pZaTlSekNKTTFPUXV6bHhLR1VNcE0zQ2tRRFdZeUt1NlJmSUtVZmZUdnYzNA==",
    ["Cursed Captain"] = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTM5NjcxMTYyMjA5NzI0NDMxMi9qU0FIa0RrNlNfMk1NZVgwbjN0VjZMM2pZaTlSekNKTTFPUXV6bHhLR1VNcE0zQ2tRRFdZeUt1NlJmSUtVZmZUdnYzNA==",
    ["Legendary Sword"] = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTM5NjcxMTYyNTgyOTkxMjYwNi9oM0Nzd1hkUzQ1bFY1blNjNEZOeWpUUklzcG4ycUdWbGdqX05tWTljV2l3MG01akRxQnFVNmx1aXBtZlpkSFB1aU9RRw==",
["Fruit"] = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTM5NjcwMzk5NjU4ODA2ODk1NC93aTFpWHBEN193b0RNWjlEUUZra2pYSDdrNlJoamVqWWp6ZGQySU5ueXFlRGgwWWhfdE1SN05NanBUdFppelpSOEhLZA==",
}

-- Khi cần dùng:
local function getWebhook(name)
	local encoded = TuanAnhIOS[name]
	if encoded then
		-- Nếu là link thật thì không decode
		if encoded:find("discord.com") then
			return encoded
		else
			return base64Decode(encoded)
		end
	end
	return nil
end

--// Enable/Disable webhook groups - Dễ dàng bật/tắt từng group
local WebhookURLs = getgenv().WebhookURLs or {
    ["TuanAnhIOS"] = true,     -- Fixed: Use string keys instead of table references
    -- Có thể thêm nhiều webhook group khác ở đây
}

--// Webhook group mapping - Fixed: Create proper mapping
local WebhookGroups = {
    ["TuanAnhIOS"] = TuanAnhIOS
}

--// Universal Webhook Sender - Gửi tới tất cả webhook được enable
function sendBossWebhook(eventName, swordName)
    -- Determine current sea based on PlaceId
    local currentSea = "Unknown Sea"
    if game.PlaceId == SEA1_PLACE_ID then
        currentSea = "First Sea"
    elseif game.PlaceId == SEA2_PLACE_ID then
        currentSea = "Second Sea"
    elseif game.PlaceId == SEA3_PLACE_ID then
        currentSea = "Third Sea"
    end
    
    local displayName = eventName
    if eventName == "Legendary Sword" and swordName then
        displayName = "Legendary Sword (" .. swordName .. ")"
    elseif eventName == "Fruit" and swordName then
        displayName = "Fruit Found (" .. swordName .. ")"
    end
    
    local data = {
    username = "Tuấn Anh IOS",
    embeds = {{
        title = displayName .. " | Notify Tuấn Anh IOS",
        color = tonumber(0x1E90FF),
        fields = {
            { name = "🧬 Type :", value = "```\n" .. displayName .. " [Spawn]\n```", inline = false },
            { name = "👥 Players In Server :", value = "```\n" .. tostring(playerCount) .. "\n```", inline = false },
            { name = "🌊 Sea :", value = "```\n" .. currentSea .. "\n```", inline = false },
            { name = "🧾 Job ID (Pc Copy):", value = "```\n" .. jobId .. "\n```", inline = false },
            { name = "📜 Join Script (Pc Copy):", value = "```lua\n" .. joinScript .. "\n```", inline = false },
            { name = "🧾 Job ID (Mobile Copy):", value = jobId, inline = false },
            { name = "📜 Join Script (Mobile Copy):", value = joinScript, inline = false }
        },
        image = {
            url = "https://cdn.discordapp.com/attachments/1369319486997528597/1398018743153459383/IMG_3408.gif?ex=6883d5ea&is=6882846a&hm=061400d8726df3e8ca32653772d274ea990e94cff406f7b0d506f0322e9e2db3&" -- Thay URL này bằng link ảnh public Discord hoặc từ website của bạn
        },
        footer = {
            text = "Notify Tuấn Anh IOS • " .. os.date("Time : %d/%m/%Y - %H:%M:%S")
        }
    }}
}
    
    local payload = HttpService:JSONEncode(data)
    local request = http_request or request or HttpPost or (syn and syn.request)
    
    if request then
        -- Fixed: Properly iterate through enabled webhook groups
        for groupName, isEnabled in pairs(WebhookURLs) do
            if isEnabled and WebhookGroups[groupName] and WebhookGroups[groupName][eventName] then
                -- Gửi request tới webhook tương ứng
                pcall(function() -- Added error handling
                    request({
                        Url = WebhookGroups[groupName][eventName],
                        Method = "POST",
                        Headers = { ["Content-Type"] = "application/json" },
                        Body = payload
                    })
                end)
            end
        end
    end
end

--// Sent flags for each checker
local sentDarkbeard = false
local sentCursedCaptain = false
local sentRipIndra = false
local sentDoughKing = false
local sentCakePrince = false
local sentTyrantSkies = false
local sentSoulReaper = false
local sentMirage = false
local sentKitsune = false
local sentPrehistoric = false
local sentFullMoon = false
local sentNearFullMoon = false
local sentFruit = {}

--// Darkbeard Only (World 2)
task.spawn(function()
    while true do
        task.wait(0.2)
        if game.PlaceId == SEA2_PLACE_ID and not sentDarkbeard then
            if ReplicatedStorage:FindFirstChild("Darkbeard") or Enemies:FindFirstChild("Darkbeard") then
                sendBossWebhook("Darkbeard")
                sentDarkbeard = true
            end
        end
    end
end)

--// Cursed Captain Only (World 2)
task.spawn(function()
    while true do
        task.wait(0.2)
        if game.PlaceId == SEA2_PLACE_ID and not sentCursedCaptain then
            if ReplicatedStorage:FindFirstChild("Cursed Captain") or Enemies:FindFirstChild("Cursed Captain") then
                sendBossWebhook("Cursed Captain")
                sentCursedCaptain = true
            end
        end
    end
end)

--// Rip Indra Only (World 3)
task.spawn(function()
    while true do
        task.wait(0.2)
        if game.PlaceId == SEA3_PLACE_ID and not sentRipIndra then
            -- Kiểm tra trong ReplicatedStorage
            for _, v in pairs(ReplicatedStorage:GetChildren()) do
                if v.Name:lower():find("rip_indra") then
                    sendBossWebhook("Rip Indra")
                    sentRipIndra = true
                    break
                end
            end
            -- Kiểm tra trong workspace.Enemies
            for _, v in pairs(Enemies:GetChildren()) do
                if v.Name:lower():find("rip_indra") then
                    sendBossWebhook("Rip Indra")
                    sentRipIndra = true
                    break
                end
            end
        end
    end
end)

--// Dough King Only (World 3)
task.spawn(function()
    while true do
        task.wait(0.2)
        if game.PlaceId == SEA3_PLACE_ID and not sentDoughKing then
            if ReplicatedStorage:FindFirstChild("Dough King") or Enemies:FindFirstChild("Dough King") then
                sendBossWebhook("Dough King")
                sentDoughKing = true
            end
        end
    end
end)

--// Cake Prince Only (World 3)
task.spawn(function()
    while true do
        task.wait(0.2)
        if game.PlaceId == SEA3_PLACE_ID and not sentCakePrince then
            if ReplicatedStorage:FindFirstChild("Cake Prince") or Enemies:FindFirstChild("Cake Prince") then
                sendBossWebhook("Cake Prince")
                sentCakePrince = true
            end
        end
    end
end)

--// Tyrant of the Skies Only (World 3)
task.spawn(function()
    while true do
        task.wait(0.2)
        if game.PlaceId == SEA3_PLACE_ID and not sentTyrantSkies then
            if ReplicatedStorage:FindFirstChild("Tyrant of the Skies") or Enemies:FindFirstChild("Tyrant of the Skies") then
                sendBossWebhook("Tyrant of the Skies")
                sentTyrantSkies = true
            end
        end
    end
end)

--// Soul Reaper Only (World 3)
task.spawn(function()
    while true do
        task.wait(0.2)
        if game.PlaceId == SEA3_PLACE_ID and not sentSoulReaper then
            if ReplicatedStorage:FindFirstChild("Soul Reaper") or Enemies:FindFirstChild("Soul Reaper") then
                sendBossWebhook("Soul Reaper")
                sentSoulReaper = true
            end
        end
    end
end)

--// Mirage Island Only (World 3)
task.spawn(function()
    while true do
        task.wait(0.2)
        if game.PlaceId == SEA3_PLACE_ID and not sentMirage then
            local locs = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
            if locs and locs:FindFirstChild("Mirage Island") then
                sendBossWebhook("Mirage Island")
                sentMirage = true
            end
        end
    end
end)

--// Kitsune Island Only (World 3)
task.spawn(function()
    while true do
        task.wait(0.2)
        if game.PlaceId == SEA3_PLACE_ID and not sentKitsune then
            local locs = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
            if locs and locs:FindFirstChild("Kitsune Island") then
                sendBossWebhook("Kitsune Island")
                sentKitsune = true
            end
        end
    end
end)

--// Prehistoric Island Only (World 3)
task.spawn(function()
    while true do
        task.wait(0.2)
        if game.PlaceId == SEA3_PLACE_ID and not sentPrehistoric then
            local locs = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
            if locs and locs:FindFirstChild("Prehistoric Island") then
                sendBossWebhook("Prehistoric Island")
                sentPrehistoric = true
            end
        end
    end
end)

--// Full Moon Only (World 3)
task.spawn(function()
    while true do
        task.wait(0.2)
        if game.PlaceId == SEA3_PLACE_ID and not sentFullMoon then
            if Lighting.Sky.MoonTextureId == "http://www.roblox.com/asset/?id=9709149431" then
                sendBossWebhook("Full Moon")
                sentFullMoon = true
            end
        end
    end
end)

--// Near Full Moon Only (World 3)
task.spawn(function()
    while true do
        task.wait(0.2)
        if game.PlaceId == SEA3_PLACE_ID and not sentNearFullMoon then
            if Lighting.Sky.MoonTextureId == "http://www.roblox.com/asset/?id=9709149052" then
                sendBossWebhook("Near Full Moon")
                sentNearFullMoon = true
            end
        end
    end
end)

--// Legendary Sword Dealer Only (World 2)
task.spawn(function()
    local previousSword = nil
    local sentLegendarySword = false
    
    while true do
        task.wait(0.5)
        if game.PlaceId == SEA2_PLACE_ID then
            -- Reset flag when checking for new sword
            if not previousSword then
                sentLegendarySword = false
            end
            
            local currentSword = nil
            local success, result
            
            -- Check for Shizu
            success, result = pcall(function()
                return ReplicatedStorage.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "1")
            end)
            if success and result then
                currentSword = "Shizu"
            end
            
            -- Check for Oroshi if Shizu not found
            if not currentSword then
                success, result = pcall(function()
                    return ReplicatedStorage.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "2")
                end)
                if success and result then
                    currentSword = "Oroshi"
                end
            end
            
            -- Check for Saishi if others not found
            if not currentSword then
                success, result = pcall(function()
                    return ReplicatedStorage.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "3")
                end)
                if success and result then
                    currentSword = "Saishi"
                end
            end

            -- Send webhook if new sword found and not already sent
            if currentSword and currentSword ~= previousSword and not sentLegendarySword then
                sendBossWebhook("Legendary Sword", currentSword)
                previousSword = currentSword
                sentLegendarySword = true
            elseif not currentSword and previousSword then
                -- Dealer left, reset for next detection
                previousSword = nil
                sentLegendarySword = false
            end
        else
            -- Reset when not in World 2
            previousSword = nil
            sentLegendarySword = false
            task.wait(5) -- Longer wait when not in correct world
        end
    end
end)

--// Gửi thông báo khi phát hiện trái cây
task.spawn(function()
    while task.wait(3) do
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Tool") and v:FindFirstChild("Handle") and not sentFruit[v.Name] and v.Name:lower():find("fruit") then
                sentFruit[v.Name] = true
                sendBossWebhook("Fruit", v.Name)
            end
        end
    end
end)
