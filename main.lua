local Player = require('player')

function love.load()
    wf = require "libraries/windfield" 


    world = wf.newWorld(0, 600)
    world:addCollisionClass("Ground")
    ground = world:newRectangleCollider(100, 400, 600, 100)
    ground:setType('static')
    ground:setCollisionClass("Ground")
    world:addCollisionClass("Player")
    
    player_one = Player:new(world, 100, 100, 100, 1)
    player_two = Player:new(world, 200, 200, 100, 2)
    love.graphics.setBackgroundColor(0, 1, 0)

    platform1 = love.graphics.newImage('/sprites/Platform1.png')


end

function love.update(dt)
    
    world:update(dt)

    player_one:update(dt, world, player_two)
    player_two:update(dt, world, player_one)
end

function love.draw()
    world:draw()

    player_one:draw()
    player_two:draw()

    love.graphics.draw(platform1, 100, 400, 0, 12, 6)
end


