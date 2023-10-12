require "util"
require "globals"
require "assets"
local GameObject = require "gameobject"
local Animation = require "animation"
local Timer = require "timer"
local TypeWriter = require "typewriter"
local io = require "io"

local function DrawScreenText( pass )
	font:setPixelDensity( 1 )
	pass:setFont( font )

	pass:setColor( 1, 0, 0 )

	if timers.oneup:GetElapsed() >= 0.5 then
		pass:text( "1UP", metrics.text_1up_left, metrics.text_1up_top, 1 )
	end

	if timers.oneup:GetElapsed() >= 1 then
		timers.oneup:Reset()
	end

	pass:text( "HIGH SCORE", metrics.text_high_score_string_left, metrics.text_high_score_string_top, 1 )

	pass:setColor( 1, 1, 1 )

	local hs = scores.high
	if scores.player > scores.high then
		hs = scores.player
	end
	pass:text( tostring( hs ), metrics.text_high_score_left, metrics.text_high_score_top, 1 )

	if scores.player == 0 then
		pass:text( "00", metrics.text_score_left, metrics.text_score_top, 1 )
	else
		local num_digits = math.floor( math.log( scores.player, 10 ) + 1 )
		local p = ((num_digits * 8) / 2) - 8
		pass:text( tostring( scores.player ), metrics.text_score_left - p, metrics.text_score_top, 1 )
	end

	if game_state == e_game_state.level_intro then
		pass:setColor( 1, 1, 1 )
		local str = "ROUND  "
		if level_idx > 9 then
			str = "ROUND "
		end
		pass:text( str .. tostring( level_idx ), game_w / 2, metrics.text_level_intro_top, 1 )

		if timers.level_intro:GetElapsed() > 1 then
			pass:text( "READY", game_w / 2, metrics.text_level_intro_top + 16, 1 )
		end
	elseif game_state == e_game_state.main_screen then
		pass:setColor( 1, 1, 1 )

		pass:text( "A FREE OPEN-SOURCE PORT", game_w / 2, metrics.text_main_screen_msg, 1 )
		pass:text( "OF THE ARCADE VERSION", game_w / 2, metrics.text_main_screen_msg + 16, 1 )
		pass:text( "MADE WITH LÖVR (lovr.org)", game_w / 2, metrics.text_main_screen_msg + 32, 1 )


		if timers.press_space:GetElapsed() >= 0.5 then
			pass:setColor( 1, 0, 0 )
			pass:text( "[PRESS SPACE TO START]", game_w / 2, metrics.text_main_screen_msg + 48, 1 )
		end

		if timers.press_space:GetElapsed() >= 1 then
			timers.press_space:Reset()
		end

		pass:setColor( 1, 1, 1 )
		pass:text( "© 1986 TAITO CORP JAPAN", game_w / 2, metrics.text_copyright_top, 1 )
		pass:text( "ALL RIGHTS RESERVED", game_w / 2, metrics.text_copyright_top + 16, 1 )
	elseif game_state == e_game_state.story then
		for i, v in ipairs( story_text[ story_text.paragraph ] ) do
			v:Draw( pass )
			if v:HasFinished() then
				if story_text[ story_text.paragraph ][ i + 1 ] then
					story_text[ story_text.paragraph ][ i + 1 ]:Start()
				else
					if not story_text.paragraph_finished then
						story_text.paragraph_finished = true
						timers.paragraph_end:Reset()

						if story_text.paragraph < 3 then
							story_text[ story_text.paragraph + 1 ][ 1 ]:Start()
						end
					end

					if timers.paragraph_end:GetElapsed() > 0.5 then
						story_text.paragraph = story_text.paragraph + 1
						story_text.paragraph_finished = false
						timers.paragraph_end:Reset()

						if story_text.paragraph == 3 then
							sounds.paddle_away:stop()
							sounds.paddle_away:play()
						end
					end

					if story_text.paragraph > 3 then
						story_text.paragraph = 1
						game_state = e_game_state.generate_level
					end
				end
			end
		end
	end
end

local function DropPowerUp( x, y )
	-- Drop random powerup
	if not powerup.dropping and timers.powerup:GetElapsed() > powerup.interval then
		-- powerup.type = math.random( e_animation.powerup_b, e_animation.powerup_s )
		powerup.type = e_animation.powerup_d
		powerup.dropping = GameObject:New( e_object_type.powerup, vec2( x, y ), powerup.type )
	end
end

local function GenerateLevel( idx )
	powerup      = { current = nil, dropping = nil, interval = math.random( 4, 7 ), type = nil }
	game_objects = nil
	game_objects = {}
	bullets      = nil
	bullets      = {}
	balls        = nil
	balls        = {}
	obj_paddle   = nil
	obj_ball     = nil
	obj_gate     = nil
	level_bricks = nil
	level_bricks = {}

	-- background
	local bg     = GameObject:New( e_object_type.decorative, vec2( metrics.bg_left, metrics.bg_top ), e_animation.bg )
	local bg_idx = level_idx % 4
	if bg_idx == 0 then
		bg_idx = 1
	end
	bg.animation:SetFrame( bg_idx )
	bg.animation:SetPaused( true )

	-- Bricks
	local level = levels[ level_idx ]
	level.num_destroyable_bricks = 0
	local x = metrics.wall_start_left
	local y = metrics.wall_start_top

	for i = 1, #level do
		if (i - 1) % metrics.wall_columns == 0 and i > 1 then
			y = y + metrics.brick_h
			x = metrics.wall_start_left
		end

		if level[ i ] ~= "0" then
			local go = GameObject:New( e_object_type.brick, vec2( x, y ), brick_type[ level[ i ] ].anim )
			go.animation:SetFrame( brick_type[ level[ i ] ].frame )
			go.animation:SetPaused( true )
			go.points = brick_type[ level[ i ] ].points

			local silver_strength = 2
			if level_idx % 8 == 0 then
				local increase = math.floor( level_idx / 8 )
				silver_strength = silver_strength + increase
			end
			if go.animation_type == e_animation.brick_silver then
				go.strength = silver_strength
				go.points = level_idx * 50
				level.num_destroyable_bricks = level.num_destroyable_bricks + 1
			elseif go.animation_type == e_animation.brick_gold then
				go.strength = 10000
			elseif go.animation_type == e_animation.brick_colored then
				go.strength = 1
				level.num_destroyable_bricks = level.num_destroyable_bricks + 1
			end

			table.insert( level_bricks, go )
		end
		x = x + metrics.brick_w
	end

	-- Side and top bars
	local bhl = GameObject:New( e_object_type.decorative, vec2( metrics.bar_h_l_left, metrics.bar_h_l_top ), e_animation.bar_h_l )
	bhl.animation:SetFrame( 1 )
	bhl.animation:SetPaused( true )
	local bhr = GameObject:New( e_object_type.decorative, vec2( metrics.bar_h_r_left, metrics.bar_h_r_top ), e_animation.bar_h_r )
	bhr.animation:SetFrame( 1 )
	bhr.animation:SetPaused( true )

	local bvl = GameObject:New( e_object_type.decorative, vec2( metrics.bar_v_l_left, metrics.bar_v_l_top ), e_animation.bar_v_closed )
	bvl.animation:SetFrame( 1 )
	bvl.animation:SetPaused( true )
	obj_gate = GameObject:New( e_object_type.decorative, vec2( metrics.bar_v_r_left, metrics.bar_v_r_top ), e_animation.bar_v_closed )
	obj_gate.animation:SetFrame( 1 )
	obj_gate.animation:SetPaused( true )

	-- Paddle (start with appear animation)
	obj_paddle = GameObject:New( e_object_type.paddle, vec2( game_w / 2, metrics.paddle_y ), e_animation.paddle_appear )

	-- Ball
	balls = {}
	local b = GameObject:New( e_object_type.ball, vec2( game_w / 2, metrics.paddle_y - 8 ), e_animation.ball )
	b.velocity = lovr.math.newVec2( 150, -150 )
	b.sticky = true
	table.insert( balls, b )

	-- Life bar
	local left = metrics.life_bar_left
	for i = 1, life_bar.total - 1 do
		local l = GameObject:New( e_object_type.decorative, vec2( left, metrics.life_bar_top ), e_animation.life )
		table.insert( life_bar.objects, l )
		left = left + 16
	end

	timers.powerup:Reset()
	timers.level_intro:Reset()
	game_state = e_game_state.level_intro
end

local function UpdateBullets()
	for i, k in ipairs( bullets ) do
		if not k.hit then
			k.position.y = k.position.y - 4
		end

		if k.position.y < metrics.bar_h_l_top + 8 then
			k.marked = true
		end

		local xx = k.position.x
		local yy = k.position.y

		-- Bricks collision
		for j, v in ipairs( game_objects ) do
			if v.type == e_object_type.brick then
				local br_l = v.position.x - 8
				local br_r = v.position.x + 8
				local br_t = v.position.y - 4
				local br_b = v.position.y + 4

				local bul_l = xx - 8
				local bul_r = xx + 8
				local bul_t = yy - 4
				local bul_b = yy + 4

				if bul_l < br_r and bul_r > br_l and bul_t < br_b and bul_b > br_t then
					-- k.marked = true
					k.hit = true
					v.strength = v.strength - 1
					if v.animation_type == e_animation.brick_silver or v.animation_type == e_animation.brick_gold then
						v.animation:SetPaused( false )
					end

					if v.strength == 0 then
						DropPowerUp( v.position.x, v.position.y )
						table.remove( game_objects, j )
						scores.player = scores.player + v.points
						levels[ level_idx ].num_destroyable_bricks = levels[ level_idx ].num_destroyable_bricks - 1
					end
				end
			end
		end
	end

	for i, v in ipairs( bullets ) do
		if v.hit then
			v.animation:SetPaused( false )
			if v.animation:GetFrame() == 3 then
				v.hit = false
				v.marked = true
			end
		end
		if v.marked then
			bullets[ i ]:Destroy()
			table.remove( bullets, i )
		end
	end
end

local function UpdatePowerUp()
	-- Powerup position
	if powerup.dropping then
		local half_size = 16
		if obj_paddle.animation_type == e_animation.paddle_big then
			half_size = 24
		end

		powerup.dropping.position.y = powerup.dropping.position.y + 1
		-- Powerup went off screen
		if powerup.dropping.position.y > game_h then
			powerup.dropping:Destroy()
			powerup.dropping = nil
			timers.powerup:Reset()

			-- Powerup -> paddle collision
		elseif powerup.dropping.position.x > obj_paddle.position.x - half_size and powerup.dropping.position.x < obj_paddle.position.x + half_size then
			if powerup.dropping.position.y > obj_paddle.position.y - 4 then
				powerup.current = powerup.dropping

				-- Powerup behavior
				if powerup.type == e_animation.powerup_b then
					obj_gate:Destroy()
					obj_gate = nil
					obj_gate = GameObject:New( e_object_type.decorative, vec2( metrics.bar_v_r_left, metrics.bar_v_r_top ), e_animation.bar_v_opening )
				elseif powerup.type == e_animation.powerup_c then
					for i, v in ipairs( balls ) do
						-- v.sticky = true
					end
				elseif powerup.type == e_animation.powerup_d then
					powerup.current = powerup.dropping

					local inv = 1
					for i = 1, 2 do
						local b = GameObject:New( e_object_type.ball, vec2( balls[ 1 ].position.x, balls[ 1 ].position.y ), e_animation.ball )
						b.velocity = lovr.math.newVec2( 150 * inv, -150 * inv )
						table.insert( balls, b )
						inv = -1
					end
				elseif powerup.type == e_animation.powerup_e then
					obj_paddle:Destroy()
					obj_paddle = nil
					obj_paddle = GameObject:New( e_object_type.paddle, vec2( game_w / 2, metrics.paddle_y ), e_animation.paddle_big )
					obj_paddle.prev_x = 0
					sounds.paddle_turn_big:stop()
					sounds.paddle_turn_big:play()
				elseif powerup.type == e_animation.powerup_l then
					obj_paddle:Destroy()
					obj_paddle = nil
					obj_paddle = GameObject:New( e_object_type.paddle, vec2( game_w / 2, metrics.paddle_y ), e_animation.paddle_laser )
					obj_paddle.prev_x = 0
					obj_paddle.can_shoot = true
				elseif powerup.type == e_animation.powerup_p then
					if life_bar.total < life_bar.max then
						local left = metrics.life_bar_left + ((life_bar.total - 1) * 16)
						local l = GameObject:New( e_object_type.decorative, vec2( left, metrics.life_bar_top ), e_animation.life )
						life_bar.total = life_bar.total + 1
					end
					powerup.current = nil
					sounds.got_life:stop()
					sounds.got_life:play()
				elseif powerup.type == e_animation.powerup_s then

				end
				powerup.dropping:Destroy()
				powerup.dropping = nil
				timers.powerup:Reset()
			end
		end
	end

	if powerup.current then
		if powerup.type == e_animation.powerup_b then
			if obj_gate.animation_type == e_animation.bar_v_opening and obj_gate.animation:GetFrame() == 3 then
				obj_gate:Destroy()
				obj_gate = nil
				obj_gate = GameObject:New( e_object_type.decorative, vec2( metrics.bar_v_r_left, metrics.bar_v_r_top ), e_animation.bar_v_open )
			end
		end
	end
end

local function UpdatePaddle()
	local scale = plane_w / game_w
	local diff = (window.w - plane_w) / 2
	obj_paddle.position.x = (mouse.position.x / scale) - (diff / scale)

	local constrain_left = metrics.paddle_constrain_left_normal
	local constrain_right = metrics.paddle_constrain_right_normal

	if obj_paddle.animation_type == e_animation.paddle_big then
		constrain_left = metrics.paddle_constrain_left_big
		constrain_right = metrics.paddle_constrain_right_big
	end

	if obj_paddle.position.x < constrain_left then
		obj_paddle.position.x = constrain_left
	end

	if obj_gate.animation_type ~= e_animation.bar_v_open then
		if obj_paddle.position.x > constrain_right then
			obj_paddle.position.x = constrain_right
		end
	end

	-- Shoot
	if IsMouseDown() and obj_paddle.can_shoot then
		local b = GameObject:New( e_object_type.laser, vec2( obj_paddle.position ), e_animation.laser )
		b.animation:SetPaused( true )
		table.insert( bullets, b )
		sounds.laser_shoot:stop()
		sounds.laser_shoot:play()
	end

	-- Exit from gate
	if obj_paddle.position.x > game_w - 16 and not obj_paddle.begin_exit then
		obj_paddle.begin_exit = true
		sounds.escape_level:stop()
		sounds.escape_level:play()
	end

	obj_paddle.prev_x = obj_paddle.position.x
end

local function UpdateBall( dt )
	local steps = 8
	for i = 1, #balls do
		if balls[ i ].sticky then
			if game_state == e_game_state.play then
				if IsMouseDown() or timers.balls[ i ]:GetElapsed() > 2 then
					balls[ i ].sticky = false
					balls[ i ].velocity.x = 150
					balls[ i ].velocity.y = -150
					sounds.ball_to_paddle:stop()
					sounds.ball_to_paddle:play()
				end
			end
		end

		local prev_x = balls[ i ].position.x
		local prev_y = balls[ i ].position.y

		for j = 1, steps do
			if balls[ i ].sticky then
				if not balls[ i ].sticky_offset then
					balls[ i ].sticky_offset = 0
				end
				balls[ i ].position.x = obj_paddle.position.x - balls[ i ].sticky_offset
				balls[ i ].position.y = obj_paddle.position.y - 8
				balls[ i ].velocity.x = 0
				balls[ i ].velocity.y = 0
			else
				balls[ i ].position.x = balls[ i ].position.x + (balls[ i ].velocity.x / steps) * dt
				balls[ i ].position.y = balls[ i ].position.y + (balls[ i ].velocity.y / steps) * dt
			end

			if ConstrainToPlayArea( i ) then
				return
			end
			BallToPaddleCollision( i )

			-- Bricks collision
			local cur_x = balls[ i ].position.x
			local cur_y = balls[ i ].position.y

			for k, v in ipairs( game_objects ) do
				if v.type == e_object_type.brick then
					local rect_brick = { l = v.position.x - 8, r = v.position.x + 8, t = v.position.y - 4, b = v.position.y + 4 }
					local rect_ball_cur = { l = cur_x - 2, r = cur_x + 2, t = cur_y - 2, b = cur_y + 2 }

					if RectToRect( rect_brick, rect_ball_cur ) then
						-- Determine collision side
						local rect_ball_prev = { l = prev_x - 2, r = prev_x + 2, t = prev_y - 2, b = prev_y + 2 }
						if rect_ball_cur.t < rect_brick.b and rect_ball_prev.t > rect_brick.b then -- from bottom
							balls[ i ].velocity.y = -balls[ i ].velocity.y
						elseif rect_ball_cur.b > rect_brick.t and rect_ball_prev.b < rect_brick.t then -- from top
							balls[ i ].velocity.y = -balls[ i ].velocity.y
						elseif rect_ball_cur.l < rect_brick.r and rect_ball_prev.l > rect_brick.r then -- from right
							balls[ i ].velocity.x = -balls[ i ].velocity.x
						elseif rect_ball_cur.r > rect_brick.l and rect_ball_prev.r < rect_brick.l then -- from left
							balls[ i ].velocity.x = -balls[ i ].velocity.x
						end

						v.strength = v.strength - 1
						if v.animation_type == e_animation.brick_silver or v.animation_type == e_animation.brick_gold then
							v.animation:SetPaused( false )

							if v.strength > 0 then
								sounds.ball_brick_ding:stop()
								sounds.ball_brick_ding:play()
							end
						end

						if v.strength == 0 then
							sounds.ball_brick_destroy:stop()
							sounds.ball_brick_destroy:play()
							DropPowerUp( v.position.x, v.position.y )
							table.remove( game_objects, k )
							scores.player = scores.player + v.points
							levels[ level_idx ].num_destroyable_bricks = levels[ level_idx ].num_destroyable_bricks - 1
						end
						break
					end
				end
			end
		end
	end
end

local Game = {}
function Game.Init()
	lovr.graphics.setBackgroundColor( 0, 0, 0 )
	LoadLevels()
	LoadTextures()
	LoadSounds()

	game_handle = ffi.C.os_get_glfw_window()
	glfw.glfwSetInputMode( game_handle, GLFW_CURSOR, GLFW_CURSOR_HIDDEN )
	math.randomseed( os.time() )

	timers.typewriter    = Timer:New()
	timers.paragraph_end = Timer:New()
	timers.press_space   = Timer:New( true )
	timers.oneup         = Timer:New( true )
	timers.powerup       = Timer:New()
	timers.level_intro   = Timer:New()
	timers.balls         = { Timer:New(), Timer:New(), Timer:New() }

	obj_arkanoid_logo    = GameObject:New( e_object_type.decorative, vec2( game_w / 2, metrics.arkanoid_logo_top ), e_animation.arkanoid_logo )
	obj_taito_logo       = GameObject:New( e_object_type.decorative, vec2( game_w / 2, metrics.taito_logo_top ), e_animation.taito_logo )

	story_text           = {
		paragraph = 1,
		paragraph_finished = false,
		{
			TypeWriter:New( "THE ERA AND TIME OF", vec2( 8, metrics.text_story_top ), timers.typewriter, 0.02, true ), -- auto-start the 1st one only
			TypeWriter:New( "THIS STORY IS UNKNOWN.", vec2( 8, metrics.text_story_top + 16 ), timers.typewriter, 0.02 )
		},
		{
			TypeWriter:New( "AFTER THE MOTHERSHIP", vec2( 8, metrics.text_story_top ), timers.typewriter, 0.02 ),
			TypeWriter:New( '"ARKANOID" WAS DESTROYED,', vec2( 8, metrics.text_story_top + 16 ), timers.typewriter, 0.02 ),
			TypeWriter:New( 'A SPACECRAFT "VAUS"', vec2( 8, metrics.text_story_top + 32 ), timers.typewriter, 0.02 ),
			TypeWriter:New( "SCRAMBLED AWAY FROM IT.", vec2( 8, metrics.text_story_top + 48 ), timers.typewriter, 0.02 )
		},
		{
			TypeWriter:New( "BUT ONLY TO BE", vec2( 8, metrics.text_story_top ), timers.typewriter, 0.02 ),
			TypeWriter:New( "TRAPPED IN SPACE WARPED", vec2( 8, metrics.text_story_top + 16 ), timers.typewriter, 0.02 ),
			TypeWriter:New( "BY SOMEONE........", vec2( 8, metrics.text_story_top + 32 ), timers.typewriter, 0.02 ),
		}

	}
end

function Game.Update( dt )
	GetWindowPos()
	GetMouse()
	GameObject.UpdateAll( dt )
	UpdateBullets()

	if game_state == e_game_state.generate_level then
		GenerateLevel( level_idx )
		sounds.level_intro:stop()
		sounds.level_intro:play()
	elseif game_state == e_game_state.lost_life then
		if not sounds.lost_life:isPlaying() then
			life_bar.total = life_bar.total - 1

			local last_life_paddle = life_bar.objects[ #life_bar.objects ]
			table.remove( life_bar.objects, #life_bar.objects )
			if last_life_paddle then
				last_life_paddle:Destroy()
			end

			if life_bar.total == 0 then
				-- game_state = e_game_state.game_over
				game_state = e_game_state.game_over
				level_idx = 1
				game_state = e_game_state.main_screen
				game_objects = nil
				game_objects = {}
				-- NOTE need to reset everything
				return
			end

			game_state = e_game_state.level_intro
			balls[ 1 ].position.x = obj_paddle.position.x
			balls[ 1 ].position.y = obj_paddle.position.y - 8
			balls[ 1 ].sticky = true
			timers.balls[ 1 ]:Reset()
			obj_paddle:Destroy()
			obj_paddle = nil
			obj_paddle = GameObject:New( e_object_type.paddle, vec2( game_w / 2, metrics.paddle_y ), e_animation.paddle_appear )
			obj_paddle.prev_x = 0
			obj_paddle.can_shoot = false
			sounds.level_intro:stop()
			sounds.level_intro:play()
		end
	elseif game_state == e_game_state.level_intro then
		UpdatePaddle()
		UpdateBall( dt )

		if obj_paddle.animation_type == e_animation.paddle_appear and obj_paddle.animation:GetFrame() == 5 then
			obj_paddle:Destroy()
			obj_paddle = nil
			obj_paddle = GameObject:New( e_object_type.paddle, vec2( mouse.position.x, metrics.paddle_y ), e_animation.paddle_normal )
			obj_paddle.prev_x = 0
			obj_paddle.can_shoot = false
		end

		local duration = sounds.level_intro:getDuration( "frames" )
		if sounds.level_intro:tell( "frames" ) >= duration - 70000 then
			local idx = 0
			for i, v in ipairs( game_objects ) do
				if v.animation_type == e_animation.brick_silver or v.animation_type == e_animation.brick_gold then
					v.animation:SetPaused( false )
					idx = i
				end
			end

			if idx > 0 then
				if game_objects[ idx ].animation:GetFrame() == 6 then
					for i, v in ipairs( game_objects ) do
						if v.animation_type == e_animation.brick_silver or v.animation_type == e_animation.brick_gold then
							v.animation:SetFrame( 1 )
							v.animation:SetPaused( true )
						end
					end

					timers.balls[ 1 ]:Reset()
					game_state = e_game_state.play
				end
			else
				timers.balls[ 1 ]:Reset()
				game_state = e_game_state.play
			end
		end
	elseif game_state == e_game_state.play then
		UpdatePowerUp()

		if obj_paddle.begin_exit then
			obj_paddle.position.x = obj_paddle.position.x + 1
			local duration = sounds.escape_level:getDuration( "frames" )
			if sounds.escape_level:tell( "frames" ) >= duration - 70000 then
				level_idx = level_idx + 1
				game_state = e_game_state.generate_level
			end
		else
			UpdatePaddle()
			UpdateBall( dt )
		end

		if levels[ level_idx ].num_destroyable_bricks == 0 then
			level_idx = level_idx + 1
			game_state = e_game_state.generate_level
		end
	end
end

function Game.Draw( pass )
	local game_pass = lovr.graphics.getPass( "render", game_texture )
	game_pass:setProjection( 1, mat4():orthographic( game_pass:getDimensions() ) )
	game_pass:setSampler( sampler )

	GameObject.DrawAll( game_pass )
	DrawScreenText( game_pass )

	if WindowWasResized() then
		local ratio = 256 / 224 -- 1,142857142857143
		plane_w = window.w
		plane_h = window.h

		if (window.h / window.w) < ratio then
			plane_h = window.h
			plane_w = window.h / ratio
		elseif (window.h / window.w) > ratio then
			plane_w = window.w
			plane_h = window.w * ratio
		end
	end

	pass:setSampler( sampler )

	pass:setColor( 1, 1, 1 )
	pass:setMaterial( game_texture )
	pass:setProjection( 1, mat4():orthographic( pass:getDimensions() ) )
	pass:plane( window.w / 2, window.h / 2, 0, plane_w, -plane_h )

	local passes = {}
	table.insert( passes, game_pass )
	table.insert( passes, pass )
	return lovr.graphics.submit( passes )
end

return Game
