local frame_time = 40 -- default frame time for animations
local images = {}

local function load_image(filename)
    if images[filename] == nil then
        images[filename] = love.graphics.newImage('resources/' .. filename)
    end
    return images[filename]
end

local actor_class = {
    startAnimation = function(self, name, first_frame)
        self.frame_no = first_frame or 1
        self.delta_time = 0
        if self.animations[name] then
            self.animation = self.animations[name]
            return true
        end
        print("no aniumation " .. name)
        return false
    end,
    setNextAnimation = function(self, name)
        if self.animations[name] then
            self.next_animation = self.animations[name]
            return true
        end
        return false
    end
}
local actor_meta = {
    __index = actor_class
}

local function new(x, y, def)
    local actor = {
        x = x,
        y = y,
        frame_no = 1,
        delta_time = 0,
        animations = {}
    }
    actor.sprites = load_image(def.filename)
    local width = actor.sprites:getWidth()
    local height = actor.sprites:getHeight()
    for key, value in pairs(def.animations) do
        local anim = {
            frames = {},
            name = key,
            next = value.next,
            loop = value.loop or false,
        }
        if value.frames then
            for i, f in ipairs(value.frames) do
                local q = f.quad
                assert(type(q) == 'table')
                assert(type(q[1]) == 'number')
                anim.frames[i] = {
                    length = f.length or frame_time,
                    quad = love.graphics.newQuad(q[1], q[2], q[3], q[4], width, height)
                }
            end
        end
        actor.animations[key] = anim
    end
    setmetatable(actor, actor_meta)
    actor:startAnimation('idle')
    return actor
end

return {
    new = new,
}
