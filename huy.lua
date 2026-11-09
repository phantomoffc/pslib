local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local MarketplaceService = game:GetService("MarketplaceService")
local isfolder = isfolder or function() return false end
local makefolder = makefolder or function() end
local isfile = isfile or function() return false end
local readfile = readfile or function() return "" end
local writefile = writefile or function() end
local listfiles = listfiles or function() return {} end
local delfile = delfile or function() end
local CoreGui
pcall(function() CoreGui = game:GetService("CoreGui") end)
local LocalPlayer = Players.LocalPlayer
local Library = {
    Flags = {},
    Signals = {},
    Defaults = {},
    Open = true,
    KeybindList = nil,
    ShowKeybinds = true,
    Binds = {},
    BindOrder = {},
    SearchIndex = {},
    ScreenGui = nil,
    Connections = {},
    Elements = {},
    Unsaved = false,
    AutoSaveEnabled = true
}
local Config = {
    Name = "PHANTOM HUB",
    Brand = "Phantom Softworks",
    Theme = "Halloween",
    Keybind = Enum.KeyCode.LeftControl,
    HideKeybind = Enum.KeyCode.Unknown,
    Duration = 0.3,
    FontMain = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    ConfigFolder = "PhantomHub"
}
if not isfolder(Config.ConfigFolder) then makefolder(Config.ConfigFolder) end
local Theme = {}
local Themes = {
    ["Halloween"] = {
        Background = Color3.fromHex("#0b0710"),
        Sidebar = Color3.fromHex("#120a18"),
        Container = Color3.fromHex("#1c1024"),
        Section = Color3.fromHex("#26142f"),
        Accent = Color3.fromHex("#ff7a1a"),
        Text = Color3.fromHex("#ffffff"),
        TextDark = Color3.fromHex("#a08aa8"),
        Stroke = Color3.fromHex("#3a2244"),
        Success = Color3.fromHex("#00ff88"),
        Danger = Color3.fromHex("#ff4444"),
        Topbar = Color3.fromHex("#150c1c")
    },
    ["Phantom Red"] = {
        Background = Color3.fromHex("#080505"),
        Sidebar = Color3.fromHex("#0c0707"),
        Container = Color3.fromHex("#140b0b"),
        Section = Color3.fromHex("#1a0e0e"),
        Accent = Color3.fromHex("#ff1a1a"),
        Text = Color3.fromHex("#ffffff"),
        TextDark = Color3.fromHex("#997373"),
        Stroke = Color3.fromHex("#2e1717"),
        Success = Color3.fromHex("#00ff88"),
        Danger = Color3.fromHex("#ff4444"),
        Topbar = Color3.fromHex("#120a0a")
    },
    ["Midnight"] = {
        Background = Color3.fromHex("#05070c"),
        Sidebar = Color3.fromHex("#0a0f1c"),
        Container = Color3.fromHex("#111b30"),
        Section = Color3.fromHex("#172342"),
        Accent = Color3.fromHex("#2f7bff"),
        Text = Color3.fromHex("#ffffff"),
        TextDark = Color3.fromHex("#7d8db0"),
        Stroke = Color3.fromHex("#22304f"),
        Success = Color3.fromHex("#00ff88"),
        Danger = Color3.fromHex("#ff4444"),
        Topbar = Color3.fromHex("#0c1424")
    },
    ["Emerald"] = {
        Background = Color3.fromHex("#050d08"),
        Sidebar = Color3.fromHex("#08170e"),
        Container = Color3.fromHex("#0e2a1b"),
        Section = Color3.fromHex("#143a26"),
        Accent = Color3.fromHex("#00ff9d"),
        Text = Color3.fromHex("#ffffff"),
        TextDark = Color3.fromHex("#71a68f"),
        Stroke = Color3.fromHex("#1f4a33"),
        Success = Color3.fromHex("#00ff88"),
        Danger = Color3.fromHex("#ff4444"),
        Topbar = Color3.fromHex("#0a1a12")
    },
    ["Royal Purple"] = {
        Background = Color3.fromHex("#0a050e"),
        Sidebar = Color3.fromHex("#150a1f"),
        Container = Color3.fromHex("#241036"),
        Section = Color3.fromHex("#301648"),
        Accent = Color3.fromHex("#b04bff"),
        Text = Color3.fromHex("#ffffff"),
        TextDark = Color3.fromHex("#9c84b8"),
        Stroke = Color3.fromHex("#3a2150"),
        Success = Color3.fromHex("#00ff88"),
        Danger = Color3.fromHex("#ff4444"),
        Topbar = Color3.fromHex("#180c24")
    },
    ["Graphite"] = {
        Background = Color3.fromHex("#0b0b0b"),
        Sidebar = Color3.fromHex("#141414"),
        Container = Color3.fromHex("#1e1e1e"),
        Section = Color3.fromHex("#272727"),
        Accent = Color3.fromHex("#e8e8e8"),
        Text = Color3.fromHex("#ffffff"),
        TextDark = Color3.fromHex("#8a8a8a"),
        Stroke = Color3.fromHex("#3a3a3a"),
        Success = Color3.fromHex("#00ff88"),
        Danger = Color3.fromHex("#ff4444"),
        Topbar = Color3.fromHex("#181818")
    },
    ["Solar"] = {
        Background = Color3.fromHex("#0f0c05"),
        Sidebar = Color3.fromHex("#1a1408"),
        Container = Color3.fromHex("#2a2010"),
        Section = Color3.fromHex("#3a2c15"),
        Accent = Color3.fromHex("#ffb020"),
        Text = Color3.fromHex("#ffffff"),
        TextDark = Color3.fromHex("#b8a06a"),
        Stroke = Color3.fromHex("#4a3a1c"),
        Success = Color3.fromHex("#00ff88"),
        Danger = Color3.fromHex("#ff4444"),
        Topbar = Color3.fromHex("#221a0a")
    }
}
for k, v in pairs(Themes[Config.Theme] or Themes["Phantom Red"]) do Theme[k] = v end
local ThemeKeys = {"Background","Sidebar","Container","Section","Accent","Text","TextDark","Stroke","Success","Danger","Topbar"}
local ThemeRegistry = {}
setmetatable(ThemeRegistry, { __mode = "k" })
local function RegisterTheme(instance, propType)
    ThemeRegistry[instance] = propType
    return instance
end
local ThemeHooks = {}
local function OnThemeChanged(fn)
    table.insert(ThemeHooks, fn)
end
local function RunThemeHooks()
    for _, fn in ipairs(ThemeHooks) do pcall(fn) end
end
local function GetParent()
    if CoreGui then return CoreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end
local function Tween(obj, props, time, style, dir)
    time = time or Config.Duration
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    local t = TweenService:Create(obj, TweenInfo.new(time, style, dir), props)
    t:Play()
    return t
end
local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end
local function Stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Stroke
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end
local ThemeScreens = {}
local function CollectThemeScreens()
    table.clear(ThemeScreens)
    if Library.ScreenGui then table.insert(ThemeScreens, Library.ScreenGui) end
    if Library.KeybindList then table.insert(ThemeScreens, Library.KeybindList.Screen) end
    for _, g in pairs(GetParent():GetChildren()) do
        if g.Name == "PhantomMiniButton" or g.Name == "PhantomTooltip" or g.Name == "PhantomNotifications" or g.Name == "PhantomWatermark" or g.Name == "PhantomEmoteWheel" or g.Name == "PhantomConsole" then
            table.insert(ThemeScreens, g)
        end
    end
end
Library.UIHidden = false
function Library:SetUIHidden(state)
    state = state and true or false
    Library.UIHidden = state
    CollectThemeScreens()
    for _, scr in ipairs(ThemeScreens) do
        if scr and scr.Parent and scr:IsA("ScreenGui") then
            pcall(function() scr.Enabled = not state end)
        end
    end
    for _, g in pairs(GetParent():GetChildren()) do
        if g:IsA("ScreenGui") and (g.Name == "PrismaMini" or g.Name == "PrismaKeybinds" or g.Name == "PrismaLoader") then
            pcall(function() g.Enabled = not state end)
        end
    end
end
local function RepaintColor(oldColor, newColor)
    if oldColor == newColor then return end
    CollectThemeScreens()
    for _, scr in ipairs(ThemeScreens) do
        if not (scr and scr.Parent) then continue end
        for _, inst in pairs(scr:GetDescendants()) do
            if inst:IsA("GuiObject") then
                if inst.BackgroundColor3 == oldColor then inst.BackgroundColor3 = newColor end
                if inst.BorderColor3 == oldColor then inst.BorderColor3 = newColor end
            end
            if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
                if inst.TextColor3 == oldColor then inst.TextColor3 = newColor end
            end
            if (inst:IsA("ImageLabel") or inst:IsA("ImageButton")) and inst.ImageColor3 == oldColor then inst.ImageColor3 = newColor end
            if inst:IsA("UIStroke") and inst.Color == oldColor then inst.Color = newColor end
            if inst:IsA("ScrollingFrame") and inst.ScrollBarImageColor3 == oldColor then inst.ScrollBarImageColor3 = newColor end
        end
    end
end
Library.Theme = Theme
Library.CurrentTheme = Themes[Config.Theme] and Config.Theme or "Phantom Red"
Library.Fonts = {Main = Config.FontMain, Bold = Config.FontBold}
function Library:SetTheme(name)
    local palette = Themes[name]
    if not palette then return false end
    for _, key in ipairs(ThemeKeys) do
        local old = Theme[key]
        local new = palette[key]
        if old and new then RepaintColor(old, new) end
    end
    for k, v in pairs(palette) do Theme[k] = v end
    Library.CurrentTheme = name
    RunThemeHooks()
    Library:Notify("Theme", "Theme set to " .. name, 2)
    return true
end
function Library:UpdateTheme(newColor)
    RepaintColor(Theme.Accent, newColor)
    Theme.Accent = newColor
    for instance, propType in pairs(ThemeRegistry) do
        if instance and instance.Parent then
            if propType == "TextColor" then instance.TextColor3 = newColor
            elseif propType == "BackgroundColor" then instance.BackgroundColor3 = newColor
            elseif propType == "BorderColor" then
                if instance:IsA("UIStroke") then instance.Color = newColor else instance.BorderColor3 = newColor end
            elseif propType == "ImageColor" then instance.ImageColor3 = newColor
            elseif propType == "ScrollBar" then instance.ScrollBarImageColor3 = newColor
            end
        end
    end
    RunThemeHooks()
end
local Icons = {
    ["swords"] = {16898613777, 967, 759},
    ["sword"] = {16898613777, 710, 967},
    ["crosshair"] = {16898613044, 453, 869},
    ["target"] = {16898613869, 514, 771},
    ["footprints"] = {16898613353, 918, 710},
    ["person-standing"] = {16898613699, 563, 771},
    ["eye"] = {16898613353, 771, 563},
    ["scan-eye"] = {16898613699, 869, 759},
    ["globe"] = {16898613509, 771, 563},
    ["earth"] = {16898613353, 0, 771},
    ["sparkles"] = {16898613777, 918, 49},
    ["skull"] = {16898613777, 49, 869},
    ["ghost"] = {16898613353, 869, 906},
    ["info"] = {16898613509, 612, 869},
    ["settings"] = {16898613777, 771, 257},
    ["user"] = {16898613869, 661, 869},
    ["users"] = {16898613869, 967, 98},
    ["zap"] = {16898613869, 918, 906},
    ["shield"] = {16898613777, 869, 0},
    ["palette"] = {16898613613, 453, 918},
    ["shirt"] = {16898613777, 98, 771},
    ["wand-sparkles"] = {16898613869, 453, 918},
    ["bug"] = {16898612819, 257, 967},
    ["flame"] = {16898613353, 967, 306},
    ["gamepad-2"] = {16898613353, 710, 967},
    ["star"] = {16898613777, 967, 147},
    ["heart"] = {16898613509, 661, 771},
    ["crown"] = {16898613044, 404, 918},
    ["map"] = {16898613613, 306, 771},
    ["mouse-pointer-click"] = {16898613613, 771, 710},
    ["bot"] = {16898612819, 869, 98},
    ["rocket"] = {16898613699, 918, 147},
    ["wind"] = {16898613869, 820, 857},
    ["move"] = {16898613613, 453, 820},
    ["venetian-mask"] = {16898613869, 918, 404},
    ["fingerprint"] = {16898613353, 563, 918},
    ["gem"] = {16898613353, 918, 857},
    ["radar"] = {16898613699, 820, 404},
    ["bomb"] = {16898612819, 257, 869},
    ["trophy"] = {16898613869, 820, 147},
    ["keyboard"] = {16898613509, 453, 820},
    ["list"] = {16898613509, 869, 808},
    ["bell"] = {16898612819, 820, 257},
    ["lock"] = {16898613509, 918, 857},
    ["key"] = {16898613509, 869, 404},
    ["music"] = {16898613613, 967, 563},
    ["camera"] = {16898612819, 967, 563},
    ["hand"] = {16898613509, 563, 820},
    ["moon"] = {16898613613, 306, 918},
    ["sun"] = {16898613777, 967, 453},
    ["candy"] = {16898612819, 771, 759},
    ["cat"] = {16898612819, 404, 918},
    ["flag"] = {16898613353, 98, 918},
    ["box"] = {16898612819, 771, 196},
    ["package"] = {16898613613, 918, 196},
    ["activity"] = {16898612629, 514, 771},
    ["layers"] = {16898613509, 98, 967},
    ["sliders-horizontal"] = {16898613777, 820, 355},
    ["user-cog"] = {16898613869, 147, 869},
    ["wrench"] = {16898613869, 820, 906},
    ["hammer"] = {16898613509, 306, 820},
    ["car"] = {16898612819, 918, 147},
    ["plane"] = {16898613699, 98, 820},
    ["search"] = {16898613699, 918, 857},
}
local IconPackUrl = "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/icons.lua"
local IconPack
local function ResolveIcon(icon)
    if icon == nil then return nil end
    if type(icon) == "number" or tonumber(icon) then return "rbxassetid://" .. tostring(icon) end
    if type(icon) ~= "string" then return nil end
    if string.find(icon, "://", 1, true) then return icon end
    local name = (string.gsub(string.lower(icon), "^lucide[%-:]", ""))
    local e = Icons[name]
    if not e then
        if IconPack == nil then
            IconPack = false
            pcall(function()
                local t = loadstring(game:HttpGet(IconPackUrl))()
                if type(t) == "table" and type(t["48px"]) == "table" then IconPack = t["48px"] end
            end)
        end
        local r = IconPack and IconPack[name]
        if type(r) == "table" and type(r[3]) == "table" then
            e = {r[1], r[3][1], r[3][2]}
            Icons[name] = e
        end
    end
    if not e then return nil end
    return "rbxassetid://" .. tostring(e[1]), Vector2.new(e[2], e[3]), Vector2.new(48, 48)
end
local function ApplyIcon(img, icon)
    local image, offset, size = ResolveIcon(icon)
    if not image then return false end
    img.Image = image
    if offset then
        img.ImageRectOffset = offset
        img.ImageRectSize = size
    end
    return true
end
Library.Icons = Icons
function Library:GetIcon(icon)
    return ResolveIcon(icon)
end
local function DecorLine(parent, x1, y1, x2, y2, color, transparency, thickness)
    local dx, dy = x2 - x1, y2 - y1
    local f = Instance.new("Frame")
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Position = UDim2.fromOffset((x1 + x2) / 2, (y1 + y2) / 2)
    f.Size = UDim2.fromOffset(math.sqrt(dx * dx + dy * dy), thickness or 1)
    f.Rotation = math.deg(math.atan2(dy, dx))
    f.BackgroundColor3 = color
    f.BackgroundTransparency = transparency or 0
    f.BorderSizePixel = 0
    f.Parent = parent
    return f
end
local function DecorLoop(obj, props, time)
    local t = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), props)
    t:Play()
    return t
end
local function BuildCobweb(parent, position, size, corner)
    local Web = Instance.new("Frame")
    Web.Name = "Cobweb"
    Web.Size = UDim2.fromOffset(size, size)
    Web.Position = position
    Web.AnchorPoint = Vector2.new(corner.X > 0 and 1 or 0, corner.Y > 0 and 1 or 0)
    Web.BackgroundTransparency = 1
    Web.Parent = parent
    local ox, oy = corner.X > 0 and size or 0, corner.Y > 0 and size or 0
    local sx, sy = corner.X > 0 and -1 or 1, corner.Y > 0 and -1 or 1
    local color = Color3.fromHex("#d8cfe0")
    local spokes = 6
    local points = {}
    for i = 0, spokes - 1 do
        local a = math.rad(90 * i / (spokes - 1))
        local px, py = ox + sx * math.cos(a) * size, oy + sy * math.sin(a) * size
        DecorLine(Web, ox, oy, px, py, color, 0.55, 1)
        points[i] = a
    end
    for _, k in ipairs({0.22, 0.42, 0.62, 0.82}) do
        local r = size * k
        for i = 0, spokes - 2 do
            local a1, a2 = points[i], points[i + 1]
            local sag = 0.9
            local x1, y1 = ox + sx * math.cos(a1) * r, oy + sy * math.sin(a1) * r
            local x2, y2 = ox + sx * math.cos(a2) * r, oy + sy * math.sin(a2) * r
            local am = (a1 + a2) / 2
            local xm, ym = ox + sx * math.cos(am) * r * sag, oy + sy * math.sin(am) * r * sag
            DecorLine(Web, x1, y1, xm, ym, color, 0.65, 1)
            DecorLine(Web, xm, ym, x2, y2, color, 0.65, 1)
        end
    end
    return Web
end
local function BuildSpider(parent, xScale, topOffset, length, speed)
    local drop = 10
    local half = length + drop + 26
    local Pivot = Instance.new("Frame")
    Pivot.Name = "Spider"
    Pivot.Size = UDim2.fromOffset(24, half * 2)
    Pivot.AnchorPoint = Vector2.new(0.5, 0.5)
    Pivot.Position = UDim2.new(xScale, 0, 0, topOffset)
    Pivot.BackgroundTransparency = 1
    Pivot.Rotation = -6
    Pivot.Parent = parent
    local Drop = Instance.new("Frame")
    Drop.Size = UDim2.fromOffset(24, length)
    Drop.Position = UDim2.fromOffset(0, half)
    Drop.BackgroundTransparency = 1
    Drop.Parent = Pivot
    local Thread = Instance.new("Frame")
    Thread.Size = UDim2.new(0, 1, 1, 0)
    Thread.Position = UDim2.fromOffset(12, 0)
    Thread.BackgroundColor3 = Color3.fromHex("#d8cfe0")
    Thread.BackgroundTransparency = 0.5
    Thread.BorderSizePixel = 0
    Thread.Parent = Drop
    local Body = Instance.new("Frame")
    Body.Size = UDim2.fromOffset(24, 24)
    Body.Position = UDim2.new(0, 0, 1, -4)
    Body.BackgroundTransparency = 1
    Body.Parent = Drop
    local dark = Color3.fromHex("#2b1a36")
    local Legs = {}
    for _, side in ipairs({-1, 1}) do
        for _, l in ipairs({{-3, -9, -6}, {0, -11, -1}, {3, -11, 4}, {5, -8, 10}}) do
            local y0, kx, ky = l[1], l[2], l[3]
            local kneeX, kneeY = 12 + side * 7, 12 + y0 - 4
            DecorLine(Body, 12, 12 + y0 / 2, kneeX, kneeY, dark, 0, 1.5)
            table.insert(Legs, DecorLine(Body, kneeX, kneeY, 12 - side * kx, 12 + ky, dark, 0, 1.5))
        end
    end
    local Abdomen = Instance.new("Frame")
    Abdomen.Size = UDim2.fromOffset(10, 12)
    Abdomen.Position = UDim2.fromOffset(7, 9)
    Abdomen.BackgroundColor3 = dark
    Abdomen.BorderSizePixel = 0
    Abdomen.Parent = Body
    Corner(Abdomen, 6)
    local Head = Instance.new("Frame")
    Head.Size = UDim2.fromOffset(7, 7)
    Head.Position = UDim2.fromOffset(8.5, 4)
    Head.BackgroundColor3 = dark
    Head.BorderSizePixel = 0
    Head.Parent = Body
    Corner(Head, 4)
    for _, ex in ipairs({1.5, 4}) do
        local Eye = Instance.new("Frame")
        Eye.Size = UDim2.fromOffset(1.5, 1.5)
        Eye.Position = UDim2.fromOffset(ex, 3)
        Eye.BackgroundColor3 = Theme.Accent
        Eye.BorderSizePixel = 0
        Eye.Parent = Head
        RegisterTheme(Eye, "BackgroundColor")
    end
    DecorLoop(Pivot, {Rotation = 6}, speed)
    DecorLoop(Drop, {Size = UDim2.fromOffset(24, length + drop)}, speed * 1.7)
    for i, leg in ipairs(Legs) do
        local r = leg.Rotation
        leg.Rotation = r - 5
        DecorLoop(leg, {Rotation = r + 5}, 0.9 + (i % 4) * 0.15)
    end
    return Pivot
end
local function BuildHalloweenDecor(win)
    local Decor = Instance.new("Frame")
    Decor.Name = "HalloweenDecor"
    Decor.Size = UDim2.new(1, 0, 1, 0)
    Decor.BackgroundTransparency = 1
    Decor.ZIndex = 15
    Decor.Parent = win
    BuildCobweb(Decor, UDim2.new(1, 0, 0, 34), 90, Vector2.new(1, 0))
    BuildCobweb(Decor, UDim2.new(1, 0, 1, 0), 70, Vector2.new(1, 1))
    BuildCobweb(Decor, UDim2.new(0, 0, 0, 34), 70, Vector2.new(0, 0))
    BuildSpider(Decor, 0.62, 34, 26, 2.4)
    BuildSpider(Decor, 0.86, 34, 48, 3.1)
    local GhostFloat = Instance.new("Frame")
    GhostFloat.Size = UDim2.fromOffset(26, 26)
    GhostFloat.Position = UDim2.new(1, -100, 1, -48)
    GhostFloat.BackgroundTransparency = 1
    GhostFloat.Parent = Decor
    local Ghost = Instance.new("ImageLabel")
    Ghost.Size = UDim2.new(1, 0, 1, 0)
    Ghost.BackgroundTransparency = 1
    Ghost.ImageColor3 = Color3.fromHex("#ffffff")
    Ghost.ImageTransparency = 0.7
    Ghost.Rotation = -7
    ApplyIcon(Ghost, "ghost")
    Ghost.Parent = GhostFloat
    DecorLoop(GhostFloat, {Position = UDim2.new(1, -100, 1, -56)}, 3.6)
    DecorLoop(Ghost, {Rotation = 7}, 2.6)
    DecorLoop(Ghost, {ImageTransparency = 0.85}, 3.1)
    local Moon = Instance.new("ImageLabel")
    Moon.Size = UDim2.fromOffset(18, 18)
    Moon.Position = UDim2.new(0, 196, 1, -28)
    Moon.BackgroundTransparency = 1
    Moon.ImageColor3 = Theme.Accent
    Moon.ImageTransparency = 0.6
    ApplyIcon(Moon, "moon")
    Moon.Parent = Decor
    RegisterTheme(Moon, "ImageColor")
    return Decor
end
Library.HubConfig = {
    Name = "Phantom Softworks",
    Game = "",
    Socials = {
        Discord = "https://discord.gg/RvXDcYHYdt",
        YouTube = "https://www.youtube.com/watch?v=K9EhYXEqIYc",
    },
    UpdateLog = {
        Date = "Aug 20, 2026",
         Added = {
            "Rewrote Whole UI",
            "Info tab with Change Log and My social links",
            "New 6 Themes, can be found in Settings",
        },
        Fixed = {
            "Ui bugs for Mobile Users",
        },
    },
}
function Library:SetHub(config)
    if type(config) == "table" then
        for k, v in pairs(config) do
            if type(v) == "table" and type(Library.HubConfig[k]) == "table" then
                for kk, vv in pairs(v) do Library.HubConfig[k][kk] = vv end
            else
                Library.HubConfig[k] = v
            end
        end
    end
end
local function CopyLink(link, name)
    if not link or link == "" then return end
    local ok = pcall(function() setclipboard(link) end)
    if ok then
        Library:Notify("Link", (name or "Link") .. " link copied to clipboard!", 2)
    else
        Library:Notify(name or "Link", link, 6)
    end
end
local function RoundToIncrement(value, increment)
    if increment <= 0 then return value end
    return math.round(value / increment) * increment
end
local function FormatNumber(value, increment)
    if increment >= 1 then
        return tostring(math.round(value))
    end
    local str = tostring(increment)
    local dotPos = string.find(str, "%.")
    if dotPos then
        local decimals = #str - dotPos
        return string.format("%." .. decimals .. "f", value)
    end
    return tostring(value)
end
local Drag_Update, Drag_Input, Drag_Driver = nil, nil, nil
local function EnsureDragDriver()
    if Drag_Driver then return end
    local a = UserInputService.InputChanged:Connect(function(input)
        if Drag_Update and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Drag_Input = input
        end
    end)
    local b = RunService.RenderStepped:Connect(function()
        if Drag_Update and Drag_Input then Drag_Update(Drag_Input) end
    end)
    Drag_Driver = {a, b}
end
local function BeginDrag(input, update, onEnd)
    EnsureDragDriver()
    Drag_Update = update
    Drag_Input = input
    local c
    c = input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            if Drag_Update == update then Drag_Update = nil Drag_Input = nil end
            c:Disconnect()
            if onEnd then onEnd() end
        end
    end)
end
local function MakeDraggable(dragArea, frame, onDragCallback)
    local dragging = false
    local c1 = dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local dragStart = input.Position
            local startPos = frame.Position
            BeginDrag(input, function(cur)
                local delta = cur.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                if onDragCallback then onDragCallback(true) end
            end, function()
                dragging = false
                if onDragCallback then onDragCallback(false) end
            end)
        end
    end)
    table.insert(Library.Connections, c1)
    return function() return dragging end
end
local function MakeResizable(resizeBtn, frame, minSize)
    local c1 = resizeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local dragStart = input.Position
            local startSize = frame.Size
            local startPos = frame.Position
            local scaleObj = frame:FindFirstChildWhichIsA("UIScale")
            local scaleMult = scaleObj and scaleObj.Scale or 1
            if scaleMult <= 0 then scaleMult = 1 end
            BeginDrag(input, function(cur)
                local delta = cur.Position - dragStart
                local newX = math.max(minSize.X, startSize.X.Offset + (delta.X / scaleMult))
                local newY = math.max(minSize.Y, startSize.Y.Offset + (delta.Y / scaleMult))
                local diffX = (newX - startSize.X.Offset) * scaleMult
                local diffY = (newY - startSize.Y.Offset) * scaleMult
                frame.Size = UDim2.new(0, newX, 0, newY)
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (diffX / 2), startPos.Y.Scale, startPos.Y.Offset + (diffY / 2))
            end)
        end
    end)
    table.insert(Library.Connections, c1)
end
local function GetBaseScale()
    local vp = workspace.CurrentCamera.ViewportSize
    if vp.X < 1 or vp.Y < 1 then return 1 end
    local scaleX = vp.X / 950
    local scaleY = vp.Y / 560
    local scale = math.min(scaleX, scaleY)
    if scale < 1 then
        return math.clamp(scale * 0.95, 0.4, 1)
    end
    return 1
end
Library.Logs = {}
Library.LogLimit = 200
local LogLevels = {Info = true, Warning = true, Error = true}
local LogListeners = {}
local function LogColor(level)
    if level == "Warning" then return Color3.fromHex("#ffc23d") end
    if level == "Error" then return Theme.Danger end
    return Theme.Text
end
function Library:Log(level, message)
    if not LogLevels[level] then level = "Info" end
    local entry = {Level = level, Text = tostring(message), Time = os.date("%H:%M:%S")}
    table.insert(Library.Logs, entry)
    if #Library.Logs > Library.LogLimit then table.remove(Library.Logs, 1) end
    for _, fn in ipairs(LogListeners) do pcall(fn, entry) end
    return entry
end
function Library:Info(message) return Library:Log("Info", message) end
function Library:Warn(message) return Library:Log("Warning", message) end
function Library:Error(message) return Library:Log("Error", message) end
function Library:ClearLogs()
    table.clear(Library.Logs)
    for _, fn in ipairs(LogListeners) do pcall(fn, nil) end
end
function Library:Try(name, fn, ...)
    if type(name) == "function" then return Library:Try("Script", name, fn, ...) end
    local res = table.pack(pcall(fn, ...))
    if not res[1] then Library:Log("Error", tostring(name) .. ": " .. tostring(res[2])) end
    return table.unpack(res, 1, res.n)
end
local Capturing = false
local CaptureConn
local CaptureLevels = {
    [Enum.MessageType.MessageOutput] = "Info",
    [Enum.MessageType.MessageInfo] = "Info",
    [Enum.MessageType.MessageWarning] = "Warning",
    [Enum.MessageType.MessageError] = "Error"
}
function Library:CaptureOutput(enabled, includePrints)
    if CaptureConn then CaptureConn:Disconnect() CaptureConn = nil end
    Capturing = enabled and true or false
    if not Capturing then return end
    CaptureConn = game:GetService("LogService").MessageOut:Connect(function(msg, msgType)
        local level = CaptureLevels[msgType]
        if not level or (level == "Info" and includePrints == false) then return end
        if msg:find("^Stack Begin") or msg:find("^Stack End") or msg:find("^Script '.-', Line %d+") then return end
        Library:Log(level, msg)
    end)
    table.insert(Library.Connections, CaptureConn)
end
local function WrapCallback(name, callback, isToggle)
    callback = callback or function() end
    return function(...)
        if isToggle then
            Library:Log("Info", tostring(name) .. ((...) and " enabled" or " disabled"))
        end
        local ok, err = pcall(callback, ...)
        if not ok then
            Library:Log("Error", tostring(name) .. ": " .. tostring(err))
            if not Capturing then warn(err) end
        end
    end
end
function Library:Unload()
    for _, conn in ipairs(Library.Connections) do pcall(function() conn:Disconnect() end) end
    Library.Connections = {}
    if Drag_Driver then
        for _, c in ipairs(Drag_Driver) do pcall(function() c:Disconnect() end) end
        Drag_Driver = nil
        Drag_Update = nil
        Drag_Input = nil
    end
    if Library.ScreenGui then pcall(function() Library.ScreenGui:Destroy() end) Library.ScreenGui = nil end
    if Library.KeybindList then pcall(function() Library.KeybindList.Screen:Destroy() end) Library.KeybindList = nil end
    Library.Binds = {}
    Library.BindOrder = {}
    Library.SearchIndex = {}
    table.clear(ThemeHooks)
    table.clear(LogListeners)
    Library.Console = nil
    for _, g in pairs(GetParent():GetChildren()) do
        if g.Name == "PrismaMini" or g.Name == Config.Name or g.Name == "PrismaKeybinds" or g.Name == "PrismaLoader" or g.Name == "PhantomNotifications" or g.Name == "PhantomWatermark" or g.Name == "PhantomTooltip" or g.Name == "PhantomMiniButton" or g.Name == "PhantomConsole" then
            pcall(function() g:Destroy() end)
        end
    end
end
function Library:GetConfigs()
    local configs = {}
    if isfolder(Config.ConfigFolder) then
        local files = listfiles(Config.ConfigFolder)
        for _, file in ipairs(files) do
            if string.sub(file, -5) == ".json" then
                local name = string.match(string.gsub(file, "\\", "/"), "([^/]+)%.json$") or file
                if name ~= "_autosave" then
                    table.insert(configs, name)
                end
            end
        end
    end
    return configs
end
local IgnoredFlags = {
    ConfigSelectorFlag = true,
    MenuAccentColor = true,
    SelectedTheme = true,
    KeybindListToggle = true,
    ConsoleToggle = true,
}
local function SerializeConfigValue(v)
    if typeof(v) == "Color3" then
        return {Type = "Color3", Hex = v:ToHex()}
    elseif typeof(v) == "EnumItem" then
        local enumName = tostring(v.EnumType):match("Enum%.(.+)") or tostring(v.EnumType)
        return {Type = "EnumItem", EnumType = enumName, Name = v.Name}
    elseif type(v) == "table" then
        local serialized = {}
        for tk, tv in pairs(v) do
            serialized[tk] = SerializeConfigValue(tv)
        end
        return {Type = "Table", Value = serialized}
    end
    return v
end
local function DeserializeConfigValue(value)
    if type(value) == "table" then
        if value.Type == "Color3" then
            local c = Color3.new(1, 1, 1)
            pcall(function() c = Color3.fromHex(value.Hex) end)
            return c
        elseif value.Type == "EnumItem" then
            local e
            pcall(function() e = Enum[value.EnumType][value.Name] end)
            return e
        elseif value.Type == "Table" then
            local deserialized = {}
            if type(value.Value) == "table" then
                for tk, tv in pairs(value.Value) do
                    deserialized[tk] = DeserializeConfigValue(tv)
                end
            end
            return deserialized
        end
    end
    return value
end
function Library:SaveConfig(name)
    if not name or name == "" then return false end
    local saveFlags = {}
    for k, v in pairs(Library.Flags) do
        if IgnoredFlags[k] then continue end
        saveFlags[k] = SerializeConfigValue(v)
    end
    local ok, json = pcall(HttpService.JSONEncode, HttpService, saveFlags)
    if ok then
        pcall(function()
            writefile(Config.ConfigFolder .. "/" .. name .. ".json", json)
        end)
        return true
    end
    return false
end
function Library:LoadConfig(name)
    if not name or name == "" then return false end
    local path = Config.ConfigFolder .. "/" .. name .. ".json"
    if not isfile(path) then return false end
    local content = readfile(path)
    local success, data = pcall(HttpService.JSONDecode, HttpService, content)
    if success and type(data) == "table" then
        for flag, value in pairs(data) do
            if IgnoredFlags[flag] then continue end
            Library.Flags[flag] = DeserializeConfigValue(value)
        end
        for flag, value in pairs(Library.Flags) do
            if IgnoredFlags[flag] then continue end
            if data[flag] ~= nil and Library.Signals[flag] then
                task.spawn(Library.Signals[flag], value)
            end
        end
        return true
    end
    return false
end
function Library:DeleteConfig(name)
    if not name or name == "" then return false end
    local path = Config.ConfigFolder .. "/" .. name .. ".json"
    if isfile(path) then
        pcall(function() delfile(path) end)
        return true
    end
    return false
end
function Library:ConfigExists(name)
    if not name or name == "" then return false end
    return isfile(Config.ConfigFolder .. "/" .. name .. ".json")
end
local TooltipGui = Instance.new("ScreenGui")
TooltipGui.Name = "PhantomTooltip"
TooltipGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
TooltipGui.Parent = GetParent()
local TooltipLabel = Instance.new("TextLabel")
TooltipLabel.BackgroundTransparency = 0.05
TooltipLabel.BackgroundColor3 = Theme.Container
TooltipLabel.TextColor3 = Theme.Text
TooltipLabel.Font = Config.FontMain
TooltipLabel.TextSize = 12
TooltipLabel.Visible = false
TooltipLabel.Parent = TooltipGui
TooltipLabel.ZIndex = 1000
Corner(TooltipLabel, 4)
Stroke(TooltipLabel, Theme.Stroke, 1)
local function ApplyTooltip(guiObj, text)
    if not text or text == "" then return end
    local hovered = false
    local c1 = guiObj.MouseEnter:Connect(function()
        hovered = true
        task.delay(0.5, function()
            if hovered and Library.Open then
                TooltipLabel.Text = " " .. text .. " "
                TooltipLabel.Size = UDim2.new(0, TooltipLabel.TextBounds.X + 10, 0, 20)
                local mPos = UserInputService:GetMouseLocation()
                TooltipLabel.Position = UDim2.new(0, mPos.X + 10, 0, mPos.Y - 25)
                TooltipLabel.Visible = true
            end
        end)
    end)
    local c2 = guiObj.MouseMoved:Connect(function()
        if TooltipLabel.Visible then
            local mPos = UserInputService:GetMouseLocation()
            TooltipLabel.Position = UDim2.new(0, mPos.X + 10, 0, mPos.Y - 25)
        end
    end)
    local c3 = guiObj.MouseLeave:Connect(function()
        hovered = false
        TooltipLabel.Visible = false
    end)
    table.insert(Library.Connections, c1)
    table.insert(Library.Connections, c2)
    table.insert(Library.Connections, c3)
end
function Library:Notify(title, text, duration)
    local lowered = string.lower(tostring(title) .. " " .. tostring(text))
    local level = (lowered:find("error") or lowered:find("fail")) and "Error" or lowered:find("warn") and "Warning" or "Info"
    Library:Log(level, tostring(title) .. ": " .. tostring(text))
    local NotifGui = GetParent():FindFirstChild("PhantomNotifications")
    if not NotifGui then
        NotifGui = Instance.new("ScreenGui")
        NotifGui.Name = "PhantomNotifications"
        NotifGui.Parent = GetParent()
        local Container = Instance.new("Frame")
        Container.Name = "Container"
        Container.Size = UDim2.new(0, 250, 1, -20)
        Container.Position = UDim2.new(1, -270, 0, 10)
        Container.BackgroundTransparency = 1
        Container.Parent = NotifGui
        local Layout = Instance.new("UIListLayout")
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        Layout.Padding = UDim.new(0, 10)
        Layout.Parent = Container
    end
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(1, 0, 0, 60)
    NotifFrame.BackgroundColor3 = Theme.Background
    NotifFrame.BackgroundTransparency = 0.1
    NotifFrame.Position = UDim2.new(1, 300, 0, 0)
    NotifFrame.Parent = NotifGui.Container
    Corner(NotifFrame, 6)
    Stroke(NotifFrame, Theme.Stroke, 1)
    local NNoise = Instance.new("ImageLabel")
    NNoise.Size = UDim2.new(1, 0, 1, 0)
    NNoise.BackgroundTransparency = 1
    NNoise.Image = "rbxassetid://9968344105"
    NNoise.ImageTransparency = 0.9
    NNoise.ScaleType = Enum.ScaleType.Tile
    NNoise.TileSize = UDim2.new(0, 100, 0, 100)
    NNoise.Parent = NotifFrame
    Corner(NNoise, 6)
    local NTitle = Instance.new("TextLabel")
    NTitle.Size = UDim2.new(1, -10, 0, 20)
    NTitle.Position = UDim2.new(0, 10, 0, 5)
    NTitle.BackgroundTransparency = 1
    NTitle.Text = title
    NTitle.TextColor3 = Theme.Accent
    NTitle.Font = Config.FontBold
    NTitle.TextSize = 13
    NTitle.TextXAlignment = Enum.TextXAlignment.Left
    NTitle.Parent = NotifFrame
    RegisterTheme(NTitle, "TextColor")
    local NText = Instance.new("TextLabel")
    NText.Size = UDim2.new(1, -20, 0, 20)
    NText.Position = UDim2.new(0, 10, 0, 25)
    NText.BackgroundTransparency = 1
    NText.Text = text
    NText.TextColor3 = Theme.Text
    NText.Font = Config.FontMain
    NText.TextSize = 12
    NText.TextXAlignment = Enum.TextXAlignment.Left
    NText.Parent = NotifFrame
    local TimebarBg = Instance.new("Frame")
    TimebarBg.Size = UDim2.new(1, 0, 0, 2)
    TimebarBg.Position = UDim2.new(0, 0, 1, -2)
    TimebarBg.BackgroundColor3 = Theme.Container
    TimebarBg.BorderSizePixel = 0
    TimebarBg.Parent = NotifFrame
    Corner(TimebarBg, 2)
    local Timebar = Instance.new("Frame")
    Timebar.Size = UDim2.new(1, 0, 1, 0)
    Timebar.BackgroundColor3 = Theme.Accent
    Timebar.BorderSizePixel = 0
    Timebar.Parent = TimebarBg
    Corner(Timebar, 2)
    RegisterTheme(Timebar, "BackgroundColor")
    Tween(NotifFrame, {Position = UDim2.new(0, 0, 0, 0)}, 0.4)
    Tween(Timebar, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear)
    task.delay(duration, function()
        Tween(NotifFrame, {Position = UDim2.new(1, 300, 0, 0)}, 0.4).Completed:Wait()
        NotifFrame:Destroy()
    end)
end
function Library:InitWatermark()
    local WatermarkGui = Instance.new("ScreenGui")
    WatermarkGui.Name = "PhantomWatermark"
    WatermarkGui.Parent = GetParent()
    WatermarkGui.IgnoreGuiInset = true
    WatermarkGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 0, 0, 26)
    Frame.Position = UDim2.new(1, -20, 0, 10)
    Frame.AnchorPoint = Vector2.new(1, 0)
    Frame.BackgroundColor3 = Theme.Background
    Frame.BackgroundTransparency = 0.05
    Frame.Parent = WatermarkGui
    Corner(Frame, 4)
    Stroke(Frame, Theme.Stroke, 1)
    local Glow = Stroke(Frame, Theme.Accent, 2, 0.8)
    RegisterTheme(Glow, "BorderColor")
    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.Position = UDim2.new(0, 0, 0, 0)
    AccentLine.BackgroundColor3 = Theme.Accent
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = Frame
    Corner(AccentLine, 2)
    RegisterTheme(AccentLine, "BackgroundColor")
    local WNoise = Instance.new("ImageLabel")
    WNoise.Size = UDim2.new(1, 0, 1, 0)
    WNoise.BackgroundTransparency = 1
    WNoise.Image = "rbxassetid://9968344105"
    WNoise.ImageTransparency = 0.95
    WNoise.ScaleType = Enum.ScaleType.Tile
    WNoise.TileSize = UDim2.new(0, 100, 0, 100)
    WNoise.Parent = Frame
    Corner(WNoise, 4)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Config.FontBold
    Label.TextSize = 12
    Label.TextColor3 = Theme.Text
    Label.RichText = true
    Label.Parent = Frame
    local lastUpdate = 0
    local frames = 0
    local conn
    conn = RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local now = os.clock()
        if now - lastUpdate >= 1 then
            local fps = frames
            frames = 0
            lastUpdate = now
            local ping = "0"
            pcall(function()
                local s = Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
                ping = s:match("%d+") or "0"
            end)
            local timeStr = os.date("%H:%M:%S")
            local text = string.format(" <font color='#%s'>%s</font> | FPS: %d | Ping: %sms | %s ", Theme.Accent:ToHex(), Config.Brand, fps, ping, timeStr)
            Label.Text = text
            local bounds = Label.TextBounds.X + 20
            Tween(Frame, {Size = UDim2.new(0, bounds, 0, 26)}, 0.1)
        end
    end)
    table.insert(Library.Connections, conn)
end
function Library:CreateKeybindList()
    if Library.KeybindList then return end
    local Screen = Instance.new("ScreenGui")
    Screen.Name = "PrismaKeybinds"
    Screen.Parent = GetParent()
    Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local listWidth = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) and 200 or 180
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, listWidth, 0, 30)
    Frame.Position = UDim2.new(0.01, 0, 0.18, 0)
    Frame.BackgroundColor3 = Theme.Background
    Frame.BackgroundTransparency = 0.1
    Frame.Parent = Screen
    Frame.Active = true
    Frame.ClipsDescendants = true
    Corner(Frame, 4)
    Stroke(Frame, Theme.Stroke, 1, 0)
    MakeDraggable(Frame, Frame)
    local KNoise = Instance.new("ImageLabel")
    KNoise.Size = UDim2.new(1, 0, 1, 0)
    KNoise.BackgroundTransparency = 1
    KNoise.Image = "rbxassetid://9968344105"
    KNoise.ImageTransparency = 0.9
    KNoise.ScaleType = Enum.ScaleType.Tile
    KNoise.TileSize = UDim2.new(0, 100, 0, 100)
    KNoise.Parent = Frame
    Corner(KNoise, 4)
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 24)
    Header.BackgroundColor3 = Theme.Sidebar
    Header.Parent = Frame
    Corner(Header, 4)
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Keybinds"
    Title.TextColor3 = Theme.Accent
    Title.Font = Config.FontBold
    Title.TextSize = 12
    Title.Parent = Header
    RegisterTheme(Title, "TextColor")
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 0)
    Container.Position = UDim2.new(0, 0, 0, 26)
    Container.BackgroundTransparency = 1
    Container.Parent = Frame
    local List = Instance.new("UIListLayout")
    List.SortOrder = Enum.SortOrder.LayoutOrder
    List.Parent = Container
    local c1 = List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Frame.Size = UDim2.new(0, listWidth, 0, List.AbsoluteContentSize.Y + 30)
    end)
    table.insert(Library.Connections, c1)
    Library.KeybindList = {Frame = Frame, Container = Container, Screen = Screen, Title = Title}
    Frame.Visible = false
end
function Library:CreateConsole()
    if Library.Console then return Library.Console end
    local mobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local HEADER_H = 30
    local width, height = mobile and 320 or 440, mobile and 200 or 250
    local LevelNames = {Info = "Info", Warning = "Warn", Error = "Error"}
    local logRows, rowOrder, open = {}, 0, true
    local function EscapeRich(str)
        return (str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
    end
    local Screen = Instance.new("ScreenGui")
    Screen.Name = "PhantomConsole"
    Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Screen.ResetOnSpawn = false
    Screen.Enabled = not Library.UIHidden
    Screen.Parent = GetParent()
    local Frame = Instance.new("Frame")
    Frame.Name = "Console"
    Frame.Size = UDim2.new(0, width, 0, height)
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.Position = UDim2.new(0, 20 + width / 2, 1, -(20 + height / 2))
    Frame.BackgroundColor3 = Theme.Background
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.ClipsDescendants = true
    Frame.Visible = false
    Frame.Parent = Screen
    Corner(Frame, 6)
    Stroke(Frame, Theme.Stroke, 1, 0)
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, HEADER_H)
    Header.BackgroundColor3 = Theme.Topbar
    Header.BorderSizePixel = 0
    Header.Active = true
    Header.Parent = Frame
    Corner(Header, 6)
    local HeaderFill = Instance.new("Frame")
    HeaderFill.Size = UDim2.new(1, 0, 0, 8)
    HeaderFill.Position = UDim2.new(0, 0, 1, -8)
    HeaderFill.BackgroundColor3 = Theme.Topbar
    HeaderFill.BorderSizePixel = 0
    HeaderFill.Parent = Header
    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(1, 0, 0, 1)
    Divider.Position = UDim2.new(0, 0, 0, HEADER_H)
    Divider.BackgroundColor3 = Theme.Stroke
    Divider.BorderSizePixel = 0
    Divider.Parent = Frame
    MakeDraggable(Header, Frame)
    local TitleRow = Instance.new("Frame")
    TitleRow.Size = UDim2.new(0.5, 0, 1, 0)
    TitleRow.Position = UDim2.new(0, 10, 0, 0)
    TitleRow.BackgroundTransparency = 1
    TitleRow.Parent = Header
    local TitleList = Instance.new("UIListLayout")
    TitleList.FillDirection = Enum.FillDirection.Horizontal
    TitleList.VerticalAlignment = Enum.VerticalAlignment.Center
    TitleList.SortOrder = Enum.SortOrder.LayoutOrder
    TitleList.Padding = UDim.new(0, 6)
    TitleList.Parent = TitleRow
    local Title = Instance.new("TextLabel")
    Title.AutomaticSize = Enum.AutomaticSize.X
    Title.Size = UDim2.new(0, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Console"
    Title.Font = Config.FontBold
    Title.TextSize = 13
    Title.TextColor3 = Theme.Text
    Title.LayoutOrder = 1
    Title.Parent = TitleRow
    local CountLabel = Instance.new("TextLabel")
    CountLabel.AutomaticSize = Enum.AutomaticSize.X
    CountLabel.Size = UDim2.new(0, 0, 1, 0)
    CountLabel.BackgroundTransparency = 1
    CountLabel.Text = "0"
    CountLabel.Font = Config.FontMain
    CountLabel.TextSize = 12
    CountLabel.TextColor3 = Theme.TextDark
    CountLabel.LayoutOrder = 2
    CountLabel.Parent = TitleRow
    local ArrowBtn = Instance.new("ImageButton")
    ArrowBtn.Size = UDim2.new(0, 22, 0, 22)
    ArrowBtn.Position = UDim2.new(1, -6, 0.5, 0)
    ArrowBtn.AnchorPoint = Vector2.new(1, 0.5)
    ArrowBtn.BackgroundTransparency = 1
    ArrowBtn.Image = "rbxassetid://10709790948"
    ArrowBtn.ImageColor3 = Theme.TextDark
    ArrowBtn.AutoButtonColor = false
    ArrowBtn.Parent = Header
    local function LinkButton(text, xOffset)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 36, 1, 0)
        btn.Position = UDim2.new(1, xOffset, 0, 0)
        btn.AnchorPoint = Vector2.new(1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = text
        btn.Font = Config.FontBold
        btn.TextSize = 12
        btn.TextColor3 = Theme.TextDark
        btn.TextXAlignment = Enum.TextXAlignment.Right
        btn.AutoButtonColor = false
        btn.Parent = Header
        table.insert(Library.Connections, btn.MouseEnter:Connect(function() Tween(btn, {TextColor3 = Theme.Text}, 0.15) end))
        table.insert(Library.Connections, btn.MouseLeave:Connect(function() Tween(btn, {TextColor3 = Theme.TextDark}, 0.15) end))
        return btn
    end
    local ClearBtn = LinkButton("Clear", -34)
    local CopyBtn = LinkButton("Copy", -78)
    local LogBox = Instance.new("ScrollingFrame")
    LogBox.Size = UDim2.new(1, 0, 1, -(HEADER_H + 1))
    LogBox.Position = UDim2.new(0, 0, 0, HEADER_H + 1)
    LogBox.BackgroundColor3 = Theme.Background
    LogBox.BorderSizePixel = 0
    LogBox.ScrollBarThickness = 2
    LogBox.ScrollBarImageColor3 = Theme.Accent
    LogBox.ScrollBarImageTransparency = 0
    LogBox.AutomaticCanvasSize = Enum.AutomaticSize.Y
    LogBox.CanvasSize = UDim2.new(0, 0, 0, 0)
    LogBox.ScrollingDirection = Enum.ScrollingDirection.Y
    LogBox.Parent = Frame
    RegisterTheme(LogBox, "ScrollBar")
    Corner(LogBox, 6)
    local LogPad = Instance.new("UIPadding")
    LogPad.PaddingTop = UDim.new(0, 6)
    LogPad.PaddingBottom = UDim.new(0, 14)
    LogPad.PaddingLeft = UDim.new(0, 10)
    LogPad.PaddingRight = UDim.new(0, 12)
    LogPad.Parent = LogBox
    local LogList = Instance.new("UIListLayout")
    LogList.SortOrder = Enum.SortOrder.LayoutOrder
    LogList.Padding = UDim.new(0, 3)
    LogList.Parent = LogBox
    local EmptyLabel = Instance.new("TextLabel")
    EmptyLabel.Size = UDim2.new(1, 0, 0, 18)
    EmptyLabel.BackgroundTransparency = 1
    EmptyLabel.Text = "No output yet"
    EmptyLabel.Font = Config.FontMain
    EmptyLabel.TextSize = 13
    EmptyLabel.TextColor3 = Theme.TextDark
    EmptyLabel.TextXAlignment = Enum.TextXAlignment.Left
    EmptyLabel.LayoutOrder = 0
    EmptyLabel.Parent = LogBox
    local Resizer = Instance.new("TextButton")
    Resizer.Size = UDim2.new(0, 16, 0, 16)
    Resizer.Position = UDim2.new(1, 0, 1, 0)
    Resizer.AnchorPoint = Vector2.new(1, 1)
    Resizer.BackgroundTransparency = 1
    Resizer.Text = "◢"
    Resizer.TextSize = 12
    Resizer.TextColor3 = Theme.TextDark
    Resizer.AutoButtonColor = false
    Resizer.ZIndex = 5
    Resizer.Parent = Frame
    MakeResizable(Resizer, Frame, Vector2.new(260, 120))
    table.insert(Library.Connections, Resizer.MouseEnter:Connect(function() Tween(Resizer, {TextColor3 = Theme.Accent}, 0.15) end))
    table.insert(Library.Connections, Resizer.MouseLeave:Connect(function() Tween(Resizer, {TextColor3 = Theme.TextDark}, 0.15) end))
    local function UpdateCount()
        CountLabel.Text = tostring(#Library.Logs)
    end
    local function AddLogRow(entry)
        rowOrder = rowOrder + 1
        local Line = Instance.new("TextLabel")
        Line.Name = "LogLine"
        Line.Size = UDim2.new(1, 0, 0, 0)
        Line.AutomaticSize = Enum.AutomaticSize.Y
        Line.BackgroundTransparency = 1
        Line.RichText = true
        Line.Text = '<font color="#' .. Theme.TextDark:ToHex() .. '">[' .. entry.Time .. ']</font> ['
            .. LevelNames[entry.Level] .. '] ' .. EscapeRich(entry.Text)
        Line.Font = Config.FontMain
        Line.TextSize = 13
        Line.TextColor3 = LogColor(entry.Level)
        Line.TextWrapped = true
        Line.TextXAlignment = Enum.TextXAlignment.Left
        Line.TextYAlignment = Enum.TextYAlignment.Top
        Line.LayoutOrder = rowOrder
        Line.Parent = LogBox
        table.insert(logRows, Line)
        if #logRows > Library.LogLimit then
            local old = table.remove(logRows, 1)
            if old then old:Destroy() end
        end
        EmptyLabel.Visible = false
        UpdateCount()
        task.defer(function()
            if LogBox.Parent then LogBox.CanvasPosition = Vector2.new(0, LogBox.AbsoluteCanvasSize.Y) end
        end)
    end
    local function RebuildConsole()
        for _, row in ipairs(logRows) do row:Destroy() end
        table.clear(logRows)
        for _, entry in ipairs(Library.Logs) do AddLogRow(entry) end
        EmptyLabel.Visible = #logRows == 0
        UpdateCount()
    end
    local expandedHeight = height
    local function SetOpen(state)
        open = state
        if open then
            HeaderFill.Visible = true
            Divider.Visible = true
            Resizer.Visible = true
        else
            expandedHeight = Frame.Size.Y.Offset
            Resizer.Visible = false
        end
        Tween(ArrowBtn, {Rotation = open and 0 or -90}, 0.2)
        local t = Tween(Frame, {Size = UDim2.new(0, Frame.Size.X.Offset, 0, open and expandedHeight or HEADER_H)}, 0.25)
        if not open then
            t.Completed:Connect(function()
                if not open then
                    HeaderFill.Visible = false
                    Divider.Visible = false
                end
            end)
        end
    end
    table.insert(Library.Connections, ArrowBtn.MouseButton1Click:Connect(function() SetOpen(not open) end))
    table.insert(Library.Connections, ArrowBtn.MouseEnter:Connect(function() Tween(ArrowBtn, {ImageColor3 = Theme.Text}, 0.15) end))
    table.insert(Library.Connections, ArrowBtn.MouseLeave:Connect(function() Tween(ArrowBtn, {ImageColor3 = Theme.TextDark}, 0.15) end))
    table.insert(Library.Connections, CopyBtn.MouseButton1Click:Connect(function()
        local lines = {}
        for _, entry in ipairs(Library.Logs) do
            table.insert(lines, "[" .. entry.Time .. "] [" .. LevelNames[entry.Level] .. "] " .. entry.Text)
        end
        local ok = pcall(function() setclipboard(table.concat(lines, "\n")) end)
        if ok then Library:Notify("Console", "Logs copied", 2) else Library:Notify("Console", "Clipboard not supported", 2) end
    end))
    table.insert(Library.Connections, ClearBtn.MouseButton1Click:Connect(function()
        Library:ClearLogs()
    end))
    table.insert(LogListeners, function(entry)
        if entry == nil then RebuildConsole() else AddLogRow(entry) end
    end)
    OnThemeChanged(RebuildConsole)
    RebuildConsole()
    Library.Console = {Screen = Screen, Frame = Frame, SetOpen = SetOpen}
    return Library.Console
end
function Library:SetConsoleVisible(state)
    local console = Library.Console or Library:CreateConsole()
    console.Frame.Visible = state and true or false
end
local function IsTouchOnly()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end
local function BindHasKey(key)
    return key ~= nil and key ~= "None" and key ~= "Unknown" and key ~= ""
end
local function BindIsListed(entry)
    if IsTouchOnly() then return false end
    return BindHasKey(entry.Key) and entry.Mode ~= "Always"
end
local function RefreshBindList()
    if not Library.KeybindList then return end
    local shown = 0
    for _, name in ipairs(Library.BindOrder) do
        local entry = Library.Binds[name]
        if entry and entry.Row then
            local listed = BindIsListed(entry)
            entry.Row.Visible = listed
            if listed then
                shown = shown + 1
                entry.Row.LayoutOrder = shown
                local color = entry.Active and Theme.Accent or Theme.TextDark
                entry.Dot.BackgroundColor3 = color
                entry.NameLabel.TextColor3 = entry.Active and Theme.Text or Theme.TextDark
                entry.KeyLabel.Text = BindHasKey(entry.Key) and ("[" .. tostring(entry.Key) .. "]") or (entry.Toggle and (entry.Active and "ON" or "OFF") or "")
                entry.KeyLabel.TextColor3 = color
            end
        end
    end
    Library.KeybindList.Title.Text = "Keybinds"
    Library.KeybindList.Frame.Visible = Library.ShowKeybinds and shown > 0
end
Library.RefreshBindList = function() RefreshBindList() end
local function CreateBindRow(name, entry)
    local Row = Instance.new("TextButton")
    Row.Name = name
    Row.Size = UDim2.new(1, -8, 0, 22)
    Row.Position = UDim2.new(0, 4, 0, 0)
    Row.BackgroundColor3 = Theme.Container
    Row.BackgroundTransparency = 1
    Row.AutoButtonColor = false
    Row.Text = ""
    Row.Visible = false
    Row.Parent = Library.KeybindList.Container
    Corner(Row, 4)
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 8, 0, 8)
    Dot.Position = UDim2.new(0, 6, 0.5, 0)
    Dot.AnchorPoint = Vector2.new(0, 0.5)
    Dot.BackgroundColor3 = Theme.TextDark
    Dot.BorderSizePixel = 0
    Dot.Parent = Row
    Corner(Dot, 4)
    local LName = Instance.new("TextLabel")
    LName.Size = UDim2.new(1, -70, 1, 0)
    LName.Position = UDim2.new(0, 20, 0, 0)
    LName.BackgroundTransparency = 1
    LName.Text = name
    LName.TextColor3 = Theme.TextDark
    LName.Font = Config.FontMain
    LName.TextSize = 12
    LName.TextXAlignment = Enum.TextXAlignment.Left
    LName.TextTruncate = Enum.TextTruncate.AtEnd
    LName.Parent = Row
    local LKey = Instance.new("TextLabel")
    LKey.Size = UDim2.new(0, 46, 1, 0)
    LKey.Position = UDim2.new(1, -6, 0, 0)
    LKey.AnchorPoint = Vector2.new(1, 0)
    LKey.BackgroundTransparency = 1
    LKey.Text = ""
    LKey.TextColor3 = Theme.TextDark
    LKey.Font = Config.FontMain
    LKey.TextSize = 12
    LKey.TextXAlignment = Enum.TextXAlignment.Right
    LKey.Parent = Row
    entry.Row = Row
    entry.Dot = Dot
    entry.NameLabel = LName
    entry.KeyLabel = LKey
    local rc1 = Row.MouseButton1Click:Connect(function()
        if entry.Toggle then entry.Toggle() end
    end)
    local rc2 = Row.MouseEnter:Connect(function()
        if entry.Toggle then Tween(Row, {BackgroundTransparency = 0.6}, 0.12) end
    end)
    local rc3 = Row.MouseLeave:Connect(function()
        Tween(Row, {BackgroundTransparency = 1}, 0.12)
    end)
    table.insert(Library.Connections, rc1)
    table.insert(Library.Connections, rc2)
    table.insert(Library.Connections, rc3)
end
function Library:RegisterBind(name, data)
    if not Library.KeybindList then Library:CreateKeybindList() end
    local entry = Library.Binds[name]
    if not entry then
        entry = {Key = "Unknown", Mode = "Toggle", Active = false}
        Library.Binds[name] = entry
        table.insert(Library.BindOrder, name)
        CreateBindRow(name, entry)
    end
    if data then
        if data.Key ~= nil then entry.Key = data.Key end
        if data.Mode ~= nil then entry.Mode = data.Mode end
        if data.Active ~= nil then entry.Active = data.Active end
        if data.Pinned ~= nil then entry.Pinned = data.Pinned end
        if data.Toggle ~= nil then entry.Toggle = data.Toggle end
    end
    RefreshBindList()
end
function Library:UpdateKeybindList(name, key, active, mode)
    Library:RegisterBind(name, {Key = key, Active = active, Mode = mode})
end
local function CreateDropdownElement(text, flag, options, default, tooltipText, callback, parentFrame, sectionRef, isMulti, customParent)
    local selected = Library.Flags[flag]
    if selected == nil then
        if isMulti then
            if type(default) ~= "table" then selected = {default} else selected = default end
        else
            selected = default or options[1]
        end
    end
    Library.Defaults[flag] = selected
    Library.Flags[flag] = selected
    local isDropped = false
    local parent = customParent or parentFrame
    local DropFrame = Instance.new("Frame")
    DropFrame.Size = UDim2.new(1, customParent and -20 or 0, 0, 46)
    if customParent then DropFrame.Position = UDim2.new(0, 20, 0, 0) end
    DropFrame.BackgroundTransparency = 1
    DropFrame.Parent = parent
    DropFrame.ZIndex = 5
    local DLabel = Instance.new("TextLabel")
    DLabel.Text = text
    DLabel.Font = Config.FontMain
    DLabel.TextSize = 13
    DLabel.TextColor3 = customParent and Theme.TextDark or Theme.Text
    DLabel.Size = UDim2.new(1, 0, 0, 16)
    DLabel.Position = UDim2.new(0, 5, 0, 0)
    DLabel.TextXAlignment = Enum.TextXAlignment.Left
    DLabel.BackgroundTransparency = 1
    DLabel.Parent = DropFrame
    local Interactive = Instance.new("TextButton")
    Interactive.Size = UDim2.new(1, 0, 0, 26)
    Interactive.Position = UDim2.new(0, 0, 0, 20)
    Interactive.BackgroundColor3 = Theme.Container
    Interactive.Text = ""
    Interactive.AutoButtonColor = false
    Interactive.Parent = DropFrame
    Interactive.ZIndex = 5
    Corner(Interactive, 4)
    Stroke(Interactive, Theme.Stroke, 1, 0.5)
    local SelectedText = Instance.new("TextLabel")
    SelectedText.Font = Config.FontMain
    SelectedText.TextSize = 13
    SelectedText.TextColor3 = Theme.Text
    SelectedText.Size = UDim2.new(1, -25, 1, 0)
    SelectedText.Position = UDim2.new(0, 8, 0, 0)
    SelectedText.TextXAlignment = Enum.TextXAlignment.Left
    SelectedText.BackgroundTransparency = 1
    SelectedText.ZIndex = 6
    SelectedText.ClipsDescendants = false
    SelectedText.TextTruncate = Enum.TextTruncate.AtEnd
    SelectedText.Parent = Interactive
    local Arrow = Instance.new("ImageLabel")
    Arrow.Image = "rbxassetid://10709790948"
    Arrow.Size = UDim2.new(0, 18, 0, 18)
    Arrow.Position = UDim2.new(1, -20, 0.5, 0)
    Arrow.AnchorPoint = Vector2.new(0, 0.5)
    Arrow.BackgroundTransparency = 1
    Arrow.ImageColor3 = Theme.TextDark
    Arrow.Parent = Interactive
    Arrow.ZIndex = 6
    local ListFrame = Instance.new("ScrollingFrame")
    ListFrame.Size = UDim2.new(1, 0, 0, 0)
    ListFrame.Position = UDim2.new(0, 0, 1, 5)
    ListFrame.BackgroundColor3 = Theme.Container
    ListFrame.BorderSizePixel = 0
    ListFrame.Parent = Interactive
    ListFrame.ZIndex = 10
    ListFrame.Visible = false
    ListFrame.Active = true
    ListFrame.ScrollBarThickness = 2
    ListFrame.ScrollBarImageColor3 = Theme.Accent
    ListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Corner(ListFrame, 4)
    Stroke(ListFrame, Theme.Stroke, 1, 0.5)
    local IList = Instance.new("UIListLayout")
    IList.SortOrder = Enum.SortOrder.LayoutOrder
    IList.Parent = ListFrame
    local function CloseDropdown()
        isDropped = false
        if sectionRef and sectionRef.Container then sectionRef.Container.ZIndex = 1 end
        DropFrame.ZIndex = 5
        if customParent then customParent.ZIndex = 1 end
        Tween(DropFrame, {Size = UDim2.new(1, customParent and -20 or 0, 0, 46)}, 0.2)
        local t = Tween(ListFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
        Tween(Arrow, {Rotation = 0}, 0.2)
        local c2
        c2 = t.Completed:Connect(function()
            if not isDropped then ListFrame.Visible = false end
            c2:Disconnect()
        end)
    end
    local optionBtns = {}
    local function IsSelected(opt)
        if isMulti then
            for _, v in ipairs(selected) do
                if v == opt then return true end
            end
            return false
        else
            return selected == opt
        end
    end
    local function UpdateVisuals()
        if isMulti then
            SelectedText.Text = (#selected > 0 and table.concat(selected, ", ") or "None")
        else
            SelectedText.Text = tostring(selected)
        end
        for opt, btn in pairs(optionBtns) do
            if IsSelected(opt) then
                btn.TextColor3 = Theme.Accent
            else
                btn.TextColor3 = Theme.TextDark
            end
        end
    end
    local function BuildOptions(newOptions)
        for _, btn in pairs(optionBtns) do btn:Destroy() end
        table.clear(optionBtns)
        options = newOptions
        for _, opt in ipairs(options) do
            local OptBtn = Instance.new("TextButton")
            OptBtn.Size = UDim2.new(1, 0, 0, 24)
            OptBtn.BackgroundColor3 = Theme.Container
            OptBtn.BackgroundTransparency = 1
            OptBtn.Text = opt
            OptBtn.Font = Config.FontMain
            OptBtn.TextSize = 12
            OptBtn.Parent = ListFrame
            OptBtn.ZIndex = 11
            if IsSelected(opt) then
                OptBtn.TextColor3 = Theme.Accent
            else
                OptBtn.TextColor3 = Theme.TextDark
            end
            optionBtns[opt] = OptBtn
            local c3 = OptBtn.MouseEnter:Connect(function()
                if not IsSelected(opt) then
                    Tween(OptBtn, {BackgroundTransparency = 0.8, TextColor3 = Theme.Accent})
                end
            end)
            local c4 = OptBtn.MouseLeave:Connect(function()
                if not IsSelected(opt) then
                    Tween(OptBtn, {BackgroundTransparency = 1, TextColor3 = Theme.TextDark})
                end
            end)
            local c5 = OptBtn.MouseButton1Click:Connect(function()
                if isMulti then
                    local found = table.find(selected, opt)
                    if found then table.remove(selected, found) else table.insert(selected, opt) end
                    UpdateVisuals()
                    Library.Flags[flag] = selected
                    Library.Unsaved = true
                    callback(selected)
                else
                    selected = opt
                    UpdateVisuals()
                    Library.Flags[flag] = selected
                    Library.Unsaved = true
                    callback(selected)
                    CloseDropdown()
                end
            end)
            table.insert(Library.Connections, c3)
            table.insert(Library.Connections, c4)
            table.insert(Library.Connections, c5)
        end
    end
    BuildOptions(options)
    UpdateVisuals()
    Library.Signals[flag] = function(val)
        if isMulti then
            if type(val) == "table" then
                selected = val
            else
                selected = {val}
            end
        else
            selected = val
        end
        UpdateVisuals()
        Library.Unsaved = true
        callback(selected)
    end
    local c6 = Interactive.MouseButton1Click:Connect(function()
        isDropped = not isDropped
        if sectionRef and sectionRef.Container then sectionRef.Container.ZIndex = isDropped and 10 or 1 end
        DropFrame.ZIndex = isDropped and 10 or 5
        if customParent then customParent.ZIndex = isDropped and 10 or 1 customParent.ClipsDescendants = false end
        if isDropped then
            ListFrame.Visible = true
            local listH = math.min(#options * 24, 200)
            local totalH = 46 + listH + 5
            Tween(DropFrame, {Size = UDim2.new(1, customParent and -20 or 0, 0, totalH)}, 0.2)
            Tween(ListFrame, {Size = UDim2.new(1, 0, 0, listH)}, 0.2)
            Tween(Arrow, {Rotation = 180}, 0.2)
        else
            CloseDropdown()
        end
    end)
    table.insert(Library.Connections, c6)
    ApplyTooltip(DropFrame, tooltipText)
    task.spawn(callback, selected)
    local DropdownObj = {}
    DropdownObj.Frame = DropFrame
    function DropdownObj:Refresh(newOptions, newDefault)
        if isMulti then
            if type(newDefault) ~= "table" then selected = {newDefault} else selected = newDefault end
        else
            selected = newDefault or (newOptions[1] or "")
        end
        Library.Flags[flag] = selected
        BuildOptions(newOptions)
        UpdateVisuals()
    end
    function DropdownObj:GetSelected()
        return selected
    end
    function DropdownObj:Set(val)
        if isMulti then
            if type(val) == "table" then selected = val else selected = {val} end
        else
            selected = val
        end
        Library.Flags[flag] = selected
        UpdateVisuals()
        callback(selected)
    end
    return DropdownObj
end
local function CreateSliderElement(text, flag, min, max, default, increment, tooltipText, callback, parentFrame, secData)
    increment = increment or 1
    local val = Library.Flags[flag]
    if val == nil then
        val = default or min
    end
    val = RoundToIncrement(val, increment)
    Library.Defaults[flag] = val
    Library.Flags[flag] = val
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 42)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parentFrame
    if secData then table.insert(secData.Items, {Name = text, Instance = Frame}) end
    local Label = Instance.new("TextLabel")
    Label.Text = text
    Label.Font = Config.FontMain
    Label.TextSize = 13
    Label.TextColor3 = Theme.Text
    Label.Size = UDim2.new(0.6, 0, 0, 16)
    Label.Position = UDim2.new(0, 5, 0, 0)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame
    local ValLabel = Instance.new("TextBox")
    ValLabel.Text = FormatNumber(val, increment)
    ValLabel.Font = Config.FontMain
    ValLabel.TextSize = 13
    ValLabel.TextColor3 = Theme.Text
    ValLabel.Size = UDim2.new(0.4, -5, 0, 16)
    ValLabel.Position = UDim2.new(0.6, 0, 0, 0)
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.BackgroundTransparency = 1
    ValLabel.ClearTextOnFocus = true
    ValLabel.Parent = Frame
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 0, 6)
    Bar.Position = UDim2.new(0, 0, 0, 24)
    Bar.BackgroundColor3 = Theme.Container
    Bar.Parent = Frame
    Corner(Bar, 3)
    Stroke(Bar, Theme.Stroke, 1, 0.5)
    local Fill = Instance.new("Frame")
    local range = max - min
    local ratio = range > 0 and (val - min) / range or 0
    Fill.Size = UDim2.new(ratio, 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar
    Corner(Fill, 3)
    RegisterTheme(Fill, "BackgroundColor")
    local function SetFromInput(input)
        local r = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local raw = min + (max - min) * r
        val = RoundToIncrement(raw, increment)
        val = math.clamp(val, min, max)
        local displayRatio = range > 0 and (val - min) / range or 0
        ValLabel.Text = FormatNumber(val, increment)
        Tween(Fill, {Size = UDim2.new(displayRatio, 0, 1, 0)}, 0.05)
        Library.Flags[flag] = val
        Library.Unsaved = true
        callback(val)
    end
    local c1 = Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            SetFromInput(input)
            BeginDrag(input, SetFromInput)
        end
    end)
    table.insert(Library.Connections, c1)
    local c5 = ValLabel.FocusLost:Connect(function(enter)
        if enter then
            local cleanText = string.gsub(ValLabel.Text, "[^%d.-]", "")
            local num = tonumber(cleanText)
            if num then
                num = RoundToIncrement(num, increment)
                num = math.clamp(num, min, max)
                val = num
                local displayRatio = range > 0 and (val - min) / range or 0
                ValLabel.Text = FormatNumber(val, increment)
                Tween(Fill, {Size = UDim2.new(displayRatio, 0, 1, 0)}, 0.05)
                Library.Flags[flag] = val
                Library.Unsaved = true
                callback(val)
            else
                ValLabel.Text = FormatNumber(val, increment)
            end
        else
            ValLabel.Text = FormatNumber(val, increment)
        end
    end)
    table.insert(Library.Connections, c5)
    Library.Signals[flag] = function(loadedVal)
        val = RoundToIncrement(loadedVal, increment)
        val = math.clamp(val, min, max)
        local displayRatio = range > 0 and (val - min) / range or 0
        ValLabel.Text = FormatNumber(val, increment)
        Tween(Fill, {Size = UDim2.new(displayRatio, 0, 1, 0)}, 0.05)
        Library.Unsaved = true
        callback(val)
    end
    ApplyTooltip(Frame, tooltipText)
    task.spawn(callback, val)
    return Frame
end
local function MakeSearchGlyph(parent, diameter, xOffset)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(0, diameter + 4, 0, diameter + 4)
    Holder.Position = UDim2.new(0, xOffset, 0.5, 0)
    Holder.AnchorPoint = Vector2.new(0, 0.5)
    Holder.BackgroundTransparency = 1
    Holder.ZIndex = parent.ZIndex + 1
    Holder.Parent = parent
    local Ring = Instance.new("Frame")
    Ring.Size = UDim2.new(0, diameter, 0, diameter)
    Ring.BackgroundTransparency = 1
    Ring.ZIndex = Holder.ZIndex
    Ring.Parent = Holder
    Corner(Ring, math.floor(diameter / 2))
    Stroke(Ring, Theme.TextDark, 1.5, 0)
    local Handle = Instance.new("Frame")
    Handle.Size = UDim2.new(0, 1.5, 0, math.max(diameter * 0.5, 3))
    Handle.Position = UDim2.new(0, diameter - 1, 0, diameter - 1)
    Handle.Rotation = -45
    Handle.BackgroundColor3 = Theme.TextDark
    Handle.BorderSizePixel = 0
    Handle.ZIndex = Holder.ZIndex
    Handle.Parent = Holder
    return Holder
end
local function CreateListSearch(parent, placeholder, order, onChanged)
    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(1, 0, 0, 22)
    Box.BackgroundColor3 = Theme.Background
    Box.LayoutOrder = order
    Box.Parent = parent
    Corner(Box, 4)
    Stroke(Box, Theme.Stroke, 1, 0.5)
    MakeSearchGlyph(Box, 9, 6)
    local Input = Instance.new("TextBox")
    Input.Size = UDim2.new(1, -26, 1, 0)
    Input.Position = UDim2.new(0, 22, 0, 0)
    Input.BackgroundTransparency = 1
    Input.Text = ""
    Input.PlaceholderText = placeholder
    Input.PlaceholderColor3 = Theme.TextDark
    Input.TextColor3 = Theme.Text
    Input.Font = Config.FontMain
    Input.TextSize = 12
    Input.TextXAlignment = Enum.TextXAlignment.Left
    Input.ClearTextOnFocus = false
    Input.Parent = Box
    local c = Input:GetPropertyChangedSignal("Text"):Connect(function()
        onChanged((Input.Text or ""):lower())
    end)
    table.insert(Library.Connections, c)
    return Box
end
local function FilterButtons(buttons, query)
    for name, btn in pairs(buttons) do
        if not btn or not btn.Parent then
        elseif query == "" then
            btn.Visible = true
        else
            btn.Visible = tostring(name):lower():find(query, 1, true) ~= nil
        end
    end
end
local function CreatePreviewController(VP, Cam)
    local ctrl = {Angle = 0, Pitch = 0.25, Zoom = 1, TargetZoom = 1, Model = nil, Dragging = false, ScrollFrame = nil}
    local dragStart, startAngle, startPitch = nil, 0, 0
    local ZoomBox = Instance.new("Frame")
    ZoomBox.Size = UDim2.new(0, 24, 0, 52)
    ZoomBox.Position = UDim2.new(1, -6, 1, -6)
    ZoomBox.AnchorPoint = Vector2.new(1, 1)
    ZoomBox.BackgroundTransparency = 1
    ZoomBox.ZIndex = 5
    ZoomBox.Parent = VP
    local ZoomList = Instance.new("UIListLayout")
    ZoomList.Padding = UDim.new(0, 4)
    ZoomList.Parent = ZoomBox
    local function MakeZoomBtn(txt, order, delta)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 24, 0, 24)
        b.BackgroundColor3 = Theme.Background
        b.BackgroundTransparency = 0.25
        b.Text = txt
        b.TextColor3 = Theme.Text
        b.TextSize = 16
        b.Font = Config.FontBold
        b.AutoButtonColor = false
        b.LayoutOrder = order
        b.ZIndex = 6
        b.Parent = ZoomBox
        Corner(b, 4)
        Stroke(b, Theme.Stroke, 1, 0.4)
        local c = b.MouseButton1Click:Connect(function()
            ctrl.TargetZoom = math.clamp(ctrl.TargetZoom + delta, 0.4, 3)
        end)
        table.insert(Library.Connections, c)
    end
    MakeZoomBtn("+", 1, -0.25)
    MakeZoomBtn("-", 2, 0.25)
    local function InsideVP()
        local m = UserInputService:GetMouseLocation()
        local ap, sz = VP.AbsolutePosition, VP.AbsoluteSize
        return m.X >= ap.X and m.X <= ap.X + sz.X and m.Y >= ap.Y and m.Y <= ap.Y + sz.Y + 36
    end
    local function LockScroll(state)
        local sf = ctrl.ScrollFrame
        if sf and sf.Parent then sf.ScrollingEnabled = not state end
    end
    local ib = VP.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            ctrl.Dragging = true
            dragStart = input.Position
            startAngle, startPitch = ctrl.Angle, ctrl.Pitch
            LockScroll(true)
        end
    end)
    local ime = VP.MouseEnter:Connect(function() LockScroll(true) end)
    local iml = VP.MouseLeave:Connect(function() if not ctrl.Dragging then LockScroll(false) end end)
    table.insert(Library.Connections, ime)
    table.insert(Library.Connections, iml)
    local ic = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            if VP.Visible and InsideVP() then
                ctrl.TargetZoom = math.clamp(ctrl.TargetZoom - input.Position.Z * 0.15, 0.4, 3)
            end
        elseif ctrl.Dragging and dragStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            ctrl.Angle = startAngle + d.X * 0.01
            ctrl.Pitch = math.clamp(startPitch - d.Y * 0.006, -1.1, 1.1)
        end
    end)
    local ie = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            ctrl.Dragging = false
            dragStart = nil
            LockScroll(false)
        end
    end)
    table.insert(Library.Connections, ib)
    table.insert(Library.Connections, ic)
    table.insert(Library.Connections, ie)
    function ctrl:Reset()
        ctrl.Zoom = 1
        ctrl.TargetZoom = 1
        ctrl.Pitch = 0.25
        ctrl.Angle = 0
    end
    function ctrl:Step(dt)
        local model = ctrl.Model
        if not model or not model.Parent then return end
        if not ctrl.Dragging then ctrl.Angle = ctrl.Angle + dt * 0.6 end
        ctrl.Zoom = ctrl.Zoom + (ctrl.TargetZoom - ctrl.Zoom) * math.min(dt * 8, 1)
        pcall(function()
            local cf, size = model:GetBoundingBox()
            local center = cf.Position
            local maxDim = math.max(size.X, size.Y, size.Z, 1)
            local dist = maxDim * 2.2 * ctrl.Zoom
            local cp = math.cos(ctrl.Pitch)
            local camPos = center + Vector3.new(math.cos(ctrl.Angle) * dist * cp, math.sin(ctrl.Pitch) * dist + size.Y * 0.1, math.sin(ctrl.Angle) * dist * cp)
            Cam.CFrame = CFrame.lookAt(camPos, center)
        end)
    end
    return ctrl
end
function Library:CreateWindow(options)
    if options and options.Name then Config.Name = options.Name end
    if options and options.ConfigFolder then Config.ConfigFolder = options.ConfigFolder end
    if options and options.Game then Library.HubConfig.Game = options.Game end
    if not isfolder(Config.ConfigFolder) then makefolder(Config.ConfigFolder) end
    Library:Unload()
    Library:InitWatermark()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = Config.Name
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = GetParent()
    Library.ScreenGui = ScreenGui
    local MiniGui = Instance.new("ScreenGui")
    MiniGui.Name = "PhantomMiniButton"
    MiniGui.Parent = GetParent()
    MiniGui.Enabled = true
    MiniGui.IgnoreGuiInset = true
    local MiniButton = Instance.new("ImageButton")
    MiniButton.Size = UDim2.new(0, 46, 0, 46)
    MiniButton.Position = UDim2.new(0, 20, 0.5, -23)
    MiniButton.BackgroundColor3 = Theme.Background
    MiniButton.BackgroundTransparency = 0.1
    MiniButton.Image = "rbxassetid://112964043447417"
    MiniButton.ImageColor3 = Theme.Accent
    MiniButton.ScaleType = Enum.ScaleType.Fit
    MiniButton.AutoButtonColor = false
    MiniButton.Active = true
    MiniButton.Parent = MiniGui
    Corner(MiniButton, 23)
    Stroke(MiniButton, Theme.Accent, 2, 0.3)
    RegisterTheme(MiniButton, "ImageColor")
    local miniWasDragged = false
    MakeDraggable(MiniButton, MiniButton, function(wasDrag)
        miniWasDragged = wasDrag
    end)
    local function ToggleFromMini()
        if Library.Open then
            Library.Open = false
            if Library._IsSettings then
                Tween(Library._SetScale, {Scale = GetBaseScale() * 0.8}, 0.25).Completed:Wait()
            else
                Tween(Library._MainScale, {Scale = GetBaseScale() * 0.8}, 0.25).Completed:Wait()
            end
            Library._MainWindow.Visible = false
            Library._SettingsWindow.Visible = false
            TooltipLabel.Visible = false
        else
            Library.Open = true
            if Library._IsSettings then
                Library._SettingsWindow.Visible = true
                Library._SettingsWindow.BackgroundTransparency = 0.1
                Library._SetScale.Scale = GetBaseScale() * 0.8
                Tween(Library._SetScale, {Scale = GetBaseScale()}, 0.35)
            else
                Library._MainWindow.Visible = true
                Library._MainWindow.BackgroundTransparency = 0.1
                Library._MainScale.Scale = GetBaseScale() * 0.8
                Tween(Library._MainScale, {Scale = GetBaseScale()}, 0.35)
            end
        end
    end
    local c1 = MiniButton.MouseButton1Click:Connect(function()
        if miniWasDragged then
            miniWasDragged = false
            return
        end
        ToggleFromMini()
    end)
    table.insert(Library.Connections, c1)
    local function CreateBaseFrame(name)
        local Frame = Instance.new("Frame")
        Frame.Name = name
        Frame.Size = UDim2.new(0, 780, 0, 450)
        Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        Frame.AnchorPoint = Vector2.new(0.5, 0.5)
        Frame.BackgroundColor3 = Theme.Background
        Frame.BackgroundTransparency = 0.1
        Frame.BorderSizePixel = 0
        Frame.ClipsDescendants = false
        Frame.Visible = false
        Frame.Parent = ScreenGui
        Frame.Active = true
        local SizeConstraint = Instance.new("UISizeConstraint")
        SizeConstraint.MaxSize = Vector2.new(1400, 900)
        SizeConstraint.MinSize = Vector2.new(520, 320)
        SizeConstraint.Parent = Frame
        Corner(Frame, 6)
        Stroke(Frame, Theme.Stroke, 1, 0)
        local BgNoise = Instance.new("ImageLabel")
        BgNoise.Size = UDim2.new(1, 0, 1, 0)
        BgNoise.BackgroundTransparency = 1
        BgNoise.Image = "rbxassetid://9968344105"
        BgNoise.ImageTransparency = 0.9
        BgNoise.ScaleType = Enum.ScaleType.Tile
        BgNoise.TileSize = UDim2.new(0, 100, 0, 100)
        BgNoise.Parent = Frame
        Corner(BgNoise, 6)
        local DragHeader = Instance.new("Frame")
        DragHeader.Name = "DragHeader"
        DragHeader.Size = UDim2.new(0, 180, 0, 60)
        DragHeader.BackgroundTransparency = 1
        DragHeader.Parent = Frame
        local Scale = Instance.new("UIScale")
        Scale.Scale = 1
        Scale.Parent = Frame
        MakeDraggable(DragHeader, Frame)
        return Frame, Scale
    end
    local GameName = Library.HubConfig.Game
    if GameName == "" then
        GameName = game.Name
        pcall(function()
            local info = MarketplaceService:GetProductInfo(game.PlaceId)
            if info and info.Name and info.Name ~= "" then GameName = info.Name end
        end)
    end
    local function CreateTopbar(parent, isSettings)
        local TopBar = Instance.new("Frame")
        TopBar.Name = "TopBar"
        TopBar.Size = UDim2.new(1, 0, 0, 34)
        TopBar.BackgroundColor3 = Theme.Topbar
        TopBar.BorderSizePixel = 0
        TopBar.Parent = parent
        TopBar.ZIndex = 3
        local TopAccent = Instance.new("Frame")
        TopAccent.Size = UDim2.new(1, 0, 0, 2)
        TopAccent.Position = UDim2.new(0, 0, 1, 0)
        TopAccent.BackgroundColor3 = Theme.Accent
        TopAccent.BorderSizePixel = 0
        TopAccent.Parent = TopBar
        RegisterTheme(TopAccent, "BackgroundColor")
        local TopTitle = Instance.new("TextLabel")
        TopTitle.Size = UDim2.new(1, -96, 1, 0)
        TopTitle.Position = UDim2.new(0, 12, 0, 0)
        TopTitle.BackgroundTransparency = 1
        TopTitle.Text = Config.Brand
        TopTitle.TextColor3 = Theme.Text
        TopTitle.Font = Config.FontBold
        TopTitle.TextSize = 14
        TopTitle.TextXAlignment = Enum.TextXAlignment.Left
        TopTitle.Parent = TopBar
        local function TopBtn(id, hoverColor, xOffset)
            local b = Instance.new("ImageButton")
            b.Size = UDim2.new(0, 22, 0, 22)
            b.AnchorPoint = Vector2.new(1, 0.5)
            b.Position = UDim2.new(1, xOffset, 0.5, 0)
            b.BackgroundTransparency = 1
            b.Image = "rbxassetid://" .. id
            b.ImageColor3 = Theme.TextDark
            b.ScaleType = Enum.ScaleType.Fit
            b.AutoButtonColor = false
            b.Parent = TopBar
            local c1 = b.MouseEnter:Connect(function() Tween(b, {ImageColor3 = hoverColor}, 0.1) end)
            local c2 = b.MouseLeave:Connect(function() Tween(b, {ImageColor3 = Theme.TextDark}, 0.1) end)
            table.insert(Library.Connections, c1)
            table.insert(Library.Connections, c2)
            return b
        end
        local CloseBtn = TopBtn(10738425363, Theme.Danger, -8)
        local MinBtn = TopBtn(10664064072, Theme.Accent, -36)
        local cc = CloseBtn.MouseButton1Click:Connect(function() Library:Unload() end)
        local mc = MinBtn.MouseButton1Click:Connect(function() ToggleFromMini() end)
        table.insert(Library.Connections, cc)
        table.insert(Library.Connections, mc)
        MakeDraggable(TopBar, parent)
        return TopBar
    end
    local MainWindow, MainScale = CreateBaseFrame("MainWindow")
    local SettingsWindow, SetScale = CreateBaseFrame("SettingsWindow")
    Library._MainWindow = MainWindow
    Library._MainScale = MainScale
    Library._SettingsWindow = SettingsWindow
    Library._SetScale = SetScale
    Library._IsSettings = false
    CreateTopbar(MainWindow, false)
    CreateTopbar(SettingsWindow, true)
    local function RefreshThemeDecor()
        for _, win in ipairs({MainWindow, SettingsWindow}) do
            local d = win:FindFirstChild("HalloweenDecor")
            if Library.CurrentTheme == "Halloween" then
                if not d then BuildHalloweenDecor(win) end
            elseif d then
                d:Destroy()
            end
        end
    end
    OnThemeChanged(RefreshThemeDecor)
    RefreshThemeDecor()
    local Resizer = Instance.new("Frame")
    Resizer.Size = UDim2.new(0, 20, 0, 20)
    Resizer.Position = UDim2.new(1, 0, 1, 0)
    Resizer.AnchorPoint = Vector2.new(1, 1)
    Resizer.BackgroundTransparency = 1
    Resizer.Parent = MainWindow
    Resizer.ZIndex = 20
    Resizer.Active = true
    local ResizerIcon = Instance.new("TextLabel")
    ResizerIcon.Size = UDim2.new(1, 0, 1, 0)
    ResizerIcon.BackgroundTransparency = 1
    ResizerIcon.Text = "◢"
    ResizerIcon.TextColor3 = Theme.TextDark
    ResizerIcon.TextSize = 16
    ResizerIcon.Parent = Resizer
    local c2 = Resizer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then Tween(ResizerIcon, {TextColor3 = Theme.Accent}) end
    end)
    local c3 = Resizer.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then Tween(ResizerIcon, {TextColor3 = Theme.TextDark}) end
    end)
    table.insert(Library.Connections, c2)
    table.insert(Library.Connections, c3)
    MakeResizable(Resizer, MainWindow, Vector2.new(450, 300))
    local function CreateSidebar(parent, isSettings)
        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(0, 180, 1, -34)
        Bar.Position = UDim2.new(0, 0, 0, 34)
        Bar.BackgroundColor3 = Theme.Sidebar
        Bar.BorderSizePixel = 0
        Bar.Parent = parent
        Bar.Active = true
        Corner(Bar, 6)
        local Div = Instance.new("Frame")
        Div.Size = UDim2.new(0, 1, 1, 0)
        Div.Position = UDim2.new(1, 0, 0, 0)
        Div.BackgroundColor3 = Theme.Stroke
        Div.BorderSizePixel = 0
        Div.Parent = Bar
        if isSettings then
            local BackBtn = Instance.new("TextButton")
            BackBtn.Size = UDim2.new(1, -20, 0, 30)
            BackBtn.Position = UDim2.new(0, 10, 0, 15)
            BackBtn.BackgroundColor3 = Theme.Container
            BackBtn.Text = " < Back to Menu"
            BackBtn.Font = Config.FontBold
            BackBtn.TextSize = 13
            BackBtn.TextColor3 = Theme.TextDark
            BackBtn.TextXAlignment = Enum.TextXAlignment.Left
            BackBtn.AutoButtonColor = false
            BackBtn.Parent = Bar
            Corner(BackBtn, 4)
            Stroke(BackBtn, Theme.Stroke, 1, 0.5)
            local c4 = BackBtn.MouseEnter:Connect(function() Tween(BackBtn, {TextColor3 = Theme.Accent}) end)
            local c5 = BackBtn.MouseLeave:Connect(function() Tween(BackBtn, {TextColor3 = Theme.TextDark}) end)
            table.insert(Library.Connections, c4)
            table.insert(Library.Connections, c5)
            local Title = Instance.new("TextLabel")
            Title.Text = "Settings"
            Title.Size = UDim2.new(1, 0, 0, 30)
            Title.Position = UDim2.new(0, 0, 0, 55)
            Title.Font = Config.FontBold
            Title.TextSize = 22
            Title.TextColor3 = Theme.Text
            Title.BackgroundTransparency = 1
            Title.Parent = Bar
            return Bar, nil, BackBtn
        else
            local Logo = Instance.new("TextLabel")
            Logo.Text = GameName
            Logo.RichText = true
            Logo.Position = UDim2.new(0, 15, 0, 20)
            Logo.Size = UDim2.new(1, -30, 0, 30)
            Logo.Font = Config.FontBold
            Logo.TextSize = 20
            Logo.TextColor3 = Theme.Accent
            Logo.TextXAlignment = Enum.TextXAlignment.Left
            Logo.BackgroundTransparency = 1
            Logo.Parent = Bar
            RegisterTheme(Logo, "TextColor")
            local LogoUnder = Instance.new("Frame")
            LogoUnder.Size = UDim2.new(1, -15, 0, 1)
            LogoUnder.Position = UDim2.new(0, 8, 0, 52)
            LogoUnder.BackgroundColor3 = Theme.Stroke
            LogoUnder.BorderSizePixel = 0
            LogoUnder.Parent = Bar
            local Container = Instance.new("ScrollingFrame")
            Container.Size = UDim2.new(1, 0, 1, -130)
            Container.Position = UDim2.new(0, 0, 0, 60)
            Container.BackgroundTransparency = 1
            Container.BorderSizePixel = 0
            Container.ScrollBarThickness = 2
            Container.ScrollBarImageColor3 = Theme.Accent
            Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
            Container.ClipsDescendants = true
            Container.Parent = Bar
            RegisterTheme(Container, "ScrollBar")
            local List = Instance.new("UIListLayout")
            List.Padding = UDim.new(0, 6)
            List.HorizontalAlignment = Enum.HorizontalAlignment.Center
            List.SortOrder = Enum.SortOrder.LayoutOrder
            List.Parent = Container
            return Bar, Container, nil
        end
    end
    local MainBar, TabContainer, _ = CreateSidebar(MainWindow, false)
    local SetBar, SetContainer, BackBtn = CreateSidebar(SettingsWindow, true)
    local ProfileBtn = Instance.new("TextButton")
    ProfileBtn.Size = UDim2.new(1, 0, 0, 60)
    ProfileBtn.Position = UDim2.new(0, 0, 1, 0)
    ProfileBtn.AnchorPoint = Vector2.new(0, 1)
    ProfileBtn.BackgroundColor3 = Theme.Sidebar
    ProfileBtn.BorderSizePixel = 0
    ProfileBtn.Text = ""
    ProfileBtn.AutoButtonColor = false
    ProfileBtn.Parent = MainBar
    local SideAvatar = Instance.new("ImageLabel")
    SideAvatar.Size = UDim2.new(0, 36, 0, 36)
    SideAvatar.Position = UDim2.new(0, 15, 0.5, 0)
    SideAvatar.AnchorPoint = Vector2.new(0, 0.5)
    SideAvatar.BackgroundColor3 = Theme.Container
    local s2, av2 = pcall(function() return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
    SideAvatar.Image = s2 and av2 or "rbxassetid://0"
    SideAvatar.Parent = ProfileBtn
    Corner(SideAvatar, 18)
    local AvS = Stroke(SideAvatar, Theme.Accent, 1)
    RegisterTheme(AvS, "BorderColor")
    local SideName = Instance.new("TextLabel")
    SideName.Size = UDim2.new(0, 100, 0, 16)
    SideName.Position = UDim2.new(0, 60, 0.5, -9)
    SideName.AnchorPoint = Vector2.new(0, 0.5)
    SideName.BackgroundTransparency = 1
    SideName.Text = LocalPlayer.Name
    SideName.TextColor3 = Theme.Text
    SideName.Font = Config.FontBold
    SideName.TextSize = 13
    SideName.TextXAlignment = Enum.TextXAlignment.Left
    SideName.Parent = ProfileBtn
    local SideSub = Instance.new("TextLabel")
    SideSub.Size = UDim2.new(0, 100, 0, 14)
    SideSub.Position = UDim2.new(0, 60, 0.5, 9)
    SideSub.AnchorPoint = Vector2.new(0, 0.5)
    SideSub.BackgroundTransparency = 1
    SideSub.Text = "Settings"
    SideSub.TextColor3 = Theme.TextDark
    SideSub.Font = Config.FontMain
    SideSub.TextSize = 11
    SideSub.TextXAlignment = Enum.TextXAlignment.Left
    SideSub.Parent = ProfileBtn
    local IsSettings = false
    local animating = false
    local function ToggleMain()
        if animating then return end
        animating = true
        Library.Open = not Library.Open
        if Library.Open then
            if IsSettings then
                SettingsWindow.Visible = true
                SettingsWindow.BackgroundTransparency = 0.1
                SetScale.Scale = GetBaseScale() * 0.8
                Tween(SetScale, {Scale = GetBaseScale()}, 0.35).Completed:Wait()
            else
                MainWindow.Visible = true
                MainWindow.BackgroundTransparency = 0.1
                MainScale.Scale = GetBaseScale() * 0.8
                Tween(MainScale, {Scale = GetBaseScale()}, 0.35).Completed:Wait()
            end
        else
            if IsSettings then
                Tween(SetScale, {Scale = GetBaseScale() * 0.8}, 0.25).Completed:Wait()
            else
                Tween(MainScale, {Scale = GetBaseScale() * 0.8}, 0.25).Completed:Wait()
            end
            MainWindow.Visible = false
            SettingsWindow.Visible = false
            TooltipLabel.Visible = false
        end
        animating = false
    end
    local function SwitchToSettings()
        if animating then return end
        animating = true
        SettingsWindow.Position = MainWindow.Position
        SettingsWindow.Size = MainWindow.Size
        Tween(MainScale, {Scale = GetBaseScale() * 0.9}, 0.2).Completed:Wait()
        MainWindow.Visible = false
        SettingsWindow.Visible = true
        SettingsWindow.BackgroundTransparency = 0.1
        SetScale.Scale = GetBaseScale() * 0.9
        Tween(SetScale, {Scale = GetBaseScale()}, 0.25).Completed:Wait()
        IsSettings = true
        Library._IsSettings = true
        animating = false
    end
    local function SwitchToMain()
        if animating then return end
        animating = true
        MainWindow.Position = SettingsWindow.Position
        MainWindow.Size = SettingsWindow.Size
        Tween(SetScale, {Scale = GetBaseScale() * 0.9}, 0.2).Completed:Wait()
        SettingsWindow.Visible = false
        MainWindow.Visible = true
        MainWindow.BackgroundTransparency = 0.1
        MainScale.Scale = GetBaseScale() * 0.9
        Tween(MainScale, {Scale = GetBaseScale()}, 0.25).Completed:Wait()
        IsSettings = false
        Library._IsSettings = false
        animating = false
    end
    local c6 = ProfileBtn.MouseButton1Click:Connect(function() task.spawn(SwitchToSettings) end)
    local c7 = BackBtn.MouseButton1Click:Connect(function() task.spawn(SwitchToMain) end)
    table.insert(Library.Connections, c6)
    table.insert(Library.Connections, c7)
    local c8 = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        if Library.Open then
            if IsSettings and SettingsWindow.Visible then
                SetScale.Scale = GetBaseScale()
            elseif not IsSettings and MainWindow.Visible then
                MainScale.Scale = GetBaseScale()
            end
        end
    end)
    table.insert(Library.Connections, c8)
    local MenuBindConnection = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if Library.UIHidden and (input.KeyCode == Config.Keybind or input.KeyCode == Config.HideKeybind) then
            Library:SetUIHidden(false)
        elseif input.KeyCode == Config.Keybind then
            task.spawn(ToggleMain)
        elseif input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode == Config.HideKeybind then
            Library:SetUIHidden(not Library.UIHidden)
        end
    end)
    table.insert(Library.Connections, MenuBindConnection)
    local WindowObj = {}
    local MainPages = Instance.new("Frame")
    MainPages.Size = UDim2.new(1, -181, 1, -34)
    MainPages.Position = UDim2.new(0, 181, 0, 34)
    MainPages.BackgroundTransparency = 1
    MainPages.Parent = MainWindow
    local SearchBar = Instance.new("Frame")
    SearchBar.Name = "SearchBar"
    SearchBar.Size = UDim2.new(1, -263, 0, 24)
    SearchBar.Position = UDim2.new(0, 191, 0, 8)
    SearchBar.BackgroundColor3 = Theme.Container
    SearchBar.BackgroundTransparency = 0.3
    SearchBar.Parent = MainWindow
    SearchBar.ZIndex = 5
    Corner(SearchBar, 4)
    Stroke(SearchBar, Theme.Stroke, 1, 0.4)
    MakeSearchGlyph(SearchBar, 10, 7)
    local SearchInput = Instance.new("TextBox")
    SearchInput.Size = UDim2.new(1, -30, 1, 0)
    SearchInput.Position = UDim2.new(0, 24, 0, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.Text = ""
    SearchInput.PlaceholderText = "Search features..."
    SearchInput.PlaceholderColor3 = Theme.TextDark
    SearchInput.TextColor3 = Theme.Text
    SearchInput.Font = Config.FontMain
    SearchInput.TextSize = 12
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left
    SearchInput.ClearTextOnFocus = false
    SearchInput.ZIndex = 6
    SearchInput.Parent = SearchBar
    local SearchResults = Instance.new("ScrollingFrame")
    SearchResults.Size = UDim2.new(1, -263, 0, 0)
    SearchResults.Position = UDim2.new(0, 191, 0, 34)
    SearchResults.BackgroundColor3 = Theme.Section
    SearchResults.BackgroundTransparency = 0.05
    SearchResults.BorderSizePixel = 0
    SearchResults.ScrollBarThickness = 2
    SearchResults.ScrollBarImageColor3 = Theme.Accent
    SearchResults.CanvasSize = UDim2.new(0, 0, 0, 0)
    SearchResults.Visible = false
    SearchResults.ZIndex = 30
    SearchResults.Parent = MainWindow
    Corner(SearchResults, 4)
    Stroke(SearchResults, Theme.Stroke, 1, 0.2)
    RegisterTheme(SearchResults, "ScrollBar")
    local ResultsList = Instance.new("UIListLayout")
    ResultsList.SortOrder = Enum.SortOrder.LayoutOrder
    ResultsList.Padding = UDim.new(0, 2)
    ResultsList.Parent = SearchResults
    local function HighlightItem(inst)
        if not inst or not inst.Parent then return end
        local flash = Instance.new("UIStroke")
        flash.Color = Theme.Accent
        flash.Thickness = 2
        flash.Transparency = 0
        flash.Parent = inst
        task.delay(0.15, function()
            local t = TweenService:Create(flash, TweenInfo.new(1.2), {Transparency = 1})
            t:Play()
            t.Completed:Connect(function() pcall(function() flash:Destroy() end) end)
        end)
    end
    local function GoToResult(entry, inst)
        if entry.Activate then entry.Activate() end
        task.defer(function()
            if not inst or not inst.Parent then return end
            local page = entry.Page
            if page then
                RunService.RenderStepped:Wait()
                local rel = inst.AbsolutePosition.Y - page.AbsolutePosition.Y + page.CanvasPosition.Y
                local scale = GetBaseScale()
                if scale > 0 then rel = rel / scale end
                Tween(page, {CanvasPosition = Vector2.new(0, math.max(rel - 12, 0))}, 0.25)
            end
            HighlightItem(inst)
        end)
    end
    local function ClearResults()
        for _, c in pairs(SearchResults:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
    end
    local function AddResultRow(tabName, itemName, order, onClick)
        local Row = Instance.new("TextButton")
        Row.Size = UDim2.new(1, -8, 0, 24)
        Row.Position = UDim2.new(0, 4, 0, 0)
        Row.BackgroundColor3 = Theme.Container
        Row.BackgroundTransparency = 1
        Row.AutoButtonColor = false
        Row.Text = ""
        Row.LayoutOrder = order
        Row.ZIndex = 31
        Row.Parent = SearchResults
        Corner(Row, 4)
        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1, -12, 1, 0)
        Lbl.Position = UDim2.new(0, 8, 0, 0)
        Lbl.BackgroundTransparency = 1
        Lbl.RichText = true
        Lbl.Text = '<font color="#8a8a8a">' .. tabName .. ' →</font> ' .. itemName
        Lbl.TextColor3 = Theme.Text
        Lbl.Font = Config.FontMain
        Lbl.TextSize = 12
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.TextTruncate = Enum.TextTruncate.AtEnd
        Lbl.ZIndex = 32
        Lbl.Parent = Row
        Row.MouseEnter:Connect(function() Tween(Row, {BackgroundTransparency = 0.5}, 0.12) end)
        Row.MouseLeave:Connect(function() Tween(Row, {BackgroundTransparency = 1}, 0.12) end)
        Row.MouseButton1Click:Connect(function()
            SearchInput.Text = ""
            onClick()
        end)
    end
    local function RunSearch(query)
        ClearResults()
        query = tostring(query or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
        if #query < 2 then
            SearchResults.Visible = false
            SearchResults.Size = UDim2.new(1, -263, 0, 0)
            return
        end
        local count = 0
        for _, entry in ipairs(Library.SearchIndex) do
            if count < 40 and entry.Tab:lower():find(query, 1, true) then
                count = count + 1
                AddResultRow(entry.Tab, "open tab", count, function() entry.Activate() end)
            end
            for _, sec in ipairs(entry.Sections) do
                if count < 40 and sec.Title and sec.Title:lower():find(query, 1, true) then
                    count = count + 1
                    local secInst = sec.Instance
                    AddResultRow(entry.Tab, sec.Title, count, function() GoToResult(entry, secInst) end)
                end
                for _, item in ipairs(sec.Items) do
                    if count >= 40 then break end
                    local nm = tostring(item.Name or "")
                    if nm ~= "" and nm:lower():find(query, 1, true) then
                        count = count + 1
                        local inst = item.Instance
                        AddResultRow(entry.Tab, nm, count, function() GoToResult(entry, inst) end)
                    end
                end
            end
        end
        if count == 0 then
            AddResultRow("No results", "", 1, function() end)
            count = 1
        end
        SearchResults.Visible = true
        local h = math.min(count * 26 + 6, 220)
        SearchResults.Size = UDim2.new(1, -263, 0, h)
        SearchResults.CanvasSize = UDim2.new(0, 0, 0, count * 26 + 6)
    end
    local sc1 = SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        RunSearch(SearchInput.Text)
    end)
    local sc2 = SearchInput.FocusLost:Connect(function()
        task.delay(0.2, function()
            if SearchInput.Text == "" then SearchResults.Visible = false end
        end)
    end)
    table.insert(Library.Connections, sc1)
    table.insert(Library.Connections, sc2)
    function WindowObj:CreateRawSection(text, parent)
        local Section = {}
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 0, 0)
        Container.BackgroundColor3 = Theme.Section
        Container.Parent = parent
        Container.ZIndex = 1
        Corner(Container, 6)
        Stroke(Container, Theme.Stroke, 1, 0.5)
        Section.Container = Container
        local Title = Instance.new("TextLabel")
        Title.Text = text
        Title.Font = Config.FontBold
        Title.TextSize = 12
        Title.TextColor3 = Theme.TextDark
        Title.Size = UDim2.new(1, -20, 0, 30)
        Title.Position = UDim2.new(0, 10, 0, 0)
        Title.BackgroundTransparency = 1
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Container
        local Content = Instance.new("Frame")
        Content.Name = "Content"
        Content.Size = UDim2.new(1, -10, 0, 0)
        Content.Position = UDim2.new(0, 5, 0, 30)
        Content.BackgroundTransparency = 1
        Content.Parent = Container
        local List = Instance.new("UIListLayout")
        List.Padding = UDim.new(0, 6)
        List.SortOrder = Enum.SortOrder.LayoutOrder
        List.Parent = Content
        local lc1 = List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local sc = (Library._MainScale and Library._MainScale.Scale > 0) and Library._MainScale.Scale or 1
            Container.Size = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y / sc + 40)
        end)
        table.insert(Library.Connections, lc1)
        function Section:Label(ltext, options)
            options = options or {}
            local LabelObj = {}
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 26)
            Frame.BackgroundColor3 = Theme.Container
            Frame.BackgroundTransparency = 0.5
            Frame.Parent = Content
            Corner(Frame, 4)
            Stroke(Frame, Theme.Stroke, 1, 0.5)
            local Lbl = Instance.new("TextLabel")
            Lbl.Size = UDim2.new(1, -10, 1, -10)
            Lbl.Position = UDim2.new(0, 5, 0, 5)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = tostring(ltext)
            Lbl.Font = Config.FontMain
            Lbl.TextSize = 13
            Lbl.TextColor3 = options.Color or Theme.Text
            Lbl.TextXAlignment = options.Alignment or Enum.TextXAlignment.Left
            Lbl.TextYAlignment = Enum.TextYAlignment.Top
            Lbl.RichText = true
            Lbl.TextWrapped = true
            Lbl.Parent = Frame
            local function UpdateHeight()
                local textHeight = Lbl.TextBounds.Y
                if textHeight > 16 then Frame.Size = UDim2.new(1, 0, 0, textHeight + 10) else Frame.Size = UDim2.new(1, 0, 0, 26) end
            end
            local boundsConn = Lbl:GetPropertyChangedSignal("TextBounds"):Connect(UpdateHeight)
            table.insert(Library.Connections, boundsConn)
            UpdateHeight()
            function LabelObj:Set(newText) Lbl.Text = tostring(newText) end
            function LabelObj:SetColor(newColor) Lbl.TextColor3 = newColor end
            return LabelObj
        end
        function Section:Button(text, tooltipText, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 32)
            Btn.BackgroundColor3 = Theme.Container
            Btn.Text = text
            Btn.Font = Config.FontMain
            Btn.TextSize = 13
            Btn.TextColor3 = Theme.Text
            Btn.AutoButtonColor = false
            Btn.Parent = Content
            Corner(Btn, 4)
            local s = Stroke(Btn, Theme.Stroke, 1, 0.5)
            local bc1 = Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Theme.Stroke}) Tween(s, {Color = Theme.Accent}) end)
            local bc2 = Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Theme.Container}) Tween(s, {Color = Theme.Stroke}) end)
            local bc3 = Btn.MouseButton1Click:Connect(WrapCallback(text, callback, false))
            table.insert(Library.Connections, bc1)
            table.insert(Library.Connections, bc2)
            table.insert(Library.Connections, bc3)
            ApplyTooltip(Btn, tooltipText)
            return Btn
        end
        function Section:Toggle(text, flag, default, tooltipText, callback)
            local quietCallback = WrapCallback(text, callback, false)
            callback = WrapCallback(text, callback, true)
            Library.Defaults[flag] = default or false
            local toggled = Library.Flags[flag]
            if toggled == nil then
                toggled = default or false
                Library.Flags[flag] = toggled
            end
            local ToggleObj = {}
            Library.Signals[flag] = function(val)
                if toggled ~= val then
                    toggled = val
                    if ToggleObj.UpdateAnim then ToggleObj.UpdateAnim() end
                    Library.Unsaved = true
                    quietCallback(val)
                end
            end
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 32)
            Btn.BackgroundColor3 = Theme.Container
            Btn.Text = ""
            Btn.AutoButtonColor = false
            Btn.Parent = Content
            Corner(Btn, 4)
            Stroke(Btn, Theme.Stroke, 1, 0.5)
            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Font = Config.FontMain
            Label.TextSize = 13
            Label.TextColor3 = Theme.Text
            Label.Size = UDim2.new(1, -30, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = Btn
            local Box = Instance.new("Frame")
            Box.Size = UDim2.new(0, 18, 0, 18)
            Box.Position = UDim2.new(1, -10, 0.5, 0)
            Box.AnchorPoint = Vector2.new(1, 0.5)
            Box.BackgroundColor3 = Theme.Background
            Box.Parent = Btn
            Corner(Box, 4)
            Stroke(Box, Theme.Stroke, 1, 0.5)
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(1, -4, 1, -4)
            Fill.Position = UDim2.new(0.5, 0, 0.5, 0)
            Fill.AnchorPoint = Vector2.new(0.5, 0.5)
            Fill.BackgroundColor3 = Theme.Accent
            Fill.BackgroundTransparency = toggled and 0 or 1
            Fill.Parent = Box
            Corner(Fill, 3)
            RegisterTheme(Fill, "BackgroundColor")
            local SubContainer = Instance.new("Frame")
            SubContainer.Name = "Sub_" .. text
            SubContainer.Size = UDim2.new(1, 0, 0, 0)
            SubContainer.BackgroundTransparency = 1
            SubContainer.ClipsDescendants = true
            SubContainer.Visible = false
            SubContainer.Parent = Content
            local SubList = Instance.new("UIListLayout")
            SubList.Padding = UDim.new(0, 6)
            SubList.SortOrder = Enum.SortOrder.LayoutOrder
            SubList.Parent = SubContainer
            local currentTween = nil
            local function ToggleAnim()
                if currentTween then currentTween:Cancel() end
                Tween(Fill, {BackgroundTransparency = toggled and 0 or 1}, 0.2)
                Library.Flags[flag] = toggled
                if ToggleObj.KeybindValue then
                    Library:UpdateKeybindList(text, ToggleObj.KeybindValue.Name, toggled, ToggleObj.KeybindMode)
                end
                if toggled then
                    SubContainer.Visible = true
                    SubContainer.ClipsDescendants = true
                    local sc2 = (Library._MainScale and Library._MainScale.Scale > 0) and Library._MainScale.Scale or 1
                    local h = SubList.AbsoluteContentSize.Y / sc2
                    if h > 0 then h = h + 6 end
                    currentTween = TweenService:Create(SubContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, h)})
                    currentTween:Play()
                    local tc
                    tc = currentTween.Completed:Connect(function(state)
                        if state == Enum.PlaybackState.Completed and toggled then SubContainer.ClipsDescendants = false end
                        tc:Disconnect()
                    end)
                else
                    SubContainer.ClipsDescendants = true
                    currentTween = TweenService:Create(SubContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)})
                    currentTween:Play()
                    local expectedToggle = toggled
                    local tc
                    tc = currentTween.Completed:Connect(function(playbackState)
                        if playbackState == Enum.PlaybackState.Completed and expectedToggle == toggled and not toggled then SubContainer.Visible = false end
                        tc:Disconnect()
                    end)
                end
            end
            ToggleObj.UpdateAnim = ToggleAnim
            ToggleObj.Set = function(_, state)
                state = state and true or false
                if toggled == state then return end
                toggled = state
                ToggleAnim()
                quietCallback(toggled)
            end
            local tlc1 = SubList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if toggled then
                    local sc3 = (Library._MainScale and Library._MainScale.Scale > 0) and Library._MainScale.Scale or 1
                    local h = SubList.AbsoluteContentSize.Y / sc3
                    if h > 0 then h = h + 6 end
                    SubContainer.Size = UDim2.new(1, 0, 0, h)
                end
            end)
            table.insert(Library.Connections, tlc1)
            local tlc2 = Btn.MouseButton1Click:Connect(function()
                toggled = not toggled
                Library.Unsaved = true
                ToggleAnim()
                callback(toggled)
            end)
            table.insert(Library.Connections, tlc2)
            if toggled then ToggleAnim() end
            ApplyTooltip(Btn, tooltipText)
            task.spawn(callback, toggled)
            return ToggleObj
        end
        function Section:TextBox(text, flag, placeholder, tooltipText, callback)
            Library.Defaults[flag] = ""
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 50)
            Frame.BackgroundTransparency = 1
            Frame.Parent = Content
            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Font = Config.FontMain
            Label.TextSize = 13
            Label.TextColor3 = Theme.Text
            Label.Size = UDim2.new(1, 0, 0, 20)
            Label.Position = UDim2.new(0, 5, 0, 0)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = Frame
            local BoxCont = Instance.new("Frame")
            BoxCont.Size = UDim2.new(1, 0, 0, 28)
            BoxCont.Position = UDim2.new(0, 0, 0, 22)
            BoxCont.BackgroundColor3 = Theme.Container
            BoxCont.Parent = Frame
            Corner(BoxCont, 4)
            Stroke(BoxCont, Theme.Stroke, 1, 0.5)
            local Input = Instance.new("TextBox")
            Input.Size = UDim2.new(1, -10, 1, 0)
            Input.Position = UDim2.new(0, 5, 0, 0)
            Input.BackgroundTransparency = 1
            Input.TextColor3 = Theme.Text
            Input.PlaceholderText = placeholder
            Input.PlaceholderColor3 = Theme.TextDark
            Input.Font = Config.FontMain
            Input.TextSize = 13
            Input.TextXAlignment = Enum.TextXAlignment.Left
            local currentText = Library.Flags[flag] or ""
            Input.Text = currentText
            Input.ClearTextOnFocus = false
            Input.Parent = BoxCont
            local ic1 = Input.FocusLost:Connect(function(enter)
                if enter then
                    Library.Flags[flag] = Input.Text
                    Library.Unsaved = true
                    callback(Input.Text)
                end
            end)
            local ic2 = Input.Changed:Connect(function(prop)
                if prop == "Text" then Library.Flags[flag] = Input.Text end
            end)
            table.insert(Library.Connections, ic1)
            table.insert(Library.Connections, ic2)
            Library.Flags[flag] = currentText
            Library.Signals[flag] = function(val)
                Input.Text = val
                Library.Unsaved = true
                callback(val)
            end
            ApplyTooltip(Frame, tooltipText)
            task.spawn(callback, currentText)
            return Input
        end
        function Section:Dropdown(text, flag, options, default, tooltipText, callback, customParent, isMulti)
            return CreateDropdownElement(text, flag, options, default, tooltipText, callback, Content, Section, isMulti, customParent)
        end
        function Section:ColorPicker(text, flag, default, tooltipText, callback)
            local color = Library.Flags[flag] or default or Color3.fromRGB(255, 255, 255)
            Library.Defaults[flag] = default or Color3.fromRGB(255, 255, 255)
            Library.Flags[flag] = color
            local h, s, v = color:ToHSV()
            local isOpen = false
            local ContainerFrame = Instance.new("Frame")
            ContainerFrame.Size = UDim2.new(1, 0, 0, 30)
            ContainerFrame.BackgroundTransparency = 1
            ContainerFrame.Parent = Content
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 30)
            Frame.BackgroundTransparency = 1
            Frame.Parent = ContainerFrame
            Frame.ZIndex = 5
            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Font = Config.FontMain
            Label.TextSize = 13
            Label.TextColor3 = Theme.Text
            Label.Size = UDim2.new(0.6, 0, 1, 0)
            Label.Position = UDim2.new(0, 5, 0, 0)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = Frame
            local Preview = Instance.new("TextButton")
            Preview.Size = UDim2.new(0, 40, 0, 20)
            Preview.Position = UDim2.new(1, -5, 0.5, 0)
            Preview.AnchorPoint = Vector2.new(1, 0.5)
            Preview.BackgroundColor3 = color
            Preview.AutoButtonColor = false
            Preview.Text = ""
            Preview.Parent = Frame
            Corner(Preview, 4)
            Stroke(Preview, Theme.Stroke, 1, 0.5)
            local PickerCont = Instance.new("Frame")
            PickerCont.Size = UDim2.new(1, 0, 0, 0)
            PickerCont.Position = UDim2.new(0, 0, 0, 30)
            PickerCont.BackgroundColor3 = Theme.Background
            PickerCont.Parent = ContainerFrame
            PickerCont.ClipsDescendants = true
            PickerCont.Visible = false
            PickerCont.ZIndex = 10
            Corner(PickerCont, 4)
            local SVMap = Instance.new("ImageLabel")
            SVMap.Size = UDim2.new(0, 140, 0, 120)
            SVMap.Position = UDim2.new(0, 10, 0, 10)
            SVMap.Image = "rbxassetid://4155801252"
            SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            SVMap.Parent = PickerCont
            SVMap.ZIndex = 11
            SVMap.Active = true
            Corner(SVMap, 4)
            local SVCursor = Instance.new("Frame")
            SVCursor.Size = UDim2.new(0, 8, 0, 8)
            SVCursor.AnchorPoint = Vector2.new(0.5, 0.5)
            SVCursor.BackgroundColor3 = Color3.new(1, 1, 1)
            SVCursor.Parent = SVMap
            SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
            SVCursor.ZIndex = 12
            Corner(SVCursor, 4)
            local HueBar = Instance.new("ImageLabel")
            HueBar.Size = UDim2.new(0, 20, 0, 120)
            HueBar.Position = UDim2.new(0, 160, 0, 10)
            HueBar.Image = "rbxassetid://4155801252"
            HueBar.Parent = PickerCont
            HueBar.ZIndex = 11
            HueBar.Active = true
            Corner(HueBar, 4)
            local UIGradient = Instance.new("UIGradient")
            UIGradient.Rotation = 90
            UIGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            })
            UIGradient.Parent = HueBar
            local HCursor = Instance.new("Frame")
            HCursor.Size = UDim2.new(1, 0, 0, 2)
            HCursor.BackgroundColor3 = Color3.new(1, 1, 1)
            HCursor.Parent = HueBar
            HCursor.Position = UDim2.new(0, 0, h, 0)
            HCursor.ZIndex = 12
            local HexInput = Instance.new("TextBox")
            HexInput.Size = UDim2.new(0, 170, 0, 20)
            HexInput.Position = UDim2.new(0, 10, 0, 140)
            HexInput.BackgroundColor3 = Theme.Container
            HexInput.TextColor3 = Theme.Text
            HexInput.Font = Config.FontMain
            HexInput.TextSize = 12
            HexInput.Text = "#" .. color:ToHex()
            HexInput.Parent = PickerCont
            HexInput.ZIndex = 11
            Corner(HexInput, 4)
            Stroke(HexInput, Theme.Stroke, 1)
            local function Update()
                color = Color3.fromHSV(h, s, v)
                Preview.BackgroundColor3 = color
                SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                HexInput.Text = "#" .. color:ToHex()
                Library.Flags[flag] = color
                Library.Unsaved = true
                callback(color)
            end
            local hc1 = HexInput.FocusLost:Connect(function()
                local t = HexInput.Text:gsub("#", "")
                if t:match("^[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]$") then
                    pcall(function()
                        local nc = Color3.fromHex(t)
                        h, s, v = nc:ToHSV()
                        HCursor.Position = UDim2.new(0, 0, h, 0)
                        SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                        Update()
                    end)
                else
                    HexInput.Text = "#" .. color:ToHex()
                end
            end)
            table.insert(Library.Connections, hc1)
            Library.Signals[flag] = function(val)
                if typeof(val) == "Color3" then
                    color = val
                    h, s, v = color:ToHSV()
                    HCursor.Position = UDim2.new(0, 0, h, 0)
                    SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                    Update()
                end
            end
            local function SetSV(input)
                local rX = math.clamp((input.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1)
                local rY = math.clamp((input.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1)
                s = rX
                v = 1 - rY
                SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                Update()
            end
            local function SetH(input)
                local rY = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                h = rY
                HCursor.Position = UDim2.new(0, 0, h, 0)
                Update()
            end
            local sv1 = SVMap.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    SetSV(input)
                    BeginDrag(input, SetSV)
                end
            end)
            table.insert(Library.Connections, sv1)
            local h1 = HueBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    SetH(input)
                    BeginDrag(input, SetH)
                end
            end)
            table.insert(Library.Connections, h1)
            local pc1 = Preview.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                Section.Container.ZIndex = isOpen and 10 or 1
                ContainerFrame.ZIndex = isOpen and 10 or 5
                if isOpen then
                    PickerCont.Visible = true
                    Tween(ContainerFrame, {Size = UDim2.new(1, 0, 0, 200)}, 0.2)
                    Tween(PickerCont, {Size = UDim2.new(1, 0, 0, 170)}, 0.2)
                else
                    Tween(ContainerFrame, {Size = UDim2.new(1, 0, 0, 30)}, 0.2)
                    local t = Tween(PickerCont, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    local pc2
                    pc2 = t.Completed:Connect(function()
                        if not isOpen then PickerCont.Visible = false end
                        pc2:Disconnect()
                    end)
                end
            end)
            table.insert(Library.Connections, pc1)
            ApplyTooltip(ContainerFrame, tooltipText)
            task.spawn(callback, color)
        end
        return Section
    end
    local function PopulateSettings()
        local SetPage = Instance.new("ScrollingFrame")
        SetPage.Size = UDim2.new(1, -200, 1, -54)
        SetPage.Position = UDim2.new(0, 190, 0, 44)
        SetPage.BackgroundTransparency = 1
        SetPage.ScrollBarThickness = 2
        SetPage.ScrollBarImageColor3 = Theme.Accent
        SetPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
        SetPage.Active = true
        SetPage.Parent = SettingsWindow
        RegisterTheme(SetPage, "ScrollBar")
        local ListLayout = Instance.new("UIListLayout")
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Padding = UDim.new(0, 10)
        ListLayout.Parent = SetPage
        local MenuSec = WindowObj:CreateRawSection("Menu Settings", SetPage)
        MenuSec:Button("Unload UI", "Destroys the Hub", function()
            Library:Unload()
        end)
        local keybindBtn
        keybindBtn = MenuSec:Button("Menu Keybind: " .. tostring(Config.Keybind.Name), "Change the open/close key", function()
            keybindBtn.Text = "Press any key..."
            local conn
            conn = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
                        Config.Keybind = Enum.KeyCode.LeftControl
                    elseif input.KeyCode ~= Enum.KeyCode.Escape and input.KeyCode ~= Enum.KeyCode.Unknown then
                        Config.Keybind = input.KeyCode
                    end
                    keybindBtn.Text = "Menu Keybind: " .. tostring(Config.Keybind.Name)
                    Library:Notify("Settings", "Menu keybind set to " .. tostring(Config.Keybind.Name), 2)
                    conn:Disconnect()
                end
            end)
        end)
        local hideBindBtn
        hideBindBtn = MenuSec:Button("Hide UI Keybind: " .. tostring(Config.HideKeybind.Name), "Change the fully hide/show key", function()
            hideBindBtn.Text = "Press any key..."
            local conn
            conn = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
                        Config.HideKeybind = Enum.KeyCode.Unknown
                    elseif input.KeyCode ~= Enum.KeyCode.Escape and input.KeyCode ~= Enum.KeyCode.Unknown then
                        Config.HideKeybind = input.KeyCode
                    end
                    hideBindBtn.Text = "Hide UI Keybind: " .. tostring(Config.HideKeybind.Name)
                    Library:Notify("Settings", "Hide UI keybind set to " .. tostring(Config.HideKeybind.Name), 2)
                    conn:Disconnect()
                end
            end)
        end)
        MenuSec:Toggle("Show Keybind List", "KeybindListToggle", true, "Show the keybind list (quick toggle buttons on mobile)", function(state)
            Library.ShowKeybinds = state
            if Library.RefreshBindList then Library.RefreshBindList() end
        end)
        MenuSec:Toggle("Show Console", "ConsoleToggle", false, "Show the console window (info / warnings / errors)", function(state)
            Library:SetConsoleVisible(state)
        end)
        MenuSec:ColorPicker("Accent Color", "MenuAccentColor", Theme.Accent, "Change the theme color", function(col)
            Library:UpdateTheme(col)
        end)
        MenuSec:Dropdown("Theme", "SelectedTheme", {"Halloween", "Phantom Red", "Midnight", "Emerald", "Royal Purple", "Graphite", "Solar"}, Config.Theme, "Switch the whole UI theme", function(name)
            Library:SetTheme(name)
        end)
        local ConfigSec = WindowObj:CreateRawSection("Configuration", SetPage)
        local ConfigContent = ConfigSec.Container:FindFirstChild("Content")
        local configNameInput = ""
        local selectedConfigName = ""
        local ConfigList = Library:GetConfigs()
        local CNameFrame = Instance.new("Frame")
        CNameFrame.Size = UDim2.new(1, 0, 0, 50)
        CNameFrame.BackgroundTransparency = 1
        CNameFrame.LayoutOrder = 1
        CNameFrame.Parent = ConfigContent
        local CNameLabel = Instance.new("TextLabel")
        CNameLabel.Text = "Config Name"
        CNameLabel.Font = Config.FontMain
        CNameLabel.TextSize = 13
        CNameLabel.TextColor3 = Theme.Text
        CNameLabel.Size = UDim2.new(1, 0, 0, 20)
        CNameLabel.Position = UDim2.new(0, 5, 0, 0)
        CNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        CNameLabel.BackgroundTransparency = 1
        CNameLabel.Parent = CNameFrame
        local CNameBoxCont = Instance.new("Frame")
        CNameBoxCont.Size = UDim2.new(1, 0, 0, 28)
        CNameBoxCont.Position = UDim2.new(0, 0, 0, 22)
        CNameBoxCont.BackgroundColor3 = Theme.Container
        CNameBoxCont.Parent = CNameFrame
        Corner(CNameBoxCont, 4)
        Stroke(CNameBoxCont, Theme.Stroke, 1, 0.5)
        local CNameInput = Instance.new("TextBox")
        CNameInput.Size = UDim2.new(1, -10, 1, 0)
        CNameInput.Position = UDim2.new(0, 5, 0, 0)
        CNameInput.BackgroundTransparency = 1
        CNameInput.TextColor3 = Theme.Text
        CNameInput.PlaceholderText = "Type config name..."
        CNameInput.PlaceholderColor3 = Theme.TextDark
        CNameInput.Font = Config.FontMain
        CNameInput.TextSize = 13
        CNameInput.TextXAlignment = Enum.TextXAlignment.Left
        CNameInput.Text = ""
        CNameInput.ClearTextOnFocus = false
        CNameInput.Parent = CNameBoxCont
        local c2 = CNameInput:GetPropertyChangedSignal("Text"):Connect(function()
            configNameInput = CNameInput.Text
        end)
        table.insert(Library.Connections, c2)
        local ConfigDropdownFrame = Instance.new("Frame")
        ConfigDropdownFrame.Size = UDim2.new(1, 0, 0, 46)
        ConfigDropdownFrame.BackgroundTransparency = 1
        ConfigDropdownFrame.LayoutOrder = 2
        ConfigDropdownFrame.Parent = ConfigContent
        local CDLabel = Instance.new("TextLabel")
        CDLabel.Text = "Select Config"
        CDLabel.Font = Config.FontMain
        CDLabel.TextSize = 13
        CDLabel.TextColor3 = Theme.Text
        CDLabel.Size = UDim2.new(1, 0, 0, 16)
        CDLabel.Position = UDim2.new(0, 5, 0, 0)
        CDLabel.TextXAlignment = Enum.TextXAlignment.Left
        CDLabel.BackgroundTransparency = 1
        CDLabel.Parent = ConfigDropdownFrame
        local CDInteractive = Instance.new("TextButton")
        CDInteractive.Size = UDim2.new(1, 0, 0, 26)
        CDInteractive.Position = UDim2.new(0, 0, 0, 20)
        CDInteractive.BackgroundColor3 = Theme.Container
        CDInteractive.Text = ""
        CDInteractive.AutoButtonColor = false
        CDInteractive.Parent = ConfigDropdownFrame
        CDInteractive.ZIndex = 5
        Corner(CDInteractive, 4)
        Stroke(CDInteractive, Theme.Stroke, 1, 0.5)
        local CDSelectedText = Instance.new("TextLabel")
        CDSelectedText.Font = Config.FontMain
        CDSelectedText.TextSize = 13
        CDSelectedText.TextColor3 = Theme.Text
        CDSelectedText.Size = UDim2.new(1, -25, 1, 0)
        CDSelectedText.Position = UDim2.new(0, 8, 0, 0)
        CDSelectedText.TextXAlignment = Enum.TextXAlignment.Left
        CDSelectedText.BackgroundTransparency = 1
        CDSelectedText.ZIndex = 6
        CDSelectedText.ClipsDescendants = false
        CDSelectedText.TextTruncate = Enum.TextTruncate.AtEnd
        CDSelectedText.Parent = CDInteractive
        local CDArrow = Instance.new("ImageLabel")
        CDArrow.Image = "rbxassetid://10709790948"
        CDArrow.Size = UDim2.new(0, 18, 0, 18)
        CDArrow.Position = UDim2.new(1, -20, 0.5, 0)
        CDArrow.AnchorPoint = Vector2.new(0, 0.5)
        CDArrow.BackgroundTransparency = 1
        CDArrow.ImageColor3 = Theme.TextDark
        CDArrow.Parent = CDInteractive
        CDArrow.ZIndex = 6
        local CDListFrame = Instance.new("ScrollingFrame")
        CDListFrame.Size = UDim2.new(1, 0, 0, 0)
        CDListFrame.Position = UDim2.new(0, 0, 1, 5)
        CDListFrame.BackgroundColor3 = Theme.Container
        CDListFrame.BorderSizePixel = 0
        CDListFrame.Parent = CDInteractive
        CDListFrame.ZIndex = 10
        CDListFrame.Visible = false
        CDListFrame.Active = true
        CDListFrame.ScrollBarThickness = 2
        CDListFrame.ScrollBarImageColor3 = Theme.Accent
        CDListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Corner(CDListFrame, 4)
        Stroke(CDListFrame, Theme.Stroke, 1, 0.5)
        local CDIList = Instance.new("UIListLayout")
        CDIList.SortOrder = Enum.SortOrder.LayoutOrder
        CDIList.Parent = CDListFrame
        local cdIsDropped = false
        local cdOptionBtns = {}
        selectedConfigName = #ConfigList > 0 and ConfigList[1] or ""
        CDSelectedText.Text = selectedConfigName ~= "" and selectedConfigName or "No configs"
        local function CDCloseDropdown()
            cdIsDropped = false
            ConfigSec.Container.ZIndex = 1
            ConfigDropdownFrame.ZIndex = 5
            Tween(ConfigDropdownFrame, {Size = UDim2.new(1, 0, 0, 46)}, 0.2)
            local t = Tween(CDListFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            Tween(CDArrow, {Rotation = 0}, 0.2)
            local c4
            c4 = t.Completed:Connect(function()
                if not cdIsDropped then CDListFrame.Visible = false end
                c4:Disconnect()
            end)
        end
        local function CDBuildOptions(opts)
            for _, btn in pairs(cdOptionBtns) do btn:Destroy() end
            table.clear(cdOptionBtns)
            for _, opt in ipairs(opts) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 24)
                OptBtn.BackgroundColor3 = Theme.Container
                OptBtn.BackgroundTransparency = 1
                OptBtn.Text = opt
                OptBtn.Font = Config.FontMain
                OptBtn.TextSize = 12
                OptBtn.Parent = CDListFrame
                OptBtn.ZIndex = 11
                OptBtn.TextColor3 = (selectedConfigName == opt) and Theme.Accent or Theme.TextDark
                cdOptionBtns[opt] = OptBtn
                local c5 = OptBtn.MouseEnter:Connect(function()
                    if selectedConfigName ~= opt then Tween(OptBtn, {BackgroundTransparency = 0.8, TextColor3 = Theme.Accent}) end
                end)
                local c6 = OptBtn.MouseLeave:Connect(function()
                    if selectedConfigName ~= opt then Tween(OptBtn, {BackgroundTransparency = 1, TextColor3 = Theme.TextDark}) end
                end)
                local c7 = OptBtn.MouseButton1Click:Connect(function()
                    selectedConfigName = opt
                    CDSelectedText.Text = opt
                    for o, b in pairs(cdOptionBtns) do b.TextColor3 = (o == opt) and Theme.Accent or Theme.TextDark end
                    CDCloseDropdown()
                end)
                table.insert(Library.Connections, c5)
                table.insert(Library.Connections, c6)
                table.insert(Library.Connections, c7)
            end
        end
        CDBuildOptions(ConfigList)
        local c8 = CDInteractive.MouseButton1Click:Connect(function()
            cdIsDropped = not cdIsDropped
            ConfigSec.Container.ZIndex = cdIsDropped and 10 or 1
            ConfigDropdownFrame.ZIndex = cdIsDropped and 10 or 5
            if cdIsDropped then
                CDListFrame.Visible = true
                local currentList = Library:GetConfigs()
                CDBuildOptions(currentList)
                local listH = math.min(#currentList * 24, 200)
                if listH < 24 then listH = 24 end
                local totalH = 46 + listH + 5
                Tween(ConfigDropdownFrame, {Size = UDim2.new(1, 0, 0, totalH)}, 0.2)
                Tween(CDListFrame, {Size = UDim2.new(1, 0, 0, listH)}, 0.2)
                Tween(CDArrow, {Rotation = 180}, 0.2)
            else
                CDCloseDropdown()
            end
        end)
        table.insert(Library.Connections, c8)
        local function RefreshConfigDropdown()
            local newList = Library:GetConfigs()
            ConfigList = newList
            if not table.find(newList, selectedConfigName) then
                selectedConfigName = #newList > 0 and newList[1] or ""
            end
            CDSelectedText.Text = selectedConfigName ~= "" and selectedConfigName or "No configs"
            CDBuildOptions(newList)
        end
        local CreateBtn = Instance.new("TextButton")
        CreateBtn.Size = UDim2.new(1, 0, 0, 32)
        CreateBtn.BackgroundColor3 = Theme.Container
        CreateBtn.Text = "Create New Config"
        CreateBtn.Font = Config.FontMain
        CreateBtn.TextSize = 13
        CreateBtn.TextColor3 = Theme.Text
        CreateBtn.AutoButtonColor = false
        CreateBtn.LayoutOrder = 3
        CreateBtn.Parent = ConfigContent
        Corner(CreateBtn, 4)
        local cs1 = Stroke(CreateBtn, Theme.Stroke, 1, 0.5)
        local c9 = CreateBtn.MouseEnter:Connect(function() Tween(CreateBtn, {BackgroundColor3 = Theme.Stroke}) Tween(cs1, {Color = Theme.Accent}) end)
        local c10 = CreateBtn.MouseLeave:Connect(function() Tween(CreateBtn, {BackgroundColor3 = Theme.Container}) Tween(cs1, {Color = Theme.Stroke}) end)
        local c11 = CreateBtn.MouseButton1Click:Connect(function()
            local name = configNameInput
            if not name or name == "" or string.match(name, "^%s*$") then
                Library:Notify("Error", "Please type a config name first", 3)
                return
            end
            name = string.gsub(name, "^%s+", "")
            name = string.gsub(name, "%s+$", "")
            if name == "" then
                Library:Notify("Error", "Please type a config name first", 3)
                return
            end
            if Library:ConfigExists(name) then
                Library:Notify("Error", "Config '" .. name .. "' already exists", 3)
                return
            end
            if Library:SaveConfig(name) then
                selectedConfigName = name
                CNameInput.Text = ""
                configNameInput = ""
                RefreshConfigDropdown()
                Library:Notify("Config", "Created: " .. name, 3)
            else
                Library:Notify("Error", "Failed to create config", 3)
            end
        end)
        table.insert(Library.Connections, c9)
        table.insert(Library.Connections, c10)
        table.insert(Library.Connections, c11)
        local LoadBtn = Instance.new("TextButton")
        LoadBtn.Size = UDim2.new(1, 0, 0, 32)
        LoadBtn.BackgroundColor3 = Theme.Container
        LoadBtn.Text = "Load Config"
        LoadBtn.Font = Config.FontMain
        LoadBtn.TextSize = 13
        LoadBtn.TextColor3 = Theme.Text
        LoadBtn.AutoButtonColor = false
        LoadBtn.LayoutOrder = 4
        LoadBtn.Parent = ConfigContent
        Corner(LoadBtn, 4)
        local cs2 = Stroke(LoadBtn, Theme.Stroke, 1, 0.5)
        local c12 = LoadBtn.MouseEnter:Connect(function() Tween(LoadBtn, {BackgroundColor3 = Theme.Stroke}) Tween(cs2, {Color = Theme.Accent}) end)
        local c13 = LoadBtn.MouseLeave:Connect(function() Tween(LoadBtn, {BackgroundColor3 = Theme.Container}) Tween(cs2, {Color = Theme.Stroke}) end)
        local c14 = LoadBtn.MouseButton1Click:Connect(function()
            local name = selectedConfigName
            if not name or name == "" then
                Library:Notify("Error", "No config selected", 3)
                return
            end
            if not Library:ConfigExists(name) then
                Library:Notify("Error", "Config '" .. name .. "' does not exist", 3)
                return
            end
            if Library:LoadConfig(name) then
                Library:Notify("Config", "Loaded: " .. name, 3)
            else
                Library:Notify("Error", "Failed to load config", 3)
            end
        end)
        table.insert(Library.Connections, c12)
        table.insert(Library.Connections, c13)
        table.insert(Library.Connections, c14)
        local RewriteBtn = Instance.new("TextButton")
        RewriteBtn.Size = UDim2.new(1, 0, 0, 32)
        RewriteBtn.BackgroundColor3 = Theme.Container
        RewriteBtn.Text = "Rewrite Config"
        RewriteBtn.Font = Config.FontMain
        RewriteBtn.TextSize = 13
        RewriteBtn.TextColor3 = Theme.Text
        RewriteBtn.AutoButtonColor = false
        RewriteBtn.LayoutOrder = 5
        RewriteBtn.Parent = ConfigContent
        Corner(RewriteBtn, 4)
        local cs3 = Stroke(RewriteBtn, Theme.Stroke, 1, 0.5)
        local c15 = RewriteBtn.MouseEnter:Connect(function() Tween(RewriteBtn, {BackgroundColor3 = Theme.Stroke}) Tween(cs3, {Color = Theme.Accent}) end)
        local c16 = RewriteBtn.MouseLeave:Connect(function() Tween(RewriteBtn, {BackgroundColor3 = Theme.Container}) Tween(cs3, {Color = Theme.Stroke}) end)
        local c17 = RewriteBtn.MouseButton1Click:Connect(function()
            local name = selectedConfigName
            if not name or name == "" then
                Library:Notify("Error", "No config selected", 3)
                return
            end
            if not Library:ConfigExists(name) then
                Library:Notify("Error", "Config '" .. name .. "' does not exist", 3)
                return
            end
            if Library:SaveConfig(name) then
                Library:Notify("Config", "Rewritten: " .. name, 3)
            else
                Library:Notify("Error", "Failed to rewrite config", 3)
            end
        end)
        table.insert(Library.Connections, c15)
        table.insert(Library.Connections, c16)
        table.insert(Library.Connections, c17)
        local DeleteBtn = Instance.new("TextButton")
        DeleteBtn.Size = UDim2.new(1, 0, 0, 32)
        DeleteBtn.BackgroundColor3 = Theme.Container
        DeleteBtn.Text = "Delete Config"
        DeleteBtn.Font = Config.FontMain
        DeleteBtn.TextSize = 13
        DeleteBtn.TextColor3 = Theme.Text
        DeleteBtn.AutoButtonColor = false
        DeleteBtn.LayoutOrder = 6
        DeleteBtn.Parent = ConfigContent
        Corner(DeleteBtn, 4)
        local cs4 = Stroke(DeleteBtn, Theme.Stroke, 1, 0.5)
        local c18 = DeleteBtn.MouseEnter:Connect(function() Tween(DeleteBtn, {BackgroundColor3 = Theme.Stroke}) Tween(cs4, {Color = Theme.Accent}) end)
        local c19 = DeleteBtn.MouseLeave:Connect(function() Tween(DeleteBtn, {BackgroundColor3 = Theme.Container}) Tween(cs4, {Color = Theme.Stroke}) end)
        local c20 = DeleteBtn.MouseButton1Click:Connect(function()
            local name = selectedConfigName
            if not name or name == "" then
                Library:Notify("Error", "No config selected", 3)
                return
            end
            if not Library:ConfigExists(name) then
                Library:Notify("Error", "Config '" .. name .. "' does not exist", 3)
                return
            end
            if Library:DeleteConfig(name) then
                RefreshConfigDropdown()
                Library:Notify("Config", "Deleted: " .. name, 3)
            else
                Library:Notify("Error", "Failed to delete config", 3)
            end
        end)
        table.insert(Library.Connections, c18)
        table.insert(Library.Connections, c19)
        table.insert(Library.Connections, c20)
        local RefreshBtn = Instance.new("TextButton")
        RefreshBtn.Size = UDim2.new(1, 0, 0, 32)
        RefreshBtn.BackgroundColor3 = Theme.Container
        RefreshBtn.Text = "Refresh Config List"
        RefreshBtn.Font = Config.FontMain
        RefreshBtn.TextSize = 13
        RefreshBtn.TextColor3 = Theme.Text
        RefreshBtn.AutoButtonColor = false
        RefreshBtn.LayoutOrder = 7
        RefreshBtn.Parent = ConfigContent
        Corner(RefreshBtn, 4)
        local cs5 = Stroke(RefreshBtn, Theme.Stroke, 1, 0.5)
        local c21 = RefreshBtn.MouseEnter:Connect(function() Tween(RefreshBtn, {BackgroundColor3 = Theme.Stroke}) Tween(cs5, {Color = Theme.Accent}) end)
        local c22 = RefreshBtn.MouseLeave:Connect(function() Tween(RefreshBtn, {BackgroundColor3 = Theme.Container}) Tween(cs5, {Color = Theme.Stroke}) end)
        local c23 = RefreshBtn.MouseButton1Click:Connect(function()
            RefreshConfigDropdown()
            Library:Notify("Config", "List Refreshed", 2)
        end)
        table.insert(Library.Connections, c21)
        table.insert(Library.Connections, c22)
        table.insert(Library.Connections, c23)
        local ResetBtn = Instance.new("TextButton")
        ResetBtn.Size = UDim2.new(1, 0, 0, 32)
        ResetBtn.BackgroundColor3 = Theme.Container
        ResetBtn.Text = "Reset to Defaults"
        ResetBtn.Font = Config.FontMain
        ResetBtn.TextSize = 13
        ResetBtn.TextColor3 = Theme.Text
        ResetBtn.AutoButtonColor = false
        ResetBtn.LayoutOrder = 8
        ResetBtn.Parent = ConfigContent
        Corner(ResetBtn, 4)
        local cs6 = Stroke(ResetBtn, Theme.Stroke, 1, 0.5)
        local c24 = ResetBtn.MouseEnter:Connect(function() Tween(ResetBtn, {BackgroundColor3 = Theme.Stroke}) Tween(cs6, {Color = Theme.Accent}) end)
        local c25 = ResetBtn.MouseLeave:Connect(function() Tween(ResetBtn, {BackgroundColor3 = Theme.Container}) Tween(cs6, {Color = Theme.Stroke}) end)
        local c26 = ResetBtn.MouseButton1Click:Connect(function()
            for flag, val in pairs(Library.Defaults) do
                if IgnoredFlags[flag] then continue end
                Library.Flags[flag] = val
                if Library.Signals[flag] then
                    task.spawn(Library.Signals[flag], val)
                end
            end
            Library:Notify("Settings", "Reset to defaults", 3)
        end)
        table.insert(Library.Connections, c24)
        table.insert(Library.Connections, c25)
        table.insert(Library.Connections, c26)
    end
    PopulateSettings()
    function WindowObj:Tab(name, iconId)
        local Tab = {}
        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, -20, 1, -20)
        Page.Position = UDim2.new(0, 10, 0, 10)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.Visible = false
        Page.Active = true
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.Parent = MainPages
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 36)
        TabBtn.BackgroundColor3 = Theme.Background
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = TabContainer
        Corner(TabBtn, 6)
        local Title = Instance.new("TextLabel")
        Title.Text = name
        Title.Font = Config.FontMain
        Title.TextSize = 14
        Title.TextColor3 = Theme.TextDark
        Title.Size = UDim2.new(1, -20, 1, 0)
        Title.Position = UDim2.new(0, iconId and 35 or 15, 0, 0)
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.BackgroundTransparency = 1
        Title.Parent = TabBtn
        if iconId then
            local Ico = Instance.new("ImageLabel")
            Ico.Size = UDim2.new(0, 20, 0, 20)
            Ico.Position = UDim2.new(0, 8, 0.5, 0)
            Ico.AnchorPoint = Vector2.new(0, 0.5)
            Ico.BackgroundTransparency = 1
            ApplyIcon(Ico, iconId)
            Ico.ImageColor3 = Theme.Accent
            Ico.ImageTransparency = 0.45
            Ico.Parent = TabBtn
            local c1 = TabBtn.MouseEnter:Connect(function() if TabBtn.BackgroundTransparency > 0.5 then Tween(Ico, {ImageTransparency = 0.15}) end end)
            local c2 = TabBtn.MouseLeave:Connect(function() if TabBtn.BackgroundTransparency > 0.5 then Tween(Ico, {ImageTransparency = 0.45}) end end)
            table.insert(Library.Connections, c1)
            table.insert(Library.Connections, c2)
        end
        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 3, 0, 16)
        Indicator.Position = UDim2.new(0, 0, 0.5, -8)
        Indicator.BackgroundColor3 = Theme.Accent
        Indicator.BackgroundTransparency = 1
        Indicator.BorderSizePixel = 0
        Indicator.Visible = false
        Indicator.Parent = TabBtn
        local function ActivateTab()
            for _, p in pairs(MainPages:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
            for _, t in pairs(TabContainer:GetChildren()) do
                if t:IsA("TextButton") then
                    Tween(t.TextLabel, {TextColor3 = Theme.TextDark})
                    Tween(t, {BackgroundTransparency = 1, BackgroundColor3 = Theme.Background})
                    if t:FindFirstChild("ImageLabel") then Tween(t.ImageLabel, {ImageColor3 = Theme.Accent, ImageTransparency = 0.45}) end
                    Tween(t.Frame, {BackgroundTransparency = 1})
                end
            end
            Page.Visible = true
            Tween(Title, {TextColor3 = Theme.Text})
            Tween(TabBtn, {BackgroundTransparency = 0.95, BackgroundColor3 = Theme.Text})
            if TabBtn:FindFirstChild("ImageLabel") then Tween(TabBtn.ImageLabel, {ImageColor3 = Theme.Accent, ImageTransparency = 0}) end
            Tween(Indicator, {BackgroundTransparency = 0})
            WindowObj._ActiveTabBtn = TabBtn
        end
        OnThemeChanged(function()
            if not TabBtn.Parent then return end
            local active = WindowObj._ActiveTabBtn == TabBtn
            Title.TextColor3 = active and Theme.Text or Theme.TextDark
            Indicator.BackgroundColor3 = Theme.Accent
            local ico = TabBtn:FindFirstChild("ImageLabel")
            if ico then ico.ImageColor3 = Theme.Accent ico.ImageTransparency = active and 0 or 0.45 end
        end)
        Tab.Activate = ActivateTab
        local searchEntry = {Tab = name, Page = Page, Activate = ActivateTab, Sections = {}}
        table.insert(Library.SearchIndex, searchEntry)
        local c3 = TabBtn.MouseButton1Click:Connect(ActivateTab)
        table.insert(Library.Connections, c3)
        local tabCount = 0
        for _, c in pairs(TabContainer:GetChildren()) do
            if c:IsA("TextButton") then tabCount = tabCount + 1 end
        end
        if tabCount <= 1 then
            Page.Visible = true
            Title.TextColor3 = Theme.Text
            TabBtn.BackgroundTransparency = 0.95
            TabBtn.BackgroundColor3 = Theme.Text
            if TabBtn:FindFirstChild("ImageLabel") then TabBtn.ImageLabel.ImageColor3 = Theme.Accent TabBtn.ImageLabel.ImageTransparency = 0 end
            Indicator.BackgroundTransparency = 0
            WindowObj._ActiveTabBtn = TabBtn
        end
        local vp = workspace.CurrentCamera.ViewportSize
        local isMobile = vp.X < 700 or (vp.X / math.max(vp.Y, 1)) < 1.3
        local LeftCol = Instance.new("Frame")
        local RightCol = Instance.new("Frame")
        if isMobile then
            local PageList = Instance.new("UIListLayout")
            PageList.SortOrder = Enum.SortOrder.LayoutOrder
            PageList.Padding = UDim.new(0, 10)
            PageList.Parent = Page
            LeftCol.Size = UDim2.new(1, 0, 0, 0)
            LeftCol.Position = UDim2.new(0, 0, 0, 0)
            LeftCol.LayoutOrder = 1
            LeftCol.BackgroundTransparency = 1
            LeftCol.AutomaticSize = Enum.AutomaticSize.Y
            LeftCol.Parent = Page
            RightCol.Size = UDim2.new(1, 0, 0, 0)
            RightCol.Position = UDim2.new(0, 0, 0, 0)
            RightCol.LayoutOrder = 2
            RightCol.BackgroundTransparency = 1
            RightCol.AutomaticSize = Enum.AutomaticSize.Y
            RightCol.Parent = Page
        else
            LeftCol.Size = UDim2.new(0.5, -5, 0, 0)
            LeftCol.Position = UDim2.new(0, 0, 0, 0)
            LeftCol.BackgroundTransparency = 1
            LeftCol.AutomaticSize = Enum.AutomaticSize.Y
            LeftCol.Parent = Page
            RightCol.Size = UDim2.new(0.5, -5, 0, 0)
            RightCol.Position = UDim2.new(0.5, 5, 0, 0)
            RightCol.BackgroundTransparency = 1
            RightCol.AutomaticSize = Enum.AutomaticSize.Y
            RightCol.Parent = Page
        end
        local LeftList = Instance.new("UIListLayout")
        LeftList.SortOrder = Enum.SortOrder.LayoutOrder
        LeftList.Padding = UDim.new(0, 10)
        LeftList.Parent = LeftCol
        local RightList = Instance.new("UIListLayout")
        RightList.SortOrder = Enum.SortOrder.LayoutOrder
        RightList.Padding = UDim.new(0, 10)
        RightList.Parent = RightCol
        function Tab:Section(text, side)
            local Section = {}
            local ParentCol = (side == "Right" and RightCol or LeftCol)
            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, 0, 0, 0)
            Container.BackgroundColor3 = Theme.Section
            Container.Parent = ParentCol
            Container.ZIndex = 1
            Corner(Container, 6)
            Stroke(Container, Theme.Stroke, 1, 0.5)
            Section.Container = Container
            local secData = {Instance = Container, Items = {}, Title = text}
            table.insert(Library.Elements, secData)
            table.insert(searchEntry.Sections, secData)
            local STitle = Instance.new("TextLabel")
            STitle.Text = text
            STitle.Font = Config.FontBold
            STitle.TextSize = 12
            STitle.TextColor3 = Theme.TextDark
            STitle.Size = UDim2.new(1, -20, 0, 25)
            STitle.Position = UDim2.new(0, 10, 0, 0)
            STitle.BackgroundTransparency = 1
            STitle.TextXAlignment = Enum.TextXAlignment.Left
            STitle.Parent = Container
            local Content = Instance.new("Frame")
            Content.Size = UDim2.new(1, -10, 0, 0)
            Content.Position = UDim2.new(0, 5, 0, 25)
            Content.BackgroundTransparency = 1
            Content.Parent = Container
            local List = Instance.new("UIListLayout")
            List.Padding = UDim.new(0, 6)
            List.SortOrder = Enum.SortOrder.LayoutOrder
            List.Parent = Content
            local function UpdateSize()
                local sc = (Library._MainScale and Library._MainScale.Scale > 0) and Library._MainScale.Scale or 1
                Container.Size = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y / sc + 35)
                if isMobile then
                    Page.CanvasSize = UDim2.new(0, 0, 0, (LeftList.AbsoluteContentSize.Y + RightList.AbsoluteContentSize.Y) / sc + 30)
                else
                    Page.CanvasSize = UDim2.new(0, 0, 0, math.max(LeftList.AbsoluteContentSize.Y, RightList.AbsoluteContentSize.Y) / sc + 20)
                end
            end
            local c4 = List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)
            table.insert(Library.Connections, c4)
            function Section:Label(ltext, options)
                options = options or {}
                local LabelObj = {}
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 26)
                Frame.BackgroundColor3 = Theme.Container
                Frame.BackgroundTransparency = 0.5
                Frame.Parent = Content
                table.insert(secData.Items, {Name = ltext, Instance = Frame})
                Corner(Frame, 4)
                Stroke(Frame, Theme.Stroke, 1, 0.5)
                local Lbl = Instance.new("TextLabel")
                Lbl.Size = UDim2.new(1, -10, 1, -10)
                Lbl.Position = UDim2.new(0, 5, 0, 5)
                Lbl.BackgroundTransparency = 1
                Lbl.Text = tostring(ltext)
                Lbl.Font = Config.FontMain
                Lbl.TextSize = 13
                Lbl.TextColor3 = options.Color or Theme.Text
                Lbl.TextXAlignment = options.Alignment or Enum.TextXAlignment.Left
                Lbl.TextYAlignment = Enum.TextYAlignment.Top
                Lbl.RichText = true
                Lbl.TextWrapped = true
                Lbl.Parent = Frame
                local function UpdateHeight()
                    local textHeight = Lbl.TextBounds.Y
                    if textHeight > 16 then Frame.Size = UDim2.new(1, 0, 0, textHeight + 10) else Frame.Size = UDim2.new(1, 0, 0, 26) end
                end
                local boundsConn = Lbl:GetPropertyChangedSignal("TextBounds"):Connect(UpdateHeight)
                table.insert(Library.Connections, boundsConn)
                UpdateHeight()
                function LabelObj:Set(newText) Lbl.Text = tostring(newText) end
                function LabelObj:SetColor(newColor) Lbl.TextColor3 = newColor end
                return LabelObj
            end
            function Section:Bullet(ltext, col)
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 26)
                Frame.BackgroundColor3 = Theme.Container
                Frame.BackgroundTransparency = 0.5
                Frame.Parent = Content
                table.insert(secData.Items, {Name = ltext, Instance = Frame})
                Corner(Frame, 4)
                Stroke(Frame, Theme.Stroke, 1, 0.5)
                local Dot = Instance.new("Frame")
                Dot.Size = UDim2.new(0, 6, 0, 6)
                Dot.Position = UDim2.new(0, 10, 0, 9)
                Dot.AnchorPoint = Vector2.new(0, 0)
                Dot.BackgroundColor3 = (col == "added" and Theme.Success) or (col == "fixed" and Theme.Accent) or Theme.TextDark
                Dot.BorderSizePixel = 0
                Dot.Parent = Frame
                Corner(Dot, 3)
                local Lbl = Instance.new("TextLabel")
                Lbl.Size = UDim2.new(1, -26, 1, -10)
                Lbl.Position = UDim2.new(0, 22, 0, 5)
                Lbl.BackgroundTransparency = 1
                Lbl.Text = tostring(ltext)
                Lbl.Font = Config.FontMain
                Lbl.TextSize = 12
                Lbl.TextColor3 = Theme.Text
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.TextYAlignment = Enum.TextYAlignment.Top
                Lbl.TextWrapped = true
                Lbl.Parent = Frame
                local function UpdateHeight()
                    local textHeight = Lbl.TextBounds.Y
                    if textHeight > 16 then Frame.Size = UDim2.new(1, 0, 0, textHeight + 10) else Frame.Size = UDim2.new(1, 0, 0, 26) end
                end
                local boundsConn = Lbl:GetPropertyChangedSignal("TextBounds"):Connect(UpdateHeight)
                table.insert(Library.Connections, boundsConn)
                UpdateHeight()
            end
            function Section:Toggle(text, flag, default, tooltipText, callback, bindable)
                local quietCallback = WrapCallback(text, callback, false)
                callback = WrapCallback(text, callback, true)
                Library.Defaults[flag] = default or false
                local toggled = Library.Flags[flag]
                if toggled == nil then
                    toggled = default or false
                    Library.Flags[flag] = toggled
                end
                local ToggleObj = {}
                Library.Signals[flag] = function(val)
                    if toggled ~= val then
                        toggled = val
                        if ToggleObj.UpdateAnim then ToggleObj.UpdateAnim() end
                        Library.Unsaved = true
                        quietCallback(val)
                    end
                end
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 32)
                Btn.BackgroundColor3 = Theme.Container
                Btn.Text = ""
                Btn.AutoButtonColor = false
                Btn.Parent = Content
                table.insert(secData.Items, {Name = text, Instance = Btn})
                Corner(Btn, 4)
                Stroke(Btn, Theme.Stroke, 1, 0.5)
                local Label = Instance.new("TextLabel")
                Label.Text = text
                Label.Font = Config.FontMain
                Label.TextSize = 13
                Label.TextColor3 = Theme.Text
                Label.Size = UDim2.new(1, -96, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.TextTruncate = Enum.TextTruncate.AtEnd
                Label.BackgroundTransparency = 1
                Label.Parent = Btn
                local Box = Instance.new("Frame")
                Box.Size = UDim2.new(0, 18, 0, 18)
                Box.Position = UDim2.new(1, -10, 0.5, 0)
                Box.AnchorPoint = Vector2.new(1, 0.5)
                Box.BackgroundColor3 = Theme.Background
                Box.Parent = Btn
                Corner(Box, 4)
                Stroke(Box, Theme.Stroke, 1, 0.5)
                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new(1, -4, 1, -4)
                Fill.Position = UDim2.new(0.5, 0, 0.5, 0)
                Fill.AnchorPoint = Vector2.new(0.5, 0.5)
                Fill.BackgroundColor3 = Theme.Accent
                Fill.BackgroundTransparency = toggled and 0 or 1
                Fill.Parent = Box
                Corner(Fill, 3)
                RegisterTheme(Fill, "BackgroundColor")
                local SubContainer = Instance.new("Frame")
                SubContainer.Name = "Sub_" .. text
                SubContainer.Size = UDim2.new(1, 0, 0, 0)
                SubContainer.BackgroundTransparency = 1
                SubContainer.ClipsDescendants = true
                SubContainer.Visible = false
                SubContainer.Parent = Content
                local SubList = Instance.new("UIListLayout")
                SubList.Padding = UDim.new(0, 6)
                SubList.SortOrder = Enum.SortOrder.LayoutOrder
                SubList.Parent = SubContainer
                local currentTween = nil
                local function ToggleAnim()
                    if currentTween then currentTween:Cancel() end
                    Tween(Fill, {BackgroundTransparency = toggled and 0 or 1}, 0.2)
                    Library.Flags[flag] = toggled
                    if ToggleObj.BindName then
                        Library:RegisterBind(ToggleObj.BindName, {Active = toggled})
                    end
                    if ToggleObj.RefreshKeyBtn then ToggleObj.RefreshKeyBtn() end
                    if toggled then
                        SubContainer.Visible = true
                        SubContainer.ClipsDescendants = true
                        local h = SubList.AbsoluteContentSize.Y
                        if h > 0 then h = h + 6 end
                        currentTween = TweenService:Create(SubContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, h)})
                        currentTween:Play()
                        local tc
                        tc = currentTween.Completed:Connect(function(state)
                            if state == Enum.PlaybackState.Completed and toggled then SubContainer.ClipsDescendants = false end
                            tc:Disconnect()
                        end)
                    else
                        SubContainer.ClipsDescendants = true
                        currentTween = TweenService:Create(SubContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)})
                        currentTween:Play()
                        local expectedToggle = toggled
                        local tc
                        tc = currentTween.Completed:Connect(function(playbackState)
                            if playbackState == Enum.PlaybackState.Completed and expectedToggle == toggled and not toggled then SubContainer.Visible = false end
                            tc:Disconnect()
                        end)
                    end
                end
                ToggleObj.UpdateAnim = ToggleAnim
                local function SetToggled(state, quiet)
                    if toggled == state then return end
                    toggled = state
                    Library.Unsaved = true
                    ToggleAnim()
                    if quiet then quietCallback(toggled) else callback(toggled) end
                end
                ToggleObj.Set = function(_, state) SetToggled(state and true or false, true) end
                if bindable and not IsTouchOnly() then
                local bindName = text
                if Library.Binds[bindName] then bindName = text .. " (" .. STitle.Text .. ")" end
                ToggleObj.BindName = bindName
                local keyFlag = flag .. "_Keybind"
                local savedBind = Library.Flags[keyFlag]
                local hasSavedBind = type(savedBind) == "table" and savedBind.Key ~= nil
                local bindKey = hasSavedBind and savedBind.Key or Enum.KeyCode.Unknown
                local bindMode = (hasSavedBind and savedBind.Mode) or "Toggle"
                Library.Defaults[keyFlag] = {Key = Enum.KeyCode.Unknown, Mode = "Toggle"}
                Library.Flags[keyFlag] = {Key = bindKey, Mode = bindMode}
                ToggleObj.KeybindValue = bindKey
                ToggleObj.KeybindMode = bindMode
                local KeyBtn = Instance.new("TextButton")
                KeyBtn.Size = UDim2.new(0, 60, 0, 20)
                KeyBtn.Position = UDim2.new(1, -34, 0.5, 0)
                KeyBtn.AnchorPoint = Vector2.new(1, 0.5)
                KeyBtn.BackgroundColor3 = Theme.Background
                KeyBtn.BackgroundTransparency = 1
                KeyBtn.Text = ""
                KeyBtn.TextColor3 = Theme.TextDark
                KeyBtn.Font = Config.FontMain
                KeyBtn.TextSize = 11
                KeyBtn.AutoButtonColor = false
                KeyBtn.Parent = Btn
                Corner(KeyBtn, 4)
                local KeyStroke = Stroke(KeyBtn, Theme.Stroke, 1, 0.2)
                local binding = false
                local function RefreshKeyBtn()
                    if binding then return end
                    if bindKey ~= Enum.KeyCode.Unknown then
                        KeyBtn.Text = bindKey.Name
                        KeyBtn.BackgroundTransparency = 0.1
                        KeyBtn.TextColor3 = toggled and Theme.Accent or Theme.Text
                        KeyStroke.Color = toggled and Theme.Accent or Theme.Stroke
                    else
                        KeyBtn.Text = "BIND"
                        KeyBtn.BackgroundTransparency = 0.35
                        KeyBtn.TextColor3 = Theme.TextDark
                        KeyStroke.Color = Theme.Stroke
                    end
                end
                ToggleObj.RefreshKeyBtn = RefreshKeyBtn
                local function PushBind()
                    Library:RegisterBind(bindName, {
                        Key = bindKey.Name,
                        Mode = bindMode,
                        Active = toggled,
                        Toggle = function() SetToggled(not toggled) end,
                    })
                    RefreshKeyBtn()
                end
                local ModeGui
                local function SetBindMode(md)
                    bindMode = md
                    ToggleObj.KeybindMode = md
                    Library.Flags[keyFlag] = {Key = bindKey, Mode = bindMode}
                    Library.Unsaved = true
                    if md == "Always" then SetToggled(true) end
                    PushBind()
                end
                local kb1 = KeyBtn.MouseButton1Click:Connect(function()
                    if binding then return end
                    binding = true
                    KeyBtn.Text = "PRESS.."
                    KeyBtn.BackgroundTransparency = 0
                    KeyBtn.TextColor3 = Theme.Accent
                    KeyStroke.Color = Theme.Accent
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                        if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
                            bindKey = Enum.KeyCode.Unknown
                        elseif input.KeyCode ~= Enum.KeyCode.Escape and input.KeyCode ~= Enum.KeyCode.Unknown then
                            bindKey = input.KeyCode
                        end
                        ToggleObj.KeybindValue = bindKey
                        Library.Flags[keyFlag] = {Key = bindKey, Mode = bindMode}
                        Library.Unsaved = true
                        binding = false
                        conn:Disconnect()
                        PushBind()
                    end)
                end)
                table.insert(Library.Connections, kb1)
                do
                    ModeGui = Instance.new("Frame")
                    ModeGui.Size = UDim2.new(0, 80, 0, 60)
                    ModeGui.Position = UDim2.new(1, -34, 0, 24)
                    ModeGui.AnchorPoint = Vector2.new(1, 0)
                    ModeGui.BackgroundColor3 = Theme.Sidebar
                    ModeGui.Visible = false
                    ModeGui.ZIndex = 100
                    ModeGui.Parent = Btn
                    Corner(ModeGui, 4)
                    Stroke(ModeGui, Theme.Stroke, 1)
                    local ModeList = Instance.new("UIListLayout")
                    ModeList.Parent = ModeGui
                    for _, md in ipairs({"Toggle", "Hold", "Always"}) do
                        local mBtn = Instance.new("TextButton")
                        mBtn.Size = UDim2.new(1, 0, 0, 20)
                        mBtn.BackgroundTransparency = 1
                        mBtn.Text = md
                        mBtn.TextColor3 = Theme.TextDark
                        mBtn.Font = Config.FontMain
                        mBtn.TextSize = 11
                        mBtn.ZIndex = 101
                        mBtn.Parent = ModeGui
                        local mb1 = mBtn.MouseButton1Click:Connect(function()
                            ModeGui.Visible = false
                            SetBindMode(md)
                        end)
                        table.insert(Library.Connections, mb1)
                    end
                    local kb2 = KeyBtn.MouseButton2Click:Connect(function()
                        ModeGui.Visible = not ModeGui.Visible
                    end)
                    table.insert(Library.Connections, kb2)
                    local kb3 = UserInputService.InputBegan:Connect(function(input, gp)
                        if gp or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                        if bindKey == Enum.KeyCode.Unknown or input.KeyCode ~= bindKey then return end
                        if bindMode == "Toggle" then
                            SetToggled(not toggled)
                        elseif bindMode == "Hold" then
                            SetToggled(true)
                        end
                    end)
                    local kb4 = UserInputService.InputEnded:Connect(function(input, gp)
                        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                        if bindKey == Enum.KeyCode.Unknown or input.KeyCode ~= bindKey then return end
                        if bindMode == "Hold" then SetToggled(false) end
                    end)
                    table.insert(Library.Connections, kb3)
                    table.insert(Library.Connections, kb4)
                end
                Library.Signals[keyFlag] = function(val)
                    if type(val) ~= "table" then return end
                    bindKey = val.Key or Enum.KeyCode.Unknown
                    bindMode = val.Mode or "Toggle"
                    ToggleObj.KeybindValue = bindKey
                    ToggleObj.KeybindMode = bindMode
                    PushBind()
                end
                PushBind()
                else
                    Label.Size = UDim2.new(1, -36, 1, 0)
                end
                local c5 = SubList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if toggled then
                        local h = SubList.AbsoluteContentSize.Y
                        if h > 0 then h = h + 6 end
                        SubContainer.Size = UDim2.new(1, 0, 0, h)
                    end
                end)
                table.insert(Library.Connections, c5)
                local c6 = Btn.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    Library.Unsaved = true
                    ToggleAnim()
                    callback(toggled)
                end)
                table.insert(Library.Connections, c6)
                if toggled then ToggleAnim() end
                ApplyTooltip(Btn, tooltipText)
                task.spawn(callback, toggled)
                function ToggleObj:AddButton(txt, cb)
                    local SBtn = Instance.new("TextButton")
                    SBtn.Size = UDim2.new(1, -20, 0, 26)
                    SBtn.Position = UDim2.new(0, 20, 0, 0)
                    SBtn.BackgroundColor3 = Theme.Container
                    SBtn.Text = txt
                    SBtn.Font = Config.FontMain
                    SBtn.TextSize = 12
                    SBtn.TextColor3 = Theme.Text
                    SBtn.AutoButtonColor = false
                    SBtn.Parent = SubContainer
                    Corner(SBtn, 4)
                    local s = Stroke(SBtn, Theme.Stroke, 1, 0.5)
                    local tbc1 = SBtn.MouseEnter:Connect(function() Tween(SBtn, {BackgroundColor3 = Theme.Stroke}) Tween(s, {Color = Theme.Accent}) end)
                    local tbc2 = SBtn.MouseLeave:Connect(function() Tween(SBtn, {BackgroundColor3 = Theme.Container}) Tween(s, {Color = Theme.Stroke}) end)
                    local tbc3 = SBtn.MouseButton1Click:Connect(cb)
                    table.insert(Library.Connections, tbc1)
                    table.insert(Library.Connections, tbc2)
                    table.insert(Library.Connections, tbc3)
                end
                function ToggleObj:AddSlider(txt, sflag, min, max, def, cb, inc)
                    inc = inc or 1
                    local val = Library.Flags[sflag]
                    if val == nil then val = def or min end
                    val = RoundToIncrement(val, inc)
                    Library.Defaults[sflag] = val
                    Library.Flags[sflag] = val
                    local range = max - min
                    local SFrame = Instance.new("Frame")
                    SFrame.Size = UDim2.new(1, -20, 0, 36)
                    SFrame.Position = UDim2.new(0, 20, 0, 0)
                    SFrame.BackgroundTransparency = 1
                    SFrame.Parent = SubContainer
                    local SLabel = Instance.new("TextLabel")
                    SLabel.Text = txt
                    SLabel.Font = Config.FontMain
                    SLabel.TextSize = 12
                    SLabel.TextColor3 = Theme.TextDark
                    SLabel.Size = UDim2.new(1, 0, 0, 16)
                    SLabel.TextXAlignment = Enum.TextXAlignment.Left
                    SLabel.BackgroundTransparency = 1
                    SLabel.Parent = SFrame
                    local SValue = Instance.new("TextBox")
                    SValue.Text = FormatNumber(val, inc)
                    SValue.Font = Config.FontMain
                    SValue.TextSize = 12
                    SValue.TextColor3 = Theme.Text
                    SValue.Size = UDim2.new(1, 0, 0, 16)
                    SValue.TextXAlignment = Enum.TextXAlignment.Right
                    SValue.BackgroundTransparency = 1
                    SValue.ClearTextOnFocus = true
                    SValue.Parent = SFrame
                    local SlideBg = Instance.new("Frame")
                    SlideBg.Size = UDim2.new(1, 0, 0, 6)
                    SlideBg.Position = UDim2.new(0, 0, 0, 22)
                    SlideBg.BackgroundColor3 = Theme.Background
                    SlideBg.Parent = SFrame
                    Corner(SlideBg, 3)
                    local SlideFill = Instance.new("Frame")
                    local ratio = range > 0 and (val - min) / range or 0
                    SlideFill.Size = UDim2.new(ratio, 0, 1, 0)
                    SlideFill.BackgroundColor3 = Theme.Accent
                    SlideFill.BorderSizePixel = 0
                    SlideFill.Parent = SlideBg
                    Corner(SlideFill, 3)
                    RegisterTheme(SlideFill, "BackgroundColor")
                    local function Set(input)
                        local r = math.clamp((input.Position.X - SlideBg.AbsolutePosition.X) / SlideBg.AbsoluteSize.X, 0, 1)
                        local raw = min + (max - min) * r
                        val = RoundToIncrement(raw, inc)
                        val = math.clamp(val, min, max)
                        local displayRatio = range > 0 and (val - min) / range or 0
                        SValue.Text = FormatNumber(val, inc)
                        Tween(SlideFill, {Size = UDim2.new(displayRatio, 0, 1, 0)}, 0.05)
                        Library.Flags[sflag] = val
                        Library.Unsaved = true
                        cb(val)
                    end
                    local ts1 = SlideBg.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                            Set(i)
                            BeginDrag(i, Set)
                        end
                    end)
                    table.insert(Library.Connections, ts1)
                    local ts4 = SValue.FocusLost:Connect(function(enter)
                        if enter then
                            local cleanText = string.gsub(SValue.Text, "[^%d.-]", "")
                            local num = tonumber(cleanText)
                            if num then
                                num = RoundToIncrement(num, inc)
                                num = math.clamp(num, min, max)
                                val = num
                                local displayRatio = range > 0 and (val - min) / range or 0
                                SValue.Text = FormatNumber(val, inc)
                                Tween(SlideFill, {Size = UDim2.new(displayRatio, 0, 1, 0)}, 0.05)
                                Library.Flags[sflag] = val
                                Library.Unsaved = true
                                cb(val)
                            else
                                SValue.Text = FormatNumber(val, inc)
                            end
                        else
                            SValue.Text = FormatNumber(val, inc)
                        end
                    end)
                    table.insert(Library.Connections, ts4)
                    Library.Signals[sflag] = function(loadedVal)
                        val = RoundToIncrement(loadedVal, inc)
                        val = math.clamp(val, min, max)
                        local displayRatio = range > 0 and (val - min) / range or 0
                        SValue.Text = FormatNumber(val, inc)
                        Tween(SlideFill, {Size = UDim2.new(displayRatio, 0, 1, 0)}, 0.05)
                        Library.Unsaved = true
                        cb(val)
                    end
                    task.spawn(cb, val)
                end
                function ToggleObj:AddDropdown(txt, dflag, opts, def, cb, isMulti)
                    CreateDropdownElement(txt, dflag, opts, def, nil, cb, Content, Section, isMulti, SubContainer)
                end
                function ToggleObj:Keybind(defaultKey, mode)
                    if not hasSavedBind and defaultKey then
                        bindKey = defaultKey
                        ToggleObj.KeybindValue = bindKey
                        Library.Flags[keyFlag] = {Key = bindKey, Mode = bindMode}
                    end
                    if mode and not hasSavedBind then
                        SetBindMode(mode)
                    else
                        PushBind()
                    end
                    return ToggleObj
                end
                return ToggleObj
            end
            function Section:Keybind(text, flag, defaultKey, mode, tooltipText, callback)
                local defObj = Library.Flags[flag]
                local key = defObj and defObj.Key or (defaultKey or Enum.KeyCode.Unknown)
                local kMode = defObj and defObj.Mode or (mode or "Toggle")
                Library.Defaults[flag] = {Key = defaultKey or Enum.KeyCode.Unknown, Mode = mode or "Toggle"}
                Library.Flags[flag] = {Key = key, Mode = kMode}
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 30)
                Frame.BackgroundTransparency = 1
                Frame.Parent = Content
                local Label = Instance.new("TextLabel")
                Label.Text = text
                Label.Font = Config.FontMain
                Label.TextSize = 13
                Label.TextColor3 = Theme.Text
                Label.Size = UDim2.new(0.6, 0, 1, 0)
                Label.Position = UDim2.new(0, 5, 0, 0)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = Frame
                local KeyBtn = Instance.new("TextButton")
                KeyBtn.Size = UDim2.new(0, 80, 0, 20)
                KeyBtn.Position = UDim2.new(1, -5, 0.5, 0)
                KeyBtn.AnchorPoint = Vector2.new(1, 0.5)
                KeyBtn.BackgroundColor3 = Theme.Container
                KeyBtn.Text = "[" .. key.Name .. "]"
                KeyBtn.Font = Config.FontMain
                KeyBtn.TextSize = 12
                KeyBtn.TextColor3 = Theme.TextDark
                KeyBtn.AutoButtonColor = false
                KeyBtn.Parent = Frame
                Corner(KeyBtn, 4)
                Stroke(KeyBtn, Theme.Stroke, 1, 0.5)
                local toggled = (kMode == "Always")
                local PushKeybindEntry
                PushKeybindEntry = function()
                    Library:RegisterBind(text, {
                        Key = key.Name,
                        Mode = kMode,
                        Active = toggled,
                        Pinned = true,
                        Toggle = function()
                            toggled = not toggled
                            PushKeybindEntry()
                            callback(toggled)
                        end,
                    })
                end
                PushKeybindEntry()
                local binding = false
                local c1 = KeyBtn.MouseButton1Click:Connect(function()
                    if binding then return end
                    binding = true
                    KeyBtn.Text = "[...]"
                    KeyBtn.TextColor3 = Theme.Accent
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
                                key = Enum.KeyCode.Unknown
                            elseif input.KeyCode ~= Enum.KeyCode.Escape and input.KeyCode ~= Enum.KeyCode.Unknown then
                                key = input.KeyCode
                            end
                            KeyBtn.Text = "[" .. key.Name .. "]"
                            KeyBtn.TextColor3 = Theme.TextDark
                            Library.Flags[flag] = {Key = key, Mode = kMode}
                            binding = false
                            Library.Unsaved = true
                            conn:Disconnect()
                            PushKeybindEntry()
                        end
                    end)
                end)
                table.insert(Library.Connections, c1)
                local ModeGui = Instance.new("Frame")
                ModeGui.Size = UDim2.new(0, 80, 0, 60)
                ModeGui.Position = UDim2.new(1, -90, 0, 25)
                ModeGui.BackgroundColor3 = Theme.Sidebar
                ModeGui.Visible = false
                ModeGui.ZIndex = 100
                ModeGui.Parent = Frame
                Corner(ModeGui, 4)
                Stroke(ModeGui, Theme.Stroke, 1)
                local ModeList = Instance.new("UIListLayout")
                ModeList.Parent = ModeGui
                local modes = {"Toggle", "Hold", "Always"}
                for _, md in ipairs(modes) do
                    local mBtn = Instance.new("TextButton")
                    mBtn.Size = UDim2.new(1, 0, 0, 20)
                    mBtn.BackgroundTransparency = 1
                    mBtn.Text = md
                    mBtn.TextColor3 = Theme.TextDark
                    mBtn.Font = Config.FontMain
                    mBtn.TextSize = 11
                    mBtn.Parent = ModeGui
                    mBtn.ZIndex = 101
                    local c2 = mBtn.MouseButton1Click:Connect(function()
                        kMode = md
                        Library.Flags[flag] = {Key = key, Mode = kMode}
                        ModeGui.Visible = false
                        Library.Unsaved = true
                        if kMode == "Always" then
                            toggled = true
                            callback(true)
                        end
                        PushKeybindEntry()
                    end)
                    table.insert(Library.Connections, c2)
                end
                local c3 = KeyBtn.MouseButton2Click:Connect(function()
                    ModeGui.Visible = not ModeGui.Visible
                    if ModeGui.Visible then Content.ClipsDescendants = false end
                end)
                table.insert(Library.Connections, c3)
                local BindConnection = UserInputService.InputBegan:Connect(function(input, gp)
                    if not gp and input.KeyCode == key and key ~= Enum.KeyCode.Unknown then
                        if kMode == "Toggle" then
                            toggled = not toggled
                            PushKeybindEntry()
                            callback(toggled)
                        elseif kMode == "Hold" then
                            toggled = true
                            PushKeybindEntry()
                            callback(toggled)
                        end
                    end
                end)
                local BindConnectionEnded = UserInputService.InputEnded:Connect(function(input, gp)
                    if not gp and input.KeyCode == key and key ~= Enum.KeyCode.Unknown then
                        if kMode == "Hold" then
                            toggled = false
                            PushKeybindEntry()
                            callback(toggled)
                        end
                    end
                end)
                table.insert(Library.Connections, BindConnection)
                table.insert(Library.Connections, BindConnectionEnded)
                ApplyTooltip(Frame, tooltipText)
                Library.Signals[flag] = function(val)
                    if type(val) == "table" and val.Key then
                        key = val.Key
                        kMode = val.Mode or "Toggle"
                        KeyBtn.Text = "[" .. key.Name .. "]"
                        if kMode == "Always" then
                            toggled = true
                            callback(true)
                        end
                        PushKeybindEntry()
                    end
                end
                local BindObj = {}
                function BindObj:SetKey(newKey)
                    key = newKey
                    KeyBtn.Text = "[" .. key.Name .. "]"
                    Library.Flags[flag] = {Key = key, Mode = kMode}
                    Library.Unsaved = true
                    PushKeybindEntry()
                end
                return BindObj
            end
            function Section:Button(text, tooltipText, callback)
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 30)
                Btn.BackgroundColor3 = Theme.Container
                Btn.Text = text
                Btn.Font = Config.FontMain
                Btn.TextSize = 13
                Btn.TextColor3 = Theme.Text
                Btn.AutoButtonColor = false
                Btn.Parent = Content
                table.insert(secData.Items, {Name = text, Instance = Btn})
                Corner(Btn, 4)
                local s = Stroke(Btn, Theme.Stroke, 1, 0.5)
                local c1 = Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Theme.Stroke}) Tween(s, {Color = Theme.Accent}) end)
                local c2 = Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Theme.Container}) Tween(s, {Color = Theme.Stroke}) end)
                local c3 = Btn.MouseButton1Click:Connect(WrapCallback(text, callback, false))
                table.insert(Library.Connections, c1)
                table.insert(Library.Connections, c2)
                table.insert(Library.Connections, c3)
                ApplyTooltip(Btn, tooltipText)
            end
            function Section:Slider(text, flag, min, max, default, increment, tooltipText, callback)
                CreateSliderElement(text, flag, min, max, default, increment, tooltipText, callback, Content, secData)
            end
            function Section:TextBox(text, flag, placeholder, tooltipText, callback)
                Library.Defaults[flag] = ""
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 46)
                Frame.BackgroundTransparency = 1
                Frame.Parent = Content
                table.insert(secData.Items, {Name = text, Instance = Frame})
                local Label = Instance.new("TextLabel")
                Label.Text = text
                Label.Font = Config.FontMain
                Label.TextSize = 13
                Label.TextColor3 = Theme.Text
                Label.Size = UDim2.new(1, 0, 0, 16)
                Label.Position = UDim2.new(0, 5, 0, 0)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = Frame
                local BoxCont = Instance.new("Frame")
                BoxCont.Size = UDim2.new(1, 0, 0, 26)
                BoxCont.Position = UDim2.new(0, 0, 0, 20)
                BoxCont.BackgroundColor3 = Theme.Container
                BoxCont.Parent = Frame
                Corner(BoxCont, 4)
                local s = Stroke(BoxCont, Theme.Stroke, 1, 0.5)
                local Input = Instance.new("TextBox")
                Input.Size = UDim2.new(1, -10, 1, 0)
                Input.Position = UDim2.new(0, 5, 0, 0)
                Input.BackgroundTransparency = 1
                Input.TextColor3 = Theme.Text
                Input.PlaceholderText = placeholder or "Type here..."
                Input.PlaceholderColor3 = Theme.TextDark
                Input.Font = Config.FontMain
                Input.TextSize = 13
                Input.TextXAlignment = Enum.TextXAlignment.Left
                local currentText = Library.Flags[flag] or ""
                Input.Text = currentText
                Input.ClearTextOnFocus = false
                Input.Parent = BoxCont
                local c1 = Input.Focused:Connect(function() Tween(s, {Color = Theme.Accent}) end)
                local c2 = Input.FocusLost:Connect(function(enter)
                    Tween(s, {Color = Theme.Stroke})
                    if enter then
                        Library.Flags[flag] = Input.Text
                        Library.Unsaved = true
                        callback(Input.Text)
                    end
                end)
                table.insert(Library.Connections, c1)
                table.insert(Library.Connections, c2)
                Library.Flags[flag] = currentText
                Library.Signals[flag] = function(val)
                    Input.Text = val
                    Library.Unsaved = true
                    callback(val)
                end
                ApplyTooltip(Frame, tooltipText)
                task.spawn(callback, currentText)
            end
            function Section:Dropdown(text, flag, options, default, tooltipText, callback, customParent, isMulti)
                local obj = CreateDropdownElement(text, flag, options, default, tooltipText, callback, Content, Section, isMulti, customParent)
                if not customParent then table.insert(secData.Items, {Name = text, Instance = obj.Frame}) end
                return obj
            end
            function Section:ColorPicker(text, flag, default, tooltipText, callback)
                local color = Library.Flags[flag] or default or Color3.fromRGB(255, 255, 255)
                Library.Defaults[flag] = default or Color3.fromRGB(255, 255, 255)
                Library.Flags[flag] = color
                local h, s, v = color:ToHSV()
                local isOpen = false
                local ContainerFrame = Instance.new("Frame")
                ContainerFrame.Size = UDim2.new(1, 0, 0, 30)
                ContainerFrame.BackgroundTransparency = 1
                ContainerFrame.Parent = Content
                table.insert(secData.Items, {Name = text, Instance = ContainerFrame})
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 30)
                Frame.BackgroundTransparency = 1
                Frame.Parent = ContainerFrame
                Frame.ZIndex = 5
                local Label = Instance.new("TextLabel")
                Label.Text = text
                Label.Font = Config.FontMain
                Label.TextSize = 13
                Label.TextColor3 = Theme.Text
                Label.Size = UDim2.new(0.6, 0, 1, 0)
                Label.Position = UDim2.new(0, 5, 0, 0)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = Frame
                local Preview = Instance.new("TextButton")
                Preview.Size = UDim2.new(0, 40, 0, 20)
                Preview.Position = UDim2.new(1, -5, 0.5, 0)
                Preview.AnchorPoint = Vector2.new(1, 0.5)
                Preview.BackgroundColor3 = color
                Preview.AutoButtonColor = false
                Preview.Text = ""
                Preview.Parent = Frame
                Corner(Preview, 4)
                Stroke(Preview, Theme.Stroke, 1, 0.5)
                local PickerCont = Instance.new("Frame")
                PickerCont.Size = UDim2.new(1, 0, 0, 0)
                PickerCont.Position = UDim2.new(0, 0, 0, 30)
                PickerCont.BackgroundColor3 = Theme.Background
                PickerCont.Parent = ContainerFrame
                PickerCont.ClipsDescendants = true
                PickerCont.Visible = false
                PickerCont.ZIndex = 10
                Corner(PickerCont, 4)
                local SVMap = Instance.new("ImageLabel")
                SVMap.Size = UDim2.new(0, 140, 0, 120)
                SVMap.Position = UDim2.new(0, 10, 0, 10)
                SVMap.Image = "rbxassetid://4155801252"
                SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                SVMap.Parent = PickerCont
                SVMap.ZIndex = 11
                Corner(SVMap, 4)
                local SVCursor = Instance.new("Frame")
                SVCursor.Size = UDim2.new(0, 8, 0, 8)
                SVCursor.AnchorPoint = Vector2.new(0.5, 0.5)
                SVCursor.BackgroundColor3 = Color3.new(1, 1, 1)
                SVCursor.Parent = SVMap
                SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                SVCursor.ZIndex = 12
                Corner(SVCursor, 4)
                local HueBar = Instance.new("ImageLabel")
                HueBar.Size = UDim2.new(0, 20, 0, 120)
                HueBar.Position = UDim2.new(0, 160, 0, 10)
                HueBar.Image = "rbxassetid://4155801252"
                HueBar.Parent = PickerCont
                HueBar.ZIndex = 11
                Corner(HueBar, 4)
                local UIGradient = Instance.new("UIGradient")
                UIGradient.Rotation = 90
                UIGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                })
                UIGradient.Parent = HueBar
                local HCursor = Instance.new("Frame")
                HCursor.Size = UDim2.new(1, 0, 0, 2)
                HCursor.BackgroundColor3 = Color3.new(1, 1, 1)
                HCursor.Parent = HueBar
                HCursor.Position = UDim2.new(0, 0, h, 0)
                HCursor.ZIndex = 12
                local HexInput = Instance.new("TextBox")
                HexInput.Size = UDim2.new(0, 170, 0, 20)
                HexInput.Position = UDim2.new(0, 10, 0, 140)
                HexInput.BackgroundColor3 = Theme.Container
                HexInput.TextColor3 = Theme.Text
                HexInput.Font = Config.FontMain
                HexInput.TextSize = 12
                HexInput.Text = "#" .. color:ToHex()
                HexInput.Parent = PickerCont
                HexInput.ZIndex = 11
                Corner(HexInput, 4)
                Stroke(HexInput, Theme.Stroke, 1)
                local function Update()
                    color = Color3.fromHSV(h, s, v)
                    Preview.BackgroundColor3 = color
                    SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    HexInput.Text = "#" .. color:ToHex()
                    Library.Flags[flag] = color
                    Library.Unsaved = true
                    callback(color)
                end
                local hc1 = HexInput.FocusLost:Connect(function()
                    local t = HexInput.Text:gsub("#", "")
                    if t:match("^[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]$") then
                        pcall(function()
                            local nc = Color3.fromHex(t)
                            h, s, v = nc:ToHSV()
                            HCursor.Position = UDim2.new(0, 0, h, 0)
                            SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                            Update()
                        end)
                    else
                        HexInput.Text = "#" .. color:ToHex()
                    end
                end)
                table.insert(Library.Connections, hc1)
                Library.Signals[flag] = function(val)
                    if typeof(val) == "Color3" then
                        color = val
                        h, s, v = color:ToHSV()
                        HCursor.Position = UDim2.new(0, 0, h, 0)
                        SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                        Update()
                    end
                end
                local function SetSV(input)
                    local rX = math.clamp((input.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1)
                    local rY = math.clamp((input.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1)
                    s = rX
                    v = 1 - rY
                    SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                    Update()
                end
                local function SetH(input)
                    local rY = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                    h = rY
                    HCursor.Position = UDim2.new(0, 0, h, 0)
                    Update()
                end
                local sv1 = SVMap.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        SetSV(input)
                        BeginDrag(input, SetSV)
                    end
                end)
                table.insert(Library.Connections, sv1)
                local h1 = HueBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        SetH(input)
                        BeginDrag(input, SetH)
                    end
                end)
                table.insert(Library.Connections, h1)
                local pc1 = Preview.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    Section.Container.ZIndex = isOpen and 10 or 1
                    ContainerFrame.ZIndex = isOpen and 10 or 5
                    if isOpen then
                        PickerCont.Visible = true
                        Tween(ContainerFrame, {Size = UDim2.new(1, 0, 0, 200)}, 0.2)
                        Tween(PickerCont, {Size = UDim2.new(1, 0, 0, 170)}, 0.2)
                    else
                        Tween(ContainerFrame, {Size = UDim2.new(1, 0, 0, 30)}, 0.2)
                        local t = Tween(PickerCont, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        local pc2
                        pc2 = t.Completed:Connect(function()
                            if not isOpen then PickerCont.Visible = false end
                            pc2:Disconnect()
                        end)
                    end
                end)
                table.insert(Library.Connections, pc1)
                ApplyTooltip(ContainerFrame, tooltipText)
                task.spawn(callback, color)
            end
            function Section:SkinBrowser(config)
                config = config or {}
                local weapons = config.weapons or {}
                local getSkins = config.getSkins or function() return {} end
                local onEquip = config.onEquip or function() end
                local onRestore = config.onRestore or function() end
                local getModel = config.getModel or function() return nil end
                local subTabs = config.subTabs or {"Skins", "Wraps", "Charms", "Finishers"}
                local tabsCfg = config.tabs or {}
                local BrowserObj = {}
                local selectedWeapon = nil
                local selectedSkin = nil
                local activeTab = subTabs[1] or "Skins"
                local tabCount = #subTabs

                local TabScroll = Page
                local BrowserFrame = Instance.new("Frame")
                BrowserFrame.Size = UDim2.new(1, 0, 0, 500)
                BrowserFrame.BackgroundColor3 = Theme.Container
                BrowserFrame.ClipsDescendants = true
                BrowserFrame.Parent = Content
                table.insert(secData.Items, {Name = "SkinBrowser", Instance = BrowserFrame})
                Corner(BrowserFrame, 6)
                Stroke(BrowserFrame, Theme.Stroke, 1, 0.5)

                -- Sub-tab bar: equal width buttons spanning full width
                local NavBar = Instance.new("Frame")
                NavBar.Size = UDim2.new(1, -16, 0, 36)
                NavBar.Position = UDim2.new(0, 8, 0, 8)
                NavBar.BackgroundColor3 = Theme.Background
                NavBar.BorderSizePixel = 0
                NavBar.Visible = tabCount > 1
                NavBar.Parent = BrowserFrame
                Corner(NavBar, 6)
                local NavLayout = Instance.new("UIListLayout")
                NavLayout.FillDirection = Enum.FillDirection.Horizontal
                NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                NavLayout.Padding = UDim.new(0, 4)
                NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
                NavLayout.Parent = NavBar
                local NavPad = Instance.new("UIPadding")
                NavPad.PaddingLeft = UDim.new(0, 4)
                NavPad.PaddingRight = UDim.new(0, 4)
                NavPad.PaddingTop = UDim.new(0, 4)
                NavPad.PaddingBottom = UDim.new(0, 4)
                NavPad.Parent = NavBar

                local navBtns = {}
                local btnWidth = math.floor((1 / math.max(tabCount, 1)) * 100) / 100
                for idx, tabName in ipairs(subTabs) do
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(btnWidth, -4, 1, 0)
                    btn.BackgroundColor3 = (tabName == activeTab) and Theme.Accent or Theme.Section
                    btn.Text = tabName
                    btn.TextColor3 = Theme.Text
                    btn.TextSize = 13
                    btn.Font = Config.FontBold
                    btn.AutoButtonColor = false
                    btn.LayoutOrder = idx
                    btn.Parent = NavBar
                    Corner(btn, 5)
                    navBtns[tabName] = btn
                end

                -- Content area
                local ContentArea = Instance.new("Frame")
                if tabCount > 1 then
                    ContentArea.Size = UDim2.new(1, -16, 1, -54)
                    ContentArea.Position = UDim2.new(0, 8, 0, 48)
                else
                    ContentArea.Size = UDim2.new(1, -16, 1, -16)
                    ContentArea.Position = UDim2.new(0, 8, 0, 8)
                end
                ContentArea.BackgroundTransparency = 1
                ContentArea.Parent = BrowserFrame

                -- === SKINS PAGE ===
                local SkinsPage = Instance.new("Frame")
                SkinsPage.Size = UDim2.new(1, 0, 1, 0)
                SkinsPage.BackgroundTransparency = 1
                SkinsPage.Visible = true
                SkinsPage.Parent = ContentArea

                -- Left panel (40%)
                local LeftPanel = Instance.new("Frame")
                LeftPanel.Size = UDim2.new(0.4, -4, 1, 0)
                LeftPanel.Position = UDim2.new(0, 0, 0, 0)
                LeftPanel.BackgroundColor3 = Theme.Section
                LeftPanel.Parent = SkinsPage
                Corner(LeftPanel, 6)
                Stroke(LeftPanel, Theme.Stroke, 1, 0.5)

                local LeftLayout = Instance.new("UIListLayout")
                LeftLayout.Padding = UDim.new(0, 4)
                LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
                LeftLayout.Parent = LeftPanel
                local LeftPad = Instance.new("UIPadding")
                LeftPad.PaddingLeft = UDim.new(0, 8)
                LeftPad.PaddingRight = UDim.new(0, 8)
                LeftPad.PaddingTop = UDim.new(0, 8)
                LeftPad.PaddingBottom = UDim.new(0, 8)
                LeftPad.Parent = LeftPanel

                -- WEAPON header
                local WepHeader = Instance.new("TextLabel")
                WepHeader.Size = UDim2.new(1, 0, 0, 16)
                WepHeader.BackgroundTransparency = 1
                WepHeader.Text = "WEAPON"
                WepHeader.TextColor3 = Theme.TextDark
                WepHeader.TextSize = 12
                WepHeader.Font = Config.FontBold
                WepHeader.TextXAlignment = Enum.TextXAlignment.Left
                WepHeader.LayoutOrder = 1
                WepHeader.Parent = LeftPanel

                -- Weapon list
                local WepScroll = Instance.new("ScrollingFrame")
                WepScroll.Size = UDim2.new(1, 0, 0, 138)
                WepScroll.BackgroundColor3 = Theme.Background
                WepScroll.BorderSizePixel = 0
                WepScroll.ScrollBarThickness = 3
                WepScroll.ScrollBarImageColor3 = Theme.Accent
                WepScroll.LayoutOrder = 3
                WepScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                WepScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                WepScroll.Parent = LeftPanel
                Corner(WepScroll, 5)
                RegisterTheme(WepScroll, "ScrollBar")
                local WepList = Instance.new("UIListLayout")
                WepList.Padding = UDim.new(0, 2)
                WepList.SortOrder = Enum.SortOrder.LayoutOrder
                WepList.Parent = WepScroll
                local WepScrollPad = Instance.new("UIPadding")
                WepScrollPad.PaddingLeft = UDim.new(0, 4)
                WepScrollPad.PaddingRight = UDim.new(0, 4)
                WepScrollPad.PaddingTop = UDim.new(0, 4)
                WepScrollPad.Parent = WepScroll

                local weaponButtons = {}
                local wepQuery = ""
                local function HighlightWeapon(name)
                    for n, b in pairs(weaponButtons) do
                        b.BackgroundColor3 = (n == name) and Theme.Accent or Theme.Section
                    end
                end
                CreateListSearch(LeftPanel, "Search weapon...", 2, function(q)
                    wepQuery = q
                    FilterButtons(weaponButtons, q)
                end)

                -- SKIN header
                local SkinHeader = Instance.new("TextLabel")
                SkinHeader.Size = UDim2.new(1, 0, 0, 16)
                SkinHeader.BackgroundTransparency = 1
                SkinHeader.Text = "SKIN"
                SkinHeader.TextColor3 = Theme.TextDark
                SkinHeader.TextSize = 12
                SkinHeader.Font = Config.FontBold
                SkinHeader.TextXAlignment = Enum.TextXAlignment.Left
                SkinHeader.LayoutOrder = 4
                SkinHeader.Parent = LeftPanel

                -- Skin list
                local SkinScroll = Instance.new("ScrollingFrame")
                SkinScroll.Size = UDim2.new(1, 0, 0, 118)
                SkinScroll.BackgroundColor3 = Theme.Background
                SkinScroll.BorderSizePixel = 0
                SkinScroll.ScrollBarThickness = 3
                SkinScroll.ScrollBarImageColor3 = Theme.Accent
                SkinScroll.LayoutOrder = 6
                SkinScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                SkinScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                SkinScroll.Parent = LeftPanel
                Corner(SkinScroll, 5)
                RegisterTheme(SkinScroll, "ScrollBar")
                local SkinListLayout = Instance.new("UIListLayout")
                SkinListLayout.Padding = UDim.new(0, 2)
                SkinListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                SkinListLayout.Parent = SkinScroll
                local SkinScrollPad = Instance.new("UIPadding")
                SkinScrollPad.PaddingLeft = UDim.new(0, 4)
                SkinScrollPad.PaddingRight = UDim.new(0, 4)
                SkinScrollPad.PaddingTop = UDim.new(0, 4)
                SkinScrollPad.Parent = SkinScroll

                local skinButtons = {}
                local skinQuery = ""
                local function HighlightSkin(name)
                    for n, b in pairs(skinButtons) do
                        b.BackgroundColor3 = (n == name) and Theme.Accent or Theme.Section
                    end
                end
                CreateListSearch(LeftPanel, "Search skin...", 5, function(q)
                    skinQuery = q
                    FilterButtons(skinButtons, q)
                end)

                -- EQUIP / RESTORE buttons
                local ActFrame = Instance.new("Frame")
                ActFrame.Size = UDim2.new(1, 0, 0, 32)
                ActFrame.BackgroundTransparency = 1
                ActFrame.LayoutOrder = 7
                ActFrame.Parent = LeftPanel

                local EquipBtnL = Instance.new("TextButton")
                EquipBtnL.Size = UDim2.new(0.5, -3, 1, 0)
                EquipBtnL.Position = UDim2.new(0, 0, 0, 0)
                EquipBtnL.BackgroundColor3 = Theme.Accent
                EquipBtnL.Text = "EQUIP"
                EquipBtnL.TextColor3 = Theme.Text
                EquipBtnL.TextSize = 13
                EquipBtnL.Font = Config.FontBold
                EquipBtnL.AutoButtonColor = false
                EquipBtnL.Parent = ActFrame
                Corner(EquipBtnL, 5)
                RegisterTheme(EquipBtnL, "BackgroundColor")

                local RestoreBtn = Instance.new("TextButton")
                RestoreBtn.Size = UDim2.new(0.5, -3, 1, 0)
                RestoreBtn.Position = UDim2.new(0.5, 3, 0, 0)
                RestoreBtn.BackgroundColor3 = Theme.Section
                RestoreBtn.Text = "RESTORE"
                RestoreBtn.TextColor3 = Theme.TextDark
                RestoreBtn.TextSize = 13
                RestoreBtn.Font = Config.FontBold
                RestoreBtn.AutoButtonColor = false
                RestoreBtn.Parent = ActFrame
                Corner(RestoreBtn, 5)
                Stroke(RestoreBtn, Theme.Stroke, 1, 0.5)

                -- Right panel (60%) — 3D Preview
                local RightPanel = Instance.new("Frame")
                RightPanel.Size = UDim2.new(0.6, -4, 1, 0)
                RightPanel.Position = UDim2.new(0.4, 4, 0, 0)
                RightPanel.BackgroundColor3 = Theme.Section
                RightPanel.Parent = SkinsPage
                Corner(RightPanel, 6)
                Stroke(RightPanel, Theme.Stroke, 1, 0.5)

                -- Viewport
                local VPFrame = Instance.new("ViewportFrame")
                VPFrame.Size = UDim2.new(1, -16, 1, -56)
                VPFrame.Position = UDim2.new(0, 8, 0, 8)
                VPFrame.BackgroundColor3 = Theme.Background
                VPFrame.BorderSizePixel = 0
                VPFrame.Parent = RightPanel
                Corner(VPFrame, 6)

                local VPCam = Instance.new("Camera")
                VPCam.FieldOfView = 50
                VPCam.Parent = VPFrame
                VPFrame.CurrentCamera = VPCam

                local WorldMdl = Instance.new("WorldModel")
                WorldMdl.Parent = VPFrame
                local SkinCtrl = CreatePreviewController(VPFrame, VPCam)
                SkinCtrl.ScrollFrame = TabScroll

                local LightPart = Instance.new("Part")
                LightPart.Transparency = 1
                LightPart.Anchored = true
                LightPart.CanCollide = false
                LightPart.Size = Vector3.new(0.1, 0.1, 0.1)
                LightPart.Position = Vector3.new(4, 4, 4)
                LightPart.Parent = WorldMdl
                local PLight = Instance.new("PointLight")
                PLight.Brightness = 2.5
                PLight.Range = 40
                PLight.Parent = LightPart

                local LightPart2 = Instance.new("Part")
                LightPart2.Transparency = 1
                LightPart2.Anchored = true
                LightPart2.CanCollide = false
                LightPart2.Size = Vector3.new(0.1, 0.1, 0.1)
                LightPart2.Position = Vector3.new(-3, 2, -3)
                LightPart2.Parent = WorldMdl
                local PLight2 = Instance.new("PointLight")
                PLight2.Brightness = 1.5
                PLight2.Range = 30
                PLight2.Color = Color3.fromRGB(200, 150, 150)
                PLight2.Parent = LightPart2

                -- Skin name label
                local SkinNameLabel = Instance.new("TextLabel")
                SkinNameLabel.Size = UDim2.new(1, -16, 0, 20)
                SkinNameLabel.Position = UDim2.new(0, 8, 1, -44)
                SkinNameLabel.BackgroundTransparency = 1
                SkinNameLabel.Text = "Select a skin"
                SkinNameLabel.TextColor3 = Theme.TextDark
                SkinNameLabel.TextSize = 13
                SkinNameLabel.Font = Config.FontMain
                SkinNameLabel.TextXAlignment = Enum.TextXAlignment.Center
                SkinNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
                SkinNameLabel.Parent = RightPanel

                -- Equip button in preview
                local EquipBtnR = Instance.new("TextButton")
                EquipBtnR.Size = UDim2.new(1, -16, 0, 28)
                EquipBtnR.Position = UDim2.new(0, 8, 1, -28)
                EquipBtnR.BackgroundColor3 = Theme.Accent
                EquipBtnR.Text = "EQUIP SKIN"
                EquipBtnR.TextColor3 = Theme.Text
                EquipBtnR.TextSize = 13
                EquipBtnR.Font = Config.FontBold
                EquipBtnR.AutoButtonColor = false
                EquipBtnR.Parent = RightPanel
                Corner(EquipBtnR, 5)
                RegisterTheme(EquipBtnR, "BackgroundColor")

                -- === GENERIC COSMETIC PAGES (Wraps / Charms / ...) ===
                local cosmeticPages = {}  -- tabName -> {Frame, SetWeapons, GetSelected}

                local function BuildCosmeticPage(pTabName, tabCfg)
                    tabCfg = tabCfg or {}
                    local pWeapons = tabCfg.weapons or {}
                    local pGetItems = tabCfg.getItems or function() return {} end
                    local pGetModel = tabCfg.getModel or function() return nil end
                    local pOnEquip = tabCfg.onEquip or function() end
                    local pOnRestore = tabCfg.onRestore or function() end
                    local pItemHeader = tabCfg.itemHeader or "ITEM"
                    local pEquipText = tabCfg.equipText or "EQUIP"
                    local pHasInverted = tabCfg.invertedToggle and true or false
                    local pNoWeapons = tabCfg.noWeapons and true or false
                    local pGetImage = tabCfg.getImage
                    local pOnSelect = tabCfg.onSelect
                    local pNoPreview = tabCfg.noPreview and true or false
                    local pSelWeapon, pSelItem, pInverted = nil, nil, false

                    local Page = Instance.new("Frame")
                    Page.Size = UDim2.new(1, 0, 1, 0)
                    Page.BackgroundTransparency = 1
                    Page.Visible = false
                    Page.Parent = ContentArea

                    local LPan = Instance.new("Frame")
                    LPan.Size = UDim2.new(0.4, -4, 1, 0)
                    LPan.BackgroundColor3 = Theme.Section
                    LPan.Parent = Page
                    Corner(LPan, 6)
                    Stroke(LPan, Theme.Stroke, 1, 0.5)
                    local LPanList = Instance.new("UIListLayout")
                    LPanList.Padding = UDim.new(0, 4)
                    LPanList.SortOrder = Enum.SortOrder.LayoutOrder
                    LPanList.Parent = LPan
                    local LPanPad = Instance.new("UIPadding")
                    LPanPad.PaddingLeft = UDim.new(0, 8)
                    LPanPad.PaddingRight = UDim.new(0, 8)
                    LPanPad.PaddingTop = UDim.new(0, 8)
                    LPanPad.PaddingBottom = UDim.new(0, 8)
                    LPanPad.Parent = LPan

                    local function mkHeader(txt, order)
                        local h = Instance.new("TextLabel")
                        h.Size = UDim2.new(1, 0, 0, 16)
                        h.BackgroundTransparency = 1
                        h.Text = txt
                        h.TextColor3 = Theme.TextDark
                        h.TextSize = 12
                        h.Font = Config.FontBold
                        h.TextXAlignment = Enum.TextXAlignment.Left
                        h.LayoutOrder = order
                        h.Parent = LPan
                    end
                    local function mkScroll(order, height)
                        local s = Instance.new("ScrollingFrame")
                        s.Size = UDim2.new(1, 0, 0, height)
                        s.BackgroundColor3 = Theme.Background
                        s.BorderSizePixel = 0
                        s.ScrollBarThickness = 3
                        s.ScrollBarImageColor3 = Theme.Accent
                        s.LayoutOrder = order
                        s.CanvasSize = UDim2.new(0, 0, 0, 0)
                        s.AutomaticCanvasSize = Enum.AutomaticSize.Y
                        s.Parent = LPan
                        Corner(s, 5)
                        RegisterTheme(s, "ScrollBar")
                        local l = Instance.new("UIListLayout")
                        l.Padding = UDim.new(0, 2)
                        l.SortOrder = Enum.SortOrder.LayoutOrder
                        l.Parent = s
                        local pd = Instance.new("UIPadding")
                        pd.PaddingLeft = UDim.new(0, 4)
                        pd.PaddingRight = UDim.new(0, 4)
                        pd.PaddingTop = UDim.new(0, 4)
                        pd.Parent = s
                        return s
                    end

                    local WScroll
                    if not pNoWeapons then
                        mkHeader("WEAPON", 1)
                        WScroll = mkScroll(3, 128)
                    end
                    mkHeader(pItemHeader, 4)
                    local IScroll = mkScroll(6, pNoWeapons and 278 or (pHasInverted and 96 or 118))

                    if pHasInverted then
                        local tf = Instance.new("TextButton")
                        tf.Size = UDim2.new(1, 0, 0, 24)
                        tf.BackgroundColor3 = Theme.Section
                        tf.Text = "Inverted: OFF"
                        tf.TextColor3 = Theme.Text
                        tf.TextSize = 12
                        tf.Font = Config.FontMain
                        tf.AutoButtonColor = false
                        tf.LayoutOrder = 7
                        tf.Parent = LPan
                        Corner(tf, 4)
                        Stroke(tf, Theme.Stroke, 1, 0.5)
                        local ic = tf.MouseButton1Click:Connect(function()
                            pInverted = not pInverted
                            tf.Text = "Inverted: " .. (pInverted and "ON" or "OFF")
                            tf.BackgroundColor3 = pInverted and Theme.Accent or Theme.Section
                        end)
                        table.insert(Library.Connections, ic)
                    end

                    local ActF = Instance.new("Frame")
                    ActF.Size = UDim2.new(1, 0, 0, 32)
                    ActF.BackgroundTransparency = 1
                    ActF.LayoutOrder = 8
                    ActF.Parent = LPan
                    local EqB = Instance.new("TextButton")
                    EqB.Size = UDim2.new(0.5, -3, 1, 0)
                    EqB.BackgroundColor3 = Theme.Accent
                    EqB.Text = pEquipText
                    EqB.TextColor3 = Theme.Text
                    EqB.TextSize = 13
                    EqB.Font = Config.FontBold
                    EqB.AutoButtonColor = false
                    EqB.Parent = ActF
                    Corner(EqB, 5)
                    RegisterTheme(EqB, "BackgroundColor")
                    local RmB = Instance.new("TextButton")
                    RmB.Size = UDim2.new(0.5, -3, 1, 0)
                    RmB.Position = UDim2.new(0.5, 3, 0, 0)
                    RmB.BackgroundColor3 = Theme.Section
                    RmB.Text = "REMOVE"
                    RmB.TextColor3 = Theme.TextDark
                    RmB.TextSize = 13
                    RmB.Font = Config.FontBold
                    RmB.AutoButtonColor = false
                    RmB.Parent = ActF
                    Corner(RmB, 5)
                    Stroke(RmB, Theme.Stroke, 1, 0.5)

                    local RPan = Instance.new("Frame")
                    RPan.Size = UDim2.new(0.6, -4, 1, 0)
                    RPan.Position = UDim2.new(0.4, 4, 0, 0)
                    RPan.BackgroundColor3 = Theme.Section
                    RPan.Parent = Page
                    Corner(RPan, 6)
                    Stroke(RPan, Theme.Stroke, 1, 0.5)
                    local VP = Instance.new("ViewportFrame")
                    VP.Size = UDim2.new(1, -16, 1, -56)
                    VP.Position = UDim2.new(0, 8, 0, 8)
                    VP.BackgroundColor3 = Theme.Background
                    VP.BorderSizePixel = 0
                    VP.Parent = RPan
                    Corner(VP, 6)
                    local Cam = Instance.new("Camera")
                    Cam.FieldOfView = 50
                    Cam.Parent = VP
                    VP.CurrentCamera = Cam
                    local WM = Instance.new("WorldModel")
                    WM.Parent = VP
                    local pCtrl = CreatePreviewController(VP, Cam)
                    pCtrl.ScrollFrame = TabScroll
                    local L1 = Instance.new("Part")
                    L1.Transparency = 1
                    L1.Anchored = true
                    L1.CanCollide = false
                    L1.Size = Vector3.new(0.1, 0.1, 0.1)
                    L1.Position = Vector3.new(4, 4, 4)
                    L1.Parent = WM
                    local PL1 = Instance.new("PointLight")
                    PL1.Brightness = 2.5
                    PL1.Range = 40
                    PL1.Parent = L1
                    local NameLbl = Instance.new("TextLabel")
                    NameLbl.Size = UDim2.new(1, -16, 0, 20)
                    NameLbl.Position = UDim2.new(0, 8, 1, -44)
                    NameLbl.BackgroundTransparency = 1
                    NameLbl.Text = "Select an item"
                    NameLbl.TextColor3 = Theme.TextDark
                    NameLbl.TextSize = 13
                    NameLbl.Font = Config.FontMain
                    NameLbl.TextXAlignment = Enum.TextXAlignment.Center
                    NameLbl.TextTruncate = Enum.TextTruncate.AtEnd
                    NameLbl.Parent = RPan
                    local EqR = Instance.new("TextButton")
                    EqR.Size = UDim2.new(1, -16, 0, 28)
                    EqR.Position = UDim2.new(0, 8, 1, -28)
                    EqR.BackgroundColor3 = Theme.Accent
                    EqR.Text = pEquipText
                    EqR.TextColor3 = Theme.Text
                    EqR.TextSize = 13
                    EqR.Font = Config.FontBold
                    EqR.AutoButtonColor = false
                    EqR.Parent = RPan
                    Corner(EqR, 5)
                    RegisterTheme(EqR, "BackgroundColor")

                    -- pages that preview on the player (emotes) use the right panel as a host
                    -- for extra controls instead of a viewport
                    local Host
                    if pNoPreview then
                        VP.Visible = false
                        Host = Instance.new("ScrollingFrame")
                        Host.Size = UDim2.new(1, -16, 1, -56)
                        Host.Position = UDim2.new(0, 8, 0, 8)
                        Host.BackgroundTransparency = 1
                        Host.BorderSizePixel = 0
                        Host.ScrollBarThickness = 3
                        Host.ScrollBarImageColor3 = Theme.Accent
                        Host.CanvasSize = UDim2.new(0, 0, 0, 0)
                        Host.AutomaticCanvasSize = Enum.AutomaticSize.Y
                        Host.Parent = RPan
                        RegisterTheme(Host, "ScrollBar")
                        local hl = Instance.new("UIListLayout")
                        hl.Padding = UDim.new(0, 6)
                        hl.SortOrder = Enum.SortOrder.LayoutOrder
                        hl.Parent = Host
                    end

                    local PrevImg
                    if pGetImage and not pNoPreview then
                        PrevImg = Instance.new("ImageLabel")
                        PrevImg.Size = UDim2.new(1, -32, 1, -72)
                        PrevImg.Position = UDim2.new(0, 16, 0, 16)
                        PrevImg.BackgroundTransparency = 1
                        PrevImg.ScaleType = Enum.ScaleType.Fit
                        PrevImg.Image = ""
                        PrevImg.Parent = RPan
                    end

                    local pPreviewModel = nil
                    local pAngle = 0
                    local function pClearPreview()
                        for _, c in ipairs(WM:GetChildren()) do
                            if c ~= L1 then pcall(function() c:Destroy() end) end
                        end
                        pPreviewModel = nil
                        pCtrl.Model = nil
                    end
                    local function pShowPreview(itemName)
                        pClearPreview()
                        NameLbl.Text = itemName or "Select an item"
                        if PrevImg then
                            local img = itemName and pGetImage(itemName) or nil
                            PrevImg.Image = img or ""
                            VP.Visible = not img
                            if img then return end
                        end
                        if not itemName then return end
                        if pNoPreview then return end
                        local model = pGetModel(itemName)
                        if not model then NameLbl.Text = itemName .. " (no preview)" return end
                        local ok, clone = pcall(function() return model:Clone() end)
                        if not ok or not clone then NameLbl.Text = "Load failed" return end
                        clone.Parent = WM
                        pPreviewModel = clone
                        local suc, cf, size = pcall(function() return clone:GetBoundingBox() end)
                        if not suc then
                            local ap = clone:FindFirstChildWhichIsA("BasePart", true)
                            if ap then cf = ap.CFrame size = ap.Size else cf = CFrame.new() size = Vector3.new(2, 2, 2) end
                        end
                        local maxDim = math.max(size.X, size.Y, size.Z, 1)
                        local dist = maxDim * 2.2
                        Cam.CFrame = CFrame.new(cf.Position + Vector3.new(0, size.Y * 0.2, dist), cf.Position)
                        pAngle = 0
                        pCtrl:Reset()
                        pCtrl.Model = clone
                        NameLbl.Text = itemName
                    end
                    local prc = RunService.RenderStepped:Connect(function(dt)
                        if pPreviewModel and Page.Visible then pCtrl:Step(dt) end
                    end)
                    table.insert(Library.Connections, prc)

                    local wButtons, iButtons = {}, {}
                    local pWepQuery, pItemQuery = "", ""
                    if WScroll then
                        CreateListSearch(LPan, "Search weapon...", 2, function(q)
                            pWepQuery = q
                            FilterButtons(wButtons, q)
                        end)
                    end
                    CreateListSearch(LPan, "Search " .. pItemHeader:lower() .. "...", 5, function(q)
                        pItemQuery = q
                        FilterButtons(iButtons, q)
                    end)
                    local function pHiWeapon(name)
                        for n, b in pairs(wButtons) do b.BackgroundColor3 = (n == name) and Theme.Accent or Theme.Section end
                    end
                    local function pHiItem(name)
                        for n, b in pairs(iButtons) do b.BackgroundColor3 = (n == name) and Theme.Accent or Theme.Section end
                    end
                    local function pBuildItems(wName)
                        for _, ch in ipairs(IScroll:GetChildren()) do
                            if ch:IsA("TextButton") then ch:Destroy() end
                        end
                        iButtons = {}
                        local items = pGetItems(wName)
                        for si, iName in ipairs(items) do
                            local ib = Instance.new("TextButton")
                            ib.Size = UDim2.new(1, 0, 0, 24)
                            ib.BackgroundColor3 = Theme.Section
                            ib.Text = iName
                            ib.TextColor3 = Theme.Text
                            ib.TextSize = 12
                            ib.Font = Config.FontMain
                            ib.TextXAlignment = Enum.TextXAlignment.Left
                            ib.AutoButtonColor = false
                            ib.LayoutOrder = si
                            ib.Parent = IScroll
                            Corner(ib, 4)
                            local ipd = Instance.new("UIPadding")
                            ipd.PaddingLeft = UDim.new(0, 8)
                            ipd.Parent = ib
                            iButtons[iName] = ib
                            local icc = ib.MouseButton1Click:Connect(function()
                                pSelItem = iName
                                pHiItem(iName)
                                pShowPreview(iName)
                                if pOnSelect then pcall(pOnSelect, pSelWeapon, iName) end
                            end)
                            table.insert(Library.Connections, icc)
                        end
                        FilterButtons(iButtons, pItemQuery)
                    end
                    local function pBuildWeapons()
                        if not WScroll then return end
                        for _, ch in ipairs(WScroll:GetChildren()) do
                            if ch:IsA("TextButton") then ch:Destroy() end
                        end
                        wButtons = {}
                        for i, wName in ipairs(pWeapons) do
                            local wb = Instance.new("TextButton")
                            wb.Size = UDim2.new(1, 0, 0, 26)
                            wb.BackgroundColor3 = Theme.Section
                            wb.Text = wName
                            wb.TextColor3 = Theme.Text
                            wb.TextSize = 13
                            wb.Font = Config.FontMain
                            wb.TextXAlignment = Enum.TextXAlignment.Left
                            wb.AutoButtonColor = false
                            wb.LayoutOrder = i
                            wb.Parent = WScroll
                            Corner(wb, 4)
                            local wpd = Instance.new("UIPadding")
                            wpd.PaddingLeft = UDim.new(0, 8)
                            wpd.Parent = wb
                            wButtons[wName] = wb
                            local wcc = wb.MouseButton1Click:Connect(function()
                                pSelWeapon = wName
                                pSelItem = nil
                                pHiWeapon(wName)
                                pBuildItems(wName)
                                pClearPreview()
                                NameLbl.Text = "Select an item"
                            end)
                            table.insert(Library.Connections, wcc)
                        end
                        FilterButtons(wButtons, pWepQuery)
                    end
                    pBuildWeapons()
                    if pNoWeapons then pBuildItems(nil) end

                    local function pDoEquip()
                        EqB.Text = "EQUIPPED"
                        EqR.Text = "EQUIPPED"
                        -- the callback may yield (game controllers preload assets); don't hold the button text on it
                        task.spawn(function() pcall(pOnEquip, pSelWeapon, pSelItem, pInverted) end)
                        task.delay(1.5, function()
                            pcall(function() EqB.Text = pEquipText EqR.Text = pEquipText end)
                        end)
                    end
                    local pe1 = EqB.MouseButton1Click:Connect(pDoEquip)
                    local pe2 = EqR.MouseButton1Click:Connect(pDoEquip)
                    local pr1 = RmB.MouseButton1Click:Connect(function()
                        pOnRestore()
                        RmB.Text = "REMOVED"
                        task.delay(1, function() pcall(function() RmB.Text = "REMOVE" end) end)
                    end)
                    table.insert(Library.Connections, pe1)
                    table.insert(Library.Connections, pe2)
                    table.insert(Library.Connections, pr1)

                    return {
                        Frame = Page,
                        ApplyHeight = function(contentH)
                            local invH = pHasInverted and 28 or 0
                            if pNoWeapons then
                                local space = contentH - (16 + 16 + 22 + 32 + 12 + invH)
                                IScroll.Size = UDim2.new(1, 0, 0, math.max(space, 120))
                            else
                                local space = math.max(contentH - (16 + 76 + 32 + 24 + invH), 160)
                                local wh = math.floor(space * 0.5)
                                WScroll.Size = UDim2.new(1, 0, 0, wh)
                                IScroll.Size = UDim2.new(1, 0, 0, space - wh)
                            end
                        end,
                        SetWeapons = function(_, nw) pWeapons = nw or {} pBuildWeapons() end,
                        GetSelected = function() return pSelWeapon, pSelItem, pInverted end,
                        -- weaponless pages have no weapon click to build their list, and the
                        -- items usually arrive after the menu is built, so refill on open
                        Refresh = function()
                            if pNoWeapons then pBuildItems(nil) end
                        end,
                        Host = Host,
                    }
                end

                for _, pName in ipairs(subTabs) do
                    if pName ~= "Skins" then
                        cosmeticPages[pName] = BuildCosmeticPage(pName, tabsCfg[pName])
                    end
                end

                -- the browser is the tallest element in the library: size it to the page so
                -- EQUIP is always on screen instead of forcing the user to resize the window
                local function ApplyBrowserHeight()
                    local sc = (Library._MainScale and Library._MainScale.Scale > 0) and Library._MainScale.Scale or 1
                    local avail = TabScroll.AbsoluteSize.Y
                    if avail < 1 then return end
                    local h = math.clamp(math.floor(avail / sc) - 40, 300, 760)
                    BrowserFrame.Size = UDim2.new(1, 0, 0, h)
                    local contentH = h - 54
                    local space = math.max(contentH - 148, 140)
                    local wh = math.floor(space * 0.52)
                    WepScroll.Size = UDim2.new(1, 0, 0, wh)
                    SkinScroll.Size = UDim2.new(1, 0, 0, space - wh)
                    for _, pg in pairs(cosmeticPages) do
                        if pg.ApplyHeight then pcall(pg.ApplyHeight, contentH) end
                    end
                end
                ApplyBrowserHeight()
                local abh = TabScroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(ApplyBrowserHeight)
                table.insert(Library.Connections, abh)
                task.defer(ApplyBrowserHeight)

                -- Navigation
                local function SwitchTab(tabName)
                    activeTab = tabName
                    for n, btn in pairs(navBtns) do
                        Tween(btn, {BackgroundColor3 = (n == tabName) and Theme.Accent or Theme.Section}, 0.15)
                    end
                    SkinsPage.Visible = (tabName == "Skins")
                    for n, pg in pairs(cosmeticPages) do
                        pg.Frame.Visible = (n == tabName)
                        if pg.Frame.Visible and pg.Refresh then pcall(pg.Refresh) end
                    end
                end
                for tName, btn in pairs(navBtns) do
                    local c = btn.MouseButton1Click:Connect(function() SwitchTab(tName) end)
                    table.insert(Library.Connections, c)
                end

                -- Preview
                local previewModel = nil
                local previewAngle = 0

                local function ClearPreview()
                    for _, c in ipairs(WorldMdl:GetChildren()) do
                        if c ~= LightPart and c ~= LightPart2 then
                            pcall(function() c:Destroy() end)
                        end
                    end
                    previewModel = nil
                    SkinCtrl.Model = nil
                end

                local function ShowPreview(skinName)
                    ClearPreview()
                    SkinNameLabel.Text = skinName or "Select a skin"
                    if not skinName then return end
                    local model = getModel(skinName)
                    if not model then
                        SkinNameLabel.Text = skinName .. " (no model)"
                        return
                    end
                    local ok, clone = pcall(function() return model:Clone() end)
                    if not ok or not clone then
                        SkinNameLabel.Text = "Load failed"
                        return
                    end
                    clone.Parent = WorldMdl
                    previewModel = clone
                    local success, cf, size = pcall(function() return clone:GetBoundingBox() end)
                    if not success then
                        local anyPart = clone:FindFirstChildWhichIsA("BasePart", true)
                        if anyPart then
                            cf = anyPart.CFrame
                            size = anyPart.Size
                        else
                            cf = CFrame.new(0, 0, 0)
                            size = Vector3.new(2, 2, 2)
                        end
                    end
                    local maxDim = math.max(size.X, size.Y, size.Z, 1)
                    local dist = maxDim * 2.2
                    VPCam.CFrame = CFrame.new(cf.Position + Vector3.new(0, size.Y * 0.2, dist), cf.Position)
                    previewAngle = 0
                    SkinCtrl:Reset()
                    SkinCtrl.Model = clone
                    SkinNameLabel.Text = skinName
                end

                local rotConn = RunService.RenderStepped:Connect(function(dt)
                    if previewModel and SkinsPage.Visible then SkinCtrl:Step(dt) end
                end)
                table.insert(Library.Connections, rotConn)

                -- Build weapon buttons
                local function BuildWeaponList()
                    for _, ch in ipairs(WepScroll:GetChildren()) do
                        if ch:IsA("TextButton") then ch:Destroy() end
                    end
                    weaponButtons = {}
                    for i, wName in ipairs(weapons) do
                        local btn = Instance.new("TextButton")
                        btn.Size = UDim2.new(1, 0, 0, 26)
                        btn.BackgroundColor3 = Theme.Section
                        btn.Text = wName
                        btn.TextColor3 = Theme.Text
                        btn.TextSize = 13
                        btn.Font = Config.FontMain
                        btn.TextXAlignment = Enum.TextXAlignment.Left
                        btn.AutoButtonColor = false
                        btn.LayoutOrder = i
                        btn.Parent = WepScroll
                        Corner(btn, 4)
                        local wPad = Instance.new("UIPadding")
                        wPad.PaddingLeft = UDim.new(0, 8)
                        wPad.Parent = btn
                        weaponButtons[wName] = btn
                        btn.Visible = wepQuery == "" or wName:lower():find(wepQuery, 1, true) ~= nil

                        local wc = btn.MouseButton1Click:Connect(function()
                            selectedWeapon = wName
                            selectedSkin = nil
                            HighlightWeapon(wName)
                            for _, ch in ipairs(SkinScroll:GetChildren()) do
                                if ch:IsA("TextButton") then ch:Destroy() end
                            end
                            skinButtons = {}
                            local skins = getSkins(wName)
                            for si, sName in ipairs(skins) do
                                local sbtn = Instance.new("TextButton")
                                sbtn.Size = UDim2.new(1, 0, 0, 24)
                                sbtn.BackgroundColor3 = Theme.Section
                                sbtn.Text = sName
                                sbtn.TextColor3 = Theme.Text
                                sbtn.TextSize = 12
                                sbtn.Font = Config.FontMain
                                sbtn.TextXAlignment = Enum.TextXAlignment.Left
                                sbtn.AutoButtonColor = false
                                sbtn.LayoutOrder = si
                                sbtn.Parent = SkinScroll
                                Corner(sbtn, 4)
                                local sPad = Instance.new("UIPadding")
                                sPad.PaddingLeft = UDim.new(0, 8)
                                sPad.Parent = sbtn
                                skinButtons[sName] = sbtn
                                local sc = sbtn.MouseButton1Click:Connect(function()
                                    selectedSkin = sName
                                    HighlightSkin(sName)
                                    ShowPreview(sName)
                                end)
                                table.insert(Library.Connections, sc)
                            end
                            FilterButtons(skinButtons, skinQuery)
                            ClearPreview()
                            SkinNameLabel.Text = "Select a skin"
                        end)
                        table.insert(Library.Connections, wc)
                    end
                end
                BuildWeaponList()

                -- Equip/Restore handlers
                local function DoEquip()
                    if selectedWeapon and selectedSkin then
                        local ok = onEquip(selectedWeapon, selectedSkin)
                        if ok then
                            EquipBtnL.Text = "EQUIPPED"
                            EquipBtnR.Text = "EQUIPPED"
                            task.delay(1.5, function()
                                pcall(function()
                                    EquipBtnL.Text = "EQUIP"
                                    EquipBtnR.Text = "EQUIP SKIN"
                                end)
                            end)
                        end
                    end
                end
                local ec1 = EquipBtnL.MouseButton1Click:Connect(DoEquip)
                local ec2 = EquipBtnR.MouseButton1Click:Connect(DoEquip)
                local rc1 = RestoreBtn.MouseButton1Click:Connect(function()
                    onRestore()
                    RestoreBtn.Text = "RESTORED"
                    task.delay(1, function() pcall(function() RestoreBtn.Text = "RESTORE" end) end)
                end)
                table.insert(Library.Connections, ec1)
                table.insert(Library.Connections, ec2)
                table.insert(Library.Connections, rc1)

                -- Hover effects
                local function HoverEffect(btn, normalColor)
                    local e1 = btn.MouseEnter:Connect(function()
                        if btn.BackgroundColor3 ~= Theme.Accent then
                            Tween(btn, {BackgroundColor3 = Theme.Stroke}, 0.15)
                        end
                    end)
                    local e2 = btn.MouseLeave:Connect(function()
                        if btn.BackgroundColor3 ~= Theme.Accent then
                            Tween(btn, {BackgroundColor3 = normalColor}, 0.15)
                        end
                    end)
                    table.insert(Library.Connections, e1)
                    table.insert(Library.Connections, e2)
                end
                HoverEffect(RestoreBtn, Theme.Section)

                function BrowserObj:SetWeapons(newWeapons, tabName)
                    if tabName and tabName ~= "Skins" and cosmeticPages[tabName] then
                        cosmeticPages[tabName]:SetWeapons(newWeapons)
                        return
                    end
                    weapons = newWeapons
                    BuildWeaponList()
                end
                function BrowserObj:GetSelected(tabName)
                    if tabName and tabName ~= "Skins" and cosmeticPages[tabName] then
                        return cosmeticPages[tabName].GetSelected()
                    end
                    return selectedWeapon, selectedSkin
                end
                function BrowserObj:GetHost(tabName)
                    local pg = cosmeticPages[tabName]
                    return pg and pg.Host or nil
                end
                function BrowserObj:Refresh(tabName)
                    local pg = cosmeticPages[tabName]
                    if pg and pg.Refresh then pg.Refresh() end
                end
                return BrowserObj
            end
            return Section
        end
        return Tab
    end
    local Auto_Save_Timer = 0
    local Auto_Save_Conn = RunService.Heartbeat:Connect(function(dt)
        if Library.AutoSaveEnabled and Library.Unsaved then
            Auto_Save_Timer = Auto_Save_Timer + dt
            if Auto_Save_Timer >= 3 then
                Auto_Save_Timer = 0
                Library.Unsaved = false
                Library:SaveConfig("_autosave")
            end
        end
    end)
    table.insert(Library.Connections, Auto_Save_Conn)
    task.defer(function()
        Library:LoadConfig("_autosave")
    end)
    local InfoTab = WindowObj:Tab("Info", "89366818397358")
    local AboutSec = InfoTab:Section("Phantom Softworks")
    AboutSec:Label(string.format("Welcome to <font color='#%s'>%s</font>. Join our community and stay up to date with the latest updates.", Theme.Accent:ToHex(), Library.HubConfig.Name))
    AboutSec:Button("Discord", "Copy the Discord link", function() CopyLink(Library.HubConfig.Socials.Discord, "Discord") end)
    AboutSec:Button("YouTube", "Copy the YouTube link", function() CopyLink(Library.HubConfig.Socials.YouTube, "YouTube") end)
    AboutSec:Label(string.format("Game: <font color='#%s'>%s</font>", Theme.Accent:ToHex(), GameName))
    local UpdSec = InfoTab:Section("Updates", "Right")
    UpdSec:Label("Latest changelog:")
    if Library.HubConfig.UpdateLog.Date and Library.HubConfig.UpdateLog.Date ~= "" then
        UpdSec:Label(string.format("Date: <font color='#%s'>%s</font>", Theme.Accent:ToHex(), Library.HubConfig.UpdateLog.Date))
    end
    if #Library.HubConfig.UpdateLog.Added > 0 then
        UpdSec:Label("Added:", { Color = Theme.Success })
        for _, v in ipairs(Library.HubConfig.UpdateLog.Added) do UpdSec:Bullet("- " .. v, "added") end
    end
    if #Library.HubConfig.UpdateLog.Fixed > 0 then
        UpdSec:Label("Fixed:", { Color = Theme.Accent })
        for _, v in ipairs(Library.HubConfig.UpdateLog.Fixed) do UpdSec:Bullet("- " .. v, "fixed") end
    end
    MainScale.Scale = GetBaseScale()
    MainWindow.Visible = true
    return WindowObj
end
return Library
