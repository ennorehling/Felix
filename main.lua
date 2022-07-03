package.cpath="./?.dll;./?.so"

local game, menu
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
    local Menu = require('menu')
    menu = Menu(app)
    local Game = require('game')
    game = Game(app)
end

function love.update(dt)
    if app.state == 'menu' then
        menu.update(dt)
    elseif app.state == 'playing' then
        game.update(dt)
    end
end

function love.draw()
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(app.state, 10, 0)
    game.draw()
    if app.state == 'menu' then
        menu.draw()
    end
end

function love.keypressed(key, isrepeat)
    if app.state == 'menu' then
        menu.keypressed(key, isrepeat)
    elseif app.state == 'playing' then
        game.keypressed(key, isrepeat)
    end
end
