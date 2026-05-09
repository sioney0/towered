Player = {}
Player.__index = Player

local wf = require "libraries/windfield"
local anim8 = require "libraries/anim8"


function Player:new(world, x_pos, y_pos, health, type)

    local entity = {
        x = x_pos,
        y = y_pos,
        hp = health,
        spriteSheet = love.graphics.newImage('/sprites/punch_animation_sheet.png'),
        runSheet = love.graphics.newImage('/sprites/run_animation.png'),
        direction = 1,
        canJump = true,
        player_number = type,
        width = 32,
        height = 48,
        spawnX = x_pos,
        spawnY = y_pos,
        punchStartup = 0,

        isPunching = false,
        punchDuration = 0.2,
        punchCooldown = 0,
        punchHitbox = nil,
        alreadyHit = false,
        knockbackTimer = 0,
        jumpcooldown = 0
    }
   
    entity.collider = world:newRectangleCollider(x_pos, y_pos, 32, 72)
    entity.collider:setFixedRotation(true)
    entity.collider:setCollisionClass("Player")

    setmetatable(entity, Player)

    entity.grid = anim8.newGrid(
        64, 48, 
        entity.spriteSheet:getWidth(),
        entity.spriteSheet:getHeight()
    )

    entity.runGrid = anim8.newGrid(
        60, 48,
        entity.runSheet:getWidth(),
        entity.runSheet:getHeight()
    )
    
    if entity.player_number == 1 then

        entity.LeftIdleAnimation = anim8.newAnimation(entity.grid(1, 1), 0.2)
        entity.RightIdleAnimation = anim8.newAnimation(entity.grid(1, 2), 0.2)
        entity.LeftpunchAnimation = anim8.newAnimation(entity.grid('2-3', 1), 0.1)
        entity.RightPunchAnimation = anim8.newAnimation(entity.grid('2-3', 2), 0.1)
        entity.RunLeftAnimation = anim8.newAnimation(entity.runGrid('2-3', 2), 0.5)
        entity.RunRightAnimation = anim8.newAnimation(entity.runGrid('2-3', 1), 0.5)
        entity.currentAnimation = entity.RightIdleAnimation

    elseif entity.player_number == 2 then

        entity.LeftIdleAnimation = anim8.newAnimation(entity.grid(1, 3), 0.2)
        entity.RightIdleAnimation = anim8.newAnimation(entity.grid(1, 4), 0.2)
        entity.LeftpunchAnimation = anim8.newAnimation(entity.grid('2-3', 3), 0.1)
        entity.RightPunchAnimation = anim8.newAnimation(entity.grid('2-3', 4), 0.1)
        entity.RunLeftAnimation = anim8.newAnimation(entity.runGrid('2-3', 4), 0.5)
        entity.RunRightAnimation = anim8.newAnimation(entity.runGrid('2-3', 3), 0.5)
        entity.direction = -1
        entity.currentAnimation = entity.LeftIdleAnimation
    end

    entity.currentSheet = entity.spriteSheet

    return entity
end

function Player:punch(world)
    if self.punchCooldown > 0 or self.punchHitbox then
        return
    end


    punchMissSFX:stop()
    punchMissSFX:play()

    if self.direction == -1 then
        self.currentAnimation = self.LeftpunchAnimation
        self.LeftpunchAnimation:gotoFrame(1)
        self.currentSheet = self.spriteSheet
    elseif self.direction == 1 then
        self.currentAnimation = self.RightPunchAnimation
        self.RightPunchAnimation:gotoFrame(1)
        self.currentSheet = self.spriteSheet
    end
    
    self.punchStartup = 0.08
    self.punchCooldown = 1 
end

function movePlayer(p, leftKey, rightKey, upKey, downKey) 
    local px, py = p.collider:getLinearVelocity()
    
    if love.keyboard.isDown(leftKey) and px > -200 and not love.keyboard.isDown(rightKey) then
        p.collider:applyForce(-5000, 0)
        p.direction = -1

        if not p.punchHitbox and p.punchStartup <= 0 then
            p.currentAnimation = p.RunLeftAnimation
            p.currentSheet = p.runSheet
        end

    elseif love.keyboard.isDown(rightKey) and px < 200 and not love.keyboard.isDown(leftKey) then
        p.collider:applyForce(5000, 0)
        p.direction = 1

        if not p.punchHitbox and p.punchStartup <= 0 then
            p.currentAnimation = p.RunRightAnimation
            p.currentSheet = p.runSheet
        end
    else 
         p.collider:setLinearVelocity(px * 0.8, py)
    end

    if love.keyboard.isDown(upKey) and py > -200 and p.canJump and p.jumpcooldown <= 0 then
        p.collider:applyLinearImpulse(0, -1600)
        p.canJump = false
        p.jumpcooldown = 0.5
    end
end

function Player:update(dt, world, opponent, cam)

    self:checkDeath(cam)


    self.currentAnimation:update(dt)
    
    if self.jumpcooldown > 0 then
        self.jumpcooldown = self.jumpcooldown - dt
    end

    if self.knockbackTimer > 0 then
        self.knockbackTimer = self.knockbackTimer - dt

        self.x = self.collider:getX()
        self.y = self.collider:getY() - 10

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

    local px = self.collider:getLinearVelocity()

    if not self.punchHitbox and self.punchStartup <= 0 then

        if math.abs(px) > 20 then

            if self.direction == -1 then
                self.currentAnimation = self.RunLeftAnimation
                self.currentSheet = self.runSheet
            else
                self.currentAnimation = self.RunRightAnimation
                self.currentSheet = self.runSheet
            end

        else

            if self.direction == -1 then
                self.currentAnimation = self.LeftIdleAnimation
                self.currentSheet = self.spriteSheet
            else
                self.currentAnimation = self.RightIdleAnimation
                self.currentSheet = self.spriteSheet
            end

        end
    end

    if self.collider:enter("Ground") or self.collider:enter("Player")then
        self.canJump = true
    end

    -- For setting sprite always equal to collider position
    self.x = self.collider:getX()
    self.y = self.collider:getY() - 10

    -- For Punching
    if self.punchCooldown > 0 then
        self.punchCooldown = self.punchCooldown - dt
    end

    self:updatePunch(dt, world, opponent)
  
    
end

function Player:updatePunch(dt, world, opponent)

    --checks if punchStartup is greater than 0, if it is, creates a punch hitbox
    if self.punchStartup > 0 then
        self.punchStartup = self.punchStartup - dt

        if self.punchStartup <= 0 then
            local punchWidth = 35
            local hitboxX

            if self.direction == 1 then
                hitboxX = self.x + self.width / 2 + 6
            else
                hitboxX = self.x - self.width / 2 - punchWidth - 6
            end

            --local punchHeight = self.height + 5
            self.punchHitbox = world:newRectangleCollider(
                hitboxX,
                self.y - 35,
                punchWidth,
                self.height + 5
            )

            self.punchHitbox:setType("static")
            self.punchHitbox:setSensor(true)
            self.alreadyHit = false
        end
    end

    --only runs if there is punchHitbox, which is only when punchStartup was > 1
    if self.punchHitbox then
        self.punchDuration = self.punchDuration - dt

        local hitboxX = self.punchHitbox:getX()
        local hitboxY = self.punchHitbox:getY()

        local colliders = world:queryRectangleArea( -- find any colliders of class "Player" in this rectangle hitbox.
            hitboxX - 35 / 2,
            hitboxY - self.height / 2,
            35,
            self.height + 5,
            {"Player"} 
        )

        for _, collider in ipairs(colliders) do --for loops and finds if the collider is the opponent's he gets punched
            if collider == opponent.collider and not self.alreadyHit then
                punchHitSFX:stop()
                punchHitSFX:play()

                opponent.knockbackTimer = 0.2
                opponent.collider:setLinearVelocity(500 * self.direction, -100)
                self.alreadyHit = true
                
            end
        end
        if self.punchDuration <= 0 then
                self.punchHitbox:destroy()
                self.punchHitbox = nil
                self.punchDuration = 0.2

                self.LeftpunchAnimation:gotoFrame(1)
                self.RightPunchAnimation:gotoFrame(1)
            if self.direction == -1 then
                self.currentAnimation = self.LeftIdleAnimation
                self.currentSheet = self.spriteSheet
            elseif self.direction == 1 then
                self.currentAnimation = self.RightIdleAnimation
                self.currentSheet = self.spriteSheet
            
            end
        end
    end
end

function Player:checkDeath(cam, gameState)
    local voidY = cam.y + love.graphics.getHeight() / 2

    if self.y > voidY then 
        
        self.hp = self.hp - 1

        if self.hp > 0 then
            self.collider:setPosition(self.spawnX, self.spawnY)
            self.collider:setLinearVelocity(0, 0)
        end
    end

    

end

function Player:draw()
    -- local imgW = self.image:getWidth() local imgH = self.image:getHeight()

    local offsetX
    if self.direction == -1 and self.currentSheet == self.spriteSheet then
        offsetX = 25
    elseif self.direction == 1 and self.currentSheet == self.runSheet then
        offsetX = 50
    else 
        offsetX = 25
    end

    self.currentAnimation:draw(self.currentSheet,
        self.x + offsetX,
        self.y,
        0,
        1.5,
        1.5,
        48,
        18
    )

end

return Player