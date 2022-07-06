package.cpath="./?.dll;./?.so"

local game
local sdk
local scores = require 'scores'
local json
local LEADERBOARD = 4402
local screen = game
local song

local app = { 
    container = {},
    state = 'playing',
    username = ''
}

local function submitScore(username, score)
    local response = sdk.createSession(username, 'android')
    response = sdk.getPlayerName()
    if response.name == '' then
        response = sdk.setPlayerName(username)
    end
    response = sdk.submitScore(LEADERBOARD, score)
    response = sdk.getScoreList(LEADERBOARD, 10, 0)
    scores.list = response.items
end

function love.load()
    song = love.audio.newSource('resources/felixgame.mp3', "stream")
    if song then
        song:setLooping(true)
    	song:play()
    end
    if love.filesystem.getInfo('username.txt') then
        for line in love.filesystem.lines('username.txt') do
            if line ~= '' then
                app.username = line
            end
        end
    end
    if app.username == '' then
        app.username = "Guest" .. love.math.random(90000) + 9999
        love.filesystem.write('username.txt', app.username)
    end
    json = require('json')
    app.container = {
        config = require('config'),
        json = json,
        https = require('https')
    } 
    local Lootlocker = require('lootlocker.game')
    sdk = Lootlocker(app.container)
    local Game = require('game')
    game = Game(app)
    screen = game
end

function love.update(dt)
    if screen == game then
        if not game.update(dt) then
            if song then
                song:stop()
            end
            submitScore(app.username, game.score())
            screen = scores
        end
    end
end

function love.draw()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(app.username, width - 200, height - 20)
    screen.draw()
end

function love.keypressed(key, scancode, isrepeat)
    screen.keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
    game.keyreleased(key, scancode)
end
