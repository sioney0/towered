Player = {}
Player__.index = Player

function Player:new(x_pos, y_pos, health)

    local entity = {
        x = x_pos
        y = y_pos
        hp = health
        image = 
    }

    setmetatable(entity, Player)
end

function Player:update()

end