-- these arent really balanced so feel free to rebalance them :)
SMODS.Joker:take_ownership("j_joker", {
	atlas = "teamname_shitfuck",
	credits = 120,
	rarity = "hpot_creditable",
	blueprint_compat = true,
	cost = 0,
	loc_vars = function(self, info_queue, card)
		if JoyousSpring and not JoyousSpring.config.disable_tooltips and not card.fake_card and not card.debuff then
			info_queue[#info_queue + 1] = { set = "Other", key = "joy_tooltip_revive" }
		end
		return { vars = {} }
	end,
	pools = {
		CreditablePool = true,
	},
	config = {},
	calculate = function(self, card, context)
		if JoyousSpring and context.setting_blind then
			local revived_card = JoyousSpring.revive_pseudorandom({}, 'hpot_revive', true)
			if revived_card then
				return { message = localize("k_joy_revive") }
			end
		end

		local ck = math.random(56, 98)
		if context.end_of_round and context.game_over and context.main_eval then
			G.E_MANAGER:add_event(Event({
				func = function()
					G.hand_text_area.blind_chips:juice_up()
					G.hand_text_area.game_chips:juice_up()
					play_sound("tarot1")
					card:start_dissolve()
					return true
				end, -- copied from vr LMAO
			}))
			return {
				message = "+" .. ck .. " HP",
				saved = "teamname_off_reference",
				colour = G.C.GREEN,
			}
		end
	end,
	
	ppu_artist = { "Mortis Ghost" },
	ppu_coder = { "GoldenLeaf" },
	ppu_team = { "Team Name" },
}, false)

SMODS.Joker({
	key = "grand_finale",
	rarity = "hpot_creditable",
	atlas = "tname_jokers",
	pos = {
		x = 0,
		y = 1,
	},
	cost = 0,
	credits = 600,
	config = {
		extra = {
			slots = 3,
		},
	},
	pools = {
		CreditablePool = true,
	},
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.slots } }
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.jokers then
			G.jokers.config.card_limit = G.jokers.config.card_limit + card.ability.extra.slots
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.jokers then
			G.jokers.config.card_limit = G.jokers.config.card_limit - card.ability.extra.slots
		end
	end,
	
	ppu_artist = { "GoldenLeaf" },
	ppu_coder = { "GoldenLeaf" },
	ppu_team = { "Team Name" },
})

SMODS.Joker({
	key = "grand_diagonal",
	rarity = "hpot_creditable",
	atlas = "tname_jokers",
	pos = {
		x = 1,
		y = 1,
	},
	cost = 0,
	credits = 600,
	config = {
		extra = {
			slots = 2,
		},
	},
	pools = {
		CreditablePool = true,
	},
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.slots } }
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.consumeables then
			G.consumeables.config.card_limit = G.consumeables.config.card_limit + card.ability.extra.slots
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.consumeables then
			G.consumeables.config.card_limit = G.consumeables.config.card_limit - card.ability.extra.slots
		end
	end,
	
	ppu_artist = { "GoldenLeaf" },
	ppu_coder = { "GoldenLeaf" },
	ppu_team = { "Team Name" },
})

SMODS.Joker({
	key = "grand_spectral",
	rarity = "hpot_creditable",
	atlas = "tname_jokers",
	pos = {
		x = 2,
		y = 1,
	},
	pools = {
		CreditablePool = true,
	},
	add_to_deck = function(self, card, from_debuff)
		G.E_MANAGER:add_event(Event({
			func = function()
				local a = G.GAME.tarot_rate
				G.GAME.tarot_rate = G.GAME.spectral_rate
				G.GAME.spectral_rate = a
				return true
			end,
		}))
	end,
	remove_from_deck = function(self, card, from_debuff)
		G.E_MANAGER:add_event(Event({
			func = function()
				local a = G.GAME.tarot_rate
				G.GAME.tarot_rate = G.GAME.spectral_rate
				G.GAME.spectral_rate = a
				return true
			end,
		}))
	end,
	cost = 0,
	credits = 600,
	
	ppu_artist = { "GoldenLeaf" },
	ppu_coder = { "GoldenLeaf" },
	ppu_team = { "Team Name" },
})

SMODS.Joker({
	key = "grand_brachial",
	rarity = "hpot_creditable",
	atlas = "tname_jokers",
	pos = {
		x = 0,
		y = 2,
	},
	pools = {
		CreditablePool = true,
	},
	cost = 0,
	credits = 600,
	calculate = function(self, card, context)
		local ret = SMODS.blueprint_effect(card, G.jokers.cards[1], context)
		local ret2 = SMODS.blueprint_effect(card, G.jokers.cards[#G.jokers.cards], context)
		local etr = nil
		if ret then
			if ret2 then
				ret.extra = ret2
			end
			etr = ret
		elseif ret2 then
			etr = ret2
		else
			etr = nil
		end

		if etr then
			return etr
		else
			return nil, true
		end
	end,
	
	ppu_artist = { "GoldenLeaf" },
	ppu_coder = { "GoldenLeaf" },
	ppu_team = { "Team Name" },
})

SMODS.Joker({
	key = "grand_chocolatier",
	rarity = "hpot_creditable",
	atlas = "tname_jokers",
	pos = {
		x = 1,
		y = 2,
	},
	cost = 0,
	credits = 600,
	config = {
		extra = {
			xmult = 7,
		},
	},
	pools = {
		CreditablePool = true,
	},
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmult } }
	end,
	calculate = function(self, card, context)
		if context.joker_main then
			return {
				xmult = card.ability.extra.xmult,
			}
		end
	end,
	
	ppu_artist = { "GoldenLeaf" },
	ppu_coder = { "GoldenLeaf" },
	ppu_team = { "Team Name" },
})

SMODS.Joker({
	key = "aries_card",
	rarity = "hpot_creditable",
	cost = 0,
	atlas = "tname_jokers",
	pos = {
		x = 2,
		y = 0,
	},
	pools = {
		CreditablePool = true,
	},
	credits = 5000,
	calculate = function(self, card, context)
		if
			G.GAME.blind.config.blind
			and G.GAME.blind.config.blind.boss
			and G.GAME.blind.config.blind.boss.showdown
			and HPTN.is_shitfuck
		then
			check_for_unlock({ type = 'get_fucked_lmao' })
			G.E_MANAGER:add_event(Event({
				trigger = "before",
				delay = 0.4,
				func = function()
					for _, joker in pairs(G.jokers.cards) do
						joker:start_dissolve(nil, true)
					end
					return true
				end,
			}))
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 0.4,
				func = function()
					SMODS.add_card({ key = "j_hpot_space_ape" })
					SMODS.add_card({ key = "j_hpot_space_ape" })
					SMODS.add_card({ key = "j_hpot_space_ape" })
					SMODS.add_card({ key = "j_hpot_space_ape" })
					SMODS.add_card({ key = "j_hpot_space_ape" })
					return true
				end,
			}))
			HPTN.is_shitfuck = false
		end
	end,
	
	ppu_artist = { "GoldenLeaf" },
	ppu_coder = { "GoldenLeaf" },
	ppu_team = { "Team Name" },
})

SMODS.Joker({
	key = "space_ape",
	atlas = "tname_jokers",
	pos = {
		x = 1,
		y = 0,
	},
	pools = {
		CreditablePool = true,
	},
	rarity = "hpot_creditable",
	cost = 0,
	credits = 0,
	no_collection = true,
	in_pool = function(self, args)
		return false
	end,
	add_to_deck = function(self, card, from_debuff)
		SMODS.Stickers["eternal"]:apply(card, true)
	end,
	
	ppu_artist = { "Mortis Ghost" },
	ppu_coder = { "GoldenLeaf" },
	ppu_team = { "Team Name" },
})
