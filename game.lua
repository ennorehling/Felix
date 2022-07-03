local Actors

local felix

local KEY_JUMP = 'x'
local AIRTIME = 2.0

-- local logger = Log('game.log')
local logger = nil
local game = {
    paused = false,
    actors = {},
    speed = 64
}

function game.draw()
    love.graphics.setBackgroundColor(179.0/255, 204.0/255, 1)
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    if game.paused then
        love.graphics.print("paused", 10, 10)
    else
        love.graphics.print("playing", 10, 10)
    end
    love.graphics.print(felix.animation.name .. ": " .. felix.frame_no .. ", Y: " .. felix.y, 10, 20)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.line(0, height - 64, width, height - 64)
    for _, actor in ipairs(game.actors) do
        local frame = actor.frame_no
        local image = actor.sprites
        local quad = actor.animation.frames[frame].quad
        local vx, vy, vw, vh = quad:getViewport()
        local x = actor.x
        local y = height - actor.y - vh - 50
        love.graphics.draw(image, quad, x, y)
    end
end

local function updateAnimation(actor, dt)
    local millis = math.floor(dt * 1000)
    local anim = actor.animation
    local frame_no = actor.frame_no
    local frame_len = actor.frame_len or anim.frames[frame_no].length
    delta = millis + actor.delta_time
    while delta > frame_len do
        delta = delta - frame_len
        local numframes = #anim.frames
        if frame_no + 1 > numframes then
            local next = anim
            if anim.loop then
                frame_no = 1
            end
            if anim.next then
                next = actor.animations[anim.next]
            elseif actor.next_animation then
                next = actor.next_animation
                actor.next_animation = nil
            end
            if actor.onEndAnimation then
                actor:onEndAnimation(next)
            end
            if next ~= anim then
                -- start a different animation
                anim = next
                actor.animation = anim
                frame_no = 1
            end
        else
            frame_no = frame_no + 1
        end
        local f = anim.frames[frame_no]
        frame_len = f.length
    end
    actor.delta_time = delta
    actor.frame_no = frame_no
end

function game.update(dt)
    if game.paused then return end
    local num_actors = #game.actors
    for i = num_actors,1,-1 do
        local actor = game.actors[i]
        if not actor:update(dt) then
            if actor == felix then
                love.event.quit()
            else
                table.remove(game.actors, i)
            end
        end
    end
end

function game.keyreleased(key, scancode)
    if key == KEY_JUMP then
        if felix.jump_held then
            felix.jump_held = false
            felix.airtime = AIRTIME - felix.airtime
        end
    end
end

function game.keypressed(key, scancode, isrepeat)
    if key == 'p' then
        game.paused = not game.paused
    elseif key == 'escape' then
        felix:setState('dead')
    elseif felix.y == 0 then
        if key == KEY_JUMP then
            felix.jump_held = true
            felix:setState('jumping')
        elseif key == 'x' then
            if felix.state == 'idle' then
                felix:setState('running')
            else
                felix:setState('idle')
            end
        end
    end
end

local function updatePlayer(actor, dt)
    if actor.state == 'airtime' then
        actor.airtime = actor.airtime - dt
        if actor.airtime * 2 > AIRTIME then
            actor.y = actor.y + 1
        else
            actor.y = actor.y - 1
        end
        if actor.airtime <= 0.0 then
            actor:setState('falling')
        elseif actor.airtime < 0.4 * AIRTIME then
            actor.frame_no = 3
        elseif actor.airtime < 0.7 * AIRTIME then
            actor.frame_no = 2
        end
    else
        updateAnimation(actor, dt)
        if actor.state == 'dead' then
            actor.y = 0
            if actor.frame_no == #actor.animation.frames then
                return false
            end
        end
        if actor.state == 'jumping' then
            actor.y = actor.y + 4
            local numframes = #actor.animation.frames
            if actor.frame_no == numframes then 
                if love.keyboard.isDown(KEY_JUMP) then
                    actor.airtime = AIRTIME
                    actor:setState('airtime')
                else
                    actor:setState('falling')
                end
            end
        elseif actor.state == 'falling' then
            if actor.y > 0 then
                actor.y = actor.y - 4
            end
            if actor.y <= 0 then
                actor.y = 0
                actor:setState('running')
            end
        end
    end
    return true
end

local function updateStaticEnemy(actor, dt)
    actor.x = actor.x - game.speed * dt
    if actor.x < -48 then
       return false 
    end
    -- TODO: better hitbox logic
    if actor.x < felix.x + 40 then
        if actor.x >= felix.x - 16 then
            if felix.y < 16 then
                felix:setState('dead')
            end
        end
    end
    return true
end

local function spawnEnemy(name, update)
    local anim = require('characters.' .. name)
    local width = love.graphics.getWidth()
    local enemy = Actors.new(width-400, 0, anim)
    enemy.update = update
    enemy:startAnimation('idle')
    return enemy
end

local function spawnPlayer(name)
    local anim = require('characters.' .. name)
    local player = Actors.new(100, 0, anim)
    player.update = updatePlayer
    player.state = 'running'
    player.setState = function(actor, state)
        if state ~= actor.state then
            print(state)
            if state == 'idle' then
                actor:startAnimation('idle')
                game.speed = 0
            elseif state == 'jumping' then
                actor:startAnimation('jump', 6)
                game.speed = 64
            elseif state == 'airtime' then
                actor:startAnimation('hover')
            elseif state == 'falling' then
                actor:startAnimation('fall')
            elseif state == 'running' then
                actor:startAnimation('run')
                game.speed = 64
            elseif state == 'dead' then
                game.speed = 0
                actor:startAnimation('death')
            end
            actor.state = state
        end
    end
    player:startAnimation('run')
    return player
end

return function(app)
    game.app = app
    Actors = require('actors')
    felix = spawnPlayer('mickey')
    table.insert(game.actors, felix)
    table.insert(game.actors, 1, spawnEnemy('enemy', updateStaticEnemy))
    return game
end
