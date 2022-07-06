scores = {
    list = {}
}

function scores.draw()
    love.graphics.setBackgroundColor(179.0/255, 204.0/255, 1)
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    love.graphics.print("GLOBAL HIGH SCORES", 20, 10)
    for pos, score in ipairs(scores.list) do
        love.graphics.print(score.rank .. " " .. score.player.name .. ": " .. score.score, 20, pos * 20 + 10)
    end
end

function scores.keypressed(key, scancode, isrepeat)
    if key == 'escape' then
        love.event.quit()
    end
end

return scores
