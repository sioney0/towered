ui = {}

ui.__index = ui

function ui:new(p1, p2)

    local manager = {
        player_one = p2,
        player_two = p1,
        blue_hearts = love.graphics.newImage('/sprites/player2_heart.png'),
        red_hearts = love.graphics.newImage('/sprites/player1_heart.png')
    }

    setmetatable(manager, ui)

    return manager

end

function ui:update()

end

function ui:draw()
    self:hearts()

end


function ui:hearts()
    local scale = 1.5
    local spacing = 120

    for i = 1, self.player_one.hp do
        love.graphics.draw(self.blue_hearts, 30 + (i - 1) * spacing, 20, 0, scale, scale)
    end

    for i = 1, self.player_two.hp do
        love.graphics.draw(self.red_hearts, love.graphics.getWidth() - (i * spacing),
            20,
            0,
            scale,
            scale
        )
    end
end

return ui