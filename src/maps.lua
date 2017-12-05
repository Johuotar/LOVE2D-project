--[[
Functions for generating the maps and housing within the maps.
--]]

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
