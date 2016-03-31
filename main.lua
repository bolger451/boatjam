debug = true

splashy = require 'libs/splashy'
gamestate = require 'libs/hump.gamestate'


-- Timers
-- We declare these here so we don't have to edit them multiple places
canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax
createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax

-- Player Object
player = { x = 10, y = 200, speed = 200, img = nil }
isAlive = true
enemy_counter = 100

-- Sound storage
sound = love.audio.newSource("gun.wav", "static")
music = love.audio.newSource("music.mp3","static")
sfx = love.audio.newSource("cheer.mp3","static")

-- Image Storage
bulletImg = nil
enemyImg = nil

-- Entity Storage
bullets = {} -- array of current bullets being drawn and updated
enemies = {} -- array of current enemies on screen

love.graphics.setBackgroundColor(0,100,255)
--music:play()
-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

-- Loading
function love.load(arg)
	--titlescreen = splashy.addSplash(love.graphics.newImage('title_screen2.jpg'))
	player.img = love.graphics.newImage('Cruiser.png')
	enemyImg = love.graphics.newImage('BattleShip.png')
	bulletImg = love.graphics.newImage('bullet.png')

	love.graphics.setFont(love.graphics.newFont(18))
	--titlescreen = love.graphics.newImage('title_screen2.jpg')
end


-- Updating
function love.update(dt)
	-- I always start with an easy way to exit the game
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end


	--splashy.update(dt)


	-- Time out how far apart our shots can be.
	canShootTimer = canShootTimer - (1 * dt)
	if canShootTimer < 0 then
		canShoot = true
	end

	-- Time out enemy creation
	createEnemyTimer = createEnemyTimer - (1 * dt)
	if createEnemyTimer < 0 then
		createEnemyTimer = createEnemyTimerMax

		-- Create an enemy
		randomNumber = math.random(10, love.graphics.getHeight() - 10)
		newEnemy = { x = love.graphics.getWidth() + 10, y = randomNumber, img = enemyImg }
		table.insert(enemies, newEnemy)
	end


	-- update the positions of bullets
	for i, bullet in ipairs(bullets) do
		bullet.x = bullet.x + (350 * dt)

		if bullet.x > love.graphics.getWidth() + 10 then -- remove bullets when they pass off the screen
			table.remove(bullets, i)
		end
	end

	-- update the positions of enemies
	for i, enemy in ipairs(enemies) do
		enemy.x = enemy.x - (600 * dt)

		if enemy.x < 0 then -- remove enemies when they pass off the screen
			table.remove(enemies, i)
		end
	end

	-- run our collision detection
	-- Since there will be fewer enemies on screen than bullets we'll loop them first
	-- Also, we need to see if the enemies hit our player
	for i, enemy in ipairs(enemies) do
		for j, bullet in ipairs(bullets) do
			if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
				table.remove(bullets, j)
				table.remove(enemies, i)
				if enemy_counter > 0 then
					enemy_counter = enemy_counter - 1
				end
			end
		end

		if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight())
		and isAlive then
			table.remove(enemies, i)
			isAlive = false
		end
	end


	if love.keyboard.isDown('left','a') then
		if player.x > 0 then -- binds us to the map
			player.x = player.x - (player.speed*dt)
		end
	elseif love.keyboard.isDown('right','d') then
		if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
			player.x = player.x + (player.speed*dt)
		end
	elseif love.keyboard.isDown('up','w') then
		if player.y > 0 then
			player.y = player.y - (player.speed*dt)
		end
	elseif love.keyboard.isDown('down','z')	then
		if player.y < (love.graphics.getHeight() - player.img:getHeight()) then
			player.y = player.y + (player.speed*dt)
		end
	end

	if love.keyboard.isDown('space', 'rctrl', 'lctrl', 'ctrl') and canShoot then
		-- Play that funky music, white boy
		sound:play()
		-- Create some bullets
		newBullet = { x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg }
		table.insert(bullets, newBullet)
		canShoot = false
		canShootTimer = canShootTimerMax
	end

	if not isAlive and love.keyboard.isDown('r') then
		-- remove all our bullets and enemies from screen
		bullets = {}
		enemies = {}

		-- reset timers
		canShootTimer = canShootTimerMax
		createEnemyTimer = createEnemyTimerMax

		-- move player back to default position
		player.x = 10
		player.y = 200

		-- reset our game state
		enemy_counter = 100
		isAlive = true
	end
end

-- Drawing
function love.draw(dt)
	--splashy.draw()

	for i, bullet in ipairs(bullets) do
		love.graphics.draw(bullet.img, bullet.x, bullet.y)
	end

	for i, enemy in ipairs(enemies) do
		love.graphics.draw(enemy.img, enemy.x, enemy.y)
	end

	love.graphics.setColor(255, 255, 255)
	love.graphics.print("Enemies Remaining: " .. tostring(enemy_counter), 400, 10)

	if isAlive then
		love.graphics.draw(player.img, player.x, player.y)
	else
		love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
	end

	if debug then
		fps = tostring(love.timer.getFPS())
		love.graphics.print("Current FPS: "..fps, 9, 10)
	end

	if enemy_counter == 0 then
			love.graphics.print([[
								You did it!
				At last you have finally become Sex Boat®]], love.graphics:getWidth()/2-250, love.graphics:getHeight()/2-50)
		enemy_counter = 0
		end

end





	--love.graphics.print("Score: ", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)


