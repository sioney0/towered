local Player = require('player')

function love.load()
    love.window.setMode(1280, 720)
    bigFont = love.graphics.newFont(48)
    wf = require "libraries/windfield" 
    sti = require "libraries/sti"
    camera = require "libraries/camera"

    cam = camera()
    anim8 = require "libraries/anim8"
    world = wf.newWorld(0, 800)
    world:addCollisionClass("Ground")

    ground = world:newRectangleCollider(100, 400, 600, 100)
    ground:setType('static')
    ground:setCollisionClass("Ground")
    world:addCollisionClass("Player")

    gameMap = sti("maps/map14.lua")
    fog = {}
    
    fog.spriteSheet = love.graphics.newImage('/sprites/fog2.png')
    fog.grid = anim8.newGrid(
        320,
        32,
        fog.spriteSheet:getWidth(),
        fog.spriteSheet:getHeight()
    )
    fog.animation = {}
    fog.animation.move = anim8.newAnimation(fog.grid(1, '2-4'),0.3)

    fog.x = 0
    fog.y = 620

     -- create colliders from Tiled object layer
    platforms = {}
    if gameMap.layers["Collisions"] then
        for i, obj in pairs(gameMap.layers["Collisions"].objects) do
            
    
            local collider = world:newRectangleCollider(
                obj.x,
                obj.y - obj.height,
                obj.width,
                obj.height
            )
            collider:setType("static")
            collider:setCollisionClass("Ground")
         

            table.insert(platforms, obj)
        end
    end

    player_one = Player:new(world, 100, 100, 3, 1)
    player_two = Player:new(world, 200, 200, 3, 2)
    love.graphics.setBackgroundColor(0, 1, 0)

    platform1 = love.graphics.newImage('/sprites/Platform1.png')

    gameState = "menu"

    

end

      
function love.keypressed(key)
    if gameState == "menu" then
        gameState = "fighting"
    end
end

function love.update(dt)
  

    if gameState == "fighting" then 
    
        cam:move(0, -5 * dt)
        

        player_one:update(dt, world, player_two, cam)
        player_two:update(dt, world, player_one, cam)

        world:update(dt)
        if player_one.hp <= 0 then
            gameState = "player2_win"
        elseif player_two.hp <= 0 then
            gameState = "player1_win"
        end
    end
    
    

    fog.animation.move:update(dt)
end

function love.draw()
    gameMap:drawLayer(gameMap.layers["background"])
    if gameState == "menu" then
    
        love.graphics.setFont(bigFont)
        love.graphics.printf("PRESS ANY KEY TO START", 0, 300, 1280, "center")

    elseif gameState == "fighting" then
        cam:attach()
        love.graphics.push()

        
        gameMap:drawLayer(gameMap.layers["Collisions"])
        world:draw()
        
        player_one:draw()
        player_two:draw()

        cam:detach()

        love.graphics.pop()

    elseif gameState == "player1_win" then
        love.graphics.setFont(bigFont)
        love.graphics.printf("PLAYER 1 WIN", 0, 300, 1280, "center")
       
    elseif gameState == "player2_win" then 
        love.graphics.setFont(bigFont)
        love.graphics.printf("PLAYER 2 WIN", 0, 300, 1280, "center")
        

    end
    
   

    fog.animation.move:draw(fog.spriteSheet, fog.x, fog.y, 0, 4, 4)
        
end



