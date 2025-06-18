local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function hsvRainbow(t)
    return Color3.fromHSV(t % 1, 1, 1)
end

local function replaceJoystickImage()
    local touchGui = playerGui:WaitForChild("TouchGui", 10)
    if not touchGui then return end

    local joystick = touchGui:FindFirstChild("DynamicThumbstickFrame", true) or touchGui:FindFirstChild("ThumbstickFrame", true)
    if joystick then
        for _, child in pairs(joystick:GetDescendants()) do
            if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                child.Image = "" -- Xóa hình mặc định
                child.BackgroundTransparency = 1

                -- Ảnh avatar
                local avatar = Instance.new("ImageLabel")
                avatar.Name = "AvatarImage"
                avatar.Parent = child
                avatar.Size = UDim2.new(1, 0, 1, 0)
                avatar.Position = UDim2.new(0, 0, 0, 0)
                avatar.Image = "rbxassetid://110657725541747" -- ← Thay ID ảnh bạn muốn
                avatar.BackgroundTransparency = 1
                avatar.ScaleType = Enum.ScaleType.Fit

                -- Viền 7 màu
                local stroke = Instance.new("UIStroke")
                stroke.Thickness = 4
                stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                stroke.Parent = avatar

                -- Cập nhật màu viền liên tục
                RunService.RenderStepped:Connect(function(step)
                    local time = tick() * 0.5 -- tốc độ xoay màu
                    stroke.Color = hsvRainbow(time)
                end)
            end
        end
    end
end

task.delay(0.1, replaceJoystickImage)