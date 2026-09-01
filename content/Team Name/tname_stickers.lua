SMODS.Atlas({
	key = "tname_stickers",
	path = "Team Name/tname_stickers.png",
	px = 71,
	py = 95,
})

SMODS.Sticker({
	needs_enable_flag = false,
	rate = 0.05,
	key = "overclock",
	badge_colour = HEX("fdaf57"),
	loc_vars = function(self, info_queue, card)
		return {
			vars = { G.GAME.overclock_timer, (card.ability.over_tally or G.GAME.overclock_timer) },
		}
	end,
	apply = function(self, card, val)
		card.ability.hpot_overclock = val
		card.ability.over_tally = G.GAME.overclock_timer
	end,
	calculate = function(self, card, context)
		if
			context.other_card == card
			and not card.debuff
			and (context.repetition or (context.retrigger_joker_check and not context.retrigger_joker))
		then
			return {
				repetitions = 1,
			}
		end

	if card.ability.set == "Default" or card.ability.set == "Enhanced" then
		if context.end_of_round and not card.hpot_temp_check then
			card.hpot_temp_check = true
			if card.ability.over_tally == nil then
				card.ability.over_tally = G.GAME.overclock_timer - 1
			end
			if to_number(card.ability.over_tally) > 1 then
				card.ability.over_tally = card.ability.over_tally - 1
				card_eval_status_text(card, "extra", nil, nil, nil, {
					message = localize({
						type = "variable",
						key = "a_remaining",
						vars = {
							card.ability.over_tally,
						},
					}),
					colour = G.C.FILTER,
					delay = 0.45,
				})
			else
				card_eval_status_text(card, "extra", nil, nil, nil, { message = localize("k_debuffed") })
				SMODS.debuff_card(card, true, card.config.center.key) -- source
			end
		end
	else
		if context.end_of_round and context.main_eval then
			
			if card.ability.over_tally == nil then
				card.ability.over_tally = G.GAME.overclock_timer - 1
			end
			if to_number(card.ability.over_tally) > 1 then
				card.ability.over_tally = card.ability.over_tally - 1
				card_eval_status_text(card, "extra", nil, nil, nil, {
					message = localize({
						type = "variable",
						key = "a_remaining",
						vars = {
							card.ability.over_tally,
						},
					}),
					colour = G.C.FILTER,
					delay = 0.45,
				})
			else
				card_eval_status_text(card, "extra", nil, nil, nil, { message = localize("k_debuffed") })
				SMODS.debuff_card(card, true, card.config.center.key) -- source
			end
		end
	end
	end,
	atlas = "tname_stickers",
	pos = {
		x = 1,
		y = 1,
	},
	
	ppu_artist = { "GoldenLeaf" },
		idea = { "Corobo" },
	ppu_coder = { "Revo"},
	ppu_team = { "Team Name" },
	should_apply = function(self, card, center, area, bypass_roll)
		return SMODS.Sticker.should_apply(self, card, center, area, bypass_roll) and G.GAME.tnamestickers
	end
})

SMODS.Sticker({
	needs_enable_flag = false,
	rate = 0.05,
	key = "redirect",
	badge_colour = HEX("b7a2fd"),
	calculate = function(self, card, context)
		if context.hpot_destroy and context.hpot_destroyed == card then
			local tab = {}

			local area

			if context.hpot_destroyed and context.hpot_destroyed.area then
				area = context.hpot_destroyed.area
			end

			for i = 1, #area.cards do
				if area.cards[i] ~= card and not SMODS.is_eternal(area.cards[i]) then
					tab[#tab + 1] = area.cards[i]
				end
			end

			if #tab > 0 then
				local random_joker = pseudorandom_element(tab)
				SMODS.destroy_cards(random_joker)

				local acard = copy_card(card)
				acard:add_to_deck()
				area:emplace(acard)
				SMODS.calculate_effect({ message = localize("hpot_redirect_ex") }, acard)
			end
		end
	end,
	atlas = "tname_stickers",
	pos = {
		x = 0,
		y = 0,
	},
	
	ppu_artist = { "GoldenLeaf" },
		idea = { "GoldenLeaf" },
	ppu_coder = { "Revo"},
	ppu_team = { "Team Name" },
	should_apply = function(self, card, center, area, bypass_roll)
		return SMODS.Sticker.should_apply(self, card, center, area, bypass_roll) and G.GAME.tnamestickers
	end
})

SMODS.Sticker({
	needs_enable_flag = false,
	rate = 0.05,
	key = "fragile",
	badge_colour = HEX("b7d5d8"),
	config = {
		xmult = 2,
	},
	loc_vars = function(self, info_queue, center)
		return {
			vars = { self.config.xmult },
		}
	end,
	calculate = function(self, card, context)
		if context.joker_main or (context.main_scoring and context.cardarea == G.play) then
			return {
				xmult = self.config.xmult,
			}
		end
		if context.hpot_destroy and context.hpot_destroyed and not context.hpot_destroyed.hpot_cons_used then
			SMODS.destroy_cards(card)
		end
	end,
	atlas = "tname_stickers",
	pos = {
		x = 2,
		y = 0,
	},
	
	ppu_artist = { "GoldenLeaf" },
		idea = { "GoldenLeaf" },
	ppu_coder = { "Revo"},
	ppu_team = { "Team Name" },
	should_apply = function(self, card, center, area, bypass_roll)
               return SMODS.Sticker.should_apply(self, card, center, area, bypass_roll) and G.GAME.tnamestickers
	end
})

SMODS.Sticker({
	needs_enable_flag = false,
	rate = 0.05,
	key = "rage",
	badge_colour = HEX("fd5f55"),
	calculate = function(self, card, context)
		if
			context.other_card == card
			and not card.debuff
			and (context.repetition or (context.retrigger_joker_check and not context.retrigger_joker))
		then
			local area = card.area
			local rr = nil
			for i = 1, #area.cards do
				if area.cards[i] == card then
					rr = i
				end
			end

			if area.cards[rr - 1] then
				SMODS.destroy_cards(area.cards[rr - 1])
			end

			if area.cards[rr + 1] then
				SMODS.destroy_cards(area.cards[rr + 1])
			end

			return {
				repetitions = 1,
			}
		end
	end,
	atlas = "tname_stickers",
	pos = {
		x = 1,
		y = 0,
	},
	
	ppu_artist = { "GoldenLeaf" },
		idea = { "GoldenLeaf" },
	ppu_coder = { "Revo"},
	ppu_team = { "Team Name" },
	should_apply = function(self, card, center, area, bypass_roll)
               return SMODS.Sticker.should_apply(self, card, center, area, bypass_roll) and G.GAME.tnamestickers
	end
})

SMODS.Sticker({
	needs_enable_flag = false,
	rate = 0.05,
	key = "spores",
	badge_colour = HEX("4bc292"),
    loc_vars = function(self, info_queue, card)
		local numerator, demonimator = SMODS.get_probability_vars(card, 1, 2, "hpot_spores")
		return {
			vars = { numerator, demonimator },
		}
	end,
	calculate = function(self, card, context)
		if
			context.joker_main
			or (context.main_scoring and context.cardarea == G.hand)
				and SMODS.pseudorandom_probability(card, "hpot_spores", 1, 2)
		then
			local r = nil
			local l = nil

			local area = card.area
			local rr = nil
			for i = 1, #area.cards do
				if area.cards[i] == card then
					rr = i
				end
			end

			if area.cards[rr - 1] then
				if area.cards[rr - 1].ability.hpot_spores == true then
					l = true
				else
					if not card.just_spored then
						area.cards[rr - 1].ability.hpot_spores = true
						area.cards[rr - 1]:juice_up()
						area.cards[rr - 1].just_spored = true
						SMODS.calculate_effect({ message = localize("hpot_infected_ex") }, area.cards[rr - 1])
					end
				end
			end

			if area.cards[rr + 1] then
				if area.cards[rr + 1].ability.hpot_spores == true then
					r = true
				else
					if not card.just_spored then
						area.cards[rr + 1].ability.hpot_spores = true
						area.cards[rr + 1]:juice_up()
						area.cards[rr + 1].just_spored = true
						SMODS.calculate_effect({ message = localize("hpot_infected_ex") }, area.cards[rr + 1])
					end
				end
			end

			if l and r then
				SMODS.destroy_cards(card)
			end
		end

		if context.before and card.just_spored then
			card.just_spored = nil
		end
	end,
	atlas = "tname_stickers",
	pos = {
		x = 0,
		y = 1,
	},
	
	ppu_artist = { "GoldenLeaf" },
		idea = { "Corobo" },
	ppu_coder = { "Revo"},
	ppu_team = { "Team Name" },
	should_apply = function(self, card, center, area, bypass_roll)
               return SMODS.Sticker.should_apply(self, card, center, area, bypass_roll) and G.GAME.tnamestickers
	end
})

SMODS.Sticker({
	needs_enable_flag = false,
	rate = 0.05,
	key = "nuke",
	badge_colour = HEX("a2615e"),
	loc_vars = function(self, info_queue, card)
		local numerator, demonimator = SMODS.get_probability_vars(card, 1, 6, "hpot_nuke")
		return {
			vars = { numerator, demonimator },
		}
	end,
	calculate = function(self, card, context)
		if context.setting_blind and SMODS.pseudorandom_probability(card, "hpot_nuke", 1, 6) then
			SMODS.destroy_cards({card})
		end
	end,
	atlas = "tname_stickers",
	pos = {
		x = 2,
		y = 1,
	},
	
	ppu_artist = { "GoldenLeaf" },
		idea = { "Revo" },
	ppu_coder = { "Revo"},
	ppu_team = { "Team Name" },
	should_apply = function(self, card, center, area, bypass_roll)
               return SMODS.Sticker.should_apply(self, card, center, area, bypass_roll) and G.GAME.tnamestickers
	end
})

SMODS.Sticker({
	needs_enable_flag = false,
	rate = 0.05,
	key = "cannibal",
	badge_colour = HEX("009cfd"),
	loc_vars = function(self, info_queue, center)
		return {
			vars = {},
		}
	end,
	calculate = function(self, card, context)
		if context.setting_blind then
			local stickers = {}
			for k, v in pairs(SMODS.Stickers) do
				if (card.ability[k] or card[k]) and k ~= "hpot_cannibal" and k ~= "hpot_jtem_mood" then
					stickers[#stickers + 1] = k
				end
			end

		if #stickers > 0 then
			local remove = pseudorandom_element(stickers)

			card:juice_up()
			SMODS.Stickers[remove]:apply(card, false)
			card_eval_status_text(
				card,
				"extra",
				nil,
				nil,
				nil,
				{ message = ("-" .. localize({ type = "name_text", key = remove, set = "Other" })) }
			)
		end
	end
	end,
	atlas = "tname_stickers",
	pos = {
		x = 3,
		y = 1,
	},
	
	ppu_artist = { "GoldenLeaf" },
		idea = { "GoldenLeaf" },
	ppu_coder = { "Revo"},
	ppu_team = { "Team Name" },
	should_apply = function(self, card, center, area, bypass_roll)
               return SMODS.Sticker.should_apply(self, card, center, area, bypass_roll) and G.GAME.tnamestickers
	end
})

SMODS.Sticker({
	needs_enable_flag = false,
	rate = 0.05,
	key = "binary",
	badge_colour = HEX("85a6ac"),
	loc_vars = function(self, info_queue, center)
		return {
			vars = {},
		}
	end,
	calculate = function(self, card, context)
		if context.setting_blind then
			local stickers, remove_stickers = {}, {}
			for k, v in pairs(SMODS.Stickers) do
				if k ~= "hpot_binary" and k ~= 'hpot_jtem_mood' then
					if not card.ability[k] and not card[k] then
						stickers[#stickers+1] = k
					else
						remove_stickers[#remove_stickers+1] = k
					end
				end
			end

			for i = 1, #remove_stickers do
				SMODS.Stickers[remove_stickers[i]]:apply(card, false)
			end

			for i = 1, #stickers do
				SMODS.Stickers[stickers[i]]:apply(card, true)
			end
		end
	end,
	atlas = "tname_stickers",
	pos = {
		x = 3,
		y = 0,
	},
	
	ppu_artist = { "GoldenLeaf" },
		idea = { "GoldenLeaf" },
	ppu_coder = { "Revo"},
	ppu_team = { "Team Name" },
	should_apply = function(self, card, center, area, bypass_roll)
               return SMODS.Sticker.should_apply(self, card, center, area, bypass_roll) and G.GAME.tnamestickers
	end
})

SMODS.Sticker({
	needs_enable_flag = false,
	rate = 0.05,
	key = "mail",
	badge_colour = HEX("85a6ac"),
	loc_vars = function(self, info_queue, center)
		return {
			vars = {},
		}
	end,
	calculate = function(self, card, context)
		if context.selling_card and context.card == card then
			local _set, _area

			if card and card.ability and card.ability.set then
				_set = card.ability.set
			end

			if card and card.area then
				_area = card.area
			end

			SMODS.add_card({
				set = _set,
				area = _area,
			})
		end
	end,
	atlas = "tname_stickers",
	pos = {
		x = 1,
		y = 2,
	},
	
	ppu_artist = { "GhostSalt" },
		idea = { "Corobo" },
	ppu_coder = { "Revo"},
	ppu_team = { "Team Name" },
	should_apply = function(self, card, center, area, bypass_roll)
               return SMODS.Sticker.should_apply(self, card, center, area, bypass_roll) and G.GAME.tnamestickers
	end
})

SMODS.Sticker({
	needs_enable_flag = false,
	rate = 0.05,
	key = "uranium",
	badge_colour = HEX("85a6ac"),
	loc_vars = function(self, info_queue, card)
		local numerator, demonimator = SMODS.get_probability_vars(card, 1, 4, "hpot_uranium")
		return {
			vars = { numerator, demonimator },
		}
	end,
	calculate = function(self, card, context)
		if
			(context.joker_main and SMODS.pseudorandom_probability(card, "hpot_uranium", 1, 4))
			or ((context.main_scoring and (context.cardarea == G.play or context.cardarea == G.hand))
				and SMODS.pseudorandom_probability(card, "hpot_uranium", 1, 4))
		then
			local r = nil
			local l = nil

			local area = card.area
			local rr = nil
			for i = 1, #area.cards do
				if area.cards[i] == card then
					rr = i
				end
			end

			if area.cards[rr - 1] and not area.cards[rr - 1].debuff then
				card_eval_status_text(area.cards[rr - 1], "extra", nil, nil, nil, { message = localize("k_debuffed") })
				SMODS.debuff_card(area.cards[rr - 1], true, card.config.center.key)
			end

			if area.cards[rr + 1] and not area.cards[rr + 1].debuff then
				card_eval_status_text(area.cards[rr + 1], "extra", nil, nil, nil, { message = localize("k_debuffed") })
				SMODS.debuff_card(area.cards[rr + 1], true, card.config.center.key)
			end

		end
	end,
		atlas = "tname_stickers",
	pos = {
		x = 2,
		y = 2,
	},
	
	ppu_artist = { "GhostSalt" },
		idea = { "Corobo" },
	ppu_coder = { "Revo"},
	ppu_team = { "Team Name" },
	should_apply = function(self, card, center, area, bypass_roll)
               return SMODS.Sticker.should_apply(self, card, center, area, bypass_roll) and G.GAME.tnamestickers
	end
})


SMODS.Sticker({
	needs_enable_flag = false,
	rate = 0.05,
	key = "spinning",
	badge_colour = HEX("85a6ac"),
		atlas = "tname_stickers",
	pos = {
		x = 0,
		y = 2,
	},
	
	ppu_artist = { "GhostSalt" },
		idea = { "Corobo" },
	ppu_coder = { "Revo"},
	ppu_team = { "Team Name" },
	should_apply = function(self, card, center, area, bypass_roll)
               return SMODS.Sticker.should_apply(self, card, center, area, bypass_roll) and G.GAME.tnamestickers
	end
})

SMODS.Sticker({
	needs_enable_flag = false,
	rate = 0.05,
	key = "cfour",
	badge_colour = HEX("b7d5d8"),
	loc_vars = function(self, info_queue, center)
		return {
			vars = { },
		}
	end,
	calculate = function(self, card, context)
		if context.hpot_destroy and context.hpot_destroyed.ability.hpot_cfour and not context.hpot_destroyed.hpot_cons_used then
			SMODS.destroy_cards(card)
		end
	end,
	atlas = "tname_stickers",
	pos = {
		x = 3,
		y = 2,
	},
	
	ppu_artist = { "GhostSalt" },
		idea = { "Corobo" },
	ppu_coder = { "Revo"},
	ppu_team = { "Team Name" },
	should_apply = function(self, card, center, area, bypass_roll)
               return SMODS.Sticker.should_apply(self, card, center, area, bypass_roll) and G.GAME.tnamestickers
	end
})

SMODS.Sticker({
	needs_enable_flag = false,
	rate = 0.05,
	key = "blunder",
	badge_colour = HEX("ff3636"),
	applied = function(self, card)
		card.prevent_trigger = true
	end,
	removed = function(self, card)
		card.prevent_trigger = false
	end,
	atlas = "tname_stickers",
	pos = {
		x = 0,
		y = 3,
	},
	
	ppu_artist = { "Revo" },
		idea = { "Violet" },
	ppu_coder = { "Revo"},
	ppu_team = { "Team Name" },
	should_apply = function(self, card, center, area, bypass_roll)
    	return SMODS.Sticker.should_apply(self, card, center, area, bypass_roll) and G.GAME.tnamestickers
	end
})

SMODS.Sticker({
	needs_enable_flag = false,
	rate = 0.03,
	key = "book",
	badge_colour = HEX("d9c57d"),
	calculate = function(self,card,context)
		if context.setting_blind then
			local _rank, _suit, _edition, _seal, _enhancement, _sticker = pseudorandom_element(SMODS.Ranks).card_key, pseudorandom_element(SMODS.Suits).key, poll_edition(), SMODS.poll_seal(), SMODS.poll_enhancement(), poll_sticker()
			local acard =
			SMODS.add_card{
				set = "Playing Card",
				area = G.deck,
				rank = _rank,
				suit = _suit,
				edition = _edition,
				seal = _seal,
				enhancement = _enhancement
			}
			if _sticker then
				SMODS.Stickers[_sticker]:apply(acard,true)
			end
		end
	end,
	atlas = "tname_stickers",
	pos = {
		x = 1,
		y = 3,
	},
	
	ppu_artist = { "Revo" },
		idea = { "Revo" },
	ppu_coder = { "Revo"},
	ppu_team = { "Team Name" },
	should_apply = function(self, card, center, area, bypass_roll)
               return SMODS.Sticker.should_apply(self, card, center, area, bypass_roll) and G.GAME.tnamestickers
	end
})

SMODS.Sticker({
	needs_enable_flag = false,
	rate = 0.01,
	key = "brilliant",
	badge_colour = HEX("7dd4d9"),
	config = {
		timer = 2
	},
	loc_vars = function(self, info_queue, card)
		return {
			vars = { self.config.timer},
		}
	end,
	calculate = function(self, card, context)
		if
			context.other_card == card
			and not card.debuff
			and (context.repetition or (context.retrigger_joker_check and not context.retrigger_joker))
			or (context.main_scoring and context.cardarea == G.play)
		then
			return {
				repetitions = self.config.timer,
			}
		end
	end,
	atlas = "tname_stickers",
	pos = {
		x = 2,
		y = 3,
	},
	
	ppu_artist = { "Revo" },
		idea = { "Revo" },
	ppu_coder = { "Revo"},
	ppu_team = { "Team Name" },
	should_apply = function(self, card, center, area, bypass_roll)
               return SMODS.Sticker.should_apply(self, card, center, area, bypass_roll) and G.GAME.tnamestickers
	end
})