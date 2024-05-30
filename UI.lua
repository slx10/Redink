--[[

		Redink UI - slx10
	|-----------------------------------------------------------------------|
	|	This UI Library is made for Dev's to make plugins or debug stuff	|
	|																		|
	| 	Github.com/slx10													|
	|-----------------------------------------------------------------------|
	
]]
local ui = {}
ui.__index = ui

local Themes = {
	Redink = {
		Primary = Color3.fromRGB(42, 41, 47),
		Secondary = Color3.fromRGB(35, 34, 40),
		Tertiary = Color3.fromRGB(245, 29, 70),
	},
	Linear = {
		Primary = Color3.fromRGB(10, 10, 10),
		Secondary = Color3.fromRGB(28, 28, 28),
		Tertiary = Color3.fromRGB(223, 84, 255)
	},
	Blueprint = {
		Primary = Color3.fromRGB(27, 30, 44),
		Secondary = Color3.fromRGB(33, 36, 50),
		Tertiary = Color3.fromRGB(12, 115, 242)
	},
	Nature = {
		Primary = Color3.fromRGB(19, 19, 17),
		Secondary = Color3.fromRGB(32, 32, 30),
		Tertiary = Color3.fromRGB(160, 206, 50)
	},
	Mist = {
		Primary = Color3.fromRGB(35, 38, 43),
		Secondary = Color3.fromRGB(44, 51, 59),
		Tertiary = Color3.fromRGB(186, 186, 186)
	},
	Sunburst = {
		Primary = Color3.fromRGB(12, 12, 12),
		Secondary = Color3.fromRGB(17, 17, 17),
		Tertiary = Color3.fromRGB(245, 83, 19)
	}
}

local function ThemeExist(ThemeName)
	for Theme,Colors in pairs(Themes) do
		if Theme == ThemeName then
			return true
		end
	end
end

function ui.New(args)
	if args.Parent ~= nil then
		if args.Parent:FindFirstChild(args.Name) then
			return
		end
		local self = setmetatable({},ui)
		self.__IsDestroyed = false
		self.__FinishedSetup = false
		self.__ThemeDebounce = false
		self.__Minimize = false
		self.Gui = script.Gui:Clone()
		self.Theme = "Redink"
		if args.Theme ~= self.Theme then
			self:SetTheme(args.Theme)
		end
		self.Gui.Name = args.Name
		self.Gui.Parent = args.Parent
		self.Gui.Window.Visible = args.Visible
		self.Gui.Window.Nav.Tabs.UIInfo.UIName.Text = args.Name
		self.Gui.Window.Size = args.Size or UDim2.fromScale(0.25,0.4)
		self.Gui.Window.Nav.Close.MouseButton1Click:Connect(function()
			self:Minimize()
		end)
		if args.Draggable then
			local UserInputService = game:GetService("UserInputService")
			local RunService = game:GetService("RunService")

			local Dragging
			local DragInput
			local DragStart
			local StartPos

			local function Lerp(a, b, m)
				return a + (b - a) * m
			end

			local LastMousePos
			local LastGoalPos
			local DragSpeed = 8
			local function Update(dt)
				if not StartPos then return end
				if not Dragging and LastGoalPos then
					self.Gui.Window.Position = UDim2.new(StartPos.X.Scale, Lerp(self.Gui.Window.Position.X.Offset, LastGoalPos.X.Offset, dt * DragSpeed), StartPos.Y.Scale, Lerp(self.Gui.Window.Position.Y.Offset, LastGoalPos.Y.Offset, dt * DragSpeed))
					return 
				end

				local delta = (LastMousePos - UserInputService:GetMouseLocation())
				local xGoal = (StartPos.X.Offset - delta.X)
				local yGoal = (StartPos.Y.Offset - delta.Y)
				LastGoalPos = UDim2.new(StartPos.X.Scale, xGoal, StartPos.Y.Scale, yGoal)
				self.Gui.Window.Position = UDim2.new(StartPos.X.Scale, Lerp(self.Gui.Window.Position.X.Offset, xGoal, dt * DragSpeed), StartPos.Y.Scale, Lerp(self.Gui.Window.Position.Y.Offset, yGoal, dt * DragSpeed))
			end

			self.Gui.Window.Nav.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					Dragging = true
					DragStart = input.Position
					StartPos = self.Gui.Window.Position
					LastMousePos = UserInputService:GetMouseLocation()

					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							Dragging = false
						end
					end)
				end
			end)

			self.Gui.Window.Nav.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					DragInput = input
				end
			end)

			RunService.Heartbeat:Connect(Update)
		end

		local utils = require(script.Utils)
		script.Notification.Parent = self.Gui.Notifications
		--spawn(function()
		--	while not self.__IsDestroyed do
		--		task.wait(0.3)
		--		utils.anim(self.Gui.Window.Title,0.3,{TextColor3=Color3.fromRGB(math.random(50,200),math.random(50,200),math.random(50,200))})
		--	end
		--end)
		self.Tabs = {}
		self.TabsObjects = {}
		self.TabChange = false
		self.__FinishedSetup = true
		return self
	end
end

local function ColorsAreEqual(color1, color2)
	return tostring(color1) == tostring(color2)
end

function ui:SetTheme(ThemeName:string)
	if not self.__ThemeDebounce then
		if ThemeExist(ThemeName) then
			self.__ThemeDebounce = true
			local utils = require(script.Utils)
			local ColorsProperties = {
				"BackgroundColor3",
				"Color"
			}
			local function IterateElements(parent)
				for i,Element in pairs(parent:GetDescendants()) do
					for i,Prop in pairs(ColorsProperties) do
						if utils.hasProp(Element,Prop) then
							local ColorGoal = nil
							for i,Color in pairs(Themes[self.Theme]) do
								if ColorsAreEqual(Color,Element[Prop]) then
									ColorGoal = Themes[ThemeName][i]
								end
							end
							if ColorGoal ~= nil and self.__FinishedSetup then
								task.spawn(function()
									utils.anim(Element,0.3,{[Prop]=ColorGoal})
									task.wait(0.3)
									Element[Prop] = ColorGoal
								end)
							elseif ColorGoal ~= nil then
								Element[Prop] = ColorGoal
							end
						end
					end
				end
			end
			if not self.__FinishedSetup then
				IterateElements(script)
			end
			IterateElements(self.Gui)
			self.Theme = ThemeName
			self.__ThemeDebounce = false
		else
			warn("Theme: "..ThemeName.." does not exist")
		end
	end
end

function ui:GetThemes()
	return Themes
end

function ui:AddTheme(themeName, colorPallette)
	if typeof(themeName) == "string" and #themeName > 0 and Themes[themeName] == nil then
		if typeof(colorPallette) == "table" and #colorPallette == 3 then
			local isValidPalette = true
			for _, color in ipairs(colorPallette) do
				if typeof(color) ~= "Color3" then
					isValidPalette = false
					break
				end
			end
			if isValidPalette then
				Themes[themeName] = colorPallette
			else
				warn("Theme was not added because the color palette contains invalid values!")
			end
		else
			warn("Theme was not added because the color palette is invalid!")
		end
	else
		warn("Theme was not added because the name is invalid!")
	end
end

function ui:Tab(args)
	if not self.__IsDestroyed then
		if not table.find(self.Tabs,args.Name) then
			table.insert(self.Tabs,args.Name)
			local tab = require(script.Tab)
			local newTab = tab.New(args,self.Gui.Window.Nav.Tabs,function(event,tabObj)
				if event == "Destroyed" then
					table.remove(self.TabsObjects,table.find(self.TabsObjects,tabObj))
					if #self.TabsObjects > 0 and tabObj.Active then
						self.TabsObjects[1]:_Active()
						self.TabsObjects[1].Active = true
					end
				end
			end)
			table.insert(self.TabsObjects,newTab)
			local function ChangeTab()
				if newTab.Enabled then
					self.TabChange = true
					if not newTab.Active then
						newTab:HideAll()
						for i,tab in pairs(self.TabsObjects) do
							if tab.Active then
								tab:HideAll()
								tab:_Deactive()
							end
						end
						newTab:_Active()
						newTab:ShowAll()
					end
					self.TabChange = false
				end
			end
			if newTab.Active and #self.TabsObjects > 1 then
				for i,tab in pairs(self.TabsObjects) do
					if newTab ~= tab and tab.Active then
						tab:_Deactive()
					end
				end
				newTab:_Active()
			elseif #self.TabsObjects < 1 then
				newTab:_Active()
			end
			newTab.TabButton.Button.MouseButton1Click:Connect(function()
				if not self.TabChange then
					ChangeTab()
				end
			end)
			newTab.TabButton.Button.Close.CloseBtn.MouseButton1Click:Connect(function()
				newTab:Destroy()
			end)
			return newTab
		end	
	end
end

function ui:SendNotification(args)
	local notifications = require(self.Gui.Notifications.Notification)
	notifications.New(args)
end

function ui:Freeze()
	if not self.__IsDestroyed then
		for i,v in pairs(self.Gui:GetDescendants()) do
			if v:IsA("ModuleScript") then
				v:Destroy()
			end
		end
	end
end

function ui:Maximize()
	repeat task.wait() until not self.__TabChange
	if self.__Minimize then
		local utils = require(script.Utils)
		self.TabChange = true
		utils.anim(self.Gui.Window,0.3,{BackgroundTransparency=0})
		utils.anim(self.Gui.Window.Nav.Close,0.3,{ImageTransparency=0})
		for i,tabButton in pairs(self.Gui.Window.Nav.Tabs:GetChildren()) do
			if tabButton:IsA("Frame") and tabButton.Name ~= "UIInfo" then
				tabButton.Visible = true
			end
		end
		for i,tabObj in pairs(self.TabsObjects) do
			if tabObj.Active then
				tabObj:Show(true)
				tabObj:ShowAll()
				tabObj:ShowButton(true)
			end
			tabObj:Show(false)
			tabObj:ShowButton()
		end
		utils.anim(self.Gui.Window.Nav.Close,0.3,{ImageTransparency=1})
		task.wait(0.3)
		local CloseBtn = self.Gui.Window.Nav.Close
		CloseBtn.Image = "rbxassetid://3926305904"
		CloseBtn.ImageRectOffset = Vector2.new(284,4)
		CloseBtn.ImageRectSize = Vector2.new(24, 24)
		utils.anim(self.Gui.Window.Nav.Close,0.3,{ImageTransparency=0})
		self.TabChange = false
		self.__Minimize = false
	else
		self:Minimize()
	end
end

function ui:Minimize()
	repeat task.wait() until not self.__TabChange
	if not self.__Minimize then
		local utils = require(script.Utils)
		self.TabChange = true
		for i,tabObj in pairs(self.TabsObjects) do
			if tabObj.Active then
				tabObj:HideAll()
			end
			tabObj:Hide()
		end
		utils.anim(self.Gui.Window,0.3,{BackgroundTransparency=1})
		utils.anim(self.Gui.Window.Nav.Close,0.3,{ImageTransparency=1})
		task.wait(0.3)
		local CloseBtn = self.Gui.Window.Nav.Close
		CloseBtn.Image = "rbxassetid://3926307971"
		CloseBtn.ImageRectOffset = Vector2.new(324,364)
		CloseBtn.ImageRectSize = Vector2.new(36,36)
		utils.anim(self.Gui.Window.Nav.Close,0.3,{ImageTransparency=0})
		for i,tabButton in pairs(self.Gui.Window.Nav.Tabs:GetChildren()) do
			if tabButton:IsA("Frame") and tabButton.Name ~= "UIInfo" then
				tabButton.Visible = false
			end
		end
		self.TabChange = false
		self.__Minimize = true
	else
		self:Maximize()
	end
end

function ui:Destroy()
	if not self.__IsDestroyed then
		self.__IsDestroyed = true
		self.Gui:Destroy()
		print("The UI was destroyed")
	end
end

return ui