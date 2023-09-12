local GameObject = require "gameobject"
local Animation = require "animation"

local e_game_state = {
	play = 1
}

e_object_type = {
	paddle = 1,
	enemy = 2
}

e_orientation = {
	horizontal = 1,
	vertical = 2
}

local Game = {}

levels = {}
backgrounds = {}
textures = {}
animations = {}

game_state = e_game_state.play
cur_level = 1
sampler = lovr.graphics.newSampler( { filter = 'nearest' } )

local function Split( str, delimiter )
	local result = {}
	for part in str:gmatch( "[^" .. delimiter .. "]+" ) do
		result[ #result + 1 ] = part
	end
	return result
end

local function LoadLevels()
	local files = lovr.filesystem.getDirectoryItems( "res/levels" )

	for i, v in ipairs( files ) do
		local str = lovr.filesystem.read( "res/levels/" .. i .. ".csv" )
		table.insert( levels, Split( str, "," ) )
	end
end

local function LoadBackgrounds()
	local files = lovr.filesystem.getDirectoryItems( "res/backgrounds" )
	for i, v in ipairs( files ) do
		local bg = lovr.graphics.newTexture( "res/backgrounds/" .. i .. ".png" )
		table.insert( backgrounds, bg )
	end
end

local function LoadTextures()
	textures.bar_h = lovr.graphics.newTexture( "res/sprites/bar_h.png" )
	textures.bar_v = lovr.graphics.newTexture( "res/sprites/bar_v.png" )
	textures.paddle_normal = lovr.graphics.newTexture( "res/sprites/paddle_normal.png" )
	textures.paddle_big = lovr.graphics.newTexture( "res/sprites/paddle_big.png" )

	textures.powerup_laser = lovr.graphics.newTexture( "res/sprites/powerup_l.png" )
	textures.powerup_enlarge = lovr.graphics.newTexture( "res/sprites/powerup_e.png" )
	textures.powerup_catch = lovr.graphics.newTexture( "res/sprites/powerup_c.png" )
	textures.powerup_slow = lovr.graphics.newTexture( "res/sprites/powerup_s.png" )
	textures.powerup_disruption = lovr.graphics.newTexture( "res/sprites/powerup_d.png" )
	textures.powerup_player = lovr.graphics.newTexture( "res/sprites/powerup_p.png" )
	textures.powerup_shadow = lovr.graphics.newTexture( "res/sprites/powerup_shadow.png" )
end

local function CreateAnimations()
	animations.bar_h = Animation:New( 1, vec2( 224, 8 ), textures.bar_h, 1, e_orientation.horizontal )
	animations.bar_v = Animation:New( 1, vec2( 8, 200 ), textures.bar_v, 1, e_orientation.vertical )
	animations.paddle_normal = Animation:New( 20, vec2( 32, 8 ), textures.paddle_normal, 6, e_orientation.vertical )
	animations.paddle_big = Animation:New( 20, vec2( 48, 8 ), textures.paddle_big, 6, e_orientation.vertical )

	animations.powerup_laser = Animation:New( 3, vec2( 16, 8 ), textures.powerup_laser, 8, e_orientation.horizontal )
	animations.powerup_enlarge = Animation:New( 3, vec2( 16, 8 ), textures.powerup_enlarge, 8, e_orientation.horizontal )
	animations.powerup_catch = Animation:New( 3, vec2( 16, 8 ), textures.powerup_catch, 8, e_orientation.horizontal )
	animations.powerup_slow = Animation:New( 3, vec2( 16, 8 ), textures.powerup_slow, 8, e_orientation.horizontal )
	animations.powerup_disruption = Animation:New( 3, vec2( 16, 8 ), textures.powerup_disruption, 8, e_orientation.horizontal )
	animations.powerup_player = Animation:New( 3, vec2( 16, 8 ), textures.powerup_player, 8, e_orientation.horizontal )
	animations.powerup_shadow = Animation:New( 3, vec2( 16, 8 ), textures.powerup_shadow, 8, e_orientation.horizontal )
end

function Game.Init()
	lovr.graphics.setBackgroundColor( 0.3, 0.3, 0.8 )
	LoadLevels()
	LoadBackgrounds()
	LoadTextures()
	CreateAnimations()
	
	go1 = GameObject:New( e_object_type.enemy, vec2( (224 * 4) / 2, 20 ), animations.bar_h )
	go2 = GameObject:New( e_object_type.enemy, vec2( 100, (232 * 4) / 2 ), animations.bar_v )
	go3 = GameObject:New( e_object_type.enemy, vec2( 200, (232 * 4) / 2 ), animations.powerup_laser )
	go4 = GameObject:New( e_object_type.enemy, vec2( 400, (232 * 4) / 2 ), animations.paddle_normal )
end

function Game.Update( dt )
	go1:Update( dt )
	go2:Update( dt )
	go3:Update( dt )
	go4:Update( dt )
end

function Game.Draw( pass )
	pass:setProjection( 1, mat4():orthographic( pass:getDimensions() ) )
	if game_state == e_game_state.play then
		pass:setSampler( sampler )
		go1:Draw( pass )
		go2:Draw( pass )
		go3:Draw( pass )
		go4:Draw( pass )
	end
end

return Game
