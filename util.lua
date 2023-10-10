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
	typedef void(*GLFWmousebuttonfun)(GLFWwindow*, int, int, int);
	int glfwGetMouseButton(GLFWwindow* window, int button);
	GLFWmousebuttonfun glfwSetMouseButtonCallback(GLFWwindow* window, GLFWmousebuttonfun callback);
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

	if glfw.glfwGetMouseButton( game_handle, 0 ) > 0 then
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

function GetWindowScale()
	return (lovr.system.getWindowWidth() / 224)
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
