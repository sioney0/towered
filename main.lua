local Player = require('player')

function love.load()
    wf = require "libraries/windfield" 


    world = wf.newWorld(0, 250)
    world:addCollisionClass("Ground")
    ground = world:newRectangleCollider(100, 400, 600, 100)
    ground:setType('static')
    ground:setCollisionClass("Ground")

    player_one = Player:new(world, 100, 100, 100)
end

function love.update(dt)
    
    world:update(dt)

    player_one:update(dt)
end

function love.draw()
    world:draw()

    player_one:draw()

end


