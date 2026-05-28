local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local C = {
	bg      = Color3.fromRGB(20, 20, 20),
	panel   = Color3.fromRGB(30, 30, 30),
	topbar  = Color3.fromRGB(24, 24, 24),
	item    = Color3.fromRGB(38, 38, 38),
	border  = Color3.fromRGB(60, 60, 60),
	accent  = Color3.fromRGB(130, 80, 200),
	text    = Color3.fromRGB(255, 255, 255),
	muted   = Color3.fromRGB(200, 200, 200),
	dim     = Color3.fromRGB(130, 130, 130),
}

local espEnabled  = false
local nameEnabled = false
local fillEnabled = false
local espObjects  = {}
local boxColor    = Color3.fromRGB(130, 80, 200)
local nameColor   = Color3.fromRGB(130, 80, 200)

local function addOutlines(parent, borderClr)
	local o1 = Instance.new("ImageLabel")
	o1.BackgroundTransparency = 1
	o1.Size = UDim2.new(1, 0, 1, 0)
	o1.Image = "rbxassetid://2592362371"
	o1.ImageColor3 = borderClr or C.border
	o1.ScaleType = Enum.ScaleType.Slice
	o1.SliceCenter = Rect.new(2, 2, 62, 62)
	o1.ZIndex = parent.ZIndex + 1
	o1.Parent = parent
	local o2 = Instance.new("ImageLabel")
	o2.BackgroundTransparency = 1
	o2.Position = UDim2.new(0, 1, 0, 1)
	o2.Size = UDim2.new(1, -2, 1, -2)
	o2.Image = "rbxassetid://2592362371"
	o2.ImageColor3 = Color3.fromRGB(0, 0, 0)
	o2.ScaleType = Enum.ScaleType.Slice
	o2.SliceCenter = Rect.new(2, 2, 62, 62)
	o2.ZIndex = parent.ZIndex + 1
	o2.Parent = parent
end

local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "ESPGui"
ESPGui.ResetOnSpawn = false
ESPGui.DisplayOrder = 999998
ESPGui.IgnoreGuiInset = true
ESPGui.Parent = playerGui

local function createESPForPlayer(target)
	if target == player then return end
	if espObjects[target] then return end

	local outerBlack = Instance.new("Frame")
	outerBlack.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	outerBlack.BackgroundTransparency = 0.7
	outerBlack.BorderSizePixel = 0
	outerBlack.ZIndex = 8
	outerBlack.Parent = ESPGui

	local box = Instance.new("Frame")
	box.BackgroundTransparency = 1
	box.BorderSizePixel = 0
	box.ZIndex = 9
	box.Parent = ESPGui

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(0, 0, 0)
	uiStroke.Thickness = 1
	uiStroke.Transparency = 0.7
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = box

	local accentBorder = Instance.new("Frame")
	accentBorder.BackgroundTransparency = 1
	accentBorder.BorderSizePixel = 0
	accentBorder.ZIndex = 10
	accentBorder.Parent = ESPGui
	addOutlines(accentBorder, boxColor)
	local ch = accentBorder:GetChildren()
	if ch[2] then ch[2].ImageTransparency = 1 end

	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = boxColor
	fill.BackgroundTransparency = 0.75
	fill.BorderSizePixel = 0
	fill.ZIndex = 7
	fill.Parent = ESPGui

	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = nameColor
	nameLabel.TextStrokeTransparency = 0.3
	nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	nameLabel.TextSize = 13
	nameLabel.Font = Enum.Font.Code
	nameLabel.TextYAlignment = Enum.TextYAlignment.Bottom
	nameLabel.ZIndex = 11
	nameLabel.Parent = ESPGui

	espObjects[target] = {
		outerBlack   = outerBlack,
		box          = box,
		accentBorder = accentBorder,
		fill         = fill,
		nameLabel    = nameLabel,
	}
end

local function removeESPForPlayer(target)
	if espObjects[target] then
		for _, v in pairs(espObjects[target]) do v:Destroy() end
		espObjects[target] = nil
	end
end

local function clearAllESP()
	for target in pairs(espObjects) do removeESPForPlayer(target) end
end

local function initESP()
	for _, p in ipairs(Players:GetPlayers()) do createESPForPlayer(p) end
end

local function updateESPColors()
	for _, objs in pairs(espObjects) do
		local borderImgs = objs.accentBorder:GetChildren()
		for _, img in ipairs(borderImgs) do
			if img:IsA("ImageLabel") and img.Position == UDim2.new(0, 0, 0, 0) then
				img.ImageColor3 = boxColor
			end
		end
		objs.fill.BackgroundColor3 = boxColor
		objs.nameLabel.TextColor3  = nameColor
	end
end

Players.PlayerAdded:Connect(function(p)
	if espEnabled then createESPForPlayer(p) end
end)
Players.PlayerRemoving:Connect(removeESPForPlayer)

local function getCharacterScreenBox(character)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not rootPart or not humanoid then return nil end
	local rootCF = rootPart.CFrame
	local size = Vector3.new(4, humanoid.HipHeight * 2 + 2, 4)
	local corners = {
		rootCF * CFrame.new( size.X/2,  size.Y/2,  size.Z/2),
		rootCF * CFrame.new(-size.X/2,  size.Y/2,  size.Z/2),
		rootCF * CFrame.new( size.X/2, -size.Y/2,  size.Z/2),
		rootCF * CFrame.new(-size.X/2, -size.Y/2,  size.Z/2),
		rootCF * CFrame.new( size.X/2,  size.Y/2, -size.Z/2),
		rootCF * CFrame.new(-size.X/2,  size.Y/2, -size.Z/2),
		rootCF * CFrame.new( size.X/2, -size.Y/2, -size.Z/2),
		rootCF * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2),
	}
	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	for _, cf in ipairs(corners) do
		local screenPos, onScreen = Camera:WorldToViewportPoint(cf.Position)
		if not onScreen then return nil end
		if screenPos.X < minX then minX = screenPos.X end
		if screenPos.X > maxX then maxX = screenPos.X end
		if screenPos.Y < minY then minY = screenPos.Y end
		if screenPos.Y > maxY then maxY = screenPos.Y end
	end
	return minX, minY, maxX, maxY
end

RunService.RenderStepped:Connect(function()
	for target, objs in pairs(espObjects) do
		local character = target.Character
		local visible = false
		if character and espEnabled then
			local minX, minY, maxX, maxY = getCharacterScreenBox(character)
			if minX then
				visible = true
				local w = maxX - minX
				local h = maxY - minY
				objs.outerBlack.Visible  = true
				objs.outerBlack.Position = UDim2.new(0, minX - 1, 0, minY - 1)
				objs.outerBlack.Size     = UDim2.new(0, w + 2, 0, h + 2)
				objs.box.Visible         = true
				objs.box.Position        = UDim2.new(0, minX, 0, minY)
				objs.box.Size            = UDim2.new(0, w, 0, h)
				objs.accentBorder.Visible  = true
				objs.accentBorder.Position = UDim2.new(0, minX, 0, minY)
				objs.accentBorder.Size     = UDim2.new(0, w, 0, h)
				objs.fill.Visible    = fillEnabled
				objs.fill.Position   = UDim2.new(0, minX + 1, 0, minY + 1)
				objs.fill.Size       = UDim2.new(0, w - 2, 0, h - 2)
				objs.nameLabel.Visible   = nameEnabled
				objs.nameLabel.Text      = target.DisplayName ~= "" and target.DisplayName or target.Name
				objs.nameLabel.Position  = UDim2.new(0, minX, 0, minY - 16)
				objs.nameLabel.Size      = UDim2.new(0, w, 0, 16)
			end
		end
		if not visible then
			objs.outerBlack.Visible   = false
			objs.box.Visible          = false
			objs.accentBorder.Visible = false
			objs.fill.Visible         = false
			objs.nameLabel.Visible    = false
		end
	end
end)

-- ScreenGui & MainFrame
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Brandon.wtf"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = playerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 34)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -90)
MainFrame.BackgroundColor3 = C.bg
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
addOutlines(MainFrame)

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, -4, 0, 28)
TopBar.Position = UDim2.new(0, 2, 0, 2)
TopBar.BackgroundColor3 = C.topbar
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 7, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "brandon.wtf"
TitleLabel.TextColor3 = C.text
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.Code
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
TitleLabel.Parent = TopBar

local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1, 0, 0, 1)
AccentLine.Position = UDim2.new(0, 0, 1, -1)
AccentLine.BackgroundColor3 = C.accent
AccentLine.BorderSizePixel = 0
AccentLine.Parent = TopBar

local HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.new(0, 26, 0, 18)
HideBtn.Position = UDim2.new(1, -30, 0.5, -9)
HideBtn.BackgroundColor3 = C.item
HideBtn.BorderSizePixel = 0
HideBtn.Text = "+"
HideBtn.TextColor3 = C.muted
HideBtn.TextSize = 13
HideBtn.Font = Enum.Font.Code
HideBtn.AutoButtonColor = false
HideBtn.ZIndex = 2
HideBtn.Parent = TopBar
addOutlines(HideBtn)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, -4, 0, 0)
ScrollFrame.Position = UDim2.new(0, 2, 0, 32)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.ScrollBarImageColor3 = C.accent
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
ScrollFrame.ClipsDescendants = true
ScrollFrame.Visible = false
ScrollFrame.Parent = MainFrame

local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -12, 0, 0)
Container.Position = UDim2.new(0, 6, 0, 6)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.AutomaticSize = Enum.AutomaticSize.Y
Container.Parent = ScrollFrame

local ContainerLayout = Instance.new("UIListLayout")
ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContainerLayout.Padding = UDim.new(0, 8)
ContainerLayout.Parent = Container

local function makeSection(name, labelWidth)
	local sec = Instance.new("Frame")
	sec.BackgroundColor3 = C.panel
	sec.BorderSizePixel = 0
	sec.ClipsDescendants = false
	sec.AutomaticSize = Enum.AutomaticSize.Y
	sec.Size = UDim2.new(1, 0, 0, 0)
	sec.Parent = Container
	addOutlines(sec)

	local stf = Instance.new("Frame")
	stf.Size = UDim2.new(0, labelWidth or 50, 0, 8)
	stf.Position = UDim2.new(0, 10, 0, 0)
	stf.BackgroundColor3 = C.panel
	stf.BorderSizePixel = 0
	stf.ZIndex = 3
	stf.Parent = sec

	local st = Instance.new("TextLabel")
	st.Size = UDim2.new(1, 0, 0, 14)
	st.Position = UDim2.new(0, 0, 0, -3)
	st.BackgroundTransparency = 1
	st.Text = name
	st.TextColor3 = C.text
	st.TextSize = 14
	st.Font = Enum.Font.Code
	st.ZIndex = 4
	st.Parent = stf

	local ih = Instance.new("Frame")
	ih.Name = "ItemHolder"
	ih.Size = UDim2.new(1, -16, 0, 0)
	ih.Position = UDim2.new(0, 8, 0, 14)
	ih.BackgroundTransparency = 1
	ih.BorderSizePixel = 0
	ih.AutomaticSize = Enum.AutomaticSize.Y
	ih.ZIndex = 2
	ih.Parent = sec

	local il = Instance.new("UIListLayout")
	il.SortOrder = Enum.SortOrder.LayoutOrder
	il.Padding = UDim.new(0, 5)
	il.Parent = ih

	local pad = Instance.new("UIPadding")
	pad.PaddingBottom = UDim.new(0, 10)
	pad.Parent = ih

	return sec, ih, il
end

local function makeCheckbox(parent, labelText)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 20)
	row.BackgroundTransparency = 1
	row.BorderSizePixel = 0
	row.ZIndex = 2
	row.Parent = parent

	local box = Instance.new("TextButton")
	box.Size = UDim2.new(0, 14, 0, 14)
	box.Position = UDim2.new(0, 0, 0.5, -7)
	box.BackgroundColor3 = C.item
	box.BorderSizePixel = 0
	box.AutoButtonColor = false
	box.Text = ""
	box.ZIndex = 3
	box.Parent = row
	addOutlines(box)

	local boxFill = Instance.new("Frame")
	boxFill.Size = UDim2.new(1, -4, 1, -4)
	boxFill.Position = UDim2.new(0, 2, 0, 2)
	boxFill.BackgroundColor3 = C.accent
	boxFill.BorderSizePixel = 0
	boxFill.Visible = false
	boxFill.ZIndex = 4
	boxFill.Parent = box

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -22, 1, 0)
	lbl.Position = UDim2.new(0, 22, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText
	lbl.TextColor3 = C.muted
	lbl.TextSize = 14
	lbl.Font = Enum.Font.Code
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextYAlignment = Enum.TextYAlignment.Center
	lbl.ZIndex = 3
	lbl.Parent = row

	local state = false
	local function setState(val)
		state = val
		boxFill.Visible = state
		lbl.TextColor3 = state and C.text or C.muted
	end

	box.MouseButton1Click:Connect(function() setState(not state) end)
	box.MouseEnter:Connect(function() box.BorderSizePixel = 1 end)
	box.MouseLeave:Connect(function() box.BorderSizePixel = 0 end)

	return row, function() return state end, setState
end

-- Color picker popup (HV square + Hue bar)
local ColorPickerPopup = Instance.new("Frame")
ColorPickerPopup.Name = "ColorPickerPopup"
ColorPickerPopup.Size = UDim2.new(0, 200, 0, 170)
ColorPickerPopup.BackgroundColor3 = C.bg
ColorPickerPopup.BorderSizePixel = 0
ColorPickerPopup.ZIndex = 100
ColorPickerPopup.Visible = false
ColorPickerPopup.Active = true
ColorPickerPopup.Draggable = false
ColorPickerPopup.Parent = ScreenGui
addOutlines(ColorPickerPopup)

local CPTitle = Instance.new("TextLabel")
CPTitle.Size = UDim2.new(1, -8, 0, 18)
CPTitle.Position = UDim2.new(0, 6, 0, 4)
CPTitle.BackgroundTransparency = 1
CPTitle.Text = "Color"
CPTitle.TextColor3 = C.muted
CPTitle.TextSize = 12
CPTitle.Font = Enum.Font.Code
CPTitle.TextXAlignment = Enum.TextXAlignment.Left
CPTitle.ZIndex = 101
CPTitle.Parent = ColorPickerPopup

local CPClose = Instance.new("TextButton")
CPClose.Size = UDim2.new(0, 18, 0, 14)
CPClose.Position = UDim2.new(1, -22, 0, 4)
CPClose.BackgroundColor3 = C.item
CPClose.BorderSizePixel = 0
CPClose.AutoButtonColor = false
CPClose.Text = "×"
CPClose.TextColor3 = C.muted
CPClose.TextSize = 14
CPClose.Font = Enum.Font.Code
CPClose.ZIndex = 102
CPClose.Parent = ColorPickerPopup
addOutlines(CPClose)

-- SV square (saturation + value)
local SVSquare = Instance.new("ImageLabel")
SVSquare.Size = UDim2.new(0, 152, 0, 120)
SVSquare.Position = UDim2.new(0, 8, 0, 26)
SVSquare.BorderSizePixel = 0
SVSquare.Image = "rbxassetid://698052001"
SVSquare.BackgroundColor3 = Color3.fromHSV(0.77, 1, 1)
SVSquare.ZIndex = 101
SVSquare.Parent = ColorPickerPopup
addOutlines(SVSquare)

-- white->transparent left-to-right gradient
local SVWhite = Instance.new("ImageLabel")
SVWhite.Size = UDim2.new(1, 0, 1, 0)
SVWhite.BackgroundTransparency = 1
SVWhite.Image = "rbxassetid://698053051"
SVWhite.ZIndex = 102
SVWhite.Parent = SVSquare

-- black->transparent bottom gradient
local SVBlack = Instance.new("ImageLabel")
SVBlack.Size = UDim2.new(1, 0, 1, 0)
SVBlack.BackgroundTransparency = 1
SVBlack.Image = "rbxassetid://698051519"
SVBlack.ZIndex = 103
SVBlack.Parent = SVSquare

-- SV cursor
local SVCursor = Instance.new("Frame")
SVCursor.Size = UDim2.new(0, 8, 0, 8)
SVCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SVCursor.BorderSizePixel = 0
SVCursor.ZIndex = 104
SVCursor.Parent = SVSquare
addOutlines(SVCursor)

-- Hue bar (vertical, right side)
local HueBar = Instance.new("ImageLabel")
HueBar.Size = UDim2.new(0, 16, 0, 120)
HueBar.Position = UDim2.new(0, 168, 0, 26)
HueBar.BorderSizePixel = 0
HueBar.Image = "rbxassetid://698054456"
HueBar.ZIndex = 101
HueBar.Parent = ColorPickerPopup
addOutlines(HueBar)

-- Hue cursor
local HueCursor = Instance.new("Frame")
HueCursor.Size = UDim2.new(1, 2, 0, 3)
HueCursor.Position = UDim2.new(0, -1, 0, 0)
HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HueCursor.BorderSizePixel = 0
HueCursor.ZIndex = 102
HueCursor.Parent = HueBar
addOutlines(HueCursor)

-- Preview swatch bottom
local CPPreview = Instance.new("Frame")
CPPreview.Size = UDim2.new(0, 152, 0, 12)
CPPreview.Position = UDim2.new(0, 8, 0, 152)
CPPreview.BorderSizePixel = 0
CPPreview.ZIndex = 101
CPPreview.Parent = ColorPickerPopup
addOutlines(CPPreview)

local currentOnChange = nil
local cpH, cpS, cpV = 0.77, 1, 1

local function cpUpdateVisuals()
	SVSquare.BackgroundColor3 = Color3.fromHSV(cpH, 1, 1)
	SVCursor.Position = UDim2.new(cpS, -4, 1 - cpV, -4)
	HueCursor.Position = UDim2.new(0, -1, 1 - cpH, -1)
	local col = Color3.fromHSV(cpH, cpS, cpV)
	CPPreview.BackgroundColor3 = col
	if currentOnChange then currentOnChange(col) end
end

local svDragging = false
local hueDragging = false

SVSquare.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1
		or inp.UserInputType == Enum.UserInputType.Touch then
		svDragging = true
		local rel = inp.Position
		local ax, ay = SVSquare.AbsolutePosition.X, SVSquare.AbsolutePosition.Y
		local aw, ah = SVSquare.AbsoluteSize.X, SVSquare.AbsoluteSize.Y
		cpS = math.clamp((rel.X - ax) / aw, 0, 1)
		cpV = 1 - math.clamp((rel.Y - ay) / ah, 0, 1)
		cpUpdateVisuals()
	end
end)

SVSquare.InputEnded:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1
		or inp.UserInputType == Enum.UserInputType.Touch then
		svDragging = false
	end
end)

HueBar.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1
		or inp.UserInputType == Enum.UserInputType.Touch then
		hueDragging = true
		local ay = HueBar.AbsolutePosition.Y
		local ah = HueBar.AbsoluteSize.Y
		cpH = 1 - math.clamp((inp.Position.Y - ay) / ah, 0, 1)
		cpUpdateVisuals()
	end
end)

HueBar.InputEnded:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1
		or inp.UserInputType == Enum.UserInputType.Touch then
		hueDragging = false
	end
end)

UserInputService.InputChanged:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseMovement
		or inp.UserInputType == Enum.UserInputType.Touch then
		if svDragging then
			local ax, ay = SVSquare.AbsolutePosition.X, SVSquare.AbsolutePosition.Y
			local aw, ah = SVSquare.AbsoluteSize.X, SVSquare.AbsoluteSize.Y
			cpS = math.clamp((inp.Position.X - ax) / aw, 0, 1)
			cpV = 1 - math.clamp((inp.Position.Y - ay) / ah, 0, 1)
			cpUpdateVisuals()
		elseif hueDragging then
			local ay = HueBar.AbsolutePosition.Y
			local ah = HueBar.AbsoluteSize.Y
			cpH = 1 - math.clamp((inp.Position.Y - ay) / ah, 0, 1)
			cpUpdateVisuals()
		end
	end
end)

CPClose.MouseButton1Click:Connect(function()
	ColorPickerPopup.Visible = false
end)

local function openColorPicker(label, currentColor, onChange)
	currentOnChange = onChange
	CPTitle.Text = label
	cpH, cpS, cpV = Color3.toHSV(currentColor)
	cpUpdateVisuals()
	local mp = MainFrame.AbsolutePosition
	local ms = MainFrame.AbsoluteSize
	ColorPickerPopup.Position = UDim2.new(0, mp.X + ms.X + 6, 0, mp.Y)
	ColorPickerPopup.Visible = true
end

local function makeColorRow(parent, labelText, getColor, onPick)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 20)
	row.BackgroundTransparency = 1
	row.BorderSizePixel = 0
	row.ZIndex = 2
	row.Parent = parent

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -50, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText
	lbl.TextColor3 = C.muted
	lbl.TextSize = 14
	lbl.Font = Enum.Font.Code
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 3
	lbl.Parent = row

	local swatch = Instance.new("TextButton")
	swatch.Size = UDim2.new(0, 40, 0, 14)
	swatch.Position = UDim2.new(1, -40, 0.5, -7)
	swatch.BackgroundColor3 = getColor()
	swatch.BorderSizePixel = 0
	swatch.AutoButtonColor = false
	swatch.Text = ""
	swatch.ZIndex = 3
	swatch.Parent = row
	addOutlines(swatch)

	swatch.MouseButton1Click:Connect(function()
		openColorPicker(labelText, getColor(), function(col)
			swatch.BackgroundColor3 = col
			onPick(col)
		end)
	end)

	swatch.MouseEnter:Connect(function() swatch.BorderSizePixel = 1 end)
	swatch.MouseLeave:Connect(function() swatch.BorderSizePixel = 0 end)

	return row
end

local CosmeticSection, CosmeticHolder = makeSection("Cosmetics", 70)

local SkinBtn = Instance.new("TextButton")
SkinBtn.Size = UDim2.new(1, 0, 0, 20)
SkinBtn.BackgroundColor3 = C.item
SkinBtn.BorderSizePixel = 0
SkinBtn.AutoButtonColor = false
SkinBtn.Text = "Unlock All Skins"
SkinBtn.TextColor3 = C.text
SkinBtn.TextSize = 14
SkinBtn.Font = Enum.Font.Code
SkinBtn.ZIndex = 2
SkinBtn.Parent = CosmeticHolder
addOutlines(SkinBtn)

local ESPSection, ESPHolder = makeSection("ESP", 36)

local _, getBoxESP  = makeCheckbox(ESPHolder, "Box ESP")
local _, getNameESP = makeCheckbox(ESPHolder, "Name ESP")
local _, getFillESP = makeCheckbox(ESPHolder, "Fill Box")

makeColorRow(ESPHolder, "Box Color", function() return boxColor end, function(col)
	boxColor = col
	updateESPColors()
end)

makeColorRow(ESPHolder, "Name Color", function() return nameColor end, function(col)
	nameColor = col
	updateESPColors()
end)

local MAX_HEIGHT = 260

local function resizeAll()
	local canvasH = Container.AbsoluteSize.Y + 14
	local frameH  = math.min(canvasH, MAX_HEIGHT) + 34
	ScrollFrame.Size = UDim2.new(1, -4, 0, frameH - 34)
	MainFrame.Size   = UDim2.new(0, 300, 0, frameH)
end

ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resizeAll)

coroutine.wrap(function()
	task.wait()
	resizeAll()
end)()

coroutine.wrap(function()
	while task.wait() do
		AccentLine.BackgroundColor3 = C.accent
	end
end)()

local contentVisible = false
HideBtn.MouseButton1Click:Connect(function()
	contentVisible = not contentVisible
	ScrollFrame.Visible = contentVisible
	HideBtn.Text = contentVisible and "—" or "+"
	if contentVisible then
		resizeAll()
	else
		MainFrame.Size = UDim2.new(0, 300, 0, 34)
		ColorPickerPopup.Visible = false
	end
end)

HideBtn.MouseEnter:Connect(function() HideBtn.BorderSizePixel = 1 end)
HideBtn.MouseLeave:Connect(function() HideBtn.BorderSizePixel = 0 end)
SkinBtn.MouseEnter:Connect(function() SkinBtn.BorderSizePixel = 1 end)
SkinBtn.MouseLeave:Connect(function() SkinBtn.BorderSizePixel = 0 end)

RunService.Heartbeat:Connect(function()
	espEnabled  = getBoxESP()
	nameEnabled = getNameESP()
	fillEnabled = getFillESP()
	if espEnabled then initESP() else clearAllESP() end
end)

SkinBtn.MouseButton1Click:Connect(function()
	SkinBtn.Text = "Loading..."
	SkinBtn.TextColor3 = C.dim
	pcall(function()
		loadstring(game:HttpGet("https://pastebin.com/raw/4rVNKnw0"))()
		SkinBtn.Text = "Unlocked"
		SkinBtn.TextColor3 = C.accent
	end)
end)

UserInputService.InputBegan:Connect(function(i)
	if i.KeyCode == Enum.KeyCode.RightShift then
		ScreenGui.Enabled = not ScreenGui.Enabled
		ColorPickerPopup.Visible = false
	end
end)
