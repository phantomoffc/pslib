local HUB_NAME = "Phantom Softworks"

if getgenv().BloxStrikeUnload then
    pcall(getgenv().BloxStrikeUnload)
    task.wait(0.5)
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/phantomoffc/pslib/refs/heads/main/huy.lua"))()

local Executor = { Missing = {} }
do
	local ok, name = pcall(function()
		return identifyexecutor()
	end)
	Executor.Name = ok and tostring(name or "Unknown") or "Unknown"
	local lower = Executor.Name:lower()
	Executor.CanHook = type(hookmetamethod) == "function" and type(getnamecallmethod) == "function"
	Executor.CanHookFunction = type(hookfunction) == "function"
	Executor.CanGC = type(getgc) == "function"
	Executor.Weak = lower:find("xeno") ~= nil or lower:find("solara") ~= nil or lower:find("jjsploit") ~= nil or not Executor.CanHook
	if not Executor.CanGC then
		table.insert(Executor.Missing, "getgc")
	end
	if not Executor.CanHook then
		table.insert(Executor.Missing, "hooks")
	end

	local function fill(name, fn)
		if type(getfenv and getfenv(1)[name] or nil) ~= "function" and type(rawget(_G, name)) ~= "function" then
			local okSet = pcall(function()
				getfenv(1)[name] = fn
			end)
			if not okSet then
				_G[name] = fn
			end
		end
	end

	fill("getgenv", function()
		return _G
	end)
	fill("cloneref", function(o)
		return o
	end)
	fill("newcclosure", function(f)
		return f
	end)
	fill("setthreadidentity", function() end)
	fill("getthreadidentity", function()
		return 2
	end)
	fill("gethui", function()
		local okCore, core = pcall(function()
			return game:GetService("CoreGui")
		end)
		return okCore and core or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	end)
	fill("isfile", function()
		return false
	end)
	fill("isfolder", function()
		return false
	end)
	fill("readfile", function()
		error("this executor can't read files", 2)
	end)
	fill("writefile", function() end)
	fill("makefolder", function() end)
	fill("listfiles", function()
		return {}
	end)
	fill("delfile", function() end)
	fill("setclipboard", (type(toclipboard) == "function" and toclipboard) or function() end)
	fill("toclipboard", (type(setclipboard) == "function" and setclipboard) or function() end)
	local req = (type(request) == "function" and request) or (type(http_request) == "function" and http_request) or (syn and syn.request) or (http and http.request)
	if req then
		fill("request", req)
		fill("http_request", req)
	end
	local queue = (type(queue_on_teleport) == "function" and queue_on_teleport) or (type(queueonteleport) == "function" and queueonteleport) or (syn and syn.queue_on_teleport)
	if queue then
		fill("queue_on_teleport", queue)
		fill("queueonteleport", queue)
	end
	fill("getgc", function()
		return {}
	end)
	fill("getconnections", function()
		return {}
	end)

	local VIM = game:GetService("VirtualInputManager")
	local UIS = game:GetService("UserInputService")
	local digits = { "Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine" }
	local vk = { [0x20] = "Space", [0x0D] = "Return", [0x10] = "LeftShift", [0x11] = "LeftControl", [0x12] = "LeftAlt", [0x1B] = "Escape", [0x09] = "Tab", [0x08] = "Backspace" }
	local function key(code)
		if typeof(code) == "EnumItem" then
			return code
		end
		if type(code) ~= "number" then
			return nil
		end
		if code >= 0x41 and code <= 0x5A then
			return Enum.KeyCode[string.char(code)]
		elseif code >= 0x30 and code <= 0x39 then
			return Enum.KeyCode[digits[code - 0x2F]]
		elseif vk[code] then
			return Enum.KeyCode[vk[code]]
		end
		return nil
	end
	local function mouse(button, down)
		local m = UIS:GetMouseLocation()
		pcall(VIM.SendMouseButtonEvent, VIM, m.X, m.Y, button, down, game, 0)
	end
	fill("keypress", function(code)
		local k = key(code)
		if k then
			pcall(VIM.SendKeyEvent, VIM, true, k, false, game)
		end
	end)
	fill("keyrelease", function(code)
		local k = key(code)
		if k then
			pcall(VIM.SendKeyEvent, VIM, false, k, false, game)
		end
	end)
	fill("mouse1press", function()
		mouse(0, true)
	end)
	fill("mouse1release", function()
		mouse(0, false)
	end)
	fill("mouse1click", function()
		mouse(0, true)
		task.wait()
		mouse(0, false)
	end)

	fill("fireproximityprompt", function(prompt)
		if typeof(prompt) ~= "Instance" or not prompt:IsA("ProximityPrompt") then
			return
		end
		local hold, dist, los = prompt.HoldDuration, prompt.MaxActivationDistance, prompt.RequiresLineOfSight
		pcall(function()
			prompt.HoldDuration, prompt.MaxActivationDistance, prompt.RequiresLineOfSight = 0, math.huge, false
			prompt:InputHoldBegin()
			task.wait()
			prompt:InputHoldEnd()
		end)
		pcall(function()
			prompt.HoldDuration, prompt.MaxActivationDistance, prompt.RequiresLineOfSight = hold, dist, los
		end)
	end)

	fill("firetouchinterest", function(a, b, state)
		if state ~= 0 or typeof(a) ~= "Instance" or typeof(b) ~= "Instance" then
			return
		end
		local char = game:GetService("Players").LocalPlayer.Character
		if not (char and a:IsDescendantOf(char)) then
			a, b = b, a
		end
		if not (char and a:IsDescendantOf(char) and a:IsA("BasePart") and b:IsA("BasePart")) then
			return
		end
		local old = a.CFrame
		pcall(function()
			a.CFrame = b.CFrame
			task.wait()
			a.CFrame = old
		end)
	end)

	if type(Drawing) ~= "table" or type(Drawing.new) ~= "function" then
		table.insert(Executor.Missing, "Drawing (using a GUI version)")
		local screen
		local function layer()
			if screen and screen.Parent then
				return screen
			end
			screen = Instance.new("ScreenGui")
			screen.Name = "PhantomDrawing"
			screen.IgnoreGuiInset = true
			screen.ResetOnSpawn = false
			screen.DisplayOrder = 5
			if not pcall(function()
				screen.Parent = gethui()
			end) or not screen.Parent then
				screen.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
			end
			return screen
		end
		local fonts = { [0] = Enum.Font.SourceSans, [1] = Enum.Font.Arial, [2] = Enum.Font.Code, [3] = Enum.Font.Code }
		local function new(kind)
			local p = {
				Visible = false, Color = Color3.new(1, 1, 1), Transparency = 1, Thickness = 1, ZIndex = 1,
				From = Vector2.zero, To = Vector2.zero, Position = Vector2.zero, Size = kind == "Text" and 13 or Vector2.zero,
				Filled = false, Radius = 10, NumSides = 32, Text = "", Center = false, Outline = false,
				OutlineColor = Color3.new(0, 0, 0), Font = 0,
			}
			local gui, stroke
			if kind == "Text" then
				gui = Instance.new("TextLabel")
				gui.BackgroundTransparency = 1
				gui.AutomaticSize = Enum.AutomaticSize.XY
				gui.Size = UDim2.new()
			elseif kind == "Line" or kind == "Square" or kind == "Circle" then
				gui = Instance.new("Frame")
				gui.BorderSizePixel = 0
				if kind ~= "Line" then
					stroke = Instance.new("UIStroke")
					stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					stroke.Parent = gui
				end
				if kind == "Circle" then
					local c = Instance.new("UICorner")
					c.CornerRadius = UDim.new(1, 0)
					c.Parent = gui
				end
			end
			if gui then
				gui.Visible = false
				gui.Parent = layer()
			end
			local function render()
				if not gui then
					return
				end
				gui.Visible = p.Visible == true
				if not gui.Visible then
					return
				end
				local alpha = 1 - math.clamp(tonumber(p.Transparency) or 1, 0, 1)
				gui.ZIndex = math.max(1, math.floor(tonumber(p.ZIndex) or 1))
				if kind == "Line" then
					local a, b = p.From, p.To
					local d = b - a
					gui.AnchorPoint = Vector2.new(0.5, 0.5)
					gui.Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2)
					gui.Size = UDim2.fromOffset(d.Magnitude, math.max(1, p.Thickness))
					gui.Rotation = math.deg(math.atan2(d.Y, d.X))
					gui.BackgroundColor3 = p.Color
					gui.BackgroundTransparency = alpha
				elseif kind == "Square" or kind == "Circle" then
					if kind == "Square" then
						gui.AnchorPoint = Vector2.zero
						gui.Position = UDim2.fromOffset(p.Position.X, p.Position.Y)
						gui.Size = UDim2.fromOffset(p.Size.X, p.Size.Y)
					else
						gui.AnchorPoint = Vector2.new(0.5, 0.5)
						gui.Position = UDim2.fromOffset(p.Position.X, p.Position.Y)
						gui.Size = UDim2.fromOffset(p.Radius * 2, p.Radius * 2)
					end
					gui.BackgroundColor3 = p.Color
					gui.BackgroundTransparency = p.Filled and alpha or 1
					stroke.Color = p.Color
					stroke.Thickness = math.max(1, p.Thickness)
					stroke.Transparency = p.Filled and 1 or alpha
				elseif kind == "Text" then
					gui.Text = tostring(p.Text)
					gui.TextSize = tonumber(p.Size) or 13
					gui.Font = fonts[p.Font] or Enum.Font.SourceSans
					gui.TextColor3 = p.Color
					gui.TextTransparency = alpha
					gui.TextStrokeColor3 = p.OutlineColor
					gui.TextStrokeTransparency = p.Outline and alpha or 1
					gui.AnchorPoint = p.Center and Vector2.new(0.5, 0) or Vector2.zero
					gui.Position = UDim2.fromOffset(p.Position.X, p.Position.Y)
				end
			end
			return setmetatable({}, {
				__index = function(_, k)
					if k == "Remove" or k == "Destroy" then
						return function()
							if gui then
								gui:Destroy()
								gui = nil
							end
						end
					elseif k == "TextBounds" then
						return gui and gui:IsA("TextLabel") and gui.TextBounds or Vector2.zero
					end
					return p[k]
				end,
				__newindex = function(_, k, v)
					p[k] = v
					render()
				end,
			})
		end
		local drawing = { new = new, Fonts = { UI = 0, System = 1, Plex = 2, Monospace = 3 } }
		local okSet = pcall(function()
			getfenv(1).Drawing = drawing
		end)
		if not okSet then
			_G.Drawing = drawing
		end
	end
end

task.delay(3, function()
	if #Executor.Missing > 0 then
		pcall(function()
			Library:Notify("Executor", Executor.Name .. " is missing " .. table.concat(Executor.Missing, ", ") .. ". Everything else still works", 7, "Warning")
		end)
	end
end)

local Changed, KeyState, Dropdowns, MultiSet, Callbacks = {}, {}, {}, {}, {}
local MenuBuilt = false
local function Fire(idx, v)
	for _, fn in ipairs(Changed[idx] or {}) do
		local ok, err = pcall(fn, v)
		if not ok then Library:Error(tostring(idx) .. ": " .. tostring(err)) end
	end
end
local function ToSet(list)
	local set = {}
	for _, v in ipairs(type(list) == "table" and list or {}) do set[v] = true end
	return set
end
local function ToList(v)
	if v == nil then return {} end
	if type(v) ~= "table" then return {v} end
	if #v > 0 then return v end
	local out = {}
	for k, on in pairs(v) do if on then table.insert(out, k) end end
	return out
end
local function CB(idx, fn, multi)
	if multi then MultiSet[idx] = true end
	local wrapped = function(v)
		if multi then v = ToSet(v) end
		if fn then fn(v) end
		Fire(idx, v)
	end
	Callbacks[idx] = wrapped
	return function(v)
		if MenuBuilt then wrapped(v) end
	end
end
local function KB(idx)
	return function(state)
		KeyState[idx] = state
		if MenuBuilt then Fire(idx, state) end
	end
end
local function Key(name)
	if typeof(name) == "EnumItem" then return name end
	local ok, k = pcall(function() return Enum.KeyCode[name] end)
	return (ok and k) or Enum.KeyCode.Unknown
end
local function Pick(values, default)
	if type(default) == "number" and type(values) == "table" then return values[default] end
	return default
end
local function Handle(idx)
	return setmetatable({}, {__index = function(_, k)
		if k == "Value" then
			local v = Library.Flags[idx]
			if type(v) == "table" and v.Key ~= nil then
				return (v.Key == Enum.KeyCode.Unknown) and "None" or v.Key.Name
			end
			if MultiSet[idx] then return ToSet(v) end
			return v
		elseif k == "Mode" then
			local v = Library.Flags[idx]
			return type(v) == "table" and v.Mode or nil
		elseif k == "OnChanged" then
			return function(_, fn)
				Changed[idx] = Changed[idx] or {}
				table.insert(Changed[idx], fn)
			end
		elseif k == "SetValue" then
			return function(_, v)
				if MultiSet[idx] then v = ToList(v) end
				local signal = Library.Signals[idx]
				if signal then signal(v) else Library.Flags[idx] = v end
			end
		elseif k == "SetValues" then
			return function(_, values)
				local d = Dropdowns[idx]
				if d then d:Refresh(values) end
			end
		elseif k == "GetState" then
			return function()
				local v = Library.Flags[idx]
				if type(v) == "table" and v.Mode == "Always" then return true end
				return KeyState[idx] == true
			end
		end
	end})
end
local Toggles = setmetatable({}, {__index = function(t, idx)
	local h = Handle(idx)
	rawset(t, idx, h)
	return h
end})
local Options = Toggles
local function FinishMenu()
	MenuBuilt = true
	for idx, fn in pairs(Callbacks) do
		local v = Library.Flags[idx]
		if v ~= nil and v ~= Library.Defaults[idx] then pcall(fn, v) end
	end
end

Library:SetHub({
    UpdateLog = {
        Date = "Nov 11, 2026",
        Added = {
            "New UI library",
            "New skin menu with previews for skins, knives and gloves",
            "Skins, knives and gloves are all in one Skins tab",
        },
        Fixed = {
            "Error on unload",
            "Features still working after you disabled them",
            "Mobile UI bugs",
            "Configs saved in one PhantomHub folder",
        },
    },
})

local Window = Library:CreateWindow({
    Name = HUB_NAME,
    Game = "BloxStrike",
    ConfigFolder = "PhantomHub/BloxStrike",
})

local Tabs = {}
Tabs.Legit = Window:Tab("Aimbot", "target")
Tabs.Combat = Window:Tab("Silent Aim", "crosshair")
Tabs.AntiAim = Window:Tab("Anti Aim", "rotate-3d")
if Window.TabDivider then Window:TabDivider() end
Tabs.Visuals = Window:Tab("ESP", "eye")
Tabs.Weapons = Window:Tab("Weapon Mods", "zap")
Tabs.Misc = Window:Tab("World", "globe")
if Window.TabDivider then Window:TabDivider() end
Tabs.SkinChanger = Window:Tab("Skins", "palette")
Tabs.World = Tabs.Misc

local HttpService = game:GetService("HttpService")
local PH = { alive = true, conns = {}, cleanup = {} }

local function PH_Cleanup()
    PH.alive = false
    for _, conn in ipairs(PH.conns) do
        pcall(function() conn:Disconnect() end)
    end
    for _, fn in ipairs(PH.cleanup) do
        pcall(fn)
    end
    getgenv().BloxStrikeUnload = nil
end
if type(Library.OnUnload) == "function" then
    Library:OnUnload(PH_Cleanup)
else
    local unload = Library.Unload
    Library.Unload = function(self, ...)
        pcall(PH_Cleanup)
        return unload(self, ...)
    end
end
getgenv().BloxStrikeUnload = function()
    pcall(function() Library:Unload() end)
end

local MaterialLimits = {
    [Enum.Material.Asphalt] = 0.25,
    [Enum.Material.Basalt] = 0.25,
    [Enum.Material.Brick] = 0.25,
    [Enum.Material.Cobblestone] = 0.25,
    [Enum.Material.Concrete] = 0.25,
    [Enum.Material.CrackedLava] = 0.25,
    [Enum.Material.DiamondPlate] = 0.25,
    [Enum.Material.Foil] = 0.25,
    [Enum.Material.Glacier] = 0.25,
    [Enum.Material.Granite] = 0.25,
    [Enum.Material.Grass] = 0.25,
    [Enum.Material.Ground] = 0.25,
    [Enum.Material.Ice] = 0.25,
    [Enum.Material.LeafyGrass] = 0.25,
    [Enum.Material.Limestone] = 0.25,
    [Enum.Material.Marble] = 0.25,
    [Enum.Material.Metal] = 0.25,
    [Enum.Material.Mud] = 0.25,
    [Enum.Material.Pavement] = 0.25,
    [Enum.Material.Rock] = 0.25,
    [Enum.Material.Salt] = 0.25,
    [Enum.Material.Sand] = 0.25,
    [Enum.Material.Sandstone] = 0.25,
    [Enum.Material.Slate] = 0.25,
    [Enum.Material.Snow] = 0.25,
    [Enum.Material.ForceField] = 0.25,
    [Enum.Material.Neon] = 0.25,
    [Enum.Material.CorrodedMetal] = 0.25,
    [Enum.Material.Pebble] = 0.25,
    [Enum.Material.CeramicTiles] = 0.25,
    [Enum.Material.Plaster] = 0.25,
    [Enum.Material.Plastic] = 7,
    [Enum.Material.SmoothPlastic] = 7,
    [Enum.Material.Wood] = 7,
    [Enum.Material.WoodPlanks] = 7,
    [Enum.Material.Cardboard] = 7,
    [Enum.Material.Glass] = 100,
    [Enum.Material.Fabric] = 100
}

local MaterialVariantLimits = {
    ["IndoorWall"] = 0.25,
    ["Sandy Brick"] = 0.25
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = (function()
    local real = game:GetService("RunService")
    local function wrapSignal(sig)
        return setmetatable({}, {
            __index = function(_, k)
                if k == "Connect" or k == "connect" then
                    return function(_, fn)
                        local c = sig:Connect(fn)
                        PH.conns[#PH.conns + 1] = c
                        return c
                    end
                end
                local v = sig[k]
                if type(v) == "function" then return function(_, ...) return v(sig, ...) end end
                return v
            end,
        })
    end
    return setmetatable({}, {
        __index = function(_, k)
            local v = real[k]
            if typeof(v) == "RBXScriptSignal" then return wrapSignal(v) end
            if type(v) == "function" then return function(_, ...) return v(real, ...) end end
            return v
        end,
        __newindex = function(_, k, v) real[k] = v end,
    })
end)()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
PH.conns[#PH.conns + 1] = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

local AAGuiBox = Tabs.AntiAim:Section("Anti Aim", "Left")
local AAGuiBox2 = Tabs.AntiAim:Section("Extras", "Left")

AAGuiBox:Toggle("Anti Aim", "AAEnabled", false, nil, CB("AAEnabled", nil), true)

Dropdowns["AAPitch"] = AAGuiBox:Dropdown("Pitch", "AAPitch", {"Up", "Zero", "Down"}, Pick({"Up", "Zero", "Down"}, "Up"), nil, CB("AAPitch", nil))

Dropdowns["AAYaw"] = AAGuiBox:Dropdown("Yaw", "AAYaw", {"Backward", "Jitter", "Spin"}, Pick({"Backward", "Jitter", "Spin"}, "Backward"), nil, CB("AAYaw", nil))

AAGuiBox:Slider("Jitter Range", "AAJitterRange", 0, 180, 46, 1, nil, CB("AAJitterRange", nil))

AAGuiBox:Slider("Spin Speed", "AASpinSpeed", 100, 5000, 1400, 1, nil, CB("AASpinSpeed", nil))

AAGuiBox2:Toggle("At Targets", "AAAtTargets", false, nil, CB("AAAtTargets", nil), true)

AAGuiBox2:Toggle("Movement Only", "AAMovementOnly", false, nil, CB("AAMovementOnly", nil), true)

AAGuiBox2:Toggle("Auto Rotate Fix", "AAAutoRotateFix", false, nil, CB("AAAutoRotateFix", nil), true)

AAGuiBox2:Divider()

AAGuiBox2:Toggle("Third Person", "ThirdPersonToggle", false, nil, CB("ThirdPersonToggle", nil), true)
AAGuiBox2:Keybind("Third Person Key", "ThirdPersonKeybind", Key("None"), "Toggle", nil, KB("ThirdPersonKeybind"))

AAGuiBox2:Slider("Third Person Distance", "ThirdPersonDist", 5, 50, 12, 1, nil, CB("ThirdPersonDist", nil))

local aaThirdPersonDist = 12

local cfg = {
    Enabled        = false,
    Pitch          = "Up",
    Yaw            = "Backward",
    JitterRange    = 46,
    SpinSpeed      = 1400,
    AtTargets      = false,
    MovementOnly   = false,
    AutoRotateFix  = true,
}

local aaThirdPersonActive = false

local function setThirdPerson()
    pcall(function()
        LP.CameraMode = Enum.CameraMode.Classic
        LP.CameraMaxZoomDistance = aaThirdPersonDist
        LP.CameraMinZoomDistance = aaThirdPersonDist
    end)
end

local function unsetThirdPerson()
    pcall(function()
        LP.CameraMode = Enum.CameraMode.Classic
        LP.CameraMaxZoomDistance = 0.5
        LP.CameraMinZoomDistance = 0.5
    end)
end

pcall(function()
    Toggles.ThirdPersonToggle:OnChanged(function(v)
        aaThirdPersonActive = v
        if v then
            setThirdPerson()
        else
            unsetThirdPerson()
        end
    end)
    Options.ThirdPersonDist:OnChanged(function(v)
        aaThirdPersonDist = v
        if aaThirdPersonActive then
            setThirdPerson()
        end
    end)
end)

PH.conns[#PH.conns + 1] = RunService.RenderStepped:Connect(function()
    pcall(function()
        if Options.ThirdPersonKeybind and Options.ThirdPersonKeybind.Value ~= "None" then
            local kState = Options.ThirdPersonKeybind:GetState()
            if kState ~= aaThirdPersonActive then
                aaThirdPersonActive = kState
                Toggles.ThirdPersonToggle:SetValue(kState)
                if kState then
                    setThirdPerson()
                else
                    unsetThirdPerson()
                end
            end
        end
    end)
end)

pcall(function()
    Toggles.AAEnabled:OnChanged(function(v) cfg.Enabled = v end)
    Options.AAPitch:OnChanged(function(v) cfg.Pitch = v end)
    Options.AAYaw:OnChanged(function(v) cfg.Yaw = v end)
    Options.AAJitterRange:OnChanged(function(v) cfg.JitterRange = v end)
    Options.AASpinSpeed:OnChanged(function(v) cfg.SpinSpeed = v end)
    Toggles.AAAtTargets:OnChanged(function(v) cfg.AtTargets = v end)
    Toggles.AAMovementOnly:OnChanged(function(v) cfg.MovementOnly = v end)
    Toggles.AAAutoRotateFix:OnChanged(function(v) cfg.AutoRotateFix = v end)
end)

local aaState = {
    spinAngle  = 0,
    lastPos    = nil,
}

task.spawn(function()
    if not (getrawmetatable and setreadonly) then return end
    local mt = getrawmetatable(game)
    local oldNewIndex = mt.__newindex
    setreadonly(mt, false)
    mt.__newindex = newcclosure(function(self, key, value)
        if self == LP and aaThirdPersonActive then
            if key == "CameraMode" then
                return oldNewIndex(self, key, Enum.CameraMode.Classic)
            elseif key == "CameraMaxZoomDistance" or key == "CameraMinZoomDistance" then
                if typeof(value) == "number" and value < 5 then
                    return oldNewIndex(self, key, aaThirdPersonDist)
                end
            end
        end
        return oldNewIndex(self, key, value)
    end)
    setreadonly(mt, true)
end)

local function getMotors(char)
    local lt = char:FindFirstChild("LowerTorso")
    local ut = char:FindFirstChild("UpperTorso")
    return  lt and lt:FindFirstChild("Root")  or nil,
            ut and ut:FindFirstChild("Neck")  or nil,
            ut and ut:FindFirstChild("Waist") or nil
end

local function getCameraYaw()
    local cam = Workspace.CurrentCamera
    if not cam then return 0 end
    local look = cam.CFrame.LookVector
    local flat = Vector3.new(look.X, 0, look.Z)
    if flat.Magnitude < 0.001 then return 0 end
    return math.deg(math.atan2(-flat.X, -flat.Z))
end

local lastT = tick()

local function aaApplyRotation()
    if not cfg.Enabled then return end

    local char = LP.Character
    if not char then return end

    local baseYaw = getCameraYaw()
    local yaw
    if cfg.Yaw == "Backward" then
        yaw = baseYaw + 180
    elseif cfg.Yaw == "Jitter" then
        yaw = baseYaw + 180 + math.sin(tick() * 35) * cfg.JitterRange
    elseif cfg.Yaw == "Spin" then
        local dt = math.clamp(tick() - lastT, 0.001, 0.1)
        lastT = tick()
        aaState.spinAngle = (aaState.spinAngle + cfg.SpinSpeed * dt) % 360
        yaw = baseYaw + aaState.spinAngle
    else
        yaw = baseYaw
    end
    local deltaYaw = yaw - baseYaw

    local pitch = 0
    if cfg.Pitch == "Up"   then pitch = 90
    elseif cfg.Pitch == "Down" then pitch = -90 end
    local pitchRad = math.rad(pitch)

    local root, neck, waist = getMotors(char)

    if root then
        root.Transform = CFrame.Angles(0, math.rad(deltaYaw), 0)
    end
    if neck then
        neck.Transform = CFrame.Angles(pitchRad, 0, 0)
    end
    if waist then
        waist.Transform = CFrame.Angles(pitchRad * 0.5, 0, 0)
    end
end

pcall(function()
    RunService:BindToRenderStep("AA_Root", Enum.RenderPriority.Character.Value + 10, function()
        pcall(aaApplyRotation)
    end)
end)
PH.conns[#PH.conns + 1] = RunService.Stepped:Connect(function()
    pcall(aaApplyRotation)
end)


local function createTracerBean(startPos, endPos)
    pcall(function()
        if not Toggles.BulletTracers or not Toggles.BulletTracers.Value then return end
        if not startPos or not endPos then return end

        local style = Options.TracerStyle and Options.TracerStyle.Value or "Block"
        local tracerColor = Options.BulletTracersColor and Options.BulletTracersColor.Value or Color3.fromRGB(0, 170, 255)

        if Toggles.TracerRainbow and Toggles.TracerRainbow.Value then
            tracerColor = Color3.fromHSV((tick() % 5) / 5, 1, 1)
        end

        local duration = Options.TracerTime and Options.TracerTime.Value or 2
        local beamPart = Instance.new("Part")
        beamPart.Name = "Memesense_Tracer"

        if style == "Cylinder (Obelius)" then
            beamPart.Shape = Enum.PartType.Cylinder
            beamPart.Size = Vector3.new((startPos - endPos).Magnitude, 0.12, 0.12)
            beamPart.CFrame = CFrame.new(startPos, endPos) * CFrame.new(0, 0, -beamPart.Size.X / 2) * CFrame.Angles(0, math.rad(90), 0)
        else
            beamPart.Size = Vector3.new(0.1, 0.1, (startPos - endPos).Magnitude)
            beamPart.CFrame = CFrame.new(startPos, endPos) * CFrame.new(0, 0, -beamPart.Size.Z / 2)
        end

        beamPart.Anchored = true
        beamPart.CanCollide = false
        beamPart.CanQuery = false
        beamPart.CanTouch = false
        beamPart.Material = Enum.Material.Neon
        beamPart.Color = tracerColor
        beamPart.Transparency = 0
        beamPart.CastShadow = false
        beamPart.Parent = Workspace

        task.spawn(function()
            local startTime = tick()
            while tick() - startTime < duration do
                local alpha = (tick() - startTime) / duration
                beamPart.Transparency = alpha
                if Toggles.TracerRainbow and Toggles.TracerRainbow.Value then
                    beamPart.Color = Color3.fromHSV((tick() % 5) / 5, 1, 1)
                end
                task.wait()
            end
            beamPart:Destroy()
        end)
    end)
end

local function createBulletImpact(pos)
    pcall(function()
        if not Toggles.BulletImpacts or not Toggles.BulletImpacts.Value then return end
        if not pos then return end

        local impactColor = Options.ImpactColor and Options.ImpactColor.Value or Color3.fromRGB(255, 255, 0)
        local impactSize = Options.ImpactSize and Options.ImpactSize.Value or 0.15

        local ball = Instance.new("Part")
        ball.Name = "Memesense_Impact"
        ball.Size = Vector3.new(impactSize, impactSize, impactSize)
        ball.Shape = Enum.PartType.Ball
        ball.Position = pos
        ball.Anchored = true
        ball.CanCollide = false
        ball.CanQuery = false
        ball.CanTouch = false
        ball.Material = Enum.Material.Neon
        ball.Color = impactColor
        ball.Transparency = 0
        ball.CastShadow = false
        ball.Parent = Workspace

        task.spawn(function()
            local startTime = tick()
            local dur = 0.5
            while tick() - startTime < dur do
                local alpha = (tick() - startTime) / dur
                ball.Transparency = alpha
                task.wait()
            end
            ball:Destroy()
        end)
    end)
end

local RageGuiBox = Tabs.Combat:Section("Silent Aim", "Left")
local RageGuiBox2 = Tabs.Combat:Section("Wallbang", "Left")
local RageGuiBox3 = Tabs.Combat:Section("Targeting", "Right")

RageGuiBox:Toggle("Silent Aim", "RageEnabled", false, "Shoots for you and sends every bullet to the closest enemy", CB("RageEnabled", nil), true)

Dropdowns["RageHitPart"] = RageGuiBox:Dropdown("Hit Part", "RageHitPart", {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, Pick({"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, "Head"), nil, CB("RageHitPart", nil))

RageGuiBox:Slider("Shot Delay", "RageDelay", 0.01, 0.5, 0.01, 0.01, nil, CB("RageDelay", nil))

RageGuiBox:Toggle("Visible Check", "RageVisibleCheck", false, nil, CB("RageVisibleCheck", nil), true)

RageGuiBox:Toggle("Team Check", "RageTeamCheck", false, nil, CB("RageTeamCheck", nil), true)

RageGuiBox2:Toggle("Wall Check", "RageWallCheck", false, "Skip enemies behind walls you can't shoot through", CB("RageWallCheck", nil), true)

RageGuiBox2:Toggle("Wallbang", "RageWallbang", false, "Shoot enemies through walls", CB("RageWallbang", nil), true)

RageGuiBox3:Toggle("Hit Chance", "RageHitChance", false, nil, CB("RageHitChance", nil), true)

RageGuiBox3:Slider("Hit Chance (%)", "RageHitChanceValue", 0, 100, 50, 1, nil, CB("RageHitChanceValue", nil))

RageGuiBox3:Divider()

RageGuiBox3:Toggle("FOV Check", "RageFovEnabled", false, nil, CB("RageFovEnabled", nil), true)

Dropdowns["RageFovMode"] = RageGuiBox3:Dropdown("FOV Mode", "RageFovMode", {"No FOV", "Yes FOV", "FOV Circle"}, Pick({"No FOV", "Yes FOV", "FOV Circle"}, "No FOV"), nil, CB("RageFovMode", nil))

RageGuiBox3:Slider("FOV Radius (px)", "RageFovRadius", 50, 800, 150, 1, nil, CB("RageFovRadius", nil))

RageGuiBox3:ColorPicker("FOV Circle Color", "RageFovCircleColor", Color3.fromRGB(0, 255, 100), nil, CB("RageFovCircleColor", nil))

local rageCfg = {
    Enabled      = false,
    Delay        = 0.01,
    HitPart      = "Head",
    VisibleCheck = true,
    WallCheck    = true,
    Wallbang     = false,
    TeamCheck    = true,
    HitChance    = false,
    HitChanceVal = 50,
    FovEnabled   = false,
    FovMode      = "No FOV",
    FovRadius    = 150,
}

pcall(function()
    Toggles.RageEnabled:OnChanged(function(v) rageCfg.Enabled = v end)
    Options.RageHitPart:OnChanged(function(v) rageCfg.HitPart = v end)
    Options.RageDelay:OnChanged(function(v) rageCfg.Delay = v end)
    Toggles.RageVisibleCheck:OnChanged(function(v) rageCfg.VisibleCheck = v end)
    Toggles.RageTeamCheck:OnChanged(function(v) rageCfg.TeamCheck = v end)
    Toggles.RageWallCheck:OnChanged(function(v) rageCfg.WallCheck = v end)
    Toggles.RageWallbang:OnChanged(function(v) rageCfg.Wallbang = v end)
    Toggles.RageHitChance:OnChanged(function(v) rageCfg.HitChance = v end)
    Options.RageHitChanceValue:OnChanged(function(v) rageCfg.HitChanceVal = v end)
    Toggles.RageFovEnabled:OnChanged(function(v) rageCfg.FovEnabled = v end)
    Options.RageFovMode:OnChanged(function(v) rageCfg.FovMode = v end)
    Options.RageFovRadius:OnChanged(function(v) rageCfg.FovRadius = v end)
end)

local RageMaterialLimits = {
    [Enum.Material.Plastic]       = 2,
    [Enum.Material.SmoothPlastic] = 2,
    [Enum.Material.Wood]          = 2.5,
    [Enum.Material.WoodPlanks]    = 2.5,
    [Enum.Material.Cardboard]     = 1.5,
    [Enum.Material.Glass]         = 100,
    [Enum.Material.Fabric]        = 100,
    [Enum.Material.Metal]         = 5,
    [Enum.Material.DiamondPlate]  = 5,
    [Enum.Material.CorrodedMetal] = 4,
    [Enum.Material.Foil]          = 1,
    [Enum.Material.Concrete]      = 4,
    [Enum.Material.Slate]         = 4,
    [Enum.Material.Marble]        = 4.5,
    [Enum.Material.Granite]       = 4.5,
    [Enum.Material.Brick]         = 3.5,
    [Enum.Material.Cobblestone]   = 3.5,
    [Enum.Material.Pebble]        = 3,
    [Enum.Material.Asphalt]       = 3,
    [Enum.Material.Grass]         = 1,
    [Enum.Material.LeafyGrass]    = 1,
    [Enum.Material.Sand]          = 1.5,
    [Enum.Material.Snow]          = 1,
    [Enum.Material.Ice]           = 1.5,
    [Enum.Material.Mud]           = 1.5,
    [Enum.Material.Ground]        = 1.5,
    [Enum.Material.Rock]          = 5,
    [Enum.Material.Water]         = 100,
}

local RageMaterialVariantLimits = {
    ["IndoorWall"]  = 0.25,
    ["Sandy Brick"] = 0.25,
}

local function RageGetPenetrationStats(origin, direction, maxPen, ignoreList, targetRoot)
    maxPen = maxPen or 4
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignoreList or { LP.Character }
    params.IgnoreWater = true
    local currentOrigin = origin
    local accMat = {}
    local accVar = {}
    for i = 1, 8 do
        local result = Workspace:Raycast(currentOrigin, direction * 500, params)
        if not result then return true end
        if targetRoot and result.Instance:IsDescendantOf(targetRoot) then
            return true
        end
        table.insert(params.FilterDescendantsInstances, result.Instance)
        local inst = result.Instance
        local thickness = 0
        if inst:IsA("BasePart") then
            local s = inst.Size
            local cf = inst.CFrame
            local absDir = cf:VectorToObjectSpace(direction)
            thickness = math.abs(absDir.X) * s.X + math.abs(absDir.Y) * s.Y + math.abs(absDir.Z) * s.Z
        else
            local enterPos = result.Position
            local fakeEnd = enterPos + (direction * 500)
            local backParams = RaycastParams.new()
            backParams.FilterType = Enum.RaycastFilterType.Include
            backParams.FilterDescendantsInstances = { inst }
            backParams.IgnoreWater = true
            local backRes = Workspace:Raycast(fakeEnd, enterPos - fakeEnd, backParams)
            if not backRes then return false end
            thickness = (enterPos - backRes.Position).Magnitude
        end
        local mat = result.Material
        local variant = ""
        pcall(function() variant = inst.MaterialVariant end)
        if variant ~= "" and RageMaterialVariantLimits[variant] then
            local limit = RageMaterialVariantLimits[variant]
            accVar[variant] = (accVar[variant] or 0) + thickness
            if accVar[variant] > limit + maxPen then return false end
        else
            local limit = RageMaterialLimits[mat] or 0.25
            accMat[mat] = (accMat[mat] or 0) + thickness
            if accMat[mat] > limit + maxPen then return false end
        end
        currentOrigin = result.Position + (direction * 0.1)
    end
    return false
end

local rageRayParams = RaycastParams.new()
rageRayParams.FilterType = Enum.RaycastFilterType.Exclude
rageRayParams.IgnoreWater = true

local function RageIsVisible(targetPart)
    if not targetPart or not targetPart.Parent then return false end
    local cam = Workspace.CurrentCamera
    rageRayParams.FilterDescendantsInstances = {LP.Character, cam}
    local result = Workspace:Raycast(cam.CFrame.Position, targetPart.Position - cam.CFrame.Position, rageRayParams)
    if result then
        local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
        return hitModel == targetPart.Parent
    end
    return true
end

local RageWeapon = nil

local function RageCanShootTarget(targetPart)
    if not targetPart or not targetPart.Parent then return false end
    local cam = Workspace.CurrentCamera
    if not cam then return false end
    if RageIsVisible(targetPart) then return true end
    if not rageCfg.Wallbang then return false end
    local origin = cam.CFrame.Position
    local dir    = (targetPart.Position - origin).Unit
    local maxPen = 4
    pcall(function()
        if RageWeapon and RageWeapon.Properties then
            local pen = RageWeapon.Properties.Penetration or 0.5
            local wb = RageWeapon.Properties.WallbangMultiplier or 1
            maxPen = math.clamp(pen * wb * 3, 0.5, 4)
        end
    end)
    return RageGetPenetrationStats(origin, dir, maxPen, { LP.Character, cam }, targetPart.Parent)
end

local function rageHasVestDetails(char)
    local armor = char and char:FindFirstChild("CharacterArmor")
    return armor and armor:FindFirstChild("VestDetails") ~= nil
end

local function rageIsEnemy(char)
    if not char or char == LP.Character then return false end
    if not rageCfg.TeamCheck then return true end
    local myChar = LP.Character
    if not myChar then return false end
    return rageHasVestDetails(myChar) ~= rageHasVestDetails(char)
end

local RageTarget = nil

local function FindRageTarget()
    if not rageCfg.Enabled then
        RageTarget = nil
        return
    end
    local cam = Workspace.CurrentCamera
    local charsFolder = Workspace:FindFirstChild("Characters")
    if not charsFolder or not cam then return end
    local closest = nil
    local minDist = math.huge
    local screenCenter = cam.ViewportSize / 2
    for _, char in ipairs(charsFolder:GetDescendants()) do
        if char:IsA("Model") and rageIsEnemy(char) then
            local isDead = char:GetAttribute("Dead") or char:GetAttribute("Invincible")
            local hp = char:GetAttribute("Health")
            if not isDead and (hp == nil or hp > 0) then
                local part = char:FindFirstChild(rageCfg.HitPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                if part then
                    local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                    local canShoot = true
                    if rageCfg.VisibleCheck and not onScreen then canShoot = false end

                    if canShoot and rageCfg.FovEnabled and rageCfg.FovMode ~= "No FOV" then
                        if onScreen then
                            local distFromCenter = (Vector2.new(sp.X, sp.Y) - screenCenter).Magnitude
                            if distFromCenter > rageCfg.FovRadius then
                                canShoot = false
                            end
                        end
                    end
                    if canShoot and (rageCfg.WallCheck or rageCfg.Wallbang) then
                        canShoot = RageCanShootTarget(part)
                    end

                    if canShoot and rageCfg.HitChance then
                        if math.random(1, 100) > rageCfg.HitChanceVal then
                            canShoot = false
                        end
                    end
                    if canShoot then
                        local dist = (cam.CFrame.Position - part.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            closest = part
                        end
                    end
                end
            end
        end
    end
    RageTarget = closest
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local RageSendOrig = nil
local RageSendBackup = nil
local onBulletHit = nil

local function rageFindSendFunc()
    for _, obj in next, getgc(true) do
        if type(obj) == "table" and type(rawget(obj, "shoot")) == "function" then
            if not RageWeapon then RageWeapon = obj end
            for _, uv in pairs(debug.getupvalues(obj.shoot) or {}) do
                if type(uv) == "table" and rawget(uv, "Inventory") then
                    local inv = rawget(uv, "Inventory")
                    if type(inv) == "table" and rawget(inv, "ShootWeapon") then
                        local sw = rawget(inv, "ShootWeapon")
                        if type(sw) == "table" then
                            local sendFn = rawget(sw, "Send")
                            if type(sendFn) == "function" then
                                RageSendOrig = sendFn
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

local rageShotLogged = false
local function rageProcessBullets(bullets)
    rayParams.FilterDescendantsInstances = { LP.Character, Workspace.CurrentCamera }
    local cam = Workspace.CurrentCamera

    for _, b in pairs(bullets) do
        if type(b) ~= "table" then continue end

        if not rageShotLogged then
            rageShotLogged = true
            pcall(function()
                local lines = {}
                local function dump(t, pre, depth)
                    for k, v in pairs(t) do
                        lines[#lines + 1] = pre .. tostring(k) .. " = " .. typeof(v) .. " " .. tostring(v)
                        if type(v) == "table" and depth < 3 then dump(v, pre .. "  ", depth + 1) end
                    end
                end
                dump(b, "", 0)
                if not isfolder("PhantomHub") then makefolder("PhantomHub") end
                writefile("PhantomHub/bloxstrike_shot.txt", table.concat(lines, string.char(10)))
            end)
        end

        if rageCfg.Enabled and RageTarget and RageTarget.Parent then
            local myChar = LP.Character
            local hrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local origin = hrp and hrp.Position or cam.CFrame.Position
            local targetPos = RageTarget.Position
            local dir = (targetPos - origin).Unit
            rawset(b, "Origin", origin)
            rawset(b, "Direction", dir)
            if rageCfg.Wallbang then
                local old = rawget(b, "Hits")
                local template = type(old) == "table" and old[1] or nil
                local hit = {}
                if type(template) == "table" then
                    for k, v in pairs(template) do hit[k] = v end
                end
                for k, v in pairs(hit) do
                    if typeof(v) == "Instance" then hit[k] = RageTarget end
                end
                if hit.Instance == nil then hit.Instance = RageTarget end
                hit.Position = targetPos
                hit.Normal = -dir
                hit.Material = RageTarget.Material
                rawset(b, "Hits", { hit })
            end
        end

        local drawn = false
        local hits = rawget(b, "Hits")
        if type(hits) == "table" then
            for _, h in pairs(hits) do
                if type(h) == "table" and h.Position then
                    createTracerBean(cam.CFrame.Position, h.Position)
                    createBulletImpact(h.Position)
                    drawn = true

                    if onBulletHit then
                        pcall(onBulletHit, h)
                    end
                end
            end
        end
        if drawn then continue end

        local dir    = rawget(b, "Direction") or rawget(b, "direction")
        local origin = rawget(b, "Origin")    or rawget(b, "origin")
        if typeof(dir) == "Vector3" and typeof(origin) == "Vector3" then
            local res = Workspace:Raycast(origin, dir * 1000, rayParams)
            local endPos = res and res.Position or (origin + dir * 1000)
            createTracerBean(origin, endPos)
            createBulletImpact(endPos)
        end
    end
end

local function rageHookSend()
    if RageSendBackup then return true end
    if not RageSendOrig then
        if not rageFindSendFunc() then return false end
    end

    pcall(function()
        local hooked = hookfunction(RageSendOrig, newcclosure(function(...)
            local args = table.pack(...)
            pcall(function()
                for i = 1, args.n do
                    local a = args[i]
                    if type(a) == "table" then
                        local bl = rawget(a, "Bullets")
                        if type(bl) == "table" then
                            rageProcessBullets(bl)
                            break
                        end
                    end
                end
            end)
            return RageSendBackup(table.unpack(args, 1, args.n))
        end))
        RageSendBackup = hooked
    end)

    return RageSendBackup ~= nil
end

task.spawn(function()
    task.wait(1)
    while PH.alive do
        if not RageSendBackup then
            pcall(rageHookSend)
        end
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.25)
        pcall(function()
            local IC = require(ReplicatedStorage.Controllers.InventoryController)
            local w = IC.peekCurrentEquippedForMovement and IC.peekCurrentEquippedForMovement() or nil
            if w then RageWeapon = w end
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(rageCfg.Delay)
        pcall(function()
            if rageCfg.Enabled and RageTarget and RageTarget.Parent and RageWeapon then
                local w = RageWeapon
                if type(w.shoot) == "function" then
                    w:shoot()
                elseif type(w.Fire) == "function" then
                    w:Fire()
                end
            end
        end)
    end
end)

local lastRageTargetCheck = 0
PH.conns[#PH.conns + 1] = RunService.Heartbeat:Connect(function()
    if rageCfg.Enabled and os.clock() - lastRageTargetCheck >= 0.08 then
        lastRageTargetCheck = os.clock()
        pcall(FindRageTarget)
    end
end)

task.spawn(function()
    local fovCircle = Drawing.new("Circle")
    fovCircle.Visible = false
    fovCircle.Thickness = 1
    fovCircle.NumSides = 64
    fovCircle.Radius = 150
    fovCircle.Filled = false
    fovCircle.Color = Color3.fromRGB(0, 255, 100)

    RunService.RenderStepped:Connect(function()
        pcall(function()
            local show = rageCfg.FovEnabled and rageCfg.FovMode == "FOV Circle" and rageCfg.Enabled
            local cam = Workspace.CurrentCamera
            if show and cam then
                fovCircle.Visible = true
                fovCircle.Radius = rageCfg.FovRadius
                fovCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                pcall(function()
                    if Options.RageFovCircleColor then
                        fovCircle.Color = Options.RageFovCircleColor.Value
                    end
                end)
            else
                fovCircle.Visible = false
            end
        end)
    end)
end)

local ModelChangerBox = Tabs.AntiAim:Section("Player Model", "Right")

ModelChangerBox:Toggle("Enable Model Changer", "ModelChangerEnabled", false, nil, CB("ModelChangerEnabled", nil), true)

Dropdowns["ModelChangerModel"] = ModelChangerBox:Dropdown("Model", "ModelChangerModel", {"Tun Tun Sahur", "aura men", "AURA-LAURA"}, Pick({"Tun Tun Sahur", "aura men", "AURA-LAURA"}, "Tun Tun Sahur"), nil, CB("ModelChangerModel", nil))

ModelChangerBox:Slider("Scale", "ModelChangerScale", 0.1, 3.0, 1.0, 0.01, nil, CB("ModelChangerScale", nil))

ModelChangerBox:Slider("Offset X", "ModelChangerOffsetX", -10, 10, 0, 0.1, nil, CB("ModelChangerOffsetX", nil))

ModelChangerBox:Slider("Offset Y", "ModelChangerOffsetY", -10, 10, 0, 0.1, nil, CB("ModelChangerOffsetY", nil))

ModelChangerBox:Slider("Offset Z", "ModelChangerOffsetZ", -10, 10, 0, 0.1, nil, CB("ModelChangerOffsetZ", nil))

ModelChangerBox:Slider("Yaw" .. " (" .. "deg" .. ")", "ModelChangerYaw", -180, 180, 0, 1, nil, CB("ModelChangerYaw", nil))

local mcCfg, mcReloadModel
ModelChangerBox:Button("Reload Model", nil, function()
    pcall(function()
        if mcCfg.Enabled and mcReloadModel then
            mcReloadModel()
        end
    end)
end)

local MODELS = {
    ["Tun Tun Sahur"] = {
        id = 94100079746169, scale = 1.0,
        offsetX = 0, offsetY = 0, offsetZ = 0, yaw = 0,
    },
    ["aura men"] = {
        id = 9177635501, scale = 1.0,
        offsetX = 0, offsetY = 0, offsetZ = 0, yaw = 0,
    },
    ["AURA-LAURA"] = {
        id = 107900119977221, scale = 0.85,
        offsetX = 0, offsetY = 0, offsetZ = 0, yaw = 0,
    },
}

mcCfg = {
    Enabled  = false,
    Model    = "Tun Tun Sahur",
    Scale    = 1.0,
    OffsetX  = 0,
    OffsetY  = 0,
    OffsetZ  = 0,
    Yaw      = 0,
}

local mcActiveModel    = nil
local mcActiveHoldConn = nil
local mcActiveOrigProps = nil
local mcModelCache     = {}

local function mcGetTemplate(name)
    local entry = MODELS[name]
    if not entry then return nil end
    local id = entry.id
    if mcModelCache[id] then return mcModelCache[id] end
    local ok, objs = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(id))
    end)
    if not ok or not objs or #objs == 0 then
        return nil
    end
    mcModelCache[id] = objs[1]
    return objs[1]
end

local function mcHideChar(char)
    if not char then return end
    mcActiveOrigProps = mcActiveOrigProps or {}
    for _, p in ipairs(char:GetDescendants()) do
        pcall(function()
            if p.Name == "HumanoidRootPart" or p.Name == "CameraPart" then return end
            if p:IsA("BasePart") then
                if p.Name == "Handle" and p:FindFirstAncestorOfClass("Accessory") then return end
                mcActiveOrigProps[p] = mcActiveOrigProps[p] or {}
                mcActiveOrigProps[p].Transparency = p.Transparency
                mcActiveOrigProps[p].CanCollide   = p.CanCollide
                p.Transparency = 1
                p.CanCollide   = false
            elseif p:IsA("Decal") or p:IsA("Texture") or p:IsA("SurfaceAppearance") then
                mcActiveOrigProps[p] = mcActiveOrigProps[p] or {}
                mcActiveOrigProps[p].Transparency = p.Transparency
                p.Transparency = 1
            end
        end)
    end
    for _, acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            mcActiveOrigProps[acc] = mcActiveOrigProps[acc] or {}
            mcActiveOrigProps[acc].Parent = acc.Parent
            acc.Parent = nil
        end
    end
end

local function mcShowChar(char)
    if mcActiveOrigProps then
        for obj, props in pairs(mcActiveOrigProps) do
            pcall(function()
                if obj:IsA("Accessory") and props.Parent then
                    obj.Parent = props.Parent
                elseif props.Transparency ~= nil then
                    obj.Transparency = props.Transparency
                end
                if props.CanCollide ~= nil then
                    obj.CanCollide = props.CanCollide
                end
            end)
        end
    end
    mcActiveOrigProps = nil
    if mcActiveHoldConn then mcActiveHoldConn:Disconnect() mcActiveHoldConn = nil end
    if mcActiveModel then mcActiveModel:Destroy() mcActiveModel = nil end
end

local function mcClearWelds()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, w in ipairs(hrp:GetChildren()) do
        if w.Name == "CustomModelWeld" then w:Destroy() end
    end
end


local function mcAttachModel(char)
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if mcActiveModel then mcActiveModel:Destroy() mcActiveModel = nil end
    if mcActiveHoldConn then mcActiveHoldConn:Disconnect() mcActiveHoldConn = nil end
    mcClearWelds()

    local entry = MODELS[mcCfg.Model]
    if not entry then return end

    local template = mcGetTemplate(mcCfg.Model)
    if not template then return end

    local model = template:Clone()
    if not model:IsA("Model") then
        local wrap = Instance.new("Model")
        model.Parent = wrap
        model = wrap
    end

    mcActiveModel = model
    model.Name = "CustomModel_Instance"
    model.Parent = char

    for _, d in ipairs(model:GetDescendants()) do
        pcall(function()
            if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") then
                d:Destroy()
            elseif d:IsA("Sound") then
                d:Destroy()
            elseif d:IsA("Humanoid") then
                d:Destroy()
            elseif d:IsA("Animator") or d:IsA("AnimationController") then
                d:Destroy()
            elseif d:IsA("BodyVelocity") or d:IsA("BodyGyro") or d:IsA("BodyPosition")
                or d:IsA("AlignPosition") or d:IsA("AlignOrientation")
                or d:IsA("VectorForce") or d:IsA("LinearVelocity")
                or d:IsA("Weld") or d:IsA("WeldConstraint")
                or d:IsA("Motor6D") or d:IsA("Snap") then
                d:Destroy()
            end
        end)
    end

    local currentScale = entry.scale or mcCfg.Scale
    pcall(function()
        if currentScale ~= 1 then model:ScaleTo(currentScale) end
    end)

    for _, d in ipairs(model:GetDescendants()) do
        pcall(function()
            if d:IsA("BasePart") then
                d.CanCollide = false
                d.CanQuery   = false
                d.CanTouch   = false
                d.Massless   = true
                d.Anchored   = true
            end
        end)
    end

    pcall(function() model:PivotTo(CFrame.new(0, 0, 0)) end)

    local minY = math.huge
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then
            local bot = d.Position.Y - d.Size.Y / 2
            if bot < minY then minY = bot end
        end
    end
    if minY == math.huge then return end

    local pivot    = model:GetPivot().Position
    local footOff  = pivot.Y - minY
    local hrpPos   = hrp.Position
    local charFootY = hrpPos.Y - 3 + (entry.offsetY or mcCfg.OffsetY)
    local targetPos = Vector3.new(
        hrpPos.X + (entry.offsetX or mcCfg.OffsetX),
        charFootY + footOff,
        hrpPos.Z + (entry.offsetZ or mcCfg.OffsetZ)
    )
    local targetCF = CFrame.new(targetPos) * CFrame.Angles(0, math.rad(entry.yaw or mcCfg.Yaw), 0)
    pcall(function() model:PivotTo(targetCF) end)

    for _, d in ipairs(model:GetDescendants()) do
        pcall(function()
            if d:IsA("BasePart") then
                d.Anchored = false
                local offset = hrp.CFrame:ToObjectSpace(d.CFrame)
                local weld = Instance.new("Weld")
                weld.Name   = "CustomModelWeld"
                weld.Part0  = hrp
                weld.Part1  = d
                weld.C0     = offset
                weld.C1     = CFrame.new()
                weld.Parent = hrp
            end
        end)
    end

    mcActiveHoldConn = RunService.Heartbeat:Connect(function()
        if not mcActiveModel or not mcActiveModel.Parent then
            if mcActiveHoldConn then mcActiveHoldConn:Disconnect() mcActiveHoldConn = nil end
            return
        end
        local h = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not h then return end
        local hasWelds = false
        for _, w in ipairs(h:GetChildren()) do
            if w.Name == "CustomModelWeld" then
                hasWelds = true
                break
            end
        end
        if not hasWelds then
            mcReloadModel()
        end
    end)
end

mcReloadModel = function()
    local char = LP.Character
    if not char then return end
    if mcActiveModel then mcActiveModel:Destroy() mcActiveModel = nil end
    if mcActiveHoldConn then mcActiveHoldConn:Disconnect() mcActiveHoldConn = nil end
    mcClearWelds()
    task.wait(0.05)
    mcAttachModel(char)
end

local function mcStartModel()
    local char = LP.Character
    if char then
        mcHideChar(char)
        task.wait(0.1)
        mcAttachModel(char)
    end
end

pcall(function()
    Toggles.ModelChangerEnabled:OnChanged(function(v)
        mcCfg.Enabled = v
        if v then
            mcStartModel()
        else
            mcShowChar(LP.Character)
        end
    end)
    Options.ModelChangerModel:OnChanged(function(v) mcCfg.Model = v if mcCfg.Enabled then mcReloadModel() end end)
    Options.ModelChangerScale:OnChanged(function(v) mcCfg.Scale = v if mcCfg.Enabled then mcReloadModel() end end)
    Options.ModelChangerOffsetX:OnChanged(function(v) mcCfg.OffsetX = v if mcCfg.Enabled then mcReloadModel() end end)
    Options.ModelChangerOffsetY:OnChanged(function(v) mcCfg.OffsetY = v if mcCfg.Enabled then mcReloadModel() end end)
    Options.ModelChangerOffsetZ:OnChanged(function(v) mcCfg.OffsetZ = v if mcCfg.Enabled then mcReloadModel() end end)
    Options.ModelChangerYaw:OnChanged(function(v) mcCfg.Yaw = v if mcCfg.Enabled then mcReloadModel() end end)
end)

if mcCfg.Enabled then
    mcStartModel()
end

LP.CharacterAdded:Connect(function(newChar)
    if mcActiveHoldConn then mcActiveHoldConn:Disconnect() mcActiveHoldConn = nil end
    mcClearWelds()
    if mcActiveModel then mcActiveModel:Destroy() mcActiveModel = nil end
    mcActiveOrigProps = nil
    if mcCfg.Enabled then
        task.wait(1)
        mcHideChar(newChar)
        task.wait(0.2)
        mcAttachModel(newChar)
    end
end)


do
    local RS = ReplicatedStorage

    local G = {
        knifeChangerSupported = true,
        executor = (identifyexecutor and identifyexecutor()) or "Unknown",
    }
    if string.find(G.executor, "RonixExploit", 1, true) or string.find(G.executor, "Xeno", 1, true) or string.find(G.executor, "Solara", 1, true) then
        G.knifeChangerSupported = false
    end

    local SD = {SkinsRoot = nil, SkinSelections = {}, GloveSelections = {}, GloveFolders = {}}
    pcall(function()
        SD.SkinsRoot = RS:FindFirstChild("Assets") and RS.Assets:FindFirstChild("Skins")
    end)

    if not SD.SkinsRoot then
        for i = 1, 30 do
            task.wait(0.5)
            pcall(function()
                SD.SkinsRoot = RS:FindFirstChild("Assets") and RS.Assets:FindFirstChild("Skins")
            end)
            if SD.SkinsRoot then break end
        end
    end

    if not SD.SkinSelections or next(SD.SkinSelections) == nil then
        SD.SkinSelections = {
            ["Karambit"] = {"Default", "Vanilla", "Fade", "Slaughter", "Case Hardened", "Crimson Web"},
            ["Butterfly Knife"] = {"Default", "Vanilla", "Blackwidow", "Damascus", "Doodle", "Fade", "Lebron James", "Midnight", "Naval", "Nebula", "Rusted", "Safari", "Scarlet", "Tiger Stripes", "Violet", "Whiteout", "Widowmaker", "Woodland"},
            ["Flip Knife"] = {"Default", "Vanilla", "Fade", "Tiger Stripes", "Damascus", "Slaughter"},
            ["Gut Knife"] = {"Default", "Vanilla", "Fade", "Damascus", "Blue Steel", "Safari"},
            ["M9 Bayonet"] = {"Default", "Vanilla", "Fade", "Damascus", "Slaughter", "Case Hardened"},
            ["Skeleton Knife"] = {"Default", "Vanilla", "Fade", "Damascus", "Slaughter", "Doodle"},
            ["Stiletto Knife"] = {"Default", "Vanilla", "Fade", "Tiger Stripes", "Damascus"},
            ["Knife"] = {"Default", "Vanilla", "Fade"},
            ["T Knife"] = {"Default", "Vanilla", "Fade"},
            ["CT Knife"] = {"Default", "Vanilla", "Fade"},
        }
    end
    if SD.SkinsRoot then
        pcall(function()
            for _, wf in ipairs(SD.SkinsRoot:GetChildren()) do
                local skins = {}
                for _, sf in ipairs(wf:GetChildren()) do skins[#skins + 1] = sf.Name end
                table.sort(skins)
                SD.SkinSelections[wf.Name] = skins
            end
            for _, folder in ipairs(SD.SkinsRoot:GetChildren()) do
                if (folder.Name:match("Glove") or folder.Name:match("Gloves") or folder.Name == "Hand Wraps")
                   and not (folder.Name:match("T Glove") or folder.Name:match("CT Glove") or folder.Name:match("T Gloves") or folder.Name:match("CT Gloves")) then
                    SD.GloveFolders[#SD.GloveFolders + 1] = folder
                end
            end
        end)
    end
    for _, gf in ipairs(SD.GloveFolders) do
        local skins = {"Default"}
        for _, skin in ipairs(gf:GetChildren()) do skins[#skins + 1] = skin.Name end
        SD.GloveSelections[gf.Name] = skins
    end

    if next(SD.GloveSelections) == nil then
        SD.GloveSelections = {
            ["Sports Gloves"] = {"Default", "Pandora's Box", "Vice", "Bronze Morph", "Omega"},
            ["Driver Gloves"] = {"Default", "King Snake", "Black Tie", "Crimson Weave", "Lunar Weave", "Snow Leopard"},
            ["Hand Wraps"] = {"Default", "Crimson Web", "Slaughter", "Overprint", "Field Agent", "Badlands"},
            ["Specialist Gloves"] = {"Default", "Emerald Web", "Fade", "Marble Fade", "Crimson Kimono", "Slingshot"},
            ["Moto Gloves"] = {"Default", "Spearmint", "Cool Mint", "Turtle", "Polygon", "BOOM"},
            ["Bloodhound Gloves"] = {"Default", "Charred", "Snakebite", "Emerald", "Guerrilla", "Bronzed"},
        }
        SD.GloveFolders = {}
        for name in pairs(SD.GloveSelections) do
            SD.GloveFolders[#SD.GloveFolders + 1] = {Name = name}
        end
    end

    local Config = {
        SkinChanger = {Enabled = false, Skins = {}},
        KnifeChanger = {Enabled = false, Model = "Skeleton Knife"},
        GloveChanger = {Enabled = false, Gloves = {}, Model = "Sports Gloves", Skin = "Default"},
    }
    for w, _ in pairs(SD.SkinSelections) do Config.SkinChanger.Skins[w] = "Default" end
    Config.KnifeChanger.Side = { CT = nil, T = nil }
    Config.GloveChanger.Side = { CT = nil, T = nil }
    for _, gf in ipairs(SD.GloveFolders) do Config.GloveChanger.Gloves[gf.Name] = "Default" end

    local Checkifbaseknife = {"CT Knife", "T Knife", "Knife"}
    local function Checkknife(w)
        if not w then return false end
        for _, k in ipairs(Checkifbaseknife) do if w == k then return true end end
        return false
    end
    local ALLKNIVES = {["CT Knife"]=true, ["T Knife"]=true, ["Knife"]=true, ["Karambit"]=true,
        ["Butterfly Knife"]=true, ["Flip Knife"]=true, ["Gut Knife"]=true, ["M9 Bayonet"]=true,
        ["Skeleton Knife"]=true, ["Stiletto Knife"]=true}
    local function isAnyKnife(w) return w ~= nil and ALLKNIVES[w] == true end

    local function localSide()
        local t
        pcall(function() t = LP:GetAttribute("Team") or (LP.Team and LP.Team.Name) end)
        t = tostring(t or ""):upper()
        if t:find("CT") or t:find("COUNTER") then return "CT" end
        if t ~= "" and t ~= "NIL" then return "T" end
        return nil
    end

    local function resolveKnife(w)
        local side = (w == "CT Knife" and "CT") or (w == "T Knife" and "T") or localSide()
        local sides = Config.KnifeChanger.Side

        local s = (side and sides[side]) or sides.CT or sides.T
        local m, sk
        if s and s.Model then
            m, sk = s.Model, s.Skin
        else
            m = Config.KnifeChanger.Model
            sk = m and Config.SkinChanger.Skins[m]
        end
        if not m then return nil end
        if not sk or sk == "Default" then sk = "Vanilla" end
        return m, sk
    end

    local function knifeSwapArgs(w)
        if not Config.KnifeChanger.Enabled or not w or not isAnyKnife(w) then return nil end
        local m, sk = resolveKnife(w)
        if m and m ~= w then return m, sk end
        return nil
    end

    local function resolveGloves(g)
        local side
        if type(g) == "string" then
            if g:match("^CT") then side = "CT" elseif g:match("^T[ %-]") then side = "T" end
        end
        side = side or localSide()
        local sides = Config.GloveChanger.Side
        local s = side and sides[side]
        if s and s.Model then return s.Model, s.Skin or "Default" end
        if sides.CT or sides.T then return nil end
        local m = Config.GloveChanger.Model
        return m, Config.GloveChanger.Gloves[m] or "Default"
    end

    local SafeRequire = function(module)
        if not module then return nil end
        local success, result = pcall(function() return require(module) end)
        if success and result and type(result) == "table" then return result end
        return nil
    end

    local KM = {"Karambit", "Butterfly Knife", "Flip Knife", "Gut Knife", "M9 Bayonet", "Skeleton Knife", "Stiletto Knife"}
    local WEARS = {"Factory New", "Minimal Wear", "Field-Tested", "Well-Worn", "Battle-Scarred"}

    local function isKnife(n)
        for _, k in ipairs(KM) do if k == n then return true end end
        return false
    end
    local function isGloveName(n) return n:match("Glove") ~= nil or n == "Hand Wraps" end

    local function withDefault(list)
        local out = { "Default" }
        for _, n in ipairs(list or {}) do
            if n ~= "Default" then out[#out + 1] = n end
        end
        return out
    end

    local TYPE_OF = {}
    local function reg(t, list) for _, n in ipairs(list) do TYPE_OF[n] = t end end
    reg("Rifles", {"AK-47", "M4A4", "M4A1-S", "AUG", "SG 553", "FAMAS", "Galil AR"})
    reg("Snipers", {"AWP", "SSG 08", "SCAR-20", "G3SG1"})
    reg("SMGs", {"MP9", "MP7", "MP5-SD", "P90", "PP-Bizon", "UMP-45", "MAC-10"})
    reg("Pistols", {"Glock-18", "USP-S", "P2000", "Desert Eagle", "P250", "Five-SeveN", "Tec-9", "CZ75-Auto", "Dual Berettas", "R8 Revolver"})
    reg("Heavy", {"Nova", "XM1014", "MAG-7", "Sawed-Off", "M249", "Negev"})

    local WeaponAssets = RS:FindFirstChild("Assets") and RS.Assets:FindFirstChild("Weapons")
    local function buildKnifeModel(knifeName)
        if not WeaponAssets then return nil end
        local folder = WeaponAssets:FindFirstChild(knifeName)
        if not folder then
            for _, c in ipairs(WeaponAssets:GetChildren()) do
                if c.Name:lower() == knifeName:lower() then folder = c break end
            end
        end
        if not folder then return nil end
        local source = folder:FindFirstChild("Camera") or folder:FindFirstChild("Character") or folder
        local weapon = source:FindFirstChild("Weapon")
        if not weapon then
            for _, c in ipairs(source:GetDescendants()) do
                if c:IsA("Model") and c.Name == "Weapon" then weapon = c break end
            end
        end
        if not weapon then return nil end
        local clone = weapon:Clone()
        clone.Name = "Weapon"
        for _, d in ipairs(clone:GetDescendants()) do
            if d.Name == "Left Arm" or d.Name == "Right Arm" or d.Name == "ViewmodelLight"
                or d.Name == "Hitbox" or d.Name == "Insert" or d.Name == "Interactables" or d.Name == "MuzzlePart"
                or d.Name == "Properties" or d.Name == "Stats" or d.Name == "CameraShake"
                or d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript")
                or d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("PointLight") or d:IsA("SurfaceLight")
                or d:IsA("Motor6D") or d:IsA("Weld") or d:IsA("WeldConstraint") or d:IsA("ManualWeld") then
                pcall(function() d:Destroy() end)
            elseif d:IsA("BasePart") then
                d.Anchored = true
                d.CanCollide = false
                d.Transparency = 0
            end
        end
        local handle = clone:FindFirstChild("Handle") or clone:FindFirstChildWhichIsA("BasePart")
        if not handle then return nil end
        for _, p in ipairs(clone:GetDescendants()) do
            if p:IsA("BasePart") and p ~= handle then
                local weld = Instance.new("Weld")
                weld.Part0 = handle
                weld.Part1 = p
                weld.C0 = handle.CFrame:ToObjectSpace(p.CFrame)
                weld.Parent = handle
                p.Anchored = false
            end
        end
        return clone
    end

    local function previewWithSkin(weaponName, skin)
        local model = weaponName and buildKnifeModel(weaponName)
        if not model or not skin or skin == "Default" or not SD.SkinsRoot then return model end
        local wsf = SD.SkinsRoot:FindFirstChild(weaponName)
        local sf = wsf and wsf:FindFirstChild(skin)
        if not sf then return model end
        local sources = {}
        for _, cat in ipairs({"Camera", "Character"}) do
            local c = sf:FindFirstChild(cat)
            if c then
                for _, wear in ipairs(WEARS) do
                    local w = c:FindFirstChild(wear)
                    if w then
                        for _, sa in ipairs(w:GetChildren()) do
                            if sa:IsA("SurfaceAppearance") then sources[#sources + 1] = sa end
                        end
                        if #sources > 0 then break end
                    end
                end
                if #sources > 0 then break end
            end
        end
        if #sources == 0 then
            for _, sa in ipairs(sf:GetDescendants()) do
                if sa:IsA("SurfaceAppearance") then sources[#sources + 1] = sa end
            end
        end
        local function paint(part, sa)
            for _, old in ipairs(part:GetChildren()) do
                if old:IsA("SurfaceAppearance") then old:Destroy() end
            end
            sa:Clone().Parent = part
            if part:IsA("MeshPart") and sa.ColorMap ~= "" then
                pcall(function() part.TextureID = sa.ColorMap end)
            end
        end
        local applied = 0
        for _, sa in ipairs(sources) do
            local part = model:FindFirstChild(sa.Name, true)
            if part and part:IsA("BasePart") then
                paint(part, sa)
                applied = applied + 1
            end
        end
        if applied == 0 and sources[1] then
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("MeshPart") then paint(part, sources[1]) end
            end
        end
        return model
    end

    local function setKnife(m, sk)
        Config.KnifeChanger.Model = m
        Config.SkinChanger.Skins[m] = sk
        Config.KnifeChanger.Side.CT = { Model = m, Skin = sk }
        Config.KnifeChanger.Side.T = { Model = m, Skin = sk }
    end

    local function setGloves(m, sk)
        Config.GloveChanger.Model = m
        Config.GloveChanger.Gloves[m] = sk
        Config.GloveChanger.Side.CT = { Model = m, Skin = sk }
        Config.GloveChanger.Side.T = { Model = m, Skin = sk }
    end

    local knives = {}
    for _, k in ipairs(KM) do
        if SD.SkinSelections[k] then knives[#knives + 1] = k end
    end
    if #knives == 0 then knives = { Config.KnifeChanger.Model } end

    local gloves = {}
    for name in pairs(SD.GloveSelections) do gloves[#gloves + 1] = name end
    table.sort(gloves)
    if #gloves == 0 then gloves = { Config.GloveChanger.Model } end

    local TYPE_RANK = { Rifles = 1, Snipers = 2, SMGs = 3, Pistols = 4, Heavy = 5, Other = 6 }
    local guns = {}
    for name in pairs(SD.SkinSelections) do
        if not isKnife(name) and not isGloveName(name) and name ~= "Knife" and name ~= "CT Knife" and name ~= "T Knife" then
            guns[#guns + 1] = name
        end
    end
    table.sort(guns, function(a, b)
        local ra, rb = TYPE_RANK[TYPE_OF[a] or "Other"], TYPE_RANK[TYPE_OF[b] or "Other"]
        if ra ~= rb then return ra < rb end
        return a < b
    end)

    local function saveLoadout()
        Library.Flags.SkinLoadout = {
            Skins = Config.SkinChanger.Skins,
            Knife = Config.KnifeChanger.Side.CT,
            Gloves = Config.GloveChanger.Side.CT,
        }
        Library.Unsaved = true
    end
    Library.Signals.SkinLoadout = function(v)
        if type(v) ~= "table" then return end
        if type(v.Skins) == "table" then
            for w, sk in pairs(v.Skins) do Config.SkinChanger.Skins[w] = sk end
        end
        if type(v.Knife) == "table" and v.Knife.Model then setKnife(v.Knife.Model, v.Knife.Skin or "Default") end
        if type(v.Gloves) == "table" and v.Gloves.Model then setGloves(v.Gloves.Model, v.Gloves.Skin or "Default") end
    end

    local SkinBox = Tabs.SkinChanger:Section("Skin Changer", "Full")
    SkinBox:Toggle("Weapon Skins", "EnableSkins", false, "Apply the skins you equipped on guns", CB("EnableSkins", function(v)
        Config.SkinChanger.Enabled = v
    end), true)
    SkinBox:Toggle("Knife Changer", "KnifeChangerToggle", false, "Use the knife you equipped", CB("KnifeChangerToggle", function(v)
        Config.KnifeChanger.Enabled = v
    end), true)
    SkinBox:Toggle("Glove Changer", "GloveChangerToggle", false, "Use the gloves you equipped", CB("GloveChangerToggle", function(v)
        Config.GloveChanger.Enabled = v
    end), true)

    local previewGun, previewKnife
    SkinBox:SkinBrowser({
        subTabs = { "Skins", "Knives", "Gloves" },
        weapons = guns,
        getSkins = function(w)
            previewGun = w
            return withDefault(SD.SkinSelections[w])
        end,
        getModel = function(skin)
            return previewWithSkin(previewGun, skin)
        end,
        onEquip = function(w, skin)
            Config.SkinChanger.Skins[w] = skin or "Default"
            if not Config.SkinChanger.Enabled then Toggles.EnableSkins:SetValue(true) end
            saveLoadout()
            Library:Notify("Skins", (skin or "Default") .. " equipped on " .. w, 2, "Success")
            return true
        end,
        onRestore = function()
            for w in pairs(SD.SkinSelections) do Config.SkinChanger.Skins[w] = "Default" end
            saveLoadout()
            Library:Notify("Skins", "All gun skins reset", 2)
        end,
        tabs = {
            Knives = {
                weapons = knives,
                itemHeader = "SKIN",
                getItems = function(k)
                    previewKnife = k
                    return withDefault(SD.SkinSelections[k])
                end,
                getModel = function(skin)
                    return previewWithSkin(previewKnife, skin)
                end,
                onEquip = function(k, skin)
                    if not k then return end
                    setKnife(k, skin or "Default")
                    if not Config.KnifeChanger.Enabled then Toggles.KnifeChangerToggle:SetValue(true) end
                    saveLoadout()
                    Library:Notify("Knives", k .. " (" .. (skin or "Default") .. ") equipped", 2, "Success")
                end,
                onRestore = function()
                    Config.KnifeChanger.Side.CT, Config.KnifeChanger.Side.T = nil, nil
                    if Config.KnifeChanger.Enabled then Toggles.KnifeChangerToggle:SetValue(false) end
                    saveLoadout()
                    Library:Notify("Knives", "Back to the default knife", 2)
                end,
            },
            Gloves = {
                weapons = gloves,
                itemHeader = "SKIN",
                getItems = function(g)
                    return withDefault(SD.GloveSelections[g])
                end,
                onEquip = function(g, skin)
                    if not g then return end
                    setGloves(g, skin or "Default")
                    if not Config.GloveChanger.Enabled then Toggles.GloveChangerToggle:SetValue(true) end
                    saveLoadout()
                    Library:Notify("Gloves", g .. " (" .. (skin or "Default") .. ") equipped", 2, "Success")
                end,
                onRestore = function()
                    Config.GloveChanger.Side.CT, Config.GloveChanger.Side.T = nil, nil
                    if Config.GloveChanger.Enabled then Toggles.GloveChangerToggle:SetValue(false) end
                    saveLoadout()
                    Library:Notify("Gloves", "Back to the default gloves", 2)
                end,
            },
        },
    })

    local function liveSwapKnife(wm, knifeName)
        if not wm or not knifeName then return end
        if wm:GetAttribute("BS_Knife") == knifeName then return end

        for _, c in ipairs(wm:GetChildren()) do
            if c.Name:sub(1, 3) == "BS_" then pcall(function() c:Destroy() end) end
        end
        local custom = buildKnifeModel(knifeName)
        if not custom then return end

        for _, d in ipairs(custom:GetDescendants()) do
            if d:IsA("BasePart") then
                d.Anchored = false
                d.CanCollide = false
            end
        end

        for _, d in ipairs(wm:GetDescendants()) do
            if d:IsA("BasePart") then
                d.Transparency = 1
                d.CanCollide = false
            elseif d:IsA("Decal") or d:IsA("Texture") then
                d.Transparency = 1
            end
        end
        custom.Name = "BS_" .. knifeName
        local oldH = wm:FindFirstChild("Handle") or wm:FindFirstChildWhichIsA("BasePart")
        local newH = custom:FindFirstChild("Handle") or custom:FindFirstChildWhichIsA("BasePart")
        if oldH and newH then
            local w = Instance.new("Weld")
            w.Part0 = oldH
            w.Part1 = newH
            w.C0 = oldH.CFrame:ToObjectSpace(newH.CFrame)
            w.Parent = oldH
        end
        custom.Parent = wm
        wm:SetAttribute("BS_Knife", knifeName)
    end

    local function InitKnifeChanger()
        pcall(function()
            local SM, VM

            for _ = 1, 40 do
                SM = RS:FindFirstChild("Database") and RS.Database:FindFirstChild("Components") and
                    RS.Database.Components:FindFirstChild("Libraries") and
                    RS.Database.Components.Libraries:FindFirstChild("Skins")
                VM = RS:FindFirstChild("Classes") and RS.Classes:FindFirstChild("WeaponComponent") and
                    RS.Classes.WeaponComponent:FindFirstChild("Classes") and
                    RS.Classes.WeaponComponent.Classes:FindFirstChild("Viewmodel")
                if SM and VM then break end
                task.wait(0.5)
            end
            if not SM or not VM then return end
            local Sk = SafeRequire(SM)
            local Vm = SafeRequire(VM)
            if not Sk or not Vm then return end

            local oGCM = Sk.GetCameraModel
            Sk.GetCameraModel = function(w, sk, ...)
                local nk, nsk = knifeSwapArgs(w)
                if nk then
                    local ok, result = pcall(oGCM, nk, nsk, ...)
                    if ok and result then return result end

                    local custom = buildKnifeModel(nk)
                    if custom then return custom end
                end
                local ok, result = pcall(oGCM, w, sk, ...)
                if ok then return result end
                return nil
            end

            local oGChM = Sk.GetCharacterModel
            Sk.GetCharacterModel = function(w, sk, ...)
                local nk, nsk = knifeSwapArgs(w)
                if nk then
                    local ok, result = pcall(oGChM, nk, nsk, ...)
                    if ok and result then return result end
                    local custom = buildKnifeModel(nk)
                    if custom then return custom end
                end
                local ok, result = pcall(oGChM, w, sk, ...)
                if ok then return result end
                return nil
            end

            local oVN = Vm.new
            Vm.new = function(vc, w, sk, ...)
                local nk, nsk = knifeSwapArgs(w)
                if nk then
                    local ok, result = pcall(oVN, vc, nk, nsk, ...)
                    if ok and result then return result end
                    local custom = buildKnifeModel(nk)
                    if custom then return custom end
                end
                local ok, result = pcall(oVN, vc, w, sk, ...)
                if ok then return result end
                return nil
            end

            if Sk.GetGloves then
                local oGG = Sk.GetGloves
                Sk.GetGloves = function(g, sk)
                    local gModel, ts = resolveGloves(g)
                    if Config.GloveChanger.Enabled and gModel then
                        local ok, result = pcall(oGG, gModel, ts)
                        if ok and result then return result end
                    end
                    local ok, result = pcall(oGG, g, sk)
                    if ok then return result end
                    return nil
                end
            end
        end)
    end
    if G.knifeChangerSupported then task.spawn(InitKnifeChanger) end

    local function UpdateInventoryNames()
        pcall(function()
            local invGui = LP:FindFirstChild("PlayerGui") and LP.PlayerGui:FindFirstChild("MainGui")
            if not invGui then return end
            local gameplay = invGui:FindFirstChild("Gameplay")
            if not gameplay then return end
            local bottom = gameplay:FindFirstChild("Bottom")
            if not bottom then return end
            local inv = bottom:FindFirstChild("Inventory")
            if not inv then return end
            local meleeSlot = inv:FindFirstChild("Melee")
            if meleeSlot and Config.KnifeChanger.Enabled then
                local weapon = meleeSlot:FindFirstChild("Weapon")
                if weapon then
                    local weaponName = weapon:FindFirstChild("WeaponName")
                    if weaponName and weaponName:IsA("TextLabel") then
                        local knifeModel = Config.KnifeChanger.Model
                        local sel = Config.SkinChanger.Skins[knifeModel]
                        local star = utf8.char(9733)
                        if sel and sel ~= "Default" then
                            weaponName.Text = star .. " " .. knifeModel .. "  " .. sel
                        else
                            weaponName.Text = star .. " " .. knifeModel
                        end
                    end
                end
            end
        end)
    end

    local function GetWeaponModel()
        local cam = Workspace.CurrentCamera
        if not cam then return nil end
        for _, ch in pairs(cam:GetChildren()) do
            if ch:IsA("Model") and ch.Name ~= "Arms" and ch.Name ~= "Arms1" and ch.Name ~= "Arms2" and ch.Name ~= "Viewmodel" then
                return ch
            end
        end
        return nil
    end

    local function applySAFromFolder(wm, wsf, sel, knifeForSkin)

        local sf = wsf:FindFirstChild(sel)
        if not sf then return 0 end

        local searchRoot = wm
        for _, c in ipairs(wm:GetChildren()) do
            if c.Name:sub(1, 3) == "BS_" then searchRoot = c break end
        end
        local sources = {}
        for _, cat in ipairs({"Camera", "Character"}) do
            local c = sf:FindFirstChild(cat)
            if c then
                for _, wear in ipairs(WEARS) do
                    local w = c:FindFirstChild(wear)
                    if w then
                        for _, sa in ipairs(w:GetChildren()) do
                            if sa:IsA("SurfaceAppearance") then sources[#sources+1] = sa end
                        end
                        if #sources > 0 then break end
                    end
                end
                if #sources > 0 then break end
            end
        end
        if #sources == 0 then return 0 end
        local applied = 0
        for _, sa in ipairs(sources) do
            local pt = searchRoot:FindFirstChild(sa.Name, true)
            if pt and pt:IsA("BasePart") then
                for _, old in pairs(pt:GetChildren()) do
                    if old:IsA("SurfaceAppearance") then old:Destroy() end
                end
                sa:Clone().Parent = pt
                applied = applied + 1
            end
        end

        if applied == 0 then
            local handle = searchRoot:FindFirstChild("Handle") or searchRoot:FindFirstChildWhichIsA("BasePart")
            if handle then
                for _, old in pairs(handle:GetChildren()) do
                    if old:IsA("SurfaceAppearance") then old:Destroy() end
                end
                sources[1]:Clone().Parent = handle
                applied = 1
            end
        end
        return applied
    end

    local function ApplySkin()
        if not SD.SkinsRoot then return end
        local wm = GetWeaponModel()
        if not wm then return end
        local own = wm.Name
        local ewn = own
        local ca = false
        local knifeSkin = nil

        if isAnyKnife(own) then
            if Config.KnifeChanger.Enabled then
                local rm, rs = resolveKnife(own)
                if rm then ewn = rm knifeSkin = rs ca = true

                    if rm ~= own then liveSwapKnife(wm, rm) end
                end
            end

            if not ca then
                local direct = Config.SkinChanger.Skins[own]
                if direct and direct ~= "Default" then
                    ewn = own knifeSkin = direct ca = true
                end
            end
        else
            if Config.SkinChanger.Enabled then ca = true end
        end
        if not ca then return end
        local sel = knifeSkin or Config.SkinChanger.Skins[ewn]
        if not sel or sel == "Default" then return end
        local wsf = SD.SkinsRoot:FindFirstChild(ewn)
        if not wsf then return end
        applySAFromFolder(wm, wsf, sel, ewn)
        UpdateInventoryNames()
    end

    local function ApplyGloves()
        if not Config.GloveChanger.Enabled then return end
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local am
        for _, ch in ipairs(cam:GetChildren()) do
            if ch:IsA("Model") and (ch.Name:match("Arms") or ch:FindFirstChild("Right Arm")) then
                am = ch
                break
            end
        end
        if not am then return end
        local la = am:FindFirstChild("Left Arm")
        local ra = am:FindFirstChild("Right Arm")
        if not la or not ra then return end
        local lg = la:FindFirstChild("Glove")
        local rg = ra:FindFirstChild("Glove")
        if not lg or not rg then return end
        for _, old in pairs(lg:GetChildren()) do if old:IsA("SurfaceAppearance") then old:Destroy() end end
        for _, old in pairs(rg:GetChildren()) do if old:IsA("SurfaceAppearance") then old:Destroy() end end
        local selectedModel, sel = resolveGloves(nil)
        if not selectedModel then return end
        if not sel or sel == "Default" then return end
        if not SD.SkinsRoot then return end
        local gloveSkinFolder = SD.SkinsRoot:FindFirstChild(selectedModel)
        if not gloveSkinFolder then return end
        local skinVariant = gloveSkinFolder:FindFirstChild(sel)
        if not skinVariant then return end
        local cameraFolder = skinVariant:FindFirstChild("Camera")
        if not cameraFolder then return end
        local factoryNew = cameraFolder:FindFirstChild("Factory New")
        if not factoryNew then return end
        for _, sa in pairs(factoryNew:GetChildren()) do
            if sa:IsA("SurfaceAppearance") then
                sa:Clone().Parent = lg
                sa:Clone().Parent = rg
            end
        end
    end

    task.spawn(function()
        while PH.alive do
            pcall(function()
                if Config.SkinChanger.Enabled or Config.KnifeChanger.Enabled then ApplySkin() end
                if Config.GloveChanger.Enabled then ApplyGloves() end
            end)
            task.wait(0.2)
        end
    end)
end

local function hasVestDetails(character)
    if not character then return false end
    local armor = character:FindFirstChild("CharacterArmor")
    if armor and armor:FindFirstChild("VestDetails") then
        return true
    end
    return false
end

local function isCharacterAlly(targetChar)
    if not LP.Character then return false end
    local myHasVest = hasVestDetails(LP.Character)
    local targetHasVest = hasVestDetails(targetChar)
    if not myHasVest then
        return not targetHasVest
    else
        return targetHasVest
    end
end

local VisualsESPBox = Tabs.Visuals:Section("ESP", "Left")

VisualsESPBox:Toggle("ESP", "ESPEnabled", false, nil, CB("ESPEnabled", nil), true)
VisualsESPBox:Toggle("Team Check", "ESPTeamCheck", false, nil, CB("ESPTeamCheck", nil), true)

VisualsESPBox:Toggle("Hide Behind Walls", "ESPHideWalls", false, "Only show far players you could actually see", CB("ESPHideWalls", nil), true)
VisualsESPBox:Slider("Wall Check Distance" .. " (" .. "m" .. ")", "ESPWallDist", 10, 500, 50, 1, nil, CB("ESPWallDist", nil))

Dropdowns["ESPBoxType"] = VisualsESPBox:Dropdown("Box ESP", "ESPBoxType", {"2D Box","3D Box","Corner Box","Disabled"}, Pick({"2D Box","3D Box","Corner Box","Disabled"}, "2D Box"), nil, CB("ESPBoxType", nil))
VisualsESPBox:ColorPicker("Box Color A", "ESPBoxColorA", Color3.fromRGB(255,255,255), nil, CB("ESPBoxColorA", nil))
VisualsESPBox:ColorPicker("Box Color B", "ESPBoxColorB", Color3.fromRGB(0,200,255), nil, CB("ESPBoxColorB", nil))
VisualsESPBox:Toggle("Fill Gradient", "ESPBoxFillGradient", false, nil, CB("ESPBoxFillGradient", nil), true)
VisualsESPBox:ColorPicker("Fill Color ", "ESPFillColorA", Color3.fromRGB(255,50,50), nil, CB("ESPFillColorA", nil))
VisualsESPBox:ColorPicker("Fill Color ", "ESPFillColorB", Color3.fromRGB(50,50,255), nil, CB("ESPFillColorB", nil))
VisualsESPBox:Toggle("Fill Rotation", "ESPBoxFillRotation", false, nil, CB("ESPBoxFillRotation", nil), true)
VisualsESPBox:Slider("Rotation Speed", "ESPBoxRotationSpeed", 0.1, 10, 2, 0.1, nil, CB("ESPBoxRotationSpeed", nil))

VisualsESPBox = Tabs.Visuals:Section("ESP Info", "Right")
VisualsESPBox:Toggle("Name ESP", "ESPName", false, nil, CB("ESPName", nil), true)
VisualsESPBox:ColorPicker("Name Color", "ESPNameColor", Color3.new(1,1,1), nil, CB("ESPNameColor", nil))

VisualsESPBox:Toggle("Health Bar", "ESPHealth", false, nil, CB("ESPHealth", nil), true)
VisualsESPBox:ColorPicker("Health Top Color", "ESPHealthTopColor", Color3.fromRGB(0,255,0), nil, CB("ESPHealthTopColor", nil))
VisualsESPBox:ColorPicker("Health Bottom Color", "ESPHealthBottomColor", Color3.fromRGB(255,0,0), nil, CB("ESPHealthBottomColor", nil))

VisualsESPBox:Toggle("Health Text", "ESPHealthText", false, nil, CB("ESPHealthText", nil), true)
VisualsESPBox:ColorPicker("HP Text Color", "ESPHealthTextColor", Color3.new(1,1,1), nil, CB("ESPHealthTextColor", nil))

VisualsESPBox:Toggle("Distance ESP", "ESPDistance", false, nil, CB("ESPDistance", nil), true)
VisualsESPBox:ColorPicker("Distance Color", "ESPDistanceColor", Color3.new(1,1,1), nil, CB("ESPDistanceColor", nil))

VisualsESPBox:Toggle("Show Weapon Name", "ESPWeapon", false, nil, CB("ESPWeapon", nil), true)
VisualsESPBox:ColorPicker("Weapon Color", "ESPWeaponColor", Color3.new(1,1,1), nil, CB("ESPWeaponColor", nil))

VisualsESPBox:Toggle("Tracer ESP", "ESPTracer", false, nil, CB("ESPTracer", nil), true)
VisualsESPBox:ColorPicker("Tracer Color", "ESPTracerColor", Color3.new(1,1,1), nil, CB("ESPTracerColor", nil))
VisualsESPBox:ColorPicker("Tracer Color ", "ESPTracerColorB", Color3.fromRGB(255,0,128), nil, CB("ESPTracerColorB", nil))
Dropdowns["ESPTracerOrigin"] = VisualsESPBox:Dropdown("Tracer Origin", "ESPTracerOrigin", {"Bottom","Top","Center","Mouse"}, Pick({"Bottom","Top","Center","Mouse"}, "Bottom"), nil, CB("ESPTracerOrigin", nil))

VisualsESPBox:Toggle("Skeleton ESP", "ESPSkeleton", false, nil, CB("ESPSkeleton", nil), true)
VisualsESPBox:ColorPicker("Skeleton Color", "ESPSkeletonColorA", Color3.new(1,1,1), nil, CB("ESPSkeletonColorA", nil))
VisualsESPBox:ColorPicker("Skeleton Color ", "ESPSkeletonColorB", Color3.fromRGB(0,255,255), nil, CB("ESPSkeletonColorB", nil))

VisualsESPBox:Toggle("Circular Target", "ESPCircularTarget", false, nil, CB("ESPCircularTarget", nil), true)
VisualsESPBox:ColorPicker("Circular Target Color", "ESPCircularTargetColor", Color3.fromRGB(255,200,0), nil, CB("ESPCircularTargetColor", nil))

local CT_COLOR = Color3.fromRGB(80, 170, 255)
local T_COLOR  = Color3.fromRGB(255, 70, 70)
local UNKNOWN_COLOR = Color3.fromRGB(255, 170, 0)

local BONES_R15 = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}
local BONES_R6 = {
    {"Head", "Torso"}, {"Torso", "Left Arm"},
    {"Torso", "Right Arm"}, {"Torso", "Left Leg"},
    {"Torso", "Right Leg"},
}

local ESP = { objects = {}, weaponCache = {} }

function ESP.on(flag)
    local t = Toggles[flag]
    return t ~= nil and t.Value == true
end

function ESP.opt(flag, default)
    local o = Options[flag]
    if o == nil or o.Value == nil then return default end
    return o.Value
end

function ESP.team(model, plr)
    if plr then
        local raw = string.lower(tostring(plr:GetAttribute("Team") or (plr.Team and plr.Team.Name) or "")):gsub("[%s_-]+", "")
        if raw:match("counter") or raw == "ct" then return "CT" end
        if raw:match("terror") or raw == "t" then return "T" end
    end
    return hasVestDetails(model) and "CT" or "T"
end

function ESP.isEnemy(model, plr)
    if not ESP.on("ESPTeamCheck") then return true end
    local mine = LP.Character
    if not mine then return true end
    return ESP.team(model, plr) ~= ESP.team(mine, LP)
end

function ESP.alive(model)
    if not model.Parent or not model:FindFirstChild("HumanoidRootPart") then return false end
    if model:GetAttribute("Dead") == true then return false end
    local hp = model:GetAttribute("Health")
    if hp ~= nil and hp <= 0 then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then return false end
    return true
end

function ESP.weapon(plr)
    if not plr or not plr.GetAttribute then return nil end
    local attr = plr:GetAttribute("CurrentEquipped")
    if type(attr) ~= "string" then return nil end
    local cached = ESP.weaponCache[attr]
    if cached == nil then
        local ok, dec = pcall(function() return HttpService:JSONDecode(attr) end)
        cached = (ok and type(dec) == "table" and dec.Name) or false
        ESP.weaponCache[attr] = cached
    end
    return cached or nil
end

function ESP.new(kind, props)
    local d = Drawing.new(kind)
    for k, v in pairs(props) do
        pcall(function() d[k] = v end)
    end
    d.Visible = false
    return d
end

function ESP.make(model)
    local o = { model = model, all = {} }
    local function add(kind, props)
        local d = ESP.new(kind, props)
        table.insert(o.all, d)
        return d
    end
    o.fill = add("Square", { Filled = true, Thickness = 1, Transparency = 0.25 })
    o.outline = add("Square", { Filled = false, Thickness = 3, Color = Color3.new(0, 0, 0), Transparency = 0.8 })
    o.box = add("Square", { Filled = false, Thickness = 1, Transparency = 1 })
    o.corners = {}
    for i = 1, 8 do o.corners[i] = add("Line", { Thickness = 1.5, Transparency = 1 }) end
    o.cube = {}
    for i = 1, 12 do o.cube[i] = add("Line", { Thickness = 1, Transparency = 1 }) end
    o.name = add("Text", { Size = 14, Center = true, Outline = true, Transparency = 1 })
    o.info = add("Text", { Size = 13, Center = true, Outline = true, Transparency = 1 })
    o.weapon = add("Text", { Size = 13, Center = true, Outline = true, Transparency = 1 })
    o.hpText = add("Text", { Size = 12, Center = false, Outline = true, Transparency = 1 })
    o.hpBack = add("Square", { Filled = true, Thickness = 1, Color = Color3.new(0, 0, 0), Transparency = 0.6 })
    o.hpBar = add("Square", { Filled = true, Thickness = 1, Transparency = 1 })
    o.tracer = add("Line", { Thickness = 1.5, Transparency = 1 })
    o.bones = {}
    for i = 1, #BONES_R15 do o.bones[i] = add("Line", { Thickness = 1.5, Transparency = 1 }) end
    o.ring = add("Circle", { Thickness = 2, NumSides = 32, Filled = false, Transparency = 1 })
    ESP.objects[model] = o
    return o
end

function ESP.hide(o)
    for _, d in ipairs(o.all) do d.Visible = false end
end

function ESP.remove(model)
    local o = ESP.objects[model]
    if not o then return end
    for _, d in ipairs(o.all) do pcall(function() d:Remove() end) end
    ESP.objects[model] = nil
end

ESP.cubeEdges = { {1, 2}, {2, 4}, {4, 3}, {3, 1}, {5, 6}, {6, 8}, {8, 7}, {7, 5}, {1, 5}, {2, 6}, {3, 7}, {4, 8} }

function ESP.draw(o, plr)
    local model = o.model
    local root = model:FindFirstChild("HumanoidRootPart")
    local head = model:FindFirstChild("Head")
    if not root then return ESP.hide(o) end
    local camPos = Camera.CFrame.Position
    local dist = (root.Position - camPos).Magnitude

    if ESP.on("ESPHideWalls") and dist > ESP.opt("ESPWallDist", 50) then
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { Camera, LP.Character, model }
        local hit = Workspace:Raycast(camPos, root.Position - camPos, params)
        if hit and hit.Instance.Transparency < 0.9 then return ESP.hide(o) end
    end

    local top = head and (head.Position.Y + head.Size.Y / 2) or (root.Position.Y + 2.5)
    local bottom = root.Position.Y - 3
    for _, n in ipairs({ "LeftFoot", "RightFoot", "Left Leg", "Right Leg" }) do
        local p = model:FindFirstChild(n)
        if p then bottom = math.min(bottom, p.Position.Y - p.Size.Y / 2) end
    end
    local height = math.max(top - bottom, 2)
    local look = root.CFrame.LookVector
    local flat = Vector3.new(look.X, 0, look.Z)
    if flat.Magnitude < 0.01 then flat = Vector3.new(0, 0, -1) end
    local frame = CFrame.lookAt(Vector3.new(root.Position.X, bottom + height / 2, root.Position.Z), Vector3.new(root.Position.X, bottom + height / 2, root.Position.Z) + flat.Unit)
    local half = Vector3.new(2, height / 2, 1.2)

    local corners, minX, minY, maxX, maxY, anyFront = {}, math.huge, math.huge, -math.huge, -math.huge, false
    for i, s in ipairs({ {-1, -1, -1}, {1, -1, -1}, {-1, 1, -1}, {1, 1, -1}, {-1, -1, 1}, {1, -1, 1}, {-1, 1, 1}, {1, 1, 1} }) do
        local world = (frame * CFrame.new(half.X * s[1], half.Y * s[2], half.Z * s[3])).Position
        local sp = Camera:WorldToViewportPoint(world)
        if sp.Z > 0 then anyFront = true end
        corners[i] = Vector2.new(sp.X, sp.Y)
        minX, minY = math.min(minX, sp.X), math.min(minY, sp.Y)
        maxX, maxY = math.max(maxX, sp.X), math.max(maxY, sp.Y)
    end
    local center, onScreen = Camera:WorldToViewportPoint(root.Position)
    if not anyFront or center.Z <= 0 then return ESP.hide(o) end

    local boxPos = Vector2.new(minX, minY)
    local boxSize = Vector2.new(maxX - minX, maxY - minY)
    local colorA = ESP.opt("ESPBoxColorA", Color3.new(1, 1, 1))
    local colorB = ESP.opt("ESPBoxColorB", colorA)
    local boxType = ESP.opt("ESPBoxType", "2D Box")
    local twoD = boxType == "2D Box"
    local corner = boxType == "Corner Box"
    local cube = boxType == "3D Box"

    o.box.Visible, o.outline.Visible = twoD and onScreen, twoD and onScreen
    if twoD then
        o.box.Position, o.box.Size, o.box.Color = boxPos, boxSize, colorA
        o.outline.Position, o.outline.Size = boxPos, boxSize
    end

    local cw, ch = boxSize.X * 0.3, boxSize.Y * 0.22
    local tl, tr, bl, br = boxPos, boxPos + Vector2.new(boxSize.X, 0), boxPos + Vector2.new(0, boxSize.Y), boxPos + boxSize
    local cornerLines = {
        { tl, tl + Vector2.new(cw, 0) }, { tl, tl + Vector2.new(0, ch) },
        { tr, tr - Vector2.new(cw, 0) }, { tr, tr + Vector2.new(0, ch) },
        { bl, bl + Vector2.new(cw, 0) }, { bl, bl - Vector2.new(0, ch) },
        { br, br - Vector2.new(cw, 0) }, { br, br - Vector2.new(0, ch) },
    }
    for i, l in ipairs(o.corners) do
        l.Visible = corner and onScreen
        if corner then l.From, l.To, l.Color = cornerLines[i][1], cornerLines[i][2], i % 2 == 0 and colorB or colorA end
    end
    for i, l in ipairs(o.cube) do
        l.Visible = cube and onScreen
        if cube then
            local e = ESP.cubeEdges[i]
            l.From, l.To, l.Color = corners[e[1]], corners[e[2]], i > 4 and colorB or colorA
        end
    end

    local fillOn = ESP.on("ESPBoxFillGradient") and onScreen and boxType ~= "Disabled"
    o.fill.Visible = fillOn
    if fillOn then
        local t = ESP.on("ESPBoxFillRotation") and (math.sin(os.clock() * ESP.opt("ESPBoxRotationSpeed", 2)) + 1) / 2 or 0
        o.fill.Position, o.fill.Size = boxPos, boxSize
        o.fill.Color = ESP.opt("ESPFillColorA", colorA):Lerp(ESP.opt("ESPFillColorB", colorA), t)
    end

    local textY = minY - 16
    o.name.Visible = ESP.on("ESPName") and onScreen
    if o.name.Visible then
        o.name.Text = model.Name
        o.name.Position = Vector2.new((minX + maxX) / 2, textY)
        o.name.Color = ESP.opt("ESPNameColor", Color3.new(1, 1, 1))
    end
    local below = maxY + 2
    o.info.Visible = ESP.on("ESPDistance") and onScreen
    if o.info.Visible then
        o.info.Text = math.floor(dist) .. " m"
        o.info.Position = Vector2.new((minX + maxX) / 2, below)
        o.info.Color = ESP.opt("ESPDistanceColor", Color3.new(1, 1, 1))
        below = below + 14
    end
    local wname = ESP.on("ESPWeapon") and ESP.weapon(plr)
    o.weapon.Visible = wname ~= nil and wname ~= false and onScreen
    if o.weapon.Visible then
        o.weapon.Text = tostring(wname)
        o.weapon.Position = Vector2.new((minX + maxX) / 2, below)
        o.weapon.Color = ESP.opt("ESPWeaponColor", Color3.new(1, 1, 1))
    end

    local hp = tonumber(model:GetAttribute("Health")) or 100
    local maxHp = tonumber(model:GetAttribute("MaxHealth")) or 100
    local pct = math.clamp(hp / math.max(maxHp, 1), 0, 1)
    local barOn = ESP.on("ESPHealth") and onScreen
    o.hpBack.Visible, o.hpBar.Visible = barOn, barOn
    if barOn then
        o.hpBack.Position, o.hpBack.Size = Vector2.new(minX - 6, minY - 1), Vector2.new(4, boxSize.Y + 2)
        o.hpBar.Position = Vector2.new(minX - 5, minY + boxSize.Y * (1 - pct))
        o.hpBar.Size = Vector2.new(2, boxSize.Y * pct)
        o.hpBar.Color = ESP.opt("ESPHealthBottomColor", Color3.fromRGB(255, 0, 0)):Lerp(ESP.opt("ESPHealthTopColor", Color3.fromRGB(0, 255, 0)), pct)
    end
    o.hpText.Visible = ESP.on("ESPHealthText") and onScreen
    if o.hpText.Visible then
        o.hpText.Text = tostring(math.floor(hp))
        o.hpText.Position = Vector2.new(minX - 8 - #tostring(math.floor(hp)) * 7, minY + boxSize.Y * (1 - pct) - 6)
        o.hpText.Color = ESP.opt("ESPHealthTextColor", Color3.new(1, 1, 1))
    end

    o.tracer.Visible = ESP.on("ESPTracer") and onScreen
    if o.tracer.Visible then
        local vs = Camera.ViewportSize
        local origin = ESP.opt("ESPTracerOrigin", "Bottom")
        local from = origin == "Top" and Vector2.new(vs.X / 2, 0) or origin == "Center" and vs / 2 or origin == "Mouse" and UserInputService:GetMouseLocation() or Vector2.new(vs.X / 2, vs.Y)
        o.tracer.From, o.tracer.To = from, Vector2.new((minX + maxX) / 2, origin == "Top" and minY or maxY)
        o.tracer.Color = ESP.opt("ESPTracerColor", Color3.new(1, 1, 1)):Lerp(ESP.opt("ESPTracerColorB", Color3.new(1, 1, 1)), math.clamp(dist / 300, 0, 1))
    end

    local skelOn = ESP.on("ESPSkeleton") and onScreen
    local bones = model:FindFirstChild("UpperTorso") and BONES_R15 or BONES_R6
    for i, l in ipairs(o.bones) do
        local b = bones[i]
        local pa = skelOn and b and model:FindFirstChild(b[1])
        local pb = skelOn and b and model:FindFirstChild(b[2])
        if pa and pb then
            local a, va = Camera:WorldToViewportPoint(pa.Position)
            local c, vc = Camera:WorldToViewportPoint(pb.Position)
            l.Visible = va and vc
            l.From, l.To = Vector2.new(a.X, a.Y), Vector2.new(c.X, c.Y)
            l.Color = ESP.opt("ESPSkeletonColorA", Color3.new(1, 1, 1)):Lerp(ESP.opt("ESPSkeletonColorB", Color3.new(1, 1, 1)), i / #bones)
        else
            l.Visible = false
        end
    end

    local ringOn = ESP.on("ESPCircularTarget") and onScreen
    o.ring.Visible = ringOn
    if ringOn then
        local feet = Camera:WorldToViewportPoint(Vector3.new(root.Position.X, bottom, root.Position.Z))
        o.ring.Position = Vector2.new(feet.X, feet.Y)
        o.ring.Radius = math.clamp(boxSize.X * 0.6, 6, 80)
        o.ring.Color = ESP.opt("ESPCircularTargetColor", Color3.fromRGB(255, 200, 0))
    end
end

PH.conns[#PH.conns + 1] = RunService.RenderStepped:Connect(function()
    if not PH.alive then return end
    local enabled = ESP.on("ESPEnabled")
    local folder = Workspace:FindFirstChild("Characters")
    local seen = {}
    if enabled and folder then
        for _, model in ipairs(folder:GetChildren()) do
            if model:IsA("Model") and model ~= LP.Character and model.Name ~= LP.Name then
                local plr = Players:GetPlayerFromCharacter(model) or Players:FindFirstChild(model.Name)
                if ESP.alive(model) and ESP.isEnemy(model, plr) then
                    seen[model] = true
                    local o = ESP.objects[model] or ESP.make(model)
                    local ok = pcall(ESP.draw, o, plr)
                    if not ok then ESP.hide(o) end
                end
            end
        end
    end
    for model, o in pairs(ESP.objects) do
        if not seen[model] then
            if model.Parent then ESP.hide(o) else ESP.remove(model) end
        end
    end
end)

table.insert(PH.cleanup or {}, function()
    for model in pairs(ESP.objects) do ESP.remove(model) end
end)

local LegitAimBox = Tabs.Legit:Section("Aimbot", "Left")

LegitAimBox:Toggle("Aimbot", "LegitAimMainToggle", false, nil, CB("LegitAimMainToggle", nil), true)
LegitAimBox:Keybind("Aimbot Key", "LegitAimKeybind", Key("None"), "Toggle", nil, KB("LegitAimKeybind"))

local LegitAimDepBox = LegitAimBox

LegitAimDepBox:Toggle("Smart Aim", "LegitAimEnabled", false, nil, CB("LegitAimEnabled", nil), true)
LegitAimDepBox:Toggle("Visible Check", "LegitAimVisibleCheck", false, nil, CB("LegitAimVisibleCheck", nil), true)

Dropdowns["LegitAimHitPart"] = LegitAimDepBox:Dropdown("Aim Part", "LegitAimHitPart", {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, Pick({"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, "Head"), nil, CB("LegitAimHitPart", nil))

LegitAimDepBox = Tabs.Legit:Section("Triggerbot", "Right")

LegitAimDepBox:Toggle("Triggerbot", "LegitTriggerbot", false, nil, CB("LegitTriggerbot", nil), true)
LegitAimDepBox:Slider("Triggerbot Delay", "LegitTriggerbotDelay", 0, 1, 0.01, 0.001, nil, CB("LegitTriggerbotDelay", nil))

LegitAimDepBox = Tabs.Legit:Section("Target", "Right")

LegitAimDepBox:Toggle("Show Target", "ShowLegitTarget", false, nil, CB("ShowLegitTarget", nil), true)

Dropdowns["ShowLegitTargetMode"] = LegitAimDepBox:Dropdown("Target Display Mode", "ShowLegitTargetMode", {"Line", "Crosshair"}, Pick({"Line", "Crosshair"}, "Crosshair"), nil, CB("ShowLegitTargetMode", nil))

LegitAimDepBox:ColorPicker("Line Color", "ShowLegitTargetLineColor", Color3.fromRGB(0, 255, 255), nil, CB("ShowLegitTargetLineColor", nil))

LegitAimDepBox:ColorPicker("Crosshair Color", "ShowLegitTargetCrosshairColor", Color3.fromRGB(0, 255, 255), nil, CB("ShowLegitTargetCrosshairColor", nil))


local legitLockedTarget = nil

local function getLegitAimActive()
    local active = Toggles.LegitAimMainToggle and Toggles.LegitAimMainToggle.Value
    if Options.LegitAimKeybind then
        local kState = Options.LegitAimKeybind:GetState()
        if Options.LegitAimKeybind.Value ~= "None" and Options.LegitAimKeybind.Value ~= "Always" and Options.LegitAimKeybind.Value ~= "Toggle" then
            active = kState
        end
    end
    return active
end

local legitRayParams = RaycastParams.new()
legitRayParams.FilterType = Enum.RaycastFilterType.Exclude
legitRayParams.IgnoreWater = true

local function legitIsVisible(targetPart)
    if not targetPart or not targetPart.Parent then return false end
    local cam = Workspace.CurrentCamera
    legitRayParams.FilterDescendantsInstances = {LP.Character, cam}
    local result = Workspace:Raycast(cam.CFrame.Position, targetPart.Position - cam.CFrame.Position, legitRayParams)
    if result then
        local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
        return hitModel == targetPart.Parent
    end
    return true
end

local function legitHasVest(char)
    local armor = char and char:FindFirstChild("CharacterArmor")
    return armor and armor:FindFirstChild("VestDetails") ~= nil
end

local function legitIsEnemy(char)
    if not char or char == LP.Character then return false end
    local myChar = LP.Character
    if not myChar then return false end
    return legitHasVest(myChar) ~= legitHasVest(char)
end

local function FindLegitTarget()
    if not (Toggles.LegitAimMainToggle and Toggles.LegitAimMainToggle.Value) then
        legitLockedTarget = nil
        return
    end
    if not (Toggles.LegitAimEnabled and Toggles.LegitAimEnabled.Value) then
        legitLockedTarget = nil
        return
    end

    local cam = Workspace.CurrentCamera
    local charsFolder = Workspace:FindFirstChild("Characters")
    if not charsFolder or not cam then return end

    local chosenPartName = Options.LegitAimHitPart and Options.LegitAimHitPart.Value or "Head"

    if legitLockedTarget and legitLockedTarget.Parent then
        local charModel = legitLockedTarget.Parent
        local isDead = charModel:GetAttribute("Dead") or charModel:GetAttribute("Invincible")
        local hp = charModel:GetAttribute("Health")
        if isDead or (hp and hp <= 0) then
            legitLockedTarget = nil
        elseif Toggles.LegitAimVisibleCheck and Toggles.LegitAimVisibleCheck.Value then
            if not legitIsVisible(legitLockedTarget) then
                legitLockedTarget = nil
            end
        end
    else
        legitLockedTarget = nil
    end

    local bestTarget = legitLockedTarget
    local bestDist = math.huge
    if legitLockedTarget then
        local bp = legitLockedTarget.Parent:FindFirstChild(chosenPartName) or legitLockedTarget
        if bp then bestDist = (cam.CFrame.Position - bp.Position).Magnitude end
    end

    for _, char in ipairs(charsFolder:GetDescendants()) do
        if char:IsA("Model") and char ~= LP.Character and legitIsEnemy(char) then
            local isDead = char:GetAttribute("Dead") or char:GetAttribute("Invincible")
            local hp = char:GetAttribute("Health")
            if not isDead and (hp == nil or hp > 0) then
                local targetPart = char:FindFirstChild(chosenPartName)
                    or char:FindFirstChild("Head")
                    or char:FindFirstChild("HumanoidRootPart")
                if targetPart then
                    local passVis = true
                    if Toggles.LegitAimVisibleCheck and Toggles.LegitAimVisibleCheck.Value then
                        if not legitIsVisible(targetPart) then passVis = false end
                    end
                    if passVis then
                        local dist = (cam.CFrame.Position - targetPart.Position).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            bestTarget = targetPart
                        end
                    end
                end
            end
        end
    end
    legitLockedTarget = bestTarget
end

PH.conns[#PH.conns + 1] = RunService.RenderStepped:Connect(function()
    pcall(function()
        if not (Toggles.LegitAimMainToggle and Toggles.LegitAimMainToggle.Value) then return end
        if not (Toggles.LegitAimEnabled and Toggles.LegitAimEnabled.Value) then return end
        if not legitLockedTarget or not legitLockedTarget.Parent then return end

        local cam = Workspace.CurrentCamera
        local targetPos = legitLockedTarget.Position
        local camPos = cam.CFrame.Position
        local dir = (targetPos - camPos).Unit
        local newCF = CFrame.new(camPos, camPos + dir)
        cam.CFrame = newCF
    end)
end)

task.spawn(function()
    while true do
        task.wait(Options.LegitTriggerbotDelay and Options.LegitTriggerbotDelay.Value or 0.01)
        pcall(function()
            if not (Toggles.LegitTriggerbot and Toggles.LegitTriggerbot.Value) then return end
            if not (Toggles.LegitAimMainToggle and Toggles.LegitAimMainToggle.Value) then return end
            if not legitLockedTarget or not legitLockedTarget.Parent then return end
            local cam = Workspace.CurrentCamera
            local result = Workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * 1000, legitRayParams)
            if result then
                local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
                if hitModel and hitModel == legitLockedTarget.Parent then
                    local mouse = LP:GetMouse()
                    mouse1click()
                end
            end
        end)
    end
end)

local lastLegitTargetCheck = 0
PH.conns[#PH.conns + 1] = RunService.Heartbeat:Connect(function()
    if Toggles.LegitAimMainToggle and Toggles.LegitAimMainToggle.Value and os.clock() - lastLegitTargetCheck >= 0.05 then
        lastLegitTargetCheck = os.clock()
        pcall(FindLegitTarget)
    end
end)

task.spawn(function()
    local targetLine = Drawing.new("Line")
    targetLine.Visible = false
    targetLine.Thickness = 1
    targetLine.Color = Color3.fromRGB(0, 255, 255)

    local targetCross1 = Drawing.new("Line")
    local targetCross2 = Drawing.new("Line")
    targetCross1.Visible = false
    targetCross2.Visible = false
    targetCross1.Thickness = 1
    targetCross2.Thickness = 1
    targetCross1.Color = Color3.fromRGB(0, 255, 255)
    targetCross2.Color = Color3.fromRGB(0, 255, 255)

    RunService.RenderStepped:Connect(function()
        pcall(function()
            local show = Toggles.ShowLegitTarget and Toggles.ShowLegitTarget.Value
            local active = Toggles.LegitAimMainToggle and Toggles.LegitAimMainToggle.Value
            local mode = Options.ShowLegitTargetMode and Options.ShowLegitTargetMode.Value or "Crosshair"
            local cam = Workspace.CurrentCamera

            if show and active and cam and legitLockedTarget and legitLockedTarget.Parent then
                local sp, onScreen = cam:WorldToViewportPoint(legitLockedTarget.Position)
                if onScreen then
                    if mode == "Line" then
                        targetLine.Visible = true
                        targetLine.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                        targetLine.To = Vector2.new(sp.X, sp.Y)
                        targetCross1.Visible = false
                        targetCross2.Visible = false
                        pcall(function()
                            if Options.ShowLegitTargetLineColor then
                                targetLine.Color = Options.ShowLegitTargetLineColor.Value
                            end
                        end)
                    else
                        local size = 8
                        targetCross1.Visible = true
                        targetCross2.Visible = true
                        targetCross1.From = Vector2.new(sp.X - size, sp.Y)
                        targetCross1.To   = Vector2.new(sp.X + size, sp.Y)
                        targetCross2.From = Vector2.new(sp.X, sp.Y - size)
                        targetCross2.To   = Vector2.new(sp.X, sp.Y + size)
                        targetLine.Visible = false
                        pcall(function()
                            if Options.ShowLegitTargetCrosshairColor then
                                targetCross1.Color = Options.ShowLegitTargetCrosshairColor.Value
                                targetCross2.Color = Options.ShowLegitTargetCrosshairColor.Value
                            end
                        end)
                    end
                else
                    targetLine.Visible = false
                    targetCross1.Visible = false
                    targetCross2.Visible = false
                end
            else
                targetLine.Visible = false
                targetCross1.Visible = false
                targetCross2.Visible = false
            end
        end)
    end)
end)

do
    local ChamsGroupbox = Tabs.Visuals:Section("Chams", "Left")

    ChamsGroupbox:Toggle("Enabled", "ChamsEnabled", false, nil, CB("ChamsEnabled", nil), true)
    ChamsGroupbox:Toggle("TeamCheck", "ChamsTeamCheck", false, nil, CB("ChamsTeamCheck", nil), true)

    ChamsGroupbox:Divider()

    ChamsGroupbox:Label("Visible")
    Dropdowns["ChamsMaterialVisible"] = ChamsGroupbox:Dropdown("MaterialVisible", "ChamsMaterialVisible", {"Neon", "Metal", "ForceField", "SmoothPlastic"}, Pick({"Neon", "Metal", "ForceField", "SmoothPlastic"}, "Neon"), nil, CB("ChamsMaterialVisible", nil))
    ChamsGroupbox:ColorPicker("ColorVisible", "ChamsColorVisible", Color3.fromRGB(0, 200, 0), nil, CB("ChamsColorVisible", nil))
    ChamsGroupbox:Slider("FillTransparencyVisible", "ChamsAlphaVisible", 0, 1, 0.3, 0.01, nil, CB("ChamsAlphaVisible", nil))
    ChamsGroupbox:Slider("OutlineTransparencyVisible", "ChamsOutlineAlphaVisible", 0, 1, 0, 0.01, nil, CB("ChamsOutlineAlphaVisible", nil))

    ChamsGroupbox:Divider()

    ChamsGroupbox:Label("Unvisible")
    Dropdowns["ChamsMaterialUnvisible"] = ChamsGroupbox:Dropdown("MaterialUnvisible", "ChamsMaterialUnvisible", {"Neon", "Metal", "ForceField", "SmoothPlastic"}, Pick({"Neon", "Metal", "ForceField", "SmoothPlastic"}, "Metal"), nil, CB("ChamsMaterialUnvisible", nil))
    ChamsGroupbox:ColorPicker("ColorUnvisible", "ChamsColorUnvisible", Color3.fromRGB(200, 0, 0), nil, CB("ChamsColorUnvisible", nil))
    ChamsGroupbox:Slider("FillTransparencyUnvisible", "ChamsAlphaUnvisible", 0, 1, 0.3, 0.01, nil, CB("ChamsAlphaUnvisible", nil))
    ChamsGroupbox:Slider("OutlineTransparencyUnvisible", "ChamsOutlineAlphaUnvisible", 0, 1, 0, 0.01, nil, CB("ChamsOutlineAlphaUnvisible", nil))

    local ESPFolder
    pcall(function()
        ESPFolder = Instance.new("Folder", game:GetService("CoreGui"))
        ESPFolder.Name = "Chams_Container"
    end)

    local Highlights = {}

    local function getMaterial(str)
        if str == "Metal"          then return Enum.Material.Metal
        elseif str == "ForceField" then return Enum.Material.ForceField
        elseif str == "SmoothPlastic" then return Enum.Material.SmoothPlastic
        else return Enum.Material.Neon end
    end

    local function removeChams(char)
        if Highlights[char] then
            pcall(function() Highlights[char].visible:Destroy() end)
            pcall(function() Highlights[char].unvisible:Destroy() end)
            Highlights[char] = nil
        end
        if not char then return end
        for _, obj in ipairs(char:GetDescendants()) do
            pcall(function()
                if obj:IsA("BasePart") and obj:GetAttribute("OrigMat") then
                    obj.Material = Enum.Material[obj:GetAttribute("OrigMat")]
                    obj.Color    = obj:GetAttribute("OrigColor") or obj.Color
                    obj:SetAttribute("OrigMat",   nil)
                    obj:SetAttribute("OrigColor", nil)
                end
            end)
        end
    end

    local function isTeammate(char)
        if not char then return false end
        local myChar = LP.Character
        if not myChar then return false end
        local myHasVest  = hasVestDetails(myChar)
        local hisHasVest = hasVestDetails(char)
        return myHasVest == hisHasVest
    end

    local chamsRayParams = RaycastParams.new()
    chamsRayParams.FilterType = Enum.RaycastFilterType.Exclude

    local function isVisible(char)
        local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        if not root then return false end
        local camPos = Camera.CFrame.Position
        local dir    = root.Position - camPos
        chamsRayParams.FilterDescendantsInstances = {LP.Character, char}
        local result = Workspace:Raycast(camPos, dir, chamsRayParams)
        return result == nil
    end

    PH.conns[#PH.conns + 1] = RunService.RenderStepped:Connect(function()
        if not PH.alive then return end
        pcall(function()
            local enabled     = Toggles.ChamsEnabled   and Toggles.ChamsEnabled.Value
            local teamCheckOn = Toggles.ChamsTeamCheck and Toggles.ChamsTeamCheck.Value

            local matVisible   = getMaterial(Options.ChamsMaterialVisible   and Options.ChamsMaterialVisible.Value   or "Neon")
            local matUnvisible = getMaterial(Options.ChamsMaterialUnvisible and Options.ChamsMaterialUnvisible.Value or "Metal")
            local colVisible   = Options.ChamsColorVisible   and Options.ChamsColorVisible.Value   or Color3.fromRGB(0,200,0)
            local colUnvisible = Options.ChamsColorUnvisible and Options.ChamsColorUnvisible.Value or Color3.fromRGB(200,0,0)

            local fillAlphaVis    = Options.ChamsAlphaVisible         and Options.ChamsAlphaVisible.Value         or 0.3
            local fillAlphaUnvis  = Options.ChamsAlphaUnvisible       and Options.ChamsAlphaUnvisible.Value       or 0.3
            local outAlphaVis     = Options.ChamsOutlineAlphaVisible   and Options.ChamsOutlineAlphaVisible.Value   or 0
            local outAlphaUnvis   = Options.ChamsOutlineAlphaUnvisible and Options.ChamsOutlineAlphaUnvisible.Value or 0

            local charsFolder = Workspace:FindFirstChild("Characters")
            if not charsFolder then return end

            local enemyChars = {}
            for _, obj in ipairs(charsFolder:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                    local char = obj
                    if char == LP.Character then continue end
                    if teamCheckOn and isTeammate(char) then
                        removeChams(char)
                        continue
                    end
                    if not enabled then
                        removeChams(char)
                        continue
                    end
                    table.insert(enemyChars, char)
                end
            end

            for _, char in ipairs(enemyChars) do
                if not Highlights[char] then
                    local hlVis = Instance.new("Highlight")
                    hlVis.DepthMode           = Enum.HighlightDepthMode.Occluded
                    hlVis.Parent              = ESPFolder

                    local hlUnvis = Instance.new("Highlight")
                    hlUnvis.DepthMode         = Enum.HighlightDepthMode.AlwaysOnTop
                    hlUnvis.Parent            = ESPFolder

                    Highlights[char] = { visible = hlVis, unvisible = hlUnvis }

                    char.AncestryChanged:Connect(function(_, newParent)
                        if newParent == nil then removeChams(char) end
                    end)
                end

                local hl  = Highlights[char]
                local seen = isVisible(char)

                hl.visible.Adornee            = char
                hl.visible.FillColor          = colVisible
                hl.visible.OutlineColor       = colVisible
                hl.visible.FillTransparency   = fillAlphaVis
                hl.visible.OutlineTransparency= outAlphaVis
                hl.visible.Enabled            = seen

                hl.unvisible.Adornee            = char
                hl.unvisible.FillColor          = colUnvisible
                hl.unvisible.OutlineColor       = colUnvisible
                hl.unvisible.FillTransparency   = fillAlphaUnvis
                hl.unvisible.OutlineTransparency= outAlphaUnvis
                hl.unvisible.Enabled            = not seen

                local targetMat = seen and matVisible or matUnvisible
                local targetCol = seen and colVisible or colUnvisible

                for _, part in ipairs(char:GetDescendants()) do
                    pcall(function()
                        if part:IsA("SurfaceAppearance") or part:IsA("Decal") or part:IsA("Texture") then
                            part:Destroy()
                        elseif part:IsA("MeshPart") and part.TextureID ~= "" then
                            part.TextureID = ""
                        elseif part:IsA("SpecialMesh") and part.TextureId ~= "" then
                            part.TextureId = ""
                        end
                        if part:IsA("BasePart") then
                            if not part:GetAttribute("OrigMat") then
                                part:SetAttribute("OrigMat",   part.Material.Name)
                                part:SetAttribute("OrigColor", part.Color)
                            end
                            part.Material = targetMat
                            part.Color    = targetCol
                        end
                    end)
                end
            end
        end)
    end)

    PH.conns[#PH.conns + 1] = Players.PlayerRemoving:Connect(function(player)
        if player.Character then
            removeChams(player.Character)
        end
    end)
end

local GrenadeVisualBox = Tabs.Visuals:Section("Grenades", "Right")

GrenadeVisualBox:Toggle("Grenade Tracers", "GrenadeTracers", false, nil, CB("GrenadeTracers", nil), true)
GrenadeVisualBox:ColorPicker("Tracer Color", "GrenadeTracerColor", Color3.fromRGB(255, 100, 0), nil, CB("GrenadeTracerColor", nil))

GrenadeVisualBox:Toggle("Molotov Zone ESP", "MolotovZoneESP", false, nil, CB("MolotovZoneESP", nil), true)
GrenadeVisualBox:ColorPicker("Zone Color", "GrenadeZoneColor", Color3.fromRGB(255, 60, 0), nil, CB("GrenadeZoneColor", nil))

GrenadeVisualBox:Toggle("Smoke Zone ESP", "SmokeZoneESP", false, nil, CB("SmokeZoneESP", nil), true)
GrenadeVisualBox:ColorPicker("Smoke Color", "SmokeZoneColor", Color3.fromRGB(180, 180, 180), nil, CB("SmokeZoneColor", nil))

do
    local SETTINGS = {
        Smoke = {
            RadiusTrim   = 0.0,
            HeightOffset = 0.3,
            Segments     = 40,
            Thickness    = 0.28,
        },
        Molotov = {
            RadiusTrim   = 4.5,
            HeightOffset = 0.3,
            Segments     = 40,
            Thickness    = 0.28,
        },
    }

    local FADE_IN_TIME    = 0.4
    local FADE_OUT_TIME   = 0.6
    local RECALC_INTERVAL = 0.05
    local RAYCAST_DOWN    = 14

    local function GetMolotovColor()
        if Options and Options.GrenadeZoneColor then
            return Options.GrenadeZoneColor.Value
        end
        return Color3.fromRGB(255, 60, 0)
    end

    local function GetSmokeColor()
        if Options and Options.SmokeZoneColor then
            return Options.SmokeZoneColor.Value
        end
        return Color3.fromRGB(180, 180, 180)
    end

    local ActiveZones = {}

    local zoneRayParams = RaycastParams.new()
    zoneRayParams.FilterType = Enum.RaycastFilterType.Exclude

    local function ComputeZoneBounds(parent)
        local sumX, sumZ = 0, 0
        local minY = math.huge
        local count = 0
        local parts = {}
        for _, v in ipairs(parent:GetChildren()) do
            if v:IsA("BasePart") then
                count = count + 1
                sumX  = sumX + v.Position.X
                sumZ  = sumZ + v.Position.Z
                local b = v.Position.Y - v.Size.Y * 0.5
                if b < minY then minY = b end
                table.insert(parts, v)
            end
        end
        if count == 0 then return nil, nil, false end
        local cx, cz = sumX/count, sumZ/count
        local maxR = 0
        for _, p in ipairs(parts) do
            local dx  = p.Position.X - cx
            local dz  = p.Position.Z - cz
            local ext = math.max(p.Size.X, p.Size.Z) * 0.5
            local r   = math.sqrt(dx*dx + dz*dz) + ext
            if r > maxR then maxR = r end
        end
        return Vector3.new(cx, minY, cz), math.max(maxR, 1.2), true
    end

    local function GetGroundY(x, baseY, z, excludeList)
        zoneRayParams.FilterDescendantsInstances = excludeList or {}
        local result = Workspace:Raycast(
            Vector3.new(x, baseY + 5, z),
            Vector3.new(0, -RAYCAST_DOWN, 0),
            zoneRayParams
        )
        return result and result.Position.Y or baseY
    end

    local function MakeCylinder(col, thickness)
        local p = Instance.new("Part")
        p.Name         = "BS_RingSeg"
        p.Anchored     = true
        p.CanCollide   = false
        p.CanQuery     = false
        p.CastShadow   = false
        p.Material     = Enum.Material.Neon
        p.Color        = col
        p.Transparency = 1
        p.Shape        = Enum.PartType.Cylinder
        p.Size         = Vector3.new(thickness, thickness, thickness)
        p.Parent       = Workspace
        return p
    end

    local function CreateZoneRing(parent, cfg, isMolotov)
        if ActiveZones[parent] then return end

        local segments  = cfg.Segments  or 40
        local thickness = cfg.Thickness or 0.28
        local initColor = isMolotov and GetMolotovColor() or GetSmokeColor()

        local cylinders = {}
        local allParts  = {}
        for i = 1, segments do
            local cyl = MakeCylinder(initColor, thickness)
            table.insert(cylinders, cyl)
            table.insert(allParts, cyl)
        end

        local record = {
            cylinders  = cylinders,
            allParts   = allParts,
            cfg        = cfg,
            isMolotov  = isMolotov,
            lastRecalc = 0,
            lastRadius = 1,
            alive      = true,
            fadingOut  = false,
            fadeAlpha  = 0,
        }
        ActiveZones[parent] = record

        local fadeInStart = tick()

        local function CurrentAlpha()
            if record.fadingOut then return record.fadeAlpha end
            return math.clamp((tick() - fadeInStart) / FADE_IN_TIME, 0, 1)
        end

        local function FadeOut()
            if record.fadingOut then return end
            record.fadingOut = true
            record.fadeAlpha = CurrentAlpha()
            local startTick  = tick()
            local startAlpha = record.fadeAlpha
            local conn
            conn = RunService.Heartbeat:Connect(function()
                local t = math.clamp((tick() - startTick) / FADE_OUT_TIME, 0, 1)
                record.fadeAlpha = startAlpha * (1 - t)
                local transp = 1 - record.fadeAlpha
                for _, cyl in ipairs(cylinders) do
                    pcall(function() cyl.Transparency = transp end)
                end
                if t >= 1 then
                    conn:Disconnect()
                    record.alive = false
                    for _, cyl in ipairs(cylinders) do
                        pcall(function() cyl:Destroy() end)
                    end
                    ActiveZones[parent] = nil
                end
            end)
        end

        parent.AncestryChanged:Connect(function(_, newParent)
            if newParent == nil then FadeOut() end
        end)

        local updateConn
        updateConn = RunService.Heartbeat:Connect(function()
            if not record.alive then updateConn:Disconnect() return end
            if not parent or not parent.Parent then
                updateConn:Disconnect()
                FadeOut()
                return
            end

            local now = tick()
            if now - record.lastRecalc < RECALC_INTERVAL then return end
            record.lastRecalc = now

            local center, radius, found = ComputeZoneBounds(parent)
            if not found then return end

            local trim     = cfg.RadiusTrim or 0
            local smoothed = record.lastRadius + (radius - record.lastRadius) * 0.25
            record.lastRadius = smoothed
            local finalR   = math.max(smoothed - trim, 0.8)

            local alpha  = CurrentAlpha()
            local transp = 1 - alpha
            local col    = record.isMolotov and GetMolotovColor() or GetSmokeColor()

            for i, cyl in ipairs(cylinders) do
                local angleA   = (2*math.pi) * ((i-1) / segments)
                local angleB   = (2*math.pi) * (i     / segments)
                local angleMid = (angleA + angleB) / 2

                local xA = center.X + math.cos(angleA)   * finalR
                local zA = center.Z + math.sin(angleA)   * finalR
                local xB = center.X + math.cos(angleB)   * finalR
                local zB = center.Z + math.sin(angleB)   * finalR
                local xM = center.X + math.cos(angleMid) * finalR
                local zM = center.Z + math.sin(angleMid) * finalR

                local yA = GetGroundY(xA, center.Y, zA, allParts) + (cfg.HeightOffset or 0.3)
                local yB = GetGroundY(xB, center.Y, zB, allParts) + (cfg.HeightOffset or 0.3)
                local yM = (yA + yB) * 0.5

                local posA = Vector3.new(xA, yA, zA)
                local posB = Vector3.new(xB, yB, zB)
                local mid  = Vector3.new(xM, yM, zM)
                local dir  = posB - posA
                local len  = dir.Magnitude
                if len < 0.001 then continue end

                local cf = CFrame.lookAt(mid, mid + dir) * CFrame.Angles(0, math.rad(90), 0)

                cyl.CFrame       = cf
                cyl.Size         = Vector3.new(len, thickness, thickness)
                cyl.Color        = col
                cyl.Transparency = transp
            end
        end)

        record.updateConn = updateConn
    end

    local function IsToggleOn(name)
        if Toggles and Toggles[name] then return Toggles[name].Value end
        return false
    end

    local ScannedObjects = {}

    local function TryHandleObject(obj)
        if not obj or not obj.Parent then return end
        if ScannedObjects[obj] then return end

        local name = obj.Name:lower()

        local isMolotov = (
            name:find("firezone") or name:find("fire_zone") or
            name:find("molotov")  or name:find("voxelfire") or
            name:find("ignite")   or name:find("flamezone")  or
            name:find("firearea") or name:find("burnzone")
        )

        local isSmoke = (
            name:find("smokezone") or name:find("smoke_zone") or
            name:find("voxelsmoke") or name:find("smokearea") or
            name:find("gaszone")
        )

        if isMolotov and IsToggleOn("MolotovZoneESP") then
            ScannedObjects[obj] = true
            CreateZoneRing(obj, SETTINGS.Molotov, true)
            obj.AncestryChanged:Connect(function(_, p)
                if p == nil then ScannedObjects[obj] = nil end
            end)
        elseif isSmoke and IsToggleOn("SmokeZoneESP") then
            ScannedObjects[obj] = true
            CreateZoneRing(obj, SETTINGS.Smoke, false)
            obj.AncestryChanged:Connect(function(_, p)
                if p == nil then ScannedObjects[obj] = nil end
            end)
        end
    end

    local function ScanFolder(folder)
        if not folder then return end
        for _, child in ipairs(folder:GetChildren()) do
            TryHandleObject(child)
            for _, sub in ipairs(child:GetChildren()) do
                TryHandleObject(sub)
            end
        end
        folder.ChildAdded:Connect(function(child)
            task.wait()
            TryHandleObject(child)
            child.ChildAdded:Connect(function(sub)
                task.wait()
                TryHandleObject(sub)
            end)
        end)
    end

    task.spawn(function()
        while not PH.alive do task.wait(1) end
        task.wait(1)

        ScanFolder(Workspace)

        local debris = Workspace:FindFirstChild("Debris")
        if debris then ScanFolder(debris) end

        local effects = Workspace:FindFirstChild("Effects")
        if effects then ScanFolder(effects) end

        local fx = Workspace:FindFirstChild("FX")
        if fx then ScanFolder(fx) end

        Workspace.ChildAdded:Connect(function(child)
            local n = child.Name:lower()
            if n == "debris" or n == "effects" or n == "fx" then
                ScanFolder(child)
            end
            task.wait()
            TryHandleObject(child)
            child.ChildAdded:Connect(function(sub)
                task.wait()
                TryHandleObject(sub)
            end)
        end)

        while PH.alive and task.wait(3) do
            for _, child in ipairs(Workspace:GetChildren()) do
                TryHandleObject(child)
                for _, sub in ipairs(child:GetChildren()) do
                    TryHandleObject(sub)
                end
            end
        end
    end)
end

local GrenadeFlightTracers = {}

local function StartGrenadeFlightTracer(part)
    if not part or not part:IsA("BasePart") then return end
    if GrenadeFlightTracers[part] then return end

    local MAX_TRAIL = 30
    local history   = {}
    local lines     = {}

    for i = 1, MAX_TRAIL do
        local l = Drawing.new("Line")
        l.Visible      = false
        l.Thickness    = 2
        l.Transparency = 1
        lines[i] = l
    end

    GrenadeFlightTracers[part] = lines

    local conn
    conn = RunService.RenderStepped:Connect(function()
        local enabled = Toggles and Toggles.GrenadeTracers and Toggles.GrenadeTracers.Value
        local col = Options and Options.GrenadeTracerColor and Options.GrenadeTracerColor.Value or Color3.fromRGB(255, 100, 0)

        if not part or not part.Parent then
            conn:Disconnect()
            GrenadeFlightTracers[part] = nil
            for _, l in ipairs(lines) do
                pcall(function() l:Remove() end)
            end
            return
        end

        if not enabled then
            for _, l in ipairs(lines) do l.Visible = false end
            return
        end

        table.insert(history, 1, part.Position)
        if #history > MAX_TRAIL + 1 then table.remove(history) end

        for i = 1, MAX_TRAIL do
            local l  = lines[i]
            local p1 = history[i]
            local p2 = history[i + 1]
            if not p1 or not p2 then
                l.Visible = false
                continue
            end
            local s1, o1 = Camera:WorldToViewportPoint(p1)
            local s2, o2 = Camera:WorldToViewportPoint(p2)
            if (o1 or o2) and s1.Z > 0 and s2.Z > 0 then
                local fade = 1 - (i / MAX_TRAIL)
                l.From      = Vector2.new(s1.X, s1.Y)
                l.To        = Vector2.new(s2.X, s2.Y)
                l.Color     = col
                l.Thickness = math.max(2 * fade, 0.5)
                l.Transparency = 1 - fade
                l.Visible   = true
            else
                l.Visible = false
            end
        end
    end)
end

local TrackedGrenades = {}

local GRENADE_PATTERNS = {
    "grenade","flash","molotov","bang","frag",
    "he_","_he","throwable","projectile","nade",
    "incendiary","decoy","c4"
}

local GRENADE_BLACKLIST = {
    "gun","rifle","pistol","bullet","casing","debris",
    "light","muzzle","launch","effect","arm","leg",
    "torso","head","humanoid","mesh","handle",
    "constraint","weld","motor","zone","voxel"
}

local function isGrenadeObject(obj)
    if not obj:IsA("BasePart") and not obj:IsA("Model") then return false end
    local name = obj.Name:lower()
    for _, p in ipairs(GRENADE_BLACKLIST) do
        if name:find(p) then return false end
    end
    if #name > 20 and name:find("%-") then return true end
    for _, p in ipairs(GRENADE_PATTERNS) do
        if name:find(p) then return true end
    end
    return false
end

local function TryTrackGrenade(obj)
    if TrackedGrenades[obj] then return end

    local part = obj
    if obj:IsA("Model") then
        part = obj:FindFirstChild("Handle")
             or obj:FindFirstChildWhichIsA("BasePart")
    end
    if not part or not part:IsA("BasePart") then return end
    if part.Size.Magnitude > 8 then return end
    if Players:GetPlayerFromCharacter(obj) then return end
    if Players:GetPlayerFromCharacter(obj.Parent) then return end

    TrackedGrenades[obj] = true

    local cc
    cc = obj.AncestryChanged:Connect(function(_, p)
        if p == nil then
            TrackedGrenades[obj] = nil
            cc:Disconnect()
        end
    end)

    StartGrenadeFlightTracer(part)
end

local function ScanForGrenades(folder)
    if not folder then return end
    for _, child in ipairs(folder:GetChildren()) do
        if isGrenadeObject(child) then TryTrackGrenade(child) end
        if child:IsA("Model") then
            for _, sub in ipairs(child:GetChildren()) do
                if isGrenadeObject(sub) then TryTrackGrenade(sub) end
            end
        end
    end
end

task.spawn(function()
    while not PH.alive do task.wait(1) end
    task.wait(0.5)
    ScanForGrenades(Workspace)

    local toWatch = {"Debris","Effects","FX","Projectiles","Grenades"}
    for _, fname in ipairs(toWatch) do
        local f = Workspace:FindFirstChild(fname)
        if f then
            ScanForGrenades(f)
            f.ChildAdded:Connect(function(child)
                task.wait()
                if isGrenadeObject(child) then TryTrackGrenade(child) end
            end)
        end
    end

    Workspace.ChildAdded:Connect(function(child)
        task.wait()
        if isGrenadeObject(child) then TryTrackGrenade(child) end
        local n = child.Name:lower()
        if n=="debris" or n=="effects" or n=="fx" or n=="projectiles" or n=="grenades" then
            ScanForGrenades(child)
            child.ChildAdded:Connect(function(sub)
                task.wait()
                if isGrenadeObject(sub) then TryTrackGrenade(sub) end
            end)
        end
        child.ChildAdded:Connect(function(sub)
            task.wait()
            if isGrenadeObject(sub) then TryTrackGrenade(sub) end
        end)
    end)
end)

local WeaponVisualBox = Tabs.Weapons:Section("Bullet Visuals", "Right")

WeaponVisualBox:Toggle("Bullet Tracers", "BulletTracers", false, nil, CB("BulletTracers", nil), true)
WeaponVisualBox:ColorPicker("Tracer Color", "BulletTracersColor", Color3.fromRGB(0, 170, 255), nil, CB("BulletTracersColor", nil))

Dropdowns["TracerStyle"] = WeaponVisualBox:Dropdown("Tracer Style", "TracerStyle", {"Block", "Cylinder (Obelius)"}, Pick({"Block", "Cylinder (Obelius)"}, "Block"), nil, CB("TracerStyle", nil))

WeaponVisualBox:Toggle("Tracer Rainbow Mode", "TracerRainbow", false, nil, CB("TracerRainbow", nil), true)

WeaponVisualBox:Slider("Tracer Time" .. " (" .. "s" .. ")", "TracerTime", 0.1, 10, 2, 0.1, nil, CB("TracerTime", nil))

WeaponVisualBox:Toggle("Bullet Impacts", "BulletImpacts", false, nil, CB("BulletImpacts", nil), true)
WeaponVisualBox:ColorPicker("Impact Color", "ImpactColor", Color3.fromRGB(255, 255, 0), nil, CB("ImpactColor", nil))

WeaponVisualBox:Slider("Impact Size", "ImpactSize", 0.05, 0.5, 0.15, 0.01, nil, CB("ImpactSize", nil))

local skyboxtable = {
    ["Night"] = {
        SkyboxBk = "rbxassetid://1514717643", SkyboxDn = "rbxassetid://1514716936",
        SkyboxFt = "rbxassetid://1514715910", SkyboxLf = "rbxassetid://1514714945",
        SkyboxRt = "rbxassetid://1514714011", SkyboxUp = "rbxassetid://1514713374"
    },
    ["Ocean Sunset"] = {
        SkyboxBk = "rbxassetid://17525686840", SkyboxDn = "rbxassetid://17525678473",
        SkyboxFt = "rbxassetid://17525684686", SkyboxLf = "rbxassetid://17525680663",
        SkyboxRt = "rbxassetid://17525682665", SkyboxUp = "rbxassetid://17525674545"
    },
    ["My Summer Car"] = {
        SkyboxBk = "rbxassetid://16648590964", SkyboxDn = "rbxassetid://16648617436",
        SkyboxFt = "rbxassetid://16648595424", SkyboxLf = "rbxassetid://16648566370",
        SkyboxRt = "rbxassetid://16648577071", SkyboxUp = "rbxassetid://16648598180"
    },
    ["Standard"] = {
        SkyboxBk = "rbxassetid://91458024", SkyboxDn = "rbxassetid://91457980",
        SkyboxFt = "rbxassetid://91458002", SkyboxLf = "rbxassetid://91457986",
        SkyboxRt = "rbxassetid://91458014", SkyboxUp = "rbxassetid://91458036"
    },
    ["Minecraft"] = {
        SkyboxBk = "rbxassetid://8735166756", SkyboxDn = "rbxassetid://8735166707",
        SkyboxFt = "rbxassetid://8735231668", SkyboxLf = "rbxassetid://8735166738",
        SkyboxRt = "rbxassetid://8735166755", SkyboxUp = "rbxassetid://8735166732"
    },
    ["Spongebob"] = {
        SkyboxBk = "rbxassetid://277099484", SkyboxDn = "rbxassetid://277099500",
        SkyboxFt = "rbxassetid://277099554", SkyboxLf = "rbxassetid://277099518",
        SkyboxRt = "rbxassetid://277099466", SkyboxUp = "rbxassetid://277099532"
    },
    ["Deep Space"] = {
        SkyboxBk = "rbxassetid://159248188", SkyboxDn = "rbxassetid://159248183",
        SkyboxFt = "rbxassetid://159248187", SkyboxLf = "rbxassetid://159248185",
        SkyboxRt = "rbxassetid://159248186", SkyboxUp = "rbxassetid://159248189"
    },
    ["Clouded Sky"] = {
        SkyboxBk = "rbxassetid://252760981", SkyboxDn = "rbxassetid://252763035",
        SkyboxFt = "rbxassetid://252761439", SkyboxLf = "rbxassetid://252762367",
        SkyboxRt = "rbxassetid://252761004", SkyboxUp = "rbxassetid://252761478"
    },
    ["Retro"] = {
        SkyboxBk = "rbxasset://sky/null_plainsky512_bk.jpg", SkyboxDn = "rbxasset://sky/null_plainsky512_dn.jpg",
        SkyboxFt = "rbxasset://sky/null_plainsky512_ft.jpg", SkyboxLf = "rbxasset://sky/null_plainsky512_lf.jpg",
        SkyboxRt = "rbxasset://sky/null_plainsky512_rt.jpg", SkyboxUp = "rbxasset://sky/null_plainsky512_up.jpg"
    },
    ["City"] = {
        SkyboxBk = "rbxassetid://9134792889", SkyboxDn = "rbxassetid://9134791975",
        SkyboxFt = "rbxassetid://9134793457", SkyboxLf = "rbxassetid://9134792341",
        SkyboxRt = "rbxassetid://9134792629", SkyboxUp = "rbxassetid://9134793152"
    },
    ["Purple Nebula"] = {
        SkyboxBk = "rbxassetid://15983968922", SkyboxDn = "rbxassetid://15983966825",
        SkyboxFt = "rbxassetid://15983965025", SkyboxLf = "rbxassetid://15983967338",
        SkyboxRt = "rbxassetid://15983968117", SkyboxUp = "rbxassetid://15983969471"
    },
    ["Pink Sky"] = {
        SkyboxBk = "http://www.roblox.com/asset/?id=7890140060",
        SkyboxDn = "http://www.roblox.com/asset/?id=7890140060",
        SkyboxFt = "http://www.roblox.com/asset/?id=7890140060",
        SkyboxLf = "http://www.roblox.com/asset/?id=7890140060",
        SkyboxRt = "http://www.roblox.com/asset/?id=7890140060",
        SkyboxUp = "http://www.roblox.com/asset/?id=7890140060"
    }
}

local skyNames = {}
for k in pairs(skyboxtable) do table.insert(skyNames, k) end
table.sort(skyNames)

local Lighting = game:GetService("Lighting")

local function UpdateSkybox(name)
    local data = skyboxtable[name]
    if not data then return end
    pcall(function()
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("Clouds") then v:Destroy() end
        end
        local sky = Lighting:FindFirstChild("Memesense_Sky")
        if not sky then
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("Sky") then v:Destroy() end
            end
            sky = Instance.new("Sky")
            sky.Name = "Memesense_Sky"
            sky.Parent = Lighting
        end
        sky.SkyboxBk = data.SkyboxBk
        sky.SkyboxDn = data.SkyboxDn
        sky.SkyboxFt = data.SkyboxFt
        sky.SkyboxLf = data.SkyboxLf
        sky.SkyboxRt = data.SkyboxRt
        sky.SkyboxUp = data.SkyboxUp
        sky.SunTextureId = ""
        sky.MoonTextureId = ""
        sky.StarCount = 0
    end)
end

local WeatherPart = nil

local function UpdateWeather(wType)
    pcall(function()
        if WeatherPart then WeatherPart:Destroy() WeatherPart = nil end
        for _, v in pairs(Workspace:GetChildren()) do
            if v.Name == "Memesense_RainDrop" then v:Destroy() end
        end
        if wType == "None" then return end

        WeatherPart = Instance.new("Part")
        WeatherPart.Name = "Memesense_Weather_Sky"
        WeatherPart.Size = Vector3.new(100, 1, 100)
        WeatherPart.Transparency = 1
        WeatherPart.Anchored = true
        WeatherPart.CanCollide = false
        WeatherPart.Parent = Workspace.CurrentCamera
        local SkyEmitter = Instance.new("ParticleEmitter")
        SkyEmitter.Parent = WeatherPart
        SkyEmitter.EmissionDirection = Enum.NormalId.Bottom
        SkyEmitter.Enabled = true

        if wType == "Rain" then
            SkyEmitter.Texture = "rbxassetid://241868005"
            SkyEmitter.Rate = 10000
            SkyEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
            SkyEmitter.LightEmission = 0.2
            SkyEmitter.Transparency = NumberSequence.new(0)
            SkyEmitter.Size = NumberSequence.new(3, 6)
            SkyEmitter.Lifetime = NumberRange.new(2, 2.5)
            SkyEmitter.Speed = NumberRange.new(80, 100)
            SkyEmitter.SpreadAngle = Vector2.new(0, 0)
            SkyEmitter.Acceleration = Vector3.new(0, -50, 0)
            SkyEmitter.Orientation = Enum.ParticleOrientation.FacingCamera
        elseif wType == "Snow" then
            SkyEmitter.Texture = "rbxassetid://99851851"
            SkyEmitter.Rate = 200
            SkyEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
            SkyEmitter.Size = NumberSequence.new(0.25, 0.35)
            SkyEmitter.Speed = NumberRange.new(30, 30)
            SkyEmitter.Lifetime = NumberRange.new(5, 10)
            SkyEmitter.Acceleration = Vector3.new(0, 0, 0)
            SkyEmitter.SpreadAngle = Vector2.new(50, 50)
            SkyEmitter.LightEmission = 0.5
            SkyEmitter.Rotation = NumberRange.new(0, 0)
            SkyEmitter.RotSpeed = NumberRange.new(0, 0)
        elseif wType == "Hell Fire" then
            SkyEmitter.Texture = "rbxassetid://242205518"
            SkyEmitter.Rate = 400
            SkyEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 100, 0), Color3.fromRGB(150, 0, 0))
            SkyEmitter.Size = NumberSequence.new(2, 4)
            SkyEmitter.Speed = NumberRange.new(40, 60)
            SkyEmitter.Lifetime = NumberRange.new(2, 3)
            SkyEmitter.Acceleration = Vector3.new(0, -10, 0)
            SkyEmitter.RotSpeed = NumberRange.new(50, 100)
        end
    end)
end

local DefaultLighting = {}
pcall(function()
    DefaultLighting = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        GlobalShadows = Lighting.GlobalShadows
    }
end)

local function UpdateLighting()
    pcall(function()
        if Toggles.EnableTime and Toggles.EnableTime.Value then
            Lighting.ClockTime = Options.WorldClockTime.Value
        else
            Lighting.ClockTime = DefaultLighting.ClockTime
        end
        if Toggles.EnableBrightness and Toggles.EnableBrightness.Value then
            Lighting.Brightness = Options.WorldBrightness.Value
        else
            Lighting.Brightness = DefaultLighting.Brightness
        end
        if Toggles.EnableColors and Toggles.EnableColors.Value then
            Lighting.Ambient = Options.WorldAmbient.Value
            Lighting.OutdoorAmbient = Options.WorldOutdoorAmbient.Value
        else
            Lighting.Ambient = DefaultLighting.Ambient
            Lighting.OutdoorAmbient = DefaultLighting.OutdoorAmbient
        end
    end)
end

local WorldSettings = {
    WorldColorEnabled = false,
    WorldColor = Color3.fromRGB(255, 255, 255),
    SkyColorEnabled = false,
    SkyColor = Color3.fromRGB(255, 255, 255)
}

local function isLocalPlayerObject(obj)
    local char = LP.Character
    if char and (obj == char or obj:IsDescendantOf(char)) then return true end
    if Workspace.CurrentCamera and obj:IsDescendantOf(Workspace.CurrentCamera) then return true end
    if obj.Name == "CubeChecker_Physical" or obj.Name:find("Memesense_") then return true end
    return false
end

local function colorObject(obj)
    if isLocalPlayerObject(obj) then return end
    if obj:IsA("BasePart") then
        if not obj:GetAttribute("OriginalColor") then obj:SetAttribute("OriginalColor", obj.Color) end
        obj.Color = WorldSettings.WorldColor
    elseif obj:IsA("Texture") or obj:IsA("Decal") then
        if not obj:GetAttribute("OriginalColor3") then obj:SetAttribute("OriginalColor3", obj.Color3) end
        obj.Color3 = WorldSettings.WorldColor
    end
end

local function restoreObject(obj)
    if obj:IsA("BasePart") then
        if obj:GetAttribute("OriginalColor") then obj.Color = obj:GetAttribute("OriginalColor") end
    elseif obj:IsA("Texture") or obj:IsA("Decal") then
        if obj:GetAttribute("OriginalColor3") then obj.Color3 = obj:GetAttribute("OriginalColor3") end
    end
end

local function RefreshWorldColor()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if WorldSettings.WorldColorEnabled then colorObject(obj) else restoreObject(obj) end
    end
end

Workspace.DescendantAdded:Connect(function(obj)
    if WorldSettings.WorldColorEnabled then
        task.defer(function()
            if obj and obj.Parent then colorObject(obj) end
        end)
    end
end)

local WorldBox = Tabs.World:Section("Lighting", "Left")

WorldBox:Toggle("Enable Skybox", "EnableSkybox", false, nil, CB("EnableSkybox", function(v)
        if v then
            if Toggles.Atmosphere and Toggles.Atmosphere.Value then Toggles.Atmosphere:SetValue(false) end
            UpdateSkybox(Options.SkyboxPreset.Value)
        end
    end), true)

Dropdowns["SkyboxPreset"] = WorldBox:Dropdown("Skybox Preset", "SkyboxPreset", skyNames, Pick(skyNames, "Night"), nil, CB("SkyboxPreset", function(v) if Toggles.EnableSkybox and Toggles.EnableSkybox.Value then UpdateSkybox(v) end end))

Dropdowns["WeatherType"] = WorldBox:Dropdown("Weather", "WeatherType", {"None", "Rain", "Snow", "Hell Fire"}, Pick({"None", "Rain", "Snow", "Hell Fire"}, "None"), nil, CB("WeatherType", function(v) UpdateWeather(v) end))

WorldBox:Toggle("Enable Time", "EnableTime", false, nil, CB("EnableTime", function(_) UpdateLighting() end), true)
WorldBox:Slider("Clock Time" .. " (" .. "h" .. ")", "WorldClockTime", 0, 24, 12, 0.1, nil, CB("WorldClockTime", function(_) UpdateLighting() end))
WorldBox:Toggle("Enable Brightness", "EnableBrightness", false, nil, CB("EnableBrightness", function(_) UpdateLighting() end), true)
WorldBox:Slider("Brightness" .. " (" .. "x" .. ")", "WorldBrightness", 0, 10, 2, 0.1, nil, CB("WorldBrightness", function(_) UpdateLighting() end))
WorldBox:Toggle("Enable Colors", "EnableColors", false, nil, CB("EnableColors", function(_) UpdateLighting() end), true)

WorldBox:ColorPicker("Ambient Color", "WorldAmbient", Color3.fromRGB(127, 127, 127), nil, CB("WorldAmbient", function(_) UpdateLighting() end))

WorldBox:ColorPicker("Outdoor Color", "WorldOutdoorAmbient", Color3.fromRGB(127, 127, 127), nil, CB("WorldOutdoorAmbient", function(_) UpdateLighting() end))

local NightModeBox = Tabs.World:Section("Night", "Right")

NightModeBox:Toggle("World Color", "WorldColorToggle", false, nil, CB("WorldColorToggle", function(state)
        WorldSettings.WorldColorEnabled = state
        RefreshWorldColor()
    end), true)
NightModeBox:ColorPicker("World Color", "WorldColorPicker", Color3.fromRGB(255, 255, 255), nil, CB("WorldColorPicker", function(c)
        WorldSettings.WorldColor = c
        if WorldSettings.WorldColorEnabled then RefreshWorldColor() end
    end))

NightModeBox:Toggle("Second Color", "SkyColorToggle", false, nil, CB("SkyColorToggle", function(state) WorldSettings.SkyColorEnabled = state end), true)
NightModeBox:ColorPicker("Second Color", "SkyColorPicker", Color3.fromRGB(255, 255, 255), nil, CB("SkyColorPicker", function(c) WorldSettings.SkyColor = c end))

PH.conns[#PH.conns + 1] = RunService.RenderStepped:Connect(function()
    pcall(function()
        if WorldSettings.SkyColorEnabled then
            local skyColor = WorldSettings.SkyColor
            Lighting.Ambient = skyColor
            Lighting.OutdoorAmbient = skyColor
            Lighting.ColorShift_Bottom = skyColor
            Lighting.ColorShift_Top = skyColor
            Lighting.FogColor = skyColor
            local atmosphere = Lighting:FindFirstChild("KamibloxSky")
            if not atmosphere then
                atmosphere = Instance.new("Atmosphere")
                atmosphere.Name = "KamibloxSky"
                atmosphere.Parent = Lighting
            end
            atmosphere.Color = skyColor
            atmosphere.Decay = skyColor
        else
            local atmosphere = Lighting:FindFirstChild("KamibloxSky")
            if atmosphere then atmosphere:Destroy() end
        end
    end)
end)

local AtmosphereBox = Tabs.World:Section("Sky & Weather", "Right")

AtmosphereBox:Toggle("Enable", "Atmosphere", false, nil, CB("Atmosphere", function(v)
        if v then
            if Toggles.EnableSkybox and Toggles.EnableSkybox.Value then Toggles.EnableSkybox:SetValue(false) end
        end
    end), true)

AtmosphereBox:Slider("Atmosphere Density", "AtmosphereDensity", 0, 1, 0.3, 0.01, nil, CB("AtmosphereDensity", nil))
AtmosphereBox:Slider("Atmosphere Haze", "SubAtmosphereHaze", 0, 10, 0, 0.1, nil, CB("SubAtmosphereHaze", nil))
AtmosphereBox:Slider("Atmosphere Glare", "AtmosphereGlare", 0, 10, 0, 0.1, nil, CB("AtmosphereGlare", nil))
AtmosphereBox:Toggle("Enabled Color Correction", "EnableColorCorrection", false, nil, CB("EnableColorCorrection", nil), true)
AtmosphereBox:Slider("Saturation", "SaturationSlider", -1, 1, 0, 0.01, nil, CB("SaturationSlider", nil))
AtmosphereBox:Slider("Contrast", "ContrastSlider", -1, 1, 0, 0.1, nil, CB("ContrastSlider", nil))

task.spawn(function()
    while PH.alive do
        task.wait(0.1)
        pcall(function()
            if Toggles.Atmosphere and Toggles.Atmosphere.Value then
                if Toggles.EnableSkybox and Toggles.EnableSkybox.Value then Toggles.EnableSkybox:SetValue(false) end
                local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
                if not atmosphere then atmosphere = Instance.new("Atmosphere") atmosphere.Parent = Lighting end
                atmosphere.Density = Options.AtmosphereDensity and Options.AtmosphereDensity.Value or 0.3
                atmosphere.Haze = Options.SubAtmosphereHaze and Options.SubAtmosphereHaze.Value or 0
                atmosphere.Glare = Options.AtmosphereGlare and Options.AtmosphereGlare.Value or 0
            else
                local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
                if atmosphere then atmosphere:Destroy() end
            end

            if Toggles.EnableColorCorrection and Toggles.EnableColorCorrection.Value then
                local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
                if not cc then cc = Instance.new("ColorCorrectionEffect") cc.Parent = Lighting end
                cc.Enabled = true
                cc.Saturation = Options.SaturationSlider and Options.SaturationSlider.Value or 0
                cc.Contrast = Options.ContrastSlider and Options.ContrastSlider.Value or 0
            else
                local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
                if cc then cc.Enabled = false end
            end

            if Toggles.EnableSkybox and Toggles.EnableSkybox.Value then
                UpdateSkybox(Options.SkyboxPreset.Value)
            end
            UpdateLighting()
        end)
    end
end)

PH.conns[#PH.conns + 1] = RunService.RenderStepped:Connect(function()
    if not Workspace.CurrentCamera then return end
    if WeatherPart then WeatherPart.CFrame = Workspace.CurrentCamera.CFrame * CFrame.new(0, 30, 0) end
end)

local CustomHandsBox = Tabs.Weapons:Section("Viewmodel", "Left")

CustomHandsBox:Toggle("Enable", "CustomHandsEnabled", false, nil, CB("CustomHandsEnabled", nil), true)
CustomHandsBox:Slider("X" .. " (" .. "studs" .. ")", "HandsX", -2, 2, 0.2, 0.001, nil, CB("HandsX", nil))
CustomHandsBox:Slider("Y" .. " (" .. "studs" .. ")", "HandsY", -2, 2, -0.155, 0.001, nil, CB("HandsY", nil))
CustomHandsBox:Slider("Z" .. " (" .. "studs" .. ")", "HandsZ", -2, 2, 0.075, 0.001, nil, CB("HandsZ", nil))

PH.conns[#PH.conns + 1] = RunService.RenderStepped:Connect(function()
    pcall(function()
        if not Toggles.CustomHandsEnabled or not Toggles.CustomHandsEnabled.Value then return end
        local xOffset = Options.HandsX and Options.HandsX.Value or 0.2
        local yOffset = Options.HandsY and Options.HandsY.Value or -0.155
        local zOffset = Options.HandsZ and Options.HandsZ.Value or 0.075
        for _, child in ipairs(Workspace.CurrentCamera:GetChildren()) do
            if child:IsA("Model") then
                local statsFolder = child:FindFirstChild("Stats")
                if statsFolder then
                    local defaultVal = statsFolder:FindFirstChild("Default")
                    if defaultVal and defaultVal:IsA("Vector3Value") then
                        defaultVal.Value = Vector3.new(xOffset, yOffset, zOffset)
                    end
                end
            end
        end
    end)
end)

local WeaponChamsBox = Tabs.Weapons:Section("Weapon Chams", "Right")

WeaponChamsBox:Toggle("Enable Weapon Chams", "WeaponChamsEnabled", false, nil, CB("WeaponChamsEnabled", nil), true)
WeaponChamsBox:ColorPicker("Chams Color", "WeaponChamsColor", Color3.fromRGB(0, 150, 255), nil, CB("WeaponChamsColor", nil))

Dropdowns["WeaponChamsMode"] = WeaponChamsBox:Dropdown("Chams Material/Type", "WeaponChamsMode", {"Glass", "ForceField", "Metal", "Highlight", "Neon"}, Pick({"Glass", "ForceField", "Metal", "Highlight", "Neon"}, "Glass"), nil, CB("WeaponChamsMode", nil))

WeaponChamsBox:Slider("Glass Transparency", "GlassTransparency", 0, 1, 0.4, 0.01, nil, CB("GlassTransparency", nil))
WeaponChamsBox:Slider("Metal Reflectance", "MetalReflectance", 0, 1, 1.0, 0.1, nil, CB("MetalReflectance", nil))

local activeNeonHighlights = {}

PH.conns[#PH.conns + 1] = RunService.RenderStepped:Connect(function()
    if not PH.alive then return end
    pcall(function()
        local chamsEnabled = Toggles.WeaponChamsEnabled and Toggles.WeaponChamsEnabled.Value
        local chamsMode = Options.WeaponChamsMode and Options.WeaponChamsMode.Value or "Glass"
        local chamsColor = Options.WeaponChamsColor and Options.WeaponChamsColor.Value or Color3.fromRGB(0, 150, 255)

        local weaponModel = nil
        for _, child in ipairs(Camera:GetChildren()) do
            if child:IsA("Model") and child.Name ~= "Viewmodel" and not child.Name:lower():find("light") then
                local w = child:FindFirstChild("Weapon") or child
                if w:IsA("Model") and w.Name ~= "Viewmodel" and not w.Name:lower():find("light") then
                    weaponModel = w
                    break
                end
            end
        end

        if not chamsEnabled or not weaponModel then
            for _, h in pairs(activeNeonHighlights) do
                if h and h.Parent then h:Destroy() end
            end
            activeNeonHighlights = {}
            if not chamsEnabled or not weaponModel then return end
        end

        local currentNeonParts = {}

        for _, part in ipairs(weaponModel:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "Hitbox" and part.Name ~= "HumanoidRootPart" then
                if part.Name == "ViewmodelLight" or part:FindFirstAncestor("ViewmodelLight") or part:FindFirstAncestor("Viewmodel") then
                    continue
                end
                pcall(function()
                    if chamsMode == "Highlight" then
                        currentNeonParts[part] = true
                        local h = part:FindFirstChild("WeaponChamsHighlight")
                        if not h then
                            h = Instance.new("Highlight")
                            h.Name = "WeaponChamsHighlight"
                            h.Adornee = part
                            h.Parent = part
                            h.FillTransparency = 0
                            h.OutlineTransparency = 1
                            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            table.insert(activeNeonHighlights, h)
                        end
                        h.FillColor = chamsColor
                    else
                        local h = part:FindFirstChild("WeaponChamsHighlight")
                        if h then h:Destroy() end
                        if chamsMode ~= "Neon" then
                            for _, v in ipairs(part:GetChildren()) do
                                if v:IsA("SurfaceAppearance") or v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end
                            end
                        end
                        if chamsMode == "Glass" then
                            part.Material = Enum.Material.Glass
                            part.Color = chamsColor
                            part.Transparency = Options.GlassTransparency and Options.GlassTransparency.Value or 0.4
                        elseif chamsMode == "ForceField" then
                            part.Material = Enum.Material.ForceField
                            part.Color = chamsColor
                            part.Transparency = 0
                        elseif chamsMode == "Metal" then
                            part.Material = Enum.Material.Metal
                            part.Color = chamsColor
                            part.Reflectance = Options.MetalReflectance and Options.MetalReflectance.Value or 1.0
                            part.Transparency = 0
                        elseif chamsMode == "Neon" then
                            part.Material = Enum.Material.Neon
                            part.Color = chamsColor
                            part.Transparency = 0
                            for _, v in ipairs(part:GetChildren()) do
                                if v:IsA("SurfaceAppearance") or v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end
                            end
                        end
                    end
                end)
            end
        end

        if chamsMode == "Highlight" then
            for i = #activeNeonHighlights, 1, -1 do
                local h = activeNeonHighlights[i]
                if not h or not h.Parent or not currentNeonParts[h.Adornee] then
                    if h then h:Destroy() end
                    table.remove(activeNeonHighlights, i)
                end
            end
        end
    end)
end)

local HitSoundBox = Tabs.Weapons:Section("Hit Sounds", "Left")

HitSoundBox:Toggle("Enable Hit Sound", "HitSoundEnabled", false, nil, CB("HitSoundEnabled", nil), true)
HitSoundBox:Toggle("Enable Custom Hit Sound", "CustomHitSoundToggle", false, nil, CB("CustomHitSoundToggle", nil), true)
HitSoundBox:Slider("Hit Sound Volume" .. " (" .. "x" .. ")", "HitSoundVolume", 0.1, 5, 1, 0.1, nil, CB("HitSoundVolume", nil))

local HitSoundPresets = {
    ["Neverlose"] = "rbxassetid://139452805868562",
    ["Skeet"] = "rbxassetid://83717596220569",
    ["Bell"] = "rbxassetid://96481309571950",
    ["Bell2"] = "rbxassetid://124010691633262",
    ["Bubble"] = "rbxassetid://104824514322839",
    ["Rust"] = "rbxassetid://1255040462",
    ["Agro1"] = "rbxassetid://132463144859699",
    ["Agro2"] = "rbxassetid://102651850556408",
    ["Coins"] = "rbxassetid://5613553529",
    ["Schaater"] = "rbxassetid://17405655409",
    ["Pick"] = "rbxassetid://8616930816"
}

Dropdowns["HitSoundPreset"] = HitSoundBox:Dropdown("Hit Sound Preset", "HitSoundPreset", {"Neverlose", "Skeet", "Bell", "Bell2", "Bubble", "Rust", "Agro1", "Agro2", "Coins", "Schaater", "Pick"}, Pick({"Neverlose", "Skeet", "Bell", "Bell2", "Bubble", "Rust", "Agro1", "Agro2", "Coins", "Schaater", "Pick"}, "Neverlose"), nil, CB("HitSoundPreset", nil))

if Library.Flags["CustomHitSoundID"] == nil then Library.Flags["CustomHitSoundID"] = "" end
HitSoundBox:TextBox("Custom Sound ID", "CustomHitSoundID", "Clean ID or rbxassetid://...", nil, CB("CustomHitSoundID", nil))

local function PlayHitSound()
    pcall(function()
        if not Toggles.HitSoundEnabled.Value then return end
        local soundId = ""
        if Toggles.CustomHitSoundToggle and Toggles.CustomHitSoundToggle.Value then
            local customInput = Options.CustomHitSoundID and Options.CustomHitSoundID.Value
            if customInput and customInput ~= "" then
                if not customInput:find("rbxassetid://") then
                    local cleanId = customInput:gsub("%D", "")
                    if cleanId ~= "" then soundId = "rbxassetid://" .. cleanId end
                else
                    soundId = customInput
                end
            end
        end
        if soundId == "" then
            soundId = HitSoundPresets[Options.HitSoundPreset.Value] or "rbxassetid://139452805868562"
        end
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Volume = Options.HitSoundVolume and Options.HitSoundVolume.Value or 1
        sound.Parent = SoundService
        sound:Play()
        task.spawn(function()
            sound.Ended:Wait()
            sound:Destroy()
        end)
    end)
end

local HitMarkerBox = Tabs.Weapons:Section("Hit Marker", "Right")

HitMarkerBox:Toggle("Enable HitMarker", "HitMarkerEnabled", false, nil, CB("HitMarkerEnabled", nil), true)
HitMarkerBox:ColorPicker("HitMarker Color", "HitMarkerColor", Color3.fromRGB(255, 255, 255), nil, CB("HitMarkerColor", nil))

HitMarkerBox:Toggle("Rainbow Mode", "HitMarkerRainbow", false, nil, CB("HitMarkerRainbow", nil), true)
HitMarkerBox:Slider("Display Duration" .. " (" .. "s" .. ")", "HitMarkerDuration", 0.5, 5, 2, 0.1, nil, CB("HitMarkerDuration", nil))
HitMarkerBox:Slider("Spin Speed" .. " (" .. "deg/s" .. ")", "HitMarkerSpinSpeed", 0, 1440, 720, 1, nil, CB("HitMarkerSpinSpeed", nil))
HitMarkerBox:Slider("Size" .. " (" .. "px" .. ")", "HitMarkerSize", 5, 50, 25, 1, nil, CB("HitMarkerSize", nil))
HitMarkerBox:Slider("Thickness" .. " (" .. "px" .. ")", "HitMarkerThickness", 1, 6, 2, 0.1, nil, CB("HitMarkerThickness", nil))

local TriggerHitMarkerEvent = nil

task.spawn(function()
    local activeHitMarkers = {}

    TriggerHitMarkerEvent = function(hitPos)
        if not Toggles.HitMarkerEnabled or not Toggles.HitMarkerEnabled.Value then return end
        local dur = Options.HitMarkerDuration and Options.HitMarkerDuration.Value or 2
        local thick = Options.HitMarkerThickness and Options.HitMarkerThickness.Value or 2
        local lines = {}
        for i = 1, 4 do
            local line = Drawing.new("Line")
            line.Thickness = thick
            line.Transparency = 1
            line.Visible = false
            lines[i] = line
        end
        table.insert(activeHitMarkers, {
            lines = lines,
            worldPos = hitPos,
            spawnTick = tick(),
            expireTick = tick() + dur
        })
    end

    onBulletHit = function(h)
        local isEnemyHit = false
        if h.Instance then
            local ancestorModel = h.Instance:FindFirstAncestorOfClass("Model")
            if ancestorModel and ancestorModel ~= LP.Character then
                if not isCharacterAlly(ancestorModel) then
                    isEnemyHit = true
                end
            end
        end
        if isEnemyHit then
            PlayHitSound()
            if TriggerHitMarkerEvent then
                TriggerHitMarkerEvent(h.Position)
            end
        end
    end

    PH.conns[#PH.conns + 1] = RunService.RenderStepped:Connect(function()
        if not PH.alive then return end
        pcall(function()
            local currentTick = tick()
            local enabled = Toggles.HitMarkerEnabled and Toggles.HitMarkerEnabled.Value
            local col = Options.HitMarkerColor and Options.HitMarkerColor.Value or Color3.fromRGB(255, 255, 255)
            if Toggles.HitMarkerRainbow and Toggles.HitMarkerRainbow.Value then
                col = Color3.fromHSV((currentTick % 5) / 5, 1, 1)
            end
            local baseSize = Options.HitMarkerSize and Options.HitMarkerSize.Value or 25
            local spinSpeed = Options.HitMarkerSpinSpeed and Options.HitMarkerSpinSpeed.Value or 720
            local pulseFactor = 1 + 0.35 * math.sin(currentTick * math.pi)
            local currentSize = baseSize * pulseFactor
            local gap = 6 * pulseFactor

            for i = #activeHitMarkers, 1, -1 do
                local data = activeHitMarkers[i]
                if not enabled or currentTick > data.expireTick then
                    for _, line in ipairs(data.lines) do pcall(function() line:Remove() end) end
                    table.remove(activeHitMarkers, i)
                else
                    local screenPos, onScreen = Camera:WorldToViewportPoint(data.worldPos)
                    if onScreen then
                        local center = Vector2.new(screenPos.X, screenPos.Y)
                        local lifetime = currentTick - data.spawnTick
                        local currentAngle = math.rad((lifetime * spinSpeed) % 360)
                        local baseAngles = {0, 90, 180, 270}
                        for j = 1, 4 do
                            local line = data.lines[j]
                            line.Color = col
                            line.Thickness = Options.HitMarkerThickness and Options.HitMarkerThickness.Value or 2
                            local totalAngle = currentAngle + math.rad(baseAngles[j])
                            local cosA = math.cos(totalAngle)
                            local sinA = math.sin(totalAngle)
                            line.From = center + Vector2.new(cosA * gap, sinA * gap)
                            line.To = center + Vector2.new(cosA * (gap + currentSize), sinA * (gap + currentSize))
                            line.Visible = true
                        end
                    else
                        for _, line in ipairs(data.lines) do line.Visible = false end
                    end
                end
            end
        end)
    end)
end)

local CustomScopeBox = Tabs.Weapons:Section("Scope", "Left")

CustomScopeBox:Toggle("Custom Scope FOV", "CustomScopeFov", false, nil, CB("CustomScopeFov", nil), true)
CustomScopeBox:Slider("Scope FOV" .. " (" .. "deg" .. ")", "ScopeFovValue", 10, 100, 70, 0.1, nil, CB("ScopeFovValue", nil))
CustomScopeBox:Toggle("Remove Scope", "RemoveScope", false, nil, CB("RemoveScope", nil), true)
CustomScopeBox:Divider()

CustomScopeBox:Toggle("Scope Crosshair", "CustomScopeCrosshair", false, nil, CB("CustomScopeCrosshair", nil), true)
CustomScopeBox:ColorPicker("Crosshair Color", "ScopeCrosshairColor", Color3.fromRGB(255, 255, 255), nil, CB("ScopeCrosshairColor", nil))

CustomScopeBox:Slider("Crosshair Thickness" .. " (" .. "px" .. ")", "ScopeCrosshairThickness", 1, 10, 2, 0.1, nil, CB("ScopeCrosshairThickness", nil))
CustomScopeBox:Slider("Left & Right Length" .. " (" .. "px" .. ")", "ScopeCrosshairLengthLR", 0, 1000, 150, 1, nil, CB("ScopeCrosshairLengthLR", nil))
CustomScopeBox:Slider("Top & Bottom Length" .. " (" .. "px" .. ")", "ScopeCrosshairLengthTB", 0, 1000, 100, 1, nil, CB("ScopeCrosshairLengthTB", nil))

task.spawn(function()
    local CoreGui = game:GetService("CoreGui")
    local crosshairGui = Instance.new("ScreenGui")
    crosshairGui.Name = "BloxStrike_GdcScopeCrosshair"
    crosshairGui.ResetOnSpawn = false
    pcall(function() crosshairGui.Parent = CoreGui end)

    local container = Instance.new("Frame", crosshairGui)
    container.BackgroundTransparency = 1
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.Position = UDim2.new(0.5, 0, 0.5, 0)
    container.Size = UDim2.new(0, 0, 0, 0)

    local leftLine = Instance.new("Frame", container)
    leftLine.AnchorPoint = Vector2.new(1, 0.5)
    leftLine.BorderSizePixel = 0

    local rightLine = Instance.new("Frame", container)
    rightLine.AnchorPoint = Vector2.new(0, 0.5)
    rightLine.BorderSizePixel = 0

    local topLine = Instance.new("Frame", container)
    topLine.AnchorPoint = Vector2.new(0.5, 1)
    topLine.BorderSizePixel = 0

    local bottomLine = Instance.new("Frame", container)
    bottomLine.AnchorPoint = Vector2.new(0.5, 0)
    bottomLine.BorderSizePixel = 0

    PH.conns[#PH.conns + 1] = RunService.RenderStepped:Connect(function()
        if not PH.alive then return end
        pcall(function()
            local isScoped = false
            local playerGui = LP:FindFirstChild("PlayerGui")
            if playerGui then
                local s, scope = pcall(function() return playerGui.MainGui.Gameplay.Middle.SniperScope end)
                if s and scope and scope.Visible then isScoped = true end
            end
            local enabled = Toggles.CustomScopeCrosshair and Toggles.CustomScopeCrosshair.Value and isScoped
            container.Visible = enabled
            if enabled then
                local col = Options.ScopeCrosshairColor and Options.ScopeCrosshairColor.Value or Color3.fromRGB(255, 255, 255)
                leftLine.BackgroundColor3 = col
                rightLine.BackgroundColor3 = col
                topLine.BackgroundColor3 = col
                bottomLine.BackgroundColor3 = col
                local t = Options.ScopeCrosshairThickness and Options.ScopeCrosshairThickness.Value or 2
                local lenLR = Options.ScopeCrosshairLengthLR and Options.ScopeCrosshairLengthLR.Value or 150
                local lenTB = Options.ScopeCrosshairLengthTB and Options.ScopeCrosshairLengthTB.Value or 100
                leftLine.Size = UDim2.new(0, lenLR, 0, t)
                leftLine.Position = UDim2.new(0, 0, 0, 0)
                rightLine.Size = UDim2.new(0, lenLR, 0, t)
                rightLine.Position = UDim2.new(0, 0, 0, 0)
                topLine.Size = UDim2.new(0, t, 0, lenTB)
                topLine.Position = UDim2.new(0, 0, 0, 0)
                bottomLine.Size = UDim2.new(0, t, 0, lenTB)
                bottomLine.Position = UDim2.new(0, 0, 0, 0)
            end
        end)
    end)
end)

task.spawn(function()
    local CachedSniperScope = nil
    PH.conns[#PH.conns + 1] = RunService.RenderStepped:Connect(function()
        if not PH.alive then return end
        if CachedSniperScope and not CachedSniperScope.Parent then CachedSniperScope = nil end
        if not CachedSniperScope then
            local playerGui = LP:FindFirstChild("PlayerGui")
            if playerGui then
                local s, scope = pcall(function() return playerGui.MainGui.Gameplay.Middle.SniperScope end)
                if s and scope then CachedSniperScope = scope end
            end
        end
        local scopeFrame = CachedSniperScope
        if not Toggles.RemoveScope or not Toggles.RemoveScope.Value then
            if scopeFrame then
                if scopeFrame.Size ~= UDim2.new(1, 0, 1, 0) then scopeFrame.Size = UDim2.new(1, 0, 1, 0) end
            end
            return
        end
        if scopeFrame then
            if scopeFrame.Visible == true then
                scopeFrame.Size = UDim2.new(0, 0, 0, 0)
            else
                if scopeFrame.Size ~= UDim2.new(1, 0, 1, 0) then scopeFrame.Size = UDim2.new(1, 0, 1, 0) end
            end
        end
    end)
end)

task.spawn(function()
    PH.conns[#PH.conns + 1] = RunService.RenderStepped:Connect(function()
        if not PH.alive then return end
        pcall(function()
            if Toggles.CustomScopeFov and Toggles.CustomScopeFov.Value then
                local playerGui = LP:FindFirstChild("PlayerGui")
                if playerGui then
                    local scope = playerGui:FindFirstChild("MainGui") and
                        playerGui.MainGui:FindFirstChild("Gameplay") and
                        playerGui.MainGui.Gameplay:FindFirstChild("Middle") and
                        playerGui.MainGui.Gameplay.Middle:FindFirstChild("SniperScope")
                    if scope and scope.Visible and Options.ScopeFovValue then
                        Camera.FieldOfView = Options.ScopeFovValue.Value
                    end
                end
            end
        end)
    end)
end)

task.spawn(function()
    local MiscWeaponBox = Tabs.Weapons:Section("Gun Mods", "Left")

    MiscWeaponBox:Toggle("Instant Reload", "InstantReload", false, nil, CB("InstantReload", nil), true)

    MiscWeaponBox:Toggle("Auto Reload", "AutoReload", false, nil, CB("AutoReload", nil), true)

    MiscWeaponBox:Toggle("Rapid Fire", "RapidFire", false, nil, CB("RapidFire", nil), true)

    MiscWeaponBox:Slider("Fire Rate", "RapidFireRate", 0.01, 1, 0.01, 0.001, nil, CB("RapidFireRate", nil))

    MiscWeaponBox:Toggle("No Recoil", "NoRecoil", false, nil, CB("NoRecoil", nil), true)

    MiscWeaponBox:Toggle("No Spread", "NoSpread", false, nil, CB("NoSpread", nil), true)

    pcall(function()
        for _, obj in next, getgc(true) do
            if type(obj) == "table" and rawget(obj, "setWeaponRecoil") then
                pcall(function()
                    local oldSetWeaponRecoil
                    oldSetWeaponRecoil = hookfunction(obj.setWeaponRecoil, function(...)
                        if Toggles.NoRecoil and Toggles.NoRecoil.Value then return end
                        return oldSetWeaponRecoil(...)
                    end)
                end)
            end
            if type(obj) == "function" and debug.getinfo(obj).name == "calculateRecoilOffset" then
                pcall(function()
                    local calculateRecoilOffset
                    calculateRecoilOffset = hookfunction(obj, function(...)
                        if Toggles.NoRecoil and Toggles.NoRecoil.Value then return UDim2.new() end
                        return calculateRecoilOffset(...)
                    end)
                end)
            end
            if type(obj) == "table" and rawget(obj, "weaponKick") then
                pcall(function()
                    local oldweaponkick
                    oldweaponkick = hookfunction(obj.weaponKick, function(p1, p2)
                        if Toggles.NoRecoil and Toggles.NoRecoil.Value then return end
                        return oldweaponkick(p1, p2)
                    end)
                end)
            end
            if type(obj) == "table" and rawget(obj, "getTrueSpread") then
                pcall(function()
                    local oldgettruespread
                    oldgettruespread = hookfunction(obj.getTrueSpread, function(p1)
                        if Toggles.NoSpread and Toggles.NoSpread.Value then return 0 end
                        return oldgettruespread(p1)
                    end)
                end)
            end
        end
    end)

    local rapidOriginal = {}
    local rapidFireObjs = {}

    pcall(function()
        for _, obj in next, getgc(true) do
            if type(obj) == "table" and rawget(obj, "FireRate") then
                pcall(function()
                    table.insert(rapidOriginal, table.clone(obj))
                    table.insert(rapidFireObjs, obj)
                end)
            end
        end
    end)

    task.spawn(function()
        while task.wait(0.05) do
            pcall(function()
                if Toggles.RapidFire and Toggles.RapidFire.Value then
                    local rate = math.max(Options.RapidFireRate.Value, 0.01)
                    for _, obj in next, rapidFireObjs do
                        pcall(function()
                            setreadonly(obj, false)
                            rawset(obj, "FireRate", rate)
                            setreadonly(obj, true)
                        end)
                    end
                else
                    for i, obj in next, rapidFireObjs do
                        pcall(function()
                            setreadonly(obj, false)
                            rawset(obj, "FireRate", rapidOriginal[i].FireRate)
                            setreadonly(obj, true)
                        end)
                    end
                end
            end)
        end
    end)

    local RELOAD_ANIMS = {
        ["Reload"]       = true,
        ["ReloadStart"]  = true,
        ["ReloadAction"] = true,
        ["ReloadEnd"]    = true,
    }

    local RELOAD_SPEED = 199
    local reloadHooked = {}

    local function getWeaponObjectSafe()
        local ok, IC = pcall(function()
            return require(game:GetService("ReplicatedStorage").Controllers.InventoryController)
        end)
        if not ok or not IC then return nil end
        return IC.peekCurrentEquippedForMovement and IC.peekCurrentEquippedForMovement() or nil
    end

    local function hookAnimationReload(animModule)
        if not animModule or reloadHooked[animModule] then return end
        reloadHooked[animModule] = true

        pcall(function()
            local origPlay = animModule.play
            animModule.play = function(self_anim, animName, ...)
                local track = origPlay(self_anim, animName, ...)
                if track and RELOAD_ANIMS[animName] then
                    task.defer(function()
                        pcall(function()
                            if Toggles.InstantReload and Toggles.InstantReload.Value then
                                if track.IsPlaying then
                                    track:AdjustSpeed(RELOAD_SPEED)
                                end
                            end
                        end)
                    end)
                end
                return track
            end
        end)
    end

    local lastReloadWeapon = nil

    task.spawn(function()
        while task.wait(0.1) do
            pcall(function()
                local weapon = getWeaponObjectSafe()
                if not weapon then return end

                if weapon ~= lastReloadWeapon then
                    lastReloadWeapon = weapon
                    if weapon.Viewmodel and weapon.Viewmodel.Animation then
                        hookAnimationReload(weapon.Viewmodel.Animation)
                    end
                    if weapon.CharacterAnimator then
                        hookAnimationReload(weapon.CharacterAnimator)
                    end
                end

                if not (Toggles.InstantReload and Toggles.InstantReload.Value) then return end

                if weapon.IsReloading then
                    pcall(function()
                        if weapon.Viewmodel and weapon.Viewmodel.Animation and weapon.Viewmodel.Animation.Animations then
                            for name, track in pairs(weapon.Viewmodel.Animation.Animations) do
                                if RELOAD_ANIMS[name] and track.IsPlaying then
                                    track:AdjustSpeed(RELOAD_SPEED)
                                end
                            end
                        end
                        if weapon.CharacterAnimator and weapon.CharacterAnimator.Animations then
                            for name, track in pairs(weapon.CharacterAnimator.Animations) do
                                if RELOAD_ANIMS[name] and track.IsPlaying then
                                    track:AdjustSpeed(RELOAD_SPEED)
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end)

    task.spawn(function()
        while task.wait(0.3) do
            pcall(function()
                if not (Toggles.AutoReload and Toggles.AutoReload.Value) then return end
                local weapon = getWeaponObjectSafe()
                if not weapon then return end
                if weapon.IsReloading then return end
                local mag = weapon.AmmoInMag or weapon.MagAmmo or weapon.CurrentAmmo
                local maxMag = weapon.MaxMagSize or weapon.MagSize or weapon.MaxAmmo
                if mag and maxMag and mag <= math.floor(maxMag * 0.25) and maxMag > 0 then
                    if type(weapon.reload) == "function" then
                        weapon:reload()
                    elseif type(weapon.Reload) == "function" then
                        weapon:Reload()
                    end
                end
            end)
        end
    end)

    pcall(function()
        local IC = require(game:GetService("ReplicatedStorage").Controllers.InventoryController)
        if IC.OnInventoryItemEquipped then
            IC.OnInventoryItemEquipped:Connect(function(_, weapon)
                if not weapon then return end
                task.defer(function()
                    if weapon.Viewmodel and weapon.Viewmodel.Animation then
                        hookAnimationReload(weapon.Viewmodel.Animation)
                    end
                    if weapon.CharacterAnimator then
                        hookAnimationReload(weapon.CharacterAnimator)
                    end
                end)
            end)
        end
    end)
end)

FinishMenu()
