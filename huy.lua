
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local MarketplaceService = game:GetService("MarketplaceService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")

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
	AutoSaveEnabled = true,
	UIHidden = false,
	
	UserScale = 1,
	BlurEnabled = false,
	WatermarkEnabled = true,
	DecorEnabled = true,
	Animations = true,
	CustomAccent = nil,
	Rounding = "Default",
	TooltipsEnabled = true,
	NotifySide = "Bottom right",
	MiniButtonEnabled = true,
	InterfaceDirty = false,
}

local function PickFont(name, fallback)
	local ok, font = pcall(function() return Enum.Font[name] end)
	if ok and font then return font end
	return fallback
end

local Config = {
	Name = "PHANTOM HUB",
	Brand = "Phantom Softworks",
	Theme = "Phantom Red",
	Keybind = Enum.KeyCode.LeftControl,
	HideKeybind = Enum.KeyCode.Unknown,
	Duration = 0.25,
	FontMain = Enum.Font.Code,
	FontBold = Enum.Font.Code,
	ConfigFolder = "PhantomHub",
}
if not isfolder(Config.ConfigFolder) then makefolder(Config.ConfigFolder) end





-- every theme shares the same neutral greys; only the accent colors change
local BASE = {
	Background = "#111111", Sidebar = "#0d0d0d", Topbar = "#0d0d0d",
	Section = "#0d0d0d", Container = "#191919", Stroke = "#282828",
	Text = "#ffffff", TextDark = "#9a9a9a", TextMuted = "#5c5c5c",
	Success = "#5fd38d", Warning = "#ffc455", Danger = "#ff4b4b",
}
local function Palette(accent, accent2, accentText)
	local p = {Accent = accent, Accent2 = accent2, AccentText = accentText or "#ffffff"}
	for k, v in pairs(BASE) do p[k] = v end
	return p
end
local Themes = {
	["Phantom Red"] = Palette("#ff3b3b", "#ff8a5c"),
	["Obsidian"] = Palette("#7d55ff", "#b18cff"),
	["Halloween"] = Palette("#ff7a1a", "#a65cff"),
	["Christmas"] = Palette("#e5484d", "#3fbf7f"),
	["Midnight"] = Palette("#4c8dff", "#7c5cff"),
	["Emerald"] = Palette("#2ee6a0", "#2bc4e0", "#0b0b0b"),
	["Rose"] = Palette("#ff5c9a", "#ff9ac1"),
	["Solar"] = Palette("#ffb22e", "#ff6b3d", "#0b0b0b"),
	["Frost"] = Palette("#7fd6ff", "#b7a6ff", "#0b0b0b"),
	["Graphite"] = Palette("#e8e8e8", "#9a9aa2", "#0b0b0b"),
}
local ThemeOrder = {"Phantom Red", "Obsidian", "Halloween", "Christmas", "Midnight", "Emerald", "Rose", "Solar", "Frost", "Graphite"}
local ThemeKeys = {"Background", "Sidebar", "Topbar", "Section", "Container", "Stroke", "Accent", "Accent2", "Text", "TextDark", "TextMuted", "AccentText", "Success", "Warning", "Danger"}
for _, palette in pairs(Themes) do
	for k, v in pairs(palette) do
		if type(v) == "string" then palette[k] = Color3.fromHex(v) end
	end
end

local Theme = {}
Library.Theme = Theme
Library.Themes = Themes
Library.CurrentTheme = Themes[Config.Theme] and Config.Theme or "Phantom Red"
Library.Fonts = {Main = Config.FontMain, Bold = Config.FontBold}

local function Luminance(c)
	return 0.2126 * c.R + 0.7152 * c.G + 0.0722 * c.B
end

local function DeriveTheme()
	Theme.Hover = Theme.Container:Lerp(Theme.Text, 0.04)
	Theme.Pressed = Theme.Container:Lerp(Theme.Text, 0.12)
	Theme.Field = Theme.Background:Lerp(Theme.Section, 0.45)
	Theme.AccentSoft = Theme.Section:Lerp(Theme.Accent, 0.16)
	Theme.StrokeHover = Theme.Stroke:Lerp(Theme.Text, 0.12)
end

----------------------------------------------------------------------------------------------------
-- UI styles: whole-look presets. The accent theme sits on top of whichever style is active.
--   Cards      each element sits on its own card (Fluent / Modern / OG)
--   GroupPanel sections are boxed panels with a title line (Obsidian / OG)
--   Dim        how faded an "off" toggle label is
--   Slider     "bar" = value written inside a 15px bar, "thin" = 4px rail + round thumb
--   WindowT    window transparency (Fluent's see-through acrylic look)
----------------------------------------------------------------------------------------------------
-- extra tokens:
--   Toggle "switch" | "check"     TabIcons / TabPill  sidebar icons / accent-tinted active tab
--   ButtonCenter   centered text  CenterLabels        labels above controls are centered
--   TitleSize / TitleDim / GroupLine   groupbox title look     Gradient   soft shade on controls
--   TopAccent  accent line under the top bar     TopLogo / TopSize   top bar logo / title size
local Styles = {
	-- your original library: red Phantom colors, Gotham, boxed elements, checkbox toggles
	["OG"] = {
		Font = "Gotham", Rounding = "Round", Cards = true, CardPad = 8, CardT = 0, CardStrokeT = 0.5,
		GroupPanel = true, GroupLine = false, TitleSize = 13, TitleDim = true,
		StrokeT = 0.5, WindowT = 0.1, Dim = 0, Slider = "og", Toggle = "check",
		ButtonCenter = true, CenterLabels = false, Gradient = false,
		TabIcons = true, TabPill = false, Dividers = true, FlatChrome = false, WindowGradient = false,
		TopAccent = true, TopLogo = true, TopSize = 15, PanelStrokeT = 0,
		Base = {
			Background = "#080505", Sidebar = "#0c0707", Topbar = "#120a0a", Section = "#1a0e0e",
			Container = "#140b0b", Card = "#140b0b", Stroke = "#2e1717",
			Text = "#ffffff", TextDark = "#997373", TextMuted = "#5e4545",
		},
	},
	["Obsidian"] = {
		Font = "Code", Rounding = "Default", Cards = false, CardPad = 0, CardT = 1, CardStrokeT = 1,
		GroupPanel = true, GroupLine = true, TitleSize = 15, TitleDim = false,
		StrokeT = 0, WindowT = 0, Dim = 0.4, Slider = "bar", Toggle = "switch",
		ButtonCenter = true, CenterLabels = false, Gradient = false,
		TabIcons = true, TabPill = false, Dividers = true, FlatChrome = false, WindowGradient = false,
		TopAccent = false, TopLogo = true, TopSize = 20, PanelStrokeT = 0,
		Base = {},
	},
	["Fluent"] = {
		Font = "Gotham", Rounding = "Default", Cards = true, CardPad = 11, CardT = 0.87, CardStrokeT = 0.35,
		GroupPanel = false, GroupLine = false, TitleSize = 17, TitleDim = false,
		StrokeT = 0.55, WindowT = 0.06, Dim = 0, Slider = "thin", Toggle = "switch",
		ButtonCenter = false, CenterLabels = false, Gradient = false,
		TabIcons = true, TabPill = false, Dividers = true, FlatChrome = false, WindowGradient = false,
		TopAccent = false, TopLogo = true, TopSize = 16, PanelStrokeT = 0,
		Base = {
			Background = "#202020", Sidebar = "#1c1c1c", Topbar = "#1c1c1c", Section = "#202020",
			Container = "#2d2d2d", Card = "#787878", Stroke = "#3c3c3c",
			Text = "#f0f0f0", TextDark = "#aaaaaa", TextMuted = "#787878",
		},
	},
	-- Modern: one smooth gradient surface, no lines, soft rounded panels,
	-- accent-tinted tab pills, capsule sliders with a gradient fill
	["Modern"] = {
		Font = "Builder Sans Bold", Rounding = "Soft", Cards = false, CardPad = 0, CardT = 1, CardStrokeT = 1,
		GroupPanel = true, GroupLine = false, TitleSize = 16, TitleDim = false,
		StrokeT = 1, WindowT = 0, Dim = 0.3, Slider = "capsule", Toggle = "switch",
		ButtonCenter = true, CenterLabels = false, Gradient = false,
		TabIcons = true, TabPill = true, Dividers = false, FlatChrome = true, WindowGradient = true,
		TopAccent = false, TopLogo = true, TopSize = 17, PanelStrokeT = 1,
		Base = {
			Background = "#17171d", Sidebar = "#17171d", Topbar = "#17171d", Section = "#1f1f27",
			Container = "#2a2a34", Card = "#1f1f27", Stroke = "#2e2e38",
			Text = "#f4f4f7", TextDark = "#9a9aa8", TextMuted = "#62626e",
		},
	},
}
local StyleOrder = {"OG", "Obsidian", "Fluent", "Modern"}
for _, st in pairs(Styles) do
	for k, v in pairs(st.Base) do st.Base[k] = Color3.fromHex(v) end
end
Library.StyleName = "Obsidian"
local Style = Styles[Library.StyleName]
local function LabelAlign()
	return Style.CenterLabels and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
end
Library.Styles = Styles

-- user color overrides (Settings > Appearance > Colors); they stay when switching themes
Library.CustomColors = {}
local function LoadPalette(name)
	local palette = Themes[name] or Themes["Phantom Red"]
	for _, key in ipairs(ThemeKeys) do
		Theme[key] = Library.CustomColors[key] or Style.Base[key] or palette[key]
	end
	Theme.Card = Library.CustomColors.Card or Style.Base.Card or Theme.Container
	DeriveTheme()
end
LoadPalette(Library.CurrentTheme)

-- Every themed property is registered here so theme changes can tween smoothly.
-- A value is either a theme key ("Accent") or a function returning the value (for state-dependent looks).
local Bound = {}
local ThemeHooks = {}
local HooksPending = false

local function Resolve(key)
	if type(key) == "function" then return key() end
	return Theme[key]
end

local function ThemeBind(inst, map)
	local cur = Bound[inst]
	if not cur then
		cur = {}
		Bound[inst] = cur
	end
	for prop, key in pairs(map) do
		cur[prop] = key
		local v = Resolve(key)
		if v ~= nil then inst[prop] = v end
	end
	return inst
end

local function OnThemeChanged(fn)
	table.insert(ThemeHooks, fn)
end

local function RefreshTheme(animate)
	local info = TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	for inst, map in pairs(Bound) do
		if inst.Parent == nil then
			Bound[inst] = nil
		else
			local goals
			for prop, key in pairs(map) do
				local ok, v = pcall(Resolve, key)
				if ok and v ~= nil then
					if animate and typeof(v) == "Color3" then
						goals = goals or {}
						goals[prop] = v
					else
						pcall(function() inst[prop] = v end)
					end
				end
			end
			if goals then
				pcall(function() TweenService:Create(inst, info, goals):Play() end)
			end
		end
	end
	-- hooks (console rebuild, keybind list, decor...) are batched so dragging the
	-- accent picker doesn't rebuild everything every frame
	if not HooksPending then
		HooksPending = true
		task.delay(0.08, function()
			HooksPending = false
			for _, fn in ipairs(ThemeHooks) do task.spawn(pcall, fn) end
		end)
	end
end

----------------------------------------------------------------------------------------------------
-- Core helpers
----------------------------------------------------------------------------------------------------

local GuiParent
local function GetParent()
	if GuiParent and GuiParent.Parent then return GuiParent end
	if typeof(gethui) == "function" then
		local ok, h = pcall(gethui)
		if ok and typeof(h) == "Instance" then
			GuiParent = h
			return h
		end
	end
	if CoreGui then
		local ok = pcall(function()
			local probe = Instance.new("ScreenGui")
			probe.Parent = CoreGui
			probe:Destroy()
		end)
		if ok then
			GuiParent = CoreGui
			return CoreGui
		end
	end
	GuiParent = LocalPlayer:WaitForChild("PlayerGui")
	return GuiParent
end

local function Track(signal, fn)
	local c = signal:Connect(fn)
	table.insert(Library.Connections, c)
	return c
end

local function Tween(obj, props, time, style, dir)
	time = time or Config.Duration
	if not Library.Animations then time = 0 end
	local t = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function Loop(obj, props, time)
	local t = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), props)
	t:Play()
	return t
end

local TEXT_CLASSES = {TextLabel = true, TextButton = true, TextBox = true}

local function New(class, props)
	local inst = Instance.new(class)
	props = props or {}
	local themeMap = props.Theme
	if inst:IsA("GuiObject") then inst.BorderSizePixel = 0 end
	if TEXT_CLASSES[class] then
		inst.BackgroundTransparency = 1
		inst.Font = Config.FontMain
		inst.TextSize = 14
		if class == "TextButton" then
			inst.AutoButtonColor = false
			inst.Text = ""
		elseif class == "TextBox" then
			inst.ClearTextOnFocus = false
			inst.Text = ""
			if not (themeMap and themeMap.PlaceholderColor3) then ThemeBind(inst, {PlaceholderColor3 = "TextMuted"}) end
		end
		if props.TextColor3 == nil and not (themeMap and themeMap.TextColor3) then
			ThemeBind(inst, {TextColor3 = "Text"})
		end
	elseif class == "ImageLabel" or class == "ImageButton" then
		inst.BackgroundTransparency = 1
		if class == "ImageButton" then inst.AutoButtonColor = false end
	elseif class == "ScrollingFrame" then
		inst.BackgroundTransparency = 1
		inst.ScrollBarThickness = 2
		inst.ScrollBarImageTransparency = 0.3
		inst.CanvasSize = UDim2.new()
		inst.AutomaticCanvasSize = Enum.AutomaticSize.Y
		inst.ScrollingDirection = Enum.ScrollingDirection.Y
		if not (themeMap and themeMap.ScrollBarImageColor3) then ThemeBind(inst, {ScrollBarImageColor3 = "Accent"}) end
	end
	-- text/image/scroll objects start transparent, but if a background color is given they should show it
	if props.BackgroundTransparency == nil and inst:IsA("GuiObject") and (props.BackgroundColor3 ~= nil or (themeMap and themeMap.BackgroundColor3 ~= nil)) then
		inst.BackgroundTransparency = 0
	end
	for k, v in pairs(props) do
		if k ~= "Parent" and k ~= "Theme" then inst[k] = v end
	end
	if themeMap then ThemeBind(inst, themeMap) end
	if props.Parent then inst.Parent = props.Parent end
	return inst
end

-- corner style ("Sharp" / "Default" / "Medium" / "Round" / "Soft") scales the 2px and 4px style corners;
-- circles and tiny dots keep their radius
local Corners = {}
local RoundingScale = {Sharp = 0, Default = 1, Medium = 1.75, Round = 2.5, Soft = 3}
local function ScaledRadius(base)
	return math.floor(base * (RoundingScale[Library.Rounding] or 1) + 0.5)
end
local function Corner(parent, radius)
	radius = radius or 6
	local scalable = (radius == 2 or radius == 4) and not (parent.Size.X.Scale == 0 and parent.Size.X.Offset <= 8)
	local c = New("UICorner", {CornerRadius = UDim.new(0, scalable and ScaledRadius(radius) or radius), Parent = parent})
	if scalable then Corners[c] = radius end
	return c
end

function Library:SetRounding(style)
	if not RoundingScale[style] then return end
	Library.Rounding = style
	for c, base in pairs(Corners) do
		if c.Parent then
			c.CornerRadius = UDim.new(0, ScaledRadius(base))
		else
			Corners[c] = nil
		end
	end
	Library.InterfaceDirty = true
end

local FontChoices = {
	Code = Enum.Font.Code,
	Gotham = Enum.Font.GothamMedium,
	["Builder Sans"] = PickFont("BuilderSansMedium", Enum.Font.GothamMedium),
	["Builder Sans Bold"] = PickFont("BuilderSansBold", Enum.Font.GothamBold),
	Ubuntu = Enum.Font.Ubuntu,
	["Source Sans"] = Enum.Font.SourceSans,
	Arial = Enum.Font.Arial,
}
local FontOrder = {"Code", "Gotham", "Builder Sans", "Builder Sans Bold", "Ubuntu", "Source Sans", "Arial"}
Library.FontName = "Code"

-- outlines created fully visible follow the style's outline strength
local function Stroke(parent, key, transparency, thickness)
	local map = {Color = key or "Stroke"}
	if (transparency or 0) == 0 then
		map.Transparency = function() return Style and Style.StrokeT or 0 end
	end
	return New("UIStroke", {
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Theme = map,
		Parent = parent,
	})
end

local function Padding(parent, t, r, b, l)
	return New("UIPadding", {
		PaddingTop = UDim.new(0, t or 0), PaddingRight = UDim.new(0, r or 0),
		PaddingBottom = UDim.new(0, b or 0), PaddingLeft = UDim.new(0, l or 0),
		Parent = parent,
	})
end

local function ListLayout(parent, pad, horizontal, halign, valign)
	return New("UIListLayout", {
		Padding = UDim.new(0, pad or 0),
		FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
		HorizontalAlignment = halign or Enum.HorizontalAlignment.Left,
		VerticalAlignment = valign or Enum.VerticalAlignment.Top,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = parent,
	})
end

local function UIScaleValue()
	local s = Library._MainScale
	if s and s.Scale > 0 then return s.Scale end
	return 1
end

-- mouse position in the same space as AbsolutePosition
local function MousePos()
	return UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
end

local function IsTouchOnly()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

-- click ripples are off in every style; kept so older calls still work
local function Ripple(btn) end

-- standard hover / press feel for button-like things
local function Interactive(btn, stroke, baseKey)
	baseKey = baseKey or "Container"
	local hovered = false
	Track(btn.MouseEnter, function()
		hovered = true
		Tween(btn, {BackgroundColor3 = Theme.Hover}, 0.18)
		if stroke then Tween(stroke, {Color = Theme.StrokeHover}, 0.18) end
	end)
	Track(btn.MouseLeave, function()
		hovered = false
		Tween(btn, {BackgroundColor3 = Theme[baseKey]}, 0.3)
		if stroke then Tween(stroke, {Color = Theme.Stroke}, 0.3) end
	end)
	Track(btn.MouseButton1Down, function()
		Tween(btn, {BackgroundColor3 = Theme.Pressed}, 0.1)
	end)
	Track(btn.MouseButton1Up, function()
		Tween(btn, {BackgroundColor3 = hovered and Theme.Hover or Theme[baseKey]}, 0.25)
	end)
end

----------------------------------------------------------------------------------------------------
-- UI hide / theme / style API
----------------------------------------------------------------------------------------------------

local OwnedScreens = {"PhantomMiniButton", "PhantomTooltip", "PhantomNotifications", "PhantomWatermark", "PhantomConsole", "PrismaKeybinds"}

function Library:SetUIHidden(state)
	state = state and true or false
	Library.UIHidden = state
	if Library.ScreenGui then pcall(function() Library.ScreenGui.Enabled = not state end) end
	for _, g in pairs(GetParent():GetChildren()) do
		if g:IsA("ScreenGui") and table.find(OwnedScreens, g.Name) then
			pcall(function() g.Enabled = not state end)
		end
	end
end

function Library:SetTheme(name, silent)
	if not Themes[name] then return false end
	Library.CurrentTheme = name
	Library.CustomAccent = nil
	LoadPalette(name)
	RefreshTheme(true)
	Library.InterfaceDirty = true
	if not silent then Library:Notify("Theme", "Switched to " .. name, 2, "Success") end
	return true
end

function Library:UpdateTheme(newColor)
	if typeof(newColor) ~= "Color3" then return end
	Theme.Accent = newColor
	Theme.AccentText = Luminance(newColor) > 0.62 and Color3.fromRGB(20, 14, 8) or Color3.fromRGB(255, 255, 255)
	Library.CustomAccent = newColor
	DeriveTheme()
	RefreshTheme(false)
	Library.InterfaceDirty = true
end

-- override one base color (Background, Section, Container, Stroke, Text, ...), nil puts the style's back
function Library:SetColor(key, color)
	if not table.find(ThemeKeys, key) then return end
	Library.CustomColors[key] = typeof(color) == "Color3" and color or nil
	local accent, accentText = Theme.Accent, Theme.AccentText
	LoadPalette(Library.CurrentTheme)
	if Library.CustomAccent then
		Theme.Accent, Theme.AccentText = accent, accentText
		DeriveTheme()
	end
	RefreshTheme(false)
	Library.InterfaceDirty = true
end

function Library:ResetColors()
	table.clear(Library.CustomColors)
	Library.CustomAccent = nil
	LoadPalette(Library.CurrentTheme)
	RefreshTheme(true)
	Library.InterfaceDirty = true
end

function Library:SetFont(name)
	local font = FontChoices[name]
	if not font then return end
	Library.FontName = name
	Config.FontMain, Config.FontBold = font, font
	Library.Fonts.Main, Library.Fonts.Bold = font, font
	local roots = {Library.ScreenGui}
	for _, g in pairs(GetParent():GetChildren()) do
		if table.find(OwnedScreens, g.Name) then table.insert(roots, g) end
	end
	for _, root in ipairs(roots) do
		if root then
			for _, d in ipairs(root:GetDescendants()) do
				if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then d.Font = font end
			end
		end
	end
	Library.InterfaceDirty = true
end

-- swap the whole look (see Styles); keeps the accent theme and custom colors
local StyleHooks = {}
function Library:SetStyle(name)
	local st = Styles[name]
	if not st then return false end
	Library.StyleName = name
	Style = st
	LoadPalette(Library.CurrentTheme)
	if Library.CustomAccent then
		Theme.Accent = Library.CustomAccent
		Theme.AccentText = Luminance(Library.CustomAccent) > 0.62 and Color3.fromRGB(20, 14, 8) or Color3.fromRGB(255, 255, 255)
		DeriveTheme()
	end
	RefreshTheme(true)
	Library:SetFont(st.Font)
	Library:SetRounding(st.Rounding)
	for _, fn in ipairs(StyleHooks) do task.spawn(pcall, fn) end
	Library.InterfaceDirty = true
	return true
end

----------------------------------------------------------------------------------------------------
-- Icons
----------------------------------------------------------------------------------------------------

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

local ASSET_CHEVRON = "rbxassetid://10709790948"
local ASSET_CLOSE = "rbxassetid://10738425363"
local ASSET_MIN = "rbxassetid://10664064072"
local ASSET_SV = "rbxassetid://4155801252"
local ASSET_LOGO = "rbxassetid://112964043447417"

local function IconImage(parent, icon, size, props)
	props = props or {}
	props.Size = UDim2.fromOffset(size, size)
	props.Parent = parent
	local img = New("ImageLabel", props)
	ApplyIcon(img, icon)
	return img
end

----------------------------------------------------------------------------------------------------
-- Seasonal decor (Halloween cobwebs + spiders, Christmas snow)
----------------------------------------------------------------------------------------------------

local function DecorLine(parent, x1, y1, x2, y2, colorKey, transparency, thickness)
	local dx, dy = x2 - x1, y2 - y1
	return New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset((x1 + x2) / 2, (y1 + y2) / 2),
		Size = UDim2.fromOffset(math.sqrt(dx * dx + dy * dy), thickness or 1),
		Rotation = math.deg(math.atan2(dy, dx)),
		BackgroundTransparency = transparency or 0,
		Theme = {BackgroundColor3 = colorKey},
		Parent = parent,
	})
end

local function BuildCobweb(parent, position, size, corner)
	local Web = New("Frame", {
		Name = "Cobweb",
		Size = UDim2.fromOffset(size, size),
		Position = position,
		AnchorPoint = Vector2.new(corner.X > 0 and 1 or 0, corner.Y > 0 and 1 or 0),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	local ox, oy = corner.X > 0 and size or 0, corner.Y > 0 and size or 0
	local sx, sy = corner.X > 0 and -1 or 1, corner.Y > 0 and -1 or 1
	local spokes = 6
	local angles = {}
	for i = 0, spokes - 1 do
		local a = math.rad(90 * i / (spokes - 1))
		DecorLine(Web, ox, oy, ox + sx * math.cos(a) * size, oy + sy * math.sin(a) * size, "TextMuted", 0.55, 1)
		angles[i] = a
	end
	for _, k in ipairs({0.22, 0.42, 0.62, 0.82}) do
		local r = size * k
		for i = 0, spokes - 2 do
			local a1, a2 = angles[i], angles[i + 1]
			local am = (a1 + a2) / 2
			local x1, y1 = ox + sx * math.cos(a1) * r, oy + sy * math.sin(a1) * r
			local x2, y2 = ox + sx * math.cos(a2) * r, oy + sy * math.sin(a2) * r
			local xm, ym = ox + sx * math.cos(am) * r * 0.9, oy + sy * math.sin(am) * r * 0.9
			DecorLine(Web, x1, y1, xm, ym, "TextMuted", 0.65, 1)
			DecorLine(Web, xm, ym, x2, y2, "TextMuted", 0.65, 1)
		end
	end
	return Web
end

local function BuildSpider(parent, xScale, topOffset, length, speed)
	local drop = 10
	local half = length + drop + 26
	local Pivot = New("Frame", {
		Name = "Spider",
		Size = UDim2.fromOffset(24, half * 2),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(xScale, 0, 0, topOffset),
		BackgroundTransparency = 1,
		Rotation = -6,
		Parent = parent,
	})
	local Drop = New("Frame", {Size = UDim2.fromOffset(24, length), Position = UDim2.fromOffset(0, half), BackgroundTransparency = 1, Parent = Pivot})
	New("Frame", {Size = UDim2.new(0, 1, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 0.5, Theme = {BackgroundColor3 = "TextMuted"}, Parent = Drop})
	local Body = New("Frame", {Size = UDim2.fromOffset(24, 24), Position = UDim2.new(0, 0, 1, -4), BackgroundTransparency = 1, Parent = Drop})
	local legs = {}
	for _, side in ipairs({-1, 1}) do
		for _, l in ipairs({{-3, -9, -6}, {0, -11, -1}, {3, -11, 4}, {5, -8, 10}}) do
			local y0, kx, ky = l[1], l[2], l[3]
			local kneeX, kneeY = 12 + side * 7, 12 + y0 - 4
			DecorLine(Body, 12, 12 + y0 / 2, kneeX, kneeY, "Stroke", 0, 1.5)
			table.insert(legs, DecorLine(Body, kneeX, kneeY, 12 - side * kx, 12 + ky, "Stroke", 0, 1.5))
		end
	end
	local Abdomen = New("Frame", {Size = UDim2.fromOffset(10, 12), Position = UDim2.fromOffset(7, 9), Theme = {BackgroundColor3 = "Stroke"}, Parent = Body})
	Corner(Abdomen, 6)
	local Head = New("Frame", {Size = UDim2.fromOffset(7, 7), Position = UDim2.fromOffset(8.5, 4), Theme = {BackgroundColor3 = "Stroke"}, Parent = Body})
	Corner(Head, 4)
	for _, ex in ipairs({1.5, 4}) do
		New("Frame", {Size = UDim2.fromOffset(1.5, 1.5), Position = UDim2.fromOffset(ex, 3), Theme = {BackgroundColor3 = "Accent"}, Parent = Head})
	end
	Loop(Pivot, {Rotation = 6}, speed)
	Loop(Drop, {Size = UDim2.fromOffset(24, length + drop)}, speed * 1.7)
	for i, leg in ipairs(legs) do
		local r = leg.Rotation
		leg.Rotation = r - 5
		Loop(leg, {Rotation = r + 5}, 0.9 + (i % 4) * 0.15)
	end
	return Pivot
end

local function BuildHalloweenDecor(win, top)
	local Decor = New("Frame", {Name = "SeasonDecor", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 15, Parent = win})
	BuildCobweb(Decor, UDim2.new(1, 0, 0, top), 84, Vector2.new(1, 0))
	BuildCobweb(Decor, UDim2.new(1, 0, 1, 0), 64, Vector2.new(1, 1))
	BuildSpider(Decor, 0.64, top, 26, 2.4)
	BuildSpider(Decor, 0.88, top, 48, 3.1)
	local GhostFloat = New("Frame", {Size = UDim2.fromOffset(26, 26), Position = UDim2.new(1, -96, 1, -46), BackgroundTransparency = 1, Parent = Decor})
	local Ghost = New("ImageLabel", {Size = UDim2.fromScale(1, 1), ImageTransparency = 0.75, Rotation = -7, Theme = {ImageColor3 = "Text"}, Parent = GhostFloat})
	ApplyIcon(Ghost, "ghost")
	Loop(GhostFloat, {Position = UDim2.new(1, -96, 1, -56)}, 3.6)
	Loop(Ghost, {Rotation = 7}, 2.6)
	Loop(Ghost, {ImageTransparency = 0.9}, 3.1)
	return Decor
end

-- gentle snowfall drawn over the window for the Christmas theme
local function BuildChristmasDecor(win, top)
	local Decor = New("Frame", {Name = "SeasonDecor", Size = UDim2.new(1, 0, 1, -top), Position = UDim2.fromOffset(0, top), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 15, Parent = win})
	local flakes = {}
	local rng = Random.new()
	for i = 1, 34 do
		local size = rng:NextNumber(2, 4.5)
		local f = New("Frame", {
			Size = UDim2.fromOffset(size, size),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = rng:NextNumber(0.45, 0.8),
			Parent = Decor,
		})
		Corner(f, 3)
		flakes[i] = {
			Frame = f,
			X = rng:NextNumber(0, 1),
			Y = rng:NextNumber(-0.1, 1),
			Speed = rng:NextNumber(0.03, 0.08) * (size / 3),
			Sway = rng:NextNumber(0.004, 0.012),
			Phase = rng:NextNumber(0, math.pi * 2),
		}
	end
	local conn = RunService.RenderStepped:Connect(function(dt)
		if not Decor.Parent or not Library.Open then return end
		local t = os.clock()
		for _, fl in ipairs(flakes) do
			fl.Y += fl.Speed * dt
			if fl.Y > 1.05 then
				fl.Y = -0.05
				fl.X = math.random()
			end
			fl.Frame.Position = UDim2.fromScale(fl.X + math.sin(t * 0.8 + fl.Phase) * fl.Sway, fl.Y)
		end
	end)
	table.insert(Library.Connections, conn)
	Decor.Destroying:Connect(function() conn:Disconnect() end)
	return Decor
end

----------------------------------------------------------------------------------------------------
-- Hub info
----------------------------------------------------------------------------------------------------

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
	if type(config) ~= "table" then return end
	for k, v in pairs(config) do
		if type(v) == "table" and type(Library.HubConfig[k]) == "table" then
			for kk, vv in pairs(v) do Library.HubConfig[k][kk] = vv end
		else
			Library.HubConfig[k] = v
		end
	end
end

local function CopyLink(link, name)
	if not link or link == "" then return end
	local ok = pcall(function() setclipboard(link) end)
	if ok then
		Library:Notify(name or "Link", "Copied to clipboard", 2, "Success")
	else
		Library:Notify(name or "Link", link, 6)
	end
end

local function RoundToIncrement(value, increment)
	if increment <= 0 then return value end
	return math.round(value / increment) * increment
end

local function FormatNumber(value, increment)
	if increment >= 1 then return tostring(math.round(value)) end
	local str = tostring(increment)
	local dotPos = string.find(str, "%.")
	if dotPos then
		return string.format("%." .. (#str - dotPos) .. "f", value)
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
			if Drag_Update == update then
				Drag_Update = nil
				Drag_Input = nil
			end
			c:Disconnect()
			if onEnd then onEnd() end
		end
	end)
end

local function IsPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end


local function MakeDraggable(handle, frame, onMoved)
	Track(handle.InputBegan, function(input)
		if not IsPress(input) then return end
		local start = input.Position
		local startPos = frame.Position
		local moved = false
		BeginDrag(input, function(cur)
			local d = cur.Position - start
			if not moved and Vector2.new(d.X, d.Y).Magnitude < 4 then return end
			moved = true
			if onMoved then onMoved() end
			Tween(frame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)}, 0.12, Enum.EasingStyle.Quad)
		end)
	end)
end

local function MakeResizable(handle, frame, minSize)
	Track(handle.InputBegan, function(input)
		if not IsPress(input) then return end
		local start = input.Position
		local startSize = frame.Size
		local startPos = frame.Position
		local scaleObj = frame:FindFirstChildWhichIsA("UIScale")
		local mult = scaleObj and scaleObj.Scale or 1
		if mult <= 0 then mult = 1 end
		BeginDrag(input, function(cur)
			local d = cur.Position - start
			local newX = math.max(minSize.X, startSize.X.Offset + d.X / mult)
			local newY = math.max(minSize.Y, startSize.Y.Offset + d.Y / mult)
			local diffX = (newX - startSize.X.Offset) * mult
			local diffY = (newY - startSize.Y.Offset) * mult
			frame.Size = UDim2.fromOffset(newX, newY)
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + diffX / 2, startPos.Y.Scale, startPos.Y.Offset + diffY / 2)
		end)
	end)
end

local function GetBaseScale()
	local vp = workspace.CurrentCamera.ViewportSize
	if vp.X < 1 or vp.Y < 1 then return 1 end
	-- phones: keep text readable, the window shrinks to fit instead (see CreateWindow)
	if IsTouchOnly() then return math.clamp(math.min(vp.Y / 460, vp.X / 700), 0.55, 1) end
	local scale = math.min(vp.X / 950, vp.Y / 560)
	if scale < 1 then return math.clamp(scale * 0.95, 0.4, 1) end
	return 1
end

local function EffectiveScale()
	return GetBaseScale() * Library.UserScale
end





Library.Logs = {}
Library.LogLimit = 200
local LogLevels = {Info = true, Warning = true, Error = true}
local LogListeners = {}

local function LogColor(level)
	if level == "Warning" then return Theme.Warning end
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
	[Enum.MessageType.MessageError] = "Error",
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





local Tooltip = {}

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
	pcall(function()
		local blur = Lighting:FindFirstChild("PhantomBlur")
		if blur then blur:Destroy() end
	end)
	Library.Binds = {}
	Library.BindOrder = {}
	Library.SearchIndex = {}
	Library.Watermark = nil
	Library.Console = nil
	Library._MainScale = nil
	Tooltip.Frame = nil
	table.clear(ThemeHooks)
	table.clear(StyleHooks)
	table.clear(LogListeners)
	table.clear(Bound)
	for _, g in pairs(GetParent():GetChildren()) do
		if g.Name == Config.Name or g.Name == "PrismaMini" or g.Name == "PrismaLoader" or table.find(OwnedScreens, g.Name) then
			pcall(function() g:Destroy() end)
		end
	end
end





function Library:GetConfigs()
	local configs = {}
	if isfolder(Config.ConfigFolder) then
		for _, file in ipairs(listfiles(Config.ConfigFolder)) do
			if string.sub(file, -5) == ".json" then
				local name = string.match(string.gsub(file, "\\", "/"), "([^/]+)%.json$") or file
				if string.sub(name, 1, 1) ~= "_" then table.insert(configs, name) end
			end
		end
	end
	table.sort(configs)
	return configs
end

local IgnoredFlags = {
	ConfigSelectorFlag = true,
	ConfigNameFlag = true,
	MenuAccentColor = true,
	SelectedTheme = true,
	KeybindListToggle = true,
	ConsoleToggle = true,
	WatermarkToggle = true,
	AnimationsToggle = true,
	BlurToggle = true,
	DecorToggle = true,
	InterfaceScale = true,
	AutosaveToggle = true,
	MiniButtonToggle = true,
	TooltipsToggle = true,
	NotifySide = true,
	FontChoice = true,
	CornerStyle = true,
	UIStyle = true,
	ColorBackground = true,
	ColorPanels = true,
	ColorControls = true,
	ColorOutline = true,
	ColorText = true,
	ColorTextDark = true,
}

local function SerializeConfigValue(v)
	if typeof(v) == "Color3" then
		return {Type = "Color3", Hex = v:ToHex()}
	elseif typeof(v) == "EnumItem" then
		local enumName = tostring(v.EnumType):match("Enum%.(.+)") or tostring(v.EnumType)
		return {Type = "EnumItem", EnumType = enumName, Name = v.Name}
	elseif type(v) == "table" then
		local out = {}
		for tk, tv in pairs(v) do out[tk] = SerializeConfigValue(tv) end
		return {Type = "Table", Value = out}
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
			local out = {}
			if type(value.Value) == "table" then
				for tk, tv in pairs(value.Value) do out[tk] = DeserializeConfigValue(tv) end
			end
			return out
		end
	end
	return value
end

function Library:SaveConfig(name)
	if not name or name == "" then return false end
	local data = {}
	for k, v in pairs(Library.Flags) do
		if not IgnoredFlags[k] then data[k] = SerializeConfigValue(v) end
	end
	local ok, json = pcall(HttpService.JSONEncode, HttpService, data)
	if not ok then return false end
	return (pcall(function() writefile(Config.ConfigFolder .. "/" .. name .. ".json", json) end))
end

function Library:LoadConfig(name)
	if not name or name == "" then return false end
	local path = Config.ConfigFolder .. "/" .. name .. ".json"
	if not isfile(path) then return false end
	local ok, data = pcall(HttpService.JSONDecode, HttpService, readfile(path))
	if not ok or type(data) ~= "table" then return false end
	for flag, value in pairs(data) do
		if not IgnoredFlags[flag] then Library.Flags[flag] = DeserializeConfigValue(value) end
	end
	for flag, value in pairs(Library.Flags) do
		if not IgnoredFlags[flag] and data[flag] ~= nil and Library.Signals[flag] then
			task.spawn(Library.Signals[flag], value)
		end
	end
	return true
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

local function InterfacePath()
	return Config.ConfigFolder .. "/_interface.json"
end

local function SaveInterface()
	local data = {
		Theme = Library.CurrentTheme,
		Accent = Library.CustomAccent and Library.CustomAccent:ToHex() or nil,
		Scale = Library.UserScale,
		Blur = Library.BlurEnabled,
		Watermark = Library.WatermarkEnabled,
		Decor = Library.DecorEnabled,
		Animations = Library.Animations,
		ShowKeybinds = Library.ShowKeybinds,
		MenuKey = Config.Keybind.Name,
		HideKey = Config.HideKeybind.Name,
		Style = Library.StyleName,
		Font = Library.FontName,
		Rounding = Library.Rounding,
		Tooltips = Library.TooltipsEnabled,
		NotifySide = Library.NotifySide,
		MiniButton = Library.MiniButtonEnabled,
		Colors = {},
	}
	for k, c in pairs(Library.CustomColors) do data.Colors[k] = c:ToHex() end
	pcall(function() writefile(InterfacePath(), HttpService:JSONEncode(data)) end)
end

local function LoadInterface()
	if not isfile(InterfacePath()) then return end
	local ok, data = pcall(function() return HttpService:JSONDecode(readfile(InterfacePath())) end)
	if not ok or type(data) ~= "table" then return end
	if type(data.Colors) == "table" then
		for k, hex in pairs(data.Colors) do
			if table.find(ThemeKeys, k) then pcall(function() Library.CustomColors[k] = Color3.fromHex(hex) end) end
		end
	end
	if Styles[data.Style] then
		Library.StyleName = data.Style
		Style = Styles[data.Style]
	end
	if FontChoices[data.Font] then
		Library.FontName = data.Font
		Config.FontMain, Config.FontBold = FontChoices[data.Font], FontChoices[data.Font]
	end
	if RoundingScale[data.Rounding] then Library.Rounding = data.Rounding end
	if type(data.Tooltips) == "boolean" then Library.TooltipsEnabled = data.Tooltips end
	if type(data.NotifySide) == "string" then Library.NotifySide = data.NotifySide end
	if type(data.MiniButton) == "boolean" then Library.MiniButtonEnabled = data.MiniButton end
	LoadPalette(Library.CurrentTheme)
	if Themes[data.Theme] then
		Library.CurrentTheme = data.Theme
		LoadPalette(data.Theme)
	end
	if type(data.Accent) == "string" then
		pcall(function()
			local c = Color3.fromHex(data.Accent)
			Library.CustomAccent = c
			Theme.Accent = c
			Theme.AccentText = Luminance(c) > 0.62 and Color3.fromRGB(20, 14, 8) or Color3.fromRGB(255, 255, 255)
			DeriveTheme()
		end)
	end
	if type(data.Scale) == "number" then Library.UserScale = math.clamp(data.Scale, 0.6, 1.4) end
	if type(data.Blur) == "boolean" then Library.BlurEnabled = data.Blur end
	if type(data.Watermark) == "boolean" then Library.WatermarkEnabled = data.Watermark end
	if type(data.Decor) == "boolean" then Library.DecorEnabled = data.Decor end
	if type(data.Animations) == "boolean" then Library.Animations = data.Animations end
	if type(data.ShowKeybinds) == "boolean" then Library.ShowKeybinds = data.ShowKeybinds end
	pcall(function() if data.MenuKey then Config.Keybind = Enum.KeyCode[data.MenuKey] end end)
	pcall(function() if data.HideKey then Config.HideKeybind = Enum.KeyCode[data.HideKey] end end)
end





local function BuildTooltip()
	local Gui = New("ScreenGui", {Name = "PhantomTooltip", IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 100, ResetOnSpawn = false, Parent = GetParent()})
	local Frame = New("Frame", {Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, Visible = false, Theme = {BackgroundColor3 = "Topbar"}, Parent = Gui})
	Corner(Frame, 4)
	local St = Stroke(Frame, "Stroke", 1)
	Padding(Frame, 6, 10, 6, 10)
	local Label = New("TextLabel", {Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY, TextSize = 13, TextWrapped = true, TextTransparency = 1, Parent = Frame})
	New("UISizeConstraint", {MaxSize = Vector2.new(260, 400), Parent = Label})
	Tooltip.Frame, Tooltip.Label, Tooltip.Stroke, Tooltip.Token = Frame, Label, St, 0
	Track(RunService.RenderStepped, function()
		if Frame.Visible then
			local m = UserInputService:GetMouseLocation()
			local target = UDim2.fromOffset(m.X + 14, m.Y + 14)
			Frame.Position = Frame.Position:Lerp(target, 0.35)
		end
	end)
end

local function HideTooltip()
	local f = Tooltip.Frame
	if not f then return end
	Tooltip.Token += 1
	local token = Tooltip.Token
	Tween(f, {BackgroundTransparency = 1}, 0.15)
	Tween(Tooltip.Stroke, {Transparency = 1}, 0.15)
	Tween(Tooltip.Label, {TextTransparency = 1}, 0.15).Completed:Connect(function()
		if Tooltip.Token == token then f.Visible = false end
	end)
end

local function ApplyTooltip(guiObj, text)
	if not text or text == "" then return end
	Track(guiObj.MouseEnter, function()
		local f = Tooltip.Frame
		if not f or not Library.TooltipsEnabled then return end
		Tooltip.Token += 1
		local token = Tooltip.Token
		task.delay(0.45, function()
			if Tooltip.Token ~= token or not Library.Open then return end
			Tooltip.Label.Text = text
			local m = UserInputService:GetMouseLocation()
			f.Position = UDim2.fromOffset(m.X + 14, m.Y + 14)
			f.Visible = true
			Tween(f, {BackgroundTransparency = 0.04}, 0.2)
			Tween(Tooltip.Stroke, {Transparency = 0.1}, 0.2)
			Tween(Tooltip.Label, {TextTransparency = 0}, 0.2)
		end)
	end)
	Track(guiObj.MouseLeave, HideTooltip)
end





local NotifyColors = {Info = "Accent", Success = "Success", Warning = "Warning", Error = "Danger"}
local NotifyIcons = {Info = "info", Success = "sparkles", Warning = "bell", Error = "skull"}
local NotifyOrder = 0

function Library:Notify(title, text, duration, kind)
	title = tostring(title or "Notice")
	text = tostring(text or "")
	duration = tonumber(duration) or 3
	local level = kind
	if not NotifyColors[level] then
		local lowered = string.lower(title .. " " .. text)
		level = (lowered:find("error") or lowered:find("fail")) and "Error" or (lowered:find("warn") and "Warning") or "Info"
	end
	Library:Log(level == "Success" and "Info" or level, title .. ": " .. text)

	local Gui = GetParent():FindFirstChild("PhantomNotifications")
	if not Gui then
		Gui = New("ScreenGui", {Name = "PhantomNotifications", IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 50, ResetOnSpawn = false, Enabled = not Library.UIHidden, Parent = GetParent()})
		local Holder = New("Frame", {Name = "Container", Size = UDim2.new(0, 290, 1, -32), Position = UDim2.new(1, -16, 0, 16), AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, Parent = Gui})
		ListLayout(Holder, 8, false, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
	end
	local Holder = Gui:FindFirstChild("Container")
	-- place the stack in the corner picked in Settings > General
	local side = Library.NotifySide or "Bottom right"
	local onRight = side:find("right") ~= nil
	local onTop = side:find("Top") ~= nil
	Holder.AnchorPoint = Vector2.new(onRight and 1 or 0, 0)
	Holder.Position = onRight and UDim2.new(1, -16, 0, 16) or UDim2.new(0, 16, 0, 16)
	local HolderList = Holder:FindFirstChildOfClass("UIListLayout")
	HolderList.HorizontalAlignment = onRight and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left
	HolderList.VerticalAlignment = onTop and Enum.VerticalAlignment.Top or Enum.VerticalAlignment.Bottom
	local offscreen = onRight and UDim2.new(1, 40, 0, 0) or UDim2.new(-1, -40, 0, 0)
	NotifyOrder += 1
	local colorKey = NotifyColors[level]

	local Slot = New("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, LayoutOrder = NotifyOrder, Parent = Holder})
	local Card = New("TextButton", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = offscreen, BackgroundTransparency = 0.03, Theme = {BackgroundColor3 = "Background"}, Parent = Slot})
	Corner(Card, 5)
	Stroke(Card, "Stroke", 0)
	local IconBg = New("Frame", {Size = UDim2.fromOffset(28, 28), Position = UDim2.fromOffset(8, 10), BackgroundTransparency = 1, Theme = {BackgroundColor3 = function() return Theme.Section:Lerp(Theme[colorKey], 0.18) end}, Parent = Card})
	Corner(IconBg, 4)
	IconImage(IconBg, NotifyIcons[level], 16, {Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Theme = {ImageColor3 = colorKey}})
	local Body = New("Frame", {Size = UDim2.new(1, -62, 0, 0), Position = UDim2.fromOffset(50, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = Card})
	Padding(Body, 9, 0, 12, 0)
	ListLayout(Body, 2)
	New("TextLabel", {Text = title, Font = Config.FontBold, TextSize = 14, Size = UDim2.new(1, 0, 0, 18), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = 1, Parent = Body})
	New("TextLabel", {Text = text, TextSize = 13, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, Theme = {TextColor3 = "TextDark"}, Parent = Body})

	local closed = false
	local function Close()
		if closed then return end
		closed = true
		Tween(Card, {Position = offscreen}, 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.3, function()
			Tween(Slot, {Size = UDim2.new(1, 0, 0, 0)}, 0.25).Completed:Connect(function() Slot:Destroy() end)
		end)
	end
	Card.MouseButton1Click:Connect(Close)

	task.defer(function()
		RunService.Heartbeat:Wait()
		if not Card.Parent then return end
		Tween(Slot, {Size = UDim2.new(1, 0, 0, Card.AbsoluteSize.Y)}, 0.3)
		Tween(Card, {Position = UDim2.new(0, 0, 0, 0)}, 0.5)
		task.delay(duration, Close)
	end)
end





function Library:InitWatermark()
	local Gui = New("ScreenGui", {Name = "PhantomWatermark", IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false, Enabled = not Library.UIHidden, Parent = GetParent()})
	local Frame = New("Frame", {Size = UDim2.fromOffset(0, 32), AutomaticSize = Enum.AutomaticSize.X, Position = UDim2.new(1, -16, 0, 12), AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 0.04, Active = true, Visible = Library.WatermarkEnabled, Theme = {BackgroundColor3 = "Background"}, Parent = Gui})
	Corner(Frame, 5)
	Stroke(Frame, "Stroke", 0)
	local Row = New("Frame", {Size = UDim2.fromOffset(0, 32), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Parent = Frame})
	Padding(Row, 0, 12, 0, 12)
	ListLayout(Row, 9, true, nil, Enum.VerticalAlignment.Center)
	local order = 0
	local function Next() order += 1 return order end
	New("ImageLabel", {Image = ASSET_LOGO, Size = UDim2.fromOffset(16, 16), ScaleType = Enum.ScaleType.Fit, LayoutOrder = Next(), Theme = {ImageColor3 = "Accent"}, Parent = Row})
	local function Chip(bold)
		return New("TextLabel", {Size = UDim2.fromOffset(0, 32), AutomaticSize = Enum.AutomaticSize.X, TextSize = 13, RichText = true, Font = bold and Config.FontBold or Config.FontMain, LayoutOrder = Next(), Parent = Row})
	end
	local function Dot()
		local d = New("Frame", {Size = UDim2.fromOffset(4, 4), LayoutOrder = Next(), Theme = {BackgroundColor3 = "TextMuted"}, Parent = Row})
		Corner(d, 2)
	end
	local Brand = Chip(true)
	Brand.Text = Config.Brand
	Dot()
	local Fps = Chip()
	Dot()
	local Ping = Chip()
	Dot()
	local Clock = Chip()
	MakeDraggable(Frame, Frame)
	Library.Watermark = Frame

	local frames, last = 0, 0
	Track(RunService.RenderStepped, function()
		frames += 1
		local now = os.clock()
		if now - last < 1 then return end
		local fps = frames
		frames = 0
		last = now
		local ping = "0"
		pcall(function()
			ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValueString():match("%d+") or "0"
		end)
		local dim = Theme.TextDark:ToHex()
		Fps.Text = string.format('%d <font color="#%s">fps</font>', fps, dim)
		Ping.Text = string.format('%s <font color="#%s">ms</font>', ping, dim)
		Clock.Text = os.date("%H:%M:%S")
	end)
end





local function BindHasKey(key)
	return key ~= nil and key ~= "None" and key ~= "Unknown" and key ~= ""
end

-- PC: every bound key shows up. Mobile: only toggles the user pinned show up, as tap buttons.
local function BindIsListed(entry)
	if IsTouchOnly() then return entry.MobilePinned == true and entry.Toggle ~= nil end
	return BindHasKey(entry.Key) and entry.Mode ~= "Always"
end

local function RefreshBindList()
	if not Library.KeybindList then return end
	local shown = 0
	local mobile = IsTouchOnly()
	for _, name in ipairs(Library.BindOrder) do
		local entry = Library.Binds[name]
		if entry and entry.Row then
			local listed = BindIsListed(entry)
			entry.Row.Visible = listed
			if listed then
				shown += 1
				entry.Row.LayoutOrder = shown
				local on = entry.Active
				if mobile then
					Tween(entry.NameLabel, {TextTransparency = on and 0 or 0.4}, 0.15)
					Tween(entry.Switch, {BackgroundColor3 = on and Theme.Accent or Theme.Container}, 0.15)
					Tween(entry.Ball, {AnchorPoint = Vector2.new(on and 1 or 0, 0), Position = UDim2.fromScale(on and 1 or 0, 0), BackgroundColor3 = on and Theme.AccentText or Theme.Text}, 0.15)
				else
					local mode = entry.Mode ~= "Toggle" and (" (" .. tostring(entry.Mode) .. ")") or ""
					local keyColor = on and Theme.Accent or Theme.TextDark
					entry.NameLabel.Text = string.format('<font color="#%s">[%s]</font> %s%s', keyColor:ToHex(), tostring(entry.Key), name, mode)
					Tween(entry.NameLabel, {TextTransparency = on and 0 or 0.45}, 0.15)
				end
			end
		end
	end
	Library.KeybindList.Title.Text = mobile and "Quick toggles" or "Keybinds"
	Library.KeybindList.Frame.Visible = Library.ShowKeybinds and shown > 0
end
Library.RefreshBindList = function() RefreshBindList() end

function Library:CreateKeybindList()
	if Library.KeybindList then return end
	local mobile = IsTouchOnly()
	local Screen = New("ScreenGui", {Name = "PrismaKeybinds", IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false, Enabled = not Library.UIHidden, Parent = GetParent()})
	local Frame = New("Frame", {Size = UDim2.fromOffset(mobile and 190 or 210, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.new(0, 16, 0.35, 0), Active = true, Visible = false, Theme = {BackgroundColor3 = "Background"}, Parent = Screen})
	Corner(Frame, 4)
	Stroke(Frame, "Stroke", 0)
	ListLayout(Frame, 0)
	local Header = New("Frame", {Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, LayoutOrder = 0, Parent = Frame})
	local Title = New("TextLabel", {Text = mobile and "Quick toggles" or "Keybinds", TextSize = 14, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = Header})
	New("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), Theme = {BackgroundColor3 = "Stroke"}, Parent = Header})
	local Container = New("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1, Parent = Frame})
	Padding(Container, 6, 8, 8, 8)
	ListLayout(Container, mobile and 4 or 2)
	MakeDraggable(Header, Frame)
	Library.KeybindList = {Frame = Frame, Container = Container, Screen = Screen, Title = Title}
	OnThemeChanged(RefreshBindList)
end

local function CreateBindRow(name, entry)
	local Container = Library.KeybindList.Container
	if IsTouchOnly() then
		-- big tap target: name + switch
		local Row = New("TextButton", {Name = name, Size = UDim2.new(1, 0, 0, 30), Visible = false, Theme = {BackgroundColor3 = "Container"}, Parent = Container})
		Corner(Row, 2)
		Stroke(Row, "Stroke", 0)
		local LName = New("TextLabel", {Text = name, TextSize = 14, TextTransparency = 0.4, Size = UDim2.new(1, -52, 1, 0), Position = UDim2.fromOffset(8, 0), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = Row})
		local Switch = New("Frame", {Size = UDim2.fromOffset(28, 16), Position = UDim2.new(1, -8, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), Theme = {BackgroundColor3 = "Container"}, Parent = Row})
		New("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Switch})
		Padding(Switch, 2, 2, 2, 2)
		Stroke(Switch, "Stroke", 0)
		local Ball = New("Frame", {Size = UDim2.fromScale(1, 1), SizeConstraint = Enum.SizeConstraint.RelativeYY, Theme = {BackgroundColor3 = "Text"}, Parent = Switch})
		New("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Ball})
		entry.Row, entry.NameLabel, entry.Switch, entry.Ball = Row, LName, Switch, Ball
		Track(Row.MouseButton1Click, function()
			if entry.Toggle then entry.Toggle() end
		end)
		return
	end
	local Row = New("TextButton", {Name = name, Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Visible = false, Parent = Container})
	local LName = New("TextLabel", {Text = name, TextSize = 14, RichText = true, TextTransparency = 0.45, Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = Row})
	entry.Row, entry.NameLabel = Row, LName
	Track(Row.MouseButton1Click, function()
		if entry.Toggle then entry.Toggle() end
	end)
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
		if data.MobilePinned ~= nil then entry.MobilePinned = data.MobilePinned end
		if data.Toggle ~= nil then entry.Toggle = data.Toggle end
	end
	RefreshBindList()
end

function Library:UpdateKeybindList(name, key, active, mode)
	Library:RegisterBind(name, {Key = key, Active = active, Mode = mode})
end





function Library:CreateConsole()
	if Library.Console then return Library.Console end
	local mobile = IsTouchOnly()
	local HEADER_H = 36
	local width, height = mobile and 320 or 460, mobile and 200 or 260
	local LevelNames = {Info = "INFO", Warning = "WARN", Error = "ERROR"}
	local logRows, rowOrder, open = {}, 0, true

	local function EscapeRich(str)
		return (str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
	end

	local Screen = New("ScreenGui", {Name = "PhantomConsole", IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false, Enabled = not Library.UIHidden, Parent = GetParent()})
	local Frame = New("Frame", {Name = "Console", Size = UDim2.fromOffset(width, height), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 20 + width / 2, 1, -(20 + height / 2)), Active = true, ClipsDescendants = true, Visible = false, BackgroundTransparency = 0.03, Theme = {BackgroundColor3 = "Background"}, Parent = Screen})
	Corner(Frame, 5)
	Stroke(Frame, "Stroke", 0)

	local Header = New("Frame", {Size = UDim2.new(1, 0, 0, HEADER_H), Active = true, Theme = {BackgroundColor3 = "Topbar"}, Parent = Frame})
	Corner(Header, 5)
	local HeaderFill = New("Frame", {Size = UDim2.new(1, 0, 0, 8), Position = UDim2.new(0, 0, 1, -8), Theme = {BackgroundColor3 = "Topbar"}, Parent = Header})
	local Divider = New("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.fromOffset(0, HEADER_H), Theme = {BackgroundColor3 = "Stroke"}, Parent = Frame})
	MakeDraggable(Header, Frame)

	local TitleRow = New("Frame", {Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1, Parent = Header})
	ListLayout(TitleRow, 8, true, nil, Enum.VerticalAlignment.Center)
	IconImage(TitleRow, "activity", 14, {LayoutOrder = 0, Theme = {ImageColor3 = "Accent"}})
	New("TextLabel", {Text = "Console", Font = Config.FontBold, TextSize = 14, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 1, Parent = TitleRow})
	local CountLabel = New("TextLabel", {Text = "0", Font = Config.FontBold, TextSize = 11, Size = UDim2.fromOffset(0, 18), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 0, LayoutOrder = 2, Theme = {BackgroundColor3 = "Container", TextColor3 = "TextDark"}, Parent = TitleRow})
	Corner(CountLabel, 9)
	Padding(CountLabel, 0, 7, 0, 7)

	local ArrowBtn = New("ImageButton", {Size = UDim2.fromOffset(22, 22), Position = UDim2.new(1, -8, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), Image = ASSET_CHEVRON, Theme = {ImageColor3 = "TextDark"}, Parent = Header})
	local function LinkButton(text, xOffset)
		local btn = New("TextButton", {Size = UDim2.new(0, 40, 1, 0), Position = UDim2.new(1, xOffset, 0, 0), AnchorPoint = Vector2.new(1, 0), Text = text, Font = Config.FontBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, Theme = {TextColor3 = "TextDark"}, Parent = Header})
		Track(btn.MouseEnter, function() Tween(btn, {TextColor3 = Theme.Text}, 0.15) end)
		Track(btn.MouseLeave, function() Tween(btn, {TextColor3 = Theme.TextDark}, 0.2) end)
		return btn
	end
	local ClearBtn = LinkButton("Clear", -36)
	local CopyBtn = LinkButton("Copy", -82)

	local LogBox = New("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -(HEADER_H + 1)), Position = UDim2.fromOffset(0, HEADER_H + 1), ScrollBarThickness = 3, Parent = Frame})
	Padding(LogBox, 8, 12, 14, 12)
	ListLayout(LogBox, 3)
	local EmptyLabel = New("TextLabel", {Size = UDim2.new(1, 0, 0, 18), Text = "No output yet", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 0, Theme = {TextColor3 = "TextMuted"}, Parent = LogBox})

	local Resizer = New("TextButton", {Size = UDim2.fromOffset(16, 16), Position = UDim2.fromScale(1, 1), AnchorPoint = Vector2.new(1, 1), ZIndex = 5, Parent = Frame})
	DecorLine(Resizer, 4, 13, 13, 4, "TextMuted", 0, 1)
	DecorLine(Resizer, 8, 13, 13, 8, "TextMuted", 0, 1)
	MakeResizable(Resizer, Frame, Vector2.new(280, 120))

	local function UpdateCount() CountLabel.Text = tostring(#Library.Logs) end

	local function AddLogRow(entry)
		rowOrder += 1
		local levelColor = entry.Level == "Error" and Theme.Danger or entry.Level == "Warning" and Theme.Warning or Theme.Accent
		local Line = New("TextLabel", {
			Name = "LogLine",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			RichText = true,
			Text = string.format('<font color="#%s">%s</font>  <font color="#%s">%s</font>  %s', Theme.TextMuted:ToHex(), entry.Time, levelColor:ToHex(), LevelNames[entry.Level], EscapeRich(entry.Text)),
			TextSize = 13,
			TextColor3 = LogColor(entry.Level),
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			LayoutOrder = rowOrder,
			Parent = LogBox,
		})
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
		Tween(ArrowBtn, {Rotation = open and 0 or -90}, 0.25)
		local t = Tween(Frame, {Size = UDim2.fromOffset(Frame.Size.X.Offset, open and expandedHeight or HEADER_H)}, 0.35)
		if not open then
			t.Completed:Connect(function()
				if not open then
					HeaderFill.Visible = false
					Divider.Visible = false
				end
			end)
		end
	end

	Track(ArrowBtn.MouseButton1Click, function() SetOpen(not open) end)
	Track(ArrowBtn.MouseEnter, function() Tween(ArrowBtn, {ImageColor3 = Theme.Text}, 0.15) end)
	Track(ArrowBtn.MouseLeave, function() Tween(ArrowBtn, {ImageColor3 = Theme.TextDark}, 0.2) end)
	Track(CopyBtn.MouseButton1Click, function()
		local lines = {}
		for _, entry in ipairs(Library.Logs) do
			table.insert(lines, entry.Time .. "  " .. LevelNames[entry.Level] .. "  " .. entry.Text)
		end
		local ok = pcall(function() setclipboard(table.concat(lines, "\n")) end)
		if ok then Library:Notify("Console", "Logs copied", 2, "Success") else Library:Notify("Console", "Clipboard not supported", 2, "Warning") end
	end)
	Track(ClearBtn.MouseButton1Click, function() Library:ClearLogs() end)
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





-- Obsidian-style sizing: short controls, thin outlines, small corners
local CTRL_H = 21
local SMALL_R = 2

local function SearchField(parent, placeholder, order, onChanged)
	local Box = New("Frame", {Size = UDim2.new(1, 0, 0, CTRL_H), LayoutOrder = order, Theme = {BackgroundColor3 = "Container"}, Parent = parent})
	Corner(Box, SMALL_R)
	local St = Stroke(Box, "Stroke", 0)
	IconImage(Box, "search", 12, {Position = UDim2.new(0, 6, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Theme = {ImageColor3 = "TextMuted"}})
	local Input = New("TextBox", {Size = UDim2.new(1, -28, 1, 0), Position = UDim2.fromOffset(24, 0), PlaceholderText = placeholder, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ClipsDescendants = true, Parent = Box})
	Track(Input.Focused, function() Tween(St, {Color = Theme.Accent}, 0.15) end)
	Track(Input.FocusLost, function() Tween(St, {Color = Theme.Stroke}, 0.2) end)
	Track(Input:GetPropertyChangedSignal("Text"), function()
		onChanged((Input.Text or ""):lower())
	end)
	return Box, Input
end

local function FilterButtons(buttons, query)
	for name, btn in pairs(buttons) do
		if btn and btn.Parent then
			btn.Visible = query == "" or tostring(name):lower():find(query, 1, true) ~= nil
		end
	end
end

local function KeyChip(parent, props)
	props.Parent = parent
	props.TextSize = 14
	props.AutomaticSize = Enum.AutomaticSize.X
	props.Theme = props.Theme or {BackgroundColor3 = "Container", TextColor3 = "TextDark"}
	local chip = New("TextButton", props)
	Corner(chip, SMALL_R)
	Padding(chip, 0, 5, 0, 5)
	New("UISizeConstraint", {MinSize = Vector2.new(24, 0), Parent = chip})
	local st = Stroke(chip, "Stroke", 0)
	return chip, st
end

local function FlatButton(parent, text, order, height)
	local b = New("TextButton", {Size = UDim2.new(1, 0, 0, height or CTRL_H), Text = text, TextSize = 14, LayoutOrder = order or 0, Theme = {BackgroundColor3 = "Container"}, Parent = parent})
	Corner(b, SMALL_R)
	local st = Stroke(b, "Stroke", 0)
	Interactive(b, st)
	New("UIGradient", {Rotation = 90, Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(205, 205, 210)), Theme = {Enabled = function() return Style.Gradient end}, Parent = b})
	return b, st
end

local function MakeListItem(parent, text, order, height)
	local b = New("TextButton", {
		Size = UDim2.new(1, 0, 0, height or CTRL_H), Text = tostring(text), TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
		BackgroundTransparency = 1, LayoutOrder = order, Parent = parent,
	})
	ThemeBind(b, {
		BackgroundColor3 = "Hover",
		TextColor3 = function() return b:GetAttribute("Sel") and Theme.Accent or Theme.TextDark end,
	})
	Corner(b, SMALL_R)
	Padding(b, 0, 6, 0, 8)
	Track(b.MouseEnter, function()
		Tween(b, {BackgroundTransparency = 0}, 0.12)
		if not b:GetAttribute("Sel") then Tween(b, {TextColor3 = Theme.Text}, 0.12) end
	end)
	Track(b.MouseLeave, function()
		Tween(b, {BackgroundTransparency = 1}, 0.18)
		if not b:GetAttribute("Sel") then Tween(b, {TextColor3 = Theme.TextDark}, 0.18) end
	end)
	return b
end

local function SetItemSelected(b, sel)
	sel = sel and true or false
	b:SetAttribute("Sel", sel)
	Tween(b, {TextColor3 = sel and Theme.Accent or Theme.TextDark}, 0.15)
end

local function ActionButton(parent, text, primary, props)
	props = props or {}
	props.Text = text
	props.TextSize = 14
	props.Parent = parent
	props.Theme = primary and {BackgroundColor3 = "Accent", TextColor3 = "AccentText"} or {BackgroundColor3 = "Container", TextColor3 = "Text"}
	local b = New("TextButton", props)
	Corner(b, SMALL_R)
	if primary then
		Track(b.MouseEnter, function() Tween(b, {BackgroundColor3 = Theme.Accent:Lerp(Theme.Text, 0.12)}, 0.12) end)
		Track(b.MouseLeave, function() Tween(b, {BackgroundColor3 = Theme.Accent}, 0.18) end)
	else
		Interactive(b, Stroke(b, "Stroke", 0))
	end
	return b
end

local function CreatePreviewController(VP, Cam)
	local ctrl = {Angle = 0, Pitch = 0.25, Zoom = 1, TargetZoom = 1, Model = nil, Dragging = false, ScrollFrame = nil}
	local dragStart, startAngle, startPitch = nil, 0, 0
	local ZoomBox = New("Frame", {Size = UDim2.fromOffset(CTRL_H, CTRL_H * 2 + 4), Position = UDim2.new(1, -6, 1, -6), AnchorPoint = Vector2.new(1, 1), BackgroundTransparency = 1, ZIndex = 5, Parent = VP})
	ListLayout(ZoomBox, 4)
	local function ZoomBtn(txt, order, delta)
		local b = FlatButton(ZoomBox, txt, order)
		b.Size = UDim2.fromOffset(CTRL_H, CTRL_H)
		b.ZIndex = 6
		Track(b.MouseButton1Click, function()
			ctrl.TargetZoom = math.clamp(ctrl.TargetZoom + delta, 0.4, 3)
		end)
	end
	ZoomBtn("+", 1, -0.25)
	ZoomBtn("-", 2, 0.25)

	local function InsideVP()
		local m = MousePos()
		local ap, sz = VP.AbsolutePosition, VP.AbsoluteSize
		return m.X >= ap.X and m.X <= ap.X + sz.X and m.Y >= ap.Y and m.Y <= ap.Y + sz.Y
	end
	local function LockScroll(state)
		local sf = ctrl.ScrollFrame
		if sf and sf.Parent then sf.ScrollingEnabled = not state end
	end
	Track(VP.InputBegan, function(input)
		if IsPress(input) then
			ctrl.Dragging = true
			dragStart = input.Position
			startAngle, startPitch = ctrl.Angle, ctrl.Pitch
			LockScroll(true)
		end
	end)
	Track(VP.MouseEnter, function() LockScroll(true) end)
	Track(VP.MouseLeave, function() if not ctrl.Dragging then LockScroll(false) end end)
	Track(UserInputService.InputChanged, function(input)
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
	Track(UserInputService.InputEnded, function(input)
		if IsPress(input) then
			ctrl.Dragging = false
			dragStart = nil
			LockScroll(false)
		end
	end)
	function ctrl:Reset()
		ctrl.Zoom, ctrl.TargetZoom, ctrl.Pitch, ctrl.Angle = 1, 1, 0.25, 0
	end
	function ctrl:Step(dt)
		local model = ctrl.Model
		if not model or not model.Parent then return end
		if not ctrl.Dragging then ctrl.Angle += dt * 0.6 end
		ctrl.Zoom += (ctrl.TargetZoom - ctrl.Zoom) * math.min(dt * 8, 1)
		pcall(function()
			local cf, size = model:GetBoundingBox()
			local center = cf.Position
			local dist = math.max(size.X, size.Y, size.Z, 1) * 2.8 * ctrl.Zoom
			local cp = math.cos(ctrl.Pitch)
			local camPos = center + Vector3.new(math.cos(ctrl.Angle) * dist * cp, math.sin(ctrl.Pitch) * dist + size.Y * 0.1, math.sin(ctrl.Angle) * dist * cp)
			Cam.CFrame = CFrame.lookAt(camPos, center)
		end)
	end
	return ctrl
end

----------------------------------------------------------------------------------------------------
-- Dropdown: label on top, 21px box, list opens underneath and pushes the content down
----------------------------------------------------------------------------------------------------

local function CreateDropdownElement(text, flag, options, default, tooltipText, callback, parentFrame, sectionRef, isMulti, customParent, layoutOrder)
	options = options or {}
	callback = WrapCallback(text, callback, false)
	local selected = Library.Flags[flag]
	if selected == nil then
		if isMulti then
			if type(default) == "table" then selected = default
			elseif default ~= nil then selected = {default}
			else selected = {} end
		else
			if default ~= nil then selected = default else selected = options[1] end
		end
	end
	Library.Defaults[flag] = selected
	Library.Flags[flag] = selected

	local hasLabel = type(text) == "string" and text ~= ""
	local TOPH = hasLabel and 18 or 0
	local HEAD = TOPH + CTRL_H
	local isOpen = false

	local Holder = New("Frame", {Size = UDim2.new(1, 0, 0, HEAD), BackgroundTransparency = 1, LayoutOrder = layoutOrder or 0, Parent = customParent or parentFrame})
	if hasLabel then
		New("TextLabel", {Text = text, Size = UDim2.new(1, 0, 0, 14), TextSize = 14, TextTruncate = Enum.TextTruncate.AtEnd, Theme = {TextXAlignment = LabelAlign}, Parent = Holder})
	end
	local Box = New("TextButton", {Size = UDim2.new(1, 0, 0, CTRL_H), Position = UDim2.fromOffset(0, TOPH), Theme = {BackgroundColor3 = "Container"}, Parent = Holder})
	New("UIGradient", {Rotation = 90, Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(205, 205, 210)), Theme = {Enabled = function() return Style.Gradient end}, Parent = Box})
	Corner(Box, SMALL_R)
	local BoxStroke = Stroke(Box, "Stroke", 0)
	local Value = New("TextLabel", {Size = UDim2.new(1, -30, 1, 0), Position = UDim2.fromOffset(8, 0), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = Box})
	local Arrow = New("ImageLabel", {Image = ASSET_CHEVRON, Size = UDim2.fromOffset(16, 16), Position = UDim2.new(1, -4, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), Theme = {ImageColor3 = "TextDark"}, Parent = Box})

	local ListBox = New("Frame", {Size = UDim2.new(1, 0, 0, 0), Position = UDim2.fromOffset(0, HEAD + 3), ClipsDescendants = true, Visible = false, Theme = {BackgroundColor3 = "Container"}, Parent = Holder})
	Corner(ListBox, SMALL_R)
	Stroke(ListBox, "Stroke", 0)
	local ListFrame = New("ScrollingFrame", {Size = UDim2.fromScale(1, 1), Active = true, ScrollBarThickness = 2, Parent = ListBox})
	ListLayout(ListFrame, 0)

	local SearchBox
	local query = ""
	local optionRows = {}

	local function IsSelected(opt)
		if isMulti then return table.find(selected, opt) ~= nil end
		return selected == opt
	end

	local function UpdateVisuals()
		if isMulti then
			local parts = {}
			for _, v in ipairs(selected) do table.insert(parts, tostring(v)) end
			Value.Text = #parts > 0 and table.concat(parts, ", ") or "---"
		else
			Value.Text = selected == nil and "---" or tostring(selected)
		end
		for _, row in ipairs(optionRows) do row.SetSelected(IsSelected(row.Option)) end
	end

	local function ListHeights()
		local visible = 0
		for _, row in ipairs(optionRows) do
			if row.Button.Visible then visible += 1 end
		end
		local searchH = (SearchBox and SearchBox.Parent.Visible) and CTRL_H or 0
		local listH = math.min(math.max(visible, 1), 8) * CTRL_H
		return searchH, listH
	end

	local function Layout(animate)
		local searchH, listH = ListHeights()
		ListFrame.Position = UDim2.fromOffset(0, searchH)
		ListFrame.Size = UDim2.new(1, 0, 0, listH)
		local boxH = isOpen and (searchH + listH) or 0
		local total = isOpen and (HEAD + 3 + boxH + 1) or HEAD
		if isOpen then ListBox.Visible = true end
		if animate then
			Tween(Holder, {Size = UDim2.new(1, 0, 0, total)}, 0.25)
			Tween(ListBox, {Size = UDim2.new(1, 0, 0, boxH)}, 0.25).Completed:Connect(function()
				if not isOpen then ListBox.Visible = false end
			end)
		else
			Holder.Size = UDim2.new(1, 0, 0, total)
			ListBox.Size = UDim2.new(1, 0, 0, boxH)
			ListBox.Visible = isOpen
		end
	end

	local function SetOpen(state)
		isOpen = state
		Tween(Arrow, {Rotation = isOpen and 180 or 0}, 0.25)
		Tween(BoxStroke, {Color = isOpen and Theme.Accent or Theme.Stroke}, 0.2)
		Layout(true)
	end

	local function BuildOptions(newOptions)
		for _, row in ipairs(optionRows) do row.Button:Destroy() end
		table.clear(optionRows)
		options = newOptions or {}
		if #options > 7 and not SearchBox then
			local box
			box, SearchBox = SearchField(ListBox, "Search...", 0, function(q)
				query = q
				for _, row in ipairs(optionRows) do
					row.Button.Visible = q == "" or tostring(row.Option):lower():find(q, 1, true) ~= nil
				end
				Layout(false)
			end)
			box.Size = UDim2.new(1, 0, 0, CTRL_H)
			box.BackgroundTransparency = 1
			box:FindFirstChildOfClass("UIStroke").Transparency = 1
		end
		for i, opt in ipairs(options) do
			local sel = false
			local Row = New("TextButton", {Size = UDim2.new(1, 0, 0, CTRL_H), BackgroundTransparency = 1, LayoutOrder = i, Theme = {BackgroundColor3 = "Hover"}, Parent = ListFrame})
			local Txt = New("TextLabel", {Text = tostring(opt), TextSize = 14, Size = UDim2.new(1, -16, 1, 0), Position = UDim2.fromOffset(8, 0), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Theme = {TextColor3 = function() return sel and Theme.Accent or Theme.TextDark end}, Parent = Row})
			local row = {Button = Row, Option = opt}
			function row.SetSelected(s)
				if s == sel then return end
				sel = s
				Tween(Txt, {TextColor3 = s and Theme.Accent or Theme.TextDark}, 0.15)
			end
			Track(Row.MouseEnter, function()
				Tween(Row, {BackgroundTransparency = 0}, 0.1)
				if not sel then Tween(Txt, {TextColor3 = Theme.Text}, 0.1) end
			end)
			Track(Row.MouseLeave, function()
				Tween(Row, {BackgroundTransparency = 1}, 0.15)
				if not sel then Tween(Txt, {TextColor3 = Theme.TextDark}, 0.15) end
			end)
			Track(Row.MouseButton1Click, function()
				if isMulti then
					local found = table.find(selected, opt)
					if found then table.remove(selected, found) else table.insert(selected, opt) end
				else
					selected = opt
				end
				Library.Flags[flag] = selected
				Library.Unsaved = true
				UpdateVisuals()
				callback(selected)
				if not isMulti then SetOpen(false) end
			end)
			if query ~= "" then Row.Visible = tostring(opt):lower():find(query, 1, true) ~= nil end
			table.insert(optionRows, row)
		end
		if SearchBox then SearchBox.Parent.Visible = #options > 7 end
		Layout(false)
	end

	BuildOptions(options)
	UpdateVisuals()

	Track(Box.MouseButton1Click, function() SetOpen(not isOpen) end)
	Track(Box.MouseEnter, function() Tween(Box, {BackgroundColor3 = Theme.Hover}, 0.12) end)
	Track(Box.MouseLeave, function() Tween(Box, {BackgroundColor3 = Theme.Container}, 0.18) end)

	Library.Signals[flag] = function(val)
		if isMulti then
			selected = type(val) == "table" and val or {val}
		else
			selected = val
		end
		UpdateVisuals()
		Library.Unsaved = true
		callback(selected)
	end

	ApplyTooltip(Holder, tooltipText)
	task.spawn(callback, selected)

	local DropdownObj = {Frame = Holder}
	function DropdownObj:Refresh(newOptions, newDefault)
		if isMulti then
			selected = type(newDefault) == "table" and newDefault or (newDefault ~= nil and {newDefault} or {})
		else
			if newDefault ~= nil then selected = newDefault else selected = (newOptions and newOptions[1]) end
		end
		Library.Flags[flag] = selected
		BuildOptions(newOptions)
		UpdateVisuals()
		if isOpen then Layout(true) end
	end
	function DropdownObj:GetSelected()
		return selected
	end
	function DropdownObj:Set(val)
		if isMulti then
			selected = type(val) == "table" and val or {val}
		else
			selected = val
		end
		Library.Flags[flag] = selected
		UpdateVisuals()
		callback(selected)
	end
	return DropdownObj
end

----------------------------------------------------------------------------------------------------
-- Slider: label on top, 15px bar with the value written inside it
-- right click the bar to type an exact value
----------------------------------------------------------------------------------------------------

-- Slider shapes (Style.Slider):
--   "bar"    Obsidian: label on top, 15px bar with "value/max" written inside, right click to type
--   "thin"   Fluent:   label left, value + 4px rail + round thumb on the right
--   "og"     OG:       label left, value top right, 6px bar underneath
--   "capsule" Modern:  one rounded pill; gradient fill, name inside on the left, value inside on the right
local function CreateSliderElement(text, flag, min, max, default, increment, tooltipText, callback, parentFrame, addItem, layoutOrder, compact)
	increment = increment or 1
	callback = WrapCallback(text, callback, false)
	local val = Library.Flags[flag]
	if val == nil then val = default or min end
	val = math.clamp(RoundToIncrement(val, increment), min, max)
	Library.Defaults[flag] = val
	Library.Flags[flag] = val
	local range = max - min
	local function Shape() return Style.Slider or "bar" end
	local function Is(name) return function() return Shape() == name end end
	local function Ratio() return range > 0 and (val - min) / range or 0 end
	local heights = {bar = compact and 15 or 33, thin = 18, og = 30, capsule = 30}

	local Frame = New("Frame", {BackgroundTransparency = 1, LayoutOrder = layoutOrder or 0, Theme = {
		Size = function() return UDim2.new(1, 0, 0, heights[Shape()] or 33) end,
	}, Parent = parentFrame})
	if addItem then addItem(text, Frame) end
	if not compact then
		New("TextLabel", {Text = text, TextSize = 14, TextTruncate = Enum.TextTruncate.AtEnd, Theme = {
			Visible = function() return Shape() ~= "capsule" end,
			Size = function()
				local sh = Shape()
				if sh == "thin" then return UDim2.new(0.45, 0, 1, 0) end
				if sh == "og" then return UDim2.new(1, -60, 0, 16) end
				return UDim2.new(1, 0, 0, 14)
			end,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, Parent = Frame})
	end

	-- bar
	local Bar = New("TextButton", {Size = UDim2.new(1, 0, 0, 15), Position = UDim2.new(0, 0, 1, -15), Theme = {BackgroundColor3 = "Container", Visible = Is("bar")}, Parent = Frame})
	Corner(Bar, SMALL_R)
	local St = Stroke(Bar, "Stroke", 0)
	local Fill = New("Frame", {Size = UDim2.new(Ratio(), 0, 1, 0), Theme = {BackgroundColor3 = "Accent"}, Parent = Bar})
	Corner(Fill, SMALL_R)
	local Display = New("TextLabel", {Size = UDim2.fromScale(1, 1), TextSize = 14, ZIndex = 2, Theme = {TextColor3 = "Text"}, Parent = Bar})
	New("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual, Color = Color3.new(0, 0, 0), Transparency = 0.4, Parent = Display})
	local Input = New("TextBox", {Size = UDim2.fromScale(1, 1), TextSize = 14, ZIndex = 3, Visible = false, BackgroundTransparency = 0, Theme = {BackgroundColor3 = "Container"}, Parent = Bar})
	Corner(Input, SMALL_R)

	-- thin
	local ThinWrap = New("Frame", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = compact and UDim2.fromScale(1, 1) or UDim2.new(0.55, 0, 1, 0), Theme = {Visible = Is("thin")}, Parent = Frame})
	local ThinValue = New("TextBox", {Size = UDim2.new(0, 46, 1, 0), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, Theme = {TextColor3 = "TextDark"}, Parent = ThinWrap})
	local Rail = New("Frame", {Size = UDim2.new(1, -62, 0, 4), Position = UDim2.new(0, 56, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Theme = {BackgroundColor3 = "Container"}, Parent = ThinWrap})
	New("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Rail})
	local RailFill = New("Frame", {Size = UDim2.new(Ratio(), 0, 1, 0), Theme = {BackgroundColor3 = "Accent"}, Parent = Rail})
	New("UICorner", {CornerRadius = UDim.new(1, 0), Parent = RailFill})
	local Thumb = New("Frame", {Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(Ratio(), 0, 0.5, 0), ZIndex = 2, Theme = {BackgroundColor3 = "Accent"}, Parent = Rail})
	New("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Thumb})
	New("UIStroke", {Thickness = 2, Theme = {Color = "Card"}, Parent = Thumb})
	local RailHit = New("TextButton", {Size = UDim2.new(1, -56, 1, 0), Position = UDim2.fromOffset(56, 0), Parent = ThinWrap})

	-- og
	local OgValue = New("TextBox", {Size = UDim2.new(0, 56, 0, 16), Position = UDim2.fromScale(1, 0), AnchorPoint = Vector2.new(1, 0), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right, Theme = {Visible = Is("og")}, Parent = Frame})
	local OgBar = New("Frame", {Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 1, -6), Theme = {BackgroundColor3 = "Container", Visible = Is("og")}, Parent = Frame})
	New("UICorner", {CornerRadius = UDim.new(0, 3), Parent = OgBar})
	Stroke(OgBar, "Stroke", 0.5)
	local OgFill = New("Frame", {Size = UDim2.new(Ratio(), 0, 1, 0), Theme = {BackgroundColor3 = "Accent"}, Parent = OgBar})
	New("UICorner", {CornerRadius = UDim.new(0, 3), Parent = OgFill})
	local OgHit = New("TextButton", {Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -10), Theme = {Visible = Is("og")}, Parent = Frame})

	-- capsule
	local Capsule = New("TextButton", {Size = UDim2.new(1, 0, 0, 30), Theme = {BackgroundColor3 = "Container", Visible = Is("capsule")}, Parent = Frame})
	New("UICorner", {CornerRadius = UDim.new(0, 9), Parent = Capsule})
	local CFill = New("Frame", {Size = UDim2.new(Ratio(), 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.1, Parent = Capsule})
	New("UICorner", {CornerRadius = UDim.new(0, 9), Parent = CFill})
	New("UIGradient", {Theme = {Color = function() return ColorSequence.new(Theme.Accent, Theme.Accent2) end}, Parent = CFill})
	New("TextLabel", {Text = text, TextSize = 14, Size = UDim2.new(1, -80, 1, 0), Position = UDim2.fromOffset(12, 0), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3, Parent = Capsule})
	local CValue = New("TextBox", {Size = UDim2.new(0, 60, 1, 0), Position = UDim2.new(1, -12, 0, 0), AnchorPoint = Vector2.new(1, 0), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 3, Parent = Capsule})
	Track(Capsule.MouseEnter, function() Tween(Capsule, {BackgroundColor3 = Theme.Hover}, 0.15) end)
	Track(Capsule.MouseLeave, function() Tween(Capsule, {BackgroundColor3 = Theme.Container}, 0.2) end)

	local tracks = {bar = Bar, thin = Rail, og = OgBar, capsule = Capsule}
	local valueBoxes = {ThinValue, OgValue, CValue}

	local function Render(t)
		local r = Ratio()
		for _, f in ipairs({Fill, RailFill, OgFill, CFill}) do Tween(f, {Size = UDim2.new(r, 0, 1, 0)}, t) end
		Tween(Thumb, {Position = UDim2.new(r, 0, 0.5, 0)}, t)
		local shown = FormatNumber(val, increment) .. "/" .. FormatNumber(max, increment)
		Display.Text = compact and (text .. ": " .. shown) or shown
		for _, box in ipairs(valueBoxes) do
			if not box:IsFocused() then box.Text = FormatNumber(val, increment) end
		end
	end
	Render(0)
	local function Commit(nv)
		nv = math.clamp(RoundToIncrement(nv, increment), min, max)
		if nv == val then return end
		val = nv
		Library.Flags[flag] = val
		Library.Unsaved = true
		callback(val)
	end
	local function SetFromInput(input)
		local track = tracks[Shape()] or Bar
		local r = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		Commit(min + range * r)
		Render(0.08)
	end
	local function StartDrag(input)
		if not IsPress(input) then return end
		SetFromInput(input)
		Tween(Thumb, {Size = UDim2.fromOffset(15, 15)}, 0.12)
		BeginDrag(input, SetFromInput, function() Tween(Thumb, {Size = UDim2.fromOffset(12, 12)}, 0.15) end)
	end

	Track(Bar.MouseEnter, function() Tween(St, {Color = Theme.StrokeHover}, 0.15) end)
	Track(Bar.MouseLeave, function() Tween(St, {Color = Theme.Stroke}, 0.2) end)
	for _, hit in ipairs({Bar, RailHit, OgHit, Capsule}) do Track(hit.InputBegan, StartDrag) end
	Track(Bar.MouseButton2Click, function()
		Input.Text = FormatNumber(val, increment)
		Input.Visible = true
		Input:CaptureFocus()
	end)
	local function Typed(box, enter)
		if enter then
			local num = tonumber((string.gsub(box.Text, "[^%d%.%-]", "")))
			if num then Commit(num) end
		end
		box.Text = FormatNumber(val, increment)
		Render(0.2)
	end
	Track(Input.FocusLost, function(enter)
		Input.Visible = false
		Typed(Input, enter)
	end)
	for _, box in ipairs(valueBoxes) do
		Track(box.FocusLost, function(enter) Typed(box, enter) end)
	end

	Library.Signals[flag] = function(loaded)
		if type(loaded) ~= "number" then return end
		val = math.clamp(RoundToIncrement(loaded, increment), min, max)
		Library.Flags[flag] = val
		Render(0.2)
		Library.Unsaved = true
		callback(val)
	end

	ApplyTooltip(Frame, tooltipText)
	task.spawn(callback, val)
	return Frame
end

----------------------------------------------------------------------------------------------------
-- Groupbox + elements
----------------------------------------------------------------------------------------------------

local function CreateSectionFrame(text, parent, order)
	-- GroupPanel styles box the section; the others just show a title above the cards
	local function panel(a, b) return function() if Style.GroupPanel then return a end return b end end
	local Container = New("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order or 0, Theme = {BackgroundColor3 = "Section", BackgroundTransparency = panel(0, 1)}, Parent = parent})
	Corner(Container, 4)
	New("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Theme = {Color = "Stroke", Transparency = function() return Style.GroupPanel and (Style.PanelStrokeT or 0) or 1 end}, Parent = Container})
	ListLayout(Container, 0)
	local Header = New("Frame", {BackgroundTransparency = 1, LayoutOrder = 0, Theme = {Size = panel(UDim2.new(1, 0, 0, 32), UDim2.new(1, 0, 0, 26))}, Parent = Container})
	local Title = New("TextLabel", {Text = tostring(text), Size = UDim2.new(1, -20, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Theme = {
		TextSize = function() return Style.TitleSize or 15 end,
		TextColor3 = function() return Style.TitleDim and Theme.TextDark or Theme.Text end,
		Position = panel(UDim2.fromOffset(10, 0), UDim2.fromOffset(2, 0)),
	}, Parent = Header})
	New("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), Theme = {BackgroundColor3 = "Stroke", BackgroundTransparency = function() return (Style.GroupPanel and Style.GroupLine) and 0 or 1 end}, Parent = Header})
	local Content = New("Frame", {Name = "Content", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1, Parent = Container})
	New("UIPadding", {Theme = {
		PaddingTop = panel(UDim.new(0, 8), UDim.new(0, 2)),
		PaddingBottom = panel(UDim.new(0, 10), UDim.new(0, 4)),
		PaddingLeft = panel(UDim.new(0, 10), UDim.new(0, 0)),
		PaddingRight = panel(UDim.new(0, 10), UDim.new(0, 0)),
	}, Parent = Content})
	ListLayout(Content, 7)
	return Container, Content, Title
end

-- ctx: {SectionName, Bindable, AddItem(name, inst), Page, OpenMenu, MakeFull}
local function AttachElements(Section, Content, ctx)
	local order = 0
	local function NextOrder()
		order += 1
		return order
	end
	Section.Content = Content
	Section._NextOrder = NextOrder
	local AddItem = ctx.AddItem or function() end

	-- every element lives in a cell; card styles turn the cell into a card
	local function Cell()
		local c = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = NextOrder(),
			Theme = {BackgroundColor3 = "Card", BackgroundTransparency = function() return Style.Cards and Style.CardT or 1 end},
			Parent = Content,
		})
		Corner(c, 4)
		New("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Theme = {Color = "Stroke", Transparency = function() return Style.Cards and Style.CardStrokeT or 1 end}, Parent = c})
		local function pad() return UDim.new(0, Style.Cards and Style.CardPad or 0) end
		New("UIPadding", {Theme = {PaddingTop = pad, PaddingBottom = pad, PaddingLeft = pad, PaddingRight = pad}, Parent = c})
		ListLayout(c, 6)
		Track(c.MouseEnter, function()
			if Style.Cards then Tween(c, {BackgroundColor3 = Theme.Card:Lerp(Theme.Text, 0.04)}, 0.12) end
		end)
		Track(c.MouseLeave, function()
			if Style.Cards then Tween(c, {BackgroundColor3 = Theme.Card}, 0.18) end
		end)
		return c
	end

	function Section:Label(ltext, options)
		options = options or {}
		local LabelObj = {}
		local Lbl = New("TextLabel", {
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			Text = tostring(ltext), RichText = true, TextWrapped = true, TextSize = 14,
			TextXAlignment = options.Alignment or Enum.TextXAlignment.Left,
			TextColor3 = options.Color,
			Parent = Cell(),
		})
		AddItem(ltext, Lbl)
		function LabelObj:Set(newText) Lbl.Text = tostring(newText) end
		function LabelObj:SetColor(newColor)
			if Bound[Lbl] then Bound[Lbl].TextColor3 = nil end
			Tween(Lbl, {TextColor3 = newColor}, 0.2)
		end
		LabelObj.Instance = Lbl
		return LabelObj
	end

	function Section:Divider()
		return New("Frame", {Size = UDim2.new(1, 0, 0, 1), LayoutOrder = NextOrder(), Theme = {BackgroundColor3 = "Stroke"}, Parent = Content})
	end

	-- "+ text" / "~ text" / "- text" lines, used by the changelog
	function Section:Bullet(ltext, col)
		local Frame = New("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = NextOrder(), Parent = Content})
		AddItem(ltext, Frame)
		local sign, key = "-", "TextMuted"
		if col == "added" then sign, key = "+", "Success" elseif col == "fixed" then sign, key = "~", "Accent" end
		New("TextLabel", {Text = sign, TextSize = 14, Size = UDim2.fromOffset(12, 16), TextXAlignment = Enum.TextXAlignment.Left, Theme = {TextColor3 = key}, Parent = Frame})
		New("TextLabel", {Size = UDim2.new(1, -16, 0, 0), Position = UDim2.fromOffset(16, 0), AutomaticSize = Enum.AutomaticSize.Y, Text = tostring(ltext), TextSize = 14, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Theme = {TextColor3 = "TextDark"}, Parent = Frame})
	end

	-- read-only "label .... value" line, value can be updated with :Set
	function Section:Row(text, value)
		local RowObj = {Value = tostring(value or "")}
		local Frame = New("Frame", {Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, LayoutOrder = NextOrder(), Parent = Content})
		AddItem(text, Frame)
		New("TextLabel", {Text = text, TextSize = 14, Size = UDim2.new(0.5, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Theme = {TextColor3 = "TextDark"}, Parent = Frame})
		local Val = New("TextLabel", {Text = RowObj.Value, TextSize = 14, Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.fromScale(0.5, 0), TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd, Parent = Frame})
		function RowObj:Set(v)
			RowObj.Value = tostring(v)
			Val.Text = RowObj.Value
		end
		return RowObj
	end

	function Section:Button(text, tooltipText, callback)
		local Btn = FlatButton(Cell(), text, 0)
		AddItem(text, Btn)
		-- on a card the card itself is the button look
		ThemeBind(Btn, {
			BackgroundTransparency = function() return Style.Cards and 1 or 0 end,
			TextXAlignment = function() return Style.ButtonCenter and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left end,
		})
		ThemeBind(Btn:FindFirstChildOfClass("UIStroke"), {Transparency = function() return Style.Cards and 1 or Style.StrokeT end})
		Track(Btn.MouseButton1Click, WrapCallback(text, callback, false))
		ApplyTooltip(Btn, tooltipText)
		return Btn
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
		Library.Signals[flag] = function(v)
			if toggled ~= v then
				toggled = v
				if ToggleObj.UpdateAnim then ToggleObj.UpdateAnim() end
				Library.Unsaved = true
				quietCallback(v)
			end
		end

		local ToggleCell = Cell()
		local Btn = New("TextButton", {Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, LayoutOrder = 1, Parent = ToggleCell})
		AddItem(text, Btn)
		local Label = New("TextLabel", {Text = text, Size = UDim2.new(1, -42, 1, 0), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = Btn})
		ThemeBind(Label, {TextTransparency = function() return toggled and 0 or Style.Dim end})
		local Switch = New("Frame", {Size = UDim2.fromOffset(32, 18), Position = UDim2.fromScale(1, 0), AnchorPoint = Vector2.new(1, 0), Theme = {
			BackgroundColor3 = function() return toggled and Theme.Accent or Theme.Container end,
			Visible = function() return Style.Toggle ~= "check" end,
		}, Parent = Btn})
		New("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Switch})
		Padding(Switch, 2, 2, 2, 2)
		local SStroke = Stroke(Switch, function() return toggled and Theme.Accent or Theme.Stroke end, 0)
		local Ball = New("Frame", {
			Size = UDim2.fromScale(1, 1), SizeConstraint = Enum.SizeConstraint.RelativeYY,
			AnchorPoint = Vector2.new(toggled and 1 or 0, 0), Position = UDim2.fromScale(toggled and 1 or 0, 0),
			Theme = {BackgroundColor3 = function() return toggled and Theme.AccentText or Theme.Text end},
			Parent = Switch,
		})
		New("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Ball})
		-- OG checkbox
		local Check = New("Frame", {Size = UDim2.fromOffset(18, 18), Position = UDim2.fromScale(1, 0), AnchorPoint = Vector2.new(1, 0), Theme = {BackgroundColor3 = "Background", Visible = function() return Style.Toggle == "check" end}, Parent = Btn})
		Corner(Check, 4)
		Stroke(Check, "Stroke", 0)
		local CheckFill = New("Frame", {Size = UDim2.new(1, -6, 1, -6), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = toggled and 0 or 1, Theme = {BackgroundColor3 = "Accent"}, Parent = Check})
		Corner(CheckFill, 2)

		Track(Btn.MouseEnter, function()
			if not toggled then Tween(Label, {TextTransparency = math.min(0.15, Style.Dim)}, 0.12) end
		end)
		Track(Btn.MouseLeave, function()
			Tween(Label, {TextTransparency = toggled and 0 or Style.Dim}, 0.18)
		end)

		-- children of the toggle (AddButton / AddSlider / AddDropdown), shown while it is on
		local Sub = New("Frame", {Name = "Sub" .. text, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true, Visible = false, LayoutOrder = 2, Parent = ToggleCell})
		local Inner = New("Frame", {Size = UDim2.new(1, -14, 0, 0), Position = UDim2.fromOffset(12, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = Sub})
		Padding(Inner, 1, 0, 1, 0)
		local SubList = ListLayout(Inner, 7)
		local subOrder = 0
		local function SubOrder()
			subOrder += 1
			return subOrder
		end
		local function SubHeight()
			local h = SubList.AbsoluteContentSize.Y / UIScaleValue()
			if h > 0 then h += 2 end
			return h
		end

		local currentTween
		local function ToggleAnim()
			if currentTween then currentTween:Cancel() end
			Library.Flags[flag] = toggled
			Tween(Switch, {BackgroundColor3 = toggled and Theme.Accent or Theme.Container}, 0.2)
			Tween(SStroke, {Color = toggled and Theme.Accent or Theme.Stroke}, 0.2)
			Tween(Label, {TextTransparency = toggled and 0 or Style.Dim}, 0.2)
			Tween(CheckFill, {BackgroundTransparency = toggled and 0 or 1}, 0.15)
			Tween(Ball, {
				AnchorPoint = Vector2.new(toggled and 1 or 0, 0),
				Position = UDim2.fromScale(toggled and 1 or 0, 0),
				BackgroundColor3 = toggled and Theme.AccentText or Theme.Text,
			}, 0.2)
			if ToggleObj.BindName then Library:RegisterBind(ToggleObj.BindName, {Active = toggled}) end
			if ToggleObj.RefreshKeyBtn then ToggleObj.RefreshKeyBtn() end
			if subOrder == 0 then return end
			if toggled then
				Sub.Visible = true
				Sub.ClipsDescendants = true
				currentTween = Tween(Sub, {Size = UDim2.new(1, 0, 0, SubHeight())}, 0.3)
				local thisTween = currentTween
				thisTween.Completed:Connect(function(state)
					if state == Enum.PlaybackState.Completed and toggled and currentTween == thisTween then Sub.ClipsDescendants = false end
				end)
			else
				Sub.ClipsDescendants = true
				currentTween = Tween(Sub, {Size = UDim2.new(1, 0, 0, 0)}, 0.25)
				local thisTween = currentTween
				thisTween.Completed:Connect(function(state)
					if state == Enum.PlaybackState.Completed and not toggled and currentTween == thisTween then Sub.Visible = false end
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

		Track(SubList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			if toggled and subOrder > 0 then
				Sub.Visible = true
				Sub.Size = UDim2.new(1, 0, 0, SubHeight())
			end
		end)

		local keyFlag, bindKey, bindMode, hasSavedBind, PushBind, SetBindMode
		if bindable and ctx.Bindable and not IsTouchOnly() then
			local bindName = text
			if Library.Binds[bindName] then bindName = text .. " (" .. tostring(ctx.SectionName) .. ")" end
			ToggleObj.BindName = bindName
			keyFlag = flag .. "_Keybind"
			local savedBind = Library.Flags[keyFlag]
			hasSavedBind = type(savedBind) == "table" and savedBind.Key ~= nil
			bindKey = hasSavedBind and savedBind.Key or Enum.KeyCode.Unknown
			bindMode = (hasSavedBind and savedBind.Mode) or "Toggle"
			Library.Defaults[keyFlag] = {Key = Enum.KeyCode.Unknown, Mode = "Toggle"}
			Library.Flags[keyFlag] = {Key = bindKey, Mode = bindMode}
			ToggleObj.KeybindValue = bindKey
			ToggleObj.KeybindMode = bindMode
			Label.Size = UDim2.new(1, -110, 1, 0)

			local KeyBtn, KeyStroke = KeyChip(Btn, {Size = UDim2.fromOffset(0, 18), Position = UDim2.new(1, -38, 0, 0), AnchorPoint = Vector2.new(1, 0)})
			local binding = false
			local function RefreshKeyBtn()
				if binding then return end
				if bindKey ~= Enum.KeyCode.Unknown then
					KeyBtn.Text = bindKey.Name
					Tween(KeyBtn, {TextColor3 = toggled and Theme.Accent or Theme.Text}, 0.15)
				else
					KeyBtn.Text = "None"
					Tween(KeyBtn, {TextColor3 = Theme.TextMuted}, 0.15)
				end
				Tween(KeyStroke, {Color = Theme.Stroke}, 0.15)
			end
			ToggleObj.RefreshKeyBtn = RefreshKeyBtn

			PushBind = function()
				Library:RegisterBind(bindName, {
					Key = bindKey.Name,
					Mode = bindMode,
					Active = toggled,
					Toggle = function() SetToggled(not toggled) end,
				})
				RefreshKeyBtn()
			end
			SetBindMode = function(md)
				bindMode = md
				ToggleObj.KeybindMode = md
				Library.Flags[keyFlag] = {Key = bindKey, Mode = bindMode}
				Library.Unsaved = true
				if md == "Always" then SetToggled(true) end
				PushBind()
			end

			Track(KeyBtn.MouseButton1Click, function()
				if binding then return end
				binding = true
				KeyBtn.Text = "..."
				Tween(KeyStroke, {Color = Theme.Accent}, 0.12)
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
			Track(KeyBtn.MouseButton2Click, function()
				if ctx.OpenMenu then ctx.OpenMenu(KeyBtn, {"Toggle", "Hold", "Always"}, bindMode, SetBindMode) end
			end)
			Track(UserInputService.InputBegan, function(input, gp)
				if gp or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
				if bindKey == Enum.KeyCode.Unknown or input.KeyCode ~= bindKey then return end
				if bindMode == "Toggle" then
					SetToggled(not toggled)
				elseif bindMode == "Hold" then
					SetToggled(true)
				end
			end)
			Track(UserInputService.InputEnded, function(input)
				if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
				if bindKey == Enum.KeyCode.Unknown or input.KeyCode ~= bindKey then return end
				if bindMode == "Hold" then SetToggled(false) end
			end)
			Library.Signals[keyFlag] = function(v)
				if type(v) ~= "table" then return end
				bindKey = v.Key or Enum.KeyCode.Unknown
				bindMode = v.Mode or "Toggle"
				ToggleObj.KeybindValue = bindKey
				ToggleObj.KeybindMode = bindMode
				PushBind()
			end
			PushBind()
		elseif bindable and ctx.Bindable and IsTouchOnly() then
			-- mobile has no keyboard: a "Pin" chip puts this toggle in the floating Quick toggles panel
			local bindName = text
			if Library.Binds[bindName] then bindName = text .. " (" .. tostring(ctx.SectionName) .. ")" end
			ToggleObj.BindName = bindName
			local pinFlag = flag .. "_Pinned"
			local pinned = Library.Flags[pinFlag] == true
			Library.Defaults[pinFlag] = false
			Library.Flags[pinFlag] = pinned
			Label.Size = UDim2.new(1, -110, 1, 0)
			local PinBtn, PinStroke = KeyChip(Btn, {Size = UDim2.fromOffset(0, 18), Position = UDim2.new(1, -38, 0, 0), AnchorPoint = Vector2.new(1, 0)})
			local function PushPin()
				PinBtn.Text = pinned and "Pinned" or "Pin"
				Tween(PinBtn, {TextColor3 = pinned and Theme.Accent or Theme.TextMuted}, 0.15)
				Tween(PinStroke, {Color = pinned and Theme.Accent or Theme.Stroke}, 0.15)
				Library:RegisterBind(bindName, {
					Key = "Unknown", Mode = "Toggle", Active = toggled, MobilePinned = pinned,
					Toggle = function() SetToggled(not toggled) end,
				})
			end
			Track(PinBtn.MouseButton1Click, function()
				pinned = not pinned
				Library.Flags[pinFlag] = pinned
				Library.Unsaved = true
				PushPin()
				if pinned and not Library.ShowKeybinds then
					Library:Notify("Quick toggles", "Turn on the keybind list in Settings to see pinned toggles", 4)
				end
			end)
			Library.Signals[pinFlag] = function(v)
				pinned = v == true
				PushPin()
			end
			PushPin()
		end

		Track(Btn.MouseButton1Click, function()
			toggled = not toggled
			Library.Unsaved = true
			ToggleAnim()
			callback(toggled)
		end)
		if toggled then ToggleAnim() end
		ApplyTooltip(Btn, tooltipText)
		task.spawn(callback, toggled)

		function ToggleObj:AddButton(txt, cb)
			local SBtn = FlatButton(Inner, txt, SubOrder())
			Track(SBtn.MouseButton1Click, WrapCallback(txt, cb, false))
			if toggled then ToggleAnim() end
			return SBtn
		end
		function ToggleObj:AddSlider(txt, sflag, smin, smax, sdef, cb, inc)
			local f = CreateSliderElement(txt, sflag, smin, smax, sdef, inc, nil, cb, Inner, nil, SubOrder(), false)
			if toggled then ToggleAnim() end
			return f
		end
		function ToggleObj:AddDropdown(txt, dflag, opts, def, cb, isMulti)
			local d = CreateDropdownElement(txt, dflag, opts, def, nil, cb, Inner, Section, isMulti, Inner, SubOrder())
			if toggled then ToggleAnim() end
			return d
		end
		function ToggleObj:Keybind(defaultKey, mode)
			if not ToggleObj.BindName or not SetBindMode then return ToggleObj end
			if not hasSavedBind and defaultKey then
				bindKey = defaultKey
				ToggleObj.KeybindValue = bindKey
				Library.Flags[keyFlag] = {Key = bindKey, Mode = bindMode}
			end
			if mode and not hasSavedBind then SetBindMode(mode) else PushBind() end
			return ToggleObj
		end
		return ToggleObj
	end

	-- label on the left, key box on the right
	local function KeyRow(text)
		local Frame = New("Frame", {Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Parent = Cell()})
		AddItem(text, Frame)
		New("TextLabel", {Text = text, TextSize = 14, TextTruncate = Enum.TextTruncate.AtEnd, Theme = {
			TextXAlignment = LabelAlign,
			Size = function() return Style.CenterLabels and UDim2.new(1, 0, 1, 0) or UDim2.new(1, -90, 1, 0) end,
		}, Parent = Frame})
		local Chip, ChipStroke = KeyChip(Frame, {Size = UDim2.fromOffset(0, 18), Position = UDim2.fromScale(1, 0), AnchorPoint = Vector2.new(1, 0)})
		return Frame, Chip, ChipStroke
	end

	function Section:Keybind(text, flag, defaultKey, mode, tooltipText, callback)
		callback = WrapCallback(text, callback, false)
		local saved = Library.Flags[flag]
		local key = (type(saved) == "table" and saved.Key) or defaultKey or Enum.KeyCode.Unknown
		local kMode = (type(saved) == "table" and saved.Mode) or mode or "Toggle"
		Library.Defaults[flag] = {Key = defaultKey or Enum.KeyCode.Unknown, Mode = mode or "Toggle"}
		Library.Flags[flag] = {Key = key, Mode = kMode}

		local Frame, KeyBtn, KeyStroke = KeyRow(text)
		local toggled = (kMode == "Always")
		local PushEntry
		PushEntry = function()
			KeyBtn.Text = key == Enum.KeyCode.Unknown and "None" or key.Name
			Library:RegisterBind(text, {
				Key = key.Name, Mode = kMode, Active = toggled, Pinned = true,
				Toggle = function()
					toggled = not toggled
					PushEntry()
					callback(toggled)
				end,
			})
		end
		PushEntry()

		local binding = false
		Track(KeyBtn.MouseButton1Click, function()
			if binding then return end
			binding = true
			KeyBtn.Text = "..."
			Tween(KeyStroke, {Color = Theme.Accent}, 0.12)
			local conn
			conn = UserInputService.InputBegan:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
				if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
					key = Enum.KeyCode.Unknown
				elseif input.KeyCode ~= Enum.KeyCode.Escape and input.KeyCode ~= Enum.KeyCode.Unknown then
					key = input.KeyCode
				end
				Tween(KeyStroke, {Color = Theme.Stroke}, 0.15)
				Library.Flags[flag] = {Key = key, Mode = kMode}
				binding = false
				Library.Unsaved = true
				conn:Disconnect()
				PushEntry()
			end)
		end)
		Track(KeyBtn.MouseButton2Click, function()
			if not ctx.OpenMenu then return end
			ctx.OpenMenu(KeyBtn, {"Toggle", "Hold", "Always"}, kMode, function(md)
				kMode = md
				Library.Flags[flag] = {Key = key, Mode = kMode}
				Library.Unsaved = true
				if kMode == "Always" then
					toggled = true
					callback(true)
				end
				PushEntry()
			end)
		end)
		Track(UserInputService.InputBegan, function(input, gp)
			if gp or key == Enum.KeyCode.Unknown or input.KeyCode ~= key then return end
			if kMode == "Toggle" then
				toggled = not toggled
				PushEntry()
				callback(toggled)
			elseif kMode == "Hold" then
				toggled = true
				PushEntry()
				callback(toggled)
			end
		end)
		Track(UserInputService.InputEnded, function(input, gp)
			if gp or key == Enum.KeyCode.Unknown or input.KeyCode ~= key then return end
			if kMode == "Hold" then
				toggled = false
				PushEntry()
				callback(toggled)
			end
		end)
		ApplyTooltip(Frame, tooltipText)

		Library.Signals[flag] = function(v)
			if type(v) == "table" and v.Key then
				key = v.Key
				kMode = v.Mode or "Toggle"
				if kMode == "Always" then
					toggled = true
					callback(true)
				end
				PushEntry()
			end
		end

		local BindObj = {}
		function BindObj:SetKey(newKey)
			key = newKey
			Library.Flags[flag] = {Key = key, Mode = kMode}
			Library.Unsaved = true
			PushEntry()
		end
		return BindObj
	end

	-- simple key capture row (no keybind list entry), used by settings
	function Section:KeyPicker(text, defaultKey, callback, allowNone)
		local key = defaultKey or Enum.KeyCode.Unknown
		local _, Chip, ChipStroke = KeyRow(text)
		local function Show()
			Chip.Text = key == Enum.KeyCode.Unknown and "None" or key.Name
		end
		Show()
		local binding = false
		Track(Chip.MouseButton1Click, function()
			if binding then return end
			binding = true
			Chip.Text = "..."
			Tween(ChipStroke, {Color = Theme.Accent}, 0.12)
			local conn
			conn = UserInputService.InputBegan:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
				if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
					if allowNone then key = Enum.KeyCode.Unknown else key = defaultKey or key end
				elseif input.KeyCode ~= Enum.KeyCode.Escape and input.KeyCode ~= Enum.KeyCode.Unknown then
					key = input.KeyCode
				end
				conn:Disconnect()
				Tween(ChipStroke, {Color = Theme.Stroke}, 0.15)
				Show()
				-- let this key press finish before the new bind becomes active
				task.defer(function()
					binding = false
					if callback then callback(key) end
				end)
			end)
		end)
		return {Set = function(_, k) key = k Show() end}
	end

	function Section:Slider(text, flag, min, max, default, increment, tooltipText, callback)
		return CreateSliderElement(text, flag, min, max, default, increment, tooltipText, callback, Cell(), AddItem, 0)
	end

	function Section:TextBox(text, flag, placeholder, tooltipText, callback)
		callback = WrapCallback(text, callback, false)
		Library.Defaults[flag] = ""
		local Frame = New("Frame", {Size = UDim2.new(1, 0, 0, 18 + CTRL_H), BackgroundTransparency = 1, Parent = Cell()})
		AddItem(text, Frame)
		New("TextLabel", {Text = text, Size = UDim2.new(1, 0, 0, 14), TextSize = 14, TextTruncate = Enum.TextTruncate.AtEnd, Theme = {TextXAlignment = LabelAlign}, Parent = Frame})
		local Box = New("Frame", {Size = UDim2.new(1, 0, 0, CTRL_H), Position = UDim2.new(0, 0, 1, -CTRL_H), Theme = {BackgroundColor3 = "Container"}, Parent = Frame})
		Corner(Box, SMALL_R)
		local BoxStroke = Stroke(Box, "Stroke", 0)
		local currentText = Library.Flags[flag] or ""
		local Input = New("TextBox", {Size = UDim2.new(1, -16, 1, 0), Position = UDim2.fromOffset(8, 0), Text = currentText, PlaceholderText = placeholder or "Type here...", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ClipsDescendants = true, Parent = Box})
		Track(Input.Focused, function() Tween(BoxStroke, {Color = Theme.Accent}, 0.15) end)
		Track(Input.FocusLost, function(enter)
			Tween(BoxStroke, {Color = Theme.Stroke}, 0.2)
			if enter then
				Library.Flags[flag] = Input.Text
				Library.Unsaved = true
				callback(Input.Text)
			end
		end)
		Track(Input:GetPropertyChangedSignal("Text"), function()
			Library.Flags[flag] = Input.Text
		end)
		Library.Flags[flag] = currentText
		Library.Signals[flag] = function(v)
			Input.Text = tostring(v or "")
			Library.Unsaved = true
			callback(Input.Text)
		end
		ApplyTooltip(Frame, tooltipText)
		task.spawn(callback, currentText)
		return Input
	end

	function Section:Dropdown(text, flag, options, default, tooltipText, callback, customParent, isMulti)
		local obj = CreateDropdownElement(text, flag, options, default, tooltipText, callback, customParent or Cell(), Section, isMulti, customParent, 0)
		if not customParent then AddItem(text, obj.Frame) end
		return obj
	end

	function Section:ColorPicker(text, flag, default, tooltipText, callback)
		callback = WrapCallback(text, callback, false)
		local color = Library.Flags[flag]
		if typeof(color) ~= "Color3" then color = default or Color3.new(1, 1, 1) end
		Library.Defaults[flag] = default or Color3.new(1, 1, 1)
		Library.Flags[flag] = color
		local h, s, v = color:ToHSV()
		local isOpen = false
		local HEAD, BODY = 18, 146

		local Holder = New("Frame", {Size = UDim2.new(1, 0, 0, HEAD), BackgroundTransparency = 1, Parent = Cell()})
		AddItem(text, Holder)
		local Head = New("TextButton", {Size = UDim2.new(1, 0, 0, HEAD), BackgroundTransparency = 1, Parent = Holder})
		New("TextLabel", {Text = text, Size = UDim2.new(1, -40, 1, 0), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = Head})
		local Swatch = New("Frame", {Size = UDim2.fromOffset(26, 14), Position = UDim2.new(1, 0, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = color, Parent = Head})
		Corner(Swatch, SMALL_R)
		local SwStroke = Stroke(Swatch, "Stroke", 0)

		local Body = New("Frame", {Size = UDim2.new(1, 0, 0, 0), Position = UDim2.fromOffset(0, HEAD + 6), BackgroundTransparency = 1, ClipsDescendants = true, Parent = Holder})
		local SVMap = New("ImageLabel", {Image = ASSET_SV, Size = UDim2.new(1, -24, 0, 110), Position = UDim2.fromOffset(1, 1), BackgroundTransparency = 0, BackgroundColor3 = Color3.fromHSV(h, 1, 1), Active = true, Parent = Body})
		Corner(SVMap, SMALL_R)
		local SVCursor = New("Frame", {Size = UDim2.fromOffset(8, 8), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(s, 0, 1 - v, 0), BackgroundTransparency = 1, ZIndex = 3, Parent = SVMap})
		Corner(SVCursor, 4)
		New("UIStroke", {Color = Color3.new(1, 1, 1), Thickness = 1.5, Parent = SVCursor})
		local HueBar = New("Frame", {Size = UDim2.new(0, 14, 0, 110), Position = UDim2.new(1, -15, 0, 1), BackgroundColor3 = Color3.new(1, 1, 1), Active = true, Parent = Body})
		Corner(HueBar, SMALL_R)
		New("UIGradient", {Rotation = 90, Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		}), Parent = HueBar})
		local HCursor = New("Frame", {Size = UDim2.new(1, 2, 0, 2), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, h, 0), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 3, Parent = HueBar})
		New("UIStroke", {Color = Color3.new(0, 0, 0), Transparency = 0.5, Parent = HCursor})

		local Bottom = New("Frame", {Size = UDim2.new(1, -2, 0, CTRL_H), Position = UDim2.fromOffset(1, 118), BackgroundTransparency = 1, Parent = Body})
		local HexBox = New("TextBox", {Size = UDim2.fromOffset(84, CTRL_H), TextSize = 14, Theme = {BackgroundColor3 = "Container"}, Parent = Bottom})
		Corner(HexBox, SMALL_R)
		local HexStroke = Stroke(HexBox, "Stroke", 0)
		local Presets = New("Frame", {Size = UDim2.new(1, -92, 1, 0), Position = UDim2.fromOffset(92, 0), BackgroundTransparency = 1, Parent = Bottom})
		ListLayout(Presets, 5, true, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

		local function Render()
			Swatch.BackgroundColor3 = color
			SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
			HCursor.Position = UDim2.new(0.5, 0, h, 0)
			if not HexBox:IsFocused() then HexBox.Text = "#" .. color:ToHex():upper() end
		end
		local function Commit()
			color = Color3.fromHSV(h, s, v)
			Render()
			Library.Flags[flag] = color
			Library.Unsaved = true
			callback(color)
		end
		local function SetColor(c, silent)
			color = c
			h, s, v = c:ToHSV()
			Render()
			Library.Flags[flag] = color
			if not silent then
				Library.Unsaved = true
				callback(color)
			end
		end
		Render()

		for i = 1, 5 do
			local preset = Themes[ThemeOrder[i]].Accent
			local p = New("TextButton", {Size = UDim2.fromOffset(16, 16), BackgroundColor3 = preset, LayoutOrder = i, Parent = Presets})
			Corner(p, SMALL_R)
			Stroke(p, "Stroke", 0)
			Track(p.MouseButton1Click, function() SetColor(preset) end)
		end

		Track(HexBox.Focused, function() Tween(HexStroke, {Color = Theme.Accent}, 0.15) end)
		Track(HexBox.FocusLost, function()
			Tween(HexStroke, {Color = Theme.Stroke}, 0.2)
			local t = HexBox.Text:gsub("#", "")
			if t:match("^%x%x%x%x%x%x$") then
				pcall(function() SetColor(Color3.fromHex(t)) end)
			else
				HexBox.Text = "#" .. color:ToHex():upper()
			end
		end)

		local function SetSV(input)
			s = math.clamp((input.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1)
			v = 1 - math.clamp((input.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1)
			Commit()
		end
		local function SetH(input)
			h = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
			Commit()
		end
		Track(SVMap.InputBegan, function(input)
			if IsPress(input) then
				SetSV(input)
				BeginDrag(input, SetSV)
			end
		end)
		Track(HueBar.InputBegan, function(input)
			if IsPress(input) then
				SetH(input)
				BeginDrag(input, SetH)
			end
		end)
		Track(Head.MouseButton1Click, function()
			isOpen = not isOpen
			Tween(Holder, {Size = UDim2.new(1, 0, 0, isOpen and (HEAD + 6 + BODY) or HEAD)}, 0.25)
			Tween(Body, {Size = UDim2.new(1, 0, 0, isOpen and BODY or 0)}, 0.25)
			Tween(SwStroke, {Color = isOpen and Theme.Accent or Theme.Stroke}, 0.15)
		end)

		Library.Signals[flag] = function(val)
			if typeof(val) == "Color3" then SetColor(val) end
		end
		ApplyTooltip(Holder, tooltipText)
		task.spawn(callback, color)

		return {
			Set = function(_, c, silent) if typeof(c) == "Color3" then SetColor(c, silent) end end,
			Get = function() return color end,
		}
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
		local selectedWeapon, selectedSkin = nil, nil
		local activeTab = subTabs[1] or "Skins"
		local tabCount = #subTabs
		local TabScroll = ctx.Page
		if ctx.MakeFull then ctx.MakeFull() end

		local BrowserFrame = New("Frame", {Size = UDim2.new(1, 0, 0, 500), ClipsDescendants = true, LayoutOrder = NextOrder(), Theme = {BackgroundColor3 = "Container"}, Parent = Content})
		Corner(BrowserFrame, 5)
		Stroke(BrowserFrame, "Stroke", 1)
		AddItem("SkinBrowser", BrowserFrame)

		
		local NavBar = New("Frame", {Size = UDim2.new(1, -16, 0, 34), Position = UDim2.fromOffset(8, 8), Visible = tabCount > 1, Theme = {BackgroundColor3 = "Field"}, Parent = BrowserFrame})
		Corner(NavBar, 4)
		local NavInner = New("Frame", {Size = UDim2.new(1, -6, 1, -6), Position = UDim2.fromOffset(3, 3), BackgroundTransparency = 1, Parent = NavBar})
		local Pill = New("Frame", {Size = UDim2.new(1 / math.max(tabCount, 1), 0, 1, 0), Theme = {BackgroundColor3 = "Accent"}, Parent = NavInner})
		Corner(Pill, 3)
		local NavBtns = New("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = NavInner})
		ListLayout(NavBtns, 0, true)
		local navBtns = {}
		for idx, tabName in ipairs(subTabs) do
			local btn = New("TextButton", {Size = UDim2.new(1 / math.max(tabCount, 1), 0, 1, 0), Text = tabName, TextSize = 13, Font = Config.FontBold, LayoutOrder = idx, Theme = {TextColor3 = function() return tabName == activeTab and Theme.AccentText or Theme.TextDark end}, Parent = NavBtns})
			navBtns[tabName] = {Button = btn, Index = idx}
		end
		do
			local first = navBtns[activeTab]
			if first then Pill.Position = UDim2.fromScale((first.Index - 1) / math.max(tabCount, 1), 0) end
		end

		local ContentArea = New("Frame", {
			Size = tabCount > 1 and UDim2.new(1, -16, 1, -56) or UDim2.new(1, -16, 1, -16),
			Position = tabCount > 1 and UDim2.fromOffset(8, 48) or UDim2.fromOffset(8, 8),
			BackgroundTransparency = 1, Parent = BrowserFrame,
		})

		local function Panel(parent, size, pos)
			local p = New("Frame", {Size = size, Position = pos, Theme = {BackgroundColor3 = "Section"}, Parent = parent})
			Corner(p, 7)
			Stroke(p, "Stroke", 1)
			return p
		end
		local function PanelHeader(parent, txt, ord)
			return New("TextLabel", {Size = UDim2.new(1, 0, 0, 16), Text = txt, Font = Config.FontBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = ord, Theme = {TextColor3 = "TextMuted"}, Parent = parent})
		end
		local function ListScroll(parent, ord, height)
			local sf = New("ScrollingFrame", {Size = UDim2.new(1, 0, 0, height), LayoutOrder = ord, ScrollBarThickness = 3, BackgroundTransparency = 0, Theme = {BackgroundColor3 = "Field"}, Parent = parent})
			Corner(sf, 4)
			ListLayout(sf, 2)
			Padding(sf, 4, 4, 4, 4)
			return sf
		end
		local function MakeViewport(parent)
			local VP = New("ViewportFrame", {Size = UDim2.new(1, -16, 1, -88), Position = UDim2.fromOffset(8, 8), Theme = {BackgroundColor3 = "Field"}, Parent = parent})
			Corner(VP, 4)
			local Cam = Instance.new("Camera")
			Cam.FieldOfView = 50
			Cam.Parent = VP
			VP.CurrentCamera = Cam
			local WM = Instance.new("WorldModel")
			WM.Parent = VP
			local L1 = Instance.new("Part")
			L1.Transparency, L1.Anchored, L1.CanCollide = 1, true, false
			L1.Size = Vector3.new(0.1, 0.1, 0.1)
			L1.Position = Vector3.new(4, 4, 4)
			L1.Parent = WM
			local PL = Instance.new("PointLight")
			PL.Brightness, PL.Range = 2.5, 40
			PL.Parent = L1
			return VP, Cam, WM, L1
		end

		
		local SkinsPage = New("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = ContentArea})
		local LeftPanel = Panel(SkinsPage, UDim2.new(0.36, -4, 1, 0), UDim2.new())
		ListLayout(LeftPanel, 5)
		Padding(LeftPanel, 8, 8, 8, 8)
		PanelHeader(LeftPanel, "WEAPON", 1)
		local WepScroll = ListScroll(LeftPanel, 3, 138)
		local weaponButtons, wepQuery = {}, ""
		local function HighlightWeapon(name)
			for n, b in pairs(weaponButtons) do SetItemSelected(b, n == name) end
		end
		SearchField(LeftPanel, "Search weapon...", 2, function(q)
			wepQuery = q
			FilterButtons(weaponButtons, q)
		end)
		PanelHeader(LeftPanel, "SKIN", 4)
		local SkinScroll = ListScroll(LeftPanel, 6, 118)
		local skinButtons, skinQuery = {}, ""
		local function HighlightSkin(name)
			for n, b in pairs(skinButtons) do SetItemSelected(b, n == name) end
		end
		SearchField(LeftPanel, "Search skin...", 5, function(q)
			skinQuery = q
			FilterButtons(skinButtons, q)
		end)

		local RightPanel = Panel(SkinsPage, UDim2.new(0.64, -4, 1, 0), UDim2.new(0.36, 4, 0, 0))
		local VPFrame, VPCam, WorldMdl, LightPart = MakeViewport(RightPanel)
		local LightPart2 = Instance.new("Part")
		LightPart2.Transparency, LightPart2.Anchored, LightPart2.CanCollide = 1, true, false
		LightPart2.Size = Vector3.new(0.1, 0.1, 0.1)
		LightPart2.Position = Vector3.new(-3, 2, -3)
		LightPart2.Parent = WorldMdl
		local PLight2 = Instance.new("PointLight")
		PLight2.Brightness, PLight2.Range = 1.5, 30
		PLight2.Color = Color3.fromRGB(200, 150, 150)
		PLight2.Parent = LightPart2
		local SkinCtrl = CreatePreviewController(VPFrame, VPCam)
		SkinCtrl.ScrollFrame = TabScroll
		local SkinNameLabel = New("TextLabel", {Size = UDim2.new(1, -24, 0, 20), Position = UDim2.new(0, 12, 1, -74), Text = "Select a skin", Font = Config.FontBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = RightPanel})
		local EquipBtnR = ActionButton(RightPanel, "EQUIP SKIN", true, {Size = UDim2.new(0.62, -12, 0, 32), Position = UDim2.new(0, 8, 1, -42)})
		local RestoreBtn = ActionButton(RightPanel, "RESTORE", false, {Size = UDim2.new(0.38, -8, 0, 32), Position = UDim2.new(0.62, 0, 1, -42)})
		local EquipBtnL = EquipBtnR

		
		local cosmeticPages = {}
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

			local PageF = New("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = ContentArea})
			local LPan = Panel(PageF, UDim2.new(0.36, -4, 1, 0), UDim2.new())
			ListLayout(LPan, 5)
			Padding(LPan, 8, 8, 8, 8)

			local WScroll
			if not pNoWeapons then
				PanelHeader(LPan, "WEAPON", 1)
				WScroll = ListScroll(LPan, 3, 128)
			end
			PanelHeader(LPan, pItemHeader, 4)
			local IScroll = ListScroll(LPan, 6, pNoWeapons and 278 or (pHasInverted and 96 or 118))

			if pHasInverted then
				local tf = New("TextButton", {Size = UDim2.new(1, 0, 0, 26), Text = "Inverted: OFF", TextSize = 13, LayoutOrder = 7, Theme = {BackgroundColor3 = "Container"}, Parent = LPan})
				Corner(tf, 3)
				Stroke(tf, "Stroke", 1)
				Track(tf.MouseButton1Click, function()
					pInverted = not pInverted
					tf.Text = "Inverted: " .. (pInverted and "ON" or "OFF")
					Tween(tf, {BackgroundColor3 = pInverted and Theme.AccentSoft or Theme.Container}, 0.2)
				end)
			end


			local RPan = Panel(PageF, UDim2.new(0.64, -4, 1, 0), UDim2.new(0.36, 4, 0, 0))
			local VP, Cam, WM, L1 = MakeViewport(RPan)
			local pCtrl = CreatePreviewController(VP, Cam)
			pCtrl.ScrollFrame = TabScroll
			local NameLbl = New("TextLabel", {Size = UDim2.new(1, -24, 0, 20), Position = UDim2.new(0, 12, 1, -74), Text = "Select an item", Font = Config.FontBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = RPan})
			local EqR = ActionButton(RPan, pEquipText, true, {Size = UDim2.new(0.62, -12, 0, 32), Position = UDim2.new(0, 8, 1, -42)})
			local RmB = ActionButton(RPan, "REMOVE", false, {Size = UDim2.new(0.38, -8, 0, 32), Position = UDim2.new(0.62, 0, 1, -42)})
			local EqB = EqR

			local Host
			if pNoPreview then
				VP.Visible = false
				Host = New("ScrollingFrame", {Size = UDim2.new(1, -16, 1, -88), Position = UDim2.fromOffset(8, 8), ScrollBarThickness = 3, Parent = RPan})
				ListLayout(Host, 6)
			end

			local PrevImg
			if pGetImage and not pNoPreview then
				PrevImg = New("ImageLabel", {Size = UDim2.new(1, -32, 1, -104), Position = UDim2.fromOffset(16, 16), ScaleType = Enum.ScaleType.Fit, Image = "", Parent = RPan})
			end

			local pPreviewModel = nil
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
				if not itemName or pNoPreview then return end
				local model = pGetModel(itemName)
				if not model then NameLbl.Text = itemName .. " (no preview)" return end
				local ok, clone = pcall(function() return model:Clone() end)
				if not ok or not clone then NameLbl.Text = "Load failed" return end
				clone.Parent = WM
				pPreviewModel = clone
				local suc, cf, size = pcall(function() return clone:GetBoundingBox() end)
				if not suc then
					local ap = clone:FindFirstChildWhichIsA("BasePart", true)
					if ap then cf, size = ap.CFrame, ap.Size else cf, size = CFrame.new(), Vector3.new(2, 2, 2) end
				end
				local dist = math.max(size.X, size.Y, size.Z, 1) * 2.8
				Cam.CFrame = CFrame.new(cf.Position + Vector3.new(0, size.Y * 0.2, dist), cf.Position)
				pCtrl:Reset()
				pCtrl.Model = clone
				NameLbl.Text = itemName
			end
			Track(RunService.RenderStepped, function(dt)
				if pPreviewModel and PageF.Visible then pCtrl:Step(dt) end
			end)

			local wButtons, iButtons = {}, {}
			local pWepQuery, pItemQuery = "", ""
			if WScroll then
				SearchField(LPan, "Search weapon...", 2, function(q)
					pWepQuery = q
					FilterButtons(wButtons, q)
				end)
			end
			SearchField(LPan, "Search " .. pItemHeader:lower() .. "...", 5, function(q)
				pItemQuery = q
				FilterButtons(iButtons, q)
			end)
			local function pBuildItems(wName)
				for _, ch in ipairs(IScroll:GetChildren()) do
					if ch:IsA("TextButton") then ch:Destroy() end
				end
				iButtons = {}
				for si, iName in ipairs(pGetItems(wName)) do
					local ib = MakeListItem(IScroll, iName, si, 26)
					iButtons[iName] = ib
					Track(ib.MouseButton1Click, function()
						pSelItem = iName
						for n, b in pairs(iButtons) do SetItemSelected(b, n == iName) end
						pShowPreview(iName)
						if pOnSelect then pcall(pOnSelect, pSelWeapon, iName) end
					end)
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
					local wb = MakeListItem(WScroll, wName, i, 28)
					wButtons[wName] = wb
					Track(wb.MouseButton1Click, function()
						pSelWeapon = wName
						pSelItem = nil
						for n, b in pairs(wButtons) do SetItemSelected(b, n == wName) end
						pBuildItems(wName)
						pClearPreview()
						NameLbl.Text = "Select an item"
					end)
				end
				FilterButtons(wButtons, pWepQuery)
			end
			pBuildWeapons()
			if pNoWeapons then pBuildItems(nil) end

			local function pDoEquip()
				EqB.Text = "EQUIPPED"
				EqR.Text = "EQUIPPED"
				task.spawn(function() pcall(pOnEquip, pSelWeapon, pSelItem, pInverted) end)
				task.delay(1.5, function()
					pcall(function()
						EqB.Text = pEquipText
						EqR.Text = pEquipText
					end)
				end)
			end
			Track(EqB.MouseButton1Click, pDoEquip)
			Track(EqR.MouseButton1Click, pDoEquip)
			Track(RmB.MouseButton1Click, function()
				pOnRestore()
				RmB.Text = "REMOVED"
				task.delay(1, function() pcall(function() RmB.Text = "REMOVE" end) end)
			end)

			return {
				Frame = PageF,
				ApplyHeight = function(contentH)
					local invH = pHasInverted and 31 or 0
					if pNoWeapons then
						IScroll.Size = UDim2.new(1, 0, 0, math.max(contentH - (16 + 26 + 40 + invH), 120))
					else
						local space = math.max(contentH - (32 + 52 + 50 + invH), 160)
						local wh = math.floor(space * 0.5)
						WScroll.Size = UDim2.new(1, 0, 0, wh)
						IScroll.Size = UDim2.new(1, 0, 0, space - wh)
					end
				end,
				SetWeapons = function(_, nw)
					pWeapons = nw or {}
					pBuildWeapons()
				end,
				GetSelected = function() return pSelWeapon, pSelItem, pInverted end,
				Refresh = function()
					if pNoWeapons then pBuildItems(nil) end
				end,
				Host = Host,
			}
		end

		for _, pName in ipairs(subTabs) do
			if pName ~= "Skins" then cosmeticPages[pName] = BuildCosmeticPage(pName, tabsCfg[pName]) end
		end

		local function ApplyBrowserHeight()
			if not TabScroll then return end
			local avail = TabScroll.AbsoluteSize.Y
			if avail < 1 then return end
			local h = math.clamp(math.floor(avail / UIScaleValue()) - 60, 300, 760)
			BrowserFrame.Size = UDim2.new(1, 0, 0, h)
			local contentH = h - 56
			local space = math.max(contentH - 129, 140)
			local wh = math.floor(space * 0.52)
			WepScroll.Size = UDim2.new(1, 0, 0, wh)
			SkinScroll.Size = UDim2.new(1, 0, 0, space - wh)
			for _, pg in pairs(cosmeticPages) do
				if pg.ApplyHeight then pcall(pg.ApplyHeight, contentH) end
			end
		end
		ApplyBrowserHeight()
		if TabScroll then Track(TabScroll:GetPropertyChangedSignal("AbsoluteSize"), ApplyBrowserHeight) end
		task.defer(ApplyBrowserHeight)

		local function SwitchTab(tabName)
			activeTab = tabName
			local info = navBtns[tabName]
			if info then Tween(Pill, {Position = UDim2.fromScale((info.Index - 1) / math.max(tabCount, 1), 0)}, 0.35) end
			for n, nb in pairs(navBtns) do
				Tween(nb.Button, {TextColor3 = n == tabName and Theme.AccentText or Theme.TextDark}, 0.25)
			end
			SkinsPage.Visible = tabName == "Skins"
			for n, pg in pairs(cosmeticPages) do
				pg.Frame.Visible = n == tabName
				if pg.Frame.Visible and pg.Refresh then pcall(pg.Refresh) end
			end
		end
		for tName, nb in pairs(navBtns) do
			Track(nb.Button.MouseButton1Click, function() SwitchTab(tName) end)
		end
		SkinsPage.Visible = activeTab == "Skins"
		if cosmeticPages[activeTab] then cosmeticPages[activeTab].Frame.Visible = true end

		local previewModel = nil
		local function ClearPreview()
			for _, c in ipairs(WorldMdl:GetChildren()) do
				if c ~= LightPart and c ~= LightPart2 then pcall(function() c:Destroy() end) end
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
				if anyPart then cf, size = anyPart.CFrame, anyPart.Size else cf, size = CFrame.new(), Vector3.new(2, 2, 2) end
			end
			local dist = math.max(size.X, size.Y, size.Z, 1) * 2.8
			VPCam.CFrame = CFrame.new(cf.Position + Vector3.new(0, size.Y * 0.2, dist), cf.Position)
			SkinCtrl:Reset()
			SkinCtrl.Model = clone
			SkinNameLabel.Text = skinName
		end
		Track(RunService.RenderStepped, function(dt)
			if previewModel and SkinsPage.Visible then SkinCtrl:Step(dt) end
		end)

		local function BuildWeaponList()
			for _, ch in ipairs(WepScroll:GetChildren()) do
				if ch:IsA("TextButton") then ch:Destroy() end
			end
			weaponButtons = {}
			for i, wName in ipairs(weapons) do
				local btn = MakeListItem(WepScroll, wName, i, 28)
				weaponButtons[wName] = btn
				btn.Visible = wepQuery == "" or wName:lower():find(wepQuery, 1, true) ~= nil
				Track(btn.MouseButton1Click, function()
					selectedWeapon = wName
					selectedSkin = nil
					HighlightWeapon(wName)
					for _, ch in ipairs(SkinScroll:GetChildren()) do
						if ch:IsA("TextButton") then ch:Destroy() end
					end
					skinButtons = {}
					for si, sName in ipairs(getSkins(wName)) do
						local sbtn = MakeListItem(SkinScroll, sName, si, 26)
						skinButtons[sName] = sbtn
						Track(sbtn.MouseButton1Click, function()
							selectedSkin = sName
							HighlightSkin(sName)
							ShowPreview(sName)
						end)
					end
					FilterButtons(skinButtons, skinQuery)
					ClearPreview()
					SkinNameLabel.Text = "Select a skin"
				end)
			end
		end
		BuildWeaponList()

		local function DoEquip()
			if selectedWeapon and selectedSkin then
				if onEquip(selectedWeapon, selectedSkin) then
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
		Track(EquipBtnL.MouseButton1Click, DoEquip)
		Track(EquipBtnR.MouseButton1Click, DoEquip)
		Track(RestoreBtn.MouseButton1Click, function()
			onRestore()
			RestoreBtn.Text = "RESTORED"
			task.delay(1, function() pcall(function() RestoreBtn.Text = "RESTORE" end) end)
		end)

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





function Library:CreateWindow(options)
	options = options or {}
	if options.Name then Config.Name = options.Name end
	if options.Brand then Config.Brand = options.Brand end
	-- starting style ("OG", "Obsidian", "Fluent", "Modern"); a player's saved choice wins
	if options.Style and Styles[options.Style] then
		Library.StyleName = options.Style
		Style = Styles[options.Style]
		Library.FontName = Style.Font
		Config.FontMain, Config.FontBold = FontChoices[Style.Font], FontChoices[Style.Font]
		Library.Rounding = Style.Rounding
		LoadPalette(Library.CurrentTheme)
	end
	-- Obsidian uses Enum.Font.Code; pass e.g. Font = Enum.Font.GothamMedium for a sans font
	if options.Font then
		Config.FontMain = options.Font
		Config.FontBold = options.Font
	end
	if options.ConfigFolder then Config.ConfigFolder = options.ConfigFolder end
	if options.Game then Library.HubConfig.Game = options.Game end
	if not isfolder(Config.ConfigFolder) then makefolder(Config.ConfigFolder) end

	Library:Unload()
	LoadInterface()
	BuildTooltip()
	Library:InitWatermark()

	local GameName = Library.HubConfig.Game
	if GameName == "" then
		GameName = game.Name
		pcall(function()
			local info = MarketplaceService:GetProductInfo(game.PlaceId)
			if info and info.Name and info.Name ~= "" then GameName = info.Name end
		end)
	end

	local vpNow = workspace.CurrentCamera.ViewportSize
	-- phones / small screens: icon-only sidebar so the pages get the room
	local Compact = IsTouchOnly() or vpNow.X < 800
	local TOP, SIDE, FOOT = 48, Compact and 48 or 190, 20

	local ScreenGui = New("ScreenGui", {Name = Config.Name, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true, ResetOnSpawn = false, DisplayOrder = 10, Parent = GetParent()})
	Library.ScreenGui = ScreenGui

	local Holder = New("Frame", {Name = "Holder", Size = UDim2.fromOffset(760, 500), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Visible = false, Parent = ScreenGui})
	New("UISizeConstraint", {MinSize = Vector2.new(560, 340), MaxSize = Vector2.new(1400, 900), Parent = Holder})
	local MainScale = New("UIScale", {Scale = EffectiveScale(), Parent = Holder})
	Library._MainScale = MainScale
	Library._SetScale = MainScale
	if Compact then
		local sc = math.max(EffectiveScale(), 0.01)
		Holder.Size = UDim2.fromOffset(math.clamp(math.floor(vpNow.X / sc * 0.94), 560, 760), math.clamp(math.floor(vpNow.Y / sc * 0.9), 340, 500))
	end
	local Window = New("Frame", {Name = "MainWindow", Size = UDim2.fromScale(1, 1), Active = true, Theme = {BackgroundColor3 = "Background"}, Parent = Holder})
	Corner(Window, 4)
	Stroke(Window, "Stroke", 0)
	Library._MainWindow = Window
	Library._SettingsWindow = Window

	------------------------------------------------------------------ topbar
	local Topbar = New("Frame", {Size = UDim2.new(1, 0, 0, TOP), Theme = {BackgroundColor3 = "Topbar"}, Parent = Window})
	Corner(Topbar, 4)
	New("Frame", {Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0, 0, 1, -4), Theme = {BackgroundColor3 = "Topbar"}, Parent = Topbar})
	New("Frame", {Position = UDim2.fromOffset(0, TOP), Theme = {
		BackgroundColor3 = function() return Style.TopAccent and Theme.Accent or Theme.Stroke end,
		BackgroundTransparency = function() return (Style.Dividers == false and not Style.TopAccent) and 1 or 0 end,
		Size = function() return UDim2.new(1, 0, 0, Style.TopAccent and 2 or 1) end,
	}, Parent = Window})
	local TitleRow = New("Frame", {Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.fromOffset(14, 0), BackgroundTransparency = 1, Parent = Topbar})
	ListLayout(TitleRow, 8, true, nil, Enum.VerticalAlignment.Center)
	New("ImageLabel", {Image = ASSET_LOGO, Size = UDim2.fromOffset(22, 22), ScaleType = Enum.ScaleType.Fit, LayoutOrder = 1, Theme = {ImageColor3 = "Accent", Visible = function() return Style.TopLogo ~= false end}, Parent = TitleRow})
	New("TextLabel", {Text = Config.Brand, Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 2, Theme = {TextSize = function() return Style.TopSize or 20 end}, Parent = TitleRow})

	local function TopButton(icon, xOff, hoverKey)
		local b = New("ImageButton", {Size = UDim2.fromOffset(26, 26), Position = UDim2.new(1, xOff, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Theme = {BackgroundColor3 = "Container"}, Parent = Topbar})
		Corner(b, SMALL_R)
		local img = New("ImageLabel", {Image = icon, Size = UDim2.fromOffset(16, 16), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Theme = {ImageColor3 = "TextDark"}, Parent = b})
		Track(b.MouseEnter, function()
			Tween(b, {BackgroundTransparency = 0}, 0.12)
			Tween(img, {ImageColor3 = Theme[hoverKey]}, 0.12)
		end)
		Track(b.MouseLeave, function()
			Tween(b, {BackgroundTransparency = 1}, 0.18)
			Tween(img, {ImageColor3 = Theme.TextDark}, 0.18)
		end)
		return b
	end
	local CloseBtn = TopButton(ASSET_CLOSE, -11, "Danger")
	local MinBtn = TopButton(ASSET_MIN, -41, "Text")

	local SearchBox = New("Frame", {Size = UDim2.fromOffset(220, 26), Position = UDim2.new(1, -76, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), Theme = {BackgroundColor3 = "Container"}, Parent = Topbar})
	Corner(SearchBox, SMALL_R)
	local SStroke = Stroke(SearchBox, "Stroke", 0)
	IconImage(SearchBox, "search", 13, {Position = UDim2.new(0, 8, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Theme = {ImageColor3 = "TextMuted"}})
	local SearchInput = New("TextBox", {Size = UDim2.new(1, -34, 1, 0), Position = UDim2.fromOffset(28, 0), PlaceholderText = "Search", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ClipsDescendants = true, Parent = SearchBox})

	------------------------------------------------------------------ footer
	local Footer = New("Frame", {Size = UDim2.new(1, 0, 0, FOOT), Position = UDim2.new(0, 0, 1, -FOOT), Theme = {BackgroundColor3 = "Topbar"}, Parent = Window})
	Corner(Footer, 4)
	New("Frame", {Size = UDim2.new(1, 0, 0, 4), Theme = {BackgroundColor3 = "Topbar"}, Parent = Footer})
	New("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -(FOOT + 1)), Theme = {BackgroundColor3 = "Stroke", BackgroundTransparency = function() return Style.Dividers == false and 1 or 0 end}, Parent = Window})
	New("TextLabel", {Text = GameName, TextSize = 13, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.fromOffset(30, 0), TextTruncate = Enum.TextTruncate.AtEnd, Theme = {TextColor3 = "TextMuted"}, Parent = Footer})

	------------------------------------------------------------------ sidebar
	local BODY_H = TOP + 1 + FOOT + 1
	local Sidebar = New("Frame", {Size = UDim2.new(0, SIDE, 1, -BODY_H), Position = UDim2.fromOffset(0, TOP + 1), Theme = {BackgroundColor3 = "Sidebar"}, Parent = Window})
	New("Frame", {Size = UDim2.new(0, 1, 1, -BODY_H), Position = UDim2.fromOffset(SIDE, TOP + 1), Theme = {BackgroundColor3 = "Stroke", BackgroundTransparency = function() return Style.Dividers == false and 1 or 0 end}, Parent = Window})
	local Clip = New("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, Parent = Sidebar})
	local MainStack = New("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = Clip})
	local SetStack = New("Frame", {Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(1, 0), BackgroundTransparency = 1, Parent = Clip})

	local TabContainer = New("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -50), ScrollBarThickness = 0, Parent = MainStack})
	Padding(TabContainer, 8, Compact and 6 or 8, 8, Compact and 6 or 8)
	ListLayout(TabContainer, 2)

	-- profile row at the bottom of the sidebar, opens settings
	New("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -50), Theme = {BackgroundColor3 = "Stroke", BackgroundTransparency = function() return Style.Dividers == false and 1 or 0 end}, Parent = MainStack})
	local Profile = New("TextButton", {Size = UDim2.new(1, -16, 0, 36), Position = UDim2.new(0, 8, 1, -43), BackgroundTransparency = 1, Theme = {BackgroundColor3 = "Container"}, Parent = MainStack})
	Corner(Profile, SMALL_R)
	local Avatar = New("ImageLabel", {Size = UDim2.fromOffset(24, 24), Position = UDim2.new(0, 6, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Theme = {BackgroundColor3 = "Container"}, Parent = Profile})
	Corner(Avatar, 12)
	task.spawn(function()
		local ok, img = pcall(function() return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
		if ok and Avatar.Parent then Avatar.Image = img end
	end)
	local ProfileName = New("TextLabel", {Text = LocalPlayer.DisplayName, TextSize = 14, Size = UDim2.new(1, -62, 1, 0), Position = UDim2.fromOffset(38, 0), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, TextTransparency = 0.4, Parent = Profile})
	local Gear = IconImage(Profile, "settings", 15, {Position = UDim2.new(1, -6, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), Theme = {ImageColor3 = "TextDark"}})
	Track(Profile.MouseEnter, function()
		Tween(Profile, {BackgroundTransparency = 0}, 0.12)
		Tween(ProfileName, {TextTransparency = 0}, 0.12)
		Tween(Gear, {Rotation = 60, ImageColor3 = Theme.Text}, 0.3)
	end)
	Track(Profile.MouseLeave, function()
		Tween(Profile, {BackgroundTransparency = 1}, 0.18)
		Tween(ProfileName, {TextTransparency = 0.4}, 0.18)
		Tween(Gear, {Rotation = 0, ImageColor3 = Theme.TextDark}, 0.3)
	end)
	ApplyTooltip(Profile, "Settings")
	if Compact then
		ProfileName.Visible = false
		Gear.Visible = false
		Avatar.Position = UDim2.fromScale(0.5, 0.5)
		Avatar.AnchorPoint = Vector2.new(0.5, 0.5)
		Profile.Size = UDim2.new(1, -12, 0, 36)
		Profile.Position = UDim2.new(0, 6, 1, -43)
	end

	local BackBtn = New("TextButton", {Size = UDim2.new(1, -16, 0, 30), Position = UDim2.fromOffset(8, 8), BackgroundTransparency = 1, Theme = {BackgroundColor3 = "Container"}, Parent = SetStack})
	Corner(BackBtn, SMALL_R)
	local BackArrow = New("ImageLabel", {Image = ASSET_CHEVRON, Size = UDim2.fromOffset(14, 14), Rotation = 90, Position = UDim2.new(0, 8, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Theme = {ImageColor3 = "TextDark"}, Parent = BackBtn})
	New("TextLabel", {Text = "Settings", TextSize = 15, Visible = not Compact, Size = UDim2.new(1, -34, 1, 0), Position = UDim2.fromOffset(28, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = BackBtn})
	if Compact then
		BackBtn.Size = UDim2.new(1, -12, 0, 30)
		BackBtn.Position = UDim2.fromOffset(6, 8)
		BackArrow.Position = UDim2.fromScale(0.5, 0.5)
		BackArrow.AnchorPoint = Vector2.new(0.5, 0.5)
	end
	Track(BackBtn.MouseEnter, function()
		Tween(BackBtn, {BackgroundTransparency = 0}, 0.12)
		Tween(BackArrow, {ImageColor3 = Theme.Text}, 0.12)
	end)
	Track(BackBtn.MouseLeave, function()
		Tween(BackBtn, {BackgroundTransparency = 1}, 0.18)
		Tween(BackArrow, {ImageColor3 = Theme.TextDark}, 0.18)
	end)
	ApplyTooltip(BackBtn, "Back to the menu")
	New("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.fromOffset(0, 46), Theme = {BackgroundColor3 = "Stroke", BackgroundTransparency = function() return Style.Dividers == false and 1 or 0 end}, Parent = SetStack})
	local SetContainer = New("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -47), Position = UDim2.fromOffset(0, 47), ScrollBarThickness = 0, Parent = SetStack})
	Padding(SetContainer, 8, Compact and 6 or 8, 8, Compact and 6 or 8)
	ListLayout(SetContainer, 2)

	------------------------------------------------------------------ pages + overlays
	ThemeBind(Window, {BackgroundTransparency = function() return Style.WindowT end})
	for _, surface in ipairs({Topbar, Footer, Sidebar}) do
		-- FlatChrome: bars and sidebar let the window's own surface show through
		ThemeBind(surface, {BackgroundTransparency = function() return Style.FlatChrome and 1 or Style.WindowT end})
		for _, filler in ipairs(surface:GetChildren()) do
			if filler:IsA("Frame") and filler.Size.Y.Offset == 4 then
				ThemeBind(filler, {BackgroundTransparency = function() return Style.FlatChrome and 1 or 0 end})
			end
		end
	end
	New("UIGradient", {Rotation = 90, Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(150, 150, 160)), Theme = {Enabled = function() return Style.WindowGradient == true end}, Parent = Window})
	local MainPages = New("Frame", {Size = UDim2.new(1, -(SIDE + 1), 1, -BODY_H), Position = UDim2.fromOffset(SIDE + 1, TOP + 1), BackgroundTransparency = 1, ClipsDescendants = true, Parent = Window})

	local Resizer = New("Frame", {Size = UDim2.fromOffset(18, 18), Position = UDim2.fromScale(1, 1), AnchorPoint = Vector2.new(1, 1), BackgroundTransparency = 1, Active = true, ZIndex = 20, Parent = Window})
	local grip1 = DecorLine(Resizer, 5, 14, 14, 5, "TextMuted", 0, 1)
	local grip2 = DecorLine(Resizer, 9, 14, 14, 9, "TextMuted", 0, 1)
	Track(Resizer.MouseEnter, function()
		Tween(grip1, {BackgroundColor3 = Theme.Accent}, 0.2)
		Tween(grip2, {BackgroundColor3 = Theme.Accent}, 0.2)
	end)
	Track(Resizer.MouseLeave, function()
		Tween(grip1, {BackgroundColor3 = Theme.TextMuted}, 0.3)
		Tween(grip2, {BackgroundColor3 = Theme.TextMuted}, 0.3)
	end)
	MakeResizable(Resizer, Holder, Vector2.new(560, 340))
	MakeDraggable(Topbar, Holder)

	local function RefreshDecor()
		local builders = {Halloween = BuildHalloweenDecor, Christmas = BuildChristmasDecor}
		local want = Library.DecorEnabled and builders[Library.CurrentTheme] and Library.CurrentTheme or nil
		local d = Window:FindFirstChild("SeasonDecor")
		if d and d:GetAttribute("Season") == want then return end
		if d then d:Destroy() end
		if want then
			local built = builders[want](Window, TOP + 1)
			built.Name = "SeasonDecor"
			built:SetAttribute("Season", want)
		end
	end
	OnThemeChanged(RefreshDecor)
	RefreshDecor()

	local SearchResults = New("Frame", {Size = UDim2.fromOffset(300, 0), Position = UDim2.new(1, -76, 0, TOP + 4), AnchorPoint = Vector2.new(1, 0), ClipsDescendants = true, Visible = false, ZIndex = 300, Theme = {BackgroundColor3 = "Topbar"}, Parent = Window})
	Corner(SearchResults, 5)
	Stroke(SearchResults, "Stroke", 0)
	local ResultsList = New("ScrollingFrame", {Size = UDim2.fromScale(1, 1), ScrollBarThickness = 2, ZIndex = 301, Parent = SearchResults})
	Padding(ResultsList, 4, 4, 4, 4)
	ListLayout(ResultsList, 2)

	local PopupLayer = New("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 350, Parent = Window})
	local Veil = New("Frame", {Size = UDim2.fromScale(1, 1), ZIndex = 500, Theme = {BackgroundColor3 = "Background"}, Parent = Window})
	Corner(Veil, 4)

	
	local ActiveMenu
	local function CloseMenu()
		if not ActiveMenu then return end
		local m = ActiveMenu
		ActiveMenu = nil
		Tween(m, {Size = UDim2.fromOffset(m.Size.X.Offset, 0)}, 0.15).Completed:Connect(function() m:Destroy() end)
	end
	local function OpenMenu(anchor, items, current, onPick)
		CloseMenu()
		local sc = UIScaleValue()
		local rel = (anchor.AbsolutePosition - Window.AbsolutePosition) / sc
		local w, h = 104, #items * 28 + 8
		local Menu = New("Frame", {Size = UDim2.fromOffset(w, 0), Position = UDim2.fromOffset(rel.X + anchor.AbsoluteSize.X / sc - w, rel.Y + anchor.AbsoluteSize.Y / sc + 4), ClipsDescendants = true, ZIndex = 360, Theme = {BackgroundColor3 = "Topbar"}, Parent = PopupLayer})
		Corner(Menu, 4)
		Stroke(Menu, "Stroke", 0)
		Padding(Menu, 4, 4, 4, 4)
		ListLayout(Menu, 0)
		for i, item in ipairs(items) do
			local isCur = item == current
			local b = New("TextButton", {Size = UDim2.new(1, 0, 0, 28), Text = item, TextSize = 13, BackgroundTransparency = 1, LayoutOrder = i, ZIndex = 361, Theme = {BackgroundColor3 = "Hover", TextColor3 = isCur and "Accent" or "TextDark"}, Parent = Menu})
			Corner(b, 3)
			Track(b.MouseEnter, function() Tween(b, {BackgroundTransparency = 0}, 0.12) end)
			Track(b.MouseLeave, function() Tween(b, {BackgroundTransparency = 1}, 0.18) end)
			Track(b.MouseButton1Click, function()
				CloseMenu()
				onPick(item)
			end)
		end
		ActiveMenu = Menu
		Tween(Menu, {Size = UDim2.fromOffset(w, h)}, 0.25)
	end
	Track(UserInputService.InputBegan, function(input)
		if not ActiveMenu or not IsPress(input) then return end
		local ap, sz = ActiveMenu.AbsolutePosition, ActiveMenu.AbsoluteSize
		local p = input.Position
		if p.X < ap.X or p.X > ap.X + sz.X or p.Y < ap.Y or p.Y > ap.Y + sz.Y then CloseMenu() end
	end)

	
	local openToken = 0
	local function SetBlur(on)
		pcall(function()
			local b = Lighting:FindFirstChild("PhantomBlur")
			if on and not b then
				b = Instance.new("BlurEffect")
				b.Name = "PhantomBlur"
				b.Size = 0
				b.Parent = Lighting
			end
			if b then Tween(b, {Size = on and 14 or 0}, 0.4) end
		end)
	end

	local function ShowWindow(state)
		openToken += 1
		local my = openToken
		Library.Open = state
		if state then
			Holder.Visible = true
			Veil.Visible = true
			Veil.BackgroundTransparency = 0
			MainScale.Scale = EffectiveScale() * 0.92
			Tween(MainScale, {Scale = EffectiveScale()}, 0.5)
			Tween(Veil, {BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Quad).Completed:Connect(function()
				if openToken == my then Veil.Visible = false end
			end)
		else
			HideTooltip()
			CloseMenu()
			SearchInput:ReleaseFocus()
			Veil.Visible = true
			Tween(Veil, {BackgroundTransparency = 0}, 0.16, Enum.EasingStyle.Quad)
			Tween(MainScale, {Scale = EffectiveScale() * 0.92}, 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.In).Completed:Connect(function()
				if openToken == my then Holder.Visible = false end
			end)
		end
		SetBlur(state and Library.BlurEnabled)
	end
	Library._ShowWindow = ShowWindow

	Track(CloseBtn.MouseButton1Click, function()
		ShowWindow(false)
		task.delay(0.3, function() Library:Unload() end)
	end)
	Track(MinBtn.MouseButton1Click, function() ShowWindow(false) end)

	
	local MiniGui = New("ScreenGui", {Name = "PhantomMiniButton", IgnoreGuiInset = true, ResetOnSpawn = false, Enabled = not Library.UIHidden, Parent = GetParent()})
	local MiniButton = New("ImageButton", {Visible = Library.MiniButtonEnabled, Size = UDim2.fromOffset(48, 48), Position = UDim2.new(0, 20, 0.5, -24), Image = ASSET_LOGO, ScaleType = Enum.ScaleType.Fit, BackgroundTransparency = 0.05, Active = true, Theme = {BackgroundColor3 = "Background", ImageColor3 = "Accent"}, Parent = MiniGui})
	Corner(MiniButton, 24)
	Padding(MiniButton, 9, 9, 9, 9)
	local MiniStroke = Stroke(MiniButton, "Accent", 0.2, 2)
	local MiniScale = New("UIScale", {Parent = MiniButton})
	local miniDragged = false
	Track(MiniButton.InputBegan, function(input) if IsPress(input) then miniDragged = false end end)
	MakeDraggable(MiniButton, MiniButton, function() miniDragged = true end)
	Track(MiniButton.MouseEnter, function() Tween(MiniScale, {Scale = 1.08}, 0.3, Enum.EasingStyle.Back) end)
	Track(MiniButton.MouseLeave, function() Tween(MiniScale, {Scale = 1}, 0.3) end)
	Track(MiniButton.MouseButton1Click, function()
		if miniDragged then
			miniDragged = false
			return
		end
		ShowWindow(not Library.Open)
	end)

	Track(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
		if Library.Open then MainScale.Scale = EffectiveScale() end
	end)

	Track(UserInputService.InputBegan, function(input, gp)
		if gp then return end
		if Library.UIHidden and (input.KeyCode == Config.Keybind or input.KeyCode == Config.HideKeybind) then
			Library:SetUIHidden(false)
		elseif input.KeyCode == Config.Keybind then
			ShowWindow(not Library.Open)
		elseif input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode == Config.HideKeybind then
			Library:SetUIHidden(not Library.UIHidden)
		end
	end)

	
	local WindowObj = {}
	local AllPages = {}
	local MainState = {List = TabContainer, Tabs = {}, Active = nil}
	local SetState = {List = SetContainer, Tabs = {}, Active = nil}
	local InSettings = false

	local function ShowPage(page)
		for _, p in ipairs(AllPages) do
			if p ~= page then p.Visible = false end
		end
		if page.Visible then return end
		page.Visible = true
		page.Position = UDim2.fromOffset(10, 26)
		Tween(page, {Position = UDim2.fromOffset(10, 10)}, 0.4)
	end

	local function SetMode(settings, skipActivate)
		InSettings = settings
		Library._IsSettings = settings
		Tween(MainStack, {Position = settings and UDim2.fromScale(-1, 0) or UDim2.fromScale(0, 0)}, 0.45)
		Tween(SetStack, {Position = settings and UDim2.fromScale(0, 0) or UDim2.fromScale(1, 0)}, 0.45)
		if not skipActivate then
			local st = settings and SetState or MainState
			if st.Active then st.Active.Activate() end
		end
	end
	Track(Profile.MouseButton1Click, function() SetMode(true) end)
	Track(BackBtn.MouseButton1Click, function() SetMode(false) end)

	local function CreateTabButton(list, name, icon, order)
		local active, hovered = false, false
		local Btn = New("TextButton", {Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, LayoutOrder = order, Theme = {BackgroundColor3 = "Container"}, Parent = list})
		Corner(Btn, SMALL_R)
		local textX = 10
		local Ico
		if icon then
			Ico = New("ImageLabel", {Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 10, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Theme = {ImageColor3 = function() return active and Theme.Accent or Theme.Text end}, ImageTransparency = 0.5, Parent = Btn})
			if ApplyIcon(Ico, icon) then
				textX = 34
			else
				Ico:Destroy()
				Ico = nil
			end
		end
		local Title = New("TextLabel", {Text = name, TextSize = 14, TextTransparency = 0.5, Size = UDim2.new(1, -(textX + 6), 1, 0), Position = UDim2.fromOffset(textX, 0), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = Btn})
		local hasIcon = Ico ~= nil
		local function ShowIcon() return hasIcon and (Compact or Style.TabIcons) end
		if Ico then ThemeBind(Ico, {Visible = ShowIcon}) end
		ThemeBind(Title, {Position = function() return UDim2.fromOffset(ShowIcon() and 34 or 14, 0) end})
		local function ActiveBg() return Style.TabPill and Theme.Section:Lerp(Theme.Accent, 0.2) or Theme.Container end
		ThemeBind(Btn, {BackgroundColor3 = ActiveBg})
		local function Visual(instant)
			local t = instant and 0 or 0.15
			Tween(Btn, {BackgroundTransparency = active and 0 or 1, BackgroundColor3 = ActiveBg()}, t)
			Tween(Title, {TextTransparency = active and 0 or (hovered and 0.2 or 0.5)}, t)
			if Ico then Tween(Ico, {ImageTransparency = (active or hovered) and 0 or 0.5, ImageColor3 = active and Theme.Accent or Theme.Text}, t) end
		end
		if Compact and Ico then
			Title.Visible = false
			Ico.Position = UDim2.fromScale(0.5, 0.5)
			Ico.AnchorPoint = Vector2.new(0.5, 0.5)
			Btn.Size = UDim2.new(1, 0, 0, 34)
			ApplyTooltip(Btn, name)
		end
		Track(Btn.MouseEnter, function() hovered = true Visual() end)
		Track(Btn.MouseLeave, function() hovered = false Visual() end)
		table.insert(StyleHooks, function() Visual(true) end)
		return {Instance = Btn, SetActive = function(state, instant) active = state Visual(instant) end}
	end

	local function CreateTab(name, icon, state, isSettings)
		local Tab = {}
		local Page = New("ScrollingFrame", {Size = UDim2.new(1, -20, 1, -10), Position = UDim2.fromOffset(10, 10), Visible = false, Active = true, ScrollBarThickness = 3, Parent = MainPages})
		Padding(Page, 0, 8, 16, 0)
		table.insert(AllPages, Page)
		local TB = CreateTabButton(state.List, name, icon, #state.Tabs + 1)
		local entry = {Page = Page, Button = TB}
		table.insert(state.Tabs, entry)

		local function Activate()
			if isSettings ~= InSettings then SetMode(isSettings, true) end
			for _, e in ipairs(state.Tabs) do e.Button.SetActive(e == entry) end
			state.Active = entry
			ShowPage(Page)
			if not isSettings then WindowObj._ActiveTabBtn = TB.Instance end
		end
		entry.Activate = Activate
		Tab.Activate = Activate
		Tab.Page = Page
		Track(TB.Instance.MouseButton1Click, Activate)

		if #state.Tabs == 1 then
			TB.SetActive(true, true)
			state.Active = entry
			if isSettings == InSettings then
				for _, p in ipairs(AllPages) do p.Visible = false end
				Page.Visible = true
			end
			if not isSettings then WindowObj._ActiveTabBtn = TB.Instance end
		end

		local searchEntry = {Tab = name, Page = Page, Activate = Activate, Sections = {}}
		table.insert(Library.SearchIndex, searchEntry)

		local vp = workspace.CurrentCamera.ViewportSize
		local isMobile = vp.X < 700 or (vp.X / math.max(vp.Y, 1)) < 1.3
		
		ListLayout(Page, 10)
		local FullCol = New("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1, Parent = Page})
		local Columns = New("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 2, Parent = Page})
		local LeftCol = New("Frame", {BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Parent = Columns})
		local RightCol = New("Frame", {BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Parent = Columns})
		if isMobile then
			ListLayout(Columns, 10)
			LeftCol.Size = UDim2.new(1, 0, 0, 0)
			LeftCol.LayoutOrder = 1
			RightCol.Size = UDim2.new(1, 0, 0, 0)
			RightCol.LayoutOrder = 2
		else
			LeftCol.Size = UDim2.new(0.5, -5, 0, 0)
			RightCol.Size = UDim2.new(0.5, -5, 0, 0)
			RightCol.Position = UDim2.new(0.5, 5, 0, 0)
		end
		ListLayout(FullCol, 10)
		ListLayout(LeftCol, 10)
		ListLayout(RightCol, 10)
		local colOrder = {[LeftCol] = 0, [RightCol] = 0, [FullCol] = 0}
		
		local function SyncAreas()
			FullCol.Visible = colOrder[FullCol] > 0
			Columns.Visible = colOrder[LeftCol] + colOrder[RightCol] > 0
		end
		SyncAreas()

		
		function Tab:Section(text, side)
			local Section = {}
			local col = side == "Right" and RightCol or side == "Full" and FullCol or LeftCol
			colOrder[col] += 1
			SyncAreas()
			local Container, Content = CreateSectionFrame(text, col, colOrder[col])
			Section.Container = Container
			local secData = {Instance = Container, Items = {}, Title = text}
			table.insert(Library.Elements, secData)
			table.insert(searchEntry.Sections, secData)
			return AttachElements(Section, Content, {
				SectionName = text,
				Bindable = not isSettings,
				Page = Page,
				OpenMenu = OpenMenu,
				AddItem = function(n, inst) table.insert(secData.Items, {Name = n, Instance = inst}) end,
				
				MakeFull = function()
					if Container.Parent == FullCol then return end
					colOrder[col] -= 1
					colOrder[FullCol] += 1
					Container.LayoutOrder = colOrder[FullCol]
					Container.Parent = FullCol
					SyncAreas()
				end,
			})
		end
		return Tab
	end

	function WindowObj:Tab(name, iconId)
		return CreateTab(name, iconId, MainState, false)
	end

	function WindowObj:CreateRawSection(text, parent)
		local Section = {}
		local Container, Content = CreateSectionFrame(text, parent)
		Section.Container = Container
		return AttachElements(Section, Content, {SectionName = text, Bindable = false, OpenMenu = OpenMenu})
	end

	
	local function HighlightItem(inst)
		if not inst or not inst.Parent then return end
		local flash = New("UIStroke", {Color = Theme.Accent, Thickness = 2, Parent = inst})
		task.delay(0.2, function()
			Tween(flash, {Transparency = 1}, 1.2, Enum.EasingStyle.Sine).Completed:Connect(function() flash:Destroy() end)
		end)
	end

	local function GoToResult(entry, inst)
		if entry.Activate then entry.Activate() end
		task.delay(0.05, function()
			if not inst or not inst.Parent then return end
			local page = entry.Page
			if page then
				RunService.RenderStepped:Wait()
				local rel = (inst.AbsolutePosition.Y - page.AbsolutePosition.Y) / UIScaleValue() + page.CanvasPosition.Y
				Tween(page, {CanvasPosition = Vector2.new(0, math.max(rel - 12, 0))}, 0.45)
			end
			HighlightItem(inst)
		end)
	end

	local function ShowResults(count)
		local h = count > 0 and math.min(count * 32 + 10, 260) or 0
		if count > 0 then SearchResults.Visible = true end
		Tween(SearchResults, {Size = UDim2.fromOffset(300, h)}, 0.3).Completed:Connect(function()
			if SearchResults.Size.Y.Offset == 0 then SearchResults.Visible = false end
		end)
	end

	local function AddResultRow(tabName, itemName, order, onClick)
		local Row = New("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = order, ZIndex = 302, Theme = {BackgroundColor3 = "Hover"}, Parent = ResultsList})
		Corner(Row, 3)
		New("TextLabel", {Size = UDim2.new(0.62, -10, 1, 0), Position = UDim2.fromOffset(10, 0), Text = itemName, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 303, Parent = Row})
		New("TextLabel", {Size = UDim2.new(0.38, -10, 1, 0), Position = UDim2.fromScale(0.62, 0), Text = tabName, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 303, Theme = {TextColor3 = "TextMuted"}, Parent = Row})
		Track(Row.MouseEnter, function() Tween(Row, {BackgroundTransparency = 0}, 0.12) end)
		Track(Row.MouseLeave, function() Tween(Row, {BackgroundTransparency = 1}, 0.18) end)
		if onClick then
			Track(Row.MouseButton1Click, function()
				SearchInput.Text = ""
				onClick()
			end)
		end
	end

	local function RunSearch(query)
		for _, c in ipairs(ResultsList:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		query = tostring(query or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
		if #query < 2 then
			ShowResults(0)
			return
		end
		local count = 0
		for _, entry in ipairs(Library.SearchIndex) do
			if count < 40 and entry.Tab:lower():find(query, 1, true) then
				count += 1
				AddResultRow("Tab", entry.Tab, count, function() entry.Activate() end)
			end
			for _, sec in ipairs(entry.Sections) do
				if count < 40 and sec.Title and tostring(sec.Title):lower():find(query, 1, true) then
					count += 1
					local secInst = sec.Instance
					AddResultRow(entry.Tab, sec.Title, count, function() GoToResult(entry, secInst) end)
				end
				for _, item in ipairs(sec.Items) do
					if count >= 40 then break end
					local nm = tostring(item.Name or "")
					local plain = nm:gsub("<[^>]->", "")
					if plain ~= "" and plain:lower():find(query, 1, true) then
						count += 1
						local inst = item.Instance
						AddResultRow(entry.Tab, plain, count, function() GoToResult(entry, inst) end)
					end
				end
			end
		end
		if count == 0 then
			AddResultRow("", "No results", 1, nil)
			count = 1
		end
		ShowResults(count)
	end
	Track(SearchInput:GetPropertyChangedSignal("Text"), function() RunSearch(SearchInput.Text) end)
	Track(SearchInput.Focused, function()
		Tween(SStroke, {Color = Theme.Accent, Transparency = 0}, 0.2)
		Tween(SearchBox, {Size = UDim2.fromOffset(250, 26)}, 0.25)
	end)
	Track(SearchInput.FocusLost, function()
		Tween(SStroke, {Color = Theme.Stroke, Transparency = 1}, 0.25)
		Tween(SearchBox, {Size = UDim2.fromOffset(220, 26)}, 0.25)
		task.delay(0.2, function()
			if SearchInput.Text == "" then ShowResults(0) end
		end)
	end)

	
	local function MarkInterface() Library.InterfaceDirty = true end

	local function PopulateSettings()
		local General = CreateTab("General", "settings", SetState, true)
		local Appearance = CreateTab("Appearance", "palette", SetState, true)
		local Keys = CreateTab("Keybinds", "keyboard", SetState, true)
		local Configs = CreateTab("Configs", "layers", SetState, true)

		
		------------------------------------------------ General
		local Iface = General:Section("Interface")
		Iface:Toggle("Watermark", "WatermarkToggle", Library.WatermarkEnabled, "FPS / ping bar in the corner", function(state)
			Library.WatermarkEnabled = state
			if Library.Watermark then Library.Watermark.Visible = state end
			MarkInterface()
		end)
		Iface:Toggle("Reopen button", "MiniButtonToggle", Library.MiniButtonEnabled, "Floating logo button that opens the menu (handy on mobile)", function(state)
			Library.MiniButtonEnabled = state
			MiniButton.Visible = state
			MarkInterface()
		end)
		Iface:Toggle("Tooltips", "TooltipsToggle", Library.TooltipsEnabled, "Show hints when hovering things", function(state)
			Library.TooltipsEnabled = state
			if not state then HideTooltip() end
			MarkInterface()
		end)
		Iface:Toggle("Animations", "AnimationsToggle", Library.Animations, "Turn off for instant transitions", function(state)
			Library.Animations = state
			MarkInterface()
		end)
		Iface:Toggle("Console", "ConsoleToggle", false, "Window with info, warnings and errors", function(state)
			Library:SetConsoleVisible(state)
		end)

		local Notes = General:Section("Notifications")
		Notes:Dropdown("Position", "NotifySide", {"Bottom right", "Top right", "Bottom left", "Top left"}, Library.NotifySide, "Corner the notifications stack in", function(side)
			if type(side) ~= "string" then return end
			Library.NotifySide = side
			MarkInterface()
		end)
		Notes:Button("Send a test notification", nil, function()
			Library:Notify("Test", "This is how notifications look.", 3, "Success")
		end)

		local Session = General:Section("Session", "Right")
		Session:Row("Profiles folder", Config.ConfigFolder)
		Session:Divider()
		Session:Label("Unloading removes the hub and everything it added to the game.")
		local armed = false
		local UnloadBtn
		UnloadBtn = Session:Button("Unload hub", "Click twice to confirm", function()
			if not armed then
				armed = true
				UnloadBtn.Text = "Click again to unload"
				task.delay(3, function()
					if armed and UnloadBtn.Parent then
						armed = false
						UnloadBtn.Text = "Unload hub"
					end
				end)
				return
			end
			ShowWindow(false)
			task.delay(0.3, function() Library:Unload() end)
		end)
		ThemeBind(UnloadBtn, {TextColor3 = "Danger"})

		------------------------------------------------ Appearance
		local LookSec = Appearance:Section("Look")
		LookSec:Dropdown("Style", "UIStyle", StyleOrder, Library.StyleName, "OG, Obsidian, Fluent or Modern. Changes the whole look instantly", function(name)
			if type(name) == "string" and name ~= Library.StyleName then
				Library:SetStyle(name)
				Library:Notify("Style", name .. " style applied", 2, "Success")
			end
		end)
		LookSec:Label("Your accent preset and custom colors stay on top of any style.")

		local ThemeSec = Appearance:Section("Theme")
		ThemeSec:Dropdown("Preset", "SelectedTheme", ThemeOrder, Library.CurrentTheme, "Pick an accent preset", function(name)
			if type(name) == "string" and (name ~= Library.CurrentTheme or Library.CustomAccent) then Library:SetTheme(name) end
		end)
		local AccentPicker = ThemeSec:ColorPicker("Accent", "MenuAccentColor", Theme.Accent, "Main highlight color", function(col)
			if col ~= Theme.Accent then Library:UpdateTheme(col) end
		end)
		OnThemeChanged(function()
			if AccentPicker:Get() ~= Theme.Accent then AccentPicker:Set(Theme.Accent, true) end
		end)

		-- every base color can be overridden; overrides survive switching presets
		local ColorSec = Appearance:Section("Colors")
		local colorPickers = {}
		local function ColorOption(label, flagName, keys, tip)
			local picker = ColorSec:ColorPicker(label, flagName, Theme[keys[1]], tip, function(col)
				if col == Theme[keys[1]] then return end
				for _, key in ipairs(keys) do Library.CustomColors[key] = col end
				Library:SetColor(keys[1], col)
			end)
			table.insert(colorPickers, {Picker = picker, Key = keys[1]})
		end
		ColorOption("Background", "ColorBackground", {"Background"}, "Window and page background")
		ColorOption("Panels", "ColorPanels", {"Section", "Sidebar", "Topbar"}, "Groupboxes, sidebar, top bar and footer")
		ColorOption("Controls", "ColorControls", {"Container"}, "Buttons, switches, sliders, boxes")
		ColorOption("Outline", "ColorOutline", {"Stroke"}, "Borders and divider lines")
		ColorOption("Text", "ColorText", {"Text"}, "Main text")
		ColorOption("Dim text", "ColorTextDark", {"TextDark"}, "Labels, hints and inactive items")
		ColorSec:Button("Reset colors", "Back to the preset's original colors", function()
			Library:ResetColors()
			for _, cp in ipairs(colorPickers) do cp.Picker:Set(Theme[cp.Key], true) end
			AccentPicker:Set(Theme.Accent, true)
		end)

		local StyleSec = Appearance:Section("Style", "Right")
		local FontPicker = StyleSec:Dropdown("Font", "FontChoice", FontOrder, Library.FontName, "Code is the Obsidian look", function(name)
			if type(name) == "string" and name ~= Library.FontName then Library:SetFont(name) end
		end)
		local CornerPicker = StyleSec:Dropdown("Corners", "CornerStyle", {"Sharp", "Default", "Medium", "Round", "Soft"}, Library.Rounding, "How rounded boxes and buttons are", function(style)
			if type(style) == "string" and style ~= Library.Rounding then Library:SetRounding(style) end
		end)
		StyleSec:Slider("Interface scale", "InterfaceScale", 60, 140, math.round(Library.UserScale * 100), 5, "Size of the whole menu in percent", function(v)
			Library.UserScale = v / 100
			if Library.Open then Tween(MainScale, {Scale = EffectiveScale()}, 0.3) end
			MarkInterface()
		end)
		StyleSec:Toggle("Background blur", "BlurToggle", Library.BlurEnabled, "Blur the game behind the open menu", function(state)
			Library.BlurEnabled = state
			SetBlur(state and Library.Open)
			MarkInterface()
		end)
		StyleSec:Toggle("Seasonal decorations", "DecorToggle", Library.DecorEnabled, "Cobwebs on Halloween, snow on Christmas", function(state)
			Library.DecorEnabled = state
			RefreshDecor()
			MarkInterface()
		end)

		table.insert(StyleHooks, function()
			FontPicker:Set(Library.FontName)
			CornerPicker:Set(Library.Rounding)
			for _, cp in ipairs(colorPickers) do cp.Picker:Set(Theme[cp.Key], true) end
		end)

		------------------------------------------------ Keybinds
		local MenuKeys = Keys:Section("Menu")
		MenuKeys:KeyPicker("Open / close menu", Config.Keybind, function(k)
			if k == Enum.KeyCode.Unknown then return end
			Config.Keybind = k
			Library:Notify("Keybinds", "Menu key set to " .. k.Name, 2, "Success")
			MarkInterface()
		end, false)
		MenuKeys:KeyPicker("Hide everything", Config.HideKeybind, function(k)
			Config.HideKeybind = k
			Library:Notify("Keybinds", k == Enum.KeyCode.Unknown and "Hide key cleared" or ("Hide key set to " .. k.Name), 2, "Success")
			MarkInterface()
		end, true)
		MenuKeys:Label("Backspace clears a key, Escape cancels.")

		local ListSec = Keys:Section(IsTouchOnly() and "Quick toggles" or "Keybind list", "Right")
		ListSec:Toggle(IsTouchOnly() and "Show quick toggles" or "Show keybind list", "KeybindListToggle", Library.ShowKeybinds, "Floating panel with your binds", function(state)
			Library.ShowKeybinds = state
			RefreshBindList()
			MarkInterface()
		end)
		ListSec:Button("Reset panel position", nil, function()
			if not Library.KeybindList then Library:CreateKeybindList() end
			Tween(Library.KeybindList.Frame, {Position = UDim2.new(0, 16, 0.35, 0)}, 0.3)
		end)
		if IsTouchOnly() then
			ListSec:Label("Tap Pin next to any toggle. Pinned toggles show up in the Quick toggles panel so you can switch them with one tap.")
		else
			ListSec:Label("Click a key box to bind it. Right click it to switch between Toggle, Hold and Always.")
		end

		------------------------------------------------ Configs
		local Profiles = Configs:Section("Profiles")
		local NameInput = Profiles:TextBox("Name", "ConfigNameFlag", "New profile name", "Name for a new profile", function() end)
		local list = Library:GetConfigs()
		local Picker = Profiles:Dropdown("Profile", "ConfigSelectorFlag", list, list[1], "Saved profiles", function() end)
		local function Selected()
			local sel = Picker:GetSelected()
			if type(sel) ~= "string" or sel == "" then return nil end
			return sel
		end
		local function RefreshList(select)
			local newList = Library:GetConfigs()
			local keep = select or Selected()
			if not keep or not table.find(newList, keep) then keep = newList[1] end
			Picker:Refresh(newList, keep)
		end
		Profiles:Button("Create profile", "Save the current settings as a new profile", function()
			local name = (NameInput.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
			if name == "" then
				Library:Notify("Configs", "Type a profile name first", 3, "Warning")
				return
			end
			if Library:ConfigExists(name) then
				Library:Notify("Configs", "A profile named " .. name .. " already exists", 3, "Warning")
				return
			end
			if Library:SaveConfig(name) then
				NameInput.Text = ""
				RefreshList(name)
				Library:Notify("Configs", "Created " .. name, 3, "Success")
			else
				Library:Notify("Configs", "Could not create the profile (error)", 3, "Error")
			end
		end)
		Profiles:Button("Load profile", "Apply the selected profile", function()
			local name = Selected()
			if not name then return Library:Notify("Configs", "No profile selected", 3, "Warning") end
			if Library:LoadConfig(name) then
				Library:Notify("Configs", "Loaded " .. name, 3, "Success")
			else
				Library:Notify("Configs", "Could not load " .. name .. " (error)", 3, "Error")
			end
		end)
		Profiles:Button("Overwrite profile", "Save current settings into the selected profile", function()
			local name = Selected()
			if not name then return Library:Notify("Configs", "No profile selected", 3, "Warning") end
			if Library:SaveConfig(name) then
				Library:Notify("Configs", "Saved over " .. name, 3, "Success")
			else
				Library:Notify("Configs", "Could not save " .. name .. " (error)", 3, "Error")
			end
		end)
		local delArmed = false
		local DeleteBtn
		DeleteBtn = Profiles:Button("Delete profile", "Click twice to confirm", function()
			local name = Selected()
			if not name then return Library:Notify("Configs", "No profile selected", 3, "Warning") end
			if not delArmed then
				delArmed = true
				DeleteBtn.Text = "Click again to delete " .. name
				task.delay(3, function()
					if delArmed and DeleteBtn.Parent then
						delArmed = false
						DeleteBtn.Text = "Delete profile"
					end
				end)
				return
			end
			delArmed = false
			DeleteBtn.Text = "Delete profile"
			if Library:DeleteConfig(name) then
				RefreshList()
				Library:Notify("Configs", "Deleted " .. name, 3, "Success")
			end
		end)
		ThemeBind(DeleteBtn, {TextColor3 = "Danger"})

		local Opts = Configs:Section("Options", "Right")
		Opts:Toggle("Autosave", "AutosaveToggle", Library.AutoSaveEnabled, "Save your settings automatically every few seconds", function(state)
			Library.AutoSaveEnabled = state
		end)
		Opts:Button("Refresh list", "Re-read the profile folder", function()
			RefreshList()
			Library:Notify("Configs", "Profile list refreshed", 2, "Success")
		end)
		Opts:Button("Reset to defaults", "Put every feature back to its default value", function()
			for flag, val in pairs(Library.Defaults) do
				if not IgnoredFlags[flag] then
					Library.Flags[flag] = val
					if Library.Signals[flag] then task.spawn(Library.Signals[flag], val) end
				end
			end
			Library:Notify("Configs", "Everything is back to default", 3, "Success")
		end)
		Opts:Label("Profiles are saved in the " .. Config.ConfigFolder .. " folder.")
	end

	
	local InfoTab = WindowObj:Tab("Info", "89366818397358")
	PopulateSettings()

	
	-- left: who / where
	local Overview = InfoTab:Section("Overview")
	Overview:Label("Welcome back, " .. LocalPlayer.DisplayName .. ".")
	Overview:Divider()
	Overview:Row("Game", GameName)
	local PlayersRow = Overview:Row("Players", "")
	local TimeRow = Overview:Row("Session", "0:00")
	local UptimeRow = Overview:Row("Server uptime", "")
	local executor = "Unknown"
	pcall(function()
		if typeof(identifyexecutor) == "function" then executor = (identifyexecutor()) or executor end
	end)
	Overview:Row("Executor", tostring(executor))

	local function Clock(sec)
		sec = math.floor(sec)
		local h, m, sx = math.floor(sec / 3600), math.floor(sec % 3600 / 60), sec % 60
		if h > 0 then return string.format("%d:%02d:%02d", h, m, sx) end
		return string.format("%d:%02d", m, sx)
	end
	local started = os.clock()
	local lastTick = 0
	Track(RunService.Heartbeat, function()
		local now = os.clock()
		if now - lastTick < 1 then return end
		lastTick = now
		PlayersRow:Set(#Players:GetPlayers() .. "/" .. Players.MaxPlayers)
		TimeRow:Set(Clock(now - started))
		UptimeRow:Set(Clock(workspace.DistributedGameTime))
	end)

	local Server = InfoTab:Section("Server")
	local MenuKeyRow = Server:Row("Menu key", Config.Keybind.Name)
	Track(RunService.Heartbeat, function()
		if MenuKeyRow.Value ~= Config.Keybind.Name then MenuKeyRow:Set(Config.Keybind.Name) end
	end)
	Server:Button("Copy server ID", "Share it so friends can join the same server", function()
		CopyLink(game.JobId ~= "" and game.JobId or "Studio session", "Server ID")
	end)
	Server:Button("Rejoin", nil, function()
		Library:Notify("Rejoining", "Teleporting back into this server", 3)
		pcall(function()
			game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
		end)
	end)

	-- right: changelog + links
	local log = Library.HubConfig.UpdateLog or {}
	local hasAdded = type(log.Added) == "table" and #log.Added > 0
	local hasFixed = type(log.Fixed) == "table" and #log.Fixed > 0
	if hasAdded or hasFixed then
		local Changelog = InfoTab:Section("Changelog", "Right")
		if log.Date and log.Date ~= "" then
			Changelog:Row("Released", log.Date)
			Changelog:Divider()
		end
		if hasAdded then for _, v in ipairs(log.Added) do Changelog:Bullet(tostring(v), "added") end end
		if hasFixed then for _, v in ipairs(log.Fixed) do Changelog:Bullet(tostring(v), "fixed") end end
	end

	local Links = InfoTab:Section(Library.HubConfig.Name, "Right")
	Links:Label("Updates, support and new scripts are posted on the Discord.")
	Links:Button("Copy Discord invite", nil, function() CopyLink(Library.HubConfig.Socials.Discord, "Discord") end)
	Links:Button("Copy YouTube link", nil, function() CopyLink(Library.HubConfig.Socials.YouTube, "YouTube") end)

	local saveTimer, ifaceTimer = 0, 0
	Track(RunService.Heartbeat, function(dt)
		if Library.AutoSaveEnabled and Library.Unsaved then
			saveTimer += dt
			if saveTimer >= 3 then
				saveTimer = 0
				Library.Unsaved = false
				Library:SaveConfig("_autosave")
			end
		end
		if Library.InterfaceDirty then
			ifaceTimer += dt
			if ifaceTimer >= 1 then
				ifaceTimer = 0
				Library.InterfaceDirty = false
				SaveInterface()
			end
		end
	end)
	task.defer(function() Library:LoadConfig("_autosave") end)

	task.defer(function() ShowWindow(true) end)
	return WindowObj
end

return Library
