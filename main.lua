function angleBetween(x1, x2, y1, y2)
  return math.atan2(y1 - y2, x1 - x2)
end

function distanceBetween(x1, y1, x2, y2)
  return math.sqrt((y2 - y1)^2 + (x2 - x1)^2)
end

function spawnZombie()
  zombie = {}
  zombie.x = math.random(0, love.graphics.getWidth())
  zombie.y = math.random(0, love.graphics.getHeight())
  zombie.speed = 1.5 * 60
  zombie.rotation = angleBetween(player.x, zombie.x, player.y, zombie.y)

  table.insert(zombies, zombie)
end

function love.load()
  sprites = {}
  sprites.player = love.graphics.newImage('sprites/player.png')
  sprites.zombie = love.graphics.newImage('sprites/zombie.png')
  sprites.bullet = love.graphics.newImage('sprites/bullet.png')
  sprites.background = love.graphics.newImage('sprites/background.png')

  player = {}
  player.x = love.graphics.getWidth()/2
  player.y = love.graphics.getHeight()/2
  player.speed = 2.5 * 60
  player.rotation = math.rad(270)

  zombies = {}
end

function love.update(dt)
  if love.keyboard.isDown('s') then
    player.y = player.y + player.speed * dt
  end
  if love.keyboard.isDown('w') then
    player.y = player.y - player.speed * dt
  end
  if love.keyboard.isDown('a') then
    player.x = player.x - player.speed * dt
  end
  if love.keyboard.isDown('d') then
    player.x = player.x + player.speed * dt
  end

  player.rotation = angleBetween(love.mouse.getX(), player.x, love.mouse.getY(), player.y)
  for i, zombie in ipairs(zombies) do
    zombie.rotation = angleBetween(player.x, zombie.x, player.y, zombie.y)
    zombie.x = zombie.x + math.cos(zombie.rotation) * zombie.speed * dt
    zombie.y = zombie.y + math.sin(zombie.rotation) * zombie.speed * dt

    if distanceBetween(zombie.x, zombie.y, player.x, player.y) < math.max(sprites.player:getWidth(), sprites.player:getHeight()) then
      for i, z in ipairs(zombies) do
        zombies[i] = nil
      end
    end
  end
end

function love.draw()
  love.graphics.draw(sprites.background, 0, 0)
  love.graphics.draw(sprites.player, player.x, player.y, player.rotation, 1, 1, sprites.player:getWidth()/2, sprites.player:getHeight()/2)

  for i, zombie in ipairs(zombies) do
    love.graphics.draw(sprites.zombie, zombie.x, zombie.y, zombie.rotation, 1, 1, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2)
  end
end

function love.keypressed(key, scancode, isrepeat)
  if key == 'space' then
    spawnZombie()
  end
end