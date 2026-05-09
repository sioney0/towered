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
        spawnX = x_pos,
        spawnY = y_pos,

        isPunching = false,
        punchDuration = 0.4,
        punchCooldown = 0,
        punchHitbox = nil,
        alreadyHit = false,
        knockbackTimer = 0,
        jumpcooldown = 0
    }
   
    entity.collider = world:newRectangleCollider(x_pos, y_pos, 45, 80)
    entity.collider:setFixedRotation(true)
    entity.collider:setCollisionClass("Player")
    setmetatable(entity, Player)
    
    return entity
end



function Player:punch(world)
    if self.punchCooldown > 0 or self.punchHitbox then
        return
    end

    local hitboxX
    local punchWidth = 35

    if self.direction == 1 then
        -- facing right start at right edge of player
        hitboxX = self.x + self.width / 2
    else
        -- facing left put hitbox to left of player
        hitboxX = self.x - self.width / 2 - punchWidth
    end

    self.punchHitbox = world:newRectangleCollider(hitboxX, self.y - 40, punchWidth, self.height) 
    self.punchHitbox:setType("static")
    self.punchHitbox:setSensor(true)
    self.alreadyHit = false

    self.punchCooldown = 1
    
end

function movePlayer(p, leftKey, rightKey, upKey, downKey) 
    local px, py = p.collider:getLinearVelocity()
    
    if love.keyboard.isDown(leftKey) and px > -200 and not love.keyboard.isDown(rightKey) then
        p.collider:applyForce(-5000, 0)
        p.direction = -1

    elseif love.keyboard.isDown(rightKey) and px < 200 and not love.keyboard.isDown(leftKey) then
        p.collider:applyForce(5000, 0)
        p.direction = 1
    else 
         p.collider:setLinearVelocity(px * 0.8, py)
    end

    if love.keyboard.isDown(upKey) and py > -200 and p.canJump and p.jumpcooldown <= 0 then
        p.collider:applyLinearImpulse(0, -3000)
        p.canJump = false
        p.jumpcooldown = 0.5
    end
end

function Player:update(dt, world, opponent, cam)

    self:checkDeath(cam)
    
    if self.jumpcooldown > 0 then
        self.jumpcooldown = self.jumpcooldown - dt
    end

    if self.knockbackTimer > 0 then
        self.knockbackTimer = self.knockbackTimer - dt

        self.x = self.collider:getX()
        self.y = self.collider:getY()

        return
    end

    if self.player_number == 1 then
        if love.keyboard.isDown("p") then
            self:punch(world)
        end
    elseif self.player_number == 2 then
        if love.keyboard.isDown("f") then
            self:punch(world)
        end
    end

    -- For moving
    if self.player_number == 1 then
        movePlayer(self, "left", "right", "up", "down")
    elseif self.player_number == 2 then
        movePlayer(self, "a", "d", "w", "s")
    end

    if self.collider:enter("Ground") or self.collider:enter("Player")then
        self.canJump = true
    end

    -- For setting sprite always equal to collider position
    self.x = self.collider:getX()
    self.y = self.collider:getY()

    -- For Punching
    if self.punchCooldown > 0 then
        self.punchCooldown = self.punchCooldown - dt
    end

    
    
    self:updatePunch(dt, world, opponent)
  
    
end

function Player:updatePunch(dt, world, opponent)
    if self.punchHitbox then
        self.punchDuration = self.punchDuration - dt
        local hitboxX = self.punchHitbox:getX()
        local hitboxY = self.punchHitbox:getY()





        local colliders = world:queryRectangleArea( -- find any colliders of class "Player" in this rectangle hitbox.
            hitboxX - 35 / 2,
            hitboxY - self.height / 2,
            35,
            self.height,
            {"Player"} 
        )

        for _, collider in ipairs(colliders) do --for loops and finds if the collider is the opponent's he gets punched
            if collider == opponent.collider and not self.alreadyHit then
                opponent.knockbackTimer = 0.2
                opponent.collider:setLinearVelocity(600 * self.direction, -100)
                self.alreadyHit = true
            end
        end
        if self.punchDuration <= 0 then
                self.punchHitbox:destroy()
                self.punchHitbox = nil
                self.punchDuration = 0.4
            end
    end
end

function Player:checkDeath(cam, gameState)
    local voidY = cam.y + love.graphics.getHeight() / 2 + 100

    if self.y > voidY then self.hp = self.hp - 1

        if self.hp > 0 then
            self.collider:setPosition(self.spawnX, self.spawnY)
            self.collider:setLinearVelocity(0, 0)
        end
    end

  

end

function Player:draw()
    
    local imgW = self.image:getWidth()
    local imgH = self.image:getHeight()

    love.graphics.draw(self.image, self.x, self.y, 0, 2 * self.direction, 2,  imgW / 2,
        imgH / 2)

end

return Player