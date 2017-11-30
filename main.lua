-- utils
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
function DIV(a,b)
    return (a - a % b) / b
end
-- end utils

function love.load()
	menu_bg = love.graphics.newImage('gfx/bg/menu.jpg')
	menu_music = love.audio.newSource('music/menu.ogg')
	font = love.graphics.newFont('Avara.ttf', 40)
	love.graphics.setFont(font)
	
    -- global ingame vars
	menu = 1
	menu_items = {}
	menu_items[1] = 'Rymyämään ->'
	menu_items[2] = 'Nukkumaan -.-'
	menuchoice = 1
	loading = 0
	game = 0
	intermission = 0
	generateTileProperties()
	tile_size = 20
	
	--tiles
	loadTileResource()
	loadActorImages()
	
	--audio
	loadJukeboxSongs()
	
	--player
	playerCreate()
	
	--actorbase
	actors = {}
	
	--do init stuff
	gamePreload()
end

function loadTileResource()
	tiles = {}
	resource = love.graphics.newImage('gfx/Assetit.png')
	
	tiles['wall_updown'] = love.graphics.newQuad(0,20,20,20,resource:getDimensions())
	tiles['wall_leftright'] = love.graphics.newQuad(20,20,20,20,resource:getDimensions())
	tiles['door_leftright'] = love.graphics.newQuad(40,20,20,20,resource:getDimensions())
	tiles['door_updown'] = love.graphics.newQuad(60,20,20,20,resource:getDimensions())
	tiles['wall_corner_nw'] = love.graphics.newQuad(0,40,20,20,resource:getDimensions())
	tiles['wall_corner_sw'] = love.graphics.newQuad(0,60,20,20,resource:getDimensions())
	tiles['wall_corner_ne'] = love.graphics.newQuad(20,40,20,20,resource:getDimensions())
	tiles['wall_corner_se'] = love.graphics.newQuad(20,60,20,20,resource:getDimensions())
	tiles['floor_wood'] = love.graphics.newQuad(60,60,20,20,resource:getDimensions())
	tiles['floor_cement'] = love.graphics.newQuad(40,60,20,20,resource:getDimensions())
	tiles['cmt'] = love.graphics.newQuad(40,60,20,20,resource:getDimensions())
	tiles['cmt_old'] = love.graphics.newImage('gfx/cmt.png')
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
	
	actors_images['lisko'] = love.graphics.newQuad(40,0,20,20, resource:getDimensions())
	actors_images['lisko_2'] = love.graphics.newQuad(60,0,20,20, resource:getDimensions())
	actors_images['demon'] = love.graphics.newQuad(60,40,20,20, resource:getDimensions())
	
	-- neutral
	actors_images['light'] = love.graphics.newQuad(40,40,20,20,resource:getDimensions())
end

function handleActors()
	for i=1, tablelength(actors) do
		runActorLogic(i)
	end
end

function createNewActor(of_type, coord_x, coord_y, weight)
	new_index = tablelength(actors) + 1
	actors[new_index] = {}
	actors[new_index]['type'] = of_type
	actors[new_index]['x'] = coord_x
	actors[new_index]['y'] = coord_y
	actors[new_index]['visual_x'] = coord_x * tile_size
	actors[new_index]['visual_y'] = coord_y * tile_size
	actors[new_index]['moving'] = 0
	actors[new_index]['weight'] = weight
end

function runActorLogic(actor)
	--provide with index
	
	--lisko: sprawl around randomly!
	if actors[actor]['type'] == 'lisko' then
		dir = love.math.random(5)
		if dir == 1 then
			actor_move(actor, actors[actor]['x']-1, actors[actor]['y'])
		elseif dir == 2 then
			actor_move(actor, actors[actor]['x']+1, actors[actor]['y'])
		elseif dir == 3 then
			actor_move(actor, actors[actor]['x'], actors[actor]['y']-1)
		elseif dir == 4 then
			actor_move(actor, actors[actor]['x'], actors[actor]['y']+1)
		elseif dir == 5 then
		end
		actors[actor]['moving'] = actors[actor]['moving'] - 1
	end
	if actors[actor]['type'] == 'demon' then
		-- demon glides around
		dir_x = love.math.random(-5, 5)
		dir_y = love.math.random(-5, 5)
		
		actor_move(actor, actors[actor]['x'] + dir_x, actors[actor]['y'] + dir_y)
		
		actors[actor]['moving'] = actors[actor]['moving'] - 1
	end

end

function playerCreate()
	player = {}
	player['x'] = 1
	player['y'] = 16
	player['visual_x'] = 1 * tile_size
	player['visual_y'] = 16 * tile_size
	player['moving'] = 0
	player['weight'] = 10
	player['image'] = love.graphics.newImage('gfx/deeku.png')
	player['arrival'] = 'left'
	
	player['frames'] = {}
	--directional frames player
	player['frames']['down'] = {}
	player['frames']['down'][1] = love.graphics.newQuad(0,0,20,20, player['image']:getDimensions())
	player['frames']['down'][2] = love.graphics.newQuad(20,0,20,20, player['image']:getDimensions())
	player['frames']['up'] = {}
	player['frames']['up'][1] = love.graphics.newQuad(0,60,20,20, player['image']:getDimensions())
	player['frames']['up'][2] = love.graphics.newQuad(20,60,20,20, player['image']:getDimensions())
	player['frames']['left'] = {}
	player['frames']['left'][1] = love.graphics.newQuad(0,40,20,20, player['image']:getDimensions())
	player['frames']['left'][2] = love.graphics.newQuad(20,40,20,20, player['image']:getDimensions())
	player['frames']['right'] = {}
	player['frames']['right'][1] = love.graphics.newQuad(0,20,20,20, player['image']:getDimensions())
	player['frames']['right'][2] = love.graphics.newQuad(20,20,20,20, player['image']:getDimensions())
	player['direction'] = 'down'
	player['activeFrame'] = 1
end

function playerArrive()
	if player['arrival'] == 'left' then
		player['x'] = 1
		player['visual_x'] = 1 * tile_size
	elseif player['arrival'] == 'right' then
		player['x'] = tablelength(start_map)
		player['visual_x'] = 32 * tile_size
	elseif player['arrival'] == 'up' then
		player['y'] = 1
		player['visual_y'] = 1 * tile_size
	elseif player['arrival'] == 'down' then
		player['y'] = tablelength(start_map[1]) --todo: fix map variable name
		player['visual_y'] = tablelength(start_map[1]) * tile_size
	end
end

function actorGeneration()
	-- call this after player is about to enter new map!
	-- empty actors list and generate it again
	actors = {}
	-- a certain amount of liskos from 1 to promille_factor...
	liskos = love.math.random(100)
	demonis = love.math.random(10)
	for i=1, liskos do
		createNewActor('lisko', love.math.random(24),love.math.random(12), 25)
	end
	for i=1, demonis do
		createNewActor('demon', love.math.random(24),love.math.random(12), 50)
	end
end

function generateMap()
	-- generate a map randomly.
	tile_type = love.math.random(100)
	-- todo: base types affect algorithms and map layouts
	if tile_type < 50 then
		base_type = 'cmt'
	else
		base_type = 'floor_wood'
	end
	
	map = {}
	-- todo: maybe use short codes or smth to represent tile types...
	for x=1, 32 do
		map[x] = {}
		for y=1, 16 do
			map[x][y] = base_type
		end
	end
	
	-- roll algorithms based on logic
	-- buildings etc.
	if base_type == 'cmt' then
		-- outside cement world: generate a certain amount of houses of certain sizes
		house_amounts = love.math.random(10)
		if house_amounts > 1 then
			for i=1, house_amounts do
				houseAlgorithm()
			end
		end
	end
	
	--close off 1-2 map borders with walls. never close arrival direction
	closed = love.math.random(2)
	for i=1, closed do
		dir = love.math.random(4)
		if dir == 1 and player['arrival'] ~= 'left' then
			--left side
			for y=1, tablelength(map[1]) do
				map[1][y] = 'wall_updown'
			end
		end
		if dir == 2 and player['arrival'] ~= 'right' then
			--right side
			for y=1, tablelength(map[tablelength(map)]) do
				map[tablelength(map)][y] = 'wall_updown'
			end
		end
		if dir == 3 and player['arrival'] ~= 'up' then
			--top
			for x=1, tablelength(map) do
				map[x][1] = 'wall_leftright'
			end
		end
		if dir == 4 and player['arrival'] ~= 'down' then
			--bottom
			for x=1, tablelength(map) do
				map[x][tablelength(map[1])] = 'wall_leftright'
			end
		end
	end
	
	return map
end

function houseAlgorithm()
	-- generate a house with a random size. Keep calling itself until successful.
	
	-- find start point that is empty space not in a corner. Check that start coords + size is not bigger than map...
	-- and is not overlapping with something else, like another house.
	-- todo: make a metamap that keeps track of what has been inserted where
	
	-- start point
	start_x = love.math.random(32)
	start_y = love.math.random(16)
	
	-- size from 4 to 8
	size_x = love.math.random(4,8)
	size_y = love.math.random(4,8)

	for x=1, tablelength(map) do
		if start_x + size_x > tablelength(map) then
			houseAlgorithm()
		end
		for y=1, tablelength(map[x]) do
			if start_y + size_y > tablelength(map[x]) then
				houseAlgorithm()
			end
		end
	end
	
	if start_x ~= 1 and start_x ~= 32 then
		if start_y ~= 1 and start_y ~= 16 then
			if tile_attrs[map[start_x][start_y]] ~= 'IMPASSABLE' then
				
				
				-- create wooden floor
				for x=0, size_x do
					for y=0, size_y do
						map[start_x+x][start_y+y] = 'floor_wood'
					end
				end
				
				-- create walls
				-- top
				for x=0, size_x do
					if x == 0 then
						map[start_x][start_y] = 'wall_corner_nw'
					else
						map[start_x+x][start_y] = 'wall_leftright'
					end
				end
				--left
				for y=0, size_y do
					if y == 0 then
						map[start_x][start_y] = 'wall_corner_nw'
					else
						map[start_x][start_y+y] = 'wall_updown'
					end
				end
				--right
				for y=0, size_y do
					if y == 0 then
						map[start_x+size_x][start_y] = 'wall_corner_ne'
					else
						map[start_x+size_x][start_y+y] = 'wall_updown'
					end
				end
				--bottom + door
				doorspot = DIV(size_x, 2)
				for x=0, size_x do
					if x == 0 then
						map[start_x][start_y+size_y] = 'wall_corner_sw'
					elseif x == doorspot then
						map[start_x+doorspot][start_y+size_y] = 'door_leftright'
					elseif x == size_x then
						map[start_x+size_x][start_y+size_y] = 'wall_corner_se'
					else
						map[start_x+x][start_y+size_y] = 'wall_leftright'
					end
				end
				
			end
		else
			houseAlgorithm()
		end
	else
		houseAlgorithm()
	end
end

function drawSector(matrix)
	-- draw a sector upon which körsy walketh. 20x20 tiles.
	for x=1, table.getn(matrix) do
		for y=1, table.getn(matrix[x]) do
			
			tile_type = map[x][y]
			love.graphics.draw(resource, tiles[tile_type], x * tile_size, y * tile_size)
		end
	end
end

function genericControls()
	--these controls apply everywhere
	--quit
	if love.keyboard.isDown('escape') then
		love.event.quit()
	end
end

function menuJukebox()
	menu_music:play()
	menu_music:setLooping(true)
end

function gameJukebox()
	-- disable menu music if playing
	if menu_music:isPlaying() == true then
		menu_music:stop()
	end
	
	ended = true
	
	-- dont do anything while any jukebox or event song is playing
	for i=1, tablelength(jukebox) do
		if jukebox[i]:isPlaying() == true then
			ended = false
		end
	end
	if ended == true then
		shuffle = love.math.random(tablelength(jukebox))
		jukebox[shuffle]:play()
	end
end

function handleMenu()
	menuJukebox()
	genericControls()
	if love.keyboard.isDown('down') then
		menuchoice = menuchoice + 1
	elseif love.keyboard.isDown('up') then
		menuchoice = menuchoice - 1
	end
	if menuchoice > table.getn(menu_items) then
		menuchoice = table.getn(menu_items)
	elseif menuchoice < 1 then
		menuchoice = 1
	end
	if love.keyboard.isDown('return') then
		if menuchoice == 1 then
			game = 1
			menu = 0
		elseif menuchoice == 2 then
			love.event.quit()
		end
	end
end

function gamePreload()
	start_map = generateMap()
	actorGeneration()
end

function player_move(coord_x, coord_y, map)
	-- check where player is about to move, allow or disallow move based on that and resolve effects
	-- apply speed / delay factor to movement
	-- can be used for teleport
	
	-- are we still moving?
	if player['moving'] < 1 then
	
		-- are we inside bounds?
		if coord_x > 0 and coord_x <= tablelength(map) then
			
			for x=1, tablelength(map) do
				if coord_y > 0 and coord_y <= tablelength(map[x]) then
	
					-- tile in question can be moved on?
					if tile_attrs[map[coord_x][coord_y]] == nil then
						-- move. set us on path
						player['moving'] = 10
						player['x'] = coord_x
						player['y'] = coord_y
						player['activeFrame'] = 2
					end
				elseif coord_y > tablelength(map[x]) and player['arrival'] ~= 'down' then
					player['arrival'] = 'up'
					intermission = 1
				elseif coord_y < 1 and player['arrival'] ~= 'up' then
					player['arrival'] = 'down'
					intermission = 1
				end

			end
		-- arrival direction determiningin, always trigger intermission
		elseif coord_x > tablelength(map) and player['arrival'] ~= 'right' then
			player['arrival'] = 'left'
			intermission = 1
		elseif coord_x < 1 and player['arrival'] ~= 'left' then
			player['arrival'] = 'right'
			intermission = 1
		end
	end
end

function actor_move(actor, coord_x, coord_y)
	-- mostly same as player, except for targeted actor (target with index)
	
	-- are we still moving?
	if actors[actor]['moving'] < 1 then
	
		-- are we inside bounds?
		if coord_x > 0 and coord_x <= tablelength(map) then
			
			for x=1, tablelength(map) do
				if coord_y > 0 and coord_y <= tablelength(map[x]) then
	
					-- tile in question can be moved on?
					if tile_attrs[map[coord_x][coord_y]] == nil then
						-- move. set it on path
						actors[actor]['moving'] = actors[actor]['weight']
						actors[actor]['x'] = coord_x
						actors[actor]['y'] = coord_y
					end
				end

			end
			
		end
	end
end

--main game loop
function handleGame()
	--not loading a new area
	if intermission == 0 then
		genericControls()
		gameJukebox()
		handleActors()
		if love.keyboard.isDown('down') then
			player_move(player['x'], player['y'] + 1, start_map)
			player['direction'] = 'down'
		elseif love.keyboard.isDown('up') then
			player_move(player['x'], player['y'] - 1, start_map)
			player['direction'] = 'up'
		elseif love.keyboard.isDown('left') then
			player_move(player['x'] - 1, player['y'], start_map)
			player['direction'] = 'left'
		elseif love.keyboard.isDown('right') then
			player_move(player['x'] + 1, player['y'], start_map)
			player['direction'] = 'right'
		end
		player['moving'] = player['moving'] - 1
	--loading a new area
	else
		start_map = generateMap() --todo: change map variable name
		actorGeneration()
		playerArrive()
		intermission = 0
	end
end

function drawMenu()
	menu_base_pos = {}
	menu_base_pos['x'] = 450
	menu_base_pos['y'] = 200
	love.graphics.draw(menu_bg, 0, 0)
	for i=1, tablelength(menu_items) do
		coord_y = menu_base_pos['y'] + (i * 100)
		love.graphics.print(menu_items[i], menu_base_pos['x'], coord_y) 
	end
	love.graphics.print('->', menu_base_pos['x'] - 50, menu_base_pos['y'] + (menuchoice * 100))
end

function drawActors()
	for i=1, tablelength(actors) do
		love.graphics.draw(resource, actors_images[actors[i]['type']], actors[i]['visual_x'], actors[i]['visual_y'])
		if actors[i]['visual_x'] < actors[i]['x'] * tile_size then
			actors[i]['visual_x'] = actors[i]['visual_x'] + 2
		end
		if actors[i]['visual_x'] > actors[i]['x'] * tile_size then
			actors[i]['visual_x'] = actors[i]['visual_x'] - 2
		end
		if actors[i]['visual_y'] < actors[i]['y'] * tile_size then
			actors[i]['visual_y'] = actors[i]['visual_y'] + 2
		end
		if actors[i]['visual_y'] > actors[i]['y'] * tile_size then
			actors[i]['visual_y'] = actors[i]['visual_y'] - 2
		end
	end
end

function drawGame()
	if intermission == 0 then
		drawSector(start_map)
		if player['visual_x'] < player['x'] * tile_size then
			player['visual_x'] = player['visual_x'] + 2
		end
		if player['visual_x'] > player['x'] * tile_size then
			player['visual_x'] = player['visual_x'] - 2
		end
		if player['visual_y'] < player['y'] * tile_size then
			player['visual_y'] = player['visual_y'] + 2
		end
		if player['visual_y'] > player['y'] * tile_size then
			player['visual_y'] = player['visual_y'] - 2
		end
		if player['moving'] < 0 then
			player['activeFrame'] = 1
		end
		drawActors()
		direction = player['direction']
		activeFrame = player['activeFrame']
		love.graphics.draw(player['image'], player['frames'][direction][activeFrame], player['visual_x'], player['visual_y'])
	end
end

function love.draw()
	if menu == 1 then
		drawMenu()
	end
	if game == 1 then
		drawGame()
	end
end

function love.update(dt)
	if menu == 1 then
		handleMenu()
	else
		handleGame()
	end
	
end