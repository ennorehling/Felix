local https, json

local game_key, game_version, development_mode

-- local api_host = 'https://love2d.requestcatcher.com'
local api_host = 'https://api.lootlocker.io'

local session_token = nil
local player_id = nil

local function request(url, method, ...)
    local params = {...}
    local headers = {
        Accept = "application/json"
    }
    if session_token then
        headers['x-session-token'] = session_token
    end
    headers["Content-Type"] = "application/json"
    headers["LL-Version"] = "2021-03-01"
    local options = {
        method = method,
        headers = headers
    }
    if #params > 0 then
        body = params[1]
        if type(body) == 'table' then
            options.data = json.encode(body)
        else
            options.data = body
        end
    end
    return https.request(url, options)
end 

local sdk = {}

sdk.createSession = function(player_identifier, platform)
    local url = api_host .. '/game/v2/session'
    data = {
        game_key = game_key,
        game_version = game_version,
        development_mode = development_mode,
        platform = platform,
        player_identifier = player_identifier
    }
    code, body, headers = request(url, "post", data)
    local j = json.decode(body)
    if code >= 200 and code < 300 then
        if j.success then
            session_token = j.session_token
            player_id = j.player_id
        end
    end
    return j
end

sdk.getPlayerInfo = function()
    local url = api_host .. '/game/v1/player/info'
    code, body, headers = request(url, "get")
    return body
end

sdk.getPlayerName = function()
    local url = api_host .. '/game/player/name'
    code, body, headers = request(url, "get")
    return json.decode(body)
end

sdk.submitXp = function(points)
    local url = api_host .. '/game/v1/player/xp'
    code, body, headers = request(url, "post", { points = points })
    return json.decode(body)
end

sdk.setPlayerName = function(name)
    local url = api_host .. '/game/player/name'
    code, body, headers = request(url, "patch", { name = name })
    return json.decode(body)
end

sdk.submitScore = function(leaderboard_id, score)
    local url = api_host .. '/game/leaderboards/' .. leaderboard_id .. '/submit'
    code, body, headers = request(url, "post", { score = score })
    return json.decode(body)
end

sdk.getScoreList = function(leaderboard_id, count, after)
    local url = api_host .. '/game/leaderboards/' .. leaderboard_id .. '/list' .. '?count=10&after=0'
    code, body, headers = request(url, "get")
    return json.decode(body)
end

return function(modules)
    https = modules.https or require('https')
    json = modules.json or require('json')

    local config = modules.config or require('config')
    game_key = config.game_key or ''
    game_version = config.game_version or "0.0"
    development_mode = config.development_mode or false
    return sdk
end
