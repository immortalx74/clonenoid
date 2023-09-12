local Animation = {}

function Animation:New( fps, size, texture, frame_count, orientation )
	local obj = {}
	setmetatable( obj, { __index = self } )

	obj.fps = fps
	obj.size = lovr.math.newVec2( size )
	obj.time_prev = 0
	obj.frame_idx = 1
	obj.frame_count = frame_count

	local t = {}
	for i = 1, frame_count do
		if orientation == e_orientation.horizontal then
			local mt = lovr.graphics.newMaterial( { texture = texture, uvScale = { 1 / frame_count, -1 }, uvShift = { (i * size.x) / (size.x * frame_count), 0 } } )
			-- local mt = lovr.graphics.newMaterial( { texture = texture, uvScale = { 1 / frame_count, -1 }, uvShift = { 0, (i * size.x) / (size.x * frame_count) } } )
			table.insert( t, mt )
		else
			local mt = lovr.graphics.newMaterial( { texture = texture, uvScale = { 1, -1 / frame_count }, uvShift = { 0, (i * size.y) / (size.y * frame_count) } } )
			table.insert( t, mt )
		end
	end
	obj.frames = t

	return obj
end

function Animation:Update()
	local time_now = lovr.timer.getTime()
	local interv = 1 / self.fps
	if time_now > self.time_prev + interv then
		self.time_prev = time_now
		self.frame_idx = self.frame_idx + 1
		if self.frame_idx > self.frame_count then
			self.frame_idx = 1
		end
	end
end

return Animation
