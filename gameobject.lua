local Animation = require "animation"

local GameObject = {}

game_objects = {}

function GameObject:New( type, position, animation_type )
	local obj = {}
	setmetatable( obj, { __index = self } )
	obj.type = type
	obj.position = lovr.math.newVec2( position )

	if animation_type == e_animation.bar_v_closed then
		obj.animation = Animation:New( 1, vec2( 8, 232 ), textures.bar_v_closed, 1, e_orientation.horizontal )
	elseif animation_type == e_animation.bar_v_opening then
		obj.animation = Animation:New( 20, vec2( 8, 232 ), textures.bar_v_opening, 3, e_orientation.horizontal )
	elseif animation_type == e_animation.bar_v_open then
		obj.animation = Animation:New( 30, vec2( 8, 232 ), textures.bar_v_open, 3, e_orientation.horizontal )
	elseif animation_type == e_animation.paddle_normal then
		obj.animation = Animation:New( 30, vec2( 32, 8 ), textures.paddle_normal, 6, e_orientation.vertical )
	elseif animation_type == e_animation.paddle_big then
		obj.animation = Animation:New( 30, vec2( 48, 8 ), textures.paddle_big, 6, e_orientation.vertical )
	elseif animation_type == e_animation.paddle_laser then
		obj.animation = Animation:New( 30, vec2( 32, 8 ), textures.paddle_laser, 6, e_orientation.vertical )
	elseif animation_type == e_animation.paddle_appear then
		obj.animation = Animation:New( 30, vec2( 32, 8 ), textures.paddle_appear, 5, e_orientation.vertical )
	elseif animation_type == e_animation.brick_colored then
		obj.animation = Animation:New( 10, vec2( 16, 8 ), textures.bricks, 8, e_orientation.horizontal )
	elseif animation_type == e_animation.brick_silver then
		obj.animation = Animation:New( 120, vec2( 16, 8 ), textures.brick_silver, 6, e_orientation.horizontal )
	elseif animation_type == e_animation.brick_gold then
		obj.animation = Animation:New( 120, vec2( 16, 8 ), textures.brick_gold, 6, e_orientation.horizontal )
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
	elseif animation_type == e_animation.life then
		obj.animation = Animation:New( 1, vec2( 16, 8 ), textures.life, 1, e_orientation.horizontal )
	elseif animation_type == e_animation.laser then
		obj.animation = Animation:New( 60, vec2( 16, 8 ), textures.laser, 4, e_orientation.vertical )
	elseif animation_type == e_animation.arkanoid_logo then
		obj.animation = Animation:New( 1, vec2( 218, 48 ), textures.arkanoid_logo, 1, e_orientation.horizontal )
	elseif animation_type == e_animation.taito_logo then
		obj.animation = Animation:New( 1, vec2( 96, 14 ), textures.taito_logo, 1, e_orientation.horizontal )
	elseif animation_type == e_animation.mothership then
		obj.animation = Animation:New( 30, vec2( 192, 88 ), textures.mothership, 5, e_orientation.vertical )
	end
	obj.animation_type = animation_type
	obj.animation.time_prev = lovr.timer.getTime()
	table.insert( game_objects, obj )

	return obj
end

function GameObject:Update( dt )
	if self.animation_type == e_animation.brick_silver or self.animation_type == e_animation.brick_gold then
		if self.animation.frame_idx == 6 then
			self.animation.frame_idx = 1
			self.animation.paused = true
		end
	end
	self.animation:Update( dt )
end

function GameObject:Draw( pass )
	local at = self.animation_type
	local shadow1 = at == e_animation.paddle_normal or at == e_animation.paddle_big or at == e_animation.paddle_laser  or at == e_animation.ball
	local shadow2 = at == e_animation.brick_colored or at == e_animation.brick_gold or at == e_animation.brick_silver
	pass:setMaterial( self.animation.frames[ self.animation.frame_idx ] )
	if shadow1 or shadow2 then
		pass:setColor( 0, 0, 0, 1 )
		local offset = 4

		if shadow2 then
			pass:setColor( 0, 0, 0, 0.5 )
			offset = 8
		end

		pass:plane( self.position.x + offset, self.position.y + offset, 0, self.animation.size.x, self.animation.size.y )
		pass:setColor( 1, 1, 1 )
	end

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
