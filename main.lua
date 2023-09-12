local Game = require "game"

function lovr.load()
	Game.Init()
end

function lovr.update( dt )
	Game.Update( dt )
end

function lovr.draw( pass )
	Game.Draw( pass )
end
