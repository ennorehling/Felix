package.cpath="./?.dll;./?.so"

local game
local app = { 
    container = {},
    state = 'playing'
}

function love.load()
    -- love.window.setMode(800, 200)
    app.container = {
        config = require('config'),
        json = require('json'),
        https = require('https')
    } 
    local Game = require('game')
    game = Game(app)
end

function love.update(dt)
    if not game.update(dt) then
        love.event.quit()
    end
end

function love.draw()
    love.graphics.setColor(0, 0, 0)
    game.draw()
end

function love.keypressed(key, scancode, isrepeat)
    game.keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
    game.keyreleased(key, scancode)
end
