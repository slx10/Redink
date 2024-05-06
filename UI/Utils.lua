local Utils = {}

function Utils.hasProp(instance,prop)
	return pcall(function()
		local x = instance[prop]
	end)
end

function Utils.anim(instance,duration,propTable)
	local tweenService = game:GetService("TweenService")
	tweenService:Create(instance,TweenInfo.new(duration,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),propTable):Play()
end

return Utils
