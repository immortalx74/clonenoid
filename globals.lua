e_game_state  = {
	play = 1,
	generate_level = 2,
	level_intro = 3,
	main_screen = 4,
	story = 5
}

e_object_type = {
	paddle = 1,
	enemy = 2,
	decorative = 3,
	brick = 4,
	ball = 5,
	powerup = 6,
	laser = 7
}

e_orientation = {
	horizontal = 1,
	vertical = 2
}

e_animation   = {
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
	bar_v_closed = 18,
	bar_v_opening = 19,
	bar_v_open = 20,
	life = 21,
	laser = 22,
	paddle_laser = 23,
	arkanoid_logo = 24,
	taito_logo = 25,
	mothership = 26,
	starfield = 27
}

brick_type    = {
	[ "w" ] = { anim = e_animation.brick_colored, frame = 1, points = 50 },
	[ "o" ] = { anim = e_animation.brick_colored, frame = 2, points = 60 },
	[ "c" ] = { anim = e_animation.brick_colored, frame = 3, points = 70 },
	[ "g" ] = { anim = e_animation.brick_colored, frame = 4, points = 80 },
	[ "r" ] = { anim = e_animation.brick_colored, frame = 5, points = 90 },
	[ "b" ] = { anim = e_animation.brick_colored, frame = 6, points = 100 },
	[ "p" ] = { anim = e_animation.brick_colored, frame = 7, points = 110 },
	[ "y" ] = { anim = e_animation.brick_colored, frame = 8, points = 120 },
	[ "s" ] = { anim = e_animation.brick_silver, frame = 1, points = 1 },
	[ "$" ] = { anim = e_animation.brick_gold, frame = 1, points = 0 }
}

metrics       = {
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
	paddle_constrain_left_normal = 24,
	paddle_constrain_right_normal = 200,
	paddle_constrain_left_big = 32,
	paddle_constrain_right_big = 192,
	ball_constrain_left = 10,
	ball_constrain_right = 214,
	ball_constrain_top = 24,
	life_bar_left = 16,
	life_bar_top = 252,
	text_high_score_string_left = 112,
	text_high_score_string_top = 4,
	text_high_score_left = 112,
	text_high_score_top = 12,
	text_1up_left = 36,
	text_1up_top = 4,
	text_score_left = 48,
	text_score_top = 12,
	text_level_intro_top = 180,
	arkanoid_logo_top = 70,
	taito_logo_top = 185,
	text_copyright_top = 208,
	text_main_screen_msg = 112,
	mothership_top = 196,
	text_story_top = 26
}

levels        = {}
backgrounds   = {}
textures      = {}
animations    = {}
window        = { w = 224, h = 256, x = 0, y = 0, handle = nil }
game_w        = 224
game_h        = 256
plane_w       = window.w
plane_h       = window.h
game_texture  = lovr.graphics.newTexture( game_w, game_h, { usage = { "sample", "render" }, mipmaps = false } )

game_state    = e_game_state.generate_level
level_idx     = 1
sampler       = lovr.graphics.newSampler( { filter = 'nearest' } )
obj_paddle    = nil
obj_ball      = nil
obj_gate      = nil
balls         = {}
powerup       = { current = nil, dropping = nil, interval = math.random( 4, 7 ), type = nil }
mouse         = { position = lovr.math.newVec2( 0, 0 ), prev_frame = 0, this_frame = 0 }
life_bar      = { total = 3, objects = {}, max = 6 }
rasterizer    = lovr.data.newRasterizer( "res/font/PressStart2P-Regular.ttf", 8 )
font          = lovr.graphics.newFont( rasterizer )
scores        = { high = 50000, player = 0 }
bullets       = {}
timers        = {}
sounds        = {}
story_text    = {}
level_bricks = {}
