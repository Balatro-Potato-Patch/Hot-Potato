G.STATES.JTEM_PANDEMONIUM = 2437856

-- Hey y'all. Paya from Haya here.
-- This ended up being unfinished due to laziness so if anyone wants to pick it up go ahead
-- 
-- I have not played Pressure Roblox. Will probably never do so maybe
-- But if you have played it and know about the Pandemonium minigame
-- then that is exactly what it is.
--
-- The general 'gist' has been implemented so far but only that
-- Anyway uhhhh yeah see ya
-- - Paya

-- Transform pixels into game units:
local function to_game_units(val)
	return val / (G.TILESCALE * G.TILESIZE)
end

local function to_pixels(val)
	return val * (G.TILESCALE * G.TILESIZE)
end

PandemoniumGame = {
	s = {
		-- Amount of time the minigame lasts for
		default_timer = 40,
		-- When is the next minigame
		time_till_next = 100,
		-- Default time for the cursor to jerk off the center
		cursor_jank_time = 1.5,
		-- Energy left before the minigame is considered 'lost'
		default_energy = 20,
		-- Default speed for energy to run out of
		default_energy_deduct = 0.1,
	},
	f = {},
	m = {}, -- Mouse stuff
}

local screen_w, screen_h = 0, 0
local world_T = {x = 0, y = 0, w = -8.000/2, h = -7.195/2}

local function t_x(x)
    return to_pixels(
        -- offset 0,0 to be relative to the center of the screen, then transform x from pixels to screen units
        to_game_units(screen_w/2) + world_T.x + x / 1280 * world_T.w
    )
end

local function t_y(y)
    -- same as above
    return to_pixels(to_game_units(screen_h/2) + world_T.y + y / 720 * world_T.h)
end

function PandemoniumGame.f.start()
	if not G.GAME.pandemonium_enabled then return end

	local game = G.GAME
	game.pandemonium = {}
	local pandemonium = game.pandemonium

	pandemonium.end_time = PandemoniumGame.s.default_timer
	pandemonium.cursor_jank_time = PandemoniumGame.s.cursor_jank_time
	pandemonium.energy_left = PandemoniumGame.s.default_energy
	pandemonium.time = 0
	pandemonium.time_till_cursor_move = 0

	screen_w, screen_h = love.window.getMode()

	-- repellent zone
	G.pandemonium_repel = Card(to_game_units(t_x(screen_w / 2)), to_game_units(t_y(screen_h / 2)), G.CARD_W / 1.2, G.CARD_W / 1.2,
		G.P_CARDS.empty, G.P_CENTERS.j_joker)
	G.pandemonium_repel.states.drag.can = false
	G.pandemonium_repel.states.click.can = false
	G.pandemonium_repel.T.scale = 1.5

	-- dead zone
	G.pandemonium_center = Card(to_game_units(t_x(screen_w / 2)), to_game_units(t_y(screen_h / 2)), G.CARD_W / 1.2, G.CARD_W / 1.2,
		G.P_CARDS.empty, G.P_CENTERS.c_base)
	G.pandemonium_center.states.drag.can = false
	G.pandemonium_center.states.click.can = false
	local old_hover = G.pandemonium_center.hover
	G.pandemonium_center.hover = function(self)
		old_hover(self)
		pandemonium.energy_left = 20
	end

	PandemoniumGame.m.oldX, PandemoniumGame.m.oldY = love.mouse.getPosition()

	-- we are now starting
	pandemonium.last_state = G.STATE
	stop_use()
	G.STATE = G.STATES.JTEM_PANDEMONIUM
	G.STATE_COMPLETE = false
end

-- stole this from cyan lmao
local function rand_dir()
	local dir = 2 * math.pi * (G and G.GAME and pseudorandom('pandemonium') or math.random())
	return { x = math.cos(dir), y = math.sin(dir), ang = math.deg(dir) % 360 }
end

function PandemoniumGame.f.update(dt)
	if not G.GAME.pandemonium_enabled then return end
	if G.SETTINGS.paused then return end
	if G.STATE ~= G.STATES.JTEM_PANDEMONIUM then return end

	G.GAME.STOP_USE = 1

	local game = G.GAME
	local pandemonium = game.pandemonium

	pandemonium.time = pandemonium.time + dt
	pandemonium.time_till_cursor_move = pandemonium.time_till_cursor_move + dt

	PandemoniumGame.m.x, PandemoniumGame.m.y = love.mouse.getPosition()

	-- move cursor lmao
	if pandemonium.time_till_cursor_move >= pandemonium.cursor_jank_time then
		local center_x, center_y = screen_w / 2, screen_h / 2
		-- rotate it to a random angle
		local dir = rand_dir()
		center_x = (dir.x * center_x) - (dir.y * center_y) * pseudorandom('pandemonium_dist')
		center_y = (dir.y * center_x) + (dir.x * center_y) * pseudorandom('pandemonium_dist')
		love.mouse.setPosition(center_x, center_y)
		pandemonium.time_till_cursor_move = 0
		-- print("move mouse lmao")
		-- print(center_x)
		-- print(center_y)
	end

	PandemoniumGame.m.oldX, PandemoniumGame.m.oldY = love.mouse.getPosition()

	pandemonium.energy_left = pandemonium.energy_left - (PandemoniumGame.s.default_energy_deduct)*dt*60

	if pandemonium.time >= pandemonium.end_time or pandemonium.energy_left <= 0 then
		G.STATE = pandemonium.last_state
		G.STATE_COMPLETE = true
		G.pandemonium_center:start_dissolve(nil, G.SPEEDFACTOR)
		G.pandemonium_repel:start_dissolve(nil, G.SPEEDFACTOR)
	end
end

function PandemoniumGame.f.draw()
	if not G.GAME.pandemonium_enabled then return end
	if G.SETTINGS.paused then return end
	if G.STATE ~= G.STATES.JTEM_PANDEMONIUM then return end

	local game = G.GAME
	local pandemonium = game.pandemonium

	love.graphics.print(("Current pandemonium time: %d"):format(pandemonium.time), 10, 50)
	love.graphics.print(("Current pandemonium energy: %d"):format(pandemonium.energy_left), 10, 60)
end
