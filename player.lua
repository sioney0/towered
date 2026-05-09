Player = {}
Player.__index = Player

local wf = require "libraries/windfield"


function Player:new(world, x_pos, y_pos, health, type)

    local entity = {
        x = x_pos,
        y = y_pos,
        hp = health,
        image = love.graphics.newImage('/sprites/Character.png'),
        direction = 1,
        canJump = true,
        player_number = type,
        width = 50,
        height = 80,
        

        isPunching = false,
        punchDuration = 0.4,
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
    if self.punchCooldown > 0 or self.punchHitbox then
        return
    end

    self.punchHitbox = world:newRectangleCollider(self.x + 25 * self.direction, self.y - 40, 35, self.height)
    self.punchHitbox:setType("static")
    self.punchHitbox:setSensor(true)
 
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

function Player:update(dt, world, opponent)
    -- For moving
    if self.player_number == 1 then
        movePlayer(self, "left", "right", "up", "down")
    elseif self.player_number == 2 then
        movePlayer(self, "a", "d", "w", "s")
    end

    if self.collider:enter("Ground") then
        self.canJump = true
    end

    -- For setting sprite always equal to collider position
    self.x = self.collider:getX()
    self.y = self.collider:getY()

    -- For Punching
    if self.player_number == 1 then
        if love.keyboard.isDown('p') then
            self:punch(world)
        end
    elseif self.player_number == 2 then
        if love.keyboard.isDown('f') then
            self:punch(world)
        end
    end

    if self.punchHitbox then
        self.punchDuration = self.punchDuration - dt

        if self.punchDuration <= 0 then
            self.punchHitbox:destroy()
            self.punchHitbox = nil
            self.punchDuration = 0.4
        end
    end
end

function Player:draw()
    
    local imgW = self.image:getWidth()
    local imgH = self.image:getHeight()

    love.graphics.draw(self.image, self.x, self.y, 0, 2, 2,  imgW / 2,
        imgH / 2)


end

return Player