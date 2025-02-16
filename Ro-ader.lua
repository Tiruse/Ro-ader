-------------------------------
--            Basic          --
-------------------------------
local toolbar = plugin:CreateToolbar("Ro-ader")
local toggleButton = toolbar:CreateButton(
	"Ro-ader",
	"Click me to open Ro-ader",
	"rbxassetid://86014139222669",
	"Ro-ader"
)
toggleButton.ClickableWhenViewportHidden = true

----------------------------
--   DockWidget setting   --
----------------------------
local dockWidgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false,
	false,
	300,
	180,
	200,
	180
)

local widget = plugin:CreateDockWidgetPluginGui("AccessoryLoader", dockWidgetInfo)
widget.Title = "Ro-ader"
widget.Enabled = false

toggleButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

---------------------------------------
--               Style               --
---------------------------------------
local function addUICornerAndStroke(obj, cornerRadius, strokeThickness, strokeColor)
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, cornerRadius or 6)
	uiCorner.Parent = obj

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = strokeThickness or 1
	uiStroke.Color = strokeColor or Color3.fromRGB(150, 150, 150)
	uiStroke.Parent = obj
end

local function styleUIObject(obj, bgColor, textColor)
	obj.BackgroundColor3 = bgColor or Color3.fromRGB(50, 50, 50)
	obj.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
	obj.BackgroundTransparency = 0
	addUICornerAndStroke(obj)
end

---------------------------------
--      Layout&MainFrame       --
---------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Parent = widget
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.BackgroundTransparency = 1
mainFrame.ClipsDescendants = true

local mainLayout = Instance.new("UIListLayout")
mainLayout.Parent = mainFrame
mainLayout.FillDirection = Enum.FillDirection.Vertical
mainLayout.Padding = UDim.new(0, 10)
mainLayout.SortOrder = Enum.SortOrder.LayoutOrder

local mainPadding = Instance.new("UIPadding")
mainPadding.Parent = mainFrame
mainPadding.PaddingTop = UDim.new(0, 10)
mainPadding.PaddingBottom = UDim.new(0, 10)
mainPadding.PaddingLeft = UDim.new(0, 10)
mainPadding.PaddingRight = UDim.new(0, 10)

---------------------------------
--   input: Label + TextBox	   --
---------------------------------
local row1 = Instance.new("Frame")
row1.Parent = mainFrame
row1.Size = UDim2.new(1, 0, 0, 40)
row1.BackgroundTransparency = 1
row1.LayoutOrder = 1

local row1Layout = Instance.new("UIListLayout")
row1Layout.Parent = row1
row1Layout.FillDirection = Enum.FillDirection.Horizontal
row1Layout.Padding = UDim.new(0, 10)
row1Layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Label
local label = Instance.new("TextLabel")
label.Parent = row1
label.Size = UDim2.new(0, 100, 1, 0)
label.BackgroundTransparency = 1
label.Text = "Accessory ID:"
label.TextScaled = true
label.LayoutOrder = 1
label.TextColor3 = Color3.new(1, 1, 1)

-- TextBox
local idInput = Instance.new("TextBox")
idInput.Parent = row1
idInput.Size = UDim2.new(1, -110, 1, 0)
idInput.Text = "Enter ID"
idInput.TextScaled = true
idInput.ClearTextOnFocus = true
idInput.LayoutOrder = 2
styleUIObject(idInput, Color3.fromRGB(60, 60, 60))

---------------------------
--  Buttons: Load Button --
---------------------------
local row2 = Instance.new("Frame")
row2.Parent = mainFrame
row2.Size = UDim2.new(1, 0, 0, 40)
row2.BackgroundTransparency = 1
row2.LayoutOrder = 2

local row2Layout = Instance.new("UIListLayout")
row2Layout.Parent = row2
row2Layout.FillDirection = Enum.FillDirection.Horizontal
row2Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
row2Layout.SortOrder = Enum.SortOrder.LayoutOrder

local loadButton = Instance.new("TextButton")
loadButton.Parent = row2
loadButton.Size = UDim2.new(0, 100, 1, 0)
loadButton.Text = "Load"
loadButton.TextScaled = true
styleUIObject(loadButton, Color3.fromRGB(70, 130, 180))

-------------------------------
--       Status Label        --
-------------------------------
local row3 = Instance.new("Frame")
row3.Parent = mainFrame
row3.Size = UDim2.new(1, 0, 0, 40)
row3.BackgroundTransparency = 1
row3.LayoutOrder = 3

local statusLabel = Instance.new("TextLabel")
statusLabel.Parent = row3
statusLabel.Size = UDim2.new(1, 0, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextScaled = true
statusLabel.TextColor3 = Color3.new(1, 0, 0)

----------------------------------------------------
--       LoadAccessory & ReArrange position       --
----------------------------------------------------
loadButton.MouseButton1Click:Connect(function()
	statusLabel.TextColor3 = Color3.new(1, 0, 0)
	statusLabel.Text = ""

	local assetIdStr = idInput.Text
	local assetId = tonumber(assetIdStr)
	if not assetId then
		statusLabel.Text = "Invalid ID."
		return
	end

	statusLabel.Text = "Loading Accessory..."
	local success, assetModel = pcall(function()
		return game:GetService("InsertService"):LoadAsset(assetId)
	end)

	if not success then
		statusLabel.Text = "Failed to load accessory.\nPlease check if you attempted to bring in assets (such as Animations or Bundles) that cannot be retrieved."
		return
	end

	if not assetModel then
		statusLabel.Text = "No asset found with this ID."
		return
	end

	local accessory = assetModel:FindFirstChildWhichIsA("Accessory")
	if not accessory then
		if assetModel:IsA("Accessory") then
			accessory = assetModel
		else
			statusLabel.Text = "Cannot find Accessory in the asset."
			assetModel:Destroy()
			return
		end
	end

	-- Add Accessory at WorkSpace
	accessory.Parent = workspace

	-- Destory Parents
	if assetModel ~= accessory then
		assetModel:Destroy()
	end

	-- Move it to camera
	local handle = accessory:FindFirstChild("Handle") or accessory:FindFirstChildWhichIsA("BasePart")
	if handle and handle:IsA("BasePart") then
		local camera = workspace.CurrentCamera
		handle.CFrame = camera.CFrame * CFrame.new(0, 0, -5)
	end

	-- Loaded
	statusLabel.TextColor3 = Color3.new(0, 1, 0)
	statusLabel.Text = "Accessory loaded!"
end)
