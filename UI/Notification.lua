local Notification = {}
local Debris = game:GetService("Debris")
Notification.__index = Notification

local function anim(instance,duration,propTable)
	local tweenService = game:GetService("TweenService")
	tweenService:Create(instance,TweenInfo.new(duration,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),propTable):Play()
end

function Notification.New(args)
	local self = setmetatable({}, Notification)
	self.__IsDestroyed = false
	self.Title = args.Title or ""
	self.Text = args.Text or ""
	self.Duration = args.Duration or 3
	
	local function HideDefault(instance,duration)
		anim(instance,duration,{BackgroundTransparency=1})
		anim(instance.Border,duration,{Transparency=1})
		anim(instance.Title,duration,{TextTransparency=1})
		anim(instance.Message,duration,{TextTransparency=1})
		anim(instance.Frame,duration,{BackgroundTransparency=1})
	end
	
	local function ShowDefault(instance,duration)
		anim(instance,duration,{BackgroundTransparency=0})
		anim(instance.Border,duration,{Transparency=0})
		anim(instance.Title,duration,{TextTransparency=0})
		anim(instance.Message,duration,{TextTransparency=0})
		anim(instance.Frame,duration,{BackgroundTransparency=0})
	end

	if type(args.Buttons) == "table" then
		local buttons = script.Buttons:Clone()
		buttons.Title.Text = self.Title
		buttons.Message.Text = self.Text
		if #args.Buttons == 1 then
			buttons.Buttons["1"].Size = UDim2.fromScale(1,0.9)
			Debris:AddItem(buttons.Buttons["2"],0)
		end

		for i, buttonData in ipairs(args.Buttons) do
			local button = buttons.Buttons[tostring(i)]
			button.Text = buttonData.Text
			button.MouseButton1Click:Connect(function()
				if buttonData.Callback then
					buttonData.Callback()
				end
			end)
		end
		
		HideDefault(buttons,0.01)
		buttons.Visible = true
		
		buttons.Parent = script.Parent
		ShowDefault(buttons,0.3)
		task.wait(self.Duration)
		HideDefault(buttons,0.3)
		anim(buttons.Buttons["1"],0.3,{TextTransparency=1})
		if #args.Buttons > 1 then
			anim(buttons.Buttons["2"],0.3,{TextTransparency=1})
		end
		Debris:AddItem(buttons,0.3)
	else
		local simple = script.Simple:Clone()
		simple.Title.Text = self.Title
		simple.Message.Text = self.Text
		
		HideDefault(simple,0.01)
		simple.Visible = true
		
		simple.Parent = script.Parent
		ShowDefault(simple,0.3)
		task.wait(self.Duration)
		HideDefault(simple,0.3)
		Debris:AddItem(simple,0.3)
	end

	return self
end

return Notification
