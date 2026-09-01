SMODS.Joker({
	key = "sticker_master",
	rarity = 2,
	config = {
		extra = {
			mult = 5,
		},
	},
    cost = 6,
    blueprint_compat = true,
	atlas = "tname_jokers",
	pos = {
		x = 0,
		y = 0
	},
    attributes = { 'stickers', 'mult' },
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		if G.jokers and G.jokers.cards then
			return {
				vars = { hpt.mult, hpt.mult * sticker_check(G.jokers.cards, nil, {"hpot_jtem_mood"}) },
			}
		else
			return {
				vars = { hpt.mult, hpt.mult * 0 },
			}
		end
	end,
	calculate = function(self, card, context)
		local hpt = card.ability.extra
		if context.joker_main then
			return {
				mult = hpt.mult * sticker_check(G.jokers.cards, nil, {"hpot_jtem_mood"}),
			}
		end
	end,
	in_pool = function(self)
		if G.jokers and G.jokers.cards and sticker_check(G.jokers.cards, nil,{ "hpot_jtem_mood"}) > 0 then
			return true
		end
		return false
	end,
    
    ppu_artist = {"GoldenLeaf"},
    ppu_coder = {"Revo"},
    ppu_team = {"Team Name"}
})

SMODS.Joker({
	key = "missing_texture",
	rarity = 2,
    blueprint_compat = true,
	atlas = "tname_jokers",
	pos = {
		x = 2,
		y = 2
	},
    cost = 7,
    config = { extra = { max = 45, min = -20 } },
    attributes = { 'credits', 'economy' },
    loc_vars = function(self, info_queue, card)
        local r_mults = {}
		local jank = ""
        for i = card.ability.extra.min, card.ability.extra.max do
			if to_number(i) < 0 then
				jank = G.GAME.seeded and " + e." or " - c."
			else
				jank = G.GAME.seeded and " + e." or " + c." 
			end
            r_mults[#r_mults + 1] = jank..math.abs(i)
        end
        local loc_mult = {string = ' ', colour = G.GAME.seeded and G.C.ORANGE or G.C.PURPLE}
        local main_start = {
            { n = G.UIT.O, config = { object = DynaText({ string = r_mults, colours = { G.GAME.seeded and G.C.ORANGE or G.C.PURPLE }, pop_in_rate = 9999999, silent = true, random_element = true, pop_delay = 0.5, scale = 0.32, min_cycle_time = 0 }) } },
            {
                n = G.UIT.O,
                config = {
                    object = DynaText({
                        string = {
                            { string = 'pseudorand', colour = G.C.JOKER_GREY }, { string = "Oops! the ", colour = G.C.JOKER_GREY }, { string = "game crashed.", colour = G.C.JOKER_GREY }, { string = "..index a nil v..", colour = G.C.JOKER_GREY },
                            loc_mult, loc_mult, loc_mult, loc_mult, loc_mult, loc_mult, loc_mult, loc_mult, loc_mult,
                            loc_mult, loc_mult, loc_mult, loc_mult },
                        colours = { G.C.UI.TEXT_DARK },
                        pop_in_rate = 9999999,
                        silent = true,
                        random_element = true,
                        pop_delay = 0.2011,
                        scale = 0.32,
                        min_cycle_time = 0
                    })
                }
            },
        }
        return { main_start = main_start }
    end,
	calculate = function(self, card, context)
		local fuck = pseudorandom("fuck", card.ability.extra.min, card.ability.extra.max)
		local jank = to_big(fuck) < to_big(0) and "-" or "+"
		if context.joker_main then
			HPTN.ease_credits(fuck, false)
			return {
				message = jank..(G.GAME.seeded and "e." or "c.")..fuck,
				colour = G.GAME.seeded and G.C.ORANGE or G.C.PURPLE
			}
		end
	end,
    
    ppu_artist = {"GoldenLeaf"},
    ppu_coder = {"GoldenLeaf"},
    ppu_team = {"Team Name"}
})
-- fixed this btw
SMODS.Joker({
	key = "power_plant",
	rarity = 2,
    blueprint_compat = false,
	cost = 0,
	credits = 5,
	config = {
		extra = {
			dollars = 2
		},
	},
	pos = {x=6,y=0},
	atlas = "tname_jokers2",
    attributes = { 'economy', 'stickers', 'joker' },
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		if G.jokers and G.jokers.cards then
			return {
				vars = { hpt.dollars, hpt.dollars * sticker_check(add_tables({G.jokers.cards, G.playing_cards}), "hpot_uranium") },
			}
		else
			return {
				vars = { hpt.dollars, hpt.dollars * 0 },
			}
		end
	end,

	calc_dollar_bonus = function(self,card)
		local hpt = card.ability.extra
        local result = hpt.dollars * sticker_check(add_tables({G.jokers.cards, G.playing_cards}), "hpot_uranium")
		return result > 0 and result or nil
	end,

	in_pool = function(self)
		if G.jokers and G.jokers.cards and sticker_check(add_tables({G.jokers.cards, G.playing_cards}), "hpot_uranium") > 0 then
			return true
		end
		return false
	end,

    
    ppu_artist = {"GhostSalt"},
    ppu_coder = {"Revo"},
    ppu_team = {"Team Name"}
})

SMODS.Joker({
	key = "sticker_dealer",
	rarity = 2,
    blueprint_compat = true,
    perishable_compat = false,
    eternal_compat = true,
	config = {
		extra = {
			xmult = 1,
			xmultg = 0.3
		},
	},
    cost = 5,
	pos = {x=7,y=0},
	atlas = "tname_jokers2",
    attributes = { 'xmult', 'stickers' },
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
			return {
				vars = { hpt.xmult, hpt.xmultg},
			}
	end,
	calculate = function(self, card, context)
		local hpt = card.ability.extra
		if context.setting_blind and not context.blueprint then
			local rr = find_self(card, G.jokers.cards)
			if not rr then return end

			local _card =  pseudorandom_element({1,-1},pseudoseed("sticker_dealer_target"))
			local target = G.jokers.cards[rr + (_card)]

			if target then
				local sticker = poll_sticker(true, target, "sticker_dealer", {"hpot_jtem_mood"})
				if sticker then
					SMODS.Stickers[sticker]:apply(target, true)
	
					hpt.xmult = hpt.xmult + hpt.xmultg
					return{
						message = localize("k_upgrade_ex")
					}
				end
		
			end
		end
		if context.joker_main then
			return {
				xmult = hpt.xmult
			}
		end
	end,
    
    ppu_artist = {"GoldenLeaf"},
    ppu_coder = {"Revo"},
    ppu_team = {"Team Name"}
})

SMODS.Joker({
	key = "credits_ex",
	rarity = 2,
    blueprint_compat = true,
	config = {
		extra = {
			xmult = 0.75,
			credits = 30,
			hands = 0,
			fuckshit = true
		},
	},
    cost = 6,
	pos = {x=8,y=0},
	atlas = "tname_jokers2",
    attributes = { 'credits', 'xmult', 'hands' },
	loc_vars = function(self, info_queue, card)
		local key
		local fucking = G.GAME.seeded and "_budget" or ""
		key = (self.key .. fucking)
		local hpt = card.ability.extra
			return {
				vars = { hpt.xmult, hpt.credits},
				key = key
			}
	end,
	calculate = function(self, card, context)
		local hpt = card.ability.extra
		if context.end_of_round then
			if hpt.fuckshit then HPTN.ease_credits(hpt.credits * hpt.hands) hpt.fuckshit = false end
			if to_number(card.ability.perish_tally or 1.0001) < 1 then
				check_for_unlock({type = 'frums'})
			end
		end
		if context.setting_blind then
			hpt.hands = 0
			hpt.fuckshit = true
		end
		if context.press_play then
			hpt.hands = hpt.hands + 1
		end
		if context.joker_main then
			return {
				xmult = hpt.xmult,
			}
		end
	end,
    
    ppu_artist = {"GoldenLeaf"},
    ppu_coder = {"GoldenLeaf"},
    ppu_team = {"Team Name"}
})
-- i havent tested this HELP
SMODS.Joker({
	key = "leek",
	rarity = 2,
    blueprint_compat = true,
	config = {
		extra = {
			xmult = 2,
			xmultm = 0.2,
			destroyed = 0,
			xmultg = 0.3,
			min = 1
		},
	},
    cost = 7,
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
			return {
				vars = { hpt.xmult, hpt.xmultm,hpt.xmultg,hpt.min},
			}
	end,
	pos = {x=2,y=1},
	atlas = "tname_jokers2",
    attributes = { 'xmult', 'scaling', 'hands' },
	calculate = function(self, card, context)
		local hpt = card.ability.extra
		if context.joker_type_destroyed then
			hpt.destroyed = hpt.destroyed + 1
            SMODS.scale_card(card, {
				ref_table = hpt,
				ref_value = "xmult",
				scalar_value = "xmultg",
			})
		end
		if context.after and not context.blueprint then
			SMODS.scale_card(card, {
				ref_table = hpt,
				ref_value = "xmult",
				scalar_value = "xmultm",
				operation = "-",
                scaling_message = {
                    message = localize('k_hotpot_leek'),
                    colour = G.C.MULT
                }
			})
            hpt.xmult = math.max(hpt.xmult, hpt.min)
		end
		if context.joker_main then
			return {
				xmult = hpt.xmult
			}
		end
	end,
    
    ppu_artist = {"GoldenLeaf"},
    ppu_coder = {"GoldenLeaf"},
    ppu_team = {"Team Name"}
})

SMODS.Joker({
	key = "aurae_joker",
	rarity = 2,
    blueprint_compat = false,
    cost = 8,
	loc_vars = function(self, info_queue, card)
			return {
				vars = { colours = {G.C.GREY}},
			}
	end,
	pos = {x=10,y=0},
	atlas = "tname_jokers2",
    attributes = { 'modify_card' },
	calculate = function(self, card, context)
		if context.ending_shop and G.consumeables.cards[1] and not context.blueprint then
            local cards_to_replace = {}
			for k,v in pairs(G.consumeables.cards) do
				if v.ability.set ~= "Aura" then
                    table.insert(cards_to_replace, v)
				end
			end
            if #cards_to_replace > 0 then
                SMODS.destroy_cards(cards_to_replace)
                for _, v in ipairs(cards_to_replace) do
					SMODS.add_card{set = "Aura"}
                end
                return {message = localize("teamname_replaced")}
            end
		end
	end,
    
    ppu_artist = {"GoldenLeaf"},
    ppu_coder = {"GoldenLeaf"},
    ppu_team = {"Team Name"}
})