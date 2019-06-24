function angleBetween(x1, x2, y1, y2)
  return math.atan2(y1 - y2, x1 - x2)
end

function distanceBetween(x1, y1, x2, y2)
  return math.sqrt((y2 - y1)^2 + (x2 - x1)^2)
end

function spawnZombie()
  local side = math.random(1, 4)
  zombie = {}

  if side == 1 then
    zombie.x = math.random(0, love.graphics.getWidth())
    zombie.y = -40
  elseif side == 2 then
    zombie.x = love.graphics.getWidth() + 40
    zombie.y = math.random(0, love.graphics.getHeight())
  elseif side == 3 then
    zombie.x = math.random(0, love.graphics.getWidth())
    zombie.y = love.graphics.getHeight() + 40
  else
    zombie.x = -40
    zombie.y = math.random(0, love.graphics.getHeight())
  end

  zombie.speed = 1.5 * 60
  zombie.rotation = angleBetween(player.x, zombie.x, player.y, zombie.y)
  zombie.dead = false

  table.insert(zombies, zombie)
end

function spawnBullet()
  bullet = {}
  bullet.x = player.x
  bullet.y = player.y
  bullet.speed = 5*60
  bullet.rotation = player.rotation
  bullet.dead = false

  table.insert(bullets, bullet)
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
  bullets = {}

  gameState = 1
  maxTime = 2
  timer = maxTime

  font = love.graphics.newFont(40)
  score = 0
end

function love.update(dt)
  if gameState == 2 then
    if love.keyboard.isDown('s') and player.y + player.speed * dt < love.graphics.getHeight() - sprites.player:getHeight()/2 then
      player.y = player.y + player.speed * dt
    end
    if love.keyboard.isDown('w') and player.y - player.speed * dt > sprites.player:getHeight()/2 then
      player.y = player.y - player.speed * dt
    end
    if love.keyboard.isDown('a') and player.x - player.speed * dt > sprites.player:getWidth()/2 then
      player.x = player.x - player.speed * dt
    end
    if love.keyboard.isDown('d') and player.x + player.speed * dt < love.graphics.getWidth() - sprites.player:getWidth()/2 then
      player.x = player.x + player.speed * dt
    end
  end

  player.rotation = angleBetween(love.mouse.getX(), player.x, love.mouse.getY(), player.y)

  for i = #bullets,1,-1 do
    local bullet = bullets[i]
    bullet.x = bullet.x + math.cos(bullet.rotation) * bullet.speed * dt
    bullet.y = bullet.y + math.sin(bullet.rotation) * bullet.speed * dt

    if bullet.x < 0 or bullet.x > love.graphics.getWidth() or bullet.y < 0 or bullet.y > love.graphics.getHeight() then
      table.remove(bullets, i)
    end
  end

  for i, zombie in ipairs(zombies) do
    zombie.rotation = angleBetween(player.x, zombie.x, player.y, zombie.y)
    zombie.x = zombie.x + math.cos(zombie.rotation) * zombie.speed * dt
    zombie.y = zombie.y + math.sin(zombie.rotation) * zombie.speed * dt

    if distanceBetween(zombie.x, zombie.y, player.x, player.y) < math.max(sprites.player:getWidth(), sprites.player:getHeight()) then
      endGame()
    end
  end

  for i,z in ipairs(zombies) do
    for j, b in ipairs(bullets) do
      if distanceBetween(z.x, z.y, b.x, b.y) < math.max(sprites.zombie:getWidth(), sprites.zombie:getHeight()) then
        z.dead = true
        b.dead = true
        score = score + 1
      end
    end
  end

  for i=#zombies, 1, -1 do
    local zombie = zombies[i]
    if zombie.dead then table.remove(zombies, i) end
  end

  for i=#bullets, 1, -1 do
    local bullet = bullets[i]
    if bullet.dead then table.remove(bullets, i) end
  end

  if gameState == 2 then
    timer = timer - dt
    if timer <= 0 then
      spawnZombie()
      maxTime = maxTime * 0.95
      timer = maxTime
    end
  end
end

function love.draw()
  love.graphics.draw(sprites.background, 0, 0)

  if gameState == 1 then
    love.graphics.setFont(font)
    love.graphics.printf('Click anywhere to begin', 0, 0, love.graphics.getWidth(), 'center')
  end

  love.graphics.printf('Score: ' .. score, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), 'center')

  love.graphics.draw(sprites.player, player.x, player.y, player.rotation, 1, 1, sprites.player:getWidth()/2, sprites.player:getHeight()/2)

  for i, zombie in ipairs(zombies) do
    love.graphics.draw(sprites.zombie, zombie.x, zombie.y, zombie.rotation, 1, 1, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2)
  end

  for i, bullet in ipairs(bullets) do
    love.graphics.draw(sprites.bullet, bullet.x, bullet.y, bullet.rotation, 0.5, 0.5, sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
  end
end

function love.keypressed(key, scancode, isrepeat)
  if key == 'space' then
    spawnZombie()
  end
end

function love.mousepressed(x, y, btn)
  if btn == 1 and gameState == 1 then
    gameState = 2
    maxTime = 2
    timer = maxTime
    score = 0
  end
  
  if btn == 1 and gameState == 2 then
    spawnBullet()
  end
end

function endGame()
  for i in ipairs(zombies) do
    zombies[i] = nil
  end
  for i in ipairs(bullets) do
    bullets[i] = nil
  end
  gameState = 1
  player.x = love.graphics.getWidth()/2
  player.y = love.graphics.getHeight()/2
end