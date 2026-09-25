do
    local Chunk = nil
    if type(loadstring) == "function" then
        Chunk = loadstring([[
            local G = (getgenv and getgenv()) or (getrenv and getrenv()) or _G
            local F = function(f) return f end
            if type(rawget(G, "LPH_NO_VIRTUALIZE")) ~= "function" then
                G.LPH_NO_VIRTUALIZE = F
            end
            if type(rawget(_G, "LPH_NO_VIRTUALIZE")) ~= "function" then
                _G.LPH_NO_VIRTUALIZE = F
            end
        ]])
    end
    if Chunk then pcall(Chunk) end
end

local Library
do
    local Url = "https://gitlab.com/phantomsoftworksoffc/lib/-/raw/main/lib"
    local Src
    for Attempt = 1, 4 do
        local Ok, Res = pcall(function() return game:HttpGet(Url) end)
        if Ok and type(Res) == "string" and #Res > 500 then Src = Res break end
        local Req = (syn and syn.request) or (http and http.request) or request or http_request
        if type(Req) == "function" then
            local Ok2, Res2 = pcall(Req, { Url = Url, Method = "GET" })
            if Ok2 and type(Res2) == "table" and type(Res2.Body) == "string" and #Res2.Body > 500 then
                Src = Res2.Body
                break
            end
        end
        if Attempt < 4 then task.wait(0.75) end
    end
    if not Src then
        error("[PH] could not download the ui library, check your internet / executor http support", 0)
    end
    Library = loadstring(Src)()
end
Library:SetHub({
    Game = "Rivals",
    Socials = {
        Discord = "https://discord.gg/6S7gHAPg3A",
    },
    UpdateLog = {
        Date = "Sept 19, 2026",
        Added = {
            "Huge Optimization, script should run smoothly now",
        },
        Fixed = {
            "Aimbot not working on MacOS",
            "Aimbot Now works when enable, no need to hold RMB anymore",
            "Skin Changer buggin ur game UI",
            "Crashes"
        },
    },
})
do
    local Discord_Invite = Library.HubConfig.Socials.Discord
    local Tween_Service = game:GetService("TweenService")
    local Lighting = game:GetService("Lighting")
    local Run_Service = game:GetService("RunService")
    local T = Library.Theme or {}
    local F = Library.Fonts or {}
    local Accent = T.Accent or Color3.fromHex("#ff1a1a")
    local Bg = T.Background or Color3.fromHex("#080505")
    local Text_Col = T.Text or Color3.new(1, 1, 1)
    local Text_Dark = T.TextDark or Color3.fromHex("#997373")
    local Stroke_Col = T.Stroke or Color3.fromHex("#2e1717")
    local Container_Col = T.Container or Color3.fromHex("#140b0b")
    local Font_Main = F.Main or Enum.Font.GothamMedium
    local Font_Bold = F.Bold or Enum.Font.GothamBold

    local function Tw(Obj, Props, Time, Style)
        local Tween = Tween_Service:Create(Obj, TweenInfo.new(Time, Style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), Props)
        Tween:Play()
        return Tween
    end
    local function Round(Obj, R)
        local C = Instance.new("UICorner")
        C.CornerRadius = UDim.new(0, R)
        C.Parent = Obj
    end

    local Blur = Instance.new("BlurEffect")
    Blur.Name = "PhantomSplashBlur"
    Blur.Size = 0
    Blur.Parent = Lighting
    local Tint = Instance.new("ColorCorrectionEffect")
    Tint.Name = "PhantomSplashTint"
    Tint.TintColor = Color3.new(1, 1, 1)
    Tint.Parent = Lighting

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "PhantomDiscordSplash"
    Gui.IgnoreGuiInset = true
    Gui.ResetOnSpawn = false
    Gui.DisplayOrder = 1000
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local Gui_Parent = (gethui and gethui()) or nil
    if not Gui_Parent then pcall(function() Gui_Parent = game:GetService("CoreGui") end) end
    Gui.Parent = Gui_Parent or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    local Overlay = Instance.new("TextButton")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(70, 8, 8)
    Overlay.BackgroundTransparency = 1
    Overlay.BorderSizePixel = 0
    Overlay.Text = ""
    Overlay.AutoButtonColor = false
    Overlay.Parent = Gui

    local Snow_Layer = Instance.new("Frame")
    Snow_Layer.Size = UDim2.new(1, 0, 1, 0)
    Snow_Layer.BackgroundTransparency = 1
    Snow_Layer.Parent = Overlay
    local Flakes = {}
    for I = 1, 90 do
        local Size = math.random(2, 6)
        local Flake = Instance.new("Frame")
        Flake.Size = UDim2.new(0, Size, 0, Size)
        Flake.AnchorPoint = Vector2.new(0.5, 0.5)
        Flake.BackgroundColor3 = Color3.fromRGB(255, 240, 240)
        Flake.BackgroundTransparency = 1
        Flake.BorderSizePixel = 0
        Flake.Parent = Snow_Layer
        Round(Flake, Size)
        Flakes[I] = {Obj = Flake, Alpha = math.random(15, 55) / 100, X = math.random(), Y = math.random(), Speed = 0.05 + math.random() * 0.1, Phase = math.random() * math.pi * 2, Sway = 0.003 + math.random() * 0.012}
    end
    local Snow_Time = 0
    local Snow_Conn = Run_Service.Heartbeat:Connect(function(Dt)
        Snow_Time = Snow_Time + Dt
        for _, Fl in ipairs(Flakes) do
            Fl.Y = Fl.Y + Fl.Speed * Dt
            if Fl.Y > 1.05 then
                Fl.Y = -0.05
                Fl.X = math.random()
            end
            Fl.Obj.Position = UDim2.new(Fl.X + math.sin(Snow_Time * 1.5 + Fl.Phase) * Fl.Sway, 0, Fl.Y, 0)
        end
    end)

    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(0, 320, 0, 152)
    Card.Position = UDim2.new(0.5, 0, 0.5, 0)
    Card.AnchorPoint = Vector2.new(0.5, 0.5)
    Card.BackgroundColor3 = Bg
    Card.BackgroundTransparency = 1
    Card.BorderSizePixel = 0
    Card.Parent = Overlay
    Round(Card, 6)
    local Card_Stroke = Instance.new("UIStroke")
    Card_Stroke.Color = Stroke_Col
    Card_Stroke.Transparency = 1
    Card_Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Card_Stroke.Parent = Card
    local Card_Scale = Instance.new("UIScale")
    Card_Scale.Scale = 0.85
    Card_Scale.Parent = Card
    local Noise = Instance.new("ImageLabel")
    Noise.Size = UDim2.new(1, 0, 1, 0)
    Noise.BackgroundTransparency = 1
    Noise.Image = "rbxassetid://9968344105"
    Noise.ImageTransparency = 1
    Noise.ScaleType = Enum.ScaleType.Tile
    Noise.TileSize = UDim2.new(0, 100, 0, 100)
    Noise.Parent = Card
    Round(Noise, 6)

    local Title_Bar = Instance.new("Frame")
    Title_Bar.Size = UDim2.new(0, 3, 0, 22)
    Title_Bar.Position = UDim2.new(0, 8, 0, 29)
    Title_Bar.AnchorPoint = Vector2.new(0, 0.5)
    Title_Bar.BackgroundColor3 = Accent
    Title_Bar.BackgroundTransparency = 1
    Title_Bar.BorderSizePixel = 0
    Title_Bar.Parent = Card
    Round(Title_Bar, 2)
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -50, 0, 30)
    Title.Position = UDim2.new(0, 18, 0, 14)
    Title.BackgroundTransparency = 1
    Title.Text = "Join Discord"
    Title.TextColor3 = Accent
    Title.TextTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Font_Bold
    Title.TextSize = 20
    Title.Parent = Card
    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(1, -16, 0, 1)
    Divider.Position = UDim2.new(0, 8, 0, 48)
    Divider.BackgroundColor3 = Stroke_Col
    Divider.BackgroundTransparency = 1
    Divider.BorderSizePixel = 0
    Divider.Parent = Card
    local Sub = Instance.new("TextLabel")
    Sub.Size = UDim2.new(1, -36, 0, 20)
    Sub.Position = UDim2.new(0, 18, 0, 62)
    Sub.BackgroundTransparency = 1
    Sub.Text = "Something New Dropping Soon👀"
    Sub.TextColor3 = Text_Col
    Sub.TextTransparency = 1
    Sub.TextXAlignment = Enum.TextXAlignment.Left
    Sub.Font = Font_Main
    Sub.TextSize = 14
    Sub.Parent = Card

    local Buttons = {}
    local function Make_Button(Text, Y)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -36, 0, 30)
        Btn.Position = UDim2.new(0, 18, 0, Y)
        Btn.BackgroundColor3 = Container_Col
        Btn.BackgroundTransparency = 1
        Btn.Text = Text
        Btn.Font = Font_Main
        Btn.TextSize = 13
        Btn.TextColor3 = Text_Col
        Btn.TextTransparency = 1
        Btn.AutoButtonColor = false
        Btn.Parent = Card
        Round(Btn, 4)
        local St = Instance.new("UIStroke")
        St.Color = Stroke_Col
        St.Transparency = 1
        St.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        St.Parent = Btn
        Btn.MouseEnter:Connect(function() Tw(Btn, {BackgroundColor3 = Stroke_Col}, 0.3) Tw(St, {Color = Accent}, 0.3) end)
        Btn.MouseLeave:Connect(function() Tw(Btn, {BackgroundColor3 = Container_Col}, 0.3) Tw(St, {Color = Stroke_Col}, 0.3) end)
        Buttons[#Buttons + 1] = {Btn = Btn, Stroke = St}
        return Btn
    end
    local Copy_Btn = Make_Button("Copy Discord", 104)

    local Close_Btn = Instance.new("TextButton")
    Close_Btn.Size = UDim2.new(0, 24, 0, 24)
    Close_Btn.Position = UDim2.new(1, -8, 0, 17)
    Close_Btn.AnchorPoint = Vector2.new(1, 0)
    Close_Btn.BackgroundTransparency = 1
    Close_Btn.Text = "×"
    Close_Btn.TextColor3 = Text_Dark
    Close_Btn.TextTransparency = 1
    Close_Btn.Font = Font_Bold
    Close_Btn.TextSize = 20
    Close_Btn.Parent = Card
    Close_Btn.MouseEnter:Connect(function() Tw(Close_Btn, {TextColor3 = Accent}, 0.3) end)
    Close_Btn.MouseLeave:Connect(function() Tw(Close_Btn, {TextColor3 = Text_Dark}, 0.3) end)

    local function Fade(Visible, Time)
        local K = Visible and 0 or 1
        local function A(V) return Visible and V or 1 end
        Tw(Overlay, {BackgroundTransparency = A(0.45)}, Time)
        Tw(Card, {BackgroundTransparency = A(0.1)}, Time)
        Tw(Card_Stroke, {Transparency = K}, Time)
        Tw(Noise, {ImageTransparency = A(0.9)}, Time)
        Tw(Title_Bar, {BackgroundTransparency = K}, Time)
        Tw(Title, {TextTransparency = K}, Time)
        Tw(Divider, {BackgroundTransparency = K}, Time)
        Tw(Sub, {TextTransparency = K}, Time)
        for _, B in ipairs(Buttons) do
            Tw(B.Btn, {BackgroundTransparency = K, TextTransparency = K}, Time)
            Tw(B.Stroke, {Transparency = A(0.5)}, Time)
        end
        Tw(Close_Btn, {TextTransparency = K}, Time)
        for _, Fl in ipairs(Flakes) do Tw(Fl.Obj, {BackgroundTransparency = A(Fl.Alpha)}, Time) end
        Tw(Card_Scale, {Scale = Visible and 1 or 0.85}, Time, Visible and Enum.EasingStyle.Back or nil)
        Tw(Blur, {Size = Visible and 14 or 0}, Time)
        return Tw(Tint, {TintColor = Visible and Color3.fromRGB(255, 210, 210) or Color3.new(1, 1, 1)}, Time)
    end

    local Closed = false
    local Done = Instance.new("BindableEvent")
    local function Close()
        if Closed then return end
        Closed = true
        Fade(false, 0.3).Completed:Wait()
        Snow_Conn:Disconnect()
        Gui:Destroy()
        Blur:Destroy()
        Tint:Destroy()
        Done:Fire()
    end
    Copy_Btn.MouseButton1Click:Connect(function()
        if setclipboard then pcall(setclipboard, Discord_Invite) end
        Library:Notify("Discord", "Invite link copied to clipboard", 5)
        task.spawn(function()
            pcall(function()
                local inviter = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Discord%20Inviter/Source.lua"))()
                inviter.Join(Discord_Invite)
            end)
        end)
        task.spawn(Close)
    end)
    Close_Btn.MouseButton1Click:Connect(function() task.spawn(Close) end)

    Fade(true, 0.4)
    if not Closed then Done.Event:Wait() end
    Done:Destroy()
end

local Window = Library:CreateWindow({Name = "PHANTOM HUB"})
local Players = game:GetService("Players")
local Run_Service = game:GetService("RunService")
local User_Input_Service = game:GetService("UserInputService")
local Virtual_Input_Manager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Sound_Service = game:GetService("SoundService")
local RS = game:GetService("ReplicatedStorage")
local Local_Player = Players.LocalPlayer
local Has_Hook = type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" and type(checkcaller) == "function"
local Has_Getgc = type(getgc) == "function"
local Exec_Name = type(identifyexecutor) == "function" and identifyexecutor() or ""
local Exec_Lower = string.lower(Exec_Name)
local Is_Restricted = string.find(Exec_Lower, "xeno") or string.find(Exec_Lower, "solara")
local Is_Weak = (Is_Restricted and true or false) or not Has_Hook or not Has_Getgc
local Game_Require
do
    local Cache = {}
    Game_Require = function(Mod)
        if Is_Weak then return nil end
        if typeof(Mod) ~= "Instance" or not Mod:IsA("ModuleScript") then return nil end
        local Hit = Cache[Mod]
        if Hit ~= nil then
            if Hit == false then return nil end
            return Hit
        end
        local Ok, Res = pcall(require, Mod)
        if not Ok or Res == nil then
            Cache[Mod] = false
            return nil
        end
        Cache[Mod] = Res
        return Res
    end
end
local Math_Abs = math.abs
local Math_Clamp = math.clamp
local Math_Floor = math.floor
local Math_Noise = math.noise
local Math_Rad = math.rad
local Math_Max = math.max
local Math_Random = math.random
local Math_Huge = math.huge
local Vector2_New = Vector2.new
local Vector3_New = Vector3.new
local Vector3_Zero = Vector3.zero
local Color3_From_Rgb = Color3.fromRGB
local Color3_From_Hsv = Color3.fromHSV
local Cframe_New = CFrame.new
local Cframe_Angles = CFrame.Angles
local Cframe_Look_At = CFrame.lookAt
local Ray_New = Ray.new
local Tick = tick
local Table_Clear = table.clear

local Config = {
    Emote_Wheel_Enabled = true,
    Aimbot_Enabled = false, Aim_Hold_Rmb = false, Aim_Type = "Mouse", Aim_Part = "Head", Aim_Logic = "Closest To FOV",
    Aim_Team_Check = true, Aim_Smoothness = 1, Aim_Prediction = false, Aim_Shake = false,
    Aim_Shake_Speed = 10, Aim_Shake_X = 5, Aim_Shake_Y = 5,
    Sa_Enabled = false, Sa_Part = "Head", Sa_Team_Check = true, Sa_Visible_Check = false, Sa_Hit_Chance = 100, Projectile_TP = false, Sa_Random_Hitbox = false,
    Show_Fov = false, Fov_Size = 100, Fov_Rainbow = false, Fov_Rainbow_Speed = 1, Fov_Color = Color3_From_Rgb(255, 255, 255),
    Esp_Enabled = false, Esp_Box = false, Esp_Box_Type = "Standard", Esp_Skeleton = false, Esp_Name = false,
    Esp_Distance = false, Esp_Health_Bar = false, Esp_Head_Circle = false,
    Esp_Tracers = false, Tracer_Origin = "Bottom", Tracer_Thickness = 1, Esp_Outline = true, Box_Color = Color3_From_Rgb(255, 255, 255),
    Esp_Team_Check = true,
    Bullet_Tracers = false, Bullet_Tracer_Color = Color3_From_Rgb(255, 170, 0), Bullet_Tracer_Life = 0.3, Bullet_Tracer_Material = "Neon",
    Hit_Sound_Enabled = false, Hit_Sound = "None", Hit_Sound_Volume = 1,
    Hit_Marker = false, Hit_Marker_Color = Color3_From_Rgb(255, 255, 255), Hit_Marker_Size = 10, Hit_Marker_Gap = 4, Hit_Marker_Thickness = 2, Hit_Marker_Life = 0.4, Hit_Marker_Rainbow = false, Hit_Marker_Rainbow_Speed = 1, Hit_Only_Target = false,
    Name_Color = Color3_From_Rgb(255, 255, 255), Distance_Color = Color3_From_Rgb(255, 255, 255),
    Skeleton_Color = Color3_From_Rgb(255, 255, 255), Tracer_Color = Color3_From_Rgb(255, 255, 255),
    Chams_Enabled = false, Chams_Color = Color3_From_Rgb(255, 0, 0), Chams_Material = "ForceField",
    Chams_Transparency = 0, Chams_Arms_Only = false, Chams_Weapon_Only = false,
    Chams_Rainbow = false, Chams_Rainbow_Speed = 1,
    Third_Person = false, No_Flashbang = false, Anti_Katana = false,
    No_Recoil = false, No_Spread = false, Rapid_Fire = false, Rapid_Fire_Speed = 0.01, No_Bullet_Waste = false,
    Instant_Grenade = false, No_Melee_Cooldown = false, Instant_Scope = false,
    Fly_Enabled = false, Fly_Speed = 50, Noclip = false, Bhop = false, Strafes = false, Strafe_Speed = 35, Inf_Jump = false,
    Ws_Enabled = false, Walk_Speed = 16, Jp_Enabled = false, Jump_Power = 50,
    Streamer_Mode = false,
    Rage_Enabled = false, Rage_Silent_Aim = true, Rage_Fov = 360, Rage_Force_Pred = false, Rage_Auto_Shoot = false,
    Rage_Visible_Check = true, Rage_Projectile_TP = false, Rage_Pred_Amt = 1, Rage_Resolver = "None", Rage_Hitbox = "Head", Rage_Seed_Spread = 0, Rage_Fire_Rate = 0.01,
    Rage_Aa_Enabled = false, Rage_Aa_Yaw = "None", Rage_Aa_Pitch = "None", Rage_Aa_Aim_Pause = true, Rage_Selection = "FOV", Rage_Revert = false,
    Rage_Auto_Reload = false,
    Fps_Boost = false,
    Bloom_Enabled = false, Bloom_Intensity = 1, Bloom_Size = 24, Bloom_Threshold = 2,
    Blur_Enabled = false, Blur_Size = 12,
    CC_Enabled = false, CC_Brightness = 0, CC_Contrast = 0, CC_Saturation = 0, CC_TintColor = Color3_From_Rgb(255, 255, 255),
    SunRays_Enabled = false, SunRays_Intensity = 0.25, SunRays_Spread = 0.1,
    Atmo_Enabled = false, Atmo_Density = 0.3, Atmo_Offset = 0.25, Atmo_Glare = 0, Atmo_Haze = 0, Atmo_Color = Color3_From_Rgb(199, 199, 199), Atmo_Decay = Color3_From_Rgb(106, 112, 125),
    Skybox_Enabled = false,
    Auto_Shoot_Shield_Check = false, Shield_Detect_Radius = 500,
    CustLight_Enabled = false, CustLight_Brightness = 1, CustLight_Time = 14, CustLight_Shadows = true, CustLight_Ambient = Color3_From_Rgb(128, 128, 128),
    SC_Enabled = false,
    Crosshair_Enabled = false, Crosshair_T_Shape = false, Crosshair_Dot = false, Crosshair_Outline = true,
    Crosshair_Size = 8, Crosshair_Gap = 4, Crosshair_Thickness = 2,
    Crosshair_Rainbow = false, Crosshair_Rainbow_Speed = 1, Crosshair_Color = Color3_From_Rgb(0, 255, 0),
    Crosshair_Rotate = false, Crosshair_Rotate_Speed = 1,
    Trigger_Enabled = false, Trigger_Team_Check = true, Trigger_Delay = 0.03, Trigger_Cooldown = 0.1,
    Backstab_Enabled = false, Backstab_Always = false, Backstab_Team_Check = true,
    Backstab_Range = 100, Backstab_Delay = 0.05, Backstab_Cooldown = 0.5,
    Backstab_Return = false, Backstab_Behind = true, Backstab_Offset = 4,
    Backstab_Only_Duel = true, Enemy_Loadout = false,
    Loadout_Viewer = false,
    Whitelist_Enabled = true,
    Fps_Cap = 0,
    Crosshair_Follow = false,
    Cos_Hat = false, Cos_Hat_Color = Color3_From_Rgb(255, 0, 0),
    Cos_Cape = false, Cos_Cape_Color = Color3_From_Rgb(255, 0, 0),
    Cos_Wings = false, Cos_Wings_Color = Color3_From_Rgb(255, 255, 255),
    Cos_Aura = false, Cos_Aura_Color = Color3_From_Rgb(80, 150, 255)
}

local Data = {
    Sa_Target_Pos = nil, Sa_Target_Player = nil, Current_Aim_Target = nil, Esp_Objects = {}, Rainbow_Hue = 0, Is_Auto_Shooting = false,
    Mm_Since = 0, Mm_Ref = 0, Mm_Broken = Is_Weak and true or false,
    Chams_Hue = 0, Char_List = {}, Loadout_Scan = { T = 0, Map = {} },
    World_Tick = 0, Tp_Parts = {}, Tp_Char = nil, Katana_Users = {},
    Whitelist = {}, Aa_Active = false
}

local Is_Mobile = User_Input_Service.TouchEnabled and not User_Input_Service.KeyboardEnabled

Data.Hit_Fx = {
    Names = {"Particles"},
    Set_On = function() end,
    Set_Style = function() end,
    Set_Float = function() end,
    Set_Alive = function() end
}

Data.Safe_Index = 0
Data.Short_Error = function(Err)
    return (tostring(Err):gsub("^.-:%d+:%s*", ""))
end
local function Safe(Fn)
    Data.Safe_Index = Data.Safe_Index + 1
    local Id = Data.Safe_Index
    local Ok, Err = pcall(Fn)
    if Ok then return true end
    print("[PH] block " .. Id .. " failed: " .. tostring(Err))
    pcall(function() Library:Notify("PHANTOM HUB", "B" .. Id .. ": " .. Data.Short_Error(Err), 8) end)
    return false
end

local Trigger_Hover_Since = 0
local Last_Trigger_Fire = 0
local Last_Backstab_Fire = 0
local Backstab_Busy = false
local Backstab_Target = nil
local Backstab_Equipped_For = nil
local Crosshair_Hue = 0
local Crosshair_Rot = 0

local Last_Sa_Update = 0
local Aim_Accum_X, Aim_Accum_Y = 0, 0
local Current_Fly_Velocity = Vector3_Zero
local Noclip_Parts = {}
local Noclip_Cached = false

local Weapon_Configs = setmetatable({}, {__mode = "k"})
local Backtrack_History = {}
local Original_Joints = {}
local AA_Prev_AutoRotate = nil
local AA_Spin_Base = tick()

local Assets = {
    HitSounds = {
        ["None"] = "",
        ["Rust Headshot"] = "rbxassetid://5043539486",
        ["Keyboard"] = "rbxassetid://18439144240",
        ["Minecraft"] = "rbxassetid://8766809464",
        ["Minecraft2"] = "rbxassetid://3442683707",
        ["Skeet"] = "rbxassetid://6607204501",
        ["Neverlose"] = "rbxassetid://110168723447153",
        ["Medal"] = "rbxassetid://6607336718",
        ["Fatality"] = "rbxassetid://6607113255",
        ["Switches"] = "rbxassetid://6607173363",
        ["Bubble"] = "rbxassetid://6534947588",
        ["Laser"] = "rbxassetid://7837461331",
        ["Steve"] = "rbxassetid://4965083997",
        ["Call of Duty"] = "rbxassetid://5952120301",
        ["Bat"] = "rbxassetid://3333907347",
        ["TF2 Critical"] = "rbxassetid://296102734",
        ["Saber"] = "rbxassetid://8415678813",
        ["Bameware"] = "rbxassetid://3124331820"
    },
    HitSoundNames = {"None", "Rust Headshot", "Keyboard", "Minecraft", "Minecraft2", "Skeet", "Neverlose", "Medal", "Fatality", "Switches", "Bubble", "Laser", "Steve", "Call of Duty", "Bat", "TF2 Critical", "Saber", "Bameware"},
    AimPartOptions = {"Head", "Torso", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Random"},
    TracerMaterials = {"Neon", "ForceField", "Plastic", "SmoothPlastic", "Glass", "Ice", "Foil", "Metal", "Marble", "Concrete"}
}
local Is_Reloading = false
local Last_Reload = 0
local Chams_Cache = {}
local Chams_Last_Vm = nil
local Chams_Dirty = true
local Cached_Ammo_Gui = nil

local My_Bloom = Instance.new("BloomEffect")
local My_Blur = Instance.new("BlurEffect")
local My_CC = Instance.new("ColorCorrectionEffect")
local My_SR = Instance.new("SunRaysEffect")
local My_Atmo = Instance.new("Atmosphere")
local My_Sky = Instance.new("Sky")

local Original_Lighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient
}

My_Sky.SkyboxBk = "rbxassetid://6444884337"
My_Sky.SkyboxDn = "rbxassetid://6444884337"
My_Sky.SkyboxFt = "rbxassetid://6444884337"
My_Sky.SkyboxLf = "rbxassetid://6444884337"
My_Sky.SkyboxRt = "rbxassetid://6444884337"
My_Sky.SkyboxUp = "rbxassetid://6444884337"
My_Sky.StarCount = 5000

local Fov_Circle = Drawing.new("Circle")
Fov_Circle.Visible = false
Fov_Circle.Thickness = 1
Fov_Circle.NumSides = 64
Fov_Circle.Radius = 100
Fov_Circle.Color = Color3_From_Rgb(255, 255, 255)
Fov_Circle.Transparency = 1
Fov_Circle.Filled = false

local Wall_Params = RaycastParams.new()
Wall_Params.FilterType = Enum.RaycastFilterType.Exclude
Wall_Params.IgnoreWater = true
Wall_Params.RespectCanCollide = false

local Trigger_Params = RaycastParams.new()
Trigger_Params.FilterType = Enum.RaycastFilterType.Exclude
Trigger_Params.IgnoreWater = true
Trigger_Params.RespectCanCollide = false

local Crosshair_Lines = {}
local Crosshair_Outlines = {}
for I = 1, 4 do
    local O = Drawing.new("Line")
    O.Visible = false O.Thickness = 3 O.Color = Color3_From_Rgb(0, 0, 0) O.ZIndex = 0
    local L = Drawing.new("Line")
    L.Visible = false L.Thickness = 1 L.ZIndex = 1
    Crosshair_Outlines[I] = O
    Crosshair_Lines[I] = L
end
local Crosshair_Dot = Drawing.new("Circle")
Crosshair_Dot.Visible = false Crosshair_Dot.Filled = true Crosshair_Dot.NumSides = 12 Crosshair_Dot.ZIndex = 1
local Crosshair_Dot_Outline = Drawing.new("Circle")
Crosshair_Dot_Outline.Visible = false Crosshair_Dot_Outline.Filled = true Crosshair_Dot_Outline.NumSides = 12
Crosshair_Dot_Outline.Color = Color3_From_Rgb(0, 0, 0) Crosshair_Dot_Outline.ZIndex = 0

local Material_Map = {
    ["ForceField"] = Enum.Material.ForceField,
    ["Neon"] = Enum.Material.Neon,
    ["Glass"] = Enum.Material.Glass,
    ["SmoothPlastic"] = Enum.Material.SmoothPlastic,
    ["Ice"] = Enum.Material.Ice,
    ["Foil"] = Enum.Material.Foil,
    ["DiamondPlate"] = Enum.Material.DiamondPlate
}

local SC_Originals = {}
local SC_ActiveSkins = {}
local SC_SpoofSkins = {}
local SC_SkinLookup = {}
local SC_WeaponSkins = {}
local SC_WeaponsByClass = { Primary = {}, Secondary = {}, Melee = {}, Utility = {} }
local SC_SkinToWeapon = {}
local SC_CosNames = { Wraps = {}, Charms = {}, Finishers = {}, Emotes = {}, Images = {} }
local SC_TYPE_TO_KIND = { Wrap = "Wraps", Charm = "Charms", Finisher = "Finishers", Emote = "Emotes" }
local SC_EmoteData = {}
local SC_AllWeaponNames = {}
local SC_SKIN_FOLDERS = {}
local SC_WeaponsFolder = nil
local SC_VM_Root = nil
local SC_Initialized = false
local SC_ViewModelSounds = nil
local SC_ItemLib = nil

local SC_P

local function SC_Init()
    if SC_Initialized then return true end
    local ps = Local_Player:FindFirstChild("PlayerScripts")
    if not ps then return false end
    local assets = ps:FindFirstChild("Assets")
    if not assets then return false end
    local vmRoot = assets:FindFirstChild("ViewModels")
    if not vmRoot then return false end
    local wf = vmRoot:FindFirstChild("Weapons")
    if not wf then return false end

    SC_VM_Root = vmRoot
    SC_WeaponsFolder = wf

    for _, child in ipairs(vmRoot:GetChildren()) do
        if child:IsA("Folder") and child.Name ~= "Weapons" then
            SC_SKIN_FOLDERS[#SC_SKIN_FOLDERS + 1] = child
        end
    end

    for _, folder in ipairs(SC_SKIN_FOLDERS) do
        for _, model in ipairs(folder:GetChildren()) do
            SC_SkinLookup[model.Name] = folder
        end
    end
    for _, model in ipairs(wf:GetChildren()) do
        if model:IsA("Model") then
            SC_SkinLookup[model.Name] = wf
        end
    end

    local ItemLib, CosLib
    local m = RS:FindFirstChild("Modules")
    if m then
        ItemLib = Game_Require(m:FindFirstChild("ItemLibrary"))
        CosLib = Game_Require(m:FindFirstChild("CosmeticLibrary"))
    end
    SC_ItemLib = ItemLib

    if ItemLib and ItemLib.Items then
        for name, data in pairs(ItemLib.Items) do
            if name ~= "MISSING_WEAPON" then
                SC_WeaponSkins[name] = { name }
                SC_SkinToWeapon[name] = name
                local c = data.Class
                if c and SC_WeaponsByClass[c] then
                    SC_WeaponsByClass[c][#SC_WeaponsByClass[c] + 1] = name
                end
            end
        end
    end

    if CosLib and CosLib.Cosmetics then
        for cosName, cosData in pairs(CosLib.Cosmetics) do
            if cosData.Type == "Skin" and cosData.ItemName then
                SC_SkinToWeapon[cosName] = cosData.ItemName
                if SC_WeaponSkins[cosData.ItemName] and SC_SkinLookup[cosName] then
                    local skins = SC_WeaponSkins[cosData.ItemName]
                    skins[#skins + 1] = cosName
                end
            else
                local kind = cosData.Type and SC_TYPE_TO_KIND[cosData.Type]
                if kind and SC_CosNames[kind] and not cosData.Hidden then
                    local list = SC_CosNames[kind]
                    list[#list + 1] = cosName
                    if type(cosData.Image) == "string" then SC_CosNames.Images[cosName] = cosData.Image end
                    if kind == "Emotes" then SC_EmoteData[cosName] = cosData end
                end
            end
        end
    end
    -- no ItemLibrary (limited executors): weapons = templates in Weapons folder,
    -- skins matched by name, else by shared part names with the template
    if not ItemLib then
        local function partNames(model)
            local t = {}
            for _, c in ipairs(model:GetChildren()) do t[c.Name] = true end
            return t
        end
        local weaponParts = {}
        for _, model in ipairs(wf:GetChildren()) do
            if model:IsA("Model") then
                SC_WeaponSkins[model.Name] = { model.Name }
                SC_SkinToWeapon[model.Name] = model.Name
                weaponParts[model.Name] = partNames(model)
            end
        end
        for skinName, folder in pairs(SC_SkinLookup) do
            if folder ~= wf then
                local target
                for weaponName in pairs(SC_WeaponSkins) do
                    if skinName:find(weaponName, 1, true) then target = weaponName break end
                end
                if not target then
                    local model = folder:FindFirstChild(skinName)
                    local mine = model and partNames(model) or {}
                    local best = 1
                    for weaponName, parts in pairs(weaponParts) do
                        local score = 0
                        for n in pairs(mine) do if parts[n] then score = score + 1 end end
                        if score > best then best, target = score, weaponName end
                    end
                end
                if target then
                    local skins = SC_WeaponSkins[target]
                    skins[#skins + 1] = skinName
                    SC_SkinToWeapon[skinName] = target
                end
            end
        end
    end
    for key, list in pairs(SC_CosNames) do if key ~= "Images" then table.sort(list) end end

    for skinName, folder in pairs(SC_SkinLookup) do
        if folder ~= wf and not SC_SkinToWeapon[skinName] then
            if ItemLib and ItemLib.ViewModels and ItemLib.ViewModels[skinName] then
                for weaponName, skins in pairs(SC_WeaponSkins) do
                    if skinName:find(weaponName) then
                        local alreadyIn = false
                        for _, s in ipairs(skins) do if s == skinName then alreadyIn = true break end end
                        if not alreadyIn then
                            skins[#skins + 1] = skinName
                        end
                        SC_SkinToWeapon[skinName] = weaponName
                        break
                    end
                end
            end
        end
    end

    for w, s in pairs(SC_WeaponSkins) do
        table.sort(s, function(a, b)
            if a == w then return true end
            if b == w then return false end
            return a < b
        end)
    end
    for _, ws in pairs(SC_WeaponsByClass) do table.sort(ws) end

    local rsModules = RS:FindFirstChild("Modules")
    if rsModules then
        local sl = rsModules:FindFirstChild("SoundLibrary")
        if sl then
            local vms = sl:FindFirstChild("ViewModelSounds")
            if vms then
                SC_ViewModelSounds = Game_Require(vms)
            end
        end
    end

    SC_Initialized = true

    -- live view-models are assembled by the game in RS.Assets.Temp.ViewModels.<player>
    -- as "<Weapon> - <Skin>"; complete them with parts the item class WaitForChild()s.
    pcall(function()
        local function originalFor(weaponName)
            if not SC_ActiveSkins[weaponName] then return nil end
            local o = SC_Originals[weaponName]
            if o then return o end
            local cur = SC_WeaponsFolder and SC_WeaponsFolder:FindFirstChild(weaponName)
            -- template is only swapped in the non-spoof path (then SC_Originals holds it)
            if cur and SC_SpoofSkins[weaponName] then return cur end
            return nil
        end
        SC_Helpers.OriginalFor = originalFor
        local function onVM(m)
            if not (m:IsA("Model") or m:IsA("Folder")) then return end
            local o = nil
            for seg in (m.Name .. " - "):gmatch("(.-)%s+%-%s+") do
                o = originalFor(seg)
                if o then break end
            end
            if not o then o = originalFor(m.Name) end
            if not o or o == m then return end
            local function fill()
                local iv = m:FindFirstChild("ItemVisual")
                if iv then pcall(SC_Helpers.FillMissing, iv, o) return true end
                return false
            end
            task.defer(function()
                if fill() then return end
                local conn
                conn = m.ChildAdded:Connect(function(c)
                    if c.Name == "ItemVisual" then
                        conn:Disconnect()
                        task.defer(fill)
                    end
                end)
                task.delay(5, function() pcall(function() conn:Disconnect() end) end)
            end)
        end
        local function watchFolder(f)
            f.ChildAdded:Connect(onVM)
            for _, c in ipairs(f:GetChildren()) do onVM(c) end
        end
        local temp = RS:WaitForChild("Assets", 10)
        temp = temp and temp:WaitForChild("Temp", 10)
        local vms = temp and temp:WaitForChild("ViewModels", 10)
        if not vms then return end
        local function tryChild(f)
            if f.Name == Local_Player.Name then watchFolder(f)
            elseif f.Name:sub(1, #Local_Player.Name + 3) == Local_Player.Name .. " - " then onVM(f) end
        end
        vms.ChildAdded:Connect(tryChild)
        for _, f in ipairs(vms:GetChildren()) do tryChild(f) end
    end)
    return true
end

local function SC_GetCurrentWeapon()
    local vmf = Workspace:FindFirstChild("ViewModels")
    if not vmf then return nil end
    local fp = vmf:FindFirstChild("FirstPerson")
    if not fp then return nil end
    for _, child in ipairs(fp:GetChildren()) do
        if child:IsA("Model") and child.Name:find(Local_Player.Name) then
            local parts = string.split(child.Name, " - ")
            if #parts >= 2 then return parts[2] end
        end
    end
    return nil
end

local SC_SoundSetup = false
local SC_ItemSounds = nil
local SC_SkinSoundMap = {}

local function SC_Normalize(name)
    if not name then return "" end
    return name:lower():gsub(" ", ""):gsub("-", ""):gsub("'", ""):gsub("%.", "")
end

local function SC_BuildWeaponSoundMap(weaponName, skinName)
    SC_SkinSoundMap[weaponName] = nil
    if SC_SpoofSkins[weaponName] then return end
    if not SC_ItemSounds then return end
    if not skinName or skinName == weaponName then return end

    local normWeapon = SC_Normalize(weaponName)
    local normSkin = SC_Normalize(skinName)
    local map = {}
    local found = false

    for key, sounds in pairs(SC_ItemSounds) do
        if type(sounds) == "table" and key:sub(1, #normWeapon + 1) == normWeapon .. "_" then
            local rest = key:sub(#normWeapon + 2)
            local skinKey = normWeapon .. "_" .. normSkin .. "_" .. rest
            if SC_ItemSounds[skinKey] then
                local skinSounds = SC_ItemSounds[skinKey]
                for _, defaultSoundId in ipairs(sounds) do
                    if type(defaultSoundId) == "string" and not map[defaultSoundId] then
                        if type(skinSounds) == "table" and #skinSounds > 0 then
                            map[defaultSoundId] = skinSounds
                            found = true
                        end
                    end
                end
            end
        end
    end

    if SC_ViewModelSounds and SC_ViewModelSounds[skinName] then
        local vms = SC_ViewModelSounds[skinName]
        if type(vms) == "table" and #vms > 0 then
            map["__viewmodel__"] = vms
            found = true
        end
    end

    if found then
        SC_SkinSoundMap[weaponName] = map
    end
end

local function SC_SetupSkinSounds()
    if SC_SoundSetup then return end
    SC_SoundSetup = true

    local ps = Local_Player:FindFirstChild("PlayerScripts")
    if not ps then return end
    local mods = ps:FindFirstChild("Modules")
    if not mods then return end

    pcall(function()
        local rsM = RS:FindFirstChild("Modules")
        if not rsM then return end
        local sl = rsM:FindFirstChild("SoundLibrary")
        if not sl then return end
        local isMod = sl:FindFirstChild("ItemSounds")
        if isMod then
            SC_ItemSounds = Game_Require(isMod)
        end
    end)

    pcall(function()
        local crc = mods:FindFirstChild("ClientReplicatedClasses")
        if not crc then return end
        local cf = crc:FindFirstChild("ClientFighter")
        if not cf then return end
        local ci = cf:FindFirstChild("ClientItem")
        if not ci then return end
        local cvmModule = ci:FindFirstChild("ClientViewModel")
        if not cvmModule then return end

        local ClientViewModel = Game_Require(cvmModule)
        if not ClientViewModel then return end

        if ClientViewModel.CreateSound then
            local origCreateSound = ClientViewModel.CreateSound
            ClientViewModel.CreateSound = function(self, soundId, ...)
                if Config.SC_Enabled and type(soundId) == "string" then
                    pcall(function()
                        local weaponName = self.ClientItem and self.ClientItem.Name
                        local player = self.ClientItem and self.ClientItem.ClientFighter and self.ClientItem.ClientFighter.Player
                        if player == Local_Player and weaponName and SC_SkinSoundMap[weaponName] then
                            local smap = SC_SkinSoundMap[weaponName]
                            local replacement = smap[soundId]
                            if replacement then
                                soundId = replacement[math.random(1, #replacement)]
                            elseif smap["__viewmodel__"] then
                                local vms = smap["__viewmodel__"]
                                soundId = vms[math.random(1, #vms)]
                            end
                        end
                    end)
                end
                return origCreateSound(self, soundId, ...)
            end
        end

        if ClientViewModel.CreateSpectatorSound then
            local origSpecSound = ClientViewModel.CreateSpectatorSound
            ClientViewModel.CreateSpectatorSound = function(self, soundId, ...)
                if Config.SC_Enabled and type(soundId) == "string" then
                    pcall(function()
                        local weaponName = self.ClientItem and self.ClientItem.Name
                        local player = self.ClientItem and self.ClientItem.ClientFighter and self.ClientItem.ClientFighter.Player
                        if player == Local_Player and weaponName and SC_SkinSoundMap[weaponName] then
                            local smap = SC_SkinSoundMap[weaponName]
                            local replacement = smap[soundId]
                            if replacement then
                                soundId = replacement[math.random(1, #replacement)]
                            elseif smap["__viewmodel__"] then
                                local vms = smap["__viewmodel__"]
                                soundId = vms[math.random(1, #vms)]
                            end
                        end
                    end)
                end
                return origSpecSound(self, soundId, ...)
            end
        end
    end)

    pcall(function()
        local crc = mods:FindFirstChild("ClientReplicatedClasses")
        if not crc then return end
        local cf = crc:FindFirstChild("ClientFighter")
        if not cf then return end
        local ci = cf:FindFirstChild("ClientItem")
        if not ci then return end

        local ClientItem = Game_Require(ci)
        if not ClientItem then return end

        if ClientItem.CreateSound then
            local origCISound = ClientItem.CreateSound
            ClientItem.CreateSound = function(self, soundId, ...)
                if Config.SC_Enabled and type(soundId) == "string" then
                    pcall(function()
                        local weaponName = self.Name
                        local player = self.ClientFighter and self.ClientFighter.Player
                        if player == Local_Player and weaponName and SC_SkinSoundMap[weaponName] then
                            local smap = SC_SkinSoundMap[weaponName]
                            local replacement = smap[soundId]
                            if replacement then
                                soundId = replacement[math.random(1, #replacement)]
                            elseif smap["__viewmodel__"] then
                                local vms = smap["__viewmodel__"]
                                soundId = vms[math.random(1, #vms)]
                            end
                        end
                    end)
                end
                return origCISound(self, soundId, ...)
            end
        end
    end)
end

-- The game's item classes WaitForChild() parts by name inside the view-model
-- (e.g. Bow: ItemVisual.Arrow.Feather). Skin models that lack them hang the
-- equip forever, so copy every missing named child over from the original
-- model (hidden, so nothing extra is rendered).
SC_Helpers = SC_Helpers or {}
-- plain method calls (not namecalls) so the pending namecall method is untouched inside hooks
SC_Helpers.IsA, SC_Helpers.FFC, SC_Helpers.GD = game.IsA, game.FindFirstChild, game.GetDescendants
function SC_Helpers.HideClone(c)
    pcall(function()
        for _, d in ipairs(SC_Helpers.GD(c)) do
            if SC_Helpers.IsA(d, "BasePart") then d.Transparency = 1 d.CanCollide = false
            elseif SC_Helpers.IsA(d, "Decal") or SC_Helpers.IsA(d, "Texture") then d.Transparency = 1
            elseif SC_Helpers.IsA(d, "ParticleEmitter") or SC_Helpers.IsA(d, "Beam") or SC_Helpers.IsA(d, "Trail") or SC_Helpers.IsA(d, "Light") then d.Enabled = false end
        end
        if SC_Helpers.IsA(c, "BasePart") then c.Transparency = 1 c.CanCollide = false
        elseif SC_Helpers.IsA(c, "Decal") or SC_Helpers.IsA(c, "Texture") then c.Transparency = 1 end
    end)
end
SC_Helpers.OriginalFor = function() return nil end
-- WaitForChild fallback: `inst` is inside a live view-model and lacks `childName`;
-- clone it (hidden) from the same path in the original weapon model.
function SC_Helpers.EnsureChild(inst, childName)
    local path = {}
    local root = inst
    local function isVMFolder(f)
        if not f then return false end
        if f.Name == "ViewModels" then return true end
        return f.Parent ~= nil and f.Parent.Name == "ViewModels" and f.Name == Local_Player.Name
    end
    for _ = 1, 16 do
        if not root.Parent then return nil end
        if isVMFolder(root.Parent) then break end
        table.insert(path, 1, root.Name)
        root = root.Parent
    end
    local o = nil
    for seg in (root.Name .. " - "):gmatch("(.-)%s+%-%s+") do
        o = SC_Helpers.OriginalFor(seg)
        if o then break end
    end
    if not o then return nil end
    -- live model: <root>.ItemVisual.<Part>; template: <Weapon>.<Part>; "Primary" is renamed "<Part>Primary"
    if path[1] == "ItemVisual" then table.remove(path, 1) end
    local src = o
    for _, n in ipairs(path) do
        src = SC_Helpers.FFC(src, n) or (n:sub(-7) == "Primary" and SC_Helpers.FFC(src, "Primary")) or nil
        if not src then return nil end
    end
    local child = SC_Helpers.FFC(src, childName)
    if not child and childName:sub(-7) == "Primary" then child = SC_Helpers.FFC(src, "Primary") end
    if not child then return nil end
    local ok, c = pcall(child.Clone, child)
    if not ok or not c then return nil end
    SC_Helpers.HideClone(c)
    c.Parent = inst
    return c
end
-- Live view-models rename "Primary" -> "<Part>Primary", so it is skipped there;
-- template-level swaps (withPrimary) copy it so direct `.Primary` indexing keeps working.
function SC_Helpers.FillMissing(target, source, withPrimary)
    pcall(function()
        for k, v in pairs(source:GetAttributes()) do
            if target:GetAttribute(k) == nil then target:SetAttribute(k, v) end
        end
    end)
    for _, child in ipairs(source:GetChildren()) do
        if child.Name ~= "" and (withPrimary or child.Name ~= "Primary") then
            local mine = target:FindFirstChild(child.Name)
            if not mine then
                local ok, c = pcall(child.Clone, child)
                if ok and c then
                    SC_Helpers.HideClone(c)
                    c.Parent = target
                end
            elseif mine.ClassName == child.ClassName or (mine:IsA("BasePart") and child:IsA("BasePart")) then
                SC_Helpers.FillMissing(mine, child, withPrimary)
            end
        end
    end
    if withPrimary and target:IsA("Model") and not target.PrimaryPart then
        local pp = target:FindFirstChild("Primary")
        if not pp and source:IsA("Model") and source.PrimaryPart then pp = target:FindFirstChild(source.PrimaryPart.Name) end
        if pp and pp:IsA("BasePart") then target.PrimaryPart = pp end
    end
end

local function SC_SwapTemplate(weaponName, skinName)
    if not SC_WeaponsFolder then return false end

    if SC_Originals[weaponName] then
        local current = SC_WeaponsFolder:FindFirstChild(weaponName)
        if current then current:Destroy() end
        SC_Originals[weaponName].Name = weaponName
        SC_Originals[weaponName].Parent = SC_WeaponsFolder
        SC_Originals[weaponName] = nil
    end

    if skinName == weaponName or not skinName then
        SC_ActiveSkins[weaponName] = nil
        SC_SkinSoundMap[weaponName] = nil
        return true
    end

    local sourceFolder = SC_SkinLookup[skinName]
    if not sourceFolder then return false end

    local skinModel = sourceFolder:FindFirstChild(skinName)
    if not skinModel then return false end

    local original = SC_WeaponsFolder:FindFirstChild(weaponName)
    if not original then return false end

    local skinClone = skinModel:Clone()
    pcall(SC_Helpers.FillMissing, skinClone, original, true)

    original.Parent = nil
    SC_Originals[weaponName] = original

    skinClone.Name = weaponName
    skinClone.Parent = SC_WeaponsFolder

    SC_ActiveSkins[weaponName] = skinName
    pcall(SC_BuildWeaponSoundMap, weaponName, skinName)
    return true
end

local function SC_RestoreAll()
    for weaponName, original in pairs(SC_Originals) do
        local current = SC_WeaponsFolder:FindFirstChild(weaponName)
        if current then current:Destroy() end
        original.Name = weaponName
        original.Parent = SC_WeaponsFolder
    end
    SC_Originals = {}
    SC_ActiveSkins = {}
    SC_SkinSoundMap = {}
    for weaponName in pairs(SC_SpoofSkins) do SC_SpoofSkins[weaponName] = nil end
end

local function SC_ForceReEquip()
    local Now = Tick()
    if Now - (Data.SC_ReEquip_Notified or 0) < 3 then return end
    if SC_GetCurrentWeapon() then
        Data.SC_ReEquip_Notified = Now
        pcall(function() Library:Notify("SKINS", "Switch weapon to apply", 3) end)
    end
end

local SC_WrapController = nil
local SC_WrapProps = {}
local SC_ActiveWrap = {}

local function SC_GetWrapController()
    if SC_WrapController then return SC_WrapController end
    local ps = Local_Player:FindFirstChild("PlayerScripts")
    local ctrl = ps and ps:FindFirstChild("Controllers")
    local mod = ctrl and ctrl:FindFirstChild("WrapController")
    if not mod then return nil end
    SC_WrapController = Game_Require(mod)
    return SC_WrapController
end

local function SC_TemplateFor(weaponName)
    local skinName = SC_SpoofSkins[weaponName]
    if skinName then
        local folder = SC_SkinLookup[skinName]
        local model = folder and folder:FindFirstChild(skinName)
        if model then return model end
    end
    return SC_WeaponsFolder and SC_WeaponsFolder:FindFirstChild(weaponName)
end

local function SC_ApplyWrap(weaponName, wrapName, inverted)
    local model = SC_TemplateFor(weaponName)
    if not model then return false, "weapon model not found" end
    local WC = SC_GetWrapController()
    if not WC then return false, "WrapController unavailable" end

    if SC_WrapProps[weaponName] then
        pcall(function() WC:ResetWrap(SC_WrapProps[weaponName]) end)
        SC_WrapProps[weaponName] = nil
    end
    SC_ActiveWrap[weaponName] = nil

    if not wrapName or wrapName == "None" or wrapName == "" then
        pcall(SC_ForceReEquip)
        return true
    end

    local ok, err = pcall(function()
        local props = WC:RecordOriginalWrapProperties(model)
        SC_WrapProps[weaponName] = props
        WC:ApplyWrap(props, { Name = wrapName, Inverted = inverted and true or false })
    end)
    if not ok then
        SC_WrapProps[weaponName] = nil
        return false, tostring(err)
    end
    SC_ActiveWrap[weaponName] = { name = wrapName, inverted = inverted and true or false }
    pcall(SC_ForceReEquip)
    return true
end

local function SC_ResetWraps()
    local WC = SC_GetWrapController()
    for _, props in pairs(SC_WrapProps) do
        if WC then pcall(function() WC:ResetWrap(props) end) end
    end
    SC_WrapProps = {}
    SC_ActiveWrap = {}
    pcall(SC_ForceReEquip)
end

local SC_Charm = {}
do
local SC_ActiveCharm = {}
local SC_CharmModule = nil
local SC_CharmModulesFolder = nil
local SC_CharmAssetsFolder = nil
local SC_VM_Class = nil
local SC_VM_BaseGet = nil
local SC_LiveVM = nil
local SC_VMs = setmetatable({}, { __mode = "k" })

local function SC_GetCharmModule()
    if SC_CharmModule ~= nil then return SC_CharmModule end
    local ps = Local_Player:FindFirstChild("PlayerScripts")
    local mods = ps and ps:FindFirstChild("Modules")
    if not mods then return nil end
    local m = mods:FindFirstChild("Charm")
    if m then SC_CharmModule = Game_Require(m) end
    SC_CharmModulesFolder = mods:FindFirstChild("Charms")
    return SC_CharmModule
end

local function SC_GetCharmAssets()
    if SC_CharmAssetsFolder then return SC_CharmAssetsFolder end
    local ps = Local_Player:FindFirstChild("PlayerScripts")
    local assets = ps and ps:FindFirstChild("Assets")
    SC_CharmAssetsFolder = assets and assets:FindFirstChild("Charms")
    return SC_CharmAssetsFolder
end

function SC_Charm.GetPreview(charmName)
    if not charmName then return nil end
    local assets = SC_GetCharmAssets()
    return assets and assets:FindFirstChild(charmName) or nil
end

local function SC_CharmFor(vm)
    local name
    pcall(function()
        local item = vm.ClientItem
        name = item and item.Name or vm.Name
    end)
    if not name then return nil end
    local want = SC_ActiveCharm[name]
    if not want and vm.Name then want = SC_ActiveCharm[vm.Name] end
    if not want and SC_SkinToWeapon then
        local base = SC_SkinToWeapon[name]
        if base then want = SC_ActiveCharm[base] end
    end
    return want
end

local function SC_HookViewModel()
    if SC_VM_Class then return true end
    local ps = Local_Player:FindFirstChild("PlayerScripts")
    local node = ps and ps:FindFirstChild("Modules")
    for _, seg in ipairs({"ClientReplicatedClasses", "ClientFighter", "ClientItem", "ClientViewModel"}) do
        node = node and node:FindFirstChild(seg)
    end
    if not node or not node:IsA("ModuleScript") then return false end
    local cls = Game_Require(node)
    if type(cls) ~= "table" or type(cls.Get) ~= "function" then return false end

    SC_VM_Class = cls
    SC_VM_BaseGet = cls.Get

    if type(cls._Setup) == "function" then
        local baseSetup = cls._Setup
        cls._Setup = function(self, ...)
            pcall(function()
                if self.ClientItem.ClientFighter.IsLocalPlayer then SC_VMs[self] = true end
            end)
            return baseSetup(self, ...)
        end
    end

    cls.Get = function(self, key)
        if key == "Name" then
            local real = SC_VM_BaseGet(self, key)
            if type(real) == "string" then
                local mine = false
                pcall(function()
                    mine = self.ClientItem.ClientFighter.IsLocalPlayer and true or false
                end)
                if mine then
                    local want = SC_SpoofSkins[real] or SC_SpoofSkins[SC_SkinToWeapon[real] or real]
                    if want and want ~= real then return want end
                end
            end
            return real
        end
        if key == "Charm" then
            local mine = false
            pcall(function()
                mine = self.ClientItem.ClientFighter.IsLocalPlayer and true or false
            end)
            if mine then
                local want = SC_CharmFor(self)
                if want then return { Name = want } end
            end
        end
        return SC_VM_BaseGet(self, key)
    end
    return true
end

local function SC_FindLiveViewModel()
    if SC_LiveVM then
        local alive = false
        pcall(function() alive = SC_LiveVM.Model and SC_LiveVM.Model.Parent ~= nil end)
        if alive then return SC_LiveVM end
        SC_LiveVM = nil
    end
    for vm in pairs(SC_VMs) do
        local alive = false
        pcall(function()
            alive = typeof(vm.Model) == "Instance" and vm.Model.Parent ~= nil
        end)
        if alive then
            SC_LiveVM = vm
            return vm
        else
            SC_VMs[vm] = nil
        end
    end
    return nil
end

local function SC_SwapLiveCharm(want)
    local vm = SC_FindLiveViewModel()
    if not vm then return false end
    if SC_CharmFor(vm) ~= want then return false end

    local pivot = vm._charm_pivot_attachment
    if typeof(pivot) ~= "Instance" or not pivot.Parent then return false end

    local CM = SC_GetCharmModule()
    if not CM then return false end

    local ok = pcall(function()
        if vm.Charm then
            vm.Charm:Destroy()
            vm.Charm = nil
        end
        if not want then return end
        local custom = SC_CharmModulesFolder and SC_CharmModulesFolder:FindFirstChild(want, true)
        local Class = CM
        if custom then
            local res = Game_Require(custom)
            if res then Class = res end
        end
        local obj = Class.new(vm, { Name = want }, pivot)
        vm.Charm = obj
        obj:SetParent(vm.Model)
    end)
    return ok
end

function SC_Charm.Apply(weaponName, charmName)
    if Is_Weak then
        return false, "not supported on this executor"
    end
    if not weaponName or weaponName == "" or weaponName == "..." then
        return false, "no weapon selected"
    end
    if not SC_HookViewModel() then
        return false, "ClientViewModel unavailable"
    end
    if not SC_GetCharmModule() then
        return false, "Charm module unavailable"
    end

    if not charmName or charmName == "None" or charmName == "" then
        SC_ActiveCharm[weaponName] = nil
        if not SC_SwapLiveCharm(nil) then pcall(SC_ForceReEquip) end
        return true
    end

    local assets = SC_GetCharmAssets()
    if not assets or not assets:FindFirstChild(charmName) then
        return false, "charm model not found"
    end

    SC_ActiveCharm[weaponName] = charmName
    if not SC_SwapLiveCharm(charmName) then
        pcall(SC_ForceReEquip)
    end
    return true
end

function SC_Charm.Reset()
    SC_ActiveCharm = {}
    if not SC_SwapLiveCharm(nil) then pcall(SC_ForceReEquip) end
end

SC_Charm.HookViewModel = SC_HookViewModel
end

local function SC_ApplySkin(weaponName, skinName)
    if not weaponName or weaponName == "" or weaponName == "..." then
        return false, "no weapon selected"
    end
    local reset = (not skinName) or skinName == "" or skinName == weaponName

    if not Is_Weak and SC_Charm.HookViewModel and SC_Charm.HookViewModel() then
        SC_SpoofSkins[weaponName] = nil
        pcall(SC_SwapTemplate, weaponName, weaponName)
        if not reset then
            if not SC_SkinLookup[skinName] then return false, "skin model not found" end
            local hasInfo = SC_ItemLib and SC_ItemLib.ViewModels and SC_ItemLib.ViewModels[skinName]
            if not hasInfo then
                local ok = SC_SwapTemplate(weaponName, skinName)
                if ok then pcall(SC_ForceReEquip) end
                return ok, (not ok) and "skin model not found" or nil
            end
            SC_SpoofSkins[weaponName] = skinName
            SC_ActiveSkins[weaponName] = skinName
            task.spawn(function()
                local folder = SC_SkinLookup[skinName]
                local model = folder and folder:FindFirstChild(skinName)
                if model then
                    pcall(function()
                        game:GetService("ContentProvider"):PreloadAsync({ model })
                    end)
                end
            end)
        end
        pcall(SC_ForceReEquip)
        return true
    end

    SC_SpoofSkins[weaponName] = nil
    local ok = SC_SwapTemplate(weaponName, reset and weaponName or skinName)
    if ok then pcall(SC_ForceReEquip) end
    return ok, (not ok) and "skin model not found" or nil
end

local SC_Fin = {}
do
local SC_WantFinisher = nil
local SC_FinisherOnlyMine = true
local SC_FinishersFolder = nil
local SC_FinisherHooked = false
local SC_FinBuilding = false
local SC_FinClasses = {}
local SC_FinLastError = nil

local function SC_GetFinishersFolder()
    if SC_FinishersFolder then return SC_FinishersFolder end
    local mods = RS:FindFirstChild("Modules")
    SC_FinishersFolder = mods and mods:FindFirstChild("Finishers")
    return SC_FinishersFolder
end

local function SC_GetFinisherClass(name)
    if SC_FinClasses[name] ~= nil then return SC_FinClasses[name] or nil end
    local folder = SC_GetFinishersFolder()
    local mod = folder and folder:FindFirstChild(name)
    if not mod or not mod:IsA("ModuleScript") then return nil end
    local cls = Game_Require(mod)
    if type(cls) == "table" and type(cls.new) == "function" then
        SC_FinClasses[name] = cls
        return cls
    end
    return nil
end

local function SC_FinisherIsMine(eliminator)
    if eliminator == nil then return false end
    local char = Local_Player.Character
    if typeof(eliminator) == "Instance" then
        if eliminator == Local_Player then return true end
        if char and (eliminator == char or eliminator:IsDescendantOf(char)) then return true end
        local ok, plr = pcall(Players.GetPlayerFromCharacter, Players, eliminator)
        return ok and plr == Local_Player
    end
    if type(eliminator) == "table" then
        local mine = false
        pcall(function()
            local c = rawget(eliminator, "Character")
            if eliminator.Player == Local_Player then mine = true end
            if char and c == char then mine = true end
            if typeof(c) == "Instance" and Players:GetPlayerFromCharacter(c) == Local_Player then mine = true end
        end)
        return mine
    end
    return false
end

local function SC_BuildWanted(subject, isFinal, eliminator)
    local want = SC_WantFinisher
    if not want or SC_FinBuilding then return nil end
    if SC_FinisherOnlyMine and not SC_FinisherIsMine(eliminator) then return nil end
    local cls = SC_GetFinisherClass(want)
    if not cls then return nil end
    SC_FinBuilding = true
    local ok, obj = pcall(cls.new, subject, isFinal, eliminator)
    SC_FinBuilding = false
    if ok and type(obj) == "table" then return obj end
    if not ok then SC_FinLastError = tostring(obj) end
    return nil
end

local function SC_WrapClass(cls)
    if type(cls) ~= "table" then return end
    local base = rawget(cls, "new")
    if type(base) ~= "function" or rawget(cls, "_ph_wrapped") then return end
    rawset(cls, "_ph_wrapped", true)
    rawset(cls, "new", function(subject, isFinal, eliminator, ...)
        local swapped = SC_BuildWanted(subject, isFinal, eliminator)
        if swapped then return swapped end
        return base(subject, isFinal, eliminator, ...)
    end)
end

local function SC_HookFinisher()
    if SC_FinisherHooked then return true end
    local folder = SC_GetFinishersFolder()
    if not folder then return false end

    local kids = folder:GetChildren()
    task.spawn(function()
        for i, mod in ipairs(kids) do
            if mod:IsA("ModuleScript") then
                local cls = Game_Require(mod)
                if type(cls) == "table" then
                    SC_FinClasses[mod.Name] = cls
                    pcall(SC_WrapClass, cls)
                end
            end
            if i % 8 == 0 then task.wait() end
        end
    end)

    pcall(function()
        local mods = RS:FindFirstChild("Modules")
        local baseMod = mods and mods:FindFirstChild("Finisher")
        if not baseMod or not baseMod:IsA("ModuleScript") then return end
        local cls = Game_Require(baseMod)
        if type(cls) ~= "table" or type(cls.Simulate) ~= "function" then return end
        if rawget(cls, "_ph_sim_wrapped") then return end
        rawset(cls, "_ph_sim_wrapped", true)
        local baseSimulate = cls.Simulate
        cls.Simulate = function(self, onError)
            if not rawget(self, "_ph_finisher") then
                local swapped = SC_BuildWanted(rawget(self, "_subject"), rawget(self, "_is_final_finisher"), rawget(self, "_eliminator"))
                if swapped then
                    rawset(swapped, "_ph_finisher", true)
                    task.delay(20, function() pcall(function() swapped:Destroy() end) end)
                    return baseSimulate(swapped, onError)
                end
            end
            return baseSimulate(self, onError)
        end
    end)

    SC_FinisherHooked = true
    return true
end

function SC_Fin.Apply(name)
    if not name or name == "None" or name == "" then
        SC_WantFinisher = nil
        return true
    end
    if Is_Weak then
        return false, "not supported on this executor"
    end
    if not SC_GetFinishersFolder() then
        return false, "Finishers folder unavailable"
    end
    if not SC_GetFinisherClass(name) then
        return false, "finisher module not found"
    end
    if not SC_HookFinisher() then
        return false, "could not hook finisher classes"
    end
    SC_WantFinisher = name
    return true
end

function SC_Fin.Reset()
    SC_WantFinisher = nil
end

function SC_Fin.SetOnlyMine(state)
    SC_FinisherOnlyMine = state and true or false
end

function SC_Fin.Selected()
    return SC_WantFinisher
end

function SC_Fin.LastError()
    return SC_FinLastError
end
end

local function Set_Vis(Obj, State)
    if Obj.Visible ~= State then Obj.Visible = State end
end

local function Is_Alive(Player)
    local Char = Player and Player.Character
    if not Char then return false end
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    return Hum and Hum.Health > 0
end

local function Is_Whitelisted(Player)
    if not Config.Whitelist_Enabled then return false end
    if not Player then return false end
    return Data.Whitelist[Player.Name] == true
end

local Is_Visible = LPH_NO_VIRTUALIZE(function(Target_Pos, Target_Char)
    local Camera = Workspace.CurrentCamera
    local Ig = {Camera}
    if Local_Player.Character then Ig[2] = Local_Player.Character end
    Wall_Params.FilterDescendantsInstances = Ig
    Wall_Params.FilterType = Enum.RaycastFilterType.Exclude
    local Origin = Camera.CFrame.Position
    local Result = Workspace:Raycast(Origin, Target_Pos - Origin, Wall_Params)
    if Result then
        return Result.Instance:IsDescendantOf(Target_Char)
    end
    return true
end)

local function Player_From_Instance(Inst)
    local M = Inst:FindFirstAncestorWhichIsA("Model")
    while M do
        local P = Players:GetPlayerFromCharacter(M)
        if P then return P end
        M = M:FindFirstAncestorWhichIsA("Model")
    end
    return nil
end

local Get_Player_Loadout = LPH_NO_VIRTUALIZE(function(Player)
    local Now = Tick()
    if Now - Data.Loadout_Scan.T >= 0.5 then
        Data.Loadout_Scan.T = Now
        local Map = {}
        local Vmf = Workspace:FindFirstChild("ViewModels")
        if Vmf then
            for _, M in ipairs(Vmf:GetDescendants()) do
                if M:IsA("Model") then
                    local Parts = string.split(M.Name, " - ")
                    if #Parts >= 2 then
                        local Owner = Parts[1]
                        local W = Parts[2]
                        local L = Map[Owner]
                        if not L then L = { Seen = {}, Names = {} } Map[Owner] = L end
                        if W ~= "" and not L.Seen[W] then L.Seen[W] = true L.Names[#L.Names + 1] = W end
                    end
                end
            end
        end
        Data.Loadout_Scan.Map = Map
    end
    local L = Data.Loadout_Scan.Map[Player.Name]
    local Names = L and L.Names or {}
    local Seen = L and L.Seen or {}
    if #Names == 0 and Player.Character then
        Names = {}
        for _, T in ipairs(Player.Character:GetChildren()) do
            if T:IsA("Tool") and not Seen[T.Name] then Seen[T.Name] = true Names[#Names + 1] = T.Name end
        end
    end
    return Names
end)

local function Get_Gui_Ammo()
    if Cached_Ammo_Gui and Cached_Ammo_Gui.Parent then
        local C = string.split(Cached_Ammo_Gui.Text, "/")[1]
        if C then
            local Match = string.match(C, "%d+")
            if Match then return tonumber(Match) end
        end
        return nil
    end
    local Pg = Local_Player:FindFirstChild("PlayerGui")
    if not Pg then return nil end
    Cached_Ammo_Gui = Pg:FindFirstChild("Ammo", true)
    return nil
end

local function Execute_Reload()
    if Tick() - Last_Reload > 3 then
        Is_Reloading = true
        Last_Reload = Tick()
        Virtual_Input_Manager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
        task.wait(0.05)
        Virtual_Input_Manager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
    end
end

local function Same_Team(P1, P2)
    local T1 = P1:GetAttribute("TeamID")
    local T2 = P2:GetAttribute("TeamID")
    return T1 ~= nil and T2 ~= nil and T1 == T2
end

local Get_Part_From_Player
do
    local Aim_Part_Map = {
        ["Head"]            = {"HitboxHead", "Head"},
        ["Torso"]           = {"HitboxBody", "UpperTorso", "Torso", "HumanoidRootPart"},
        ["Body"]            = {"HitboxBody", "UpperTorso", "HumanoidRootPart"},
        ["RootPart"]        = {"HumanoidRootPart", "HitboxBody"},
        ["HumanoidRootPart"]= {"HumanoidRootPart", "HitboxBody"},
        ["Left Arm"]        = {"LeftHand", "LeftLowerArm", "LeftUpperArm", "Left Arm"},
        ["Right Arm"]       = {"RightHand", "RightLowerArm", "RightUpperArm", "Right Arm"},
        ["Left Leg"]        = {"LeftFoot", "LeftLowerLeg", "LeftUpperLeg", "Left Leg"},
        ["Right Leg"]       = {"RightFoot", "RightLowerLeg", "RightUpperLeg", "Right Leg"},
    }
    Get_Part_From_Player = function(Player, Part_Name)
        local Char = Player.Character
        if not Char then return nil end
        local names = Aim_Part_Map[Part_Name] or Aim_Part_Map["Head"]
        for _, n in ipairs(names) do
            local p = Char:FindFirstChild(n)
            if p and p:IsA("BasePart") then return p end
        end
        for _, n in ipairs(names) do
            local p = Char:FindFirstChild(n, true)
            if p and p:IsA("BasePart") then return p end
        end
        return Char:FindFirstChild("HumanoidRootPart") or Char:FindFirstChild("HumanoidRootPart", true)
    end
end

local Check_Shields = LPH_NO_VIRTUALIZE(function()
    if not Config.Auto_Shoot_Shield_Check then return false end
    local L_Pos = Local_Player.Character and Local_Player.Character:FindFirstChild("HumanoidRootPart") and Local_Player.Character.HumanoidRootPart.Position
    if not L_Pos then return false end

    local Plrs = Players:GetPlayers()
    for I = 1, #Plrs do
        local P = Plrs[I]
        if P == Local_Player or not Is_Alive(P) or Same_Team(P, Local_Player) then continue end
        local E_Pos = P.Character:FindFirstChild("HumanoidRootPart") and P.Character.HumanoidRootPart.Position
        if not E_Pos or (L_Pos - E_Pos).Magnitude > Config.Shield_Detect_Radius then continue end

        local M = P.Character:FindFirstChild("Model") or P.Character
        if M then
            local Uv = M:FindFirstChild("UnequippedViewModel", true) or M:FindFirstChild("_riot_shield_back", true)
            if Uv then
                for _, v in ipairs(Uv:GetDescendants()) do
                    if v:IsA("Weld") or v:IsA("Motor6D") then
                        if v.Part0 and v.Part0.Name == "UpperTorso" or v.Part1 and v.Part1.Name == "UpperTorso" then

                        else
                             return true
                        end
                    end
                end
                 local Sh = M:FindFirstChild("Shield", true) or M:FindFirstChild("RiotShield", true)
                 if Sh and Sh.Parent and (Sh.Parent:IsA("Model") or Sh.Parent:IsA("Tool")) then
                    local RightGrip = P.Character:FindFirstChild("RightGrip", true)
                    local LeftGrip = P.Character:FindFirstChild("LeftGrip", true)
                    if RightGrip or LeftGrip then return true end
                 end
            end
        end
    end
    return false
end)

Data.Aim_Cam_Ctrl = nil
Data.Aim_Cam_Ctrl_Tried = false
Data.Get_Aim_Cam_Ctrl = function()
    if Data.Aim_Cam_Ctrl_Tried then return Data.Aim_Cam_Ctrl end
    Data.Aim_Cam_Ctrl_Tried = true
    pcall(function()
        local Ps = Local_Player:FindFirstChild("PlayerScripts")
        local Ctrl = Ps and Ps:FindFirstChild("Controllers")
        local Cm = Ctrl and Ctrl:FindFirstChild("CameraController")
        if Cm and Cm:IsA("ModuleScript") then
            local Res = Game_Require(Cm)
            if type(Res) == "table" and type(Res.MimicRotation) == "function" then
                Data.Aim_Cam_Ctrl = Res
            end
        end
    end)
    return Data.Aim_Cam_Ctrl
end
-- rotates the view through the game's camera controller when possible (works without mousemoverel),
-- otherwise writes Camera.CFrame directly and drags the first person view-model along
Data.Aim_Rotate_Camera = LPH_NO_VIRTUALIZE(function(Camera, Oc, Nc)
    local Ctrl = Data.Get_Aim_Cam_Ctrl()
    if Ctrl then
        local Ok = pcall(Ctrl.MimicRotation, Ctrl, Nc)
        if Ok then return end
        Data.Aim_Cam_Ctrl = nil
    end
    Camera.CFrame = Nc
    local Dc = Oc:Inverse() * Nc
    local Vm = Workspace:FindFirstChild("ViewModels")
    if Vm then
        local Fp = Vm:FindFirstChild("FirstPerson")
        if Fp then
            for _, Vp in ipairs(Fp:GetChildren()) do
                if Vp.Name:find(Local_Player.Name, 1, true) then
                    local M = Vp:FindFirstChild("ViewModel")
                    if M then M:PivotTo(M:GetPivot() * Dc) end
                end
            end
        end
    end
end)

local Get_Best_Player = LPH_NO_VIRTUALIZE(function(Is_Silent)
    local Camera = Workspace.CurrentCamera
    local Cam_Pos = Camera.CFrame.Position
    local Center = Camera.ViewportSize / 2
    local Best, Shortest = nil, Math_Huge
    local Tpn = Is_Silent and Config.Sa_Part or Config.Aim_Part
    local Tc = Is_Silent and Config.Sa_Team_Check or Config.Aim_Team_Check
    local Wc = Config.Rage_Enabled and Config.Rage_Visible_Check or (Is_Silent and Config.Sa_Visible_Check or false)
    local Sm = Config.Rage_Enabled and Config.Rage_Selection or Config.Aim_Logic
    if Config.Rage_Enabled then Tpn = Config.Rage_Hitbox end

    local Random_Hitbox = Is_Silent and Config.Sa_Random_Hitbox and not Config.Rage_Enabled
    local Aim_Parts = {"Head", "Torso", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}

    local Plrs = Players:GetPlayers()
    for I = 1, #Plrs do
        local P = Plrs[I]
        if P == Local_Player or not Is_Alive(P) or (Tc and Same_Team(P, Local_Player)) then continue end
        if Is_Whitelisted(P) then continue end
        if Config.Anti_Katana and Data.Katana_Users[P] then continue end
        local PartName = Tpn
        if Random_Hitbox then PartName = Aim_Parts[Math_Random(1, #Aim_Parts)] end
        local Hp = Get_Part_From_Player(P, PartName)
        if not Hp then continue end
        local Wp = Hp.Position
        local D3 = (Wp - Cam_Pos).Magnitude
        if Config.Rage_Enabled and D3 > 1000 then continue end
        if not Config.Rage_Enabled and D3 > 1500 then continue end
        local Sp, Os = Camera:WorldToViewportPoint(Wp)
        local Aa_Spin = Data.Aa_Active
        if not Aa_Spin and (not Os or Sp.Z < 0) then continue end
        local Df = Sp.Z > 0 and (Center - Vector2_New(Sp.X, Sp.Y)).Magnitude or Math_Huge
        local Mf = Config.Rage_Enabled and Config.Rage_Fov or Config.Fov_Size
        if not Aa_Spin and (Config.Show_Fov or Config.Rage_Enabled) and Df > Mf then continue end
        if Wc then
            if not Is_Visible(Wp, P.Character) then continue end
        end
        local Val = Df
        if Aa_Spin then Val = D3
        elseif Sm == "Closest Player" or Sm == "Distance" then Val = D3
        elseif Sm == "Health" then
            local Hum = P.Character:FindFirstChildOfClass("Humanoid")
            Val = Hum and Hum.Health or Math_Huge
        end
        if Val < Shortest then Shortest = Val Best = P end
    end
    return Best
end)

local Resolve_Velocity = LPH_NO_VIRTUALIZE(function(Player, CurrentVel)
    if Config.Rage_Resolver == "Zero Velocity" then
        return Vector3_Zero
    elseif Config.Rage_Resolver == "Desync Resolver" then
        if Backtrack_History[Player] and #Backtrack_History[Player].Data >= 2 then
            local Bh = Backtrack_History[Player]
            local P1 = Bh.Data[1]
            local P2 = Bh.Data[2]
            if P1 and P2 and P1.T ~= P2.T then
                local CalcVel = (P1.P - P2.P) / (P1.T - P2.T)
                return Vector3_New(CalcVel.X, CurrentVel.Y, CalcVel.Z)
            end
        end
    end
    return CurrentVel
end)

local function Get_My_Viewmodel()
    local Vm_Folder = Workspace:FindFirstChild("ViewModels")
    if not Vm_Folder then return nil end
    local Fp = Vm_Folder:FindFirstChild("FirstPerson")
    if not Fp then return nil end
    for _, Child in ipairs(Fp:GetChildren()) do
        if Child:IsA("Model") and Child.Name:find(Local_Player.Name) then
            return Child
        end
    end
    return nil
end

local function Rebuild_Chams_Cache(Vm)
    Table_Clear(Chams_Cache)
    if not Vm then return end
    for _, Desc in ipairs(Vm:GetDescendants()) do
        if Desc:IsA("BasePart") then
            local N = Desc.Name:lower()
            local Is_Arm = N:find("arm") or N:find("hand") or N:find("finger") or N:find("sleeve") or N:find("glove") or N:find("wrist")
            local Is_Weapon = N:find("gun") or N:find("weapon") or N:find("barrel") or N:find("stock") or N:find("grip") or N:find("mag") or N:find("scope") or N:find("rail") or N:find("sight") or N:find("muzzle") or N:find("receiver") or N:find("trigger") or N:find("bolt") or N:find("suppressor") or N:find("laser") or N:find("attachment")
            Chams_Cache[#Chams_Cache + 1] = {
                Part = Desc,
                Is_Arm = Is_Arm and true or false,
                Is_Weapon = Is_Weapon and true or false,
                Orig_Material = Desc.Material,
                Orig_Color = Desc.Color,
                Orig_Transparency = Desc.Transparency
            }
        end
    end
end

local Apply_Chams = LPH_NO_VIRTUALIZE(function()
    local Vm = Get_My_Viewmodel()
    if not Vm then
        if Chams_Last_Vm then
            Chams_Last_Vm = nil
            Table_Clear(Chams_Cache)
        end
        return
    end
    if Vm ~= Chams_Last_Vm or Chams_Dirty then
        Chams_Last_Vm = Vm
        Rebuild_Chams_Cache(Vm)
        Chams_Dirty = false
    end
    local Mat = Material_Map[Config.Chams_Material] or Enum.Material.ForceField
    local Col = Config.Chams_Color
    if Config.Chams_Rainbow then
        Col = Color3_From_Hsv(Data.Chams_Hue, 1, 1)
    end
    for I = 1, #Chams_Cache do
        local D = Chams_Cache[I]
        local P = D.Part
        if not P.Parent then continue end
        local Should_Apply = true
        if Config.Chams_Arms_Only and not Config.Chams_Weapon_Only then
            Should_Apply = D.Is_Arm
        elseif Config.Chams_Weapon_Only and not Config.Chams_Arms_Only then
            Should_Apply = D.Is_Weapon
        elseif Config.Chams_Arms_Only and Config.Chams_Weapon_Only then
            Should_Apply = D.Is_Arm or D.Is_Weapon
        end
        if Should_Apply then
            if P.Material ~= Mat then P.Material = Mat end
            if P.Color ~= Col then P.Color = Col end
            if P.Transparency ~= Config.Chams_Transparency then P.Transparency = Config.Chams_Transparency end
        end
    end
end)

local function Remove_Chams()
    for I = 1, #Chams_Cache do
        local D = Chams_Cache[I]
        local P = D.Part
        if P and P.Parent then
            P.Material = D.Orig_Material
            P.Color = D.Orig_Color
            P.Transparency = D.Orig_Transparency
        end
    end
    Table_Clear(Chams_Cache)
    Chams_Last_Vm = nil
    Chams_Dirty = true
end

local function Create_Esp()
    local E = {
        Box = Drawing.new("Square"), Corner_Lines = {}, Name = Drawing.new("Text"), Distance = Drawing.new("Text"),
        Health_Bar_Bg = Drawing.new("Line"), Health_Bar = Drawing.new("Line"),
        Head_Circle = Drawing.new("Circle"), Tracer = Drawing.new("Line"), Skeleton = {}, Hp_Lerp = 1,
        Loadout = Drawing.new("Text"),
        Box3 = {}, Box3_Size = nil, Box3_Stamp = 0,
        Parts = {}, Bone_Parts = {}, Char = nil, Hidden = false, Shadow = {}
    }
    E.Box.Visible = false E.Box.Thickness = 1 E.Box.Filled = false E.Box.Transparency = 1
    for I = 1, 8 do
        local L = Drawing.new("Line")
        L.Visible = false L.Thickness = 1
        E.Corner_Lines[I] = L
    end
    E.Name.Visible = false E.Name.Center = true E.Name.Size = 14
    E.Distance.Visible = false E.Distance.Center = true E.Distance.Size = 12
    E.Loadout.Visible = false E.Loadout.Center = true E.Loadout.Size = 12 E.Loadout.Outline = true
    E.Health_Bar_Bg.Visible = false E.Health_Bar_Bg.Thickness = 3 E.Health_Bar_Bg.Color = Color3_From_Rgb(0, 0, 0)
    E.Health_Bar.Visible = false E.Health_Bar.Thickness = 1
    E.Head_Circle.Visible = false E.Head_Circle.Thickness = 1 E.Head_Circle.Filled = false
    E.Tracer.Visible = false E.Tracer.Thickness = 1
    for I = 1, 14 do
        local L = Drawing.new("Line")
        L.Visible = false L.Thickness = 1
        E.Skeleton[I] = L
    end
    return E
end

Data.Esp_Box3_Build = function(E)
    if #E.Box3 > 0 then return end
    for I = 1, 12 do
        local L = Drawing.new("Line")
        L.Visible = false L.Thickness = 1
        E.Box3[I] = L
    end
end

local function Hide_Esp(E)
    if E.Hidden then return end
    E.Hidden = true
    local B3 = E.Box3
    for I = 1, #B3 do Set_Vis(B3[I], false) end
    Set_Vis(E.Box, false) Set_Vis(E.Name, false) Set_Vis(E.Distance, false) Set_Vis(E.Loadout, false)
    Set_Vis(E.Health_Bar_Bg, false) Set_Vis(E.Health_Bar, false)
    Set_Vis(E.Head_Circle, false) Set_Vis(E.Tracer, false)
    local Cl = E.Corner_Lines
    for I = 1, 8 do Set_Vis(Cl[I], false) end
    local Sk = E.Skeleton
    for I = 1, 14 do Set_Vis(Sk[I], false) end
end

local function Remove_Esp(E)
    E.Hidden = false
    Hide_Esp(E)
    E.Box:Remove()
    for I = 1, 8 do E.Corner_Lines[I]:Remove() end
    E.Name:Remove() E.Distance:Remove() E.Loadout:Remove()
    E.Health_Bar_Bg:Remove() E.Health_Bar:Remove()
    E.Head_Circle:Remove() E.Tracer:Remove()
    for I = 1, 14 do E.Skeleton[I]:Remove() end
    for I = 1, #E.Box3 do E.Box3[I]:Remove() end
end

local R15_Bones = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}
local R6_Bones = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

local Update_Esp_All
do
local Esp_Ctx = {}
local Esp_Proj_X, Esp_Proj_Y, Esp_Proj_Ok = {}, {}, {}
local Esp_Hp_Red = Color3_From_Rgb(255, 0, 0)
local Esp_Hp_Green = Color3_From_Rgb(0, 255, 0)
local Esp_Loadout_Cache = setmetatable({}, { __mode = "k" })

local function Esp_Loadout_Text(Player)
    local C = Esp_Loadout_Cache[Player]
    local Now = Tick()
    if C and Now - C.T < 0.5 then return C.Text end
    local Lo = Get_Player_Loadout(Player)
    local Text = #Lo > 0 and table.concat(Lo, " | ") or ""
    if C then
        C.T = Now
        C.Text = Text
    else
        Esp_Loadout_Cache[Player] = { T = Now, Text = Text }
    end
    return Text
end

local function Esp_Set(E, D, K, V)
    local S = E.Shadow[D]
    if not S then S = {} E.Shadow[D] = S end
    if S[K] ~= V then
        S[K] = V
        D[K] = V
    end
end

local function Esp_Bone_Part(Char, Bp, Name)
    local P = Bp[Name]
    if P and P.Parent then return P end
    P = Char:FindFirstChild(Name)
    Bp[Name] = P
    return P
end

local function Esp_Project(Camera, Part, Name)
    local Ok = Esp_Proj_Ok[Name]
    if Ok == nil then
        local S, V = Camera:WorldToViewportPoint(Part.Position)
        Ok = (V and S.Z > 0) and true or false
        Esp_Proj_Ok[Name] = Ok
        Esp_Proj_X[Name] = S.X
        Esp_Proj_Y[Name] = S.Y
    end
    return Ok
end

local Box3_Offsets = {
    Vector3_New(-1, -1, -1), Vector3_New(1, -1, -1), Vector3_New(1, -1, 1), Vector3_New(-1, -1, 1),
    Vector3_New(-1, 1, -1), Vector3_New(1, 1, -1), Vector3_New(1, 1, 1), Vector3_New(-1, 1, 1)
}
local Box3_Edges = {
    {1, 2}, {2, 3}, {3, 4}, {4, 1},
    {5, 6}, {6, 7}, {7, 8}, {8, 5},
    {1, 5}, {2, 6}, {3, 7}, {4, 8}
}
local Box3_Px, Box3_Py = {}, {}

local function Esp_Draw_Box3(Camera, Char, E)
    Data.Esp_Box3_Build(E)
    local Now = Tick()
    if not E.Box3_Size or Now - E.Box3_Stamp > 1 then
        local Ok, _, Size = pcall(Char.GetBoundingBox, Char)
        if Ok and Size then E.Box3_Size = Size end
        E.Box3_Stamp = Now
        if not E.Box3_Size then E.Box3_Size = Vector3_New(4, 6, 2) end
    end
    local Hrp = E.Parts.Hrp
    local Cf = Cframe_New(Hrp.Position) * Cframe_Angles(0, select(2, Hrp.CFrame:ToEulerAnglesYXZ()), 0)
    local Half = E.Box3_Size * 0.5
    local Col = Config.Box_Color
    local Vis = true
    for I = 1, 8 do
        local O = Box3_Offsets[I]
        local Sp, On = Camera:WorldToViewportPoint((Cf * Cframe_New(O.X * Half.X, O.Y * Half.Y, O.Z * Half.Z)).Position)
        if Sp.Z <= 0 then Vis = false end
        Box3_Px[I] = Sp.X
        Box3_Py[I] = Sp.Y
    end
    for I = 1, 12 do
        local L = E.Box3[I]
        if Vis then
            local Ed = Box3_Edges[I]
            L.From = Vector2_New(Box3_Px[Ed[1]], Box3_Py[Ed[1]])
            L.To = Vector2_New(Box3_Px[Ed[2]], Box3_Py[Ed[2]])
            Esp_Set(E, L, "Color", Col)
            Set_Vis(L, true)
        else
            Set_Vis(L, false)
        end
    end
end

local Update_Esp
Update_Esp = LPH_NO_VIRTUALIZE(function(Player, E, Dt, Ctx)
    local Camera = Ctx.Camera
    local Char = Player.Character
    if not Char then Hide_Esp(E) return end
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    if not Hum or Hum.Health <= 0 then Hide_Esp(E) return end
    if E.Char ~= Char or not E.Parts.Hrp or not E.Parts.Head or not E.Parts.Hrp.Parent then
        E.Char = Char
        E.Parts.Head = Char:FindFirstChild("HitboxHead", true) or Char:FindFirstChild("Head", true)
        E.Parts.Hrp = Char:FindFirstChild("HumanoidRootPart") or Char:FindFirstChild("UpperTorso", true) or Char:FindFirstChild("Torso", true)
        Table_Clear(E.Bone_Parts)
    end
    local Hrp = E.Parts.Hrp
    local Head = E.Parts.Head
    if not Hrp or not Head then Hide_Esp(E) return end
    local Hrp_Pos = Hrp.Position
    local Dtc = (Hrp_Pos - Ctx.Cam_Pos).Magnitude
    if Dtc > 2500 then Hide_Esp(E) return end
    local Head_Pos = Head.Position
    local Top_Pos, Top_Vis = Camera:WorldToViewportPoint(Head_Pos + Vector3_New(0, 0.5, 0))
    local Bot_Pos, Bot_Vis = Camera:WorldToViewportPoint(Hrp_Pos - Vector3_New(0, 3.5, 0))
    if not Top_Vis or not Bot_Vis or Top_Pos.Z < 0 or Bot_Pos.Z < 0 then Hide_Esp(E) return end
    local H = Math_Abs(Top_Pos.Y - Bot_Pos.Y)
    local W = H * 0.6
    local Px = Top_Pos.X - (W / 2)
    local Py = Top_Pos.Y
    E.Hidden = false
    Esp_Set(E, E.Name, "Outline", Config.Esp_Outline)
    Esp_Set(E, E.Distance, "Outline", Config.Esp_Outline)
    if Config.Esp_Box then
        if Config.Esp_Box_Type == "3D" then
            Set_Vis(E.Box, false)
            for I = 1, 8 do Set_Vis(E.Corner_Lines[I], false) end
            Esp_Draw_Box3(Camera, Char, E)
        elseif Config.Esp_Box_Type == "Standard" then
            for I = 1, #E.Box3 do Set_Vis(E.Box3[I], false) end
            Set_Vis(E.Box, true)
            E.Box.Size = Vector2_New(W, H)
            E.Box.Position = Vector2_New(Px, Py)
            Esp_Set(E, E.Box, "Color", Config.Box_Color)
            for I = 1, 8 do Set_Vis(E.Corner_Lines[I], false) end
        else
            Set_Vis(E.Box, false)
            for I = 1, #E.Box3 do Set_Vis(E.Box3[I], false) end
            local Ll = W / 3
            local Cl = E.Corner_Lines
            local Ty, By, Lx, Rx = Py, Py + H, Px, Px + W
            local Bc = Config.Box_Color
            Cl[1].From = Vector2_New(Lx, Ty) Cl[1].To = Vector2_New(Lx + Ll, Ty) Esp_Set(E, Cl[1], "Color", Bc) Set_Vis(Cl[1], true)
            Cl[2].From = Vector2_New(Lx, Ty) Cl[2].To = Vector2_New(Lx, Ty + Ll) Esp_Set(E, Cl[2], "Color", Bc) Set_Vis(Cl[2], true)
            Cl[3].From = Vector2_New(Rx - Ll, Ty) Cl[3].To = Vector2_New(Rx, Ty) Esp_Set(E, Cl[3], "Color", Bc) Set_Vis(Cl[3], true)
            Cl[4].From = Vector2_New(Rx, Ty) Cl[4].To = Vector2_New(Rx, Ty + Ll) Esp_Set(E, Cl[4], "Color", Bc) Set_Vis(Cl[4], true)
            Cl[5].From = Vector2_New(Lx, By) Cl[5].To = Vector2_New(Lx + Ll, By) Esp_Set(E, Cl[5], "Color", Bc) Set_Vis(Cl[5], true)
            Cl[6].From = Vector2_New(Lx, By - Ll) Cl[6].To = Vector2_New(Lx, By) Esp_Set(E, Cl[6], "Color", Bc) Set_Vis(Cl[6], true)
            Cl[7].From = Vector2_New(Rx - Ll, By) Cl[7].To = Vector2_New(Rx, By) Esp_Set(E, Cl[7], "Color", Bc) Set_Vis(Cl[7], true)
            Cl[8].From = Vector2_New(Rx, By - Ll) Cl[8].To = Vector2_New(Rx, By) Esp_Set(E, Cl[8], "Color", Bc) Set_Vis(Cl[8], true)
        end
    else
        Set_Vis(E.Box, false)
        for I = 1, 8 do Set_Vis(E.Corner_Lines[I], false) end
        for I = 1, #E.Box3 do Set_Vis(E.Box3[I], false) end
    end
    if Config.Esp_Head_Circle then
        local Hp2, Hv = Camera:WorldToViewportPoint(Head_Pos)
        if Hv and Hp2.Z > 0 then
            Set_Vis(E.Head_Circle, true)
            E.Head_Circle.Position = Vector2_New(Hp2.X, Hp2.Y)
            E.Head_Circle.Radius = W / 5
            Esp_Set(E, E.Head_Circle, "Color", Config.Box_Color)
        else
            Set_Vis(E.Head_Circle, false)
        end
    else
        Set_Vis(E.Head_Circle, false)
    end
    if Config.Esp_Name then
        Set_Vis(E.Name, true)
        Esp_Set(E, E.Name, "Text", Player.Name)
        E.Name.Position = Vector2_New(Top_Pos.X, Py - 16)
        Esp_Set(E, E.Name, "Color", Config.Name_Color)
    else
        Set_Vis(E.Name, false)
    end
    if Config.Esp_Distance then
        local D = Math_Floor((Ctx.Local_Pos - Hrp_Pos).Magnitude)
        Set_Vis(E.Distance, true)
        Esp_Set(E, E.Distance, "Text", D .. "m")
        E.Distance.Position = Vector2_New(Top_Pos.X, Py + H + 2)
        Esp_Set(E, E.Distance, "Color", Config.Distance_Color)
    else
        Set_Vis(E.Distance, false)
    end
    if Config.Enemy_Loadout then
        local Lo = Esp_Loadout_Text(Player)
        if Lo ~= "" then
            Set_Vis(E.Loadout, true)
            Esp_Set(E, E.Loadout, "Text", Lo)
            E.Loadout.Position = Vector2_New(Top_Pos.X, Py + H + (Config.Esp_Distance and 16 or 2))
            Esp_Set(E, E.Loadout, "Color", Config.Name_Color)
        else
            Set_Vis(E.Loadout, false)
        end
    else
        Set_Vis(E.Loadout, false)
    end
    if Config.Esp_Health_Bar then
        local Mx = Hum.MaxHealth
        local Pct = Mx > 0 and Math_Clamp(Hum.Health / Mx, 0, 1) or 0
        E.Hp_Lerp = E.Hp_Lerp + (Pct - E.Hp_Lerp) * Math_Clamp(Dt * 8, 0, 1)
        local Hh = H * E.Hp_Lerp
        Set_Vis(E.Health_Bar_Bg, true)
        E.Health_Bar_Bg.From = Vector2_New(Px - 6, Py)
        E.Health_Bar_Bg.To = Vector2_New(Px - 6, Py + H)
        Set_Vis(E.Health_Bar, true)
        E.Health_Bar.From = Vector2_New(Px - 6, Py + H)
        E.Health_Bar.To = Vector2_New(Px - 6, Py + H - Hh)
        E.Health_Bar.Color = Esp_Hp_Red:Lerp(Esp_Hp_Green, E.Hp_Lerp)
    else
        Set_Vis(E.Health_Bar_Bg, false)
        Set_Vis(E.Health_Bar, false)
    end
    if Config.Esp_Tracers then
        Set_Vis(E.Tracer, true)
        E.Tracer.From = Ctx.Tracer_From
        E.Tracer.To = Vector2_New(Bot_Pos.X, Bot_Pos.Y)
        Esp_Set(E, E.Tracer, "Color", Config.Tracer_Color)
        Esp_Set(E, E.Tracer, "Thickness", Config.Tracer_Thickness)
    else
        Set_Vis(E.Tracer, false)
    end
    if Config.Esp_Skeleton then
        local Bones = Hum.RigType == Enum.HumanoidRigType.R15 and R15_Bones or R6_Bones
        local Sk = E.Skeleton
        local Bp = E.Bone_Parts
        local Col = Config.Skeleton_Color
        Table_Clear(Esp_Proj_Ok)
        for I = 1, #Bones do
            local Bone = Bones[I]
            local N1, N2 = Bone[1], Bone[2]
            local P1 = Esp_Bone_Part(Char, Bp, N1)
            local P2 = Esp_Bone_Part(Char, Bp, N2)
            local L = Sk[I]
            if P1 and P2 and Esp_Project(Camera, P1, N1) and Esp_Project(Camera, P2, N2) then
                L.From = Vector2_New(Esp_Proj_X[N1], Esp_Proj_Y[N1])
                L.To = Vector2_New(Esp_Proj_X[N2], Esp_Proj_Y[N2])
                Esp_Set(E, L, "Color", Col)
                Set_Vis(L, true)
            elseif L then
                Set_Vis(L, false)
            end
        end
        for I = #Bones + 1, 14 do
            if Sk[I] then Set_Vis(Sk[I], false) end
        end
    else
        local Sk = E.Skeleton
        for I = 1, 14 do Set_Vis(Sk[I], false) end
    end
end)

local Esp_Was_On = false

Update_Esp_All = LPH_NO_VIRTUALIZE(function(Dt)
    if not Config.Esp_Enabled then
        if Esp_Was_On then
            Esp_Was_On = false
            for _, E in pairs(Data.Esp_Objects) do Hide_Esp(E) end
        end
        return
    end
    Esp_Was_On = true

    local Camera = Workspace.CurrentCamera
    if not Camera then return end
    local Ctx = Esp_Ctx
    Ctx.Camera = Camera
    Ctx.Cam_Pos = Camera.CFrame.Position
    local Lc = Local_Player.Character
    local Lh = Lc and Lc:FindFirstChild("HumanoidRootPart")
    Ctx.Local_Pos = Lh and Lh.Position or Ctx.Cam_Pos
    if Config.Esp_Tracers then
        local Vp = Camera.ViewportSize
        local Ori = Config.Tracer_Origin
        if Ori == "Top" then
            Ctx.Tracer_From = Vector2_New(Vp.X / 2, 0)
        elseif Ori == "Center" then
            Ctx.Tracer_From = Vector2_New(Vp.X / 2, Vp.Y / 2)
        elseif Ori == "Mouse" then
            local M = User_Input_Service:GetMouseLocation()
            Ctx.Tracer_From = Vector2_New(M.X, M.Y)
        else
            Ctx.Tracer_From = Vector2_New(Vp.X / 2, Vp.Y)
        end
    end

    for P, E in pairs(Data.Esp_Objects) do
        if Is_Whitelisted(P) or (Config.Esp_Team_Check and Same_Team(P, Local_Player)) then
            Hide_Esp(E)
        else
            Update_Esp(P, E, Dt, Ctx)
        end
    end
end)
end

local function Update_Bloom()
    if Config.Bloom_Enabled then
        My_Bloom.Parent = Lighting
        My_Bloom.Intensity = Config.Bloom_Intensity
        My_Bloom.Size = Config.Bloom_Size
        My_Bloom.Threshold = Config.Bloom_Threshold
    else
        My_Bloom.Parent = nil
    end
end

local function Update_Blur()
    if Config.Blur_Enabled then
        My_Blur.Parent = Lighting
        My_Blur.Size = Config.Blur_Size
    else
        My_Blur.Parent = nil
    end
end

local function Update_CC()
    if Config.CC_Enabled then
        My_CC.Parent = Lighting
        My_CC.Brightness = Config.CC_Brightness
        My_CC.Contrast = Config.CC_Contrast
        My_CC.Saturation = Config.CC_Saturation
        My_CC.TintColor = Config.CC_TintColor
    else
        My_CC.Parent = nil
    end
end

local function Update_SR()
    if Config.SunRays_Enabled then
        My_SR.Parent = Lighting
        My_SR.Intensity = Config.SunRays_Intensity
        My_SR.Spread = Config.SunRays_Spread
    else
        My_SR.Parent = nil
    end
end

local Hidden_Atmos = {}
local Hidden_Skies = {}

local function Hide_Game_Instances(className, keep, store)
    for _, v in ipairs(Lighting:GetChildren()) do
        if v ~= keep and v:IsA(className) then
            store[#store + 1] = v
            v.Parent = nil
        end
    end
end

local function Restore_Game_Instances(store)
    for I = 1, #store do
        local v = store[I]
        if v then pcall(function() v.Parent = Lighting end) end
    end
    Table_Clear(store)
end

local function Update_Atmo()
    if Config.Atmo_Enabled then
        Hide_Game_Instances("Atmosphere", My_Atmo, Hidden_Atmos)
        My_Atmo.Density = Config.Atmo_Density
        My_Atmo.Offset = Config.Atmo_Offset
        My_Atmo.Glare = Config.Atmo_Glare
        My_Atmo.Haze = Config.Atmo_Haze
        My_Atmo.Color = Config.Atmo_Color
        My_Atmo.Decay = Config.Atmo_Decay
        My_Atmo.Parent = Lighting
    else
        My_Atmo.Parent = nil
        Restore_Game_Instances(Hidden_Atmos)
    end
end

local function Update_Skybox()
    if Config.Skybox_Enabled then
        Hide_Game_Instances("Sky", My_Sky, Hidden_Skies)
        My_Sky.Parent = Lighting
    else
        My_Sky.Parent = nil
        Restore_Game_Instances(Hidden_Skies)
    end
end

local function Update_CustomLighting()
    if Config.CustLight_Enabled then
        Lighting.Brightness = Config.CustLight_Brightness
        Lighting.ClockTime = Config.CustLight_Time
        Lighting.GlobalShadows = Config.CustLight_Shadows
        Lighting.Ambient = Config.CustLight_Ambient
    else
        Lighting.Brightness = Original_Lighting.Brightness
        Lighting.ClockTime = Original_Lighting.ClockTime
        Lighting.GlobalShadows = Original_Lighting.GlobalShadows
        Lighting.Ambient = Original_Lighting.Ambient
    end
end

local function Refresh_World_Visuals()
    if Config.Bloom_Enabled and My_Bloom.Parent ~= Lighting then My_Bloom.Parent = Lighting end
    if Config.Blur_Enabled and My_Blur.Parent ~= Lighting then My_Blur.Parent = Lighting end
    if Config.CC_Enabled and My_CC.Parent ~= Lighting then My_CC.Parent = Lighting end
    if Config.SunRays_Enabled and My_SR.Parent ~= Lighting then My_SR.Parent = Lighting end
    if Config.Atmo_Enabled and My_Atmo.Parent ~= Lighting then Update_Atmo() end
    if Config.Skybox_Enabled and My_Sky.Parent ~= Lighting then Update_Skybox() end
end

local function Hide_Crosshair()
    for I = 1, 4 do
        Set_Vis(Crosshair_Lines[I], false)
        Set_Vis(Crosshair_Outlines[I], false)
    end
    Set_Vis(Crosshair_Dot, false)
    Set_Vis(Crosshair_Dot_Outline, false)
end

local Update_Crosshair = LPH_NO_VIRTUALIZE(function(Center, Dt)
    if not Config.Crosshair_Enabled then Hide_Crosshair() return end
    local Col = Config.Crosshair_Color
    if Config.Crosshair_Rainbow then
        Crosshair_Hue = (Crosshair_Hue + (Dt * Config.Crosshair_Rainbow_Speed * 0.1)) % 1
        Col = Color3_From_Hsv(Crosshair_Hue, 1, 1)
    end
    local Cx, Cy = Center.X, Center.Y
    local G = Config.Crosshair_Gap
    local S = Config.Crosshair_Size
    local T = Config.Crosshair_Thickness
    local Out = Config.Crosshair_Outline
    local Off = {
        {-G - S, 0, -G, 0},
        {G, 0, G + S, 0},
        {0, -G - S, 0, -G},
        {0, G, 0, G + S}
    }
    local Cos, Sin = 1, 0
    if Config.Crosshair_Rotate then
        Crosshair_Rot = (Crosshair_Rot + (Dt * Config.Crosshair_Rotate_Speed)) % (math.pi * 2)
        Cos = math.cos(Crosshair_Rot)
        Sin = math.sin(Crosshair_Rot)
    end
    local Pts = {}
    for I = 1, 4 do
        local O = Off[I]
        Pts[I] = {
            Vector2_New(Cx + (O[1] * Cos - O[2] * Sin), Cy + (O[1] * Sin + O[2] * Cos)),
            Vector2_New(Cx + (O[3] * Cos - O[4] * Sin), Cy + (O[3] * Sin + O[4] * Cos))
        }
    end
    for I = 1, 4 do
        if (I == 3 and Config.Crosshair_T_Shape) or S <= 0 then
            Set_Vis(Crosshair_Lines[I], false)
            Set_Vis(Crosshair_Outlines[I], false)
        else
            local L = Crosshair_Lines[I]
            L.From = Pts[I][1] L.To = Pts[I][2] L.Thickness = T L.Color = Col
            Set_Vis(L, true)
            local O = Crosshair_Outlines[I]
            if Out then
                O.From = Pts[I][1] O.To = Pts[I][2] O.Thickness = T + 2
                Set_Vis(O, true)
            else
                Set_Vis(O, false)
            end
        end
    end
    if Config.Crosshair_Dot then
        Crosshair_Dot.Position = Center
        Crosshair_Dot.Radius = T
        Crosshair_Dot.Color = Col
        Set_Vis(Crosshair_Dot, true)
        if Out then
            Crosshair_Dot_Outline.Position = Center
            Crosshair_Dot_Outline.Radius = T + 1
            Set_Vis(Crosshair_Dot_Outline, true)
        else
            Set_Vis(Crosshair_Dot_Outline, false)
        end
    else
        Set_Vis(Crosshair_Dot, false)
        Set_Vis(Crosshair_Dot_Outline, false)
    end
end)

local function Trigger_Active()
    return Config.Trigger_Enabled
end

local function Trigger_Fire()
    if mouse1click then
        mouse1click()
    elseif mouse1press and mouse1release then
        mouse1press()
        task.delay(0.03, function() if mouse1release then mouse1release() end end)
    else
        local M = Local_Player:GetMouse()
        Virtual_Input_Manager:SendMouseButtonEvent(M.X, M.Y, 0, true, game, 0)
        Virtual_Input_Manager:SendMouseButtonEvent(M.X, M.Y, 0, false, game, 0)
    end
end

local HB_Triggerbot = LPH_NO_VIRTUALIZE(function(Char, Camera)
    if not Char or not Trigger_Active() then Trigger_Hover_Since = 0 return end
    local Cam = Camera or Workspace.CurrentCamera
    local Origin = Cam.CFrame.Position
    Trigger_Params.FilterDescendantsInstances = {Cam, Char}
    local Res = Workspace:Raycast(Origin, Cam.CFrame.LookVector * 3000, Trigger_Params)
    local On_Enemy = false
    if Res and Res.Instance then
        local Plr = Player_From_Instance(Res.Instance)
        if Plr and Plr ~= Local_Player and Is_Alive(Plr) and not Is_Whitelisted(Plr) then
            if not (Config.Trigger_Team_Check and Same_Team(Plr, Local_Player)) then
                On_Enemy = true
            end
        end
    end
    if On_Enemy then
        local Now = Tick()
        if Trigger_Hover_Since == 0 then Trigger_Hover_Since = Now end
        if Now - Trigger_Hover_Since >= Config.Trigger_Delay and Now - Last_Trigger_Fire >= Config.Trigger_Cooldown then
            Trigger_Fire()
            Last_Trigger_Fire = Now
        end
    else
        Trigger_Hover_Since = 0
    end
end)

local Duel_Ctrl = nil
local Get_Duel_Ctrl = LPH_NO_VIRTUALIZE(function()
    if Duel_Ctrl then return Duel_Ctrl end
    if not Has_Getgc then return nil end
    local Grm = getrawmetatable or getmetatable
    for _, V in ipairs(getgc(true)) do
        if type(V) == "table" then
            local Ok, Mt = pcall(Grm, V)
            if Ok and type(Mt) == "table" then
                local Gd = rawget(Mt, "GetDuel")
                local Gi = rawget(Mt, "GetDuelByID")
                if type(Gd) == "function" and type(Gi) == "function" then
                    Duel_Ctrl = V
                    return V
                end
            end
        end
    end
    return nil
end)

local In_Duel = LPH_NO_VIRTUALIZE(function()
    local C = Get_Duel_Ctrl()
    if not C then return false end
    local Ok, D = pcall(function() return C:GetDuel(Local_Player) end)
    return Ok and D ~= nil
end)

local Get_Nearest_Player = LPH_NO_VIRTUALIZE(function(Range, Tc)
    local Lc = Local_Player.Character
    local Lh = Lc and Lc:FindFirstChild("HumanoidRootPart")
    if not Lh then return nil end
    local Lpos = Lh.Position
    local Best, Short = nil, Range
    local Plrs = Players:GetPlayers()
    for I = 1, #Plrs do
        local P = Plrs[I]
        if P == Local_Player or not Is_Alive(P) or (Tc and Same_Team(P, Local_Player)) then continue end
        if Is_Whitelisted(P) then continue end
        local Th = Get_Part_From_Player(P, "Body")
        if Th then
            local D = (Th.Position - Lpos).Magnitude
            if D < Short then Short = D Best = P end
        end
    end
    return Best
end)

local Fighter_Ctrl = nil
local Get_Fighter_Ctrl = LPH_NO_VIRTUALIZE(function()
    if Fighter_Ctrl then return Fighter_Ctrl end
    if not Has_Getgc then return nil end
    local Grm = getrawmetatable or getmetatable
    for _, V in ipairs(getgc(true)) do
        if type(V) == "table" then
            local Ok, Mt = pcall(Grm, V)
            if Ok and type(Mt) == "table"
                and type(rawget(Mt, "SimulateInputBegan")) == "function"
                and type(rawget(Mt, "Slide")) == "function" then
                Fighter_Ctrl = V
                return V
            end
        end
    end
    return nil
end)

local Equip_Slot = LPH_NO_VIRTUALIZE(function(Slot)
    local C = Get_Fighter_Ctrl()
    local LF = C and C.LocalFighter
    if LF then
        pcall(function() LF:EquipItem(Slot) end)
        return true
    end
    return false
end)

local Send_RMB = LPH_NO_VIRTUALIZE(function()
    if mouse2press and mouse2release then
        mouse2press()
        task.wait(0.06)
        mouse2release()
    elseif mouse2click then
        mouse2click()
    else
        local M = Local_Player:GetMouse()
        Virtual_Input_Manager:SendMouseButtonEvent(M.X, M.Y, 1, true, game, 0)
        task.wait(0.06)
        Virtual_Input_Manager:SendMouseButtonEvent(M.X, M.Y, 1, false, game, 0)
    end
end)

local Backstab_Attack = LPH_NO_VIRTUALIZE(function(Target)
    Send_RMB()
end)

local function Backstab_Active()
    if not Config.Backstab_Enabled then return false end
    if Config.Backstab_Always then return true end
    local Kb = Library.Flags and Library.Flags.BackstabKey
    if Kb and Kb.Key and Kb.Key ~= Enum.KeyCode.Unknown then
        return Data.Backstab_Held
    end
    return false
end

local Target_Still_Valid = LPH_NO_VIRTUALIZE(function(Char, Target)
    if not Target or not Target.Parent then return false end
    if not Is_Alive(Target) then return false end
    if Config.Backstab_Team_Check and Same_Team(Target, Local_Player) then return false end
    local Hrp = Char:FindFirstChild("HumanoidRootPart")
    local Th = Get_Part_From_Player(Target, "Body")
    if not Hrp or not Th then return false end
    return (Th.Position - Hrp.Position).Magnitude <= Config.Backstab_Range + 10
end)

local Backstab_Reset = function(Char)
    Backstab_Target = nil
    Backstab_Equipped_For = nil
    if Char then
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if Hum and Hum.AutoRotate == false then Hum.AutoRotate = true end
    end
end

local HB_Backstab = LPH_NO_VIRTUALIZE(function(Char)
    if not Char or not Backstab_Active() then Backstab_Reset(Char) return end
    if Config.Backstab_Only_Duel and not In_Duel() then Backstab_Reset(Char) return end
    local Hrp = Char:FindFirstChild("HumanoidRootPart")
    if not Hrp then return end

    local Target = Backstab_Target
    if not Target_Still_Valid(Char, Target) then
        Target = Get_Nearest_Player(Config.Backstab_Range, Config.Backstab_Team_Check)
        Backstab_Target = Target
    end
    if not Target then Backstab_Reset(Char) return end

    local Tc = Target.Character
    local Th = (Tc and Tc:FindFirstChild("HumanoidRootPart")) or Get_Part_From_Player(Target, "Body")
    if not Th then Backstab_Target = nil return end

    local Stand_CF = Cframe_New((Th.CFrame * Cframe_New(0, 0, Config.Backstab_Offset)).Position)
        * (Th.CFrame - Th.CFrame.Position) * Cframe_Angles(0, math.pi, 0)

    if Config.Backstab_Return then
        local Now = Tick()
        if not Backstab_Busy and Now - Last_Backstab_Fire >= Config.Backstab_Cooldown then
            Last_Backstab_Fire = Now
            Backstab_Busy = true
            local Tgt = Target
            task.spawn(function()
                local Origin = Hrp.CFrame
                Equip_Slot(3)
                Hrp.CFrame = Stand_CF
                if Config.Backstab_Delay > 0 then task.wait(Config.Backstab_Delay) end
                Backstab_Attack(Tgt)
                task.wait(0.03)
                if Hrp and Hrp.Parent then Hrp.CFrame = Origin end
                Backstab_Equipped_For = nil
                Backstab_Busy = false
            end)
        end
        return
    end

    if Backstab_Equipped_For ~= Target then
        Equip_Slot(3)
        Backstab_Equipped_For = Target
    end

    local Hum = Char:FindFirstChildOfClass("Humanoid")
    if Hum and Hum.AutoRotate then Hum.AutoRotate = false end

    Hrp.CFrame = Stand_CF

    local Now = Tick()
    if not Backstab_Busy and Now - Last_Backstab_Fire >= Config.Backstab_Cooldown then
        Last_Backstab_Fire = Now
        Backstab_Busy = true
        local Tgt = Target
        task.spawn(function()
            if Config.Backstab_Delay > 0 then task.wait(Config.Backstab_Delay) end
            Backstab_Attack(Tgt)
            Backstab_Busy = false
        end)
    end
end)

local LV_Update
do
local LV_BG = Color3.fromHex("#080505")
local LV_Container = Color3.fromHex("#140b0b")
local LV_Section = Color3.fromHex("#1a0e0e")
local LV_Accent = Color3.fromHex("#ff1a1a")
local LV_Text = Color3.fromHex("#ffffff")
local LV_TextDark = Color3.fromHex("#997373")
local LV_StrokeCol = Color3.fromHex("#2e1717")

local LV_Gui, LV_Title, LV_Preview, LV_Cam, LV_PreviewLabel
local LV_SlotLabels = {}
local LV_Last_Target = nil
local LV_Mem = { nil, nil, nil, nil }
local LV_Seen = { 0, 0, 0, 0 }
local LV_Last_Update = 0
local LV_Preview_Name = nil

local function LV_Get_VM_Folder()
    local A = RS:FindFirstChild("Assets")
    local T = A and A:FindFirstChild("Temp")
    local Vm = T and T:FindFirstChild("ViewModels")
    if Vm then return Vm end
    return Workspace:FindFirstChild("ViewModels")
end

local function LV_New(Class, Props, Parent)
    local I = Instance.new(Class)
    for K, V in pairs(Props) do I[K] = V end
    if Parent then I.Parent = Parent end
    return I
end

local LV_Build = LPH_NO_VIRTUALIZE(function()
    if LV_Gui and LV_Gui.Parent then return end
    local Parent = (gethui and gethui()) or Local_Player:FindFirstChild("PlayerGui") or Local_Player:WaitForChild("PlayerGui")
    LV_Gui = LV_New("ScreenGui", { Name = "PH_LoadoutViewer", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true }, Parent)
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(LV_Gui) end end)

    local Main = LV_New("Frame", {
        Size = UDim2.new(0, 320, 0, 150),
        Position = UDim2.new(0.5, -160, 0, 24),
        BackgroundColor3 = LV_BG,
        BorderSizePixel = 0,
    }, LV_Gui)
    LV_New("UICorner", { CornerRadius = UDim.new(0, 8) }, Main)
    local Stroke = LV_New("UIStroke", { Color = LV_StrokeCol, Thickness = 1 }, Main)
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local Accent = LV_New("Frame", { Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = LV_Accent, BorderSizePixel = 0 }, Main)
    LV_New("UICorner", { CornerRadius = UDim.new(0, 2) }, Accent)

    LV_Title = LV_New("TextLabel", {
        Size = UDim2.new(1, -16, 0, 26),
        Position = UDim2.new(0, 8, 0, 6),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = LV_Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "Waiting for target...",
    }, Main)

    local Line = LV_New("Frame", { Size = UDim2.new(1, -16, 0, 1), Position = UDim2.new(0, 8, 0, 32), BackgroundColor3 = LV_StrokeCol, BorderSizePixel = 0 }, Main)

    for I = 1, 4 do
        LV_SlotLabels[I] = LV_New("TextLabel", {
            Size = UDim2.new(0, 180, 0, 22),
            Position = UDim2.new(0, 10, 0, 12 + I * 26),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = LV_TextDark,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "[ " .. I .. " ]  -",
        }, Main)
    end

    local PrevHolder = LV_New("Frame", {
        Size = UDim2.new(0, 110, 0, 100),
        Position = UDim2.new(1, -118, 0, 42),
        BackgroundColor3 = LV_Container,
        BorderSizePixel = 0,
    }, Main)
    LV_New("UICorner", { CornerRadius = UDim.new(0, 6) }, PrevHolder)
    LV_New("UIStroke", { Color = LV_StrokeCol, Thickness = 1 }, PrevHolder)

    LV_Preview = LV_New("ViewportFrame", {
        Size = UDim2.new(1, -6, 1, -18),
        Position = UDim2.new(0, 3, 0, 3),
        BackgroundColor3 = LV_Section,
        BorderSizePixel = 0,
    }, PrevHolder)
    LV_New("UICorner", { CornerRadius = UDim.new(0, 6) }, LV_Preview)
    LV_Cam = LV_New("Camera", {}, LV_Preview)
    LV_Preview.CurrentCamera = LV_Cam
    LV_Preview.LightDirection = Vector3.new(-0.4, -1, -0.2)
    LV_Preview.Ambient = Color3.fromRGB(160, 160, 160)

    LV_PreviewLabel = LV_New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -15),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = LV_Text,
        Text = "",
    }, PrevHolder)
end)

local LV_Destroy = LPH_NO_VIRTUALIZE(function()
    if LV_Gui then LV_Gui:Destroy() LV_Gui = nil end
    LV_SlotLabels = {}
    LV_Last_Target = nil
    LV_Mem = { nil, nil, nil, nil }
    LV_Seen = { 0, 0, 0, 0 }
    LV_Preview_Name = nil
end)

local LV_Set_Preview = LPH_NO_VIRTUALIZE(function(Model, Label)
    if not LV_Preview then return end
    for _, C in ipairs(LV_Preview:GetChildren()) do
        if C ~= LV_Cam then C:Destroy() end
    end
    if not Model then
        if LV_PreviewLabel then LV_PreviewLabel.Text = "" end
        return
    end
    local Clone = Model:Clone()
    local Minv, Maxv
    for _, D in ipairs(Clone:GetDescendants()) do
        if D:IsA("BasePart") then
            D.Anchored = true
            D.CanCollide = false
            if D.Transparency < 1 then
                local Half = D.Size * 0.5
                local Pp = D.Position
                local Lo = Pp - Half
                local Hi = Pp + Half
                if not Minv then Minv = Lo Maxv = Hi
                else
                    Minv = Vector3.new(math.min(Minv.X, Lo.X), math.min(Minv.Y, Lo.Y), math.min(Minv.Z, Lo.Z))
                    Maxv = Vector3.new(math.max(Maxv.X, Hi.X), math.max(Maxv.Y, Hi.Y), math.max(Maxv.Z, Hi.Z))
                end
            end
        elseif D:IsA("Script") or D:IsA("LocalScript") then
            D:Destroy()
        end
    end
    Clone.Parent = LV_Preview
    if not Minv then
        local Ok, Cf, Sz = pcall(function() return Clone:GetBoundingBox() end)
        if Ok and Cf then Minv = Cf.Position - Sz * 0.5 Maxv = Cf.Position + Sz * 0.5 end
    end
    if Minv then
        local Center = (Minv + Maxv) * 0.5
        local Radius = ((Maxv - Minv).Magnitude) * 0.5
        if Radius <= 0 then Radius = 2 end
        local Fov = math.rad(LV_Cam.FieldOfView)
        local Dist = (Radius / math.tan(Fov * 0.5)) * 1.1
        local Dir = Vector3.new(1, 0.35, 1).Unit
        LV_Cam.CFrame = CFrame.lookAt(Center + Dir * Dist, Center)
    end
    if LV_PreviewLabel then LV_PreviewLabel.Text = Label or "" end
end)

local LV_Get_Nearest = LPH_NO_VIRTUALIZE(function()
    local Lc = Local_Player.Character
    local Lh = Lc and Lc:FindFirstChild("HumanoidRootPart")
    if not Lh then return nil, 0 end
    local Best, Short = nil, Math_Huge
    for _, P in ipairs(Players:GetPlayers()) do
        if P ~= Local_Player and Is_Alive(P) then
            local Th = Get_Part_From_Player(P, "Body")
            if Th then
                local D = (Th.Position - Lh.Position).Magnitude
                if D < Short then Short = D Best = P end
            end
        end
    end
    return Best, (Best and Short) or 0
end)

LV_Update = LPH_NO_VIRTUALIZE(function()
    if not Config.Loadout_Viewer then
        if LV_Gui then LV_Destroy() end
        return
    end
    LV_Build()
    local Now = Tick()
    if Now - LV_Last_Update < 0.1 then return end
    LV_Last_Update = Now

    local Target, Dist = LV_Get_Nearest()
    if not Target then
        LV_Title.Text = "Waiting for target..."
        for I = 1, 4 do
            LV_SlotLabels[I].Text = "[ " .. I .. " ]  -"
            LV_SlotLabels[I].TextColor3 = LV_TextDark
        end
        LV_Last_Target = nil
        LV_Mem = { nil, nil, nil, nil }
        LV_Seen = { 0, 0, 0, 0 }
        LV_Set_Preview(nil)
        LV_Preview_Name = nil
        return
    end

    if LV_Last_Target ~= Target then
        LV_Last_Target = Target
        LV_Mem = { nil, nil, nil, nil }
        LV_Seen = { 0, 0, 0, 0 }
        LV_Preview_Name = nil
        LV_Set_Preview(nil)
    end

    LV_Title.Text = "[ " .. Target.Name .. " ]  |  " .. Math_Floor(Dist) .. "m"

    local Vmf = LV_Get_VM_Folder()
    local Prefix = Target.Name .. " - "
    local Plen = string.len(Prefix)
    local Current = {}
    local Held_Model, Held_Name = nil, nil
    if Vmf then
        for _, Obj in ipairs(Vmf:GetChildren()) do
            if string.sub(Obj.Name, 1, Plen) == Prefix then
                local Raw = string.sub(Obj.Name, Plen + 1)
                local Clean = string.split(Raw, " - ")[1]
                if Clean and Clean ~= "" then
                    Current[Clean] = true
                    Held_Model = Obj
                    Held_Name = Clean
                end
            end
        end
    end

    for Item in pairs(Current) do
        local Found = false
        for I = 1, 4 do
            if LV_Mem[I] == Item then LV_Seen[I] = Now Found = true break end
        end
        if not Found then
            local Placed = false
            for I = 1, 4 do
                if LV_Mem[I] == nil then LV_Mem[I] = Item LV_Seen[I] = Now Placed = true break end
            end
            if not Placed then
                local Oldest, Oi = Math_Huge, 1
                for I = 1, 4 do if LV_Seen[I] < Oldest then Oldest = LV_Seen[I] Oi = I end end
                LV_Mem[Oi] = Item LV_Seen[Oi] = Now
            end
        end
    end

    for I = 1, 4 do
        if LV_Mem[I] then
            LV_SlotLabels[I].Text = "[ " .. I .. " ]  " .. LV_Mem[I]
            LV_SlotLabels[I].TextColor3 = LV_Text
        else
            LV_SlotLabels[I].Text = "[ " .. I .. " ]  -"
            LV_SlotLabels[I].TextColor3 = LV_TextDark
        end
    end

    if Held_Model and Held_Name ~= LV_Preview_Name then
        LV_Preview_Name = Held_Name
        LV_Set_Preview(Held_Model, Held_Name)
    end
end)
end

local Combat_Tab = Window:Tab("Combat", "119113699176402")
local Movement_Tab = Window:Tab("Movement", "128427292087850")
local Visuals_Tab = Window:Tab("Visuals", "131421588030422")
local World_Tab = Window:Tab("World", "92734878284244")
local Skins_Tab = Window:Tab("Skins", "97447555315469")
local Rage_Tab
if not Is_Restricted then
    Rage_Tab = Window:Tab("Rage", "121243182446697")
end

Safe(function()
local Aimbot_Section = Combat_Tab:Section("Aimbot", "Left")
Aimbot_Section:Toggle("Enable Aimbot", "AimEnabled", false, "", function(V) Config.Aimbot_Enabled = V if not V then Data.Current_Aim_Target = nil end end, true)
Aimbot_Section:Toggle("Hold RMB To Aim", "AimHoldRmb", false, "Aim only while right mouse button is held", function(V) Config.Aim_Hold_Rmb = V end)
Aimbot_Section:Dropdown("Aim Type", "AimType", {"Mouse", "Camera"}, "Mouse", "", function(V) Config.Aim_Type = V end, nil, false)
Aimbot_Section:Dropdown("Aim Logic", "AimLogic", {"Closest Player", "Closest Camera", "Closest To FOV"}, "Closest To FOV", "", function(V) Config.Aim_Logic = V end, nil, false)
Aimbot_Section:Dropdown("Aim Part", "AimPart", Assets.AimPartOptions, "Head", "", function(V) Config.Aim_Part = V end, nil, false)
Aimbot_Section:Toggle("Team Check", "AimTeamChk", true, "", function(V) Config.Aim_Team_Check = V end)
Aimbot_Section:Toggle("Prediction", "AimPred", false, "", function(V) Config.Aim_Prediction = V end)
Aimbot_Section:Slider("Smoothness", "AimSmooth", 1, 10, 1, 1, "", function(V) Config.Aim_Smoothness = tonumber(V) or 1 end)
Aimbot_Section:Toggle("Shake", "AimShake", false, "", function(V) Config.Aim_Shake = V end)
Aimbot_Section:Slider("Shake Speed", "AimShakeSpd", 1, 50, 10, 1, "", function(V) Config.Aim_Shake_Speed = tonumber(V) or 10 end)
Aimbot_Section:Slider("Shake X", "AimShakeX", 1, 20, 5, 1, "", function(V) Config.Aim_Shake_X = tonumber(V) or 5 end)
Aimbot_Section:Slider("Shake Y", "AimShakeY", 1, 20, 5, 1, "", function(V) Config.Aim_Shake_Y = tonumber(V) or 5 end)

local Fov_Section = Combat_Tab:Section("FOV", "Left")
Fov_Section:Toggle("Show FOV", "ShowFOV", false, "", function(V) Config.Show_Fov = V end)
Fov_Section:Slider("FOV Size", "FOVSize", 10, 800, 100, 1, "", function(V) Config.Fov_Size = tonumber(V) or 100 Fov_Circle.Radius = Config.Fov_Size end)
Fov_Section:Toggle("Rainbow Mode", "FOVRainbow", false, "", function(V) Config.Fov_Rainbow = V end)
Fov_Section:Slider("Rainbow Speed", "FOVRainSpd", 1, 10, 1, 1, "", function(V) Config.Fov_Rainbow_Speed = tonumber(V) or 1 end)
Fov_Section:ColorPicker("FOV Color", "FOVColor", Color3_From_Rgb(255, 255, 255), "", function(C) Config.Fov_Color = C end)

local Trigger_Section = Combat_Tab:Section("Triggerbot", "Left")
Trigger_Section:Toggle("Enable Triggerbot", "TriggerEnabled", false, "", function(V) Config.Trigger_Enabled = V if not V then Trigger_Hover_Since = 0 end end, true)
Trigger_Section:Toggle("Team Check", "TriggerTeamChk", true, "", function(V) Config.Trigger_Team_Check = V end)
Trigger_Section:Slider("Reaction Delay (ms)", "TriggerDelay", 0, 500, 30, 1, "", function(V) Config.Trigger_Delay = (tonumber(V) or 30) / 1000 end)
Trigger_Section:Slider("Cooldown (ms)", "TriggerCD", 0, 500, 100, 1, "", function(V) Config.Trigger_Cooldown = (tonumber(V) or 100) / 1000 end)

if Has_Hook then
    local Sa_Section = Combat_Tab:Section("Silent Aim", "Right")
    Sa_Section:Toggle("Enable Silent Aim", "SAEnabled", false, "", function(V) Config.Sa_Enabled = V end, true)
    Sa_Section:Dropdown("Silent Aim Part", "SAPart", Assets.AimPartOptions, "Head", "", function(V) Config.Sa_Part = V end, nil, false)
    Sa_Section:Toggle("Random Hitbox", "SARandomHb", false, "Randomly selects hitbox per target", function(V) Config.Sa_Random_Hitbox = V end)
    Sa_Section:Toggle("Team Check", "SATeamChk", true, "", function(V) Config.Sa_Team_Check = V end)
    Sa_Section:Toggle("Visible Check", "SAVisChk", false, "", function(V) Config.Sa_Visible_Check = V end)
    Sa_Section:Toggle("Projectile TP", "ProjTP", false, "", function(V) Config.Projectile_TP = V end)
    Sa_Section:Slider("Hit Chance (%)", "SAChance", 1, 100, 100, 1, "", function(V) Config.Sa_Hit_Chance = tonumber(V) or 100 end)
end

if Has_Getgc then
    local Gun_Section = Combat_Tab:Section("Weapon Mods", "Right")
    Gun_Section:Toggle("No Recoil", "NoRecoil", false, "", function(V) Config.No_Recoil = V end)
    Gun_Section:Toggle("No Spread", "NoSpread", false, "", function(V) Config.No_Spread = V end)
    Gun_Section:Toggle("No Bullet Waste", "NoWaste", false, "", function(V) Config.No_Bullet_Waste = V end)
    Gun_Section:Toggle("Rapid Fire", "RapidFire", false, "", function(V) Config.Rapid_Fire = V end)
    Gun_Section:Slider("Fire Rate", "FireRateSpd", 0, 1, 0.01, 0.01, "", function(V) Config.Rapid_Fire_Speed = tonumber(V) or 0.01 end)
    Gun_Section:Toggle("Instant Grenade Explode", "InstaGrenade", false, "", function(V) Config.Instant_Grenade = V end)
    Gun_Section:Toggle("No Melee Cooldown", "NoMeleeCD", false, "", function(V) Config.No_Melee_Cooldown = V end)
    Gun_Section:Toggle("Instant Scope", "InstaScope", false, "", function(V) Config.Instant_Scope = V end)
    Gun_Section:Toggle("No Flashbang", "NoFlash", false, "", function(V) Config.No_Flashbang = V end)
    if not Is_Weak then
        Gun_Section:Toggle("Anti Katana", "AntiKatana", false, "Do not shoot enemies while their katana is deflecting", function(V) Config.Anti_Katana = V end)
    end
end

Safe(function()
    if Is_Weak then return end
    if not Local_Player:FindFirstChild("PlayerScripts") then
        Local_Player.PlayerScriptsAdded:Wait()
    end
    task.spawn(function()
        local Katana, Attempts = nil, 0
        while Attempts < 20 do
            pcall(function()
                local Items = Local_Player.PlayerScripts:FindFirstChild("Modules")
                Items = Items and Items:FindFirstChild("Items")
                local M = Items and Items:FindFirstChild("Katana", true)
                if M then Katana = Game_Require(M) end
            end)
            if not Katana then
                for _, M in pairs(Local_Player.PlayerScripts:GetDescendants()) do
                    if M.Name == "Katana" and M:IsA("ModuleScript") then
                        Katana = Game_Require(M)
                        if Katana then break end
                    end
                end
            end
            if Katana and type(Katana) == "table" and Katana.StartAiming then break end
            Attempts += 1
            task.wait(1)
        end
        if Katana and type(Katana) == "table" and Katana.StartAiming then
            local Old = Katana.StartAiming
            Katana.StartAiming = function(Self, Force)
                local Fighter = Self.ClientFighter
                local Plr = Fighter and Fighter.Player
                if Plr then
                    Data.Katana_Users[Plr] = true
                    local Dur = Self.Info.DeflectDuration or 0.6
                    task.delay(Dur, function() Data.Katana_Users[Plr] = nil end)
                end
                return Old(Self, Force)
            end
        end
    end)
end)


local Backstab_Section = Combat_Tab:Section("Backstab", "Right")
Backstab_Section:Toggle("Enable Backstab", "BackstabEnabled", false, "Teleports behind the nearest enemy, equips slot 3 and right-clicks", function(V) Config.Backstab_Enabled = V end, true)
Backstab_Section:Toggle("Always (no key)", "BackstabAlways", false, "Run non-stop while enabled; ignores the key", function(V) Config.Backstab_Always = V end)
Backstab_Section:Keybind("Backstab Key", "BackstabKey", Enum.KeyCode.Unknown, "Hold", "Hold to backstab (used when Always is off)", function(S) Data.Backstab_Held = S end)
Backstab_Section:Toggle("Team Check", "BackstabTeamChk", true, "", function(V) Config.Backstab_Team_Check = V end)
Backstab_Section:Toggle("Only In Duel", "BackstabOnlyDuel", true, "Only backstab while you are in a match/duel", function(V) Config.Backstab_Only_Duel = V end)
Backstab_Section:Toggle("Return After", "BackstabReturn", false, "Blink behind them, hit, then teleport back to your spot (off = stay behind them)", function(V) Config.Backstab_Return = V end)
Backstab_Section:Slider("Range", "BackstabRange", 10, 500, 100, 1, "", function(V) Config.Backstab_Range = tonumber(V) or 100 end)
Backstab_Section:Slider("Reaction Delay (ms)", "BackstabDelay", 0, 500, 50, 1, "", function(V) Config.Backstab_Delay = (tonumber(V) or 50) / 1000 end)
Backstab_Section:Slider("Cooldown (ms)", "BackstabCD", 0, 2000, 500, 1, "", function(V) Config.Backstab_Cooldown = (tonumber(V) or 500) / 1000 end)

local Fly_Section = Movement_Tab:Section("Fly", "Left")
Fly_Section:Toggle("Fly", "FlyEnabled", false, "", function(V) Config.Fly_Enabled = V end, true)
Fly_Section:Slider("Fly Speed", "FlySpeed", 10, 200, 50, 1, "", function(V) Config.Fly_Speed = tonumber(V) or 50 end)

local Player_Stats_Section = Movement_Tab:Section("Player Stats", "Left")
Player_Stats_Section:Toggle("Infinite Jump", "InfJump", false, "", function(V) Config.Inf_Jump = V end, true)
Player_Stats_Section:Toggle("Enable WalkSpeed", "WSEnabled", false, "", function(V) Config.Ws_Enabled = V end)
Player_Stats_Section:Slider("WalkSpeed", "WalkSpeed", 16, 200, 16, 1, "", function(V) Config.Walk_Speed = tonumber(V) or 16 end)
Player_Stats_Section:Toggle("Enable JumpPower", "JPEnabled", false, "", function(V) Config.Jp_Enabled = V end)
Player_Stats_Section:Slider("JumpPower", "JumpPower", 50, 300, 50, 1, "", function(V) Config.Jump_Power = tonumber(V) or 50 end)

local Mobility_Section = Movement_Tab:Section("Mobility", "Right")
Mobility_Section:Toggle("Noclip", "Noclip", false, "", function(V) Config.Noclip = V end, true)
Mobility_Section:Toggle("Bhop", "Bhop", false, "", function(V) Config.Bhop = V end, true)
Mobility_Section:Toggle("Auto Strafes", "Strafes", false, "", function(V) Config.Strafes = V end)
Mobility_Section:Slider("Strafe Speed", "StrafeSpeed", 16, 100, 35, 1, "", function(V) Config.Strafe_Speed = tonumber(V) or 35 end)

local Esp_Type_Section = Visuals_Tab:Section("ESP Elements", "Left")
Esp_Type_Section:Toggle("Enable ESP", "ESPEnabled", false, "", function(V)
    Config.Esp_Enabled = V
    if not V then for _, E in pairs(Data.Esp_Objects) do Hide_Esp(E) end end
end, true)
Esp_Type_Section:Toggle("Box ESP", "BoxESP", false, "", function(V) Config.Esp_Box = V end)
Esp_Type_Section:Dropdown("Box Type", "BoxType", {"Standard", "Corner", "3D"}, "Standard", "", function(V) Config.Esp_Box_Type = V end, nil, false)
Esp_Type_Section:Toggle("Skeleton ESP", "SkelESP", false, "", function(V) Config.Esp_Skeleton = V end)
Esp_Type_Section:Toggle("Head Circle", "HeadCircESP", false, "", function(V) Config.Esp_Head_Circle = V end)

local Chams_Section = Visuals_Tab:Section("Self Chams", "Left")
Chams_Section:Toggle("Enable Self Chams", "ChamsEnabled", false, "", function(V)
    Config.Chams_Enabled = V
    if not V then Remove_Chams() end
end, true)
Chams_Section:Dropdown("Material", "ChamsMaterial", {"ForceField", "Neon", "Glass", "SmoothPlastic", "Ice", "Foil", "DiamondPlate"}, "ForceField", "", function(V) Config.Chams_Material = V end, nil, false)
Chams_Section:ColorPicker("Chams Color", "ChamsColor", Color3_From_Rgb(255, 0, 0), "", function(C) Config.Chams_Color = C end)
Chams_Section:Slider("Transparency", "ChamsTransparency", 0, 100, 0, 1, "", function(V) Config.Chams_Transparency = (tonumber(V) or 0) / 100 end)
Chams_Section:Toggle("Arms Only", "ChamsArmsOnly", false, "", function(V) Config.Chams_Arms_Only = V Chams_Dirty = true end)
Chams_Section:Toggle("Weapon Only", "ChamsWeaponOnly", false, "", function(V) Config.Chams_Weapon_Only = V Chams_Dirty = true end)
Chams_Section:Toggle("Rainbow", "ChamsRainbow", false, "", function(V) Config.Chams_Rainbow = V end)
Chams_Section:Slider("Rainbow Speed", "ChamsRainbowSpd", 1, 10, 1, 1, "", function(V) Config.Chams_Rainbow_Speed = tonumber(V) or 1 end)

local Crosshair_Section = Visuals_Tab:Section("Crosshair", "Left")
Crosshair_Section:Toggle("Enable Crosshair", "CrosshairEnabled", false, "", function(V) Config.Crosshair_Enabled = V end, true)
Crosshair_Section:Toggle("T Shape", "CrosshairT", false, "", function(V) Config.Crosshair_T_Shape = V end)
Crosshair_Section:Toggle("Center Dot", "CrosshairDot", false, "", function(V) Config.Crosshair_Dot = V end)
Crosshair_Section:Toggle("Outline", "CrosshairOutline", true, "", function(V) Config.Crosshair_Outline = V end)
Crosshair_Section:Slider("Size", "CrosshairSize", 0, 30, 8, 1, "", function(V) Config.Crosshair_Size = tonumber(V) or 8 end)
Crosshair_Section:Slider("Gap", "CrosshairGap", 0, 30, 4, 1, "", function(V) Config.Crosshair_Gap = tonumber(V) or 4 end)
Crosshair_Section:Slider("Thickness", "CrosshairThick", 1, 10, 2, 1, "", function(V) Config.Crosshair_Thickness = tonumber(V) or 2 end)
Crosshair_Section:Toggle("Rotating", "CrosshairRotate", false, "", function(V) Config.Crosshair_Rotate = V end)
Crosshair_Section:Slider("Rotation Speed", "CrosshairRotSpd", 1, 20, 1, 1, "", function(V) Config.Crosshair_Rotate_Speed = tonumber(V) or 1 end)
Crosshair_Section:Toggle("Rainbow", "CrosshairRainbow", false, "", function(V) Config.Crosshair_Rainbow = V end)
Crosshair_Section:Slider("Rainbow Speed", "CrosshairRainSpd", 1, 10, 1, 1, "", function(V) Config.Crosshair_Rainbow_Speed = tonumber(V) or 1 end)
Crosshair_Section:ColorPicker("Color", "CrosshairColor", Color3_From_Rgb(0, 255, 0), "", function(C) Config.Crosshair_Color = C end)
Crosshair_Section:Toggle("Follow Target", "CrossFollow", false, "Crosshair snaps onto the current target", function(V) Config.Crosshair_Follow = V end)

local Esp_Set_Section = Visuals_Tab:Section("ESP Settings", "Right")
Esp_Set_Section:Toggle("Team Check", "ESPTTeamChk", true, "Hide teammates in ESP", function(V) Config.Esp_Team_Check = V end)
Esp_Set_Section:Toggle("Show Name", "NameESP", false, "", function(V) Config.Esp_Name = V end)
Esp_Set_Section:Toggle("Show Distance", "DistESP", false, "", function(V) Config.Esp_Distance = V end)
Esp_Set_Section:Toggle("Health Bar", "HealthBarESP", false, "", function(V) Config.Esp_Health_Bar = V end)
Esp_Set_Section:Toggle("Tracers", "TracerESP", false, "", function(V) Config.Esp_Tracers = V end)
Esp_Set_Section:Dropdown("Tracer Origin", "TracerOrigin", {"Bottom", "Center", "Top", "Mouse"}, "Bottom", "", function(V) Config.Tracer_Origin = V end, nil, false)
Esp_Set_Section:Slider("Tracer Thickness", "TracerThick", 1, 5, 1, 1, "", function(V) Config.Tracer_Thickness = tonumber(V) or 1 end)
Esp_Set_Section:Toggle("Enemy Loadout", "LoadoutViewer", false, "Top panel: nearest enemy's nick, weapons & preview", function(V) Config.Loadout_Viewer = V end)
Esp_Set_Section:Toggle("Outline", "OutlineESP", true, "", function(V) Config.Esp_Outline = V end)

local Colors_Section = Visuals_Tab:Section("ESP Colors", "Right")
Colors_Section:ColorPicker("Box/Corner Color", "BoxColor", Color3_From_Rgb(255, 255, 255), "", function(C) Config.Box_Color = C end)
Colors_Section:ColorPicker("Name Color", "NameColor", Color3_From_Rgb(255, 255, 255), "", function(C) Config.Name_Color = C end)
Colors_Section:ColorPicker("Distance Color", "DistColor", Color3_From_Rgb(255, 255, 255), "", function(C) Config.Distance_Color = C end)
Colors_Section:ColorPicker("Skeleton Color", "SkelColor", Color3_From_Rgb(255, 255, 255), "", function(C) Config.Skeleton_Color = C end)
Colors_Section:ColorPicker("Tracer Color", "TracerColor", Color3_From_Rgb(255, 255, 255), "", function(C) Config.Tracer_Color = C end)
end)

Safe(function()
    local Start_Fallback
    local Start_Hook
    local Hooking = false
    local Fallback_Wanted = false

    local Bullet_Section = Visuals_Tab:Section("Bullet Tracers", "Right")
    Bullet_Section:Toggle("Bullet Tracers", "BulletTracers", false, "Draw a beam from the gun to each shot's impact", function(V)
        Config.Bullet_Tracers = V
        if V and Start_Hook then Start_Hook() end
        if V and Fallback_Wanted and Start_Fallback then Start_Fallback() end
    end)
    Bullet_Section:Slider("Tracer Life", "BulletTracerLife", 0.1, 1, 0.3, 0.05, "", function(V) Config.Bullet_Tracer_Life = tonumber(V) or 0.3 end)
    Bullet_Section:Dropdown("Material", "BulletTracerMaterial", Assets.TracerMaterials, "Neon", "", function(V) Config.Bullet_Tracer_Material = V end, nil, false)
    Bullet_Section:ColorPicker("Tracer Color", "BulletTracerColor", Color3_From_Rgb(255, 170, 0), "", function(C) Config.Bullet_Tracer_Color = C end)

    local Live = {}
    local Conn = nil
    local Hooked = false
    local Fallback_Running = false

    local function Step()
        local Now = Tick()
        for I = #Live, 1, -1 do
            local T = Live[I]
            local A = (Now - T.T0) / T.L
            if A >= 1 or not T.P.Parent then
                T.P:Destroy()
                table.remove(Live, I)
            else
                T.P.Transparency = A
            end
        end
        if #Live == 0 and Conn then Conn:Disconnect() Conn = nil end
    end

    local function Spawn_Tracer(A, B)
        if #Live >= 60 then return end
        local Dist = (B - A).Magnitude
        if Dist < 1 or Dist > 5000 then return end
        local Part = Instance.new("Part")
        Part.Anchored = true
        Part.CanCollide = false
        Part.CanTouch = false
        Part.CanQuery = false
        Part.CastShadow = false
        Part.Material = Enum.Material[Config.Bullet_Tracer_Material] or Enum.Material.Neon
        Part.Color = Config.Bullet_Tracer_Color
        Part.Size = Vector3_New(0.06, 0.06, Dist)
        Part.CFrame = Cframe_New(A:Lerp(B, 0.5), B)
        Part.Parent = Workspace
        Live[#Live + 1] = {P = Part, T0 = Tick(), L = Config.Bullet_Tracer_Life}
        if not Conn then Conn = Run_Service.RenderStepped:Connect(Step) end
    end

    local function Muzzle_Pos()
        local Vm = Workspace:FindFirstChild("ViewModels")
        local Fp = Vm and Vm:FindFirstChild("FirstPerson")
        if not Fp then return nil end
        for _, Model in ipairs(Fp:GetChildren()) do
            if Model:IsA("Model") and Model.Name:find(Local_Player.Name, 1, true) then
                local Muzzle = Model:FindFirstChild("_muzzle", true)
                if Muzzle and Muzzle:IsA("Attachment") then return Muzzle.WorldPosition end
                local Bp = Model:FindFirstChild("BodyPrimary", true)
                if Bp and Bp:IsA("BasePart") then return Bp.Position end
            end
        end
        return nil
    end

    local function Hook_Tracer_Effect()
        if Hooked then return end
        pcall(function()
            local Ps = Local_Player:FindFirstChild("PlayerScripts")
            local Mod = Ps and Ps:FindFirstChild("Modules")
            Mod = Mod and Mod:FindFirstChild("TracerEffect")
            if not Mod or not Mod:IsA("ModuleScript") then return end
            local Te = Game_Require(Mod)
            if type(Te) ~= "table" or type(Te.Play) ~= "function" then return end
            local Orig = Te.Play
            Te.Play = function(Self, Tracer_Data, Cfg, Extra)
                if Config.Bullet_Tracers and Tracer_Data and Tracer_Data.IsLocal and Tracer_Data.RaycastResults then
                    local Mp = Muzzle_Pos()
                    if Mp then
                        for _, H in ipairs(Tracer_Data.RaycastResults) do
                            if H.Position then Spawn_Tracer(Mp, H.Position) end
                        end
                    end
                end
                return Orig(Self, Tracer_Data, Cfg, Extra)
            end
            Hooked = true
        end)
    end

    function Start_Hook()
        if Is_Weak or Hooked or Hooking then return end
        Hooking = true
        task.spawn(function()
            for _ = 1, 30 do
                if not Config.Bullet_Tracers then break end
                Hook_Tracer_Effect()
                if Hooked then break end
                task.wait(0.5)
            end
            Hooking = false
        end)
    end

    function Start_Fallback()
        if Fallback_Running then return end
        Fallback_Running = true
        task.spawn(function()
            local Rp = RaycastParams.new()
            Rp.FilterType = Enum.RaycastFilterType.Exclude
            while Config.Bullet_Tracers and not Hooked do
                if User_Input_Service:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    local Char = Local_Player.Character
                    local Cam = Workspace.CurrentCamera
                    if Char and Cam then
                        Rp.FilterDescendantsInstances = {Char, Cam}
                        local Cf = Cam.CFrame
                        local Res = Workspace:Raycast(Cf.Position, Cf.LookVector * 2000, Rp)
                        local Endp = Res and Res.Position or (Cf.Position + Cf.LookVector * 2000)
                        Spawn_Tracer(Muzzle_Pos() or (Cf.Position + Cf.RightVector * 0.6 - Cf.UpVector * 0.5), Endp)
                    end
                end
                task.wait(0.07)
            end
            Fallback_Running = false
        end)
    end

    Bullet_Section:Toggle("Fallback On Click", "BulletTracerFallback", false, "Only used when the game tracer module cannot be hooked", function(V)
        Fallback_Wanted = V
        if V and Config.Bullet_Tracers then Start_Fallback() end
    end)
end)

Safe(function()
    if Is_Weak then return end
    local Tween_Service = game:GetService("TweenService")
    local On = false
    local Col = Color3_From_Rgb(159, 133, 195)
    local Float = 7
    local Alive = 2.8
    local Styles = {"Particles"}
    local Active = 0

    local Dot = "rbxassetid://6603835352"
    local Spark = "rbxassetid://243660364"
    local Bolt = "rbxassetid://446111271"
    local Beam = "rbxassetid://12781852245"
    local Flame = "rbxassetid://241650108"
    local Heart = "rbxassetid://120777973"
    local Star = "rbxassetid://1084982556"

    local function Scale(S) return S * (Alive / 2.8) end

    local function Blend(C, A)
        return Color3.new(Math_Clamp(C.R + A, 0, 1), Math_Clamp(C.G + A * 0.5, 0, 1), Math_Clamp(C.B + A * 0.25, 0, 1))
    end

    local function Ring(Part, C, Start, Finish, Dur, Trans, Mat)
        local R = Instance.new("Part")
        R.Shape = Enum.PartType.Cylinder
        R.Anchored = true
        R.CanCollide = false
        R.CanQuery = false
        R.CanTouch = false
        R.CastShadow = false
        R.Material = Mat or Enum.Material.Neon
        R.Color = C
        R.Transparency = Trans or 0.35
        R.Size = Vector3_New(0.05, Start, Start)
        R.CFrame = Part.CFrame * Cframe_Angles(0, 0, Math_Rad(90))
        R.Parent = Workspace.CurrentCamera
        local D = Scale(Dur)
        Tween_Service:Create(R, TweenInfo.new(D, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = Vector3_New(0.05, Finish, Finish), Transparency = 1}):Play()
        task.delay(D + 0.1, function() if R.Parent then R:Destroy() end end)
    end

    local function Flash(Part, C, Bright, Range, Dur)
        local L = Instance.new("PointLight")
        L.Color = C
        L.Brightness = Bright
        L.Range = Range
        L.Parent = Part
        local D = Scale(Dur)
        Tween_Service:Create(L, TweenInfo.new(D, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Brightness = 0, Range = 0}):Play()
        task.delay(D + 0.05, function() if L.Parent then L:Destroy() end end)
    end

    local function Emit(Part, O)
        if Active >= 40 then return end
        Active = Active + 1
        local E = Instance.new("ParticleEmitter")
        E.Texture = O.Tex or Dot
        E.Color = typeof(O.Color) == "ColorSequence" and O.Color or ColorSequence.new(O.Color or Col)
        E.LightEmission = 1
        E.Brightness = O.Bright or 8
        E.LightInfluence = 0
        E.Orientation = Enum.ParticleOrientation.FacingCamera
        E.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, O.Size or 0.15),
            NumberSequenceKeypoint.new(1, (O.Size or 0.15) * 0.25)
        })
        E.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        E.Speed = NumberRange.new(O.SpeedMin or 12, O.SpeedMax or 18)
        E.SpreadAngle = Vector2_New(O.Spread or 120, O.Spread or 120)
        E.Lifetime = NumberRange.new(Scale(O.LifeMin or 0.6), Scale(O.LifeMax or 1.2))
        E.Drag = O.Drag or 2
        E.Acceleration = O.Accel or Vector3_New(0, 4, 0)
        E.Rate = 0
        E.Enabled = true
        E.Parent = Part
        E:Emit(O.Count or 40)
        task.delay(Scale(4), function()
            Active = Active - 1
            if E.Parent then E:Destroy() end
        end)
    end

    local function Fortnite(Part, Text)
        local Off = Vector3_New(Math_Random(-6, 6), Math_Random(1, 5), Math_Random(-3, 3))
        local Bb = Instance.new("BillboardGui")
        Bb.Name = "PhantomDamageNumber"
        Bb.Size = UDim2.new(0, 70, 0, 40)
        Bb.StudsOffset = Off
        Bb.AlwaysOnTop = true
        Bb.LightInfluence = 0
        Bb.Adornee = Part
        Bb.Parent = Workspace.CurrentCamera
        local L = Instance.new("TextLabel")
        L.Size = UDim2.new(1, 0, 1, 0)
        L.BackgroundTransparency = 1
        L.Text = Text
        L.TextColor3 = Col
        L.TextTransparency = 1
        L.TextStrokeColor3 = Color3.new(0, 0, 0)
        L.TextStrokeTransparency = 1
        L.TextScaled = true
        L.Font = Enum.Font.GothamBlack
        L.Parent = Bb
        Tween_Service:Create(L, TweenInfo.new(0.12), {TextTransparency = 0, TextStrokeTransparency = 0.55}):Play()
        Tween_Service:Create(Bb, TweenInfo.new(Alive, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {StudsOffset = Off + Vector3_New(0, Float, 0)}):Play()
        task.delay(Alive, function()
            if not Bb.Parent then return end
            local F = Scale(0.5)
            Tween_Service:Create(L, TweenInfo.new(F), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
            task.delay(F + 0.05, function() if Bb.Parent then Bb:Destroy() end end)
        end)
    end

    local Handlers = {
        Particles = function(P)
            Emit(P, {Tex = Dot, Count = 60, SpeedMin = 22, SpeedMax = 29, Spread = 130, Size = 0.13, Bright = 13, Drag = 3.2})
        end,
        Shockwave = function(P)
            Flash(P, Col, 8, 18, 0.4)
            Ring(P, Col, 0.5, 7, 0.5)
            Ring(P, Blend(Col, 0.2), 0.25, 5, 0.35, 0.55)
            Emit(P, {Tex = Spark, Count = 28, SpeedMin = 14, SpeedMax = 24, Spread = 180, LifeMin = 0.25, LifeMax = 0.45, Drag = 5, Size = 0.35})
        end,
        Lightning = function(P)
            local B = Color3.new(0.85, 0.92, 1)
            Flash(P, B, 14, 22, 0.2)
            Emit(P, {Tex = Bolt, Color = B, Count = 22, SpeedMin = 32, SpeedMax = 48, Spread = 18,
                LifeMin = 0.08, LifeMax = 0.22, Drag = 0.2, Accel = Vector3_New(0, -20, 0), Bright = 16})
            Emit(P, {Tex = Beam, Count = 40, SpeedMin = 20, SpeedMax = 38, Spread = 120,
                LifeMin = 0.12, LifeMax = 0.35, Drag = 1, Accel = Vector3_New(0, -14, 0), Bright = 12})
        end,
        Blood = function(P)
            local B = Color3.new(Math_Clamp(Col.R * 0.9 + 0.35, 0, 1), Math_Clamp(Col.G * 0.15, 0, 0.35), Math_Clamp(Col.B * 0.15, 0, 0.35))
            Emit(P, {Tex = Spark, Color = B, Count = 70, SpeedMin = 12, SpeedMax = 28, Spread = 175,
                LifeMin = 0.7, LifeMax = 1.3, Drag = 5, Accel = Vector3_New(0, -22, 0), Size = 0.22})
            Emit(P, {Tex = Dot, Color = B, Count = 20, SpeedMin = 4, SpeedMax = 10, Spread = 180, Size = 0.5, Bright = 3})
        end,
        Fire = function(P)
            local F = Color3.new(Math_Clamp(Col.R + 0.25, 0, 1), Math_Clamp(Col.G * 0.6 + 0.2, 0, 1), Math_Clamp(Col.B * 0.2, 0, 0.4))
            Flash(P, F, 10, 16, 0.45)
            Emit(P, {Tex = Flame, Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3_From_Rgb(255, 240, 120)),
                ColorSequenceKeypoint.new(1, F)}), Count = 45, SpeedMin = 8, SpeedMax = 16,
                Spread = 60, Accel = Vector3_New(0, 12, 0), Size = 0.6, Bright = 12})
        end,
        Ice = function(P)
            local I = Color3.new(Math_Clamp(Col.R * 0.4 + 0.4, 0, 1), Math_Clamp(Col.G * 0.5 + 0.5, 0, 1), 1)
            Flash(P, I, 6, 12, 0.35)
            Emit(P, {Tex = Spark, Color = I, Count = 40, SpeedMin = 10, SpeedMax = 22, Spread = 160,
                Accel = Vector3_New(0, -10, 0), Size = 0.25})
            Ring(P, I, 0.2, 3.5, 0.5, 0.4, Enum.Material.Glass)
        end,
        Hearts = function(P)
            Emit(P, {Tex = Heart, Count = 26, SpeedMin = 6, SpeedMax = 14, Spread = 90,
                Accel = Vector3_New(0, 8, 0), Size = 0.7, LifeMin = 1, LifeMax = 1.6, Bright = 5})
        end,
        Stars = function(P)
            Flash(P, Col, 7, 14, 0.3)
            Emit(P, {Tex = Star, Count = 34, SpeedMin = 14, SpeedMax = 26, Spread = 150, Size = 0.4, Bright = 10})
        end,
        Confetti = function(P)
            Emit(P, {Tex = Spark, Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Col),
                ColorSequenceKeypoint.new(0.5, Blend(Col, 0.5)),
                ColorSequenceKeypoint.new(1, Col)}), Count = 80, SpeedMin = 16, SpeedMax = 30,
                Spread = 180, Accel = Vector3_New(0, -18, 0), Drag = 3, Size = 0.2})
        end,
        Ripple = function(P)
            Ring(P, Col, 0.3, 4.5, 0.45, 0.3)
            task.delay(0.12, function()
                if P.Parent then Ring(P, Blend(Col, 0.15), 0.2, 6.5, 0.65, 0.5) end
            end)
            Emit(P, {Tex = Dot, Count = 18, SpeedMin = 3, SpeedMax = 8, Spread = 180, Size = 0.3, Bright = 6})
        end,
        Sparks = function(P)
            Flash(P, Col, 9, 12, 0.25)
            Emit(P, {Tex = Beam, Count = 40, SpeedMin = 25, SpeedMax = 45, Spread = 140,
                LifeMin = 0.2, LifeMax = 0.5, Drag = 4, Accel = Vector3_New(0, -25, 0), Size = 0.2, Bright = 14})
            Emit(P, {Tex = Dot, Count = 15, SpeedMin = 5, SpeedMax = 12, Spread = 180, Size = 0.2})
        end,
        Neon = function(P)
            Flash(P, Col, 16, 20, 0.5)
            Ring(P, Col, 0.15, 4, 0.35, 0.15)
            Emit(P, {Tex = Dot, Count = 50, SpeedMin = 18, SpeedMax = 30, Spread = 180, Size = 0.18, Bright = 18})
        end,
        Void = function(P)
            local D = Color3.new(Col.R * 0.3, Col.G * 0.2, Math_Clamp(Col.B * 0.6 + 0.2, 0, 1))
            Emit(P, {Tex = Spark, Color = D, Count = 45, SpeedMin = -18, SpeedMax = -8, Spread = 180,
                Size = 0.3, Bright = 4, Accel = Vector3_Zero})
            Emit(P, {Tex = Bolt, Color = D, Count = 20, SpeedMin = 10, SpeedMax = 20, Spread = 160, Size = 0.35, Bright = 6})
            Ring(P, D, 0.2, 4, 0.7, 0.5, Enum.Material.Glass)
        end,
        Plasma = function(P)
            Flash(P, Col, 12, 18, 0.35)
            Emit(P, {Tex = Bolt, Count = 35, SpeedMin = 20, SpeedMax = 36, Spread = 170, Size = 0.3, Bright = 15})
            Ring(P, Blend(Col, 0.3), 0.4, 5.5, 0.4, 0.25)
        end,
        Glitch = function(P)
            for I = 0, 2 do
                task.delay(I * 0.06, function()
                    if not P.Parent then return end
                    Emit(P, {Tex = Spark, Color = I == 1 and Blend(Col, 0.6) or Col, Count = 22,
                        SpeedMin = 18, SpeedMax = 34, Spread = 180, LifeMin = 0.1, LifeMax = 0.25, Size = 0.28, Bright = 12})
                end)
            end
            Flash(P, Blend(Col, 0.6), 8, 10, 0.15)
        end,
        Cosmic = function(P)
            Flash(P, Blend(Col, 0.25), 5, 16, 0.6)
            Emit(P, {Tex = Star, Count = 55, SpeedMin = 6, SpeedMax = 18, Spread = 180,
                LifeMin = 1.2, LifeMax = 2, Drag = 1.5, Accel = Vector3_New(0, 2, 0), Size = 0.18, Bright = 10})
            Ring(P, Blend(Col, 0.1), 0.2, 3.5, 0.8, 0.65, Enum.Material.Glass)
        end
    }

    local Style_Names = {"Particles", "Fortnite", "Shockwave", "Lightning", "Blood", "Fire", "Ice",
        "Hearts", "Stars", "Confetti", "Ripple", "Sparks", "Neon", "Void", "Plasma", "Glitch", "Cosmic"}

    local Fx_Conn = nil

    local On_Descendant = LPH_NO_VIRTUALIZE(function(Obj)
        if not On then return end
        if not Obj:IsA("BillboardGui") then return end
        if Obj.Name == "PhantomDamageNumber" then return end
        task.defer(function()
            if not Obj.Parent then return end
            local Lbl = Obj:FindFirstChildWhichIsA("TextLabel", true)
            if not Lbl then return end
            local Text = Lbl.Text
            local Dmg = tonumber(Text)
            if not (Dmg and Dmg > 0) then return end
            local Adornee = Obj.Adornee or (Obj.Parent:IsA("BasePart") and Obj.Parent)
            if not Adornee then return end
            local Part
            if Adornee:IsA("BasePart") then
                Part = Adornee
            elseif Adornee:IsA("Attachment") then
                Part = Adornee.Parent
            elseif Adornee:IsA("Model") then
                Part = Adornee.PrimaryPart
            end
            if not Part or not Part:IsA("BasePart") then return end
            for _, S in ipairs(Styles) do
                if S == "Fortnite" then
                    Obj.Enabled = false
                    Fortnite(Part, Text)
                else
                    local H = Handlers[S]
                    if H then pcall(H, Part) end
                end
            end
        end)
    end)

    Data.Hit_Fx = {
        Names = Style_Names,
        Set_On = function(V)
            On = V
            if V and not Fx_Conn then
                Fx_Conn = Workspace.DescendantAdded:Connect(On_Descendant)
            elseif not V and Fx_Conn then
                Fx_Conn:Disconnect()
                Fx_Conn = nil
            end
        end,
        Set_Style = function(V) Styles = type(V) == "table" and V or {V} end,
        Set_Float = function(V) Float = tonumber(V) or 7 end,
        Set_Alive = function(V) Alive = tonumber(V) or 2.8 end
    }
end)


Safe(function()
    local Hit_Section = Visuals_Tab:Section("Hit Effects", "Right")
    Hit_Section:Toggle("Hit Sound", "HitSoundEnabled", false, "Play a sound when you damage an enemy", function(V) Config.Hit_Sound_Enabled = V end)
    Hit_Section:Dropdown("Sound", "HitSoundValue", Assets.HitSoundNames, "None", "", function(V) Config.Hit_Sound = V end, nil, false)
    Hit_Section:Slider("Volume", "HitSoundVolume", 0.1, 3, 1, 0.1, "", function(V) Config.Hit_Sound_Volume = tonumber(V) or 1 end)
    Hit_Section:Toggle("Hit Effects", "HitFxEnabled", false, "Spawn an effect on the enemy you hit", function(V) Data.Hit_Fx.Set_On(V) end)
    Hit_Section:Dropdown("Style", "HitFxStyle", Data.Hit_Fx.Names, {"Particles"}, "", function(V) Data.Hit_Fx.Set_Style(V) end, nil, true)
    Hit_Section:Slider("Float Speed", "HitFxFloat", 1, 25, 7, 1, "How far the effect rises", function(V) Data.Hit_Fx.Set_Float(V) end)
    Hit_Section:Slider("Disappear Timer", "HitFxAlive", 0.5, 8, 2.8, 0.1, "How long the effect stays", function(V) Data.Hit_Fx.Set_Alive(V) end)
    Hit_Section:Toggle("Hit Marker", "HitMarkerEnabled", false, "Show a marker on the enemy when hit", function(V) Config.Hit_Marker = V end)
	Hit_Section:ColorPicker("Marker Color", "HitMarkerColor", Color3_From_Rgb(255, 255, 255), "", function(C) Config.Hit_Marker_Color = C end)
    Hit_Section:Slider("Marker Size", "HitMarkerSize", 2, 30, 10, 1, "", function(V) Config.Hit_Marker_Size = tonumber(V) or 10 end)
    Hit_Section:Slider("Marker Gap", "HitMarkerGap", 0, 20, 4, 1, "", function(V) Config.Hit_Marker_Gap = tonumber(V) or 4 end)
    Hit_Section:Slider("Marker Thickness", "HitMarkerThick", 1, 8, 2, 1, "", function(V) Config.Hit_Marker_Thickness = tonumber(V) or 2 end)
    Hit_Section:Slider("Marker Duration", "HitMarkerLife", 0.1, 2, 0.4, 0.05, "", function(V) Config.Hit_Marker_Life = tonumber(V) or 0.4 end)
    Hit_Section:Toggle("Marker Rainbow", "HitMarkerRainbow", false, "", function(V) Config.Hit_Marker_Rainbow = V end)
    Hit_Section:Slider("Rainbow Speed", "HitMarkerRainSpd", 1, 10, 1, 1, "", function(V) Config.Hit_Marker_Rainbow_Speed = tonumber(V) or 1 end)
end)

do
local Last_Health = {}
local Hit_Markers = {}
local Hit_Marker_Hue = 0
local Last_Fire = 0

local function Play_Hit_Sound()
    if not Config.Hit_Sound_Enabled then return end
    local Id = Assets.HitSounds[Config.Hit_Sound]
    if not Id or Id == "" then return end
    local S = Instance.new("Sound")
    S.SoundId = Id
    S.Volume = Config.Hit_Sound_Volume
    S.PlayOnRemove = true
    S.Parent = Sound_Service
    S:Destroy()
end

local function Spawn_Hit_Marker(Part)
    if not Config.Hit_Marker then return end
    local Lines = {}
    for I = 1, 4 do
        local L = Drawing.new("Line")
        L.Visible = false
        L.Thickness = Config.Hit_Marker_Thickness
        L.Transparency = 1
        Lines[I] = L
    end
    Hit_Markers[#Hit_Markers + 1] = {Part = Part, Pos = Part and Part.Position, T0 = Tick(), Lines = Lines}
end

local function Register_Hit(Player)
    Play_Hit_Sound()
    if Config.Hit_Marker then
        local Part = Player and (Get_Part_From_Player(Player, "Head") or Get_Part_From_Player(Player, "Torso"))
        Spawn_Hit_Marker(Part)
    end
end

Run_Service.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
    if not (Config.Hit_Sound_Enabled or Config.Hit_Marker) then
        if next(Last_Health) then Table_Clear(Last_Health) end
        return
    end
    if User_Input_Service:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or Data.Is_Auto_Shooting then
        Last_Fire = Tick()
    end
    local Firing_Recent = (Tick() - Last_Fire) < 0.25
    local Target = Data.Sa_Target_Player or Data.Current_Aim_Target
    local Cam = Workspace.CurrentCamera
    local Look = Cam and Cam.CFrame.LookVector
    local Cam_Pos = Cam and Cam.CFrame.Position
    local Plrs = Players:GetPlayers()
    for I = 1, #Plrs do
        local P = Plrs[I]
        if P ~= Local_Player then
            local Char = P.Character
            local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
            if Hum and not Same_Team(P, Local_Player) then
                local Prev = Last_Health[P]
                local Cur = Hum.Health
                if Prev and Cur < Prev - 0.05 and Firing_Recent then
                    local Ok
                    if Config.Hit_Only_Target then
                        Ok = (P == Target)
                    elseif P == Target then
                        Ok = true
                    elseif Look and Cam_Pos then
                        local Hrp = Char:FindFirstChild("HumanoidRootPart") or Char:FindFirstChild("Head")
                        if Hrp then
                            local Dir = (Hrp.Position - Cam_Pos)
                            if Dir.Magnitude > 0.1 then
                                Ok = Look:Dot(Dir.Unit) > 0.985
                            end
                        end
                    end
                    if Ok then Register_Hit(P) end
                end
                Last_Health[P] = Cur
            else
                Last_Health[P] = nil
            end
        end
    end
end))

Run_Service.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function(Dt)
    if #Hit_Markers == 0 then return end
    Hit_Marker_Hue = (Hit_Marker_Hue + Dt * 0.5 * Config.Hit_Marker_Rainbow_Speed) % 1
    local Camera = Workspace.CurrentCamera
    local Now = Tick()
    for I = #Hit_Markers, 1, -1 do
        local M = Hit_Markers[I]
        local A = (Now - M.T0) / Config.Hit_Marker_Life
        if A >= 1 then
            for _, L in ipairs(M.Lines) do L:Remove() end
            table.remove(Hit_Markers, I)
        else
            local WorldPos = (M.Part and M.Part.Parent) and M.Part.Position or M.Pos
            local Sp, Vis = Camera:WorldToViewportPoint(WorldPos)
            if Vis and Sp.Z > 0 then
                local Cx, Cy = Sp.X, Sp.Y
                local G = Config.Hit_Marker_Gap
                local Sz = Config.Hit_Marker_Size
                local Col = Config.Hit_Marker_Rainbow and Color3_From_Hsv(Hit_Marker_Hue, 1, 1) or Config.Hit_Marker_Color
                local Tr = 1 - A
                local Seg = {
                    {Vector2_New(Cx - G - Sz, Cy - G - Sz), Vector2_New(Cx - G, Cy - G)},
                    {Vector2_New(Cx + G, Cy - G), Vector2_New(Cx + G + Sz, Cy - G - Sz)},
                    {Vector2_New(Cx - G - Sz, Cy + G + Sz), Vector2_New(Cx - G, Cy + G)},
                    {Vector2_New(Cx + G, Cy + G), Vector2_New(Cx + G + Sz, Cy + G + Sz)},
                }
                for J = 1, 4 do
                    local L = M.Lines[J]
                    L.Visible = true
                    L.From = Seg[J][1]
                    L.To = Seg[J][2]
                    L.Color = Col
                    L.Transparency = Tr
                    L.Thickness = Config.Hit_Marker_Thickness
                end
            else
                for _, L in ipairs(M.Lines) do L.Visible = false end
            end
        end
    end
end))
end

Safe(function()
    if Is_Weak then return end
    local Finisher_Section = Visuals_Tab:Section("Finisher", "Right")
    Finisher_Section:Toggle("Only My Kills", "FinOnlyMine", true, "Play the finisher picked in Skins only on your own eliminations", function(V)
        pcall(SC_Fin.SetOnlyMine, V)
    end)
end)

local Visual_Misc_Section = Visuals_Tab:Section("Misc", "Left")
Visual_Misc_Section:Toggle("Third Person", "ThirdPerson", false, "", function(V)
    Config.Third_Person = V
    if not V then
        Local_Player.CameraMinZoomDistance = 0.5
        Local_Player.CameraMaxZoomDistance = 400
    end
end, true)
Visual_Misc_Section:Toggle("Streamer Mode", "StreamerMode", false, "", function(V)
    Config.Streamer_Mode = V
    if V and Local_Player.Character and Local_Player.Character:FindFirstChild("Humanoid") then
        Local_Player.Character.Humanoid.DisplayName = "Hidden"
    end
end)

do
    local O = { Shadows = false, VFX = false, Textures = false, Materials = false, Quality = false, Water = false }
    local Fps_Conn = nil

    local function Any_On()
        return O.Shadows or O.VFX or O.Textures or O.Materials or O.Quality or O.Water
    end

    local function Optimize(inst)
        pcall(function()
            if inst:IsA("BasePart") then
                if O.Materials then inst.Material = Enum.Material.Plastic inst.Reflectance = 0 end
                if O.Shadows then inst.CastShadow = false end
                if inst:IsA("MeshPart") then
                    if O.Quality then inst.RenderFidelity = Enum.RenderFidelity.Performance end
                    if O.Textures then inst.TextureID = "" end
                end
            elseif inst:IsA("Decal") or inst:IsA("Texture") then
                if O.Textures then inst.Transparency = 1 end
            elseif inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Smoke")
                or inst:IsA("Fire") or inst:IsA("Sparkles") or inst:IsA("Beam") then
                if O.VFX then inst.Enabled = false end
            end
        end)
    end

    local function Apply_Global()
        pcall(function() Lighting.GlobalShadows = not O.Shadows end)
        pcall(function()
            settings().Rendering.QualityLevel = O.Quality and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
        end)
        if O.Water then
            pcall(function()
                local T = Workspace:FindFirstChildOfClass("Terrain")
                if T then T.WaterWaveSize = 0 T.WaterWaveSpeed = 0 T.WaterReflectance = 0 end
            end)
        end
    end

    local Scan_Running = false
    local function Refresh()
        Apply_Global()
        if Any_On() then
            if not Scan_Running then
                Scan_Running = true
                task.spawn(function()
                    local Descs = Workspace:GetDescendants()
                    for I = 1, #Descs do
                        Optimize(Descs[I])
                        if I % 400 == 0 then task.wait() end
                    end
                    Scan_Running = false
                end)
            end
            if not Fps_Conn then
                Fps_Conn = Workspace.DescendantAdded:Connect(function(inst)
                    if Any_On() then task.defer(Optimize, inst) end
                end)
            end
        elseif Fps_Conn then
            Fps_Conn:Disconnect()
            Fps_Conn = nil
        end
    end

    local S = World_Tab:Section("FPS Boost", "Left")
    S:Toggle("FPS Boost (All)", "FpsBoostAll", false, "Apply every optimization below at once for max FPS", function(V)
        O.Shadows = V O.VFX = V O.Textures = V O.Materials = V O.Quality = V O.Water = V
        Refresh()
    end)
    S:Toggle("Remove Shadows", "FpsShadows", false, "Disable global & part shadows", function(V) O.Shadows = V Refresh() end)
    S:Toggle("Remove Particles / VFX", "FpsVFX", false, "Disable particles, trails, smoke, fire, beams", function(V) O.VFX = V Refresh() end)
    S:Toggle("Remove Textures", "FpsTextures", false, "Hide decals & mesh textures (rejoin to restore)", function(V) O.Textures = V Refresh() end)
    S:Toggle("Low Materials", "FpsMaterials", false, "Force plastic material, no reflectance (rejoin to restore)", function(V) O.Materials = V Refresh() end)
    S:Toggle("Low Quality Level", "FpsQuality", false, "Force lowest render quality", function(V) O.Quality = V Refresh() end)
    S:Toggle("No Water Detail", "FpsWater", false, "Flatten terrain water waves", function(V) O.Water = V Refresh() end)
end

Safe(function()
local PostFX_Section = World_Tab:Section("Post FX", "Left")
PostFX_Section:Toggle("Enable Bloom", "BloomEnabled", false, "", function(V) Config.Bloom_Enabled = V Update_Bloom() end)
PostFX_Section:Slider("Bloom Intensity", "BloomInt", 0, 10, 1, 0.01, "", function(V) Config.Bloom_Intensity = tonumber(V) Update_Bloom() end)
PostFX_Section:Slider("Bloom Size", "BloomSize", 0, 56, 24, 0.1, "", function(V) Config.Bloom_Size = tonumber(V) Update_Bloom() end)
PostFX_Section:Slider("Bloom Threshold", "BloomThresh", 0, 4, 2, 0.01, "", function(V) Config.Bloom_Threshold = tonumber(V) Update_Bloom() end)
PostFX_Section:Toggle("Enable Blur", "BlurEnabled", false, "", function(V) Config.Blur_Enabled = V Update_Blur() end)
PostFX_Section:Slider("Blur Size", "BlurSize", 0, 56, 12, 0.1, "", function(V) Config.Blur_Size = tonumber(V) Update_Blur() end)
PostFX_Section:Toggle("Enable Color Correction", "CCEnabled", false, "", function(V) Config.CC_Enabled = V Update_CC() end)
PostFX_Section:Slider("Brightness", "CCBright", -1, 1, 0, 0.01, "", function(V) Config.CC_Brightness = tonumber(V) Update_CC() end)
PostFX_Section:Slider("Contrast", "CCCont", -1, 2, 0, 0.01, "", function(V) Config.CC_Contrast = tonumber(V) Update_CC() end)
PostFX_Section:Slider("Saturation", "CCSat", -1, 2, 0, 0.01, "", function(V) Config.CC_Saturation = tonumber(V) Update_CC() end)
PostFX_Section:ColorPicker("Tint Color", "CCTint", Color3_From_Rgb(255, 255, 255), "", function(C) Config.CC_TintColor = C Update_CC() end)
PostFX_Section:Toggle("Enable Sun Rays", "SREnabled", false, "", function(V) Config.SunRays_Enabled = V Update_SR() end)
PostFX_Section:Slider("Sun Rays Intensity", "SRInt", 0, 1, 0.25, 0.01, "", function(V) Config.SunRays_Intensity = tonumber(V) Update_SR() end)
PostFX_Section:Slider("Sun Rays Spread", "SRSpread", 0, 1, 0.1, 0.01, "", function(V) Config.SunRays_Spread = tonumber(V) Update_SR() end)

local Custom_Lighting_Section = World_Tab:Section("Custom Lighting", "Right")
Custom_Lighting_Section:Toggle("Enable Custom Lighting", "CustLightEnabled", false, "", function(V) Config.CustLight_Enabled = V Update_CustomLighting() end)
Custom_Lighting_Section:Slider("Brightness", "CustLightBright", 0, 10, 1, 0.1, "", function(V) Config.CustLight_Brightness = tonumber(V) Update_CustomLighting() end)
Custom_Lighting_Section:Slider("Time of Day", "CustLightTime", 0, 24, 14, 0.1, "", function(V) Config.CustLight_Time = tonumber(V) Update_CustomLighting() end)
Custom_Lighting_Section:Toggle("Global Shadows", "CustLightShadows", true, "", function(V) Config.CustLight_Shadows = V Update_CustomLighting() end)
Custom_Lighting_Section:ColorPicker("Ambient Color", "CustLightAmbient", Color3_From_Rgb(128, 128, 128), "", function(C) Config.CustLight_Ambient = C Update_CustomLighting() end)

local Atmo_Section = World_Tab:Section("Atmosphere", "Right")
Atmo_Section:Toggle("Custom Atmosphere", "AtmoEnabled", false, "", function(V) Config.Atmo_Enabled = V Update_Atmo() end)
Atmo_Section:Slider("Density", "AtmoDens", 0, 1, 0.3, 0.01, "", function(V) Config.Atmo_Density = tonumber(V) Update_Atmo() end)
Atmo_Section:Slider("Offset", "AtmoOff", 0, 1, 0.25, 0.01, "", function(V) Config.Atmo_Offset = tonumber(V) Update_Atmo() end)
Atmo_Section:Slider("Glare", "AtmoGlare", 0, 10, 0, 0.01, "", function(V) Config.Atmo_Glare = tonumber(V) Update_Atmo() end)
Atmo_Section:Slider("Haze", "AtmoHaze", 0, 10, 0, 0.01, "", function(V) Config.Atmo_Haze = tonumber(V) Update_Atmo() end)
Atmo_Section:ColorPicker("Color", "AtmoColor", Color3_From_Rgb(199, 199, 199), "", function(C) Config.Atmo_Color = C Update_Atmo() end)
Atmo_Section:ColorPicker("Decay", "AtmoDecay", Color3_From_Rgb(106, 112, 125), "", function(C) Config.Atmo_Decay = C Update_Atmo() end)
end)

Safe(function()
    if Is_Weak then return end
    local Skies = {
        Aurora = {"340908398", "340908450", "340908468", "340908504", "340908530", "340908586"},
        ["Blue Aurora"] = {"12063984", "12064107", "12064152", "12064121", "12064115", "12064131"},
        ["Blue Stars"] = {"149397684", "149397686", "149397688", "149397692", "149397697", "149397702"},
        Chill = {"5084575798", "5084575916", "5103949679", "5103948542", "5103948784", "5084576400"},
        Clouds = {"570557514", "570557775", "570557559", "570557620", "570557672", "570557727"},
        Gloomy = {"5346760450", "5346760689", "5346760919", "5346761102", "5346761335", "5346761509"},
        Jungle = {"214399891", "214399887", "214399894", "214405668", "214399899", "214399889"},
        Minecraft = {"1876545003", "1876544331", "1876542941", "1876543392", "1876543764", "1876544642"},
        ["Mountain Scape"] = {"12474836637", "12474837052", "12474836748", "12474836935", "12474836446", "12474835757"},
        Nebula = {"159454299", "159454296", "159454293", "159454286", "159454300", "159454288"},
        ["Nebula Purple"] = {"129876530632297", "108406529909981", "104400530594543", "73372229972523", "87408857415924", "13781740568136"},
        Neptune = {"218955819", "218953419", "218954524", "218958493", "218957134", "218950090"},
        Realistic = {"144933338", "144931530", "144933262", "144933244", "144933299", "144931564"},
        Redshift = {"401664839", "401664862", "401664960", "401664881", "401664901", "401664936"},
        Stormy = {"255027929", "255027967", "255027923", "255027938", "255027946", "255027960"},
        Twilight = {"264908339", "264907909", "264909420", "264909758", "264908886", "264907379"},
        Vaporwave = {"1417494030", "1417494146", "1417494253", "1417494402", "1417494499", "1417494643"},
        ["Winter Mountain"] = {"402229526", "402229596", "402229293", "402229368", "402229417", "402229564"},
        ["Yellow Clouds"] = {"252760981", "252763035", "252761439", "252760980", "252760986", "252762652"}
    }
    local Sky_Names = {}
    for K in pairs(Skies) do Sky_Names[#Sky_Names + 1] = K end
    table.sort(Sky_Names)

    local Current = "Aurora"

    local function Apply_Sky()
        local T = Skies[Current]
        if not T then return end
        My_Sky.SkyboxBk = "rbxassetid://" .. T[1]
        My_Sky.SkyboxDn = "rbxassetid://" .. T[2]
        My_Sky.SkyboxFt = "rbxassetid://" .. T[3]
        My_Sky.SkyboxLf = "rbxassetid://" .. T[4]
        My_Sky.SkyboxRt = "rbxassetid://" .. T[5]
        My_Sky.SkyboxUp = "rbxassetid://" .. T[6]
    end

    local Sky_Section = World_Tab:Section("Skybox", "Left")
    Sky_Section:Toggle("Custom Skybox", "SkyboxEnabled", false, "", function(V)
        Config.Skybox_Enabled = V
        if V then Apply_Sky() end
        Update_Skybox()
    end)
    Sky_Section:Dropdown("Skybox", "SkyboxPick", Sky_Names, "Aurora", "", function(V)
        Current = V
        if Config.Skybox_Enabled then Apply_Sky() end
    end, nil, false)
end)

Safe(function()
    if Is_Weak then return end
    local Cfgs = {
        Rain = {Base_Rate = 600, Speed = 60, Size = 10, Life = 0.8, Locked = true,
            Tex = "rbxassetid://1822883048", Ori = Enum.ParticleOrientation.FacingCameraWorldUp, Li = 0.9, Le = 0.05},
        Snow = {Base_Rate = 1000, Speed = 30, Size = 0.4, Life = 4, Locked = false,
            Tex = "rbxassetid://99851851", Ori = Enum.ParticleOrientation.FacingCamera, Li = 1, Le = 0.5},
        ["Light Rain"] = {Base_Rate = 500, Speed = 40, Size = 0.2, Life = 9, Locked = true,
            Tex = "rbxasset://textures/particles/sparkles_main.dds", Ori = Enum.ParticleOrientation.FacingCameraWorldUp, Li = 0.3, Le = 0.5},
        Stars = {Base_Rate = 1000, Speed = 30, Size = 0.4, Life = 4, Locked = false,
            Tex = "rbxassetid://6822501679", Ori = Enum.ParticleOrientation.FacingCamera, Li = 1, Le = 0.5},
        Hearts = {Base_Rate = 1000, Speed = 30, Size = 0.4, Life = 4, Locked = false,
            Tex = "rbxassetid://36721240", Ori = Enum.ParticleOrientation.FacingCamera, Li = 1, Le = 0.5}
    }

    local Shared = {Color = Color3_From_Rgb(255, 255, 255), Rate = 100, Size_Scale = 1,
        Opacity = 0.5, Spread = 0, Brightness = 1, Glow = 0}

    local On = false
    local Parts, Emitters = {}, {}
    local Count = 0
    local Offset = Vector3_New(0, 20, 0)

    local Conn = nil

    local Follow = LPH_NO_VIRTUALIZE(function()
        local Cam = Workspace.CurrentCamera
        if not Cam then return end
        local Cf = Cframe_New(Cam.CFrame.Position + Offset)
        for _, P in pairs(Parts) do P.CFrame = Cf end
    end)

    local function Apply(E, C)
        E.EmissionDirection = Enum.NormalId.Bottom
        E.LockedToPart = C.Locked
        E.Orientation = C.Ori
        E.Texture = C.Tex
        E.Speed = NumberRange.new(C.Speed, C.Speed)
        E.Lifetime = NumberRange.new(C.Life, C.Life)
        E.SpreadAngle = Vector2_New(Shared.Spread, Shared.Spread)
        local G = Math_Clamp(Shared.Glow, 0, 5)
        E.Brightness = Shared.Brightness * (1 + G * 1.75)
        E.LightEmission = Math_Clamp(C.Le + G * 0.2, 0, 1)
        E.LightInfluence = Math_Clamp(C.Li * (1 - (G / 5) * 0.98), 0, 1)
        E.Rate = C.Base_Rate * (Shared.Rate / 100)
        local Sz = C.Size * Shared.Size_Scale
        E.Size = NumberSequence.new(Sz)
        local Tr = 1 - Shared.Opacity
        E.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.25, Tr),
            NumberSequenceKeypoint.new(0.75, Tr),
            NumberSequenceKeypoint.new(1, 1)
        })
        E.Color = ColorSequence.new(Shared.Color)
    end

    local function Destroy_One(K)
        if Parts[K] then
            Parts[K]:Destroy()
            Parts[K] = nil
            Emitters[K] = nil
            Count = Count - 1
        end
    end

    local function Build(K)
        Destroy_One(K)
        local P = Instance.new("Part")
        P.Size = Vector3_New(40, 1, 85)
        P.CanCollide = false
        P.CanQuery = false
        P.CanTouch = false
        P.Massless = true
        P.CastShadow = false
        P.Transparency = 1
        P.Anchored = true
        P.Parent = Workspace
        local E = Instance.new("ParticleEmitter")
        Apply(E, Cfgs[K])
        E.Parent = P
        Parts[K] = P
        Emitters[K] = E
        Count = Count + 1
    end

    local function Refresh()
        for K, E in pairs(Emitters) do Apply(E, Cfgs[K]) end
    end

    local Selected = {}

    local function Sync()
        for K in pairs(Cfgs) do
            if On and table.find(Selected, K) then
                if not Parts[K] then Build(K) end
            else
                Destroy_One(K)
            end
        end
        Refresh()
        if Count > 0 and not Conn then
            Conn = Run_Service.Heartbeat:Connect(Follow)
        elseif Count == 0 and Conn then
            Conn:Disconnect()
            Conn = nil
        end
    end

    local W = World_Tab:Section("Weather", "Right")
    W:Toggle("Enable", "WeatherEnabled", false, "", function(V) On = V Sync() end)
    W:Dropdown("Effects", "WeatherFx", {"Rain", "Snow", "Light Rain", "Stars", "Hearts"}, {}, "", function(V)
        Selected = type(V) == "table" and V or {}
        Sync()
    end, nil, true)
    W:ColorPicker("Color", "WeatherColor", Color3_From_Rgb(255, 255, 255), "", function(C) Shared.Color = C Refresh() end)
    W:Slider("Rate", "WeatherRate", 0, 100, 100, 1, "", function(V) Shared.Rate = tonumber(V) or 100 Refresh() end)
    W:Slider("Size Scale", "WeatherSize", 0.1, 5, 1, 0.1, "", function(V) Shared.Size_Scale = tonumber(V) or 1 Refresh() end)
    W:Slider("Opacity", "WeatherOpacity", 0, 100, 50, 1, "", function(V) Shared.Opacity = (tonumber(V) or 50) / 100 Refresh() end)
    W:Slider("Spread", "WeatherSpread", 0, 180, 0, 1, "", function(V) Shared.Spread = tonumber(V) or 0 Refresh() end)
    W:Slider("Brightness", "WeatherBright", 0, 5, 1, 0.1, "", function(V) Shared.Brightness = tonumber(V) or 1 Refresh() end)
    W:Slider("Glow", "WeatherGlow", 0, 5, 0, 0.1, "", function(V) Shared.Glow = tonumber(V) or 0 Refresh() end)
end)



local EM = { Slots = 8, Wheel = nil }
do
    local FLAG = "SkinChanger"
    local legacy = "PhantomHub/skinchanger.json"
    local data = { skins = {}, wraps = {}, charms = {}, finisher = nil, emotes = {} }

    local function fromTable(d)
        if type(d) ~= "table" then return end
        data.skins = type(d.skins) == "table" and d.skins or {}
        data.wraps = type(d.wraps) == "table" and d.wraps or {}
        data.charms = type(d.charms) == "table" and d.charms or {}
        data.finisher = type(d.finisher) == "string" and d.finisher or nil
        data.emotes = {}
        if type(d.emotes) == "table" then
            for k, v in pairs(d.emotes) do
                local slot = tonumber(k)
                if slot and type(v) == "string" then data.emotes[slot] = v end
            end
        end
    end

    local function save()
        local out = { skins = data.skins, wraps = data.wraps, charms = data.charms, finisher = data.finisher, emotes = {} }
        for slot, name in pairs(data.emotes) do out.emotes[tostring(slot)] = name end
        Library.Flags[FLAG] = out
        Library.Unsaved = true
    end

    local function loadDisk()
        local d = Library.Flags[FLAG]
        if type(d) ~= "table" and type(isfile) == "function" and type(readfile) == "function" then
            pcall(function()
                if not isfile(legacy) then return end
                d = HttpService:JSONDecode(readfile(legacy))
                if type(delfile) == "function" then pcall(delfile, legacy) end
            end)
        end
        fromTable(d)
    end

    local function apply()
        for weapon, skin in pairs(data.skins) do
            if type(skin) == "string" and skin ~= "" then pcall(SC_ApplySkin, weapon, skin) end
        end
        for weapon, w in pairs(data.wraps) do
            if type(w) == "table" and type(w.name) == "string" and w.name ~= "" then
                pcall(SC_ApplyWrap, weapon, w.name, w.inverted and true or false)
            end
        end
        for weapon, charm in pairs(data.charms) do
            if type(charm) == "string" and charm ~= "" then pcall(SC_Charm.Apply, weapon, charm) end
        end
        if type(data.finisher) == "string" and data.finisher ~= "" then
            pcall(SC_Fin.Apply, data.finisher)
        end
    end

    SC_P = {
        data = data,
        save = save,
        restore = function() loadDisk() pcall(apply) end,
    }
    Library.Signals[FLAG] = function(val)
        if not Config.SC_Enabled then return end
        fromTable(val)
        pcall(apply)
        if EM and EM.Refresh then pcall(EM.Refresh) end
    end
end



;(function()
    local Tween_Service = game:GetService("TweenService")

    local function EM_Theme()
        local T = Library and Library.Theme
        if T then return T end
        return {
            Background = Color3.fromHex("#080505"), Container = Color3.fromHex("#140b0b"),
            Section = Color3.fromHex("#1a0e0e"), Accent = Color3.fromHex("#ff1a1a"),
            Text = Color3.fromHex("#ffffff"), TextDark = Color3.fromHex("#997373"),
            Stroke = Color3.fromHex("#2e1717"),
        }
    end
    local function EM_Font(bold)
        local F = Library and Library.Fonts
        if F then return bold and F.Bold or F.Main end
        return bold and Enum.Font.GothamBold or Enum.Font.GothamMedium
    end

    local Local_Emote = nil
    local Local_Hum = nil

    local function EM_Humanoid()
        local char = Local_Player.Character
        return char and char:FindFirstChildOfClass("Humanoid") or nil
    end

    local function EM_Module(name)
        local folder = RS:FindFirstChild("Modules")
        folder = folder and folder:FindFirstChild("Emotes")
        local mod = folder and folder:FindFirstChild(name)
        if not (mod and mod:IsA("ModuleScript")) then return nil end
        local m = Game_Require(mod)
        if type(m) == "table" and type(m.new) == "function" then return m end
        return nil
    end

    local function EM_Remote(child)
        local r = RS:FindFirstChild("Remotes")
        r = r and r:FindFirstChild("Replication")
        r = r and r:FindFirstChild("Fighter")
        r = r and r:FindFirstChild(child)
        return r and r:IsA("RemoteEvent") and r or nil
    end

    local function EM_IsEmoting(hum)
        local ok, tracks = pcall(hum.GetPlayingAnimationTracks, hum)
        if not ok then return false end
        for _, t in ipairs(tracks) do
            if t.Priority == Enum.AnimationPriority.Action or t.Priority == Enum.AnimationPriority.Action4 then return true end
        end
        return false
    end

    local EM_JUNK = { Decal = true, Texture = true, Sound = true, ParticleEmitter = true, Beam = true, Trail = true,
        PointLight = true, SpotLight = true, SurfaceLight = true, Accessory = true, Model = true, Attachment = true,
        Highlight = true, SurfaceAppearance = true }
    local function EM_Snapshot(char)
        local set = {}
        if char then for _, x in ipairs(char:GetDescendants()) do set[x] = true end end
        return set
    end
    local function EM_CleanNew(char, before)
        if not (char and before) then return end
        pcall(function()
            for _, x in ipairs(char:GetDescendants()) do
                if not before[x] and EM_JUNK[x.ClassName] then x:Destroy() end
            end
        end)
    end

    local EM_IdCache = {}
    local function EM_AnimIds(mod, name)
        if EM_IdCache[name] then return EM_IdCache[name] end
        local ids = {}
        local getc = (debug and debug.getconstants) or getconstants
        if type(getc) == "function" and type(mod.PlayClient) == "function" then
            pcall(function()
                for _, c in ipairs(getc(mod.PlayClient)) do
                    if type(c) == "string" and c:match("^rbxassetid://%d+$") then table.insert(ids, c) end
                end
            end)
        end
        EM_IdCache[name] = ids
        return ids
    end
    local function EM_HasTracks(obj, hum)
        local n = 0
        pcall(function() n = #(obj._animation_tracks or {}) end)
        if n > 0 then return true end
        return EM_IsEmoting(hum)
    end
    -- plays the emote animation straight on the humanoid (fallback when the game module did nothing)
    local function EM_DirectAnim(hum, ids, speed)
        local id = ids[#ids]
        if not id then return nil end
        local anim = Instance.new("Animation")
        anim.AnimationId = id
        local animator = hum:FindFirstChildOfClass("Animator")
        local ok, track = pcall(function()
            return animator and animator:LoadAnimation(anim) or hum:LoadAnimation(anim)
        end)
        if not ok or not track then
            warn("[PH] emote anim load failed: " .. tostring(track))
            return nil
        end
        track.Priority = Enum.AnimationPriority.Action4
        track:Play(0.1)
        track:AdjustSpeed(speed or 1)
        return track
    end

    function EM.List() return SC_CosNames.Emotes or {} end
    function EM.Image(name) return SC_CosNames.Images and SC_CosNames.Images[name] or nil end

    local Local_Track = nil
    local Local_Before = nil
    local function EM_StopLocal()
        if Local_Emote then
            local e = Local_Emote
            Local_Emote = nil
            pcall(function() e:Destroy() end)
        end
        if Local_Track then
            pcall(function() Local_Track:Stop(0.2) Local_Track:Destroy() end)
            Local_Track = nil
        end
        if Local_Hum then
            local hum, before = Local_Hum, Local_Before
            Local_Hum, Local_Before = nil, nil
            pcall(function()
                for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
                    if t.Priority == Enum.AnimationPriority.Action or t.Priority == Enum.AnimationPriority.Action4 then t:Stop(0.2) end
                end
            end)
            task.delay(0.3, function() EM_CleanNew(hum.Parent, before) end)
        end
    end

    function EM.Stop()
        EM_StopLocal()
        local r = EM_Remote("CancelEmoteFromClient")
        if r then pcall(r.FireServer, r) end
    end

    local function EM_PlayLocal(name)
        local hum = EM_Humanoid()
        if not hum then return false, "no character" end
        local m = EM_Module(name)
        if not m then return false, "no emote module" end
        EM_StopLocal()
        local before = EM_Snapshot(hum.Parent)
        local ok, obj = pcall(m.new, hum)
        if not ok or type(obj) ~= "table" then
            warn("[PH] emote new failed: " .. tostring(obj))
            return false, "create failed"
        end
        Local_Emote = obj
        Local_Hum = hum
        Local_Before = before
        local ok2, err = pcall(function() obj:PlayClient(true) end)
        if not ok2 then
            warn("[PH] emote PlayClient failed: " .. tostring(err))
            EM_StopLocal()
            return false, tostring(err)
        end
        local conn
        conn = hum:GetPropertyChangedSignal("MoveDirection"):Connect(function()
            if hum.MoveDirection.Magnitude > 0.1 then
                conn:Disconnect()
                if Local_Emote == obj then EM_StopLocal() end
            end
        end)
        task.spawn(function()
            task.wait(0.5)
            if Local_Emote ~= obj then return end
            if not EM_HasTracks(obj, hum) then
                Local_Track = EM_DirectAnim(hum, EM_AnimIds(m, name), 1)
                if not Local_Track then warn("[PH] emote '" .. name .. "': no animation found") end
            end
            -- auto cleanup once the animation is over
            local idle = 0
            while Local_Emote == obj do
                task.wait(0.25)
                local playing = false
                if Local_Track and Local_Track.IsPlaying then playing = true end
                if not playing then
                    pcall(function()
                        for _, t in ipairs(obj._animation_tracks or {}) do
                            if t.IsPlaying then playing = true end
                        end
                    end)
                end
                if not playing then playing = EM_IsEmoting(hum) end
                if obj._destroyed then playing = false end
                idle = playing and 0 or idle + 1
                if idle >= 2 then
                    if Local_Emote == obj then EM_StopLocal() end
                    break
                end
            end
            pcall(function() conn:Disconnect() end)
        end)
        return true
    end

    function EM.Play(name)
        if not name or name == "" then return false, "no emote" end
        EM_StopLocal()
        local r = EM_Remote("UseEmoteByName")
        local hum = EM_Humanoid()
        if r and hum then
            pcall(r.FireServer, r, name)
            task.delay(0.7, function()
                local h = EM_Humanoid()
                if h == hum and not EM_IsEmoting(h) and not Local_Emote then
                    EM_PlayLocal(name)
                end
            end)
            return true
        end
        return EM_PlayLocal(name)
    end

    function EM.Preview(name)
        if not name or name == "" then return false, "no emote" end
        return EM_PlayLocal(name)
    end

    -- animated dummy preview: EmoteDummy + emote module inside our own ViewportFrame
    local function EM_Dummy()
        local ps = Local_Player:FindFirstChild("PlayerScripts")
        local assets = ps and ps:FindFirstChild("Assets")
        local misc = assets and assets:FindFirstChild("Misc")
        local d = misc and misc:FindFirstChild("EmoteDummy")
        return d and d:IsA("Model") and d or nil
    end
    local function EM_GameCamera()
        local cam = nil
        pcall(function()
            local ps = Local_Player:FindFirstChild("PlayerScripts")
            local mods = ps and ps:FindFirstChild("Modules")
            local m = mods and mods:FindFirstChild("ViewportCameras")
            if m and m:IsA("ModuleScript") then
                local r = Game_Require(m)
                if type(r) == "table" and typeof(r.Emote) == "Instance" and r.Emote:IsA("Camera") then cam = r.Emote end
            end
        end)
        return cam
    end

    -- returns { Destroy = fn } ; renders an animated dummy playing `name` inside `parent`
    function EM.MakeViewport(name, parent, speed)
        if not name or name == "" then return nil end
        local template = EM_Dummy()
        local mod = EM_Module(name)
        if not template or not mod then return nil end
        local VP = Instance.new("ViewportFrame")
        VP.Size = UDim2.new(1, 0, 1, 0)
        VP.BackgroundTransparency = 1
        VP.ImageTransparency = 1
        VP.Ambient = Color3.fromRGB(200, 200, 200)
        VP.LightColor = Color3.fromRGB(255, 255, 255)
        VP.LightDirection = Vector3.new(-1, -1, -1)
        VP.ZIndex = parent.ZIndex + 1
        VP.Parent = parent
        local WM = Instance.new("WorldModel")
        WM.Parent = VP
        local gcam = EM_GameCamera()
        local Cam = gcam and gcam:Clone() or Instance.new("Camera")
        if not gcam then
            Cam.FieldOfView = 40
            Cam.CFrame = CFrame.new(Vector3.new(0, 2.6, -8.5), Vector3.new(0, 2.2, 0))
        end
        Cam.Parent = VP
        VP.CurrentCamera = Cam
        local alive = true
        local dummy, emote = nil, nil
        local function clear()
            if emote then pcall(function() emote:Destroy() end) emote = nil end
            if dummy then pcall(function() dummy:Destroy() end) dummy = nil end
        end
        local function cycle()
            if not alive then return end
            clear()
            local d = template:Clone()
            for _, x in ipairs(d:GetDescendants()) do
                if x:IsA("BaseScript") then x:Destroy() end
            end
            local off = SC_EmoteData[name] and SC_EmoteData[name].ViewportCFrameOffset
            if typeof(off) == "CFrame" then pcall(d.PivotTo, d, off) end
            d.Parent = WM
            dummy = d
            local hum = d:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local ok, e = pcall(mod.new, hum)
            if not ok or type(e) ~= "table" then return end
            emote = e
            task.defer(function()
                local okp, errp = pcall(function() e:PlayClient(true) end)
                if not okp then warn("[PH] emote preview PlayClient failed: " .. tostring(errp)) end
                task.wait(0.5)
                if not alive or emote ~= e then return end
                local track = nil
                if not EM_HasTracks(e, hum) then
                    track = EM_DirectAnim(hum, EM_AnimIds(mod, name), speed)
                elseif speed and speed ~= 1 then
                    pcall(function()
                        for _, t in ipairs(e._animation_tracks or {}) do t:AdjustSpeed(speed) end
                    end)
                end
                local idle = 0
                while alive and emote == e do
                    task.wait(0.3)
                    local playing = track and track.IsPlaying or false
                    if not playing then
                        pcall(function()
                            for _, t in ipairs(e._animation_tracks or {}) do
                                if t.IsPlaying then playing = true end
                            end
                        end)
                    end
                    if e._destroyed then playing = false end
                    idle = playing and 0 or idle + 1
                    if idle >= 2 then
                        if track then pcall(function() track:Destroy() end) end
                        if alive and emote == e then task.delay(0.6, cycle) end
                        break
                    end
                end
            end)
        end
        local tw = Tween_Service:Create(VP, TweenInfo.new(0.35, Enum.EasingStyle.Quad), { ImageTransparency = 0 })
        tw:Play()
        task.spawn(cycle)
        return {
            Destroy = function()
                alive = false
                clear()
                pcall(function() VP:Destroy() end)
            end,
        }
    end

    -- Emote circle ------------------------------------------------------------
    local W = { Open = false, Mode = "play", Hover = nil, Place = nil, Gui = nil, Slots = {}, Consumed = false }
    EM.Wheel = W
    local SLOT_R = 128
    local SLOT_SIZE = 86

    local function W_Tween(o, p, t, style)
        local tw = Tween_Service:Create(o, TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), p)
        tw:Play()
        return tw
    end
    local function W_Corner(p, r)
        local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r) c.Parent = p return c
    end
    local function W_Stroke(p, col, th, tr)
        local s = Instance.new("UIStroke") s.Color = col s.Thickness = th or 1 s.Transparency = tr or 0
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border s.Parent = p return s
    end

    local function W_Build()
        if W.Gui and W.Gui.Parent then return end
        local T = EM_Theme()
        local Parent = (gethui and gethui()) or Local_Player:FindFirstChild("PlayerGui") or Local_Player:WaitForChild("PlayerGui")
        local Gui = Instance.new("ScreenGui")
        Gui.Name = "PhantomEmoteWheel"
        Gui.ResetOnSpawn = false
        Gui.IgnoreGuiInset = true
        Gui.DisplayOrder = 950
        Gui.Enabled = false
        Gui.Parent = Parent
        pcall(function() if syn and syn.protect_gui then syn.protect_gui(Gui) end end)
        W.Gui = Gui

        -- Modal button: Roblox unlocks/shows the cursor while it is visible and
        -- hands control back to the game when the gui is disabled
        local Dim = Instance.new("TextButton")
        Dim.Size = UDim2.new(1, 0, 1, 0)
        Dim.BackgroundColor3 = Color3.new(0, 0, 0)
        Dim.BackgroundTransparency = 1
        Dim.BorderSizePixel = 0
        Dim.Text = ""
        Dim.AutoButtonColor = false
        Dim.Modal = true
        Dim.Parent = Gui
        W.Dim = Dim

        local Root = Instance.new("CanvasGroup")
        Root.AnchorPoint = Vector2.new(0.5, 0.5)
        Root.Position = UDim2.new(0.5, 0, 0.5, 0)
        Root.Size = UDim2.new(0, (SLOT_R + SLOT_SIZE / 2) * 2 + 16, 0, (SLOT_R + SLOT_SIZE / 2) * 2 + 16)
        Root.BackgroundTransparency = 1
        Root.GroupTransparency = 1
        Root.Parent = Gui
        W.Root = Root
        local Scale = Instance.new("UIScale")
        Scale.Scale = 0.7
        Scale.Parent = Root
        W.Scale = Scale

        local Ring = Instance.new("Frame")
        Ring.AnchorPoint = Vector2.new(0.5, 0.5)
        Ring.Position = UDim2.new(0.5, 0, 0.5, 0)
        Ring.Size = UDim2.new(0, SLOT_R * 2, 0, SLOT_R * 2)
        Ring.BackgroundTransparency = 1
        Ring.Parent = Root
        W_Corner(Ring, SLOT_R)
        W.RingStroke = W_Stroke(Ring, T.Stroke, 2, 0.35)

        local Center = Instance.new("Frame")
        Center.AnchorPoint = Vector2.new(0.5, 0.5)
        Center.Position = UDim2.new(0.5, 0, 0.5, 0)
        Center.Size = UDim2.new(0, 104, 0, 104)
        Center.BackgroundColor3 = T.Background
        Center.Parent = Root
        W_Corner(Center, 52)
        W.CenterStroke = W_Stroke(Center, T.Accent, 2, 0.2)
        local CTitle = Instance.new("TextLabel")
        CTitle.Size = UDim2.new(1, -10, 0, 14)
        CTitle.Position = UDim2.new(0, 5, 0, 30)
        CTitle.BackgroundTransparency = 1
        CTitle.Text = "EMOTES"
        CTitle.TextColor3 = T.TextDark
        CTitle.TextSize = 10
        CTitle.Font = EM_Font(true)
        CTitle.Parent = Center
        W.CTitle = CTitle
        local CName = Instance.new("TextLabel")
        CName.Size = UDim2.new(1, -12, 0, 34)
        CName.Position = UDim2.new(0, 6, 0, 44)
        CName.BackgroundTransparency = 1
        CName.Text = "Select"
        CName.TextColor3 = T.Text
        CName.TextSize = 12
        CName.TextWrapped = true
        CName.Font = EM_Font(true)
        CName.Parent = Center
        W.CName = CName

        W.Slots = {}
        for i = 1, EM.Slots do
            local ang = (i - 1) / EM.Slots * math.pi * 2 - math.pi / 2
            local S = Instance.new("TextButton")
            S.AnchorPoint = Vector2.new(0.5, 0.5)
            S.Position = UDim2.new(0.5, math.cos(ang) * SLOT_R, 0.5, math.sin(ang) * SLOT_R)
            S.Size = UDim2.new(0, SLOT_SIZE, 0, SLOT_SIZE)
            S.BackgroundColor3 = T.Container
            S.Text = ""
            S.AutoButtonColor = false
            S.Parent = Root
            W_Corner(S, SLOT_SIZE / 2)
            local st = W_Stroke(S, T.Stroke, 1.5, 0.2)
            local sc = Instance.new("UIScale") sc.Scale = 1 sc.Parent = S
            local Img = Instance.new("ImageLabel")
            Img.AnchorPoint = Vector2.new(0.5, 0.5)
            Img.Position = UDim2.new(0.5, 0, 0.5, -6)
            Img.Size = UDim2.new(0, 44, 0, 44)
            Img.BackgroundTransparency = 1
            Img.ScaleType = Enum.ScaleType.Fit
            Img.Image = ""
            Img.Parent = S
            local VPH = Instance.new("Frame")
            VPH.AnchorPoint = Vector2.new(0.5, 0.5)
            VPH.Position = UDim2.new(0.5, 0, 0.5, -6)
            VPH.Size = UDim2.new(1, -10, 1, -22)
            VPH.BackgroundTransparency = 1
            VPH.ClipsDescendants = true
            VPH.Parent = S
            local Lbl = Instance.new("TextLabel")
            Lbl.Size = UDim2.new(1, -8, 0, 14)
            Lbl.Position = UDim2.new(0, 4, 1, -20)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = tostring(i)
            Lbl.TextColor3 = T.TextDark
            Lbl.TextSize = 10
            Lbl.Font = EM_Font(true)
            Lbl.TextTruncate = Enum.TextTruncate.AtEnd
            Lbl.Parent = S
            local Num = Instance.new("TextLabel")
            Num.Size = UDim2.new(0, 16, 0, 12)
            Num.Position = UDim2.new(0.5, -8, 0, 6)
            Num.BackgroundTransparency = 1
            Num.Text = tostring(i)
            Num.TextColor3 = T.TextDark
            Num.TextSize = 9
            Num.Font = EM_Font(false)
            Num.Parent = S
            W.Slots[i] = { Btn = S, Stroke = st, Scale = sc, Img = Img, VPH = VPH, Lbl = Lbl, Num = Num, VP = nil, VPName = nil }
            S.MouseButton1Click:Connect(function() EM.Choose(i) end)
            S.MouseEnter:Connect(function() W.HoverBtn = i end)
            S.MouseLeave:Connect(function() if W.HoverBtn == i then W.HoverBtn = nil end end)
        end
    end

    local function W_SlotPreview(s, name)
        if s.VPName == name and (s.VP ~= nil or name == nil) then return end
        if s.VP then s.VP:Destroy() s.VP = nil end
        s.VPName = name
        if name and W.Gui and W.Gui.Enabled then
            s.VP = EM.MakeViewport(name, s.VPH, 1.5)
        end
        s.Img.Visible = (name ~= nil) and (s.VP == nil) and (s.Img.Image ~= "")
    end

    local function W_Refresh()
        if not W.Gui then return end
        local T = EM_Theme()
        local slots = SC_P and SC_P.data.emotes or {}
        for i, s in ipairs(W.Slots) do
            local name = slots[i]
            if name then
                local img = EM.Image(name)
                s.Img.Image = img or ""
                s.Lbl.Text = name
                s.Lbl.Position = UDim2.new(0, 4, 1, -20)
                s.Lbl.TextColor3 = T.Text
                s.Num.Visible = true
                W_SlotPreview(s, name)
            else
                s.Img.Image = ""
                s.Lbl.Text = "EMPTY"
                s.Lbl.Position = UDim2.new(0, 4, 0.5, -7)
                s.Lbl.TextColor3 = T.TextDark
                s.Num.Visible = false
                W_SlotPreview(s, nil)
            end
        end
    end
    local function W_DropPreviews()
        for _, s in ipairs(W.Slots) do
            if s.VP then s.VP:Destroy() s.VP = nil end
            s.VPName = nil
        end
    end
    EM.Refresh = W_Refresh

    local function W_SetHover(i)
        if W.Hover == i then return end
        local T = EM_Theme()
        local old = W.Hover and W.Slots[W.Hover]
        if old then
            W_Tween(old.Scale, { Scale = 1 }, 0.15)
            W_Tween(old.Stroke, { Color = T.Stroke, Transparency = 0.2 }, 0.15)
            W_Tween(old.Btn, { BackgroundColor3 = T.Container }, 0.15)
        end
        W.Hover = i
        local s = i and W.Slots[i]
        if s then
            W_Tween(s.Scale, { Scale = 1.1 }, 0.18, Enum.EasingStyle.Quint)
            W_Tween(s.Stroke, { Color = T.Accent, Transparency = 0 }, 0.18)
            W_Tween(s.Btn, { BackgroundColor3 = T.Section }, 0.18)
            local name = SC_P and SC_P.data.emotes[i]
            W.CName.Text = name or ("Slot " .. i)
            W.CName.TextColor3 = name and T.Text or T.TextDark
        else
            W.CName.Text = W.Mode == "place" and (W.Place or "") or "Select"
            W.CName.TextColor3 = W.Mode == "place" and T.Text or T.TextDark
        end
    end

    local Step_Conn = nil
    local Close_Token = 0

    local function W_Show(mode, placeName)
        W_Build()
        Close_Token = Close_Token + 1
        W.Gui.Enabled = true
        W_Refresh()
        local T = EM_Theme()
        W.Mode = mode
        W.Place = placeName
        W.Hover = nil
        W.CTitle.Text = mode == "place" and "PLACE INTO SLOT" or "EMOTES"
        W.CName.Text = mode == "place" and (placeName or "") or "Select"
        W.CName.TextColor3 = mode == "place" and T.Text or T.TextDark
        W.CenterStroke.Color = mode == "place" and T.Text or T.Accent
        for _, s in ipairs(W.Slots) do
            s.Scale.Scale = 1
            s.Stroke.Color = T.Stroke
            s.Stroke.Transparency = 0.2
            s.Btn.BackgroundColor3 = T.Container
            s.Btn.BackgroundTransparency = 0
            s.Btn.Visible = true
        end
        if W.Open then return end
        W.Open = true
        W.PrevMouse = User_Input_Service.MouseBehavior
        W.Dim.Modal = true
        W.Dim.Active = true
        W.Scale.Scale = 0.82
        W.Root.Visible = true
        W.Root.GroupTransparency = 1
        W_Tween(W.Scale, { Scale = 1 }, 0.28, Enum.EasingStyle.Quint)
        W_Tween(W.Root, { GroupTransparency = 0 }, 0.2, Enum.EasingStyle.Quad)
        W_Tween(W.Dim, { BackgroundTransparency = 0.45 }, 0.25, Enum.EasingStyle.Quad)
        if Step_Conn then Step_Conn:Disconnect() end
        Step_Conn = Run_Service.RenderStepped:Connect(function()
            if not W.Open then return end
            local mp = User_Input_Service:GetMouseLocation()
            local c = W.Root.AbsolutePosition + W.Root.AbsoluteSize / 2
            local d = mp - c
            local dist = d.Magnitude
            local hover = W.HoverBtn
            if not hover and dist > 52 * W.Scale.Scale then
                local ang = math.atan2(d.Y, d.X) + math.pi / 2
                local idx = math.floor((ang / (math.pi * 2)) * EM.Slots + 0.5) % EM.Slots + 1
                hover = idx
            end
            W_SetHover(hover)
        end)
    end

    local function W_Hide(flash)
        if not W.Open then return end
        W.Open = false
        Close_Token = Close_Token + 1
        local token = Close_Token
        if Step_Conn then Step_Conn:Disconnect() Step_Conn = nil end
        -- release the cursor lock right away so the game camera regains control
        W.Dim.Modal = false
        W.Dim.Active = false
        local prev = W.PrevMouse
        W.PrevMouse = nil
        task.defer(function()
            pcall(function()
                if prev and prev ~= Enum.MouseBehavior.Default then
                    User_Input_Service.MouseBehavior = prev
                else
                    local cam = workspace.CurrentCamera
                    local char = Local_Player.Character
                    local head = char and char:FindFirstChild("Head")
                    if cam and head and (cam.CFrame.Position - head.Position).Magnitude < 1.5 then
                        User_Input_Service.MouseBehavior = Enum.MouseBehavior.LockCenter
                    end
                end
            end)
        end)
        local T = EM_Theme()
        local dur = 0.18
        if flash and W.Slots[flash] then
            local s = W.Slots[flash]
            W_Tween(s.Btn, { BackgroundColor3 = T.Accent }, 0.1)
            W_Tween(s.Stroke, { Color = T.Accent, Transparency = 0 }, 0.1)
            W_Tween(s.Scale, { Scale = 1.22 }, 0.26, Enum.EasingStyle.Quad)
            dur = 0.26
        end
        W_Tween(W.Dim, { BackgroundTransparency = 1 }, dur, Enum.EasingStyle.Quad)
        W_Tween(W.Root, { GroupTransparency = 1 }, dur, Enum.EasingStyle.Quad)
        W_Tween(W.Scale, { Scale = flash and 1.05 or 0.9 }, dur, Enum.EasingStyle.Quad)
        task.delay(dur + 0.03, function()
            if Close_Token ~= token or W.Open then return end
            W.Gui.Enabled = false
            W.Hover = nil
            W.HoverBtn = nil
            W_DropPreviews()
        end)
    end
    EM.Hide = W_Hide

    function EM.Choose(i)
        if not W.Open then return end
        local slots = SC_P and SC_P.data.emotes
        if not slots then return end
        if W.Mode == "place" then
            slots[i] = W.Place
            SC_P.save()
            W_Refresh()
            pcall(function() Library:Notify("EMOTES", tostring(W.Place) .. " → slot " .. i, 2) end)
            W_Hide(i)
            return
        end
        local name = slots[i]
        if not name then return end
        W.Consumed = true
        W_Hide(i)
        local ok, err = EM.Play(name)
        if not ok then pcall(function() Library:Notify("EMOTES", "Failed: " .. tostring(err), 3) end) end
    end

    local Place_Token = 0
    function EM.BeginPlace(name)
        Place_Token = Place_Token + 1
        local token = Place_Token
        W_Show("place", name)
        task.delay(6, function()
            if token == Place_Token and W.Open and W.Mode == "place" then W_Hide() end
        end)
    end

    function EM.HoldChanged(down)
        if down then
            if not Config.Emote_Wheel_Enabled then return end
            W.Consumed = false
            if W.Open and W.Mode == "place" then return end
            W_Show("play")
        else
            if W.Open and W.Mode == "play" then W_Hide() end
        end
    end

    -- click anywhere on the wheel (mouse/touch) selects the hovered slot
    User_Input_Service.InputBegan:Connect(function(input, gp)
        if not W.Open then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if W.HoverBtn then return end
            if W.Hover then EM.Choose(W.Hover) end
        end
    end)
end)()

if Skins_Tab then
    local SC_Browser = nil
    local skinOk, skinErr = pcall(function()
        local SC_Section = Skins_Tab:Section("Skin Changer", "Left")
        pcall(function()
            local container = SC_Section.Container
            local parentCol = container and container.Parent
            if parentCol then
                parentCol.Size = UDim2.new(1, 0, 0, 0)
            end
        end)
        SC_Browser = SC_Section:SkinBrowser({
            weapons = {},
            subTabs = Is_Weak and {"Skins"} or {"Skins", "Wraps", "Charms", "Finishers", "Emotes"},
            getSkins = function(weaponName)
                return SC_WeaponSkins[weaponName] or {}
            end,
            getModel = function(skinName)
                local folder = SC_SkinLookup[skinName]
                if not folder then return nil end
                return folder:FindFirstChild(skinName)
            end,
            onEquip = function(weaponName, skinName)
                if not Config.SC_Enabled then
                    Library:Notify("SKINS", "Not initialized yet", 3)
                    return false
                end
                if skinName == weaponName then
                    pcall(SC_ApplySkin, weaponName, weaponName)
                    SC_P.data.skins[weaponName] = nil
                    SC_P.save()
                    Library:Notify("SKINS", weaponName .. " restored to default", 3)
                    return true
                end
                local ok, err = SC_ApplySkin(weaponName, skinName)
                if ok then
                    SC_P.data.skins[weaponName] = skinName
                    SC_P.save()
                    Library:Notify("SKINS", weaponName .. " → " .. skinName, 3)
                else
                    Library:Notify("SKINS", "Failed: " .. tostring(skinName) .. " (" .. tostring(err) .. ")", 3)
                end
                return ok
            end,
            onRestore = function()
                if not Config.SC_Enabled then return end
                pcall(SC_RestoreAll)
                SC_P.data.skins = {}
                SC_P.save()
                Library:Notify("SKINS", "All skins restored", 3)
            end,
            tabs = {
                Wraps = {
                    weapons = {},
                    itemHeader = "WRAP",
                    equipText = "EQUIP WRAP",
                    invertedToggle = true,
                    getItems = function()
                        return SC_CosNames.Wraps or {}
                    end,
                    getModel = function() return nil end,
                    onEquip = function(weaponName, wrapName, inverted)
                        if not Config.SC_Enabled then
                            Library:Notify("WRAPS", "Not initialized yet", 3)
                            return false
                        end
                        local okCall, ok, err = pcall(SC_ApplyWrap, weaponName, wrapName, inverted and true or false)
                        if not okCall then ok, err = false, ok end
                        pcall(function()
                            Library:Notify("WRAPS", ok and (tostring(weaponName) .. " → " .. tostring(wrapName)) or ("Failed: " .. tostring(err)), 3)
                        end)
                        if ok then
                            pcall(function()
                                if not wrapName or wrapName == "None" or wrapName == "" then
                                    SC_P.data.wraps[weaponName] = nil
                                else
                                    SC_P.data.wraps[weaponName] = { name = wrapName, inverted = inverted and true or false }
                                end
                                SC_P.save()
                            end)
                        end
                        return ok
                    end,
                    onRestore = function()
                        if not Config.SC_Enabled then return end
                        pcall(SC_ResetWraps)
                        SC_P.data.wraps = {}
                        SC_P.save()
                        Library:Notify("WRAPS", "All wraps removed", 3)
                    end,
                },
                Charms = {
                    weapons = {},
                    itemHeader = "CHARM",
                    equipText = "EQUIP CHARM",
                    getItems = function()
                        return SC_CosNames.Charms or {}
                    end,
                    getModel = function(charmName)
                        return SC_Charm.GetPreview(charmName)
                    end,
                    onEquip = function(weaponName, charmName)
                        if not Config.SC_Enabled then
                            Library:Notify("CHARMS", "Not initialized yet", 3)
                            return false
                        end
                        local ok, err = SC_Charm.Apply(weaponName, charmName)
                        if ok then
                            if not charmName or charmName == "None" or charmName == "" then
                                SC_P.data.charms[weaponName] = nil
                            else
                                SC_P.data.charms[weaponName] = charmName
                            end
                            SC_P.save()
                        end
                        Library:Notify("CHARMS", ok and (weaponName .. " → " .. tostring(charmName)) or ("Failed: " .. tostring(err)), 3)
                        return ok
                    end,
                    onRestore = function()
                        if not Config.SC_Enabled then return end
                        pcall(SC_Charm.Reset)
                        SC_P.data.charms = {}
                        SC_P.save()
                        Library:Notify("CHARMS", "All charms removed", 3)
                    end,
                },
                Finishers = {
                    noWeapons = true,
                    itemHeader = "FINISHER",
                    equipText = "EQUIP FINISHER",
                    getItems = function()
                        return SC_CosNames.Finishers or {}
                    end,
                    getImage = function(name)
                        return SC_CosNames.Images and SC_CosNames.Images[name] or nil
                    end,
                    onEquip = function(_, finisherName)
                        if not Config.SC_Enabled then
                            Library:Notify("FINISHERS", "Not initialized yet", 3)
                            return false
                        end
                        local ok, err = SC_Fin.Apply(finisherName)
                        if ok then
                            if not finisherName or finisherName == "None" or finisherName == "" then
                                SC_P.data.finisher = nil
                            else
                                SC_P.data.finisher = finisherName
                            end
                            SC_P.save()
                        end
                        Library:Notify("FINISHERS", ok and ("Finisher → " .. tostring(finisherName)) or ("Failed: " .. tostring(err)), 3)
                        return ok
                    end,
                    onRestore = function()
                        if not Config.SC_Enabled then return end
                        pcall(SC_Fin.Reset)
                        SC_P.data.finisher = nil
                        SC_P.save()
                        Library:Notify("FINISHERS", "Finisher reset to default", 3)
                    end,
                },
                Emotes = {
                    noWeapons = true,
                    noPreview = true,
                    itemHeader = "EMOTE",
                    equipText = "EQUIP EMOTE",
                    getItems = function()
                        return EM.List()
                    end,
                    getImage = function(name) return EM.Image(name) end,
                    onSelect = function(_, emoteName)
                        EM.Selected = emoteName
                        if EM.ShowTabPreview then EM.ShowTabPreview(emoteName) end
                    end,
                    onEquip = function(_, emoteName)
                        if not emoteName or emoteName == "" then
                            Library:Notify("EMOTES", "Select an emote first", 3)
                            return false
                        end
                        EM.BeginPlace(emoteName)
                        return true
                    end,
                    onRestore = function()
                        EM.Stop()
                        for i = 1, EM.Slots do SC_P.data.emotes[i] = nil end
                        SC_P.save()
                        EM.Refresh()
                        Library:Notify("EMOTES", "All emote slots cleared", 3)
                    end,
                },
            },
        })
        local host = SC_Browser.GetHost and SC_Browser:GetHost("Emotes")
        if host then
            local T = Library.Theme or {}
            local PV = Instance.new("Frame")
            PV.Size = UDim2.new(1, 0, 0, 200)
            PV.BackgroundColor3 = T.Container or Color3.fromRGB(20, 20, 24)
            PV.BorderSizePixel = 0
            PV.LayoutOrder = 0
            PV.ClipsDescendants = true
            PV.Parent = host
            local pvc = Instance.new("UICorner") pvc.CornerRadius = UDim.new(0, 6) pvc.Parent = PV
            local pvs = Instance.new("UIStroke") pvs.Color = T.Stroke or Color3.fromRGB(40, 40, 46) pvs.Thickness = 1 pvs.Parent = PV
            local PVName = Instance.new("TextLabel")
            PVName.Size = UDim2.new(1, -12, 0, 16)
            PVName.Position = UDim2.new(0, 6, 1, -20)
            PVName.BackgroundTransparency = 1
            PVName.Text = "Select an emote"
            PVName.TextColor3 = T.TextDark or Color3.fromRGB(150, 150, 150)
            PVName.TextSize = 11
            PVName.Font = (Library.Fonts and Library.Fonts.Bold) or Enum.Font.GothamBold
            PVName.TextXAlignment = Enum.TextXAlignment.Left
            PVName.ZIndex = 5
            PVName.Parent = PV
            local PVHost = Instance.new("Frame")
            PVHost.Size = UDim2.new(1, 0, 1, -22)
            PVHost.BackgroundTransparency = 1
            PVHost.Parent = PV
            local curVP = nil
            EM.ShowTabPreview = function(name)
                if curVP then curVP:Destroy() curVP = nil end
                PVName.Text = name or "Select an emote"
                PVName.TextColor3 = name and (T.Text or Color3.new(1, 1, 1)) or (T.TextDark or Color3.fromRGB(150, 150, 150))
                if name then curVP = EM.MakeViewport(name, PVHost, 1) end
            end

            local EW = Skins_Tab:Section("Emote Circle", "Right")
            EW.Container.Parent = host
            EW.Container.LayoutOrder = 1
            EW:Toggle("Enable Emote Circle", "EmoteWheel", true, "Hold the bind to open the emote circle", function(V)
                Config.Emote_Wheel_Enabled = V
                if not V then EM.Hide() end
            end)
            EW:Keybind("Circle Key", "EmoteWheelKey", Enum.KeyCode.B, "Hold", "Hold to show the circle, click an emote to play it", function(S) EM.HoldChanged(S) end)
            EW:Button("Play On Me", "Plays the selected emote on your character (local preview)", function()
                local ok, err = EM.Preview(EM.Selected)
                if not ok then Library:Notify("EMOTES", "Preview failed: " .. tostring(err), 3) end
            end)
            EW:Button("Stop Emote", "Stops the emote currently playing on you", function() EM.Stop() end)
        end
    end)
    if not skinOk then
        pcall(function() Library:Notify("SKINS", "UI Error: " .. tostring(skinErr), 5) end)
    end

    task.spawn(function()
        task.wait(1)
        local initOk, initErr = pcall(function()
            if not SC_Init() then return end
            pcall(SC_SetupSkinSounds)
            Config.SC_Enabled = true
            local AllWeapons = {}
            if SC_ItemLib then
                for class, weapons in pairs(SC_WeaponsByClass) do
                    for _, wName in ipairs(weapons) do
                        if SC_WeaponSkins[wName] and #SC_WeaponSkins[wName] > 1 then
                            AllWeapons[#AllWeapons + 1] = wName
                        end
                    end
                end
            else
                for wName, skins in pairs(SC_WeaponSkins) do
                    if #skins > 1 then AllWeapons[#AllWeapons + 1] = wName end
                end
            end
            table.sort(AllWeapons)
            if SC_Browser and SC_Browser.SetWeapons then
                SC_Browser:SetWeapons(AllWeapons)
            end

            SC_AllWeaponNames = {}
            if SC_WeaponsFolder then
                for _, m in ipairs(SC_WeaponsFolder:GetChildren()) do
                    if m:IsA("Model") then SC_AllWeaponNames[#SC_AllWeaponNames + 1] = m.Name end
                end
            end
            table.sort(SC_AllWeaponNames)
            if SC_Browser and SC_Browser.SetWeapons and #SC_AllWeaponNames > 0 then
                pcall(function() SC_Browser:SetWeapons(SC_AllWeaponNames, "Wraps") end)
                pcall(function() SC_Browser:SetWeapons(SC_AllWeaponNames, "Charms") end)
            end

            pcall(function() SC_P.restore() end)
            pcall(function() if SC_Browser and SC_Browser.Refresh then SC_Browser:Refresh("Emotes") end end)
            pcall(EM.Refresh)
        end)
        if not initOk then
            pcall(function() Library:Notify("SKINS", "Error: " .. tostring(initErr), 5) end)
        end
    end)
end

if not Is_Restricted then
    local Sec

    Sec = Rage_Tab:Section("Aimbot", "Left")
    Sec:Toggle("Enabled", "RageEnabled", false, "Master rage aimbot switch", function(V) Config.Rage_Enabled = V end)
    Sec:Toggle("Auto Shoot", "RageAutoShoot", false, "Fire automatically at the target", function(V) Config.Rage_Auto_Shoot = V end)
    Sec:Toggle("Auto Reload", "RageAutoReload", false, "Reload when the mag is empty", function(V) Config.Rage_Auto_Reload = V end)
    Sec:Toggle("Visible Check", "RageVisChk", true, "Only target visible enemies", function(V) Config.Rage_Visible_Check = V end)
    Sec:Slider("Field of View", "RageFOV", 1, 360, 360, 1, "", function(V) Config.Rage_Fov = tonumber(V) or 360 end)
    Sec:Dropdown("Hitbox", "RageHitbox", Assets.AimPartOptions, "Head", "", function(V) Config.Rage_Hitbox = V end, nil, false)
    Sec:Dropdown("Target Selection", "RageSelection", {"Distance", "FOV", "Health"}, "FOV", "", function(V) Config.Rage_Selection = V end, nil, false)

    Sec = Rage_Tab:Section("Prediction", "Left")
    Sec:Toggle("Force Prediction", "RageForcePred", false, "Always apply prediction", function(V) Config.Rage_Force_Pred = V end)
    Sec:Slider("Prediction", "RagePredAmt", 1, 50, 10, 1, "", function(V) Config.Rage_Pred_Amt = (tonumber(V) or 10) / 10 end)
    Sec:Dropdown("Resolver", "RageResolver", {"None", "Zero Velocity", "Desync Resolver"}, "None", "", function(V) Config.Rage_Resolver = V end, nil, false)

    Sec = Rage_Tab:Section("Anti-Aim", "Right")
    Sec:Toggle("Enabled", "RageAAEnabled", false, "", function(V) Config.Rage_Aa_Enabled = V end)
    Sec:Dropdown("Yaw", "RageAAYaw", {"None", "Spin", "Jitter", "Backward", "Sideways"}, "None", "", function(V) Config.Rage_Aa_Yaw = V end, nil, false)
    Sec:Dropdown("Pitch", "RageAAPitch", {"None", "Down", "Up", "Jitter"}, "None", "", function(V) Config.Rage_Aa_Pitch = V end, nil, false)
    Sec:Toggle("Pause While Aiming", "RageAAPause", true, "Stops Anti-Aim while aimbot or silent aim is locking a target", function(V) Config.Rage_Aa_Aim_Pause = V end)
    Sec:Toggle("Revert Position", "RageRevert", false, "", function(V) Config.Rage_Revert = V end)

    Sec = Rage_Tab:Section("Weapon", "Right")
    Sec:Slider("Seed Spread", "RageSpread", 0, 100, 0, 1, "", function(V) Config.Rage_Seed_Spread = tonumber(V) or 0 end)
    Sec:Slider("Fire Rate", "RageFireRate", 0, 1, 0.01, 0.01, "", function(V) Config.Rage_Fire_Rate = tonumber(V) or 0.01 end)
    Sec:Toggle("Check Shield", "RageChkShield", false, "Skip shielded targets when auto shooting", function(V) Config.Auto_Shoot_Shield_Check = V end)
    Sec:Toggle("Projectile TP", "RageProjTP", false, "Teleport projectiles onto the target", function(V) Config.Rage_Projectile_TP = V end)
end

if Has_Hook then
    local Namecall_Hook
    Namecall_Hook = hookmetamethod(game, "__namecall", LPH_NO_VIRTUALIZE(function(Self, ...)
        if checkcaller() then return Namecall_Hook(Self, ...) end
        local Method = getnamecallmethod()
        if Method == "Kick" then return nil end
        if Method == "Teleport" or Method == "TeleportToPlaceInstance" then return nil end
        if Method == "Ban" or Method == "ban" then return nil end
        if Method == "WaitForChild" and Config.SC_Enabled and next(SC_ActiveSkins) ~= nil and typeof(Self) == "Instance" then
            local childName = ...
            if type(childName) == "string" and not Self:FindFirstChild(childName) then
                local a = Self
                local inVM = false
                for _ = 1, 12 do
                    a = a.Parent
                    if not a then break end
                    if a.Name == "ViewModels" and a.Parent and a.Parent.Name == "Temp" then inVM = true break end
                end
                if inVM then pcall(SC_Helpers.EnsureChild, Self, childName) end
            end
            -- nested :IsA()/:FindFirstChild() above clobber the pending namecall method
            if setnamecallmethod then pcall(setnamecallmethod, Method) end
            return Namecall_Hook(Self, ...)
        end

        if Self == Workspace and (Config.Rage_Enabled or Config.Sa_Enabled) then
            local Use_Proj_Tp = (Config.Rage_Enabled and Config.Rage_Projectile_TP) or (not Config.Rage_Enabled and Config.Sa_Enabled and Config.Projectile_TP)

            local TPos = Data.Sa_Target_Pos
            if Data.Sa_Use_Live and Data.Sa_Target_Part and Data.Sa_Target_Part.Parent then
                TPos = Data.Sa_Target_Part.Position
            end
            if not TPos then return Namecall_Hook(Self, ...) end

            local Chance = Config.Rage_Enabled and 100 or Config.Sa_Hit_Chance
            local NowT = Tick()
            if (NowT - (Data.Sa_Roll_Time or 0)) > 0.06 then
                Data.Sa_Roll_Time = NowT
                Data.Sa_Roll_Hit = (Math_Random(1, 100) <= Chance)
            end
            local Hit = Data.Sa_Roll_Hit
            local Shift_Origin = Use_Proj_Tp
            if Method == "Raycast" then
                local A1, A2, A3 = ...
                if typeof(A1) == "Vector3" and typeof(A2) == "Vector3" and A2.Magnitude > 15 then
                    if Hit then
                        local Dir = (TPos - A1).Unit
                        if Shift_Origin then
                            A1 = TPos - (Dir * 1.5)
                        end
                        A2 = Dir * 5000
                        return Namecall_Hook(Self, A1, A2, A3)
                    end
                end
            elseif Method == "Spherecast" then
                local A1, A2, A3, A4 = ...
                if typeof(A1) == "Vector3" and typeof(A3) == "Vector3" and A3.Magnitude > 15 then
                    if Hit then
                        local Dir = (TPos - A1).Unit
                        if Shift_Origin then
                            A1 = TPos - (Dir * 1.5)
                        end
                        A3 = Dir * 5000
                        return Namecall_Hook(Self, A1, A2, A3, A4)
                    end
                end
            elseif Method == "Blockcast" then
                local A1, A2, A3, A4 = ...
                if typeof(A1) == "CFrame" and typeof(A3) == "Vector3" and A3.Magnitude > 15 then
                    if Hit then
                        local Dir = (TPos - A1.Position).Unit
                        if Shift_Origin then
                            A1 = Cframe_New(TPos - (Dir * 1.5))
                        end
                        A3 = Dir * 5000
                        return Namecall_Hook(Self, A1, A2, A3, A4)
                    end
                end
            elseif Method == "FindPartOnRay" or Method == "FindPartOnRayWithIgnoreList" or Method == "FindPartOnRayWithWhitelist" then
                local A1, A2, A3, A4 = ...
                if typeof(A1) == "Ray" and A1.Direction.Magnitude > 15 then
                    if Hit then
                        local Dir = (TPos - A1.Origin).Unit
                        local Origin = A1.Origin
                        if Shift_Origin then
                            Origin = TPos - (Dir * 1.5)
                        end
                        A1 = Ray_New(Origin, Dir * 5000)
                        return Namecall_Hook(Self, A1, A2, A3, A4)
                    end
                end
            end
        end
        return Namecall_Hook(Self, ...)
    end))

    local OldNewIndex
    OldNewIndex = hookmetamethod(game, "__newindex", LPH_NO_VIRTUALIZE(function(t, k, v)
        if not checkcaller() then
            if t:IsA("Humanoid") then
                if k == "WalkSpeed" and Config.Ws_Enabled then return end
                if k == "JumpPower" and Config.Jp_Enabled then return end
            end
        end
        return OldNewIndex(t, k, v)
    end))
end


Safe(function()
    if hookfunction then
        local TS = game:GetService("TeleportService")
        pcall(function()
            local origTeleport = TS.Teleport
            hookfunction(origTeleport, function(...)
                return nil
            end)
        end)
        pcall(function()
            local origTPI = TS.TeleportToPlaceInstance
            hookfunction(origTPI, function(...)
                return nil
            end)
        end)
    end
end)

Safe(function()
    if hookfunction then
        pcall(function()
            local Old = Local_Player.Kick
            if type(Old) == "function" then
                hookfunction(Old, function() return nil end)
            end
        end)
    end
end)

Safe(function()
    local VIM = game:GetService("VirtualInputManager")
    task.spawn(function()
        while task.wait(60) do
            pcall(function()
                VIM:SendKeyEvent(true, Enum.KeyCode.F13, false, game)
                VIM:SendKeyEvent(false, Enum.KeyCode.F13, false, game)
            end)
        end
    end)
end)

Safe(function()
    if gethiddenproperty and sethiddenproperty then
        task.spawn(function()
            task.wait(3)
            local pg = Local_Player:FindFirstChildOfClass("PlayerGui")
            if pg then
                for _, gui in ipairs(pg:GetChildren()) do
                    if gui:IsA("ScreenGui") and (gui.Name:find("PH_") or gui.Name:find("Phantom")) then
                        pcall(sethiddenproperty, gui, "OnTopOfCoreBlur", true)
                    end
                end
            end
        end)
    end
end)

Safe(function()
    if Has_Hook and getconnections then
        task.spawn(function()
            task.wait(2)
            pcall(function()
                local ScriptContext = game:GetService("ScriptContext")
                local conns = getconnections(ScriptContext.Error)
                for _, conn in ipairs(conns) do
                    if not conn.Function or not checkcaller() then
                        pcall(function() conn:Disable() end)
                    end
                end
            end)
        end)
    end
end)

Safe(function()
    task.spawn(function()
        while task.wait(3) do
            pcall(function()
                local char = Local_Player.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp.AssemblyLinearVelocity.Magnitude > 500 then
                        hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity.Unit * 100
                    end
                end
            end)
        end
    end)
end)

Safe(function()
    if getconnections then
        task.spawn(function()
            task.wait(5)
            pcall(function()
                local step_conns = getconnections(Run_Service.Heartbeat)
                for _, conn in ipairs(step_conns) do
                    pcall(function()
                        local info = getinfo and getinfo(conn.Function)
                        if info and info.source and (info.source:find("anticheat") or info.source:find("security") or info.source:find("monitor")) then
                            conn:Disable()
                        end
                    end)
                end
            end)
        end)
    end
end)

local function Safe_Set(Table, Key, Value)
    if rawget(Table, Key) ~= Value then
        rawset(Table, Key, Value)
    end
end

if Has_Getgc then
    task.spawn(LPH_NO_VIRTUALIZE(function()
        local scanCount = 0
        local configsFound = 0
        while true do
            local anyActive = Config.No_Recoil or Config.No_Spread or Config.Rapid_Fire or Config.Rage_Enabled or Config.No_Bullet_Waste or Config.No_Melee_Cooldown or Config.Instant_Grenade or Config.Instant_Scope or Config.No_Flashbang
            if scanCount < 1 then
                task.wait(4)
            elseif anyActive then
                task.wait(configsFound > 0 and 30 or 8)
            else
                task.wait(60)
            end
            scanCount = scanCount + 1

            anyActive = Config.No_Recoil or Config.No_Spread or Config.Rapid_Fire or Config.Rage_Enabled or Config.No_Bullet_Waste or Config.No_Melee_Cooldown or Config.Instant_Grenade or Config.Instant_Scope or Config.No_Flashbang
            if not anyActive and configsFound > 0 then continue end

            local S, Gc = pcall(getgc, true)
            if not S then continue end
            local P = 0
            for I = 1, #Gc do
                local V = Gc[I]
                if type(V) == "table" and not Weapon_Configs[V] then
                    if rawget(V, "ShootCooldown") ~= nil or rawget(V, "ShootRecoil") ~= nil or rawget(V, "CameraKick") ~= nil or rawget(V, "AimRecoil") ~= nil or rawget(V, "FireRate") ~= nil or rawget(V, "AutoFire") ~= nil or rawget(V, "AttackCooldown") ~= nil or rawget(V, "DetonateDelay") ~= nil or rawget(V, "AimSpeed") ~= nil or rawget(V, "Cooldown") ~= nil then
                        if setreadonly then pcall(setreadonly, V, false) end
                        local C = { _RecoilKeys = {}, _SpreadKeys = {} }
                        for K, Cv in pairs(V) do
                            C[K] = Cv
                            if type(K) == "string" then
                                local Kl = K:lower()
                                if Kl:find("recoil") or Kl:find("kick") then
                                    C._RecoilKeys[#C._RecoilKeys + 1] = K
                                elseif Kl:find("spread") then
                                    C._SpreadKeys[#C._SpreadKeys + 1] = K
                                end
                            end
                        end
                        Weapon_Configs[V] = C
                        configsFound = configsFound + 1
                    end
                    if rawget(V, "AttemptToFlash") and type(rawget(V, "AttemptToFlash")) == "function" and not rawget(V, "__PH_FLASH_HOOKED") then
                        if setreadonly then pcall(setreadonly, V, false) end
                        rawset(V, "__PH_FLASH_HOOKED", true)
                        local Of = V.AttemptToFlash
                        V.AttemptToFlash = function(...)
                            if Config.No_Flashbang then return end
                            return Of(...)
                        end
                    end
                    if rawget(V, "UpdateAmmo") and type(rawget(V, "UpdateAmmo")) == "function" and not rawget(V, "__PH_AMMO_HOOKED") then
                        if setreadonly then pcall(setreadonly, V, false) end
                        rawset(V, "__PH_AMMO_HOOKED", true)
                        local Oua = V.UpdateAmmo
                        V.UpdateAmmo = function(self, ...)
                            local Res = Oua(self, ...)
                            if Config.Rage_Auto_Reload and Config.Rage_Enabled and self.ClientItem and self.ClientItem.IsEquipped then
                                local ammovals = self:_GetAmmoVariables()
                                if ammovals and ammovals == 0 then Execute_Reload() end
                            end
                            return Res
                        end
                    end
                    if rawget(V, "StartShooting") and type(rawget(V, "StartShooting")) == "function" and not rawget(V, "__PH_RAPID_HOOKED") then
                        if setreadonly then pcall(setreadonly, V, false) end
                        rawset(V, "__PH_RAPID_HOOKED", true)
                        local Oss = V.StartShooting
                        V.StartShooting = function(self, p1, p2)
                            local ir = Config.Rage_Enabled or Config.Rapid_Fire
                            if ir and self.Info and self.Info.AutoFire ~= nil then
                                self.Info.AutoFire = true
                            end
                            local r1, r2, r3, r4 = Oss(self, p1, p2)
                            if ir then
                                if rawget(self, "_shoot_cooldown") ~= nil then self._shoot_cooldown = 0 end
                                if rawget(self, "_is_input_queueing") ~= nil then self._is_input_queueing = false end
                            end
                            return r1, r2, r3, r4
                        end
                    end
                end
                P = P + 1
                if P >= 300 then
                    P = 0
                    task.wait()
                end
            end
        end
    end))
end

Local_Player.CharacterAdded:Connect(function()
    Table_Clear(Noclip_Parts)
    Noclip_Cached = false
    Table_Clear(Original_Joints)
    Table_Clear(Chams_Cache)
    Chams_Last_Vm = nil
    Chams_Dirty = true
end)

User_Input_Service.JumpRequest:Connect(function()
    if Config.Inf_Jump and Local_Player.Character then
        local H = Local_Player.Character:FindFirstChildOfClass("Humanoid")
        if H then H:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

Players.PlayerAdded:Connect(function(P)
    if P ~= Local_Player then Data.Esp_Objects[P] = Create_Esp() Backtrack_History[P] = {Idx = 1, Data = {}} end
end)

Players.PlayerRemoving:Connect(function(P)
    if Data.Esp_Objects[P] then Remove_Esp(Data.Esp_Objects[P]) Data.Esp_Objects[P] = nil end
    if Data.Current_Aim_Target == P then Data.Current_Aim_Target = nil end
    Backtrack_History[P] = nil
end)

for _, P in ipairs(Players:GetPlayers()) do
    if P ~= Local_Player then Data.Esp_Objects[P] = Create_Esp() Backtrack_History[P] = {Idx = 1, Data = {}} end
end

Run_Service.Stepped:Connect(LPH_NO_VIRTUALIZE(function()
    if Config.Noclip and Local_Player.Character then
        if not Noclip_Cached then
            Table_Clear(Noclip_Parts)
            for _, P in pairs(Local_Player.Character:GetDescendants()) do
                if P:IsA("BasePart") then Noclip_Parts[#Noclip_Parts + 1] = {P = P, C = P.CanCollide} end
            end
            Noclip_Cached = true
        end
        for I = 1, #Noclip_Parts do
            local D = Noclip_Parts[I]
            if D.P.Parent then D.P.CanCollide = false end
        end
    elseif Noclip_Cached then
        for I = 1, #Noclip_Parts do
            local D = Noclip_Parts[I]
            if D.P and D.P.Parent then D.P.CanCollide = D.C end
        end
        Table_Clear(Noclip_Parts)
        Noclip_Cached = false
    end
end))

local Heartbeat_Tick = 0
local Mods_Tick = 0

local HB_AutoReload = LPH_NO_VIRTUALIZE(function(Char)
    if Config.Rage_Enabled and Config.Rage_Auto_Reload and Char and Char:FindFirstChild("HumanoidRootPart") then
        local A = Get_Gui_Ammo()
        if A ~= nil then
            if A == 0 then Execute_Reload() else Is_Reloading = false end
        end
    end
end)

local HB_Backtrack = LPH_NO_VIRTUALIZE(function()
    if not (Config.Rage_Enabled and Config.Rage_Revert) then return end
    local Plrs = Players:GetPlayers()
    local Now = Tick()
    for I = 1, #Plrs do
        local P = Plrs[I]
        if P ~= Local_Player and P.Character then
            if Is_Alive(P) then
                local Hr = P.Character:FindFirstChild("HumanoidRootPart")
                if Hr then
                    local Bh = Backtrack_History[P]
                    if not Bh then
                        Bh = {Idx = 1, Data = {}}
                        Backtrack_History[P] = Bh
                    end
                    local Cd = Bh.Data[Bh.Idx]
                    if not Cd then
                        Cd = {}
                        Bh.Data[Bh.Idx] = Cd
                    end
                    Cd.P = Hr.Position
                    Cd.T = Now
                    Bh.Idx = (Bh.Idx % 12) + 1
                end
            end
        end
    end
end)

local HB_Weapon_Mods = LPH_NO_VIRTUALIZE(function()
    local Ir = Config.Rage_Enabled or Config.Rapid_Fire
    local NoRecoilActive = Config.No_Recoil or Config.Rage_Enabled
    local NoSpreadActive = Config.Rage_Enabled or Config.No_Spread
    local NoWaste = Config.No_Bullet_Waste
    local anyMod = Ir or NoRecoilActive or NoSpreadActive or NoWaste or Config.No_Melee_Cooldown or Config.Instant_Grenade or Config.Instant_Scope
    if not anyMod then return end
    local Rf = Config.Rage_Enabled and Config.Rage_Fire_Rate or Config.Rapid_Fire_Speed
    local AmmoVal = NoWaste and 9999 or nil
    local RageSpread = Config.Rage_Enabled and Config.Rage_Seed_Spread or 0
    local SpreadVec = Vector3_New(RageSpread, RageSpread, RageSpread)
    for V, C in pairs(Weapon_Configs) do
        if C.ShootCooldown ~= nil then Safe_Set(V, "ShootCooldown", Ir and Rf or C.ShootCooldown) end
        if C.ShootBurstCooldown ~= nil then Safe_Set(V, "ShootBurstCooldown", Ir and Rf or C.ShootBurstCooldown) end
        if C.EquipCooldown ~= nil then Safe_Set(V, "EquipCooldown", Ir and Rf or C.EquipCooldown) end
        if C.FireRate ~= nil then Safe_Set(V, "FireRate", Ir and 1000 or C.FireRate) end
        if C.AutoFire ~= nil then Safe_Set(V, "AutoFire", Ir and true or C.AutoFire) end
        if C.BurstFire ~= nil then Safe_Set(V, "BurstFire", Ir and false or C.BurstFire) end
        if C.MagSize ~= nil then Safe_Set(V, "MagSize", AmmoVal or C.MagSize) end
        if C.SpareAmmo ~= nil then Safe_Set(V, "SpareAmmo", AmmoVal or C.SpareAmmo) end
        if C.Ammo ~= nil then Safe_Set(V, "Ammo", AmmoVal or C.Ammo) end
        if C.AttackCooldown ~= nil then Safe_Set(V, "AttackCooldown", Config.No_Melee_Cooldown and 0 or C.AttackCooldown) end
        if C.AttackDelay ~= nil then Safe_Set(V, "AttackDelay", Config.No_Melee_Cooldown and 0 or C.AttackDelay) end
        if C.DetonateDelay ~= nil then Safe_Set(V, "DetonateDelay", Config.Instant_Grenade and 0 or C.DetonateDelay) end
        if C.AimSpeed ~= nil then Safe_Set(V, "AimSpeed", Config.Instant_Scope and 9999 or C.AimSpeed) end
        for I = 1, #C._RecoilKeys do
            local K = C._RecoilKeys[I]
            local Ov = C[K]
            if NoRecoilActive then
                if type(Ov) == "number" then
                    Safe_Set(V, K, 0)
                elseif typeof(Ov) == "Vector3" then
                    Safe_Set(V, K, Vector3_Zero)
                end
            else
                Safe_Set(V, K, Ov)
            end
        end
        for I = 1, #C._SpreadKeys do
            local K = C._SpreadKeys[I]
            local Ov = C[K]
            if NoSpreadActive then
                if type(Ov) == "number" then
                    Safe_Set(V, K, RageSpread)
                elseif typeof(Ov) == "Vector3" then
                    Safe_Set(V, K, SpreadVec)
                end
            else
                Safe_Set(V, K, Ov)
            end
        end
    end
end)

local HB_Silent_Target = LPH_NO_VIRTUALIZE(function()
    local Active_Sa = Config.Rage_Enabled or Config.Sa_Enabled
    if Has_Hook and Active_Sa then
        local Now = Tick()
        if Now - Last_Sa_Update >= 0.08 then
            Last_Sa_Update = Now
            local Sp = Get_Best_Player(true)
            Data.Sa_Target_Player = Sp
            if Sp and Is_Alive(Sp) then
                local Hp = Get_Part_From_Player(Sp, Config.Rage_Enabled and Config.Rage_Hitbox or Config.Sa_Part)
                Data.Sa_Target_Part = Hp
                if Config.Rage_Enabled and Config.Rage_Revert and Backtrack_History[Sp] then
                    local Bh = Backtrack_History[Sp]
                    local Fd = Bh.Data[1]
                    Data.Sa_Use_Live = false
                    if Fd then Data.Sa_Target_Pos = Fd.P else Data.Sa_Target_Pos = Hp and Hp.Position or nil end
                else
                    Data.Sa_Use_Live = true
                    Data.Sa_Target_Pos = Hp and Hp.Position or nil
                end
            else
                Data.Sa_Target_Pos = nil
                Data.Sa_Target_Part = nil
            end
        end
    else
        Data.Sa_Target_Pos = nil
        Data.Sa_Target_Player = nil
        Data.Sa_Target_Part = nil
    end
end)

local HB_Aim_Target = LPH_NO_VIRTUALIZE(function()
    local Aim_Cond = not Config.Rage_Enabled and Config.Aimbot_Enabled and (not Config.Aim_Hold_Rmb or User_Input_Service:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))
    if Aim_Cond then
        if Data.Current_Aim_Target and not Is_Alive(Data.Current_Aim_Target) then Data.Current_Aim_Target = nil end
        if not Data.Current_Aim_Target then Data.Current_Aim_Target = Get_Best_Player(false) end
    else
        Data.Current_Aim_Target = nil
        Aim_Accum_X, Aim_Accum_Y = 0, 0
        Data.Mm_Since = 0
    end
end)

local HB_Auto_Shoot = LPH_NO_VIRTUALIZE(function()
    if Config.Rage_Enabled and Config.Rage_Auto_Shoot then
        local Shield_Active = Check_Shields()
        local Ias = false
        if not Shield_Active and Data.Sa_Target_Pos then
            local Sp = Data.Sa_Target_Player
            if Sp and Is_Alive(Sp) then
                local Pt = Get_Part_From_Player(Sp, Config.Rage_Hitbox)
                if Pt then
                    if Is_Visible(Pt.Position, Sp.Character) then Ias = true end
                end
            end
        end
        if Ias and not Data.Is_Auto_Shooting then
            if mouse1press then mouse1press() end
            Data.Is_Auto_Shooting = true
        elseif not Ias and Data.Is_Auto_Shooting then
            if mouse1release then mouse1release() end
            Data.Is_Auto_Shooting = false
        end
    elseif Data.Is_Auto_Shooting then
        if mouse1release then mouse1release() end
        Data.Is_Auto_Shooting = false
    end
end)

local HB_Fly = LPH_NO_VIRTUALIZE(function(Char, Camera, Dt)
    if Config.Fly_Enabled and Char then
        local Hrp = Char:FindFirstChild("HumanoidRootPart")
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if Hrp and Hum then
            local Md = Vector3_Zero
            local Im = Hum.MoveDirection
            if Im.Magnitude > 0 then
                local Lv = Camera.CFrame.LookVector
                local Rv = Camera.CFrame.RightVector
                local Fl = Vector3_New(Lv.X, 0, Lv.Z).Unit
                local Fr = Vector3_New(Rv.X, 0, Rv.Z).Unit
                Md = (Camera.CFrame.LookVector * Im:Dot(Fl)) + (Camera.CFrame.RightVector * Im:Dot(Fr))
            end
            if User_Input_Service:IsKeyDown(Enum.KeyCode.Space) then Md = Md + Vector3_New(0, 1, 0) end
            if User_Input_Service:IsKeyDown(Enum.KeyCode.LeftControl) or User_Input_Service:IsKeyDown(Enum.KeyCode.LeftShift) then Md = Md - Vector3_New(0, 1, 0) end
            if Md.Magnitude > 0 then Current_Fly_Velocity = Current_Fly_Velocity:Lerp(Md.Unit * Config.Fly_Speed, 10 * Dt)
            else Current_Fly_Velocity = Vector3_Zero end
            Hrp.CFrame = Hrp.CFrame + (Current_Fly_Velocity * Dt)
            Hrp.AssemblyLinearVelocity = Vector3_Zero
            Hrp.AssemblyAngularVelocity = Vector3_Zero
        end
    else Current_Fly_Velocity = Vector3_Zero end
end)

local HB_Movement = LPH_NO_VIRTUALIZE(function(Char)
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    if Hum then
        local Hrp = Char:FindFirstChild("HumanoidRootPart")
        if Config.Ws_Enabled then Hum.WalkSpeed = Config.Walk_Speed end
        if Config.Jp_Enabled then Hum.UseJumpPower = true Hum.JumpPower = Config.Jump_Power end
        if Config.Bhop and User_Input_Service:IsKeyDown(Enum.KeyCode.Space) and Hum.FloorMaterial ~= Enum.Material.Air then Hum.Jump = true end
        if Config.Strafes and Hum.FloorMaterial == Enum.Material.Air then
            local Mv = Hum.MoveDirection
            if Hrp and Mv.Magnitude > 0 then
                local Cc = Workspace.CurrentCamera.CFrame
                local Fl = Vector3_New(Cc.LookVector.X, 0, Cc.LookVector.Z).Unit
                local Fr = Vector3_New(Cc.RightVector.X, 0, Cc.RightVector.Z).Unit
                local St = (Fl * Mv:Dot(Fl)) + (Fr * Mv:Dot(Fr))
                if St.Magnitude > 0 then Hrp.AssemblyLinearVelocity = Vector3_New(St.X * Config.Strafe_Speed, Hrp.AssemblyLinearVelocity.Y, St.Z * Config.Strafe_Speed) end
            end
        end
        local Aa_On = Config.Rage_Aa_Enabled and Is_Alive(Local_Player)
        if Aa_On and Config.Rage_Aa_Aim_Pause then
            if Config.Aimbot_Enabled and (not Config.Aim_Hold_Rmb or User_Input_Service:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) then Aa_On = false end
        end
        Data.Aa_Active = Aa_On and Config.Rage_Aa_Yaw ~= "None"
        if Aa_On then
            if Hrp then
                local Ya
                if Config.Rage_Aa_Yaw == "Spin" then Ya = ((Tick() - AA_Spin_Base) * 10) % (math.pi * 2)
                elseif Config.Rage_Aa_Yaw == "Jitter" then Ya = Math_Rad(Math_Random(-180, 180))
                elseif Config.Rage_Aa_Yaw == "Backward" then Ya = Math_Rad(180)
                elseif Config.Rage_Aa_Yaw == "Sideways" then Ya = Math_Rad(90) end
                if Ya then
                    if AA_Prev_AutoRotate == nil then AA_Prev_AutoRotate = Hum.AutoRotate end
                    Hum.AutoRotate = false
                    Hrp.CFrame = Cframe_New(Hrp.Position) * Cframe_Angles(0, Ya, 0)
                elseif AA_Prev_AutoRotate ~= nil then
                    Hum.AutoRotate = AA_Prev_AutoRotate AA_Prev_AutoRotate = nil
                end
            end
            local Rj = Char:FindFirstChild("RootJoint", true) or (Char:FindFirstChild("LowerTorso") and Char.LowerTorso:FindFirstChild("Root"))
            if Rj then
                if not Original_Joints[Rj] then Original_Joints[Rj] = Rj.C0 end
                local Pa = 0
                if Config.Rage_Aa_Pitch == "Down" then Pa = Math_Rad(-60)
                elseif Config.Rage_Aa_Pitch == "Up" then Pa = Math_Rad(60)
                elseif Config.Rage_Aa_Pitch == "Jitter" then Pa = Math_Rad(Math_Random(-60, 60)) end
                if Pa ~= 0 then
                    Rj.C0 = Original_Joints[Rj] * Cframe_Angles(Pa, 0, 0)
                else
                    Rj.C0 = Original_Joints[Rj]
                end
            end
        else
            if AA_Prev_AutoRotate ~= nil then Hum.AutoRotate = AA_Prev_AutoRotate AA_Prev_AutoRotate = nil end
            for J, Oc in pairs(Original_Joints) do
                if J and J.Parent then J.C0 = Oc end
            end
        end
    else
        AA_Prev_AutoRotate = nil
        Data.Aa_Active = false
        for J, Oc in pairs(Original_Joints) do
            if J and J.Parent then J.C0 = Oc end
        end
    end
end)

local Run_Errors = {}
local Run_Error_Count = 0

local function Run_Safe(F, A, B, C)
    local Ok, Err = pcall(F, A, B, C)
    if Ok then return end
    Err = tostring(Err)
    if Run_Errors[Err] or Run_Error_Count >= 3 then return end
    Run_Errors[Err] = true
    Run_Error_Count = Run_Error_Count + 1
    print("[PH] runtime failed: " .. Err)
    task.spawn(function()
        pcall(function() Library:Notify("PHANTOM HUB", "RT: " .. Data.Short_Error(Err), 8) end)
    end)
end

Run_Service.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(Dt)
    Heartbeat_Tick = Heartbeat_Tick + Dt
    Mods_Tick = Mods_Tick + Dt
    local Camera = Workspace.CurrentCamera
    local Char = Local_Player.Character
    Run_Safe(HB_AutoReload, Char)
    if Config.CustLight_Enabled then Run_Safe(Update_CustomLighting) end
    Data.World_Tick = Data.World_Tick + Dt
    if Data.World_Tick >= 0.5 then Data.World_Tick = 0 Run_Safe(Refresh_World_Visuals) end
    if Heartbeat_Tick >= 0.1 then Heartbeat_Tick = 0 Run_Safe(HB_Backtrack) end
    if Has_Getgc and Mods_Tick >= 1 then Mods_Tick = 0 Run_Safe(HB_Weapon_Mods) end
    Run_Safe(HB_Silent_Target)
    Run_Safe(HB_Aim_Target)
    Run_Safe(HB_Auto_Shoot)
    Run_Safe(HB_Triggerbot, Char, Camera)
    Run_Safe(HB_Backstab, Char)
    Run_Safe(HB_Fly, Char, Camera, Dt)
    Run_Safe(HB_Movement, Char)
end))

local function Main_Render(Dt)
    local Camera = Workspace.CurrentCamera
    local Center = Camera.ViewportSize / 2
    local Cross_At = Center
    if Config.Crosshair_Follow then
        local Tgt = Data.Current_Aim_Target or Data.Sa_Target_Player or Get_Best_Player(true)
        if Tgt and Tgt.Character then
            local Tp = Get_Part_From_Player(Tgt, Config.Sa_Part) or Tgt.Character:FindFirstChild("HumanoidRootPart")
            if Tp then
                local Sp, On = Camera:WorldToViewportPoint(Tp.Position)
                if On and Sp.Z > 0 then Cross_At = Vector2_New(Sp.X, Sp.Y) end
            end
        end
    end
    Run_Safe(Update_Crosshair, Cross_At, Dt)
    if Config.Third_Person and Local_Player.Character then
        Local_Player.CameraMode = Enum.CameraMode.Classic
        Local_Player.CameraMinZoomDistance = 10
        Local_Player.CameraMaxZoomDistance = 10
        Camera.CFrame = Camera.CFrame * Cframe_New(2.5, 1.5, 8)
        local Char = Local_Player.Character
        if Data.Tp_Char ~= Char then
            Data.Tp_Char = Char
            Table_Clear(Data.Tp_Parts)
            for _, Obj in ipairs(Char:GetDescendants()) do
                if Obj:IsA("BasePart") and Obj.Name ~= "HumanoidRootPart" then
                    Data.Tp_Parts[#Data.Tp_Parts + 1] = Obj
                end
            end
        end
        local Tp = Data.Tp_Parts
        for I = 1, #Tp do
            local Obj = Tp[I]
            if Obj.Parent then Obj.LocalTransparencyModifier = 0 end
        end
    end

    if Config.Chams_Enabled then
        if Config.Chams_Rainbow then
            Data.Chams_Hue = (Data.Chams_Hue + (Dt * Config.Chams_Rainbow_Speed * 0.1)) % 1
        end
        Apply_Chams()
    end

    if Config.Show_Fov then
        Set_Vis(Fov_Circle, true) Fov_Circle.Position = Center
        if Config.Fov_Rainbow then
            Data.Rainbow_Hue = (Data.Rainbow_Hue + (Dt * Config.Fov_Rainbow_Speed * 0.1)) % 1
            Config.Fov_Color = Color3_From_Hsv(Data.Rainbow_Hue, 1, 1)
        end
        Fov_Circle.Color = Config.Fov_Color
    else Set_Vis(Fov_Circle, false) end

    local Aim_Cond = not Config.Rage_Enabled and Config.Aimbot_Enabled and (not Config.Aim_Hold_Rmb or User_Input_Service:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))
    if Aim_Cond and Data.Current_Aim_Target and Data.Current_Aim_Target.Character then
        local Hp = Get_Part_From_Player(Data.Current_Aim_Target, Config.Aim_Part) or Data.Current_Aim_Target.Character:FindFirstChild("HumanoidRootPart")
        if Hp then
            local Ap = Hp.Position
            if Config.Aim_Prediction then
                local Rt = Data.Current_Aim_Target.Character:FindFirstChild("HumanoidRootPart") or Hp
                if Rt then
                    local Vel = Resolve_Velocity(Data.Current_Aim_Target, Rt.AssemblyLinearVelocity)
                    local Dist = (Ap - Camera.CFrame.Position).Magnitude
                    local Tth = Dist / 3000
                    Ap = Ap + (Vel * Tth)
                end
            end
            if Config.Aim_Shake then
                local Tv = Tick() * (Config.Aim_Shake_Speed / 2)
                Ap = Ap + Vector3_New(Math_Noise(Tv, 100, 100) * Config.Aim_Shake_X, Math_Noise(200, Tv, 200) * Config.Aim_Shake_Y, Math_Noise(300, 300, Tv) * Config.Aim_Shake_X)
            end
            if Config.Aim_Type == "Mouse" and type(mousemoverel) == "function" and not Data.Mm_Broken then
                local Sp2, _ = Camera:WorldToViewportPoint(Ap)
                if Sp2.Z > 0 then
                    local Sm = Math_Max(1, Config.Aim_Smoothness)
                    local Off = (Center - Vector2_New(Sp2.X, Sp2.Y)).Magnitude
                    Aim_Accum_X = Aim_Accum_X + ((Sp2.X - Center.X) / Sm)
                    Aim_Accum_Y = Aim_Accum_Y + ((Sp2.Y - Center.Y) / Sm)
                    local Mx = Math_Floor(Aim_Accum_X + 0.5)
                    local My = Math_Floor(Aim_Accum_Y + 0.5)
                    Aim_Accum_X = Aim_Accum_X - Mx
                    Aim_Accum_Y = Aim_Accum_Y - My
                    if Mx ~= 0 or My ~= 0 then
                        mousemoverel(Mx, My)
                        local Now = Tick()
                        if Off < 8 or Data.Mm_Since == 0 then
                            Data.Mm_Since = Now
                            Data.Mm_Ref = Off
                        elseif Now - Data.Mm_Since > 0.75 then
                            if Off > Data.Mm_Ref * 0.85 then
                                Data.Mm_Broken = true
                                pcall(function() Library:Notify("AIMBOT", "mousemoverel does nothing here, switched to camera aim", 6) end)
                            else
                                Data.Mm_Since = Now
                                Data.Mm_Ref = Off
                            end
                        end
                    end
                end
            else
                local Oc = Camera.CFrame
                local Tc2 = Cframe_Look_At(Oc.Position, Ap)
                local Sm = Config.Aim_Smoothness
                local Nc = Sm > 1 and Oc:Lerp(Tc2, 1 / Sm) or Tc2
                Data.Aim_Rotate_Camera(Camera, Oc, Nc)
            end
        end
    end
    Run_Safe(Update_Esp_All, Dt)
    Run_Safe(LV_Update)
end

do
    pcall(function() Run_Service:UnbindFromRenderStep("PH_MainLoop") end)
    local Bound = pcall(function()
        Run_Service:BindToRenderStep("PH_MainLoop", 2005, LPH_NO_VIRTUALIZE(function(Dt)
            Run_Safe(Main_Render, Dt)
        end))
    end)
    if not Bound then
        Run_Service.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function(Dt)
            Run_Safe(Main_Render, Dt)
        end))
    end
    print(string.format("[PH] loaded, renderstep=%s hook=%s getgc=%s identity=%s executor=%s",
        Bound and "bind" or "stepped", tostring(Has_Hook), tostring(Has_Getgc),
        tostring(type(setthreadidentity) == "function"), Exec_Name))
end

if Has_Hook and Has_Getgc then Library:Notify("PHANTOM HUB", "Loaded!", 5)
else Library:Notify("PHANTOM HUB", "Loaded in Limited Mode!", 5) end

Safe(function()
    if Is_Weak then return end
    local Spoof_Tab = Window:Tab("Spoof", "89125229111071")
    local Sp = {
        Level = false, Level_Value = 9999,
        Streak = false, Streak_Value = 9999,
        Name = false, Name_Value = "", Verified = false, Premium = false,
        Fps = false, Fps_Fraud = false, Fps_Value = "60",
        Ms = false, Ms_Fraud = false, Ms_Value = "12",
        Region = false, Region_Value = "PHANTOM",
        Device = false, Device_Type = "PC",
        Skin = false, Skin_Id = ""
    }

    local Verified_Char = utf8.char(0xE000)
    local Premium_Char = utf8.char(0xE001)
    local Name_Busy = false

    local function Strip_Badges(S)
        if type(S) ~= "string" then return "" end
        return (S:gsub(Verified_Char, ""):gsub(Premium_Char, ""))
    end

    local function Spoof_Name_Text()
        local Base = Strip_Badges(Sp.Name_Value)
        if Base == "" then Base = Local_Player.DisplayName end
        return Base .. (Sp.Premium and Premium_Char or "") .. (Sp.Verified and Verified_Char or "")
    end

    local function Apply_Name(Char)
        if not Sp.Name then return end
        local C = Char or Local_Player.Character
        local Hum = C and C:FindFirstChildOfClass("Humanoid")
        if not Hum then return end
        local New = Spoof_Name_Text()
        pcall(function()
            Hum.DisplayName = New
            local Old = Hum.DisplayDistanceType
            Hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            Hum.DisplayDistanceType = Old
        end)
    end

    local function Apply_Skin(Char)
        if not Sp.Skin then return end
        local C = Char or Local_Player.Character
        local Id = tonumber(Sp.Skin_Id)
        if not C or not Id then return end
        pcall(function()
            local Model = Players:CreateHumanoidModelFromUserId(Id)
            if not Model then return end
            for _, O in ipairs(C:GetChildren()) do
                if O:IsA("Accessory") or O:IsA("Shirt") or O:IsA("Pants") or O:IsA("BodyColors")
                    or O:IsA("CharacterMesh") or O:IsA("ShirtGraphic") then
                    O:Destroy()
                end
            end
            local Head = C:FindFirstChild("Head")
            local Face = Head and Head:FindFirstChildOfClass("Decal")
            if Face then Face:Destroy() end
            for _, O in ipairs(Model:GetChildren()) do
                if O:IsA("Accessory") or O:IsA("Shirt") or O:IsA("Pants") or O:IsA("BodyColors")
                    or O:IsA("CharacterMesh") or O:IsA("ShirtGraphic") then
                    O:Clone().Parent = C
                elseif O.Name == "Head" and Head then
                    local F = O:FindFirstChildOfClass("Decal")
                    if F then F:Clone().Parent = Head end
                end
            end
            Model:Destroy()
        end)
    end

    local Device_Codes = {Mobile = "Touch", Console = "Gamepad", VR = "VR", PC = "MouseKeyboard"}
    local Last_Device = 0

    local function Apply_Device()
        if not Sp.Device then return end
        local Code = Device_Codes[Sp.Device_Type]
        if not Code then return end
        if Tick() - Last_Device < 0.5 then return end
        Last_Device = Tick()
        pcall(function()
            local R = RS:FindFirstChild("Remotes")
            R = R and R:FindFirstChild("Replication")
            R = R and R:FindFirstChild("Fighter")
            R = R and R:FindFirstChild("SetControls")
            if R then R:FireServer(Code) end
        end)
    end

    local Stat_Labels, Region_Labels = {}, {}

    local function Scan_Labels()
        Table_Clear(Stat_Labels)
        Table_Clear(Region_Labels)
        local Gui = Local_Player:FindFirstChild("PlayerGui")
        if not Gui then return end
        for _, D in ipairs(Gui:GetDescendants()) do
            if D:IsA("TextLabel") and D.Name == "Title" then
                if D.Parent and D.Parent.Name == "ServerRegion" then
                    Region_Labels[#Region_Labels + 1] = D
                else
                    Stat_Labels[#Stat_Labels + 1] = D
                end
            end
        end
    end

    local Fps_Drift, Ms_Drift = 0, 0

    local function Fraud_Fps()
        local Base = tonumber(Sp.Fps_Value) or 60
        Fps_Drift = Math_Clamp(Fps_Drift + math.random(-3, 5), -15, 15)
        return Math_Clamp(Base + math.random(-8, 12) + Fps_Drift, 10, 240)
    end

    local function Fraud_Ms()
        local Base = tonumber(Sp.Ms_Value) or 12
        Ms_Drift = Math_Clamp(Ms_Drift + math.random(-4, 6), -20, 25)
        local Spike = (math.random(1, 100) <= 12) and math.random(15, 45) or 0
        return Math_Clamp(Base + math.random(-6, 10) + Ms_Drift + Spike, 4, 250)
    end

    task.spawn(function()
        local N = 0
        local Scanned = false
        while task.wait(0.5) do
            if not (Sp.Level or Sp.Streak or Sp.Name or Sp.Fps or Sp.Ms or Sp.Region or Sp.Device) then
                continue
            end
            N = N + 1
            if (Sp.Fps or Sp.Ms or Sp.Region) and (not Scanned or N % 20 == 0) then
                Scanned = true
                Scan_Labels()
            end

            if Sp.Level then
                pcall(function() Local_Player:SetAttribute("Level", Sp.Level_Value) end)
            end
            if Sp.Streak then
                pcall(function()
                    local Ls = Local_Player:FindFirstChild("CustomLeaderstats")
                    local Ws = Ls and Ls:FindFirstChild("Win Streak")
                    if Ws then Ws.Value = Sp.Streak_Value end
                end)
            end
            if Sp.Name then
                local Want = Spoof_Name_Text()
                local Hum = Local_Player.Character and Local_Player.Character:FindFirstChildOfClass("Humanoid")
                if Hum and Hum.DisplayName ~= Want then Apply_Name() end
            end
            if Sp.Fps or Sp.Ms then
                local F = Sp.Fps and tostring(Sp.Fps_Fraud and Fraud_Fps() or (tonumber(Sp.Fps_Value) or 60))
                local M = Sp.Ms and tostring(Sp.Ms_Fraud and Fraud_Ms() or (tonumber(Sp.Ms_Value) or 12))
                for I = 1, #Stat_Labels do
                    local L = Stat_Labels[I]
                    if L.Parent then
                        local T = L.Text
                        if F then T = T:gsub("%d+fps", F .. "fps") end
                        if M then T = T:gsub("%d+ms", M .. "ms") end
                        if T ~= L.Text then L.Text = T end
                    end
                end
            end
            if Sp.Region then
                for I = 1, #Region_Labels do
                    local L = Region_Labels[I]
                    if L.Parent and L.Text ~= Sp.Region_Value then L.Text = Sp.Region_Value end
                end
            end
            if Sp.Device and Tick() - Last_Device > 30 then Apply_Device() end
        end
    end)

    local function Patch_Text(D)
        if not Sp.Name or Name_Busy then return end
        if not (D:IsA("TextLabel") or D:IsA("TextButton") or D:IsA("TextBox")) then return end
        local T = D.Text
        if not T or T == "" then return end
        local Want = Spoof_Name_Text()
        if T:find(Local_Player.Name, 1, true) then
            Name_Busy = true
            D.Text = T:gsub(Local_Player.Name:gsub("([^%w])", "%%%1"), Want)
            Name_Busy = false
        end
    end
    local Name_Conns = {}
    local function Set_Name_Hooks(State)
        if State then
            if #Name_Conns > 0 then return end
            pcall(function()
                local Gui = Local_Player:FindFirstChild("PlayerGui")
                if Gui then Name_Conns[#Name_Conns + 1] = Gui.DescendantAdded:Connect(Patch_Text) end
            end)
            pcall(function()
                Name_Conns[#Name_Conns + 1] = game:GetService("CoreGui").DescendantAdded:Connect(Patch_Text)
            end)
        else
            for I = #Name_Conns, 1, -1 do
                pcall(function() Name_Conns[I]:Disconnect() end)
                Name_Conns[I] = nil
            end
        end
    end

    Local_Player.CharacterAdded:Connect(function(C)
        task.wait(0.5)
        Apply_Name(C)
        Apply_Skin(C)
    end)

    local Profile_Section = Spoof_Tab:Section("Profile", "Left")
    Profile_Section:Toggle("Spoof Level", "SpoofLevel", false, "Fake your displayed level", function(V) Sp.Level = V end)
    Profile_Section:Slider("Level", "SpoofLevelVal", 1, 9999, 9999, 1, "", function(V) Sp.Level_Value = tonumber(V) or 9999 end)
    Profile_Section:Toggle("Spoof Win Streak", "SpoofStreak", false, "", function(V) Sp.Streak = V end)
    Profile_Section:Slider("Win Streak", "SpoofStreakVal", 1, 9999, 9999, 1, "", function(V) Sp.Streak_Value = tonumber(V) or 9999 end)

    local Name_Section = Spoof_Tab:Section("Name", "Left")
    Name_Section:Toggle("Spoof Name", "SpoofName", false, "", function(V)
        Sp.Name = V
        Set_Name_Hooks(V)
        if V then Apply_Name() end
    end)
    Name_Section:TextBox("Custom Name", "SpoofNameVal", "type name...", "", function(V)
        Sp.Name_Value = Strip_Badges(V)
        if Sp.Name then Apply_Name() end
    end)
    Name_Section:Toggle("Verified Badge", "SpoofVerified", false, "", function(V)
        Sp.Verified = V
        if Sp.Name then Apply_Name() end
    end)
    Name_Section:Toggle("Premium Badge", "SpoofPremium", false, "", function(V)
        Sp.Premium = V
        if Sp.Name then Apply_Name() end
    end)

    local Skin_Section = Spoof_Tab:Section("Fit Changer", "Left")
    Skin_Section:Toggle("Enable", "SpoofSkin", false, "Copy another user's avatar onto your character", function(V)
        Sp.Skin = V
        if V then Apply_Skin() end
    end)
    Skin_Section:TextBox("User ID", "SpoofSkinId", "type user id...", "", function(V)
        Sp.Skin_Id = V
        if Sp.Skin then Apply_Skin() end
    end)

    local Stats_Section = Spoof_Tab:Section("Stats", "Right")
    Stats_Section:Toggle("Spoof FPS", "SpoofFps", false, "", function(V) Sp.Fps = V end)
    Stats_Section:Toggle("FPS Fraud", "SpoofFpsFraud", false, "Randomly drift the value so it looks real", function(V) Sp.Fps_Fraud = V end)
    Stats_Section:TextBox("FPS Value", "SpoofFpsVal", "60", "", function(V) Sp.Fps_Value = V end)
    Stats_Section:Toggle("Spoof MS", "SpoofMs", false, "", function(V) Sp.Ms = V end)
    Stats_Section:Toggle("MS Fraud", "SpoofMsFraud", false, "Randomly drift the value so it looks real", function(V) Sp.Ms_Fraud = V end)
    Stats_Section:TextBox("MS Value", "SpoofMsVal", "12", "", function(V) Sp.Ms_Value = V end)
    Stats_Section:Toggle("Spoof Region", "SpoofRegion", false, "", function(V) Sp.Region = V end)
    Stats_Section:TextBox("Region Text", "SpoofRegionVal", "PHANTOM", "", function(V)
        if V ~= "" then Sp.Region_Value = V end
    end)

    local Device_Section = Spoof_Tab:Section("Device", "Right")
    Device_Section:Toggle("Spoof Device", "SpoofDevice", false, "Report a different input device to the server", function(V)
        Sp.Device = V
        if V then Apply_Device() end
    end)
    Device_Section:Dropdown("Device", "SpoofDeviceType", {"PC", "Mobile", "Console", "VR"}, "PC", "", function(V)
        Sp.Device_Type = V
        if Sp.Device then Apply_Device() end
    end, nil, false)
end)

Safe(function()
    Config.Fps_Cap = Is_Mobile and 120 or 0
    local Set_Cap = setfpscap or (getgenv and getgenv().setfpscap)
    Data.Set_Fps_Cap = function(V)
        Config.Fps_Cap = V
        if type(Set_Cap) == "function" then pcall(Set_Cap, V) end
    end
    Data.Set_Fps_Cap(Config.Fps_Cap)
end)

Safe(function()
    local Perf_Section = World_Tab:Section("Performance", "Left")
    Perf_Section:Slider("Max FPS", "FpsCap", 0, 360, Config.Fps_Cap, 10, "0 = uncapped", function(V)
        if Data.Set_Fps_Cap then Data.Set_Fps_Cap(tonumber(V) or 0) end
    end)
end)

Safe(function()
    local Wl_Section = Combat_Tab:Section("Whitelist", "Left")
    local Dd

    local function Player_Names()
        local L = {}
        for _, P in ipairs(Players:GetPlayers()) do
            if P ~= Local_Player then L[#L + 1] = P.Name end
        end
        for N in pairs(Data.Whitelist) do
            local Found = false
            for _, V in ipairs(L) do if V == N then Found = true break end end
            if not Found then L[#L + 1] = N end
        end
        table.sort(L)
        return L
    end

    Wl_Section:Toggle("Enable Whitelist", "WlEnabled", true, "No feature targets whitelisted players", function(V)
        Config.Whitelist_Enabled = V
    end)
    local function Whitelisted_List()
        local L = {}
        for N in pairs(Data.Whitelist) do L[#L + 1] = N end
        table.sort(L)
        return L
    end

    Dd = Wl_Section:Dropdown("Players", "WlPlayers", Player_Names(), {}, "Selected players are ignored by all features", function(V)
        local New = {}
        if type(V) == "table" then
            for K, Sel in pairs(V) do
                if Sel == true then New[K] = true
                elseif type(Sel) == "string" then New[Sel] = true end
            end
        elseif type(V) == "string" and V ~= "" then
            New[V] = true
        end
        Data.Whitelist = New
    end, nil, true)
    Wl_Section:Button("Refresh List", "Rescan players in the server", function()
        if Dd and Dd.Refresh then pcall(Dd.Refresh, Dd, Player_Names(), Whitelisted_List()) end
    end)
    Wl_Section:TextBox("Add By Name", "WlAdd", "Username", "Adds a name manually", function(V)
        if type(V) == "string" and V ~= "" then
            Data.Whitelist[V] = true
            if Dd and Dd.Refresh then pcall(Dd.Refresh, Dd, Player_Names(), Whitelisted_List()) end
            Library:Notify("PHANTOM HUB", V .. " whitelisted", 4)
        end
    end)
    Wl_Section:Button("Clear Whitelist", "", function()
        Data.Whitelist = {}
        if Dd and Dd.Refresh then pcall(Dd.Refresh, Dd, Player_Names(), {}) end
    end)
end)

Safe(function()
    local Cos_Refresh
    local Cos_Parts = {}

    local function Cos_Clear()
        for I = 1, #Cos_Parts do
            pcall(function() Cos_Parts[I]:Destroy() end)
        end
        Table_Clear(Cos_Parts)
    end

    local function Track(Obj)
        Cos_Parts[#Cos_Parts + 1] = Obj
        return Obj
    end

    local function Torso_Of(Char)
        return Char:FindFirstChild("UpperTorso") or Char:FindFirstChild("Torso") or Char:FindFirstChild("HumanoidRootPart")
    end

    local function Make_Hat(Char)
        local Head = Char:FindFirstChild("Head")
        if not Head then return end
        local Cone = Instance.new("Part")
        Cone.Name = "PH_Hat"
        Cone.Size = Vector3_New(1, 1, 1)
        Cone.Material = Enum.Material.Neon
        Cone.Color = Config.Cos_Hat_Color
        Cone.Transparency = 0.2
        Cone.CanCollide = false
        Cone.Massless = true
        local Mesh = Instance.new("SpecialMesh")
        Mesh.MeshType = Enum.MeshType.FileMesh
        Mesh.MeshId = "rbxassetid://1033714"
        Mesh.Scale = Vector3_New(1.7, 1.1, 1.7)
        Mesh.Parent = Cone
        local Weld = Instance.new("Weld")
        Weld.Part0 = Head
        Weld.Part1 = Cone
        Weld.C0 = Cframe_New(0, 0.9, 0)
        Weld.Parent = Cone
        Cone.Parent = Char
        Track(Cone)
    end

    local function Make_Cape(Char)
        local Torso = Torso_Of(Char)
        if not Torso then return end
        local Cape = Instance.new("Part")
        Cape.Name = "PH_Cape"
        Cape.Size = Vector3_New(2, 3, 0.15)
        Cape.Material = Enum.Material.SmoothPlastic
        Cape.Color = Config.Cos_Cape_Color
        Cape.CanCollide = false
        Cape.Massless = true
        local Weld = Instance.new("Weld")
        Weld.Part0 = Torso
        Weld.Part1 = Cape
        Weld.C0 = Cframe_New(0, -0.4, 0.65) * Cframe_Angles(Math_Rad(8), 0, 0)
        Weld.Parent = Cape
        Cape.Parent = Char
        Track(Cape)
    end

    local function Make_Wings(Char)
        local Torso = Torso_Of(Char)
        if not Torso then return end
        local Att = Instance.new("Attachment")
        Att.Name = "PH_WingsAtt"
        Att.CFrame = Cframe_New(0, 0.5, 0.6)
        Att.Parent = Torso
        Track(Att)
        for I = 1, 2 do
            local Pe = Instance.new("ParticleEmitter")
            Pe.Name = "PH_Wing" .. I
            Pe.Color = ColorSequence.new(Config.Cos_Wings_Color)
            Pe.Texture = "rbxassetid://7511321694"
            Pe.LightEmission = 1
            Pe.LightInfluence = 0
            Pe.LockedToPart = true
            Pe.Orientation = Enum.ParticleOrientation.FacingCamera
            Pe.Lifetime = NumberRange.new(1, 2)
            Pe.Rate = I == 1 and 50 or 100
            Pe.Speed = NumberRange.new(2.5, 2.5)
            Pe.SpreadAngle = Vector2_New(0, 360)
            Pe.Acceleration = Vector3_New(0, -6, 0)
            Pe.EmissionDirection = Enum.NormalId.Bottom
            Pe.Rotation = NumberRange.new(-360, 360)
            Pe.RotSpeed = NumberRange.new(-100, 100)
            Pe.Size = NumberSequence.new(0.5)
            Pe.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.15, 0),
                NumberSequenceKeypoint.new(0.85, 0),
                NumberSequenceKeypoint.new(1, 1)
            })
            Pe.Parent = Att
            Track(Pe)
        end
    end

    local function Make_Aura(Char)
        local Root = Char:FindFirstChild("HumanoidRootPart") or Torso_Of(Char)
        if not Root then return end
        local Att = Instance.new("Attachment")
        Att.Name = "PH_AuraAtt"
        Att.CFrame = Cframe_New(0, -2.6, 0)
        Att.Parent = Root
        Track(Att)
        local Flame = Instance.new("ParticleEmitter")
        Flame.Name = "PH_Aura"
        Flame.Color = ColorSequence.new(Config.Cos_Aura_Color)
        Flame.Texture = "rbxassetid://10545078665"
        Flame.Brightness = 8
        Flame.LightEmission = 1
        Flame.LightInfluence = 0
        Flame.LockedToPart = false
        Flame.Orientation = Enum.ParticleOrientation.FacingCamera
        Flame.Lifetime = NumberRange.new(0.4, 0.7)
        Flame.Rate = 120
        Flame.Speed = NumberRange.new(2, 4)
        Flame.SpreadAngle = Vector2_New(90, 90)
        Flame.Acceleration = Vector3_New(0, 6, 0)
        Flame.EmissionDirection = Enum.NormalId.Top
        Flame.Rotation = NumberRange.new(-360, 360)
        Flame.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1.2),
            NumberSequenceKeypoint.new(1, 0)
        })
        Flame.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0.1),
            NumberSequenceKeypoint.new(1, 1)
        })
        Flame.Parent = Att
        Track(Flame)
    end

    Cos_Refresh = function()
        Cos_Clear()
        local Char = Local_Player.Character
        if not Char then return end
        if Config.Cos_Hat then pcall(Make_Hat, Char) end
        if Config.Cos_Cape then pcall(Make_Cape, Char) end
        if Config.Cos_Wings then pcall(Make_Wings, Char) end
        if Config.Cos_Aura then pcall(Make_Aura, Char) end
    end

    Local_Player.CharacterAdded:Connect(function(Char)
        Char:WaitForChild("HumanoidRootPart", 8)
        task.wait(0.4)
        Cos_Refresh()
    end)

    local Cos_Section = Visuals_Tab:Section("Self Cosmetics", "Left")
    Cos_Section:Toggle("China Hat", "CosHat", false, "Local only, other players do not see it", function(V) Config.Cos_Hat = V Cos_Refresh() end)
    Cos_Section:ColorPicker("Hat Color", "CosHatCol", Config.Cos_Hat_Color, "", function(V) Config.Cos_Hat_Color = V Cos_Refresh() end)
    Cos_Section:Toggle("Cape", "CosCape", false, "Local only", function(V) Config.Cos_Cape = V Cos_Refresh() end)
    Cos_Section:ColorPicker("Cape Color", "CosCapeCol", Config.Cos_Cape_Color, "", function(V) Config.Cos_Cape_Color = V Cos_Refresh() end)
    Cos_Section:Toggle("Wings", "CosWings", false, "Local only", function(V) Config.Cos_Wings = V Cos_Refresh() end)
    Cos_Section:ColorPicker("Wings Color", "CosWingsCol", Config.Cos_Wings_Color, "", function(V) Config.Cos_Wings_Color = V Cos_Refresh() end)
    Cos_Section:Toggle("Aura", "CosAura", false, "Local only", function(V) Config.Cos_Aura = V Cos_Refresh() end)
    Cos_Section:ColorPicker("Aura Color", "CosAuraCol", Config.Cos_Aura_Color, "", function(V) Config.Cos_Aura_Color = V Cos_Refresh() end)
end)

