local Game = require "game"

function lovr.load()
	Game.Init()
end

function lovr.update( dt )
	Game.Update( dt )
end

function lovr.draw( pass )
	local game_pass = Game.Draw()

	-- pass:setProjection( 1, mat4():orthographic( pass:getDimensions() ) )
	pass:setSampler( sampler )
	pass:fill( game_texture )

	local passes = {}
	table.insert( passes, game_pass )
	table.insert( passes, pass )
	return lovr.graphics.submit( passes )
end
