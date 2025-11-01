-- I did this so it can be used elsewhere

-- Hey y'all, Haya from Paya here.
-- Training is a mechanic for Jokers, intended to mimic Uma Musume's Career Mode.
-- Jokers can start training via a simple button, and this process is irreversible.
-- With this, specific Tarot cards can increase the stats of this Joker.
--
-- Yes this is a poor excuse to add umamusume to this fucking mod fuck you
-- also hi bepis if youre seeing this, :) (please improve the ui thx)

-- Checks if a card has a mood sticker.
function hpot_has_mood(card)
	return (card.ability.hpot_jtem_mood or card.ability.hp_jtem_mood) and "hpot_jtem_mood" or nil
end

local index_to_mood = {
	"depressed",
	"horrible",
	"awful",
	"bad",
	"normal",
	"good",
	"great",
	"hyper",
	"trance",
	-- lmaooo
}

local mood_to_index = {
	["depressed"] = 1,
	["horrible"] = 2,
	["awful"] = 3,
	["bad"] = 4,
	["normal"] = 5,
	["good"] = 6,
	["great"] = 7,
	["hyper"] = 8,
	["trance"] = 9,
	-- lmaooo
}

local mood_to_multiply = {
	["depressed"] = 0.05,
	["horrible"] = 0.3,
	["awful"] = 0.8,
	["bad"] = 0.9,
	["normal"] = 1,
	["good"] = 1.1,
	["great"] = 1.2,
	["hyper"] = 1.5,
	["trance"] = 2,
	-- lmaooo
}

local mood_to_passive_energy = {
	["depressed"] = 2,
	["horrible"] = 2,
	["awful"] = 3,
	["bad"] = 3,
	["normal"] = 4,
	["good"] = 5,
	["great"] = 5,
	["hyper"] = 6,
	["trance"] = 6,
}

-- Changes the current mood of a Joker.
---@param card Card|table
---@param mood_mod number
function hot_mod_mood(card, mood_mod)
	G.E_MANAGER:add_event(Event {
		func = function()
			card.ability["hp_jtem_mood"] = index_to_mood
				[math.max(1, math.min(mood_to_index[card.ability["hp_jtem_mood"]] + mood_mod, #index_to_mood))]
			card:juice_up(0.5, 0.3)
			check_for_unlock({type = "max_mood", conditions = card.ability["hp_jtem_mood"] or "bweh"})
			-- TODO: sound
			return true
		end
	})
end

--- Calculates the failure rate given the energy.
---@param energy number
---@return integer
function hpot_calc_failure_rate(energy)
    energy = to_number(energy)
	-- if special week is here then no failure
	if next(SMODS.find_card("j_hpot_jtem_special_week")) then return 0 end
	-- energy with atlast 70 or above yields always success
	if energy >= 70 then return 0 end
	-- no one can save you
	if energy <= 0 then return 1 end
	if energy < 10 then return 0.99 end
	return math.floor((1 - (energy / 70)) * 100) / 100
end

--- Returns the rank name and the color given the score.
--- @param score number
--- @return string
--- @return table|SMODS.Gradient
function hpot_get_rank_and_colour(score)
    score = to_number(score)
	if score >= 1900 then
		return "US", SMODS.Gradients["hpot_jtem_training_ug"]
	elseif score >= 1800 then
		return "UA", SMODS.Gradients["hpot_jtem_training_ug"]
	elseif score >= 1700 then
		return "UB", SMODS.Gradients["hpot_jtem_training_ug"]
	elseif score >= 1600 then
		return "UC", SMODS.Gradients["hpot_jtem_training_ug"]
	elseif score >= 1500 then
		return "UD", SMODS.Gradients["hpot_jtem_training_ug"]
	elseif score >= 1400 then
		return "UE", SMODS.Gradients["hpot_jtem_training_ug"]
	elseif score >= 1300 then
		return "UF", SMODS.Gradients["hpot_jtem_training_ug"]
	elseif score >= 1200 then
		return "UG", SMODS.Gradients["hpot_jtem_training_ug"]
	elseif score >= 1150 then
		return "SS+", G.C.HP_JTEM.RANKS.SS
	elseif score >= 1100 then
		return "SS", G.C.HP_JTEM.RANKS.SS
	elseif score >= 1050 then
		return "S+", G.C.HP_JTEM.RANKS.S
	elseif score >= 1000 then
		return "S", G.C.HP_JTEM.RANKS.S
	elseif score >= 800 then
		return "A+", G.C.HP_JTEM.RANKS.A
	elseif score >= 700 then
		return "A", G.C.HP_JTEM.RANKS.A
	elseif score >= 600 then
		return "B+", G.C.HP_JTEM.RANKS.B
	elseif score >= 500 then
		return "B", G.C.HP_JTEM.RANKS.B
	elseif score >= 450 then
		return "C+", G.C.HP_JTEM.RANKS.C
	elseif score >= 400 then
		return "C", G.C.HP_JTEM.RANKS.C
	elseif score >= 350 then
		return "D+", G.C.HP_JTEM.RANKS.D
	elseif score >= 300 then
		return "D", G.C.HP_JTEM.RANKS.D
	elseif score >= 250 then
		return "E+", G.C.HP_JTEM.RANKS.E
	elseif score >= 200 then
		return "E", G.C.HP_JTEM.RANKS.E
	elseif score >= 150 then
		return "F+", G.C.HP_JTEM.RANKS.F
	elseif score >= 100 then
		return "F", G.C.HP_JTEM.RANKS.F
	elseif score >= 50 then
		return "G+", G.C.HP_JTEM.RANKS.G
	end
	return "G", G.C.HP_JTEM.RANKS.G
end

HP_JTEM_STATS = { "speed", "stamina", "power", "guts", "wits" }

HP_MOOD_STICKERS = {}

-- this part is for saving misc values for this stuff
local card_init_val = Card.init
function Card:init(x, y, w, h, _card, _center, _params)
	local _c = card_init_val(self, x, y, w, h, _card, _center, _params)
	self.jp_jtem_orig_sell_cost = self.jp_jtem_orig_sell_cost or 0
	return _c
end

local card_save_additional_props = Card.save
function Card:save()
	local st = card_save_additional_props(self)
	st.jp_jtem_orig_sell_cost = self.jp_jtem_orig_sell_cost or 0
	return st
end

local card_load_additional_props = Card.load
function Card:load(ct, oc)
	local st = card_load_additional_props(self, ct, oc)
	self.jp_jtem_orig_sell_cost = ct.jp_jtem_orig_sell_cost or 0
	return st
end

---@alias TrainingStat
---| "speed"
---| "stamina"
---| "power"
---| "guts"
---| "wit"

---Calculates the stat multiplier.
---@param card Card|table
---@param stat TrainingStat|string
---@return number
function hpot_calc_stat_multiplier(card, stat)
	local multiplier = (card.ability["hp_jtem_train_mult"][stat] * mood_to_multiply[card.ability["hp_jtem_mood"] or "normal"])
	for _, joker in pairs(G.jokers.cards) do
		local centers = {joker.config.center, joker.ability.quantum_1 and joker.ability.quantum_1.config.center, joker.ability.quantum_2 and joker.ability.quantum_2.config.center}
		for _, center in pairs(centers) do
			if center and center.calc_training_mul then
				multiplier = center:calc_training_mul(joker, card, multiplier, stat) or multiplier
			end
		end
	end
	return multiplier
end

local function format_stat_effect(stat, value)
    value = to_number(value)
    if stat == "speed" then
        local speed = value - 200
        local retriggers, percent = 0, 0
        if speed > 0 then
            retriggers = math.floor(speed / 1000)
            percent = math.fmod(speed, 1000) / 1000 * 100
        end
        if retriggers > 0 then
            return SMODS.localize_box(loc_parse_string("{C:attention}#1#+#2#%{} retrigger"), {
                vars = { retriggers, percent },
                scale = 0.7,
                text_colour = G.C.UI.TEXT_INACTIVE
            })
        else
            return SMODS.localize_box(loc_parse_string("{C:attention}#1#%{} to retrigger"), {
                vars = { percent },
                scale = 0.7,
                text_colour = G.C.UI.TEXT_INACTIVE
            })
        end
    elseif stat == "wits" then
        local percent = math.floor(value <= 150 and 0 or ((value - 150) / 50)) * 100
        return SMODS.localize_box(loc_parse_string("{C:attention}+#1#%{} sell cost"), {
            vars = { percent },
            scale = 0.7,
            text_colour = G.C.UI.TEXT_INACTIVE
        })
    elseif stat == "stamina" then
        local percent = math.min(value / 800, 0.9) * 100
        return SMODS.localize_box(loc_parse_string("{C:attention}-#1#%{} energy cost"), {
            vars = { percent },
            scale = 0.7,
            text_colour = G.C.UI.TEXT_INACTIVE
        })
    elseif stat == "power" then
        local xvalue = 1 + ((value / 800) * 100) / 100
        return SMODS.localize_box(loc_parse_string("{X:chips,C:white}X#1#{} & {X:mult,C:white}X#2#{}"), {
            vars = { xvalue, xvalue },
            scale = 0.7,
            text_colour = G.C.UI.TEXT_INACTIVE
        })
    elseif stat == "guts" then
        local scale_value = value > 150 and ((value - 150) / 200) * 100 or 0
        return SMODS.localize_box(loc_parse_string("{C:attention}+#1#%{} Joker values"), {
            vars = { scale_value },
            scale = 0.7,
            text_colour = G.C.UI.TEXT_INACTIVE
        })
    elseif stat == "energy_income" then
        local income_value = mood_to_passive_energy[value]
        return SMODS.localize_box(loc_parse_string("{C:attention}+#1#{}/round"), {
            vars = { income_value },
            scale = 0.7,
            text_colour = G.C.UI.TEXT_INACTIVE
        })
    else
        return {}
    end
end

-- Taken from training grounds
local function create_stat_display(stat, values, multipliers)
	local rank, col = hpot_get_rank_and_colour(values[stat])
	col = col or G.C.UI.TEXT_DARK
	local subrank, subcol = nil, nil
	-- U rank, get second subrank
	if rank:sub(1,1) == "U" then
		subrank = rank:sub(2,2)
		rank = rank:sub(1,1)
		subcol = G.C.HP_JTEM.RANKS[subrank == "S" and "SS" or subrank] or G.C.UI.TEXT_DARK
	end
	return {
        n = G.UIT.C,
        config = { align = "cm" },
        nodes = {
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.05 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "cm" },
                        nodes = {
                            {
                                n = G.UIT.R,
                                nodes = {
                                    {
                                        n = G.UIT.C,
                                        config = { align = "bm" },
                                        nodes = {
                                            { n = G.UIT.T, config = { text = rank, scale = 0.6, colour = col, shadow = true } },
                                        }
                                    },
                                    subrank and {
                                        n = G.UIT.C,
                                        config = { align = "bm" },
                                        nodes = {
                                            { n = G.UIT.T, config = { text = subrank, scale = 0.4, colour = subcol, shadow = true } },
                                        }
                                    } or nil
                                }
                            }
                        }
                    },
                    { n = G.UIT.C, config = { minw = 0.05 }},
                    {
                        n = G.UIT.C,
                        config = { align = "cm" },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = { align = "cm" },
                                nodes = {
                                    { n = G.UIT.T, config = { ref_table = values, ref_value = stat, scale = 0.425, colour = G.C.UI.TEXT_DARK } },
                                }
                            },
                            { n = G.UIT.R, config = { minh = 0.02 } },
                            {
                                n = G.UIT.R,
                                config = { align = "cm" },
                                nodes = {
                                    { n = G.UIT.T, config = { text = "/1200", scale = 0.3, colour = G.C.UI.TEXT_DARK } },
                                }
                            },
                            { n = G.UIT.R, config = { minh = 0.02 } },
                            -- stat multiplier
                            -- idk what to do with it. Is it really that important to show in info queue?
							-- Moved it to training grounds instead- you dont need to see it all the time -haya
                            -- {
                            -- 	n = G.UIT.R,
                            -- 	config = { align = "cm" },
                            -- 	nodes = {
                            -- 		{ n = G.UIT.T, config = { text = "+", scale = 0.2, colour = G.C.UI.TEXT_INACTIVE } },
                            -- 		{ n = G.UIT.T, config = { text = (multipliers[stat] - 1) * 100, scale = 0.2, colour = G.C.UI.TEXT_INACTIVE } },
                            -- 		{ n = G.UIT.T, config = { text = "%", scale = 0.2, colour = G.C.UI.TEXT_INACTIVE } },
                            -- 	}
                            -- },
                        }
                    },
                }
            },
            {
                n = G.UIT.R,
                config = { align = "cm" },
                nodes = format_stat_effect(stat, values[stat]) or {}
            }
        }
    }
end

-- Mood stickers
SMODS.Sticker {
	key = "jtem_mood",
	rate = 0,
	atlas = "jtem_mood",
	pos = { x = 2, y = 0 },
	hpot_mood_sticker = true,
    no_collection = true,
	-- TODO: this is for pissdrawer :3 - nxkoo
	-- For people peeping in here, especially people who know UI code
	-- I wanna see this separate as little ui block elements someday
	-- Instead of one big description
	-- HAYA: its kinda funny no one really did this
	loc_vars = function(self, info_queue, card)
		local st = {}
		local clr = {}
		-- initial stats and ranks
		for _, keys in ipairs(HP_JTEM_STATS) do
			table.insert(st, card.ability["hp_jtem_stats"][keys])
			local r, c = hpot_get_rank_and_colour(card.ability["hp_jtem_stats"][keys] or 0)
			table.insert(st, r)
			table.insert(clr, c)
		end
		-- empty these, these will be used to indicate stat increases via tarots
		for _, stat in ipairs(HP_JTEM_STATS) do
			if G.hpot_training_consumable_highlighted and G.hpot_training_consumable_highlighted.ability.hpot_train_increase and G.hpot_training_consumable_highlighted.ability.hpot_train_increase[stat] then
				local stats_to_increase = G.hpot_training_consumable_highlighted.ability.hpot_train_increase
				local multiplier = hpot_calc_stat_multiplier(card, stat)
				table.insert(st, (" +%d"):format(math.ceil(stats_to_increase[stat] * multiplier)))
			else
				table.insert(st, "") -- empty
			end
		end
		clr[#clr + 1] = G.C.ORANGE -- +stat indicator
		-- stat multipliers
		for _, stat in ipairs(HP_JTEM_STATS) do
			table.insert(st, (card.ability["hp_jtem_train_mult"][stat] - 1) * 100)
		end
		-- energy
		table.insert(st, card.ability.hp_jtem_energy)
		-- energy color
		clr[#clr + 1] = to_number(card.ability.hp_jtem_energy) <= 25 and G.C.RED or to_number(card.ability.hp_jtem_energy) <= 50 and G.C.BLUE or
			G.C.UI.TEXT_DARK
		-- failure rate
		if G.hpot_training_consumable_highlighted and G.hpot_training_consumable_highlighted.ability and not G.hpot_training_consumable_highlighted.ability.hpot_skip_fail_check then
			local fail_rate = hpot_calc_failure_rate(card.ability.hp_jtem_energy)
			table.insert(st, " - " .. fail_rate * 100 .. "% Failure")
			-- failure rate color
			clr[#clr + 1] = fail_rate >= 0.7 and G.C.RED or fail_rate >= 0.4 and G.C.ORANGE or G.C.UI.TEXT_DARK
		else
			table.insert(st, "")
			clr[#clr + 1] = G.C.UI.TEXT_DARK
		end
		st.colours = clr
		-- info_queue[#info_queue + 1] = {
		-- 	key = card.config.center_key == "c_base" and "hpot_jtem_training_status" or "hpot_jtem_training_status_iq",
		-- 	set = "Other",
		-- 	vars = st
		-- }
		return {
            vars = { math.abs(1 - mood_to_multiply[card.ability["hp_jtem_mood"] or "normal"]) * 100 },
			key = self.key .. "_" .. (card.ability.hp_jtem_mood or "normal"),
		}
	end,
	apply = function(self, card, val)
		card.ability[self.key] = val
		card.ability["hp_jtem_mood_config"] = copy_table(self.config)
		-- initial mood is normal
		card.ability["hp_jtem_mood"] = "normal"
		-- determines initial stats
		card.ability["hp_jtem_stats"] = {
			speed = 60 + math.floor(pseudorandom('hp_jtem_initial_speed') * 60) - 5,
			stamina = 60 + math.floor(pseudorandom('hp_jtem_initial_stamina') * 60) - 5,
			power = 60 + math.floor(pseudorandom('hp_jtem_initial_power') * 60) - 5,
			guts = 60 + math.floor(pseudorandom('hp_jtem_initial_guts') * 60) - 5,
			wits = 60 + math.floor(pseudorandom('hp_jtem_initial_wit') * 60) - 5,
		}
		-- determines training stat multiplier
		-- only 2 can be chosen to be increased
		-- one is 20% and one is 10%
		card.ability["hp_jtem_train_mult"] = {
			speed = 1, stamina = 1, power = 1, guts = 1, wits = 1
		}
		local rnd = copy_table(card.ability["hp_jtem_train_mult"])
		local override_stat_key = nil
		local chance = 0.5
		for i = 1, 3 do -- multipliers
			-- originally this was just or 10% and 20%, but it aint accurate
			-- its either 10-10-10, 10-20, or 30
			-- 30% is less common though
			local _, stat_key = pseudorandom_element(rnd, 'hp_jtem_train_stat')
			local seed = 'kill_off_this_mf_stat_'..(G.GAME.round_resets.ante or 1)
			if G.OVERLAY_MENU or G.STAGE ~= G.STAGES.RUN then seed = 'collection_stat_kill' end
			if override_stat_key then
				stat_key = override_stat_key
				override_stat_key = nil
			end
			if not override_stat_key then
				if pseudorandom(seed) > chance and stat_key then
					rnd[stat_key] = nil
				else
					override_stat_key = stat_key
					chance = chance / 2
				end
			end
			card.ability["hp_jtem_train_mult"][stat_key] = card.ability["hp_jtem_train_mult"][stat_key] + 0.1
		end
		-- energy
		card.ability.hp_jtem_energy = 100
		card.jp_jtem_orig_sell_cost = card.sell_cost

		-- this probably isnt needed but idk
		local stats = card.ability["hp_jtem_stats"]
		hpot_jtem_with_deck_effects(card, function(c)
			if stats.guts > 200 then
				hpot_jtem_misprintize({ val = c.ability, amt = 1 + ((((stats.guts - 200) / 500) * 100) / 100) })
			end
		end)
        card:set_cost()
	end,
	draw = function(self, card, layer)
		local val = card.ability["hp_jtem_mood"] or "normal"

		HP_MOOD_STICKERS[val] = HP_MOOD_STICKERS[val] or
			Sprite(card.T.x, card.T.y, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["hpot_jtem_mood"],
				{ x = (mood_to_index[(val or "normal")]) - 1, y = 0 })
		HP_MOOD_STICKERS[val].role.draw_major = card
		HP_MOOD_STICKERS[val]:draw_shader('dissolve', 0, nil, nil, card.children.center, nil, nil, 0,
			0.1 + (-8 * (card.T.h / 95) * card.T.scale), nil, 0.6)
		HP_MOOD_STICKERS[val]:draw_shader('dissolve', nil, nil, nil, card.children.center, nil, nil, 0,
			(-8 * (card.T.h / 95) * card.T.scale))
	end,
	calculate = function(self, card, context)
		local stats = card.ability["hp_jtem_stats"]
		if context.retrigger_joker_check and not context.retrigger_joker and context.other_card == card then
            local speed_n = to_number(stats.speed)
			-- Speed checks
			if speed_n > 200 then
				local speed = (speed_n - 200)
				-- if stat is at least 1200 guarantee a retrig
				local retriggers = math.floor(speed / 1000)
				-- and the remainder gets calculated as chance
				retriggers = retriggers +
					(pseudorandom('speed_repetition_check_' .. G.GAME.round_resets.ante) < math.fmod(speed, 1000) and 1 or 0)
				return {
					repetitions = retriggers
				}
			end
		end
		if context.joker_main then
			-- TODO: Probably nerf this????
			return {
				xmult = 1 + ((stats.power / 800) * 100) / 100,
				xchips = 1 + ((stats.power / 800) * 100) / 100
			}
		end
		if context.end_of_round and context.main_eval then
			card:mod_training_stat("energy", mood_to_passive_energy[card.ability["hp_jtem_mood"] or "normal"])
		end
	end,
	generate_ui = function(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
		--SMODS.Sticker.super.generate_ui(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
		local values = card and card.ability and card.ability["hp_jtem_stats"] or {}
		if full_UI_table.sticker_pass or (card and card.area == G.train_jokers) then return end
		local function create_stat(stat, w, h)
			w = w or 2
			h = h or 1
			return {
				n = G.UIT.C,
				config = { align = "cm", minw = w, maxw = w, minh = h, maxh = h },
				nodes = {
					create_stat_display(stat, values, (card and card.ability and card.ability.hp_jtem_train_mult) or {}),
				}
			}
		end
        local function create_stat_header(stat, w, h)
            return {
				n = G.UIT.C,
				config = { align = "cm", minw = w, maxw = w, minh = h, maxh = h },
				nodes = {
					{n = G.UIT.R, config = {align = "cm", minh = 0.4, minw = w, padding = 0.05}, nodes = {
						{n = G.UIT.T, config = {text = localize("hotpot_"..stat), scale = 0.35, colour = G.C.UI.TEXT_LIGHT}},
					}},
				}
			}
        end
        local function create_energy_stat(w, h)
            w = w or 2
			h = h or 1
            local energy_colour = to_number(card.ability.hp_jtem_energy) <= 25 and G.C.RED or to_number(card.ability.hp_jtem_energy) <= 50 and G.C.BLUE or
                G.C.UI.TEXT_DARK
            return {
                n = G.UIT.C,
				config = { align = "cm", minw = w, maxw = w, minh = h, maxh = h },
				nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "cm" },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = { align = "cm", padding = 0.05 },
                                nodes = {
                                    {
                                        n = G.UIT.C,
                                        config = { align = "cm" },
                                        nodes = {
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cm" },
                                                nodes = {
                                                    {
                                                        n = G.UIT.T,
                                                        config = {
                                                            ref_table = card.ability,
                                                            ref_value = 'hp_jtem_energy',
                                                            colour = energy_colour,
                                                            scale = 0.425
                                                        }
                                                    },
                                                },
                                            },
                                            { n = G.UIT.R, config = { minh = 0.02 } },
                                            {
                                                n = G.UIT.R,
                                                config = { align ="cm" },
                                                nodes = {
                                                    {
                                                        n = G.UIT.T,
                                                        config = {
                                                            text = '/100', -- no support for dynamic max energy cap? What a lame Aiko
                                                            colour = G.C.UI.TEXT_DARK,
                                                            scale = 0.3
                                                        }
                                                    },
                                                }
                                            },
                                            { n = G.UIT.R, config = { minh = 0.02 } },
                                        }
                                    }
                                },
                            },
                            {
                                n = G.UIT.R,
                                config = { align = "cm" },
                                nodes = format_stat_effect("energy_income", card.ability['hp_jtem_mood'] or "normal")
                            },
                        }
                    }
				}
            }
        end
        
		-- Main stats
		full_UI_table.info[#full_UI_table.info + 1] = {
			custom_ui = function(info)
				return {
					n = G.UIT.R,
					config = { align = "cm", colour = G.C.CLEAR },
					nodes = {
						{
							n = G.UIT.C,
							config = { align = "cm", colour = lighten(G.C.GREY, 0.15), r = 0.15, outline_colour = lighten(G.C.JOKER_GREY, 0.5), outline = 1.2, emboss = 0.075 },
							nodes = {
								{
									n = G.UIT.R,
									config = { align = "cm" },
									nodes = {
								        create_stat_header("speed", 1.75),
										create_stat_header("stamina", 1.75),
										create_stat_header("power", 1.75),
									}
								},
                                {
                                    n = G.UIT.R,
                                    config = { align = "cm", colour = G.C.WHITE, r = 0.15, padding = 0.05 },
                                    nodes = {
									    create_stat("speed", 1.75),
										create_stat("stamina", 1.75),
										create_stat("power", 1.75),
                                    }
                                },
								{
									n = G.UIT.R,
									config = { align = "cm" },
									nodes = {
										create_stat_header("guts", 1.75),
										create_stat_header("wits", 1.75),
										create_stat_header("energy", 1.75)
									}
								},
                                {
                                    n = G.UIT.R,
                                    config = { align = "cm", colour = G.C.WHITE, r = 0.15, padding = 0.05 },
                                    nodes = {
										create_stat("guts", 1.75),
										create_stat("wits", 1.75),
                                        create_energy_stat(1.75)
                                    }
                                },
							}
						}
					}
				}
			end,
			{ }
		}
		full_UI_table.sticker_pass = true
	end,
    should_apply = function() return false end,
	badge_colour = HEX('ffcc11'),
	hotpot_credits = {
		art = { "Aikoyori" },
		idea = { "Haya", "Aikoyori" },
		code = { "Haya", "Aikoyori", "SleepyG11", "BepisFever" },
		team = { "Jtem" }
	}
}

--- Gets the default training cost.
---@param card Card|table
---@return number
function hpot_get_training_cost(card)
	return 20000 * (G.GAME.hpot_training_cost_mult or 1)
end

G.FUNCS.hpot_can_train_joker = function(e)
	---@type Card
	local card = e.config.ref_table
	if not (
        ((G.play and #G.play.cards > 0) or
        (G.CONTROLLER.locked) or
        (G.GAME.STOP_USE and G.GAME.STOP_USE > 0) or
        (to_big(G.GAME.spark_points) < to_big(hpot_get_training_cost(card)))) or
        PlinkoLogic.STATE == PlinkoLogic.STATES.IN_PROGRESS or
        PlinkoLogic.STATE == PlinkoLogic.STATES.REWARD or
        Wheel.STATE.SPUN
    ) then
		e.config.colour = G.C.CHIPS
		e.config.button = 'hpot_start_training_joker'
	else
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
	end
end

-- This Joker is now training
function G.FUNCS.hpot_start_training_joker(e)
	---@type Card
	local card = e.config.ref_table
	G.CONTROLLER.locks.use = true
	ease_spark_points(-1 * hpot_get_training_cost(card))
	card.area:remove_from_highlighted(card) -- Youre welcome Jtem - ruby
	card:highlight(false)
	G.E_MANAGER:add_event(Event {
		trigger = 'after',
		delay = 0.25 * G.SPEEDFACTOR,
		func = function()
			SMODS.Stickers["hpot_jtem_mood"]:apply(card, true)
			-- This process is irreversible!
			card.ability.hpot_training_mode = true
			if not G.GAME.hpot_training_has_ever_been_done and not G.PROFILES[G.SETTINGS.profile].disable_training_tips then
				open_hotpot_info("hotpot_training")
			end
			G.GAME.hpot_training_has_ever_been_done = true
			card:juice_up(0.3, 0.3)
			play_sound('gold_seal', 1.2, 0.4)
			return true
		end
	})
	G.E_MANAGER:add_event(Event {
		trigger = 'after',
		delay = 0.4 * G.SPEEDFACTOR,
		func = function()
			G.CONTROLLER.locks.use = nil
			return true
		end
	})
end

-- Jokers can have a 'TRAIN' button at the bottom when highlighted
function hpot_joker_train_button_definition(card)
	local args = generate_currency_string_args("joker_exchange")
	return {
		n = G.UIT.R,
		config = { ref_table = card, r = 0.08, padding = 0.1, align = "bm", minw = 0.5 * card.T.w - 0.15, maxw = 0.9 * card.T.w - 0.15, minh = 0.4 * card.T.h, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'hpot_start_training_joker', func = 'hpot_can_train_joker' },
		nodes = {
			{
				n = G.UIT.C,
				config = { align = "cm" },
				nodes = {
					{
						n = G.UIT.R,
						config = { align = "cm" },
						nodes = {
							{ n = G.UIT.T, config = { text = localize('b_hpot_train'), colour = G.C.UI.TEXT_LIGHT, scale = 0.45, shadow = true } },
						}
					},
					{
						n = G.UIT.R,
						config = { align = "cm" },
						nodes = {
							{ n = G.UIT.T, config = { text = args.symbol, font = args.font, colour = G.C.UI.TEXT_LIGHT, scale = 0.3, shadow = true } },
							{ n = G.UIT.T, config = { text = number_format(hpot_get_training_cost(card)), colour = G.C.UI.TEXT_LIGHT, scale = 0.3, shadow = true } }
						}
					},
				}
			}
		}
	}
end

SMODS.draw_ignore_keys.hpot_train_button = true

--#region Tarots

---@param self SMODS.Consumable|table
---@param card Card|table
function hpot_training_tarot_can_use(self, card)
	local trainable_jokers = {}
	for k, v in pairs(G.jokers.highlighted) do
		if v.ability.hp_jtem_mood then
			trainable_jokers[#trainable_jokers + 1] = v
		end
	end
	return G.jokers and trainable_jokers and #trainable_jokers > 0 and
		#trainable_jokers <= card.ability.max_highlighted
end

---@param self SMODS.Consumable|table
---@param card Card|table
---@param area CardArea|table
---@param copier Card|table|nil
function hpot_training_tarot_use(self, card, area, copier)
	local trainable_jokers = {}
	for k, v in pairs(G.jokers.highlighted) do
		if v.ability.hp_jtem_mood then
			trainable_jokers[#trainable_jokers + 1] = v
		end
	end
	local stats_to_increase = copy_table(card.ability.hpot_train_increase)
	local energy_changed = 0
	local success = true
	local stats_increased = {}
	local old_stats = {}
	-- Actual stat changing
	for i = 1, #trainable_jokers do
		local joker = trainable_jokers[i]
		if joker and hpot_has_mood(joker) then
			-- For comparison later down the line...
			old_stats[joker.sort_id] = copy_table(joker.ability["hp_jtem_stats"])
			local stats = joker.ability["hp_jtem_stats"]
			-- roll for luck!
			local fail_rate = to_number(hpot_calc_failure_rate(joker.ability.hp_jtem_energy))
			if pseudorandom('hpot_fail_train') < fail_rate and not card.ability.hpot_skip_fail_check then
				-- Failure...
				success = false
				-- Reverse stat increases
				for k, v in pairs(stats_to_increase) do
					stats_to_increase[k] = stats_to_increase[k] * -1.1
				end
			end
			-- iterate through all available stats to increase
			for stat, value in pairs(stats) do
				local multiplier = hpot_calc_stat_multiplier(joker, stat)
				if stats_to_increase[stat] then
					joker:mod_training_stat(stat, math.ceil(stats_to_increase[stat] * multiplier))
					stats_increased[stat] = math.ceil(stats_to_increase[stat] * multiplier)
					stats[stat] = value + stats_increased[stat]
				end
			end
			-- reduce energy if possible, only if successful
			if card.ability.hpot_energy_change and success then
				energy_changed = to_number(card.ability.hpot_energy_change)
				if energy_changed < 0 then
					energy_changed = math.ceil(energy_changed * (1 - math.min(stats.stamina / 800, 0.9)))
				else
					energy_changed = math.ceil(energy_changed * (1 + (stats.stamina / 1200)))
				end
				joker:mod_training_stat("energy", energy_changed)
			end
		end
	end
	delay(0.6)
	-- Messages
	for i = 1, #trainable_jokers do
		local joker = trainable_jokers[i]
		if joker and hpot_has_mood(joker) then
			G.E_MANAGER:add_event(Event {
				trigger = 'after',
				delay = 0.1,
				func = function()
					joker:juice_up(0.5, 0.3)
					return true
				end
			})
			-- Success! or Failure...
			if not card.ability.hpot_skip_fail_check then
				card_eval_status_text(joker, 'extra', nil, nil, nil,
					{
						message = localize('hotpot_train_' .. (success and 'success' or 'failure')),
						colour = (success and G.C.FILTER or G.C.BLUE),
						sound =
							"hpot_sfx_" .. (success and 'success' or 'failure'),
                        volume = 0.7
					})
			end
			--[[
			-- reduce energy if possible
			if energy_changed and energy_changed ~= 0 then
				card_eval_status_text(joker, 'extra', nil, nil, nil,
					{ message = localize { type = 'variable', key = 'hotpot_train_energy' .. (energy_changed >= 0 and '_up' or '_down'), vars = { math.abs(energy_changed) } }, colour = (energy_changed >= 0 and G.C.FILTER or G.C.BLUE), sound = "hpot_sfx_stat"..(energy_changed >= 0 and '_up' or '_down') })
			end
			for stat, value in pairs(stats_increased) do
				-- oh my fucking god
				value = tonumber(value)
				card_eval_status_text(joker, 'extra', nil, nil, nil,
					{ message = localize { type = 'variable', key = 'hotpot_train_' .. stat .. (value >= 0 and '_up' or '_down'), vars = { math.abs(value) } }, colour = (value >= 0 and G.C.FILTER or G.C.BLUE), sound = "hpot_sfx_stat"..(value >= 0 and '_up' or '_down') })
			end
			-- change joker stats
			local stats = joker.ability["hp_jtem_stats"]
			hpot_jtem_with_deck_effects(joker, function(c)
				if stats.guts > 150 then
					hpot_jtem_misprintize({ val = c.ability, amt = 1/(1+((((math.max(150,old_stats[joker.sort_id].guts)-150)/200)*100)/100)) })
					hpot_jtem_misprintize({ val = c.ability, amt = 1+((((stats.guts-150)/200)*100)/100) })
				end
			end)
			-- print(inspect(stats))
			-- change joker sell cost
			if stats.wits and stats.wits > 150 then
				joker.sell_cost = joker.jp_jtem_orig_sell_cost * ( 1 + ( stats.wits - 150 ) / 50)
			end
			]]
			-- increase/decrease mood if possible
			if card.ability.hpot_mood_change then
				hot_mod_mood(joker, card.ability.hpot_mood_change * (success and 1 or -1))
				card_eval_status_text(joker, 'extra', nil, nil, nil,
					{
						message = localize('hotpot_train_mood_' .. (success and 'up' or 'down')),
						colour = (success and G.C.FILTER or G.C.BLUE),
						sound =
						"hpot_sfx_stat_up",
                        volume = 0.7
					})
			end
		end
	end
	G.hpot_training_consumable_highlighted = nil
	delay(0.6)
	G.E_MANAGER:add_event(Event {
		func = function()
			G.jokers:unhighlight_all()
			return true
		end
	})
end

---@param self SMODS.Consumable|table
---@param info_queue table
---@param card Card|table
---@return table
function hpot_training_tarot_loc_vars(self, info_queue, card)
	local vars = {}
	for _, value in ipairs(HP_JTEM_STATS) do
		if card.ability.hpot_train_increase[value] then
			table.insert(vars, card.ability.hpot_train_increase[value])
		end
	end
	if card.ability.hpot_energy_change then
		table.insert(vars, math.abs(card.ability.hpot_energy_change))
	end
	if card.ability.hpot_mood_change then
		table.insert(vars, math.abs(card.ability.hpot_mood_change))
	end
	return { vars = vars }
end

local hpot_training_pool_check = function(self, args)
	return G.GAME.hpot_training_has_ever_been_done
end

local training_tarot_credits = {
	art = { 'Aikoyori' },
	code = { 'Haya' },
	idea = { 'Aikoyori', 'Haya' },
	team = { 'Jtem' }
}

-- All of these consumables below are for training specific stats.
-- `hpot_train_increase`: List of stats to increase to what value.
-- Valid stats to increase are:
-- 		speed - Likelyhood to retrigger
--		stamina - Reduces energy used when training
--		power - Additional XChips and XMult
-- 		guts - Base Joker value multiplier
-- 		wits - Sell value
-- `hpot_energy_change`: How much energy to gain/drain.
-- `hpot_mood_change`: How much mood to gain/drain.
-- `hpot_skip_fail_check`: Skips the failure check. Also doesn't show the "Success!" or "Failure..." text.

SMODS.Consumable {
	key = 'training_speed',
	set = 'Tarot',
	atlas = 'jtem_training_tarots',
	pos = { x = 0, y = 0 },
	config = { max_highlighted = 1, hpot_train_increase = { speed = 22, power = 11 }, hpot_energy_change = -5 },
	can_use = hpot_training_tarot_can_use,
	use = hpot_training_tarot_use,
	loc_vars = hpot_training_tarot_loc_vars,
	hotpot_credits = training_tarot_credits,
	in_pool = hpot_training_pool_check,
}

SMODS.Consumable {
	key = 'training_stamina',
	set = 'Tarot',
	atlas = 'jtem_training_tarots',
	pos = { x = 1, y = 0 },
	config = { max_highlighted = 1, hpot_train_increase = { stamina = 24, guts = 10 }, hpot_energy_change = -5 },
	can_use = hpot_training_tarot_can_use,
	use = hpot_training_tarot_use,
	loc_vars = hpot_training_tarot_loc_vars,
	hotpot_credits = training_tarot_credits,
	in_pool = hpot_training_pool_check,
}

SMODS.Consumable {
	key = 'training_power',
	set = 'Tarot',
	atlas = 'jtem_training_tarots',
	pos = { x = 2, y = 0 },
	config = { max_highlighted = 1, hpot_train_increase = { power = 18, stamina = 8 }, hpot_energy_change = -5 },
	can_use = hpot_training_tarot_can_use,
	use = hpot_training_tarot_use,
	loc_vars = hpot_training_tarot_loc_vars,
	hotpot_credits = training_tarot_credits,
	in_pool = hpot_training_pool_check,
}

SMODS.Consumable {
	key = 'training_guts',
	set = 'Tarot',
	atlas = 'jtem_training_tarots',
	pos = { x = 3, y = 0 },
	config = { max_highlighted = 1, hpot_train_increase = { guts = 20, speed = 7, power = 8 }, hpot_energy_change = -5 },
	can_use = hpot_training_tarot_can_use,
	use = hpot_training_tarot_use,
	loc_vars = hpot_training_tarot_loc_vars,
	hotpot_credits = training_tarot_credits,
	in_pool = hpot_training_pool_check,
}

SMODS.Consumable {
	key = 'training_wit',
	set = 'Tarot',
	atlas = 'jtem_training_tarots',
	pos = { x = 0, y = 1 },
	config = { max_highlighted = 1, hpot_train_increase = { wits = 22, speed = 8 }, hpot_energy_change = 8 },
	can_use = hpot_training_tarot_can_use,
	use = hpot_training_tarot_use,
	loc_vars = hpot_training_tarot_loc_vars,
	hotpot_credits = training_tarot_credits,
	in_pool = hpot_training_pool_check,
}

SMODS.Consumable {
	key = 'training_rest',
	set = 'Tarot',
	atlas = 'jtem_training_tarots',
	pos = { x = 1, y = 1 },
	config = { max_highlighted = 1, hpot_train_increase = {}, hpot_energy_change = 75, hpot_skip_fail_check = true },
	can_use = hpot_training_tarot_can_use,
	use = hpot_training_tarot_use,
	loc_vars = hpot_training_tarot_loc_vars,
	hotpot_credits = training_tarot_credits,
	in_pool = hpot_training_pool_check,
}

SMODS.Consumable {
	key = 'training_recreation',
	set = 'Tarot',
	atlas = 'jtem_training_tarots',
	pos = { x = 2, y = 1 },
	config = { max_highlighted = 1, hpot_train_increase = {}, hpot_mood_change = 1, hpot_skip_fail_check = true },
	can_use = hpot_training_tarot_can_use,
	use = hpot_training_tarot_use,
	loc_vars = hpot_training_tarot_loc_vars,
	hotpot_credits = training_tarot_credits,
	in_pool = hpot_training_pool_check,
}

SMODS.Consumable {
	key = 'training_inspiration',
	set = 'Spectral',
    soul_set = 'Tarot',
	hidden = true,
	atlas = 'jtem_training_spectrals',
	pos = { x = 0, y = 0 },
	config = { max_highlighted = 1, hpot_train_increase = { speed = 24, stamina = 24, power = 24, guts = 24, wits = 24 }, hpot_energy_change = -30, hpot_skip_fail_check = true },
	can_use = hpot_training_tarot_can_use,
	use = hpot_training_tarot_use,
	loc_vars = hpot_training_tarot_loc_vars,
	hotpot_credits = {
		art = { 'Aikoyori' },
		code = { 'Aikoyori' },
		idea = { 'Haya' },
		team = { 'Jtem' }
	},
	in_pool = hpot_training_pool_check,
}

local list_of_training_cards = {
	"c_hpot_training_speed",
	"c_hpot_training_stamina",
	"c_hpot_training_power",
	"c_hpot_training_guts",
	"c_hpot_training_wit",
	"c_hpot_training_rest",
	"c_hpot_training_recreation",
}
SMODS.Booster {
	key = "training_pack",
	set = "Booster",
	config = { extra = 7, choose = 2 },
	loc_vars = function(self, info_queue, card)
		return {
			vars = {
				card.ability.choose,
				card.ability.extra,
			},
		}
	end,
	atlas = 'jtem_trainingpack', pos = { x = 0, y = 0 },
	group_key = "hotpot_training_pack",
	cost = 8,
	weight = 0.4,
	draw_hand = true,
	kind = "hotpot_training_pack",
	create_card = function(self, card, i)
		return SMODS.create_card { key = list_of_training_cards[i], area = G.pack_cards, skip_materialize = true, allow_duplicates = true }
	end,
	ease_background_colour = function(self)
		ease_background_colour({
			new_colour = G.C.HP_JTEM.MISC.TRAIN_Y,
			special_colour = G.C.HP_JTEM.MISC.TRAIN_O,
			tertiary_colour =
				G.C.HP_JTEM.MISC.TRAIN_P,
			contrast = 4
		})
	end,
	in_pool = hpot_training_pool_check,
	hotpot_credits = {
		art = { 'Aikoyori' },
		code = { 'Aikoyori' },
		idea = { 'Aikoyori', 'Haya' },
		team = { 'Jtem' }
	}
}

--#endregion
