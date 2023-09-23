local TypeWriter = {}

function TypeWriter:New( text, position, timer, interval, auto_start )
	local obj = {}
	setmetatable( obj, { __index = self } )

	obj.text = text
	obj.text_writer = ""
	obj.position = lovr.math.newVec2( position )
	obj.timer = timer
	obj.interval = interval
	obj.cursor = 1
	obj.started = auto_start or false
	obj.finished = false
	return obj
end

function TypeWriter:Start()
	self.started = true
end

function TypeWriter:HasFinished()
	return self.finished
end

function TypeWriter:Draw( pass )
	if self.started then
		local char_count = #self.text_writer
		local half = (char_count * 8) / 2
		pass:text( self.text_writer, self.position.x + half, self.position.y, 1 )

		if not self.finished and self.timer:GetElapsed() > self.interval then
			self.text_writer = string.sub( self.text, 1, self.cursor )
			self.cursor = self.cursor + 1
			self.timer:Reset()
		end

		if self.cursor > #self.text then
			self.finished = true
		end
	end
end

return TypeWriter
