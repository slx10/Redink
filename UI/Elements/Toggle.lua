local Toggle = {}
Toggle.__index = Toggle

local function anim(instance,duration,propTable)
	local tweenService = game:GetService("TweenService")
	tweenService:Create(instance,TweenInfo.new(duration,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),propTable):Play()
end

local function SetStatus(status:boolean,toggle:Frame)
	if not status then
		anim(toggle.Holder.HolderBG.ToggleBtn,0.3,{BackgroundColor3=Color3.fromRGB(214, 23, 65)})
	else
		anim(toggle.Holder.HolderBG.ToggleBtn,0.3,{BackgroundColor3=Color3.fromRGB(21, 214, 111)})
	end
end

function Toggle.New(args)
	local self = setmetatable({},Toggle)
	self.__Destroyed = false
	self.__Enabled = args.Enabled or true
	self.__Debounce = false
	self.__Visible = args.Visible or true
	self.__VisibilityDebounce = false
	self.Text = args.Text or ""
	self.Description = args.Description or ""
	self.Status = args.Status or false
	self.Callback = args.Callback or function() end
	local function createToggleInstance()
		local newToggle = script.Toggle:Clone()
		newToggle.Texts.Title.Text = self.Text
		newToggle.Texts.Description.Text = self.Description
		newToggle.Parent = script.Parent.Parent
		newToggle.Holder.HolderBG.ToggleBtn.MouseButton1Click:Connect(function()
			if self.__Enabled and not self.__Debounce then
				self.__Debounce = true
				self.Status = not self.Status
				SetStatus(self.Status,newToggle)
				pcall(function() self.Callback(self,self.Status) end)
				self.__Debounce = false
			end
		end)
		return newToggle
	end
	self.ToggleObject = createToggleInstance()
	if self.Description == "" then
		self.ToggleObject.Texts.Title.Size = UDim2.fromScale(1,0.6)
		self.ToggleObject.Texts.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		self.ToggleObject.Texts.Title.TextYAlignment = Enum.TextYAlignment.Center
		self.ToggleObject.Texts.Description.Visible = false
	end
	SetStatus(self.Status,self.ToggleObject)
	return self
end

function Toggle:Hide()
	if not self.__Destroyed and self.__Visible and not self.__VisibilityDebounce then
		self.__VisibilityDebounce = true
		anim(self.ToggleObject,0.3,{BackgroundTransparency=1})
		anim(self.ToggleObject.Texts.Title,0.3,{TextTransparency=1})
		anim(self.ToggleObject.Texts.Description,0.3,{TextTransparency=1})
		anim(self.ToggleObject.Holder.HolderBG,0.3,{BackgroundTransparency=1})
		anim(self.ToggleObject.Holder.HolderBG.ToggleBtn,0.3,{BackgroundTransparency=1})
		task.wait(0.3)
		self.ToggleObject.Visible = false
		self.__Visible = false
		self.__VisibilityDebounce = false
	end
end

function Toggle:Show()
	if not self.__Destroyed and not self.__Visible and not self.__VisibilityDebounce then
		self.__VisibilityDebounce = true
		self.ToggleObject.Visible = true
		anim(self.ToggleObject,0.3,{BackgroundTransparency=0})
		anim(self.ToggleObject.Texts.Title,0.3,{TextTransparency=0})
		anim(self.ToggleObject.Texts.Description,0.3,{TextTransparency=0})
		anim(self.ToggleObject.Holder.HolderBG,0.3,{BackgroundTransparency=0})
		anim(self.ToggleObject.Holder.HolderBG.ToggleBtn,0.3,{BackgroundTransparency=0})
		task.wait(0.3)
		self.__Visible = true
		self.__VisibilityDebounce = false
	end
end

function Toggle:SetStatus(status)
	if not self.__Destroyed then
		self.__Debounce = true
		SetStatus(status,self.ToggleObject)
		self.Status = status
		self.__Debounce = false
	end
end

function Toggle:SetTitle(text)
	if not self.__Destroyed and typeof(text) == "string" then
		self.ToggleObject.Texts.Title.Text = text
	end
end

function Toggle:SetDescription(text)
	if not self.__Destroyed and typeof(text) == "string" then
		self.ToggleObject.Texts.Description.Text = text
	end
end

function Toggle:SetProperty(prop,val)
	if not self.__Destroyed then
		self.ToggleObject[prop] = val
	end
end

function Toggle:Destroy()
	if not self.__Destroyed then
		self.ToggleObject:Destroy()
		self.__Destroyed = true
	end
end

return Toggle