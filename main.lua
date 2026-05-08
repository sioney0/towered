local world = love.physics.newWorld(0,0)


function love.load()
    player = {
        x = 200,
        y = 200
    }
    player.body = love.physics.newBody(world, player.x, player.y, "dynamic")


end


function love.update(dt)
    if love.keyboard.isDown("w") then 
        player.y = player.y - speed*dt
    end

    if love.keyboard.isDown("a") then 
        player.x = player.x - speed*dt
    end
    if love.keyboard.isDown("s") then 
        player.y = player.y + speed*dt
    end
    if love.keyboard.isDown("d") then 
        player.x = player.x + speed*dt
    end





end

function love.draw()

end