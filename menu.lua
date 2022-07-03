local menu = {}

function menu.draw()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
end

function menu.update(dt)
    love.graphics.print("menu active", 10, 30)
end

function menu.keypressed(key, isrepeat)
    if key == 'f1' then
        menu.app.state = 'playing'
    elseif key == 'escape' then
        print(game.score()))
        love.event.quit()
    end
end

return function(app)
    menu.app = app
    return menu
end
