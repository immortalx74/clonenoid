local GameObject = require "gameobject"
local Animation = require "animation"
local io = require "io"
local ffi = require "ffi"
local glfw = ffi.load( "glfw3" )

ffi.cdef( [[
	enum {
		GLFW_RESIZABLE = 0x00020003,
		GLFW_VISIBLE = 0x00020004,
		GLFW_DECORATED = 0x00020005,
		GLFW_FLOATING = 0x00020007
	};

	typedef int BOOL;
	typedef long LONG;

	typedef struct{
		LONG x, y;
	}POINT, *LPPOINT;

	BOOL GetCursorPos(LPPOINT);

	typedef struct GLFWvidmode {
		int width;
		int height;
		int refreshRate;
	} GLFWvidmode;

	typedef struct GLFWwindow GLFWwindow;
	GLFWwindow* os_get_glfw_window(void);
	void glfwGetWindowPos(GLFWwindow* window, int *xpos, int *ypos);
	void glfwSetInputMode(GLFWwindow * window, int GLFW_CURSOR, int GLFW_CURSOR_HIDDEN);
]] )
GLFW_CURSOR        = 0x00033001
GLFW_CURSOR_HIDDEN = 0x00034002

local e_game_state = {
	play = 1,
	generate_level = 2
}

e_object_type      = {
	paddle = 1,
	enemy = 2,
	decorative = 3,
	brick = 4,
	ball = 5,
	powerup = 6
}

e_orientation      = {
	horizontal = 1,
	vertical = 2
}

e_animation        = {
	bg = 1,
	bar_v = 2,
	paddle_normal = 3,
	paddle_big = 4,
	brick_colored = 5,
	brick_silver = 6,
	brick_gold = 7,
	ball = 8,
	bar_h_l = 9,
	bar_h_r = 10,
	powerup_b = 11,
	powerup_c = 12,
	powerup_d = 13,
	powerup_e = 14,
	powerup_l = 15,
	powerup_p = 16,
	powerup_s = 17,
}

local Game         = {}

brick_type         = {
	[ "w" ] = { anim = e_animation.brick_colored, frame = 1 },
	[ "o" ] = { anim = e_animation.brick_colored, frame = 2 },
	[ "c" ] = { anim = e_animation.brick_colored, frame = 3 },
	[ "g" ] = { anim = e_animation.brick_colored, frame = 4 },
	[ "r" ] = { anim = e_animation.brick_colored, frame = 5 },
	[ "b" ] = { anim = e_animation.brick_colored, frame = 6 },
	[ "p" ] = { anim = e_animation.brick_colored, frame = 7 },
	[ "y" ] = { anim = e_animation.brick_colored, frame = 8 },
	[ "s" ] = { anim = e_animation.brick_silver, frame = 1 },
	[ "$" ] = { anim = e_animation.brick_gold, frame = 1 }
}

metrics            = {
	bg_left = 112,
	bg_top = 140,
	bar_h_l_left = 56,
	bar_h_l_top = 20,
	bar_h_r_left = 168,
	bar_h_r_top = 20,
	bar_v_l_left = 4,
	bar_v_l_top = 140,
	bar_v_r_left = 220,
	bar_v_r_top = 140,
	wall_start_left = 16,
	wall_start_top = 28,
	wall_columns = 13,
	brick_w = 16,
	brick_h = 8,
	paddle_y = 236,
	paddle_constrain_left = 24,
	paddle_constrain_right = 200,
	ball_constrain_left = 10,
	ball_constrain_right = 214,
	ball_constrain_top = 24
}

levels             = {}
backgrounds        = {}
textures           = {}
animations         = {}
window             = { w = 224, h = 256, x = 0, y = 0, handle = nil }
game_texture       = lovr.graphics.newTexture( window.w, window.h, { usage = { "sample", "render" }, mipmaps = false } )

game_state         = e_game_state.generate_level
level_idx          = 1
sampler            = lovr.graphics.newSampler( { filter = 'nearest' } )
obj_paddle         = nil
obj_ball           = nil
obj_gate           = nil
balls              = {}
powerup            = { current = nil, dropping = nil, last_time = 0, interval = math.random( 4, 7 ) }

function Split( input )
	local stripped = input:gsub( "[\r\n,]", "" ) -- Remove newlines and commas
	local characters = {}

	for char in stripped:gmatch( "." ) do
		table.insert( characters, char )
	end

	return characters
end

local function LoadLevels()
	local files = lovr.filesystem.getDirectoryItems( "res/levels" )

	for i, v in ipairs( files ) do
		local str = lovr.filesystem.read( "res/levels/" .. i .. ".csv" )
		table.insert( levels, Split( str ) )
	end
end

local function LoadTextures()
	textures.bg = lovr.graphics.newTexture( "res/sprites/bg.png" )
	textures.bar_v = lovr.graphics.newTexture( "res/sprites/bar_v.png" )

	textures.bar_h_l = lovr.graphics.newTexture( "res/sprites/bar_h_l.png" )
	textures.bar_h_r = lovr.graphics.newTexture( "res/sprites/bar_h_r.png" )

	textures.paddle_normal = lovr.graphics.newTexture( "res/sprites/paddle_normal.png" )
	textures.paddle_big = lovr.graphics.newTexture( "res/sprites/paddle_big.png" )

	textures.powerup_break = lovr.graphics.newTexture( "res/sprites/powerup_b.png" )
	textures.powerup_laser = lovr.graphics.newTexture( "res/sprites/powerup_l.png" )
	textures.powerup_enlarge = lovr.graphics.newTexture( "res/sprites/powerup_e.png" )
	textures.powerup_catch = lovr.graphics.newTexture( "res/sprites/powerup_c.png" )
	textures.powerup_slow = lovr.graphics.newTexture( "res/sprites/powerup_s.png" )
	textures.powerup_disruption = lovr.graphics.newTexture( "res/sprites/powerup_d.png" )
	textures.powerup_player = lovr.graphics.newTexture( "res/sprites/powerup_p.png" )
	textures.powerup_shadow = lovr.graphics.newTexture( "res/sprites/powerup_shadow.png" )

	textures.bricks = lovr.graphics.newTexture( "res/sprites/bricks.png" )
	textures.brick_silver = lovr.graphics.newTexture( "res/sprites/brick_silver.png" )
	textures.brick_gold = lovr.graphics.newTexture( "res/sprites/brick_gold.png" )

	textures.ball = lovr.graphics.newTexture( "res/sprites/ball.png" )
end

local function GenerateLevel( idx )
	local bg = GameObject:New( e_object_type.decorative, vec2( metrics.bg_left, metrics.bg_top ), e_animation.bg )
	bg.animation:SetFrame( level_idx % 4 )
	bg.animation:SetPaused( true )

	local bhl = GameObject:New( e_object_type.decorative, vec2( metrics.bar_h_l_left, metrics.bar_h_l_top ), e_animation.bar_h_l )
	bhl.animation:SetFrame( 1 )
	bhl.animation:SetPaused( true )
	local bhr = GameObject:New( e_object_type.decorative, vec2( metrics.bar_h_r_left, metrics.bar_h_r_top ), e_animation.bar_h_r )
	bhr.animation:SetFrame( 1 )
	bhr.animation:SetPaused( true )

	local bvl = GameObject:New( e_object_type.decorative, vec2( metrics.bar_v_l_left, metrics.bar_v_l_top ), e_animation.bar_v )
	bvl.animation:SetFrame( 1 )
	bvl.animation:SetPaused( true )
	obj_gate = GameObject:New( e_object_type.decorative, vec2( metrics.bar_v_r_left, metrics.bar_v_r_top ), e_animation.bar_v )
	obj_gate.animation:SetFrame( 1 )
	obj_gate.animation:SetPaused( true )

	local level = levels[ level_idx ]

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

			x = x + metrics.brick_w
		end
	end

	obj_paddle = GameObject:New( e_object_type.paddle, vec2( window.w / 2, metrics.paddle_y ), e_animation.paddle_normal )
	obj_paddle.prev_x = 0

	balls = {}
	local b = GameObject:New( e_object_type.ball, vec2( 100, 180 ), e_animation.ball )
	b.velocity_x = 2
	b.velocity_y = 2
	table.insert( balls, b )

	powerup.last_time = lovr.timer.getTime()

	game_state = e_game_state.play
end

function Game.Init()
	lovr.graphics.setBackgroundColor( 0, 0, 0 )
	LoadLevels()
	LoadTextures()

	window.handle = ffi.C.os_get_glfw_window()
	glfw.glfwSetInputMode( window.handle, GLFW_CURSOR, GLFW_CURSOR_HIDDEN )
	math.randomseed( os.time() )
end

function Game.Update( dt )
	local wx, wy = ffi.new( 'int[1]' ), ffi.new( 'int[1]' )
	glfw.glfwGetWindowPos( window.handle, wx, wy )
	window.x = wx[ 0 ]
	window.y = wy[ 0 ]

	local mouse_pos = ffi.new( "POINT[1]" )
	ffi.C.GetCursorPos( mouse_pos )
	local scale = lovr.system.getWindowWidth() / 224

	GameObject.UpdateAll( dt )

	if game_state == e_game_state.generate_level then
		GenerateLevel( level_idx )
	elseif game_state == e_game_state.play then
		-- Powerup position
		if powerup.dropping then
			powerup.dropping.position.y = powerup.dropping.position.y + 1
			if powerup.dropping.position.y > window.h then
				powerup.dropping:Destroy()
				powerup.dropping = nil
				powerup.last_time = lovr.timer.getTime()
			end

			-- Powerup -> paddle collision
			if powerup.dropping.position.x > obj_paddle.position.x - 16 and powerup.dropping.position.x < obj_paddle.position.x + 16 then
				if powerup.dropping.position.y > obj_paddle.position.y - 4 then
					powerup.current = powerup.dropping
					-- TODO: handle what to do when catching powerup
					powerup.dropping:Destroy()
					powerup.dropping = nil
					powerup.last_time = lovr.timer.getTime()
				end
			end
		end

		-- Paddle position
		obj_paddle.position.x = (mouse_pos[ 0 ].x / scale) - (window.x / scale)

		if obj_paddle.position.x < metrics.paddle_constrain_left then
			obj_paddle.position.x = metrics.paddle_constrain_left
		end

		if obj_paddle.position.x > metrics.paddle_constrain_right then
			obj_paddle.position.x = metrics.paddle_constrain_right
		end

		-- Ball[s] position
		for i = 1, #balls do
			balls[ i ].position.x = balls[ i ].position.x + balls[ i ].velocity_x
			balls[ i ].position.y = balls[ i ].position.y + balls[ i ].velocity_y

			if balls[ i ].position.x < metrics.ball_constrain_left then
				balls[ i ].position.x = metrics.ball_constrain_left
				balls[ i ].velocity_x = -balls[ i ].velocity_x
			end

			if balls[ i ].position.x > metrics.ball_constrain_right then
				balls[ i ].position.x = metrics.ball_constrain_right
				balls[ i ].velocity_x = -balls[ i ].velocity_x
			end

			if balls[ i ].position.y < metrics.ball_constrain_top then
				balls[ i ].position.y = metrics.ball_constrain_top
				balls[ i ].velocity_y = -balls[ i ].velocity_y
			end

			-- NOTE: bounces on floor
			if balls[ i ].position.y > window.h then
				balls[ i ].position.y = window.h
				balls[ i ].velocity_y = -balls[ i ].velocity_y
			end

			-- Ball -> paddle collision
			if balls[ i ].position.x > obj_paddle.position.x - 16 and balls[ i ].position.x < obj_paddle.position.x + 16 then
				if balls[ i ].position.y > obj_paddle.position.y - 4 then
					balls[ i ].velocity_y = -balls[ i ].velocity_y

					local dir = 0

					if obj_paddle.position.x > obj_paddle.prev_x then
						dir = 1
					end

					if obj_paddle.position.x < obj_paddle.prev_x then
						dir = -1
					end

					if balls[ i ].position.x > obj_paddle.position.x + 6 then
						-- right
						balls[ i ].velocity_x = balls[ i ].velocity_x + 0.5
					elseif balls[ i ].position.x < obj_paddle.position.x - 6 then
						-- left
						balls[ i ].velocity_x = balls[ i ].velocity_x - 0.5
					else
						-- middle
						local sign = 1
						if balls[ i ].velocity_x < 0 then sign = -1 end
						balls[ i ].velocity_x = 2 * sign
					end
				end
			end

			local xx = balls[ i ].position.x
			local yy = balls[ i ].position.y

			-- Bricks collision
			for j, v in ipairs( game_objects ) do
				if v.type == e_object_type.brick then
					local l = v.position.x - 8
					local r = v.position.x + 8
					local t = v.position.y - 4
					local b = v.position.y + 4

					if xx > l and xx < r and yy > t and yy < b then
						balls[ i ].velocity_y = -balls[ i ].velocity_y

						-- Drop random powerup
						if not powerup.dropping and lovr.timer.getTime() - powerup.last_time > powerup.interval then
							powerup.dropping = GameObject:New( e_object_type.powerup, vec2( v.position.x, v.position.y ), math.random( e_animation.powerup_b, e_animation.powerup_s ) )
						end

						table.remove( game_objects, j )
					end
				end
			end
		end

		obj_paddle.prev_x = obj_paddle.position.x
	end
end

function Game.Draw()
	local game_pass = lovr.graphics.getPass( "render", game_texture )
	game_pass:setProjection( 1, mat4():orthographic( game_pass:getDimensions() ) )
	game_pass:setSampler( sampler )

	if game_state == e_game_state.play then
		GameObject.DrawAll( game_pass )
	end

	return game_pass
end

return Game
