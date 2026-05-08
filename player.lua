Player = {}
Player.__index = Player

local wf = require "libraries/windfield"


function Player:new(world, x_pos, y_pos, health, type)

    local entity = {
        x = x_pos,
        y = y_pos,
        hp = health,
        image = love.graphics.newImage('/sprites/Placeholder_Human.png'),
        direction = 1,
        canJump = true,
        player_number = type,
        

        isPunching = false,
        punchTimer = 0,
        punchDuration = 0.15,
        punchCooldown = 0,
        punchCooldownTime = 0.4,
        punchHitbox = nil
    }
   
    entity.collider = world:newRectangleCollider(x_pos, y_pos, 50, 80)
    entity.collider:setFixedRotation(true)
    
   
    setmetatable(entity, Player)

    return entity
end

function Player:punch(world)

    
end


function movePlayer(p, leftKey, rightKey, upKey, downKey) 
    local px, py = p.collider:getLinearVelocity()
    
    if love.keyboard.isDown(leftKey) and px > -200 then
        p.collider:applyForce(-5000, 0)
        p.direction = -1

    elseif love.keyboard.isDown(rightKey) and px < 200 then
        p.collider:applyForce(5000, 0)
        p.direction = 1
    else 
         p.collider:setLinearVelocity(px * 0.8, py)
    end

    if love.keyboard.isDown(upKey) and py > -200 and p.canJump then
        p.collider:applyLinearImpulse(0, -3000)
        p.canJump = false
    end
end

function Player:update(dt)
    if self.player_number == 1 then
        movePlayer(self, "left", "right", "up", "down")
    elseif self.player_number == 2 then
        movePlayer(self, "a", "d", "w", "s")
    end


    if self.collider:enter("Ground") then
        self.canJump = true
    end

    self.x = self.collider:getX()
    self.y = self.collider:getY()
end

function Player:draw()
    
    local imgW = self.image:getWidth()
    local imgH = self.image:getHeight()

    love.graphics.draw(self.image, self.x, self.y, 0, 5, 5,  imgW / 2,
        imgH / 2)
end

return Player