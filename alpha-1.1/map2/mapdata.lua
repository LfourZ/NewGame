local M = {}

--This is tutorial on how to create a mapdata file
--All data is stored as a lua table, so if there are any issues, you can look it up
--For now though, a basic rundown: (Starting at '--' and ending at the end of the line, code is commented and not counted)

--'M' is the root table, defined as an empty table at the top of the file

M.objects = {--Here I created a table within the root table called 'objects' this table MUST be called objects
	wall = {--Here I create another table witin 'objects', note the new line and indentation
		body = love.physics.newBody(_G.world, 500, 500, "dynamic"),--Here is my first actual item in the table
		--body = something means that the item is called "body". If I had used bob = something, that would have been the name
		--Note the comma at the end of the line - this means that there is another item in this table.
		shape = love.physics.newRectangleShape(200, 200),--Again, a comma to indicate more item(s) to come
		color = { 200, 200, 200 },--Another comma
		drawmode = "fill",--Another comma
		renderdist = 100,--Another comma
		render = true,--Another comma
		angularDamping = 1,
		linearDamping = 1,
		mass = 0.01--No comma! This is of course because it is the last item in the table 'wall'
	},--And again another comma - thiis is because the table is also considered an item, and isn't the last thing
	--in the table 'objects'

	--Google 'Lua tables' for more information on the syntax - highly reccommended

	--Now that you know how to make tables, here is how to create an object:
	leftwall = {--This is the name of the object. Try to give it a descriptive name
		body = love.physics.newBody(_G.world, 1, 1081, "static"), --Here we define the object body.
		--'World' means that physics will be applied according to the world 'world', you don't need to worry about this
		--'1' and '1081' refer to the centroid of the object. This doesn't apply to all shapes, however
		--'static' means that is is a static physics object. There are three types of objects:
			--static: Has infinite mass, does not move
			--dynamic: Collides with every type of object, can move
			--kinematic: Only collides with dynamic objects
		shape = love.physics.newRectangleShape(2, 1838),--This line creates a shape object, in this case a rectangle
		--'2' and '1838' define the total width and height of the object.
		color = { 0, 0, 0, 0 },--This is the color, R, G, B and A (alpha) seperated by commas. The alpha value defines
		--the opacity, 255 for fully visible and 0 for fully invisible. You can leave the alpha value out if it is 255
		--(You should also try to not use any value other than 0 and 255 when not needed - much harder to render)
		drawmode = "line",--Polygons and circles can be rendered in two seperate ways:
			--line: renders outline
			--fill: renders full object
		renderdist = 1000,--This has not been implemented yet, but it is the distance from which the centroid is visible
		--This should generally be set to half the highest width or height, whatever is higher
		render = false,--This should be set to false if the alpha channel is equal to zero. Stops object from being rendered
		--whatsoever
		angularDamping = 2,
		linearDamping = 2,
		mass = 10--This doesn't do anything since this is a static body, but I have been setting static objects' mass to 10
	},
	topwall = {
		body = love.physics.newBody(_G.world, 0, 0, "static"),--Since this is an edge shape (see line below), it's center is
		--actually the first segment
		shape = love.physics.newEdgeShape(0, 0, 5000, 0),--An edge is defined by x1, y1, x2, y2. So this edge goes from
		--(0, 0) to (5000, 0). This is actually the whole top edge of the map, as the map starts at 0, 0 and goes
		--right (higher x) and down (higher y)
		color = { 0, 0, 255 },--Note how I didn't include the apha channel
		renderdist = 0,
		render = false,--This is a map border, I don't want to render that
		angularDamping = 2,
		linearDamping = 2,
		mass = 10
	}
}

M.data = {--This stuff is still in development
	spawnpoint = { x = 0, y = 0 },
	tileres = 500,
	music = {
		"test.mp3"
	}
}

M.tiles = {
	{
		"1st row, 1st item",
		"1st row, 2nd item"
	},
	{
		"2nd row, 1st item",
		"2nd row, 2nd item"
	}
}

return M
