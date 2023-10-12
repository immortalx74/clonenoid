ffi = require "ffi"
glfw = ffi.load( "glfw3" )
local GameObject = require "gameobject"

ffi.cdef( [[
	enum {
		GLFW_RESIZABLE = 0x00020003,
		GLFW_VISIBLE = 0x00020004,
		GLFW_DECORATED = 0x00020005,
		GLFW_FLOATING = 0x00020007
	};

	typedef struct GLFWvidmode {
		int width;
		int height;
		int refreshRate;
	} GLFWvidmode;

	typedef struct GLFWwindow GLFWwindow;
	GLFWwindow* os_get_glfw_window(void);
	void glfwGetWindowPos(GLFWwindow* window, int *xpos, int *ypos);
	void glfwSetInputMode(GLFWwindow * window, int GLFW_CURSOR, int GLFW_CURSOR_HIDDEN);
	void glfwGetCursorPos(GLFWwindow *window, double *xpos, double *ypos); 	
]] )
GLFW_CURSOR        = 0x00033001
GLFW_CURSOR_HIDDEN = 0x00034002

function Split( input )
	local stripped = input:gsub( "[\r\n,]", "" ) -- Remove newlines and commas
	local characters = {}

	for char in stripped:gmatch( "." ) do
		table.insert( characters, char )
	end

	return characters
end

function GetMouse()
	local mx = ffi.new( "double[1]" )
	local my = ffi.new( "double[1]" )

	glfw.glfwGetCursorPos( game_handle, mx, my )
	mouse.position.x = mx[ 0 ]
	mouse.position.y = my[ 0 ]

	if lovr.system.isMouseDown( 1 ) then
		if mouse.prev_frame == 0 then
			mouse.prev_frame = 1
			mouse.this_frame = 1
		else
			mouse.prev_frame = 1
			mouse.this_frame = 0
		end
	else
		mouse.prev_frame = 0
	end
end

function GetWindowPos()
	local wx, wy = ffi.new( 'int[1]' ), ffi.new( 'int[1]' )
	glfw.glfwGetWindowPos( game_handle, wx, wy )
	window.x = wx[ 0 ]
	window.y = wy[ 0 ]
end

function IsMouseDown()
	if mouse.this_frame == 1 and mouse.prev_frame == 1 then
		return true
	end
	return false
end

function RectToRect( rect1, rect2 )
	local left1 = rect1.l
	local right1 = rect1.r
	local top1 = rect1.t
	local bottom1 = rect1.b

	local left2 = rect2.l
	local right2 = rect2.r
	local top2 = rect2.t
	local bottom2 = rect2.b

	if right1 < left2 or left1 > right2 or bottom1 < top2 or top1 > bottom2 then
		return false
	end

	return true
end

function lovr.keypressed( key, scancode, repeating )
	if game_state == e_game_state.main_screen then
		if key == "space" then
			obj_arkanoid_logo:Destroy()
			obj_arkanoid_logo = nil
			obj_taito_logo:Destroy()
			obj_taito_logo = nil
			GameObject:New( e_object_type.decorative, vec2( game_w / 2, game_h / 2 ), e_animation.starfield )
			obj_mothership = GameObject:New( e_object_type.decorative, vec2( game_w / 2, metrics.mothership_top ), e_animation.mothership )
			sounds.mothership_intro:stop()
			sounds.mothership_intro:play()
			timers.typewriter:Reset()
			game_state = e_game_state.story
		end
	end

	if game_state == e_game_state.play then
		if key == "return" then
			level_idx = level_idx + 1
			game_state = e_game_state.generate_level
		end
	end
end

function WindowWasResized()
	local w, h = lovr.system.getWindowDimensions()
	if w ~= window.w or h ~= window.h then
		window.w = w
		window.h = h
		return true
	end

	return false
end

function ConstrainToPlayArea( ball_idx )
	if balls[ ball_idx ].position.x < metrics.ball_constrain_left then
		balls[ ball_idx ].position.x = metrics.ball_constrain_left
		balls[ ball_idx ].velocity.x = -balls[ ball_idx ].velocity.x
	end

	if balls[ ball_idx ].position.x > metrics.ball_constrain_right then
		balls[ ball_idx ].position.x = metrics.ball_constrain_right
		balls[ ball_idx ].velocity.x = -balls[ ball_idx ].velocity.x
	end

	if balls[ ball_idx ].position.y < metrics.ball_constrain_top then
		balls[ ball_idx ].position.y = metrics.ball_constrain_top
		balls[ ball_idx ].velocity.y = -balls[ ball_idx ].velocity.y
	end

	if balls[ ball_idx ].position.y > game_h then
		balls[ ball_idx ].position.y = game_h
		balls[ ball_idx ].velocity.y = -balls[ ball_idx ].velocity.y
	end
end

function BallToPaddleCollision( ball_idx )
	local half_size = 16
	if obj_paddle.animation_type == e_animation.paddle_big then
		half_size = 24
	end

	if balls[ ball_idx ].position.x > obj_paddle.position.x - half_size and balls[ ball_idx ].position.x < obj_paddle.position.x + half_size then
		if balls[ ball_idx ].position.y > obj_paddle.position.y - 4 then
			if powerup.current and powerup.current.animation_type == e_animation.powerup_c then
				balls[ ball_idx ].sticky = true
				balls[ ball_idx ].sticky_offset = obj_paddle.position.x - balls[ ball_idx ].position.x
				timers.balls[ ball_idx ]:Reset()
			else
				balls[ ball_idx ].velocity.y = -balls[ ball_idx ].velocity.y
				sounds.ball_to_paddle:stop()
				sounds.ball_to_paddle:play()
			end
		end
	end
end
