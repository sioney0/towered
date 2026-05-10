local Player = require('player')
local Ui = require('ui')

function love.load()
    punchHitSFX = love.audio.newSource("sounds/punchHit.wav", "static")
    punchMissSFX = love.audio.newSource("sounds/punchMiss.wav", "static")
    
    --audio
    bgm = love.audio.newSource("sounds/mainBGM.mp3", "stream")
    bgm:setLooping(true)
    bgm:setVolume(0.4)
    punchMissSFX:setVolume(0.5)
    punchHitSFX:setVolume(0.7)

    

    love.window.setMode(1280, 720)
    bigFont = love.graphics.newFont(48)
    wf = require "libraries/windfield" 
    sti = require "libraries/sti"
    camera = require "libraries/camera"
    
    cam = camera() 
    anim8 = require "libraries/anim8"
    world = wf.newWorld(0, 800)
    world:addCollisionClass("Ground")

    world:addCollisionClass("Player")

    gameMap = sti("maps/map27.lua")
    mapHeight = gameMap.height * gameMap.tileheight
    cam = camera()
    cam:lookAt(640, mapHeight - 360)
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
            
            if obj.width > 0 and obj.height > 0 then
                local collider = world:newRectangleCollider(
                    obj.x,
                    obj.y,
                    obj.width,
                    obj.height
                )
                collider:setType("static")
                collider:setCollisionClass("Ground")
            end
         

            table.insert(platforms, obj)
        end
    end

    player_one = Player:new(world, 300, mapHeight - 200, 3, 1)
    player_two = Player:new(world, 900, mapHeight - 200, 3, 2)
    love.graphics.setBackgroundColor(0, 1, 0)

    --ui
    UImanager = ui:new(player_one, player_two)

    platform1 = love.graphics.newImage('/sprites/Platform1.png')

    gameState = "menu"

    

end

      
function love.keypressed(key)
    if gameState == "menu" then
        gameState = "fighting"
        bgm:stop()
        bgm:play()
    end
end

function love.update(dt)
  

    if gameState == "fighting" then 

        cam:move(0, -40 * dt)
        

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
        gameMap:draw()
        love.graphics.setFont(bigFont)
        love.graphics.printf("Player 1: arrowkey movement, P to punch", 0, 200, 1280, "center")
        
        love.graphics.printf("TOWERED", 0, 300, 1280, "center")
        love.graphics.printf("PRESS ANY KEY TO START", 0, 600, 1280, "center")
       
    elseif gameState == "fighting" then
        cam:attach()
        love.graphics.push()
        
        gameMap:drawLayer(gameMap.layers["tiles"])
        
        
        
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

    UImanager:draw()
        
end



