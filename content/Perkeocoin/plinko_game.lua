

-- watch lua Mods/Hot-Potato/Perkeocoin/plinko_game.lua

---------------
-- Game Physics
---------------


-- Transform pixels into game units:
local function to_game_units(val)
    return val / (G.TILESCALE*G.TILESIZE)
end

local function to_pixels(val)
    return val * (G.TILESCALE*G.TILESIZE)
end


if PlinkoGame then
    -- Cleanup old stuff on reload
    PlinkoGame.yeet()
end

local world_offset = {x = 0, y = 0}
--local world_offset = {x = 845, y = 390}

PlinkoGame = {
    world = "undefined",

    -- settings
    s = {
        meter = 150,
        acceleration_x = 0,
        acceleration_y = 9.81,
        world_width = 660,  -- x
        world_height = 590, -- y

        total_rewards = 7,

        peg_radius = 3.5,
        pegs_x = 10,
        pegs_y = 8,
        peg_offset = 45,
        peg_offset_x = 66,

        ball_radius = 13,
        -- density in kg / m^2, 
        -- which definies weight of this object.
        ball_density = 1,
        -- How much velocity is saved after collision?
        -- range: [0.0, 1.0]
        ball_bounce = 0.84,

        wall_height = 100,
        wall_width = 3,

        moving_pegs = false,
        peg_speed = 25, -- per second
        max_peg_offset = 5,

        
    },
    -- objects
    o = { },
    -- functions
    f = { },

    -- Remove cached data
    yeet = function ()
        if PlinkoGame.world ~= "undefined" then
            PlinkoGame.world:destroy()
            PlinkoGame.world = "undefined"
            PlinkoGame.o = {}
        end
    end
}


--#region Testing how draw game relative to the center of the screen

local screen_w, screen_h
local world_T = {x = 0, y = 0, w = 7.000, h = 6.195}

local function t_x(x)
    return to_pixels(
        -- offset 0,0 to be relative to the center of the screen, then transform x from pixels to screen units
        to_game_units(screen_w/2) + world_T.x + x / PlinkoGame.s.world_width * world_T.w
    )
end

local function t_y(y)
    -- same as above
    return to_pixels(to_game_units(screen_h/2) + world_T.y + y / PlinkoGame.s.world_height * world_T.h)
end

local function t_r(r)
    return to_pixels(r / PlinkoGame.s.world_height * world_T.h)
end

local function p_to_pixels(x, y)
    return t_x(x), t_y(y)
end

local function poly_to_pixels(x1, y1, x2, y2, x3, y3, x4, y4)
    return t_x(x1), t_y(y1), t_x(x2), t_y(y2), t_x(x3), t_y(y3), t_x(x4), t_y(y4)
end

--#endregion

function PlinkoGame.f.draw()
    if not G.shop then return end
  if PlinkoGame.world == 'undefined' then
    return
  end
  if PlinkoLogic.STATE == PlinkoLogic.STATES.CLOSED then
      return
  end
  
  PlinkoUI.f.init_sprites()
  
  -- update window size
  screen_w, screen_h = love.window.getMode()
  -- update transform to use cardarea width
  world_T = {x = -3.6 + 0.588, y = -3. + 0.701, w = 7, h = 5.5}

  local plinking = G.shop:get_UIE_by_ID("plinking_area")
  if plinking then
    PlinkoGame.UI = {
      x = plinking.VT.x,
      y = plinking.VT.y,
      w = plinking.VT.w,
      -- account for cardarea padding
      h = (G.plinko_rewards.VT.y + G.plinko_rewards.VT.h) - plinking.VT.y,
    }
  end

  love.graphics.push()
  -- draw properly with screenshake
  G.shop:translate_container()
  
  PlinkoGame.f.draw_objects()
  
  love.graphics.pop()

  PlinkoGame.f.debug_objects()
end

function PlinkoGame.f.draw_objects()
    for _, v in pairs(PlinkoGame.o) do
        if type(v.draw) == "function" then
            v:draw()
        end
    end
end

--#region Movable pegs logic
local peg_offset = 0
local sign = 1
local function move_pegs(dt)
    if G.plinko_rewards then
        if PlinkoGame.s.moving_pegs ~= G.GAME.plinko_rewards.moving_pegs then
            PlinkoGame.f.toggle_moving_pegs(G.GAME.plinko_rewards.moving_pegs)
        end

        if not PlinkoGame.s.moving_pegs then
            return
        end

        if peg_offset >= PlinkoGame.s.max_peg_offset then
            sign = -1
        elseif peg_offset <= -PlinkoGame.s.max_peg_offset then
            sign = 1
        end

        local add = PlinkoGame.s.peg_speed * dt * sign
        for k, v in pairs(PlinkoGame.o) do
            if k:find("obstacle_") then
                if v.odd then
                    v.body:setX(v.body:getX() - add)
                else
                    v.body:setX(v.body:getX() + add)
                end
            end
        end
        peg_offset = peg_offset + add
    end
end

function PlinkoGame.f.toggle_moving_pegs(value)
    if value == PlinkoGame.s.moving_pegs then
        return
    end
    if type(value) ~= "nil" then
        PlinkoGame.s.moving_pegs = not not value
    else
        PlinkoGame.s.moving_pegs = not PlinkoGame.s.moving_pegs
    end

    if not PlinkoGame.s.moving_pegs then
        -- Reset peg positions
        for k, v in pairs(PlinkoGame.o) do
            if k:find("obstacle_") then
                if v.odd then
                    v.body:setX(v.body:getX() + peg_offset)
                else
                    v.body:setX(v.body:getX() - peg_offset)
                end
            end
        end
        peg_offset = 0
    end
end
--#endregion



function PlinkoGame.f.update_plinko_world(dt)
    if G.SETTINGS.paused then
        return
    end
    if PlinkoLogic.STATE == PlinkoLogic.STATES.CLOSED then
        return
    end

    if PlinkoGame.world == 'undefined' then
        PlinkoGame.f.create_world()
        PlinkoGame.f.init_dummy_ball()
        return
    end

    -- Remove destroyed objects
    for k, v in pairs(PlinkoGame.o) do
        if v.destroyed then
            PlinkoGame.o[k] = nil
        end
    end

    local capped_dt = math.min(0.02, dt)

    move_pegs(capped_dt)

    PlinkoGame.f.ballin(capped_dt)
    PlinkoGame.world:update(capped_dt)
end



--#region Dynamic ball offset

local plinko_balling = 1
local where_is_plinko_balling = 1
local how_much_balling_per_second = 250
local ball_idle_offset = 175/2
local plinko_should_be_balling_in_a_different_direction = (PlinkoGame.s.world_width - ball_idle_offset * 2)
local function get_dummy_ball_x()
    return world_offset.x + (ball_idle_offset + plinko_balling)
end

function PlinkoGame.f.ballin(dt)
    plinko_balling = plinko_balling + where_is_plinko_balling * how_much_balling_per_second * dt
    if plinko_balling >= plinko_should_be_balling_in_a_different_direction or plinko_balling <= 1 then
        where_is_plinko_balling = -where_is_plinko_balling
        plinko_balling = math.max(1, math.min(plinko_should_be_balling_in_a_different_direction, plinko_balling))
    end

    if PlinkoGame.o.dummy_ball then
        PlinkoGame.o.dummy_ball.body:setX(get_dummy_ball_x())
    end
end

--#endregion

local destroy_obj = function (self)
    self.fixture:destroy()
    self.destroyed = true
end

local function fix(obj)
    -- Connect body (placement) with shape
    obj.fixture = love.physics.newFixture(obj.body, obj.shape, obj.density)
    obj.shape = obj.fixture:getShape()
    obj.density = nil
    obj.destroy = destroy_obj
    return obj
end

local function draw_peg(self)
    local sprite = PlinkoUI.sprites.peg

    self.curr_pos = {x = self.body:getX() - self.shape:getRadius(), y = self.body:getY() - self.shape:getRadius()}
    sprite.T.x, sprite.T.y = PlinkoGame.f.translate_pos(self.curr_pos)
    -- hard set T or something
    sprite.VT.x = sprite.T.x
    sprite.VT.y = sprite.T.y
    sprite:draw()
end

-- Create obstacle pegs 
function PlinkoGame.f.create_obstacle(offset)
    return fix {
        body = love.physics.newBody(
            PlinkoGame.world,
            world_offset.x + offset.x,
            world_offset.y + offset.y
        ),
        shape = love.physics.newCircleShape(PlinkoGame.s.peg_radius),
        debug_draw = PlinkoGame.f.circle,
        draw = draw_peg,
    }
end

local function vec_length(p1, p2)
    return math.sqrt((p1.x - p2.x)^2 + (p1.y - p2.y)^2)
end

-- Offset pos to the starting point of the UI, then convert world coordinate into coordinate within the UI box
function PlinkoGame.f.translate_pos(pos)
    return PlinkoGame.UI.x + pos.x / PlinkoGame.s.world_width * PlinkoGame.UI.w,
           PlinkoGame.UI.y + pos.y / PlinkoGame.s.world_height * PlinkoGame.UI.h
end

local function draw_perkeorb(self)
    local sprite = PlinkoUI.sprites.perkeorb

    self.curr_pos = {x = self.body:getX() - self.shape:getRadius(), y = self.body:getY() - self.shape:getRadius()}
    self.last_pos = self.last_pos or self.curr_pos
    local sign = self.curr_pos.x - self.last_pos.x < 0 and -1 or 1
    local delta_r = sign * vec_length(self.curr_pos, self.last_pos) / (PlinkoLogic.STATE == PlinkoLogic.STATES.IDLE and 30 or 40) -- 30 when idle makes animation nicer
    if sprite.T.r > 100 then
        sprite.T.r = 0
        sprite.VT.r = 0
    end
    sprite.T.r = sprite.T.r + delta_r
    sprite.T.x, sprite.T.y = PlinkoGame.f.translate_pos(self.curr_pos)
    -- hard set T or something
    sprite.VT.x = sprite.T.x
    sprite.VT.y = sprite.T.y
    sprite.VT.r = sprite.T.r
    self.last_pos = self.curr_pos
    sprite:draw()
end

local custom_sprites = {
    [42] = "stupid",
    [69] = "stupid",
    [88] = "jcoin",
    [80] = "fisch",
    [90] = "morb",
    [5] = "finity",
    [20] = "caino_plinker",
    [21] = "trib_plinker",
    [22] = "yorick_plinker",
    [23] = "chicot_plinker",
    [10] = "entropy",
    [11] = "github",
    [12] = "bitcoin",
}

local function t_size(t_)
    local size = 0
    local last = next(t_)
    while last do
        size = size + 1
        last = next(t_, last)
    end
    return size
end


function PlinkoGame.f.init_dummy_ball()
    PlinkoGame.f.remove_balls()
    PlinkoUI.f.init_sprites()

    local choice = G.GAME.plinko_force_choice or math.random(100 + t_size(custom_sprites))
    PlinkoUI.sprites.is_stupid = nil

    local custom = custom_sprites[choice]

    if G.GAME.balls_dropped and to_number(G.GAME.balls_dropped) > 0 and custom then
        PlinkoUI.sprites.changed = custom
        PlinkoUI.sprites.perkeorb = PlinkoUI.sprites[custom]
        PlinkoUI.sprites.is_stupid = custom == "stupid"
    else
         PlinkoUI.sprites.changed = nil
         PlinkoUI.sprites.perkeorb = PlinkoUI.sprites.perkeorbOG
    end

    PlinkoGame.o.dummy_ball = fix {
        body = love.physics.newBody(
            PlinkoGame.world,
            get_dummy_ball_x(),
            world_offset.y + 20
        ),
        shape = love.physics.newCircleShape(PlinkoGame.s.ball_radius),
        debug_draw = PlinkoGame.f.circle_fill,
        draw = draw_perkeorb,
    }
end

function PlinkoGame.f.remove_balls()
    if PlinkoGame.o.dummy_ball then
        PlinkoGame.o.dummy_ball:destroy()
    end

    if PlinkoGame.o.ball then
        PlinkoGame.o.ball:destroy()
    end
end

-- Create ball
function PlinkoGame.f.drop_ball(x)
    x = x and (world_offset.x + x) or get_dummy_ball_x()

    PlinkoGame.f.remove_balls()

    PlinkoGame.o.ball = fix {
        body = love.physics.newBody(
            PlinkoGame.world,
            x,
            world_offset.y + 20,
            "dynamic"
        ),
        shape = love.physics.newCircleShape(PlinkoGame.s.ball_radius),
        density = PlinkoGame.s.ball_density,
        debug_draw = PlinkoGame.f.circle_fill,
        draw = draw_perkeorb
    }

    PlinkoGame.o.ball.fixture:setRestitution(PlinkoGame.s.ball_bounce)
    PlinkoGame.o.ball.fixture:getBody():applyForce(where_is_plinko_balling * (400 + math.random() * 150), 0)
end

function PlinkoGame.f.create_world_box()
    local h_rect = {
        width = PlinkoGame.s.world_width,
        height = 1,
    }

    local v_rect = {
        width = 1,
        height = PlinkoGame.s.world_height,
    }

    PlinkoGame.o.box_bottom = fix {
        body = love.physics.newBody(
            PlinkoGame.world,
            world_offset.x + PlinkoGame.s.world_width / 2, -- in the middle
            world_offset.y + PlinkoGame.s.world_height - h_rect.height / 2 -- at the bottom
        ),
        shape = love.physics.newRectangleShape(h_rect.width, h_rect.height),
        debug_draw = PlinkoGame.f.polygon
    }
    PlinkoGame.o.box_top = fix {
        body = love.physics.newBody(
            PlinkoGame.world,
            world_offset.x + PlinkoGame.s.world_width / 2, -- in the middle
            world_offset.y + h_rect.height / 2 -- at the top
        ),
        shape = love.physics.newRectangleShape(h_rect.width, h_rect.height),
        debug_draw = PlinkoGame.f.polygon
    }

    PlinkoGame.o.box_left = fix {
        body = love.physics.newBody(
            PlinkoGame.world,
            world_offset.x + v_rect.width / 2, -- to the left
            world_offset.y + PlinkoGame.s.world_height / 2 -- in the middle
        ),
        shape = love.physics.newRectangleShape(v_rect.width, v_rect.height),
        debug_draw = PlinkoGame.f.polygon
    }

    PlinkoGame.o.box_right = fix {
        body = love.physics.newBody(
            PlinkoGame.world,
            world_offset.x + PlinkoGame.s.world_width - v_rect.width / 2, -- to the right
            world_offset.y + PlinkoGame.s.world_height / 2 -- in the middle
        ),
        shape = love.physics.newRectangleShape(v_rect.width, v_rect.height),
        debug_draw = PlinkoGame.f.polygon
    }
end

function PlinkoGame.f.get_object(fixture)
    for _, k in pairs(PlinkoGame.o) do
        if k.fixture == fixture then
            return k
        end
    end
end

local function draw_wall(self)
    local sprite = PlinkoUI.sprites.wall

    local x1, y1 = self.body:getWorldPoints(self.shape:getPoints())

    self.curr_pos = {x = x1 - PlinkoGame.s.wall_width / 2, y = y1}
    sprite.T.x, sprite.T.y = PlinkoGame.f.translate_pos(self.curr_pos)
    -- hard set T or something
    sprite.VT.x = sprite.T.x
    sprite.VT.y = sprite.T.y
    sprite:draw()
end

function PlinkoGame.f.create_rewards()
    local width = PlinkoGame.s.world_width / PlinkoGame.s.total_rewards

    local wall_height = PlinkoGame.s.wall_height
    local wall_width = PlinkoGame.s.wall_width

    for i = 1, PlinkoGame.s.total_rewards do
        PlinkoGame.o["reward_"..tostring(i)] = fix {
            body = love.physics.newBody(
                PlinkoGame.world,
                world_offset.x + width * i - width/2, -- in the middle
                world_offset.y + PlinkoGame.s.world_height - 1  -- at the bottom
            ),
            color = {i/PlinkoGame.s.world_width * 100/255, 255/255, i/PlinkoGame.s.world_width * 190/255},
            shape = love.physics.newRectangleShape(width, 1),
            debug_draw = PlinkoGame.f.polygon,
            callback = function ()
                PlinkoLogic.f.won_reward(i)
            end
        }

        if i < PlinkoGame.s.total_rewards then
            PlinkoGame.o["reward_wall"..tostring(i)] = fix {
                body = love.physics.newBody(
                    PlinkoGame.world,
                    world_offset.x + width * i, -- in the middle
                    world_offset.y + PlinkoGame.s.world_height - wall_height + 40 -- at the bottom
                ),
                shape = love.physics.newRectangleShape(wall_width, wall_height),
                debug_draw = PlinkoGame.f.polygon,
                draw = draw_wall,
            }
        end
    end

end

local function is_above(body_a, body_b)
    return body_a:isActive() and body_a:getY() > body_b:getY()
end

-- Check if moveable ball is above the statis one
local function should_boost(a, b)
    if a:type() == b:type() and a:type() == "Fixture" and a:getShape():type() == b:getShape():type() and a:getShape():type() == "CircleShape" then
        return
            (is_above(a:getBody(), b:getBody())) or
            (is_above(b:getBody(), a:getBody()))
    end
end



function PlinkoGame.f.create_world()
    if PlinkoGame.world ~= "undefined" then
        return
    end

    love.physics.setMeter(PlinkoGame.s.meter)

    PlinkoGame.world = love.physics.newWorld(
        PlinkoGame.s.acceleration_x * PlinkoGame.s.meter,
        PlinkoGame.s.acceleration_y * PlinkoGame.s.meter,
        true -- Whether the bodies in this world are allowed to sleep (eepy)
    )

    PlinkoGame.world:setCallbacks(
        -- Begin contact callback
        function (a, b, coll)
            -- Small chance to boost if balls are colliding 
            local boost = should_boost(a, b)
            if boost then
                
                -- extra bounce
                if math.random() < 0.4 then
                    coll:setRestitution(1.1)
                end
            elseif boost == false then
                -- lower bounce, boolean check because hitting a wall would return nil
                if math.random() < 0.7 then
                    coll:setRestitution(0.5)
                end
            else
                -- hit a rectangle
                local obj = PlinkoGame.f.get_object(a)
                if obj and obj.callback then
                    obj:callback()
                end
            end
            
            local sfx = nil
            local pitch = nil
            local volume = nil
            if type(boost) == "boolean" then
                if PlinkoUI.sprites.is_stupid then
                    sfx = "hpot_meow"
                else
                    sfx = 'voice'..tostring(math.random(11))
                    if math.random(1000) == 1 then
                        pitch = math.random(0.04,8) / 4
                        --nothing to see here
                    end
                end
                volume = math.random(0.85,0.9)
            else
                sfx = 'hpot_plink'
                pitch = 0.8
                --volume = 0
            end
            G.E_MANAGER:add_event(Event{blocking = false, blockable = false, func = function ()
              play_sound(sfx, pitch, volume)
              return true
            end})
        end,
        nil,
        nil,
        nil
    )

    PlinkoGame.f.create_world_box()
    PlinkoGame.f.create_rewards()

    --#region Create obstacles for the ball

    local obstacle_id = 1
    for y = 1, PlinkoGame.s.pegs_y do
        local max_x = y%2 == 0 and PlinkoGame.s.pegs_x + 1 or PlinkoGame.s.pegs_x
        for x = 1, max_x do

            local pos = {
                x = (y%2 == 0 and -PlinkoGame.s.peg_offset_x/2 or 0) - PlinkoGame.s.peg_offset_x/2 + x * PlinkoGame.s.peg_offset_x, -- offset every other row a bit
                y = 40 + y * PlinkoGame.s.peg_offset, -- generic offset from top, then every 90 px
            }

            local o = PlinkoGame.f.create_obstacle(pos)
            PlinkoGame.o["obstacle_"..tostring(obstacle_id)] = o
            if y%2 == 1 then
                o.odd = true
            else
                o.even = true
            end
            obstacle_id = obstacle_id + 1
        end
    end

    --#endregion
end


--#region Debug Objects (draw hitboxes outlines)

function PlinkoGame.f.circle(obj)
    local r,g,b,a = love.graphics.getColor()
    
    love.graphics.setColor(255/255, 100/255, 100/255, 255/255)
    local x, y = p_to_pixels(obj.body:getX(), obj.body:getY())
    love.graphics.circle("line", x, y, t_r(obj.shape:getRadius()))
    love.graphics.setColor(r,g,b,a)
end 

function PlinkoGame.f.circle_fill(obj)
    local r,g,b,a = love.graphics.getColor()

    love.graphics.setColor(100/255, 100/255, 255/255, 255/255)
    local x, y = p_to_pixels(obj.body:getX(), obj.body:getY())
    love.graphics.circle("fill", x, y, t_r(obj.shape:getRadius()))
    love.graphics.setColor(r,g,b,a)
end

function PlinkoGame.f.polygon(obj)
    local r,g,b,a = love.graphics.getColor()

    if obj.color then
        love.graphics.setColor(obj.color)
    else
        love.graphics.setColor(100/255, 255/255, 100/255, 255/255)
    end
    love.graphics.polygon("fill", poly_to_pixels(obj.body:getWorldPoints(obj.shape:getPoints())))
    love.graphics.setColor(r,g,b,a)
end

local debugging = false
 
-- Draw hitboxes
function PlinkoGame.f.debug_objects(toggle)
    if toggle then
        debugging = not debugging
        print(("You are %s debugging objects"):format(debugging and "now" or "no longer"))
        return
    end

    if not debugging then
        return
    end

    for _, v in pairs(PlinkoGame.o) do
        v:debug_draw()
    end
end

--#endregion



