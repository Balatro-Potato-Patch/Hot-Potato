-- Might as well lmao
function init_jtem(game)
	game.spark_points = game.spark_points or 20000
	game.spark_points_display = game.spark_points_display or "20,000"
	game.current_round.spark_points = game.current_round.spark_points or 0
	game.hpot_events_encountered = game.hpot_events_encountered or {}
	game.hpot_jtem_base_values = game.hpot_jtem_base_values or {}
    game.hpot_training_cost_mult = game.hpot_training_cost_mult or 1
	G.hpot_training_consumable_highlighted = nil
end

-- I needed these earlier than Perkeocoins files were loaded so theyre here now
SMODS.Gradient {
    key = 'plincoin',
    colours = {G.C.MONEY, G.C.GREEN},
    cycle = 2
}
SMODS.Gradient {
    key = 'advert',
    colours = {G.C.FILTER, G.C.RED},
    cycle = 1
}

SMODS.Gradient {
    key = 'stupid',
    colours = {G.C.WHITE, G.C.BLUE},
    cycle = 2
}

SMODS.Gradient {
    key = 'smart',
    colours = {G.C.BLUE, G.C.WHITE},
    cycle = 2
}

-- SMODS.Fonts.hpot_plincoin
SMODS.Font {
  key = "plincoin",
  path = "plincoin2.ttf"
}

-- For the splash text
function ease_splash_text(delta, reset)
	if not G.SPLASH_TEXT or type(HPJTTT.text[HPJTTT.chosen]) ~= 'string' then
		return
	end
	G.SPLASH_TEXT.scale_mod = G.SPLASH_TEXT.scale_mod or 0
	-- ease to desired scale
	G.E_MANAGER:add_event(
		Event({
			trigger = "ease",
			ease = "quad",
			ref_table = G.SPLASH_TEXT,
			ref_value = "scale_mod",
			ease_to = reset and 1 or (1 + delta),
			delay = 0.5,
			pause_force = true,
			func = function(t)
				return t
			end,
		}),
		"splash_text"
	)
	-- call it again as an event, this time backwards or vice versa. yes this is recursive
	G.E_MANAGER:add_event(
		Event({
			pause_force = true,
			func = function()
				ease_splash_text(delta, not reset)
				return true
			end,
		}),
		"splash_text"
	)
end

function simple_add_event(func, config)
	config = config or { delay = 0, trigger = "after" }
	G.E_MANAGER:add_event(Event({
		func = func,
		unpack(config),
	}))
end

function find_index_from_list(_table, object)
	if not _table then
		return nil
	end
	for _i, _e in pairs(_table) do
		if _e == object then
			return _i
		end
	end
	return nil
end

function remove_element_from_list(_table, object)
	local ind = find_index_from_list(_table, object)
	table.remove(_table, ind)
end

function set_element_object(container, object)
	if container then
		container.config.object:remove()
		container.config.object = object
		if object then
			object.config.parent = container
		else
			container.config.object = Moveable()
		end
		container.UIBox:recalculate()
	end
end

function remove_unavailable(_table)
	local _t2 = {}
	for _, v in ipairs(_table) do 
		if v ~= "UNAVAILABLE" then
			table.insert(_t2, v)
		end
	end
	return _t2
end


G.C.HP_JTEM = {
	STATS = {
		SPEED   = HEX("556665"),
		STAMINA = HEX("FF5E73"),
		POWER   = HEX("64A7FF"),
		GUTS    = HEX("FFCD29"),
		WITS    = HEX("5DF158"),
	},
	MISC = {
		-- training card colours for reuse
		TRAIN_Y = HEX("ffcf61"), -- yellow
		TRAIN_O = HEX("ff9266"), -- orange
		TRAIN_C = HEX("a92e79"), -- crimson
		TRAIN_P = HEX("630d49"), -- purple
	},
	RANKS = {
		G   = HEX("686868"), 
		F   = HEX("7071AA"),
		E   = HEX("B157C4"),
		D   = HEX("7CCFFF"),
		C   = HEX("55DF39"),
		B   = HEX("FF5D85"),
		A   = HEX("FF9C59"),
		S   = HEX("D29763"),
		SS  = HEX("FFA837"),
	}
}

G.ARGS.LOC_COLOURS.jtem_stats_speed = G.C.HP_JTEM.STATS.SPEED
G.ARGS.LOC_COLOURS.jtem_stats_stamina = G.C.HP_JTEM.STATS.STAMINA
G.ARGS.LOC_COLOURS.jtem_stats_power = G.C.HP_JTEM.STATS.POWER
G.ARGS.LOC_COLOURS.jtem_stats_guts = G.C.HP_JTEM.STATS.GUTS
G.ARGS.LOC_COLOURS.jtem_stats_wits = G.C.HP_JTEM.STATS.WITS
G.ARGS.LOC_COLOURS.jtem_crimson = G.C.HP_JTEM.MISC.TRAIN_C
G.ARGS.LOC_COLOURS.orange = G.C.ORANGE

SMODS.Gradient{
	key = "jtem_training_ug",
	colours = {
		HEX("3FD2FF"),
		HEX("A14FFF"),
		HEX("FF55F6"),
	},
	cycle = 4
}

-- Misprintize code taken from pta lmaooooo
local MisprintizeForbidden = {
	["id"] = true,
	["ID"] = true,
	["sort_id"] = true,
	["perish_tally"] = true,
	["colour"] = true,
	["suit_nominal"] = true,
	["base_nominal"] = true,
	["face_nominal"] = true,
	["qty"] = true,
	["rounds_reset"] = true, -- Login Bonus
	["current_cycle"] = true, -- also Login Bonus
	["n_seen"] = true, -- Hangman
	["times_scaled"] = true, -- Greedy Bastard's Big Eater achievement
	["selected_d6_face"] = true,
	["h_x_mult"] = true,
	["h_x_chips"] = true,
	["d_size"] = true,
	["h_size"] = true,
	["immutable"] = true,
	['min_highlighted'] = true,
	['hp_jtem_mood_config'] = true,
	['hp_jtem_mood'] = true,
	['hp_jtem_stats'] = true,
	['hp_jtem_train_mult'] = true,
	['hp_jtem_energy'] = true,
	['speed'] = true,
	['power'] = true,
	['stamina'] = true,
	['guts'] = true,
	['wits'] = true,
	["quantum"] = true,
	["config"] = true, -- Here for quantum jokers.... You shouldn't modify this!
    ["cards_req"] = true, -- Blue, Red and Yellow Deck Jokers
	["card_limit"] = true, -- Guts can increase this which doesn't make sense
	--["x_mult"] = true,
}

hpot_jtem_base_values = {}
is_number = is_number or function(a) return type(a) == "number" end

-- Loosely based on https://github.com/balt-dev/Inkbleed/blob/trunk/modules/misprintize.lua
-- Specifically for non random values
---@param val any Value to be modified. Recursive.
---@param amt? any Value to be used with `value`. See `func`. Defaults to 1.
---@param reference? table Reference table to check previous values edited by this function. Defaults to an empty table.
---@param key? any Key of the current table used, if `val` is a table. Defaults to "1".
---@param func? fun(value: any, amount: any): any Function used to modify `val` with `amt`. Uses multiplication if not specified.
---@param whitelist? table<any, boolean> Whitelisted keys for tables. If not specified, uses `blacklist`.
---@param blacklist? table<any, boolean> Blacklisted keys for tables. If not specified, uses a default blacklist.
---@param layer? number Layer of current table for recursive checking, if `val` is a table. Defaults to 0.
---@param blacklist_key? fun(key: any, value: any, layer: number): boolean Additional blacklist function, taking in the key, value and layer as parameters. Defaults to a function for checking `x_mult` and `x_chips` for the ability table.
---@return any val Value modified.
function hpot_jtem_MMisprintize(val, amt, reference, key, func, whitelist, blacklist, layer, blacklist_key)
	local meta = type(val) == 'table' and not is_number(val) and getmetatable(val) or nil
	if meta then setmetatable(val, nil) end
	reference = reference or {}
	key = key or "1"
	amt = amt or 1
	func = func or function(v, a)
		return v * a
	end
	layer = layer or 0
	blacklist_key = blacklist_key or function(k, v, l)
		if v == 1 and l == 1 then
			if k == "x_mult" or k == "x_chips" then
				return false
			end
		end
		return true
	end
	blacklist = blacklist or MisprintizeForbidden
	-- Forbidden, skip it
	if blacklist[key] then
		if type(val) == 'table' and not is_number(val) and meta then setmetatable(val, meta) end
		return val
	end
	if (whitelist and whitelist[key]) or not whitelist then
		local t = type(val)
		--if is_number(val) then print("key: "..key.." val: "..val.." layer: "..layer) end
		if is_number(val) and blacklist_key(key, val, layer) then
			if type(val) == 'table' and not is_number(val) and meta then setmetatable(val, meta) end
			reference[key] = val
			return func(val, amt)
		elseif t == "table" then
			for k, v in pairs(val) do
				val[k] = hpot_jtem_MMisprintize(v, amt, reference[key], k, func, whitelist, blacklist, layer + 1,
					blacklist_key)
			end
		end
	end
	if type(val) == 'table' and not is_number(val) and meta then setmetatable(val, meta) end
	return val
end

---@class MisprintizeContext
---@field val any Value to be modified. Recursive.
---@field amt? any Value to be used with `value`. See `func`. Defaults to 1.
---@field reference? table Reference table to check previous values edited by this function. Defaults to an empty table.
---@field key? any Key of the current table used, if `val` is a table. Defaults to "1".
---@field func? fun(value: any, amount: any): any Function used to modify `val` with `amt`. Uses multiplication if not specified.
---@field whitelist? table<any, boolean> Whitelisted keys for tables. If not specified, uses `blacklist`.
---@field blacklist? table<any, boolean> Blacklisted keys for tables. If not specified, uses a default blacklist.
---@field layer? number Layer of current table for recursive checking, if `val` is a table. Defaults to 0.
---@field blacklist_key? fun(key: any, value: any, layer: number): boolean Additional blacklist function, taking in the key, value and layer as parameters. Defaults to a function for checking `x_mult` and `x_chips` for the ability table.

-- The above, but with the parameters as a table instead.
-- In short, misprintizes values by multiplication or a specified `func` function.
---@param t MisprintizeContext Misprintize parameters.
---@return any val Return value.
function hpot_jtem_misprintize(t)
	t = t or {}
	assert(t.val, "hpot_jtem_misprintize: Value not provided!")
	assert(t.amt, "hpot_jtem_misprintize: Amount not provided!")
	return hpot_jtem_MMisprintize(t.val, t.amt, t.reference, t.key, t.func, t.whitelist, t.blacklist, t.layer,
		t.blacklist_key)
end

-- Taken from Cryptid...
---@param card Card
---@param func fun(card: Card): any
---@return any
function hpot_jtem_with_deck_effects(card, func)
	if not card.added_to_deck then
		return func(card)
	else
		card:remove_from_deck(true)
		local ret = func(card)
		card:add_to_deck(true)
		return ret
	end
end

function hpot_print_moveables_list()
    for index, m in ipairs(G.MOVEABLES) do
        if m:is(Sprite) then
            local s = m.sprite_pos or {}
            print(string.format("[%s] Sprite: %s (%s,%s)", index, m.atlas.name, s.x or '-', s.y or '-'))
        elseif m:is(CardArea) then
            print(string.format("[%s] CardArea: %s (%s/%s) (%.1f,%.1f %.1fx%.1f)", index, m.config.type, m.config.card_count, m.config.temp_limit, m.T.x, m.T.y, m.T.w, m.T.h))
        elseif m:is(Moveable) then
            local c = m.config or {}
            if m.UIT == G.UIT.T then
                if c.ref_table and c.ref_value then
                    print(string.format("[%s] T Moveable: %s | %s (ref_table[%s]) (%.1f,%.1f %.1fx%.1f)", index, c.id or "-", c.text, c.ref_value, m.T.x, m.T.y, m.T.w, m.T.h))
                else
                    print(string.format("[%s] T Moveable: %s | %s (%.1f,%.1f %.1fx%.1f)", index, c.id or "-", c.text, m.T.x, m.T.y, m.T.w, m.T.h))
                end
            else
                local UIT = '?'
                for k, v in pairs(G.UIT) do
                    if v == m.UIT then UIT = ''..k end
                end
                print(string.format("[%s] %s Moveable: %s (%.1f,%.1f %.1fx%.1f)", index, UIT, c.id or "-", m.T.x, m.T.y, m.T.w, m.T.h))
            end
        end
    end
end