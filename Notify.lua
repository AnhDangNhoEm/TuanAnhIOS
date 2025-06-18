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
    'game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, "%s", game.Players.LocalPlayer)',
    jobId
)

--// Webhook Configuration
local TuanAnhIOS = {
    ["Mirage Island"] = "https://discord.com/api/webhooks/1385009288145010818/Ow-4cW10wEuP9rNNy-5WWK_fZWAVbhK_KuHESbOdlK6uga5uEqfMEF-09BVYYB7kDY93",
    ["Kitsune Island"] = "https://discord.com/api/webhooks/1385009613161889852/vAm44CY82qHqq3VUNbZtBq3fqxPpj8I4mIGMo84oz45qXYeLzK5oVkeTqSqMq_rEZZKZ",
    ["Prehistoric Island"] = "https://discord.com/api/webhooks/1385010407185449001/2wE4MZPSvUFwDXw-uTeJqaMkTR9bZ1rnfmXHSwX0A3kG0rk-IYO0p0L2OFZE0_5gd_ny",
    ["Full Moon"] = "https://discord.com/api/webhooks/1385010945666973737/4rW92dIaQcCFA3eYC38QYTl7Mc4hKL33REiKjqAIFsxMxE3SX-NMK1nBN4vsCKJx-Yrf",
    ["Near Full Moon"] = "https://discord.com/api/webhooks/1385011340027891863/SAoKQvzp66PtrIvUGQYb9vo4cS-yDR0ZiWpHxziNw3_cc5JCX3zFLmiLQT9GxDAr5RDX",
    ["Rip Indra"] = "https://discord.com/api/webhooks/1385011626440392776/nB53TfilYYm171ZUW2euVWc0w01EHybW46GdBaOWIpa0dWCL4IsxCW6WY_93Tvdvz-3-",
    ["Dough King"] = "https://discord.com/api/webhooks/1385011913036923141/GluXd2NbQyQ-8kXyDAKZUYG73ffj2VNxV4JPPcdua8lqCxMMyJymLNBp36P2DbxCwhDf",
    ["Cake Prince"] = "https://discord.com/api/webhooks/1385011926563553321/HsW4FQ54vveljsDoQmCbN8xqSz5ODCvU4N9tzS3ls6fC1DjkOqqn5UAfbHMc0H2XKNSi",
    ["Tyrant of the Skies"] = "https://discord.com/api/webhooks/1385012433768153320/RCuwXffKDHjr8xo3-KCsnm_AmUZgxLUDv1vvQkpgxmOoF0rXC07MN74XMFz-fwPaOe8U",
    ["Darkbeard"] = "https://discord.com/api/webhooks/1385013485636812900/UDC_qlUamRy4ytYw_Ww6rNlBNE-dCSvTf-PBQsAJNPOSKzL_Zvw8-1q0WJ7-12w3QuPB",
    ["Soul Reaper"] = "https://discord.com/api/webhooks/1385011926563553321/HsW4FQ54vveljsDoQmCbN8xqSz5ODCvU4N9tzS3ls6fC1DjkOqqn5UAfbHMc0H2XKNSi",
    ["Cursed Captain"] = "https://discord.com/api/webhooks/1385011926563553321/HsW4FQ54vveljsDoQmCbN8xqSz5ODCvU4N9tzS3ls6fC1DjkOqqn5UAfbHMc0H2XKNSi",
    ["Legendary Sword"] = "https://discord.com/api/webhooks/1385013736892272732/CMQixEJcEIMlK9LQpVauQ77pAMm6WtQxu0OlRQqBFmEpTKKif39v3fB2Mwgw29Gq7bX0"
}

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
            if ReplicatedStorage:FindFirstChild("Rip Indra") or Enemies:FindFirstChild("Rip Indra") then
                sendBossWebhook("Rip Indra")
                sentRipIndra = true
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