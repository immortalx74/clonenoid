function LoadLevels()
	local files = lovr.filesystem.getDirectoryItems( "res/levels" )

	for i, v in ipairs( files ) do
		local str = lovr.filesystem.read( "res/levels/" .. i .. ".csv" )
		table.insert( levels, Split( str ) )
	end
end

function LoadTextures()
	textures.bg = lovr.graphics.newTexture( "res/sprites/bg.png" )
	textures.starfield = lovr.graphics.newTexture( "res/sprites/starfield.png" )
	textures.arkanoid_logo = lovr.graphics.newTexture( "res/sprites/arkanoid_logo.png" )
	textures.taito_logo = lovr.graphics.newTexture( "res/sprites/taito_logo.png" )
	textures.life = lovr.graphics.newTexture( "res/sprites/life.png" )
	textures.mothership = lovr.graphics.newTexture( "res/sprites/mothership.png" )

	textures.bar_v_closed = lovr.graphics.newTexture( "res/sprites/bar_v_closed.png" )
	textures.bar_v_opening = lovr.graphics.newTexture( "res/sprites/bar_v_opening.png" )
	textures.bar_v_open = lovr.graphics.newTexture( "res/sprites/bar_v_open.png" )

	textures.bar_h_l = lovr.graphics.newTexture( "res/sprites/bar_h_l.png" )
	textures.bar_h_r = lovr.graphics.newTexture( "res/sprites/bar_h_r.png" )

	textures.paddle_normal = lovr.graphics.newTexture( "res/sprites/paddle_normal.png" )
	textures.paddle_big = lovr.graphics.newTexture( "res/sprites/paddle_big.png" )
	textures.paddle_laser = lovr.graphics.newTexture( "res/sprites/paddle_laser.png" )
	textures.paddle_appear = lovr.graphics.newTexture( "res/sprites/paddle_appear.png" )

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

	textures.laser = lovr.graphics.newTexture( "res/sprites/laser.png" )
end

function LoadSounds()
	sounds.ball_brick_destroy = lovr.audio.newSource( "res/sounds/ball_brick_destroy.wav" )
	sounds.ball_brick_ding = lovr.audio.newSource( "res/sounds/ball_brick_ding.wav" )
	sounds.ball_to_paddle = lovr.audio.newSource( "res/sounds/ball_to_paddle.wav" )
	sounds.ball_to_paddle_stick = lovr.audio.newSource( "res/sounds/ball_to_paddle_stick.wav" )
	sounds.enemy_destroy = lovr.audio.newSource( "res/sounds/enemy_destroy.wav" )
	sounds.got_life = lovr.audio.newSource( "res/sounds/got_life.wav" )
	sounds.laser_shoot = lovr.audio.newSource( "res/sounds/laser_shoot.wav" )
	sounds.level_intro = lovr.audio.newSource( "res/sounds/level_intro.wav" )
	sounds.paddle_turn_big = lovr.audio.newSource( "res/sounds/paddle_turn_big.wav" )
	sounds.escape_level = lovr.audio.newSource( "res/sounds/escape_level.wav" )
	sounds.mothership_intro = lovr.audio.newSource( "res/sounds/mothership_intro.wav" )
	sounds.paddle_away = lovr.audio.newSource( "res/sounds/paddle_away.wav" )
	sounds.lost_life = lovr.audio.newSource( "res/sounds/lost_life.wav" )
end