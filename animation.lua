local Animation = {}

function Animation:New( fps, size, texture, frame_count, orientation )
	local obj = {}
	setmetatable( obj, { __index = self } )

	obj.fps = fps
	obj.size = lovr.math.newVec2( size )
	obj.time_prev = 0
	obj.frame_idx = 1
	obj.frame_count = frame_count
	obj.paused = false

	local t = {}
	for i = 1, frame_count do
		if orientation == e_orientation.horizontal then
			local mt = lovr.graphics.newMaterial( { texture = texture, uvScale = { 1 / frame_count, -1 }, uvShift = { (1 / frame_count) * (i - 1), 0 } } )
			table.insert( t, mt )
		else
			local mt = lovr.graphics.newMaterial( { texture = texture, uvScale = { 1, -1 / frame_count }, uvShift = { 0, (1 / frame_count) * (i - frame_count) } } )
			table.insert( t, mt )
		end
	end
	obj.frames = t

	return obj
end

function Animation:Update( dt )
	local time_now = lovr.timer.getTime()
	local interv = (self.frame_count / self.fps)
	if time_now > self.time_prev + interv then
		self.time_prev = time_now

		if not self.paused then
			self.frame_idx = self.frame_idx + 1
		end

		if self.frame_idx > self.frame_count then
			self.frame_idx = 1
		end
	end
end

function Animation:SetPaused( paused )
	self.paused = paused
end

function Animation:GetPaused( paused )
	return self.paused
end

function Animation:SetFrame( idx )
	self.frame_idx = idx
end

function Animation:GetFrame( idx )
	return self.frame_idx
end

return Animation
