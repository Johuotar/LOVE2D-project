--[[
Functions for loading and handling assets, such as gfx, sfx and music.
--]]

function preloadGraphicsResources()
  -- preload for handling all graphics resource files.
  resource = love.graphics.newImage('gfx/Static_shit.png')
  dynamics_resource = love.graphics.newImage('gfx/CharacterSheet.png')
end

function loadTileResource()
	tiles = {}

	tiles['wall_updown'] = love.graphics.newQuad(32,32,32,32,resource:getDimensions())
	tiles['wall_leftright'] = love.graphics.newQuad(0,32,32,32,resource:getDimensions())
	tiles['door_leftright'] = love.graphics.newQuad(352,32,32,32,resource:getDimensions())
	tiles['door_updown'] = love.graphics.newQuad(320,32,32,32,resource:getDimensions())
	tiles['wall_corner_nw'] = love.graphics.newQuad(128,32,32,32,resource:getDimensions())
	tiles['wall_corner_sw'] = love.graphics.newQuad(160,32,32,32,resource:getDimensions())
	tiles['wall_corner_ne'] = love.graphics.newQuad(96,32,32,32,resource:getDimensions())
	tiles['wall_corner_se'] = love.graphics.newQuad(64,32,32,32,resource:getDimensions())
	tiles['floor_wood'] = love.graphics.newQuad(32,0,32,32,resource:getDimensions())
	tiles['floor_cement'] = love.graphics.newQuad(0,0,32,32,resource:getDimensions())
	tiles['cmt'] = love.graphics.newQuad(0,0,32,32,resource:getDimensions())
end

function generateTileProperties()
	-- if a tile is not named here, it means the tile has no property and is considered WALKABLE.
	tile_attrs = {}
	tile_attrs['wall_updown'] = 'IMPASSABLE'
	tile_attrs['wall_leftright'] = 'IMPASSABLE'
	tile_attrs['wall_corner_ne'] = 'IMPASSABLE'
	tile_attrs['wall_corner_nw'] = 'IMPASSABLE'
	tile_attrs['wall_corner_se'] = 'IMPASSABLE'
	tile_attrs['wall_corner_sw'] = 'IMPASSABLE'
end

function loadJukeboxSongs()
	-- todo: something to read contents of jukebox directory
	jukebox = {}

	jukebox[1] = love.audio.newSource('music/jukebox/sharkest.ogg')
	jukebox[2] = love.audio.newSource('music/jukebox/urut.ogg')
end

function loadActorImages()
	actors_images = {}

  -- START FRAMES FROM 1!!!
  actors_images['lisko'] = {}
	actors_images['lisko'][1] = love.graphics.newQuad(0,160,32,32, dynamics_resource:getDimensions())
	actors_images['lisko'][2] = love.graphics.newQuad(32,160,32,32, dynamics_resource:getDimensions())
  
  actors_images['demon'] = {}
	actors_images['demon'][1] = love.graphics.newQuad(0,192,32,32, dynamics_resource:getDimensions())
  actors_images['demon'][2] = love.graphics.newQuad(32,192,32,32, dynamics_resource:getDimensions())

	-- neutral
	-- actors_images['light'] = love.graphics.newQuad(40,40,20,20,resource:getDimensions())
end

function loadProjectileImages()
	projectile_images = {}

	-- todo: use quads
	projectile_images['puke'] = love.graphics.newQuad(0,224,32,32, dynamics_resource:getDimensions())
end
