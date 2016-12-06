function love.load()
	love.window.setMode(1000, 1000, { resizable = true, msaa = 0, vsync = false })
	--[[
	CHANGES:
	-Fixed moving system, no longer sucks
	-Added parallax
	-Cleaned up code
	-Another batch of optimizations and bugfixes
	-Removed a lot of files no longer used
	]]--
	STOPVEL = 0.1
	_G.world = love.physics.newWorld(0, 0, true)
	curmap = "map2"
	MAPDATA = require(curmap..".mapdata")
	CHARACTERS = require("characters.default")
	WEAPONS = require("weapons.default")
	MODS = require("mods.default")
	PLAYERDATA = require("loadstats")
	DEFAULTS = require("objdef")
	RANK = 1
	LEVEL = 1
	PARALLAX = 0.2

	debugval = 0

	--Load character
	player = {
		body = love.physics.newBody(_G.world, 500, 500, "dynamic"),
		shape = love.physics.newCircleShape(45),
		weapons = {}
	}
	function loadCharacter()
		player.character = DEFAULTS.character
		for k, v in pairs(CHARACTERS[PLAYERDATA.character]) do
			player.character[k] = v
		end
		if PLAYERDATA.weapons.primary ~= nil then
			player.weapons.primary = DEFAULTS.weapon
			for k, v in pairs(WEAPONS[PLAYERDATA.weapons.primary]) do
				player.weapons.primary[k] = v
			end
		end
		if PLAYERDATA.weapons.secondary ~= nil then
			player.weapons.secondary = DEFAULTS.weapon
			for k, v in pairs(WEAPONS[PLAYERDATA.weapons.secondary]) do
				player.weapons.secondary[k] = v
			end
		end
		if PLAYERDATA.weapons.special ~= nil then
			player.weapons.special = DEFAULTS.weapon
			for k, v in pairs(WEAPONS[PLAYERDATA.weapons.special]) do
				player.weapons.special[k] = v
			end
		end
		local addstats = player
		for k, v in pairs(PLAYERDATA.mods) do
			local mod = MODS[v]
			if mod.kind == "character" then
				for k2, v2 in pairs(mod.stats) do
					if v2.method == "mult" then
						player[k2] = player[k2] + addstats[k2] * (v2.perlv + v2.perrank * RANK) * LEVEL
					elseif v2.method == "add" then
						player[k2] = player[k2] + addstats[k2] + (v2.perlv + v2.perrank * RANK) * LEVEL
					end
				end
			elseif mod.kind == "weapon" then
				for k2, v2 in pairs(mod.stats) do
					if v2.method == "mult" then
						player[k2] = player[k2] + addstats[k2] * (v2.perlv + v2.perrank * RANK) * LEVEL
					elseif v2.method == "add" then
						player[k2] = player[k2] + addstats[k2] + (v2.perlv + v2.perrank * RANK) * LEVEL
					end
				end
			end
		end
	end
	loadCharacter()
	love.physics.setMeter(15)

	map = {}
	--Load map tiles into map table
	for i = 0, 9 do
		map[i] = {}
		for  n = 0, 9 do
			map[i][n] = love.graphics.newImage("map2/map2-0"..tostring(n).."-0"..tostring(i)..".png")
		end
	end

	function checkForStop(Body)
		local xlvel, ylvel = Body:getLinearVelocity()
		if math.abs(xlvel) < STOPVEL and math.abs(ylvel) < STOPVEL and math.abs(Body:getAngularVelocity()) < STOPVEL then
			Body:setAwake(false)
		end
	end

	function loadMap(String)
		curmap = String
		MAPDATA = require(curmap..".mapdata")
		map = {}
		for k, v in pairs(MAPDATA.tiles) do
			map[k] = {}
			for k2, v2 in pairs(v) do
				map[k][k2] = love.grapgics.newImage(curmap.."/"..v2..".png")
			end
		end
		player.body:setPosition(MAPDATA.data.spawnpoint.x, MAPDATA.data.spawnpoint.y)
		for k, v in pairs(objects) do
			v.body:destroy()
		end
		objects = MAPDATA.objects
		for k, object in pairs(objects) do
			object.fixture = love.physics.newFixture(object.body, object.shape, object.mass)
			object.body:setLinearDamping(object.linearDamping)
			object.body:setAngularDamping(object.angularDamping)
		end
	end

	objects = MAPDATA.objects
	for k, object in pairs(objects) do
		object.fixture = love.physics.newFixture(object.body, object.shape, object.mass)
		object.body:setLinearDamping(object.linearDamping)
		object.body:setAngularDamping(object.angularDamping)
	end

	player.fixture = love.physics.newFixture(player.body, player.shape, 0.25)
	posx, posy = 0, 0
	wX, wY = love.window.getMode()
	wXh, wYh = wX / 2, wY / 2
	mapTileResolution = 500
	mapTileHalf = mapTileResolution / 2
	mapTileRenderDistX = wXh
	mapTileRenderDistY = wYh
	physicsRate = 1 / 60
	Dtt = 0
	love.graphics.setNewFont(72)
	love.keyboard.setKeyRepeat(true)

	--Subtracts current x and y values from an indefinite amount of tuples
	function subtractPos(Tbl)
		local argtype = "x"
		local returntbl = {}
		for k, v in ipairs(Tbl) do
			if argtype == "x" then
				returntbl[#returntbl + 1] = v - posx
				argtype = "y"
			else
				returntbl[#returntbl + 1] = v - posy
				argtype = "x"
			end
		end
		return unpack(returntbl)
	end
	--Calculates if map tile is on screen
	function isNear(X, Y)
		if X > posx + mapTileRenderDistX or X < posx - mapTileRenderDistX - mapTileResolution or Y > posy + mapTileRenderDistY or Y < posy - mapTileRenderDistY - mapTileResolution then
			return false
		else
			return true
		end
	end
end

function love.draw()
	posx, posy = player.body:getPosition()
	posx, posy = posx + (love.mouse.getX() - wXh) * PARALLAX, posy + (love.mouse.getY() - wYh) * PARALLAX
	love.graphics.translate(wXh, wYh)
	for k, v in pairs(map) do
		for k2, v2 in pairs(v) do
			local imgx, imgy = k2 * mapTileResolution, k * mapTileResolution
			if isNear(imgx, imgy) then
				love.graphics.draw(v2, imgx - posx, imgy - posy)
			end
		end
	end
	love.graphics.setColor(0, 255, 0)
	love.graphics.print(love.timer.getFPS(), -wXh, -wYh, 0, 0.25)
	love.graphics.setColor(193, 47, 14)
	love.graphics.circle("fill", player.body:getX() - posx, player.body:getY() - posy, player.shape:getRadius())
	for name, object in pairs(objects) do
		if object.shape:getType() == "polygon" then
			local polytbl = { object.body:getWorldPoints(object.shape:getPoints()) }
			love.graphics.setColor(object.color)
			love.graphics.polygon(object.drawmode, subtractPos(polytbl))
		elseif object.shape:getType() == "circle" then
			love.graphics.setColor(object.color)
			love.graphics.circle(object.drawmode, object.body:getX() - posx, object.body:getY() - posy, object.shape:getRadius())
		elseif object.shape:getType() == "edge" then
			love.graphics.setColor(object.color)
			local polytbl = { object.body:getWorldPoints(object.shape:getPoints()) }
			love.graphics.line(subtractPos(polytbl))
		end
	end
	love.graphics.setColor(255, 255, 255)
	local stats = love.graphics.getStats()
	print(stats.drawcalls, stats.texturememory / 1024 / 1024)
end

function love.resize(Nx, Ny)
	wX, wY = Nx, Ny
	wXh, wYh = wX / 2, wY / 2
	mapTileRenderDistX = wXh
	mapTileRenderDistY = wYh
end

function love.update(Dt)
	_G.world:update(Dt)
	for k, object in pairs(objects) do
		if object.body:isAwake() then
			checkForStop(object.body)
		end
	end
	mvx, mvy = 0, 0
	if love.keyboard.isDown("w") then
		mvy = -player.character.movespeed
	elseif love.keyboard.isDown("s") then
		mvy = player.character.movespeed
	end
	if love.keyboard.isDown("a") then
		mvx = -player.character.movespeed
	elseif love.keyboard.isDown("d") then
		mvx = player.character.movespeed
	end
	player.body:setLinearVelocity(mvx, mvy)
end

function love.keypressed(Key, Scancode, Repeat)
	if Key == "`" then
		local cmd, rest = string.match(io.read(), "(%S+) (.*)")
		if cmd == "setpos" then
			local param1, param2, param3 = string.match(rest, "(%S+) (%S+) (%S+)")
			if param1 == "self" then
				player.body:setPosition(param2, param3)
			else
				objects[param1].body:setPosition(param2, param3)
			end
		elseif cmd == "getpos" then
			local param1 = string.match(rest, "(%S+)")
			if param1 == "self" then
				print(player.body:getPosition())
			else
				print(objects[param1].body:getPosition())
			end
		elseif cmd == "getvel" then
			local param1 = string.match(rest, "(%S+)")
			if param1 == "self" then
				print(player.body:getLinearVelocity())
			else
				print(objects[param1].body:getLinearVelocity())
			end
		elseif cmd == "setvel" then
			local param1, param2, param3 = string.match(rest, "(%S+) (%S+) (%S+)")
			if param1 == "self" then
				player.body:setLinearVelocity(param2, param3)
			else
				objects[param1].body:setLinearVelocity(param2, param3)
			end
		end
	end
end
