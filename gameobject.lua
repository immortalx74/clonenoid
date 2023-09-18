local Animation = require "animation"

local GameObject = {}

game_objects = {}

function GameObject:New( type, position, animation_type )
	local obj = {}
	setmetatable( obj, { __index = self } )
	obj.type = type
	obj.position = lovr.math.newVec2( position )

	if animation_type == e_animation.bar_v then
		obj.animation = Animation:New( 60, vec2( 8, 232 ), textures.bar_v, 7, e_orientation.horizontal )
	elseif animation_type == e_animation.paddle_normal then
		obj.animation = Animation:New( 30, vec2( 32, 8 ), textures.paddle_normal, 6, e_orientation.vertical )
	elseif animation_type == e_animation.paddle_big then
		obj.animation = Animation:New( 30, vec2( 48, 8 ), textures.paddle_big, 6, e_orientation.vertical )
	elseif animation_type == e_animation.brick_colored then
		obj.animation = Animation:New( 10, vec2( 16, 8 ), textures.bricks, 8, e_orientation.horizontal )
	elseif animation_type == e_animation.brick_silver then
		obj.animation = Animation:New( 30, vec2( 16, 8 ), textures.brick_silver, 6, e_orientation.horizontal )
	elseif animation_type == e_animation.brick_gold then
		obj.animation = Animation:New( 30, vec2( 16, 8 ), textures.brick_gold, 6, e_orientation.horizontal )
	elseif animation_type == e_animation.ball then
		obj.animation = Animation:New( 1, vec2( 4, 4 ), textures.ball, 1, e_orientation.horizontal )
	elseif animation_type == e_animation.bar_h_l then
		obj.animation = Animation:New( 30, vec2( 112, 8 ), textures.bar_h_l, 6, e_orientation.vertical )
	elseif animation_type == e_animation.bar_h_r then
		obj.animation = Animation:New( 30, vec2( 112, 8 ), textures.bar_h_r, 6, e_orientation.vertical )
	elseif animation_type == e_animation.bg then
		obj.animation = Animation:New( 60, vec2( 208, 232 ), textures.bg, 4, e_orientation.horizontal )
	elseif animation_type == e_animation.powerup_b then
		obj.animation = Animation:New( 60, vec2( 16, 8 ), textures.powerup_break, 8, e_orientation.horizontal )
	elseif animation_type == e_animation.powerup_c then
		obj.animation = Animation:New( 60, vec2( 16, 8 ), textures.powerup_catch, 8, e_orientation.horizontal )
	elseif animation_type == e_animation.powerup_d then
		obj.animation = Animation:New( 60, vec2( 16, 8 ), textures.powerup_disruption, 8, e_orientation.horizontal )
	elseif animation_type == e_animation.powerup_e then
		obj.animation = Animation:New( 60, vec2( 16, 8 ), textures.powerup_enlarge, 8, e_orientation.horizontal )
	elseif animation_type == e_animation.powerup_l then
		obj.animation = Animation:New( 60, vec2( 16, 8 ), textures.powerup_laser, 8, e_orientation.horizontal )
	elseif animation_type == e_animation.powerup_p then
		obj.animation = Animation:New( 60, vec2( 16, 8 ), textures.powerup_player, 8, e_orientation.horizontal )
	elseif animation_type == e_animation.powerup_s then
		obj.animation = Animation:New( 60, vec2( 16, 8 ), textures.powerup_slow, 8, e_orientation.horizontal )
	end
	obj.animation.time_prev = lovr.timer.getTime()
	table.insert( game_objects, obj )

	return obj
end

function GameObject:Update( dt )
	self.animation:Update( dt )
end

function GameObject:Draw( pass )
	pass:setMaterial( self.animation.frames[ self.animation.frame_idx ] )
	pass:plane( self.position.x, self.position.y, 0, self.animation.size.x, self.animation.size.y )
	pass:setMaterial()
end

function GameObject:Destroy()
	for i, v in ipairs( game_objects ) do
		if v == self then
			v.animation = nil
			table.remove( game_objects, i )
		end
	end
end

function GameObject.UpdateAll( dt )
	for i, v in ipairs( game_objects ) do
		v:Update( dt )
	end
end

function GameObject.DrawAll( pass )
	for i, v in ipairs( game_objects ) do
		v:Draw( pass )
	end
end

return GameObject
