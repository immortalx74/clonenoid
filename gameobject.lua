local Animation = require "animation"

local GameObject = {}

game_objects = {}

function GameObject:New( type, position, animation )
	local obj = {}
	setmetatable( obj, { __index = self } )
	obj.type = type
	obj.animation = animation
	obj.position = lovr.math.newVec2( position )
	table.insert( game_objects, obj )

	return obj
end

function GameObject:Update( dt )
	self.animation:Update()
end

function GameObject:Draw( pass )
	pass:setMaterial( self.animation.frames[ self.animation.frame_idx ] )
	pass:plane( self.position.x, self.position.y, 0, self.animation.size.x * 4, self.animation.size.y * 4 )
	pass:setMaterial()
end

return GameObject
