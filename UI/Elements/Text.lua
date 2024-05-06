local Text = {}
Text.__index = Text

local function anim(instance,duration,propTable)
	local tweenService = game:GetService("TweenService")
	tweenService:Create(instance,TweenInfo.new(duration,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),propTable):Play()
end

function Text.New(args)
	local self = setmetatable({},Text)
	self.__Destroyed = false
	self.__Visible = args.Visible or true
	self.__VisibilityDebounce = false
	self.Text = args.Text or ""
	self.Description = args.Description or ""
	local function createTextInstance()
		local newText = script.Text:Clone()
		newText.Texts.Title.Text = self.Text
		newText.Texts.Description.Text = self.Description
		newText.Parent = script.Parent.Parent
		return newText
	end
	self.TextObject = createTextInstance()
	if self.Description == "" then
		self.TextObject.Texts.Title.Size = UDim2.fromScale(1,0.6)
		self.TextObject.Texts.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		self.TextObject.Texts.Title.TextYAlignment = Enum.TextYAlignment.Center
		self.TextObject.Texts.Description.Visible = false
	end
	return self
end

function Text:Hide()
	if not self.__Destroyed and self.__Visible and not self.__VisibilityDebounce then
		self.__VisibilityDebounce = true
		anim(self.TextObject,0.3,{BackgroundTransparency=1})
		anim(self.TextObject.Texts.Title,0.3,{TextTransparency=1})
		anim(self.TextObject.Texts.Description,0.3,{TextTransparency=1})
		task.wait(0.3)
		self.TextObject.Visible = false
		self.__Visible = false
		self.__VisibilityDebounce = false
	end
end

function Text:Show()
	if not self.__Destroyed and not self.__Visible and not self.__VisibilityDebounce then
		self.__VisibilityDebounce = true
		self.TextObject.Visible = true
		anim(self.TextObject,0.3,{BackgroundTransparency=0})
		anim(self.TextObject.Texts.Title,0.3,{TextTransparency=0})
		anim(self.TextObject.Texts.Description,0.3,{TextTransparency=0})
		task.wait(0.3)
		self.__Visible = true
		self.__VisibilityDebounce = false
	end
end

function Text:SetText(text)
	if not self.__Destroyed and typeof(text) == "string" then
		self.TextObject.Text = text
	end
end

function Text:SetProperty(prop,val)
	if not self.__Destroyed then
		pcall(function()
			self.TextObject[prop] = val
		end)
	end
end

function Text:Destroy()
	if not self.__Destroyed then
		self.TextObject:Destroy()
		self.__Destroyed = true
	end
end

return Text