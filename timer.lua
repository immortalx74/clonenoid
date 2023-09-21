local Timer = {}

function Timer:New( auto_start )
	local obj = {}
	setmetatable( obj, { __index = self } )
	obj.start_time = auto_start and lovr.timer.getTime() or 0
	obj.started = auto_start or false
	return obj
end

function Timer:Reset()
	self.start_time = lovr.timer.getTime()
	self.started = true
end

function Timer:GetElapsed()
	return self.started and lovr.timer.getTime() - self.start_time or 0
end

return Timer
