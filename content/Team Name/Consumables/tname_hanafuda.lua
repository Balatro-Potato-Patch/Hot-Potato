SMODS.ConsumableType({
	key = "Hanafuda",
	collection_rows = { 4, 4, 4 },
	primary_colour = G.C.RED,
	secondary_colour = G.C.RED,
	shop_rate = 0.09,
})

-- currecntly hanafuda cards cannot apply to both jokers and hand cards

function highlight_jokers_hand(val, jokers_only, hand_only)
	local joker_check, hand_check, check = nil, nil, nil

	local ret = false

	if G.jokers and G.jokers.highlighted and (#G.jokers.highlighted <= val and #G.jokers.highlighted > 0) then
		joker_check = true
		check = true
	end

	if G.hand and G.hand.highlighted and (#G.hand.highlighted <= val and #G.hand.highlighted > 0) then
		hand_check = true
		check = true
	end

	if jokers_only then
		if joker_check then
			ret = true
		end
	elseif hand_only then
		if hand_check then
			ret = true
		end
	elseif check then
		ret = true
	end

	return ret
end

function unhighlight_hj()
	G.jokers:unhighlight_all()
	G.hand:unhighlight_all()
end

function apply_remove_sticker(card, sticker)
	if card[sticker] or card.ability[sticker] then
		SMODS.Stickers[sticker]:apply(card, false)
	else
		SMODS.Stickers[sticker]:apply(card, true)
	end
end

-- joyous :3
function joy_hanafuda_score(types, context)
    if JoyousSpring then
        if context.individual and context.cardarea == G.play then
            local _, key = JoyousSpring.get_hanafuda(context.other_card)

			for _, hanafuda_type in ipairs(types) do
				if key == hanafuda_type then
					return {
						xchips = 1.5
					}
				end
			end
		end
	end
end

-- PINE
SMODS.Consumable({
	key = "pine_1",
	atlas = "tname_hanafuda",
	pos = { x = 0, y = 0 },
	set = "Hanafuda",
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
	config = {
		extra = {
			high = 3,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		info_queue[#info_queue + 1] =
			{ key = "hpot_fragile", set = "Other", vars = { SMODS.Stickers["hpot_fragile"].config.xmult } }
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				apply_remove_sticker(G.jokers.highlighted[i], "hpot_fragile")
			end
		else
			for i = 1, #G.hand.highlighted do
				apply_remove_sticker(G.hand.highlighted[i], "hpot_fragile")
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Pine with Crane"}, context)
	end
})

SMODS.Consumable({
	key = "pine_2",
	atlas = "tname_hanafuda",
	pos = { x = 0, y = 1 },
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 2,
		},
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] =
			{ key = "hpot_fragile", set = "Other", vars = { SMODS.Stickers["hpot_fragile"].config.xmult } }
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				apply_remove_sticker(G.jokers.highlighted[i], "hpot_fragile")
			end
		else
			for i = 1, #G.hand.highlighted do
				apply_remove_sticker(G.hand.highlighted[i], "hpot_fragile")
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
	end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Pine with Ribbon"}, context)
	end
})

SMODS.Consumable({
	key = "pine_3",
	atlas = "tname_hanafuda",
	pos = { x = 0, y = 2 },
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 1,
		},
	},
	loc_vars = function(self, info_queue, card)
		local numerator, demonimator = SMODS.get_probability_vars(nil, 1, 4, "hpot_uranium")
		info_queue[#info_queue + 1] =
			{ key = "hpot_uranium", set = "Other", vars = { numerator, demonimator } }
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				apply_remove_sticker(G.jokers.highlighted[i], "hpot_uranium")
			end
		else
			for i = 1, #G.hand.highlighted do
				apply_remove_sticker(G.hand.highlighted[i], "hpot_uranium")
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
	end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Pine", "Pine_2"}, context)
	end
})

SMODS.Consumable({
	key = "pine_4",
	atlas = "tname_hanafuda",
	pos = { x = 0, y = 3 },
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 1,
		},
	},
	loc_vars = function(self, info_queue, card)
		local numerator, demonimator = SMODS.get_probability_vars(nil, 1, 4, "hpot_uranium")
		info_queue[#info_queue + 1] =
			{ key = "hpot_uranium", set = "Other", vars = { numerator, demonimator } }
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				apply_remove_sticker(G.jokers.highlighted[i], "hpot_uranium")
			end
		else
			for i = 1, #G.hand.highlighted do
				apply_remove_sticker(G.hand.highlighted[i], "hpot_uranium")
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Pine", "Pine_2"}, context)
	end
})

-- WILLOW

SMODS.Consumable({
	key = "willow_1",
	pos = {x = 10, y = 0},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 3,
		},
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = { key = "hpot_redirect", set = "Other", vars = {} }
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				apply_remove_sticker(G.jokers.highlighted[i], "hpot_redirect")
			end
		else
			for i = 1, #G.hand.highlighted do
				apply_remove_sticker(G.hand.highlighted[i], "hpot_redirect")
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Willow with Calligrapher"}, context)
	end
})

SMODS.Consumable({
	key = "willow_2",
		pos = {x = 10, y = 1},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 3,
		},
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = { key = "hpot_redirect", set = "Other", vars = {} }
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				apply_remove_sticker(G.jokers.highlighted[i], "hpot_redirect")
			end
		else
			for i = 1, #G.hand.highlighted do
				apply_remove_sticker(G.hand.highlighted[i], "hpot_redirect")
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
	end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Willow with Swallow"}, context)
	end
})

SMODS.Consumable({
	key = "willow_3",
		pos = {x = 10, y = 2},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 2,
		},
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = { key = "hpot_cannibal", set = "Other", vars = {} }
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				apply_remove_sticker(G.jokers.highlighted[i], "hpot_cannibal")
			end
		else
			for i = 1, #G.hand.highlighted do
				apply_remove_sticker(G.hand.highlighted[i], "hpot_cannibal")
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
	end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Willow with Ribbon"}, context)
	end
})

SMODS.Consumable({
		pos = {x = 10, y = 3},
	atlas = "tname_hanafuda",
	key = "willow_4",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 1,
		},
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = { key = "hpot_cannibal", set = "Other", vars = {} }
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				apply_remove_sticker(G.jokers.highlighted[i], "hpot_cannibal")
			end
		else
			for i = 1, #G.hand.highlighted do
				apply_remove_sticker(G.hand.highlighted[i], "hpot_cannibal")
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Willow"}, context)
	end
})

-- SAKURA

SMODS.Consumable({
	key = "sakura_1",
	set = "Hanafuda",
		pos = {x = 2, y = 0},
	atlas = "tname_hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 3,
		},
	},
	loc_vars = function(self, info_queue, card)
		local numerator, demonimator = SMODS.get_probability_vars(nil, 1, 4, "hpot_spores")
		info_queue[#info_queue + 1] =
			{ key = "hpot_spores", set = "Other", vars = { numerator, demonimator } }
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				apply_remove_sticker(G.jokers.highlighted[i], "hpot_spores")
			end
		else
			for i = 1, #G.hand.highlighted do
				apply_remove_sticker(G.hand.highlighted[i], "hpot_spores")
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Cherry Blossom with Curtain"}, context)
	end
})

SMODS.Consumable({
	key = "sakura_2",
			pos = {x = 2, y = 1},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 2,
		},
	},
	loc_vars = function(self, info_queue, card)
		local numerator, demonimator = SMODS.get_probability_vars(nil, 1, 4, "hpot_spores")
		info_queue[#info_queue + 1] =
			{ key = "hpot_spores", set = "Other", vars = { numerator, demonimator } }
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				apply_remove_sticker(G.jokers.highlighted[i], "hpot_spores")
			end
		else
			for i = 1, #G.hand.highlighted do
				apply_remove_sticker(G.hand.highlighted[i], "hpot_spores")
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Cherry Blossom with Ribbon"}, context)
	end
})

SMODS.Consumable({
	key = "sakura_3",
			pos = {x = 2, y = 2},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 1,
		},
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = { key = "hpot_cfour", set = "Other", vars = {} }
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				apply_remove_sticker(G.jokers.highlighted[i], "hpot_cfour")
			end
		else
			for i = 1, #G.hand.highlighted do
				apply_remove_sticker(G.hand.highlighted[i], "hpot_cfour")
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Cherry Blossom", "Cherry Blossom_2"}, context)
	end
})

SMODS.Consumable({
	key = "sakura_4",
			pos = {x = 2, y = 3},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 1,
		},
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = { key = "hpot_cfour", set = "Other", vars = {} }
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				apply_remove_sticker(G.jokers.highlighted[i], "hpot_cfour")
			end
		else
			for i = 1, #G.hand.highlighted do
				apply_remove_sticker(G.hand.highlighted[i], "hpot_cfour")
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Cherry Blossom", "Cherry Blossom_2"}, context)
	end
})

-- PAULOWNIA

SMODS.Consumable({
	key = "paulownia_1",
	pos = {x = 11, y = 0},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 3,
		},
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = {
			key = "hpot_overclock",
			set = "Other",
			vars = { G.GAME.overclock_timer, (card.ability.over_tally or G.GAME.overclock_timer) },
		}
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				apply_remove_sticker(G.jokers.highlighted[i], "hpot_overclock")
			end
		else
			for i = 1, #G.hand.highlighted do
				apply_remove_sticker(G.hand.highlighted[i], "hpot_overclock")
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Paulownia with Phoenix"}, context)
	end
})

SMODS.Consumable({
	key = "paulownia_2",
	pos = {x = 11, y = 1},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 1,
		},
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = {
			key = "hpot_overclock",
			set = "Other",
			vars = { G.GAME.overclock_timer, (card.ability.over_tally or G.GAME.overclock_timer) },
		}
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				apply_remove_sticker(G.jokers.highlighted[i], "hpot_overclock")
			end
		else
			for i = 1, #G.hand.highlighted do
				apply_remove_sticker(G.hand.highlighted[i], "hpot_overclock")
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Paulownia", "Paulownia_2", "Paulownia_3"}, context)
	end
})

SMODS.Consumable({
	key = "paulownia_3",
	pos = {x = 11, y = 2},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 1,
		},
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = { key = "hpot_rage", set = "Other", vars = {} }
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				apply_remove_sticker(G.jokers.highlighted[i], "hpot_rage")
			end
		else
			for i = 1, #G.hand.highlighted do
				apply_remove_sticker(G.hand.highlighted[i], "hpot_rage")
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Paulownia", "Paulownia_2", "Paulownia_3"}, context)
	end
})

SMODS.Consumable({
	key = "paulownia_4",
	pos = {x = 11, y = 3},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 1,
		},
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = { key = "hpot_rage", set = "Other", vars = {} }
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				apply_remove_sticker(G.jokers.highlighted[i], "hpot_rage")
			end
		else
			for i = 1, #G.hand.highlighted do
				apply_remove_sticker(G.hand.highlighted[i], "hpot_rage")
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Paulownia", "Paulownia_2", "Paulownia_3"}, context)
	end
})

-- PEONY

SMODS.Consumable({
	key = "peony_1",
	set = "Hanafuda",
	pos = {x = 5, y = 0},
	atlas = "tname_hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 3,
		},
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = { key = "hpot_spinning", set = "Other", vars = {} }
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				apply_remove_sticker(G.jokers.highlighted[i], "hpot_spinning")
			end
		else
			for i = 1, #G.hand.highlighted do
				apply_remove_sticker(G.hand.highlighted[i], "hpot_spinning")
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Peony with Butterfly"}, context)
	end
})

SMODS.Consumable({
	key = "peony_2",
	set = "Hanafuda",
	pos = {x = 5, y = 1},
	atlas = "tname_hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 2,
		},
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = { key = "hpot_spinning", set = "Other", vars = {} }
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				apply_remove_sticker(G.jokers.highlighted[i], "hpot_spinning")
			end
		else
			for i = 1, #G.hand.highlighted do
				apply_remove_sticker(G.hand.highlighted[i], "hpot_spinning")
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Peony with Ribbon"}, context)
	end
})

SMODS.Consumable({
	key = "peony_3",
	pos = {x = 5, y = 2},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 1,
		},
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = { key = "hpot_binary", set = "Other", vars = {} }
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				apply_remove_sticker(G.jokers.highlighted[i], "hpot_binary")
			end
		else
			for i = 1, #G.hand.highlighted do
				apply_remove_sticker(G.hand.highlighted[i], "hpot_binary")
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Peony", "Peony_2"}, context)
	end
})

SMODS.Consumable({
	key = "peony_4",
	pos = {x = 5, y = 3},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 1,
		},
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = { key = "hpot_binary", set = "Other", vars = {} }
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				apply_remove_sticker(G.jokers.highlighted[i], "hpot_binary")
			end
		else
			for i = 1, #G.hand.highlighted do
				apply_remove_sticker(G.hand.highlighted[i], "hpot_binary")
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Peony", "Peony_2"}, context)
	end
})

-- MAPLE

SMODS.Consumable({
	key = "maple_1",
	pos = {x = 9, y = 0},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 5,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		if G.jokers and #G.jokers.cards > 0 then
			return true
		end
		return false
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		ease_dollars(hpt.high * #G.jokers.cards)
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Maple with Deer"}, context)
	end
})

SMODS.Consumable({
	key = "maple_2",
	pos = {x = 9, y = 1},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 3,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		if G.jokers and #G.jokers.cards > 0 then
			return true
		end
		return false
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		ease_dollars(hpt.high * #G.jokers.cards)
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Maple with Ribbon"}, context)
	end
})

SMODS.Consumable({
	key = "maple_3",
	pos = {x = 9, y = 2},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 1,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		if G.jokers and #G.jokers.cards > 0 then
			return true
		end
		return false
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		ease_dollars(hpt.high * #G.jokers.cards)
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Maple", "Maple_2"}, context)
	end
})

SMODS.Consumable({
	key = "maple_4",
	pos = {x = 9, y = 3},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 1,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		if G.jokers and #G.jokers.cards > 0 then
			return true
		end
		return false
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		ease_dollars(hpt.high * #G.jokers.cards)
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Maple", "Maple_2"}, context)
	end
})

-- Chrysanthemum

SMODS.Consumable({
	key = "chrysanthemum_1",
	pos = {x = 8, y = 0},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 3,
			odds = 4
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		local numerator, denominator = SMODS.get_probability_vars(card, 1, hpt.odds, "hpot_chrysanthemum")
		return {
			vars = { hpt.high ,numerator, denominator },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high, true)
	end,
	use = function(self, card, area, copier)
	if SMODS.pseudorandom_probability(card, "hpot_chrysanthemum", 1, card.ability.extra.odds ) then
		for i = 1, #G.jokers.highlighted do
			apply_modification(G.jokers.highlighted[i], random_modif("GOOD", card).key)
		end
        play_sound("hpot_tname_reforge")
		unhighlight_hj()
	else
		noping_it(card)
	end
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Chrysanthemum with Sake"}, context)
	end
})

SMODS.Consumable({
	key = "chrysanthemum_2",
	pos = {x = 8, y = 1},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 2,
			odds = 4,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		local numerator, denominator = SMODS.get_probability_vars(card, 1, hpt.odds, "hpot_chrysanthemum")
		return {
			vars = { hpt.high ,numerator, denominator },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high, true)
	end,
	use = function(self, card, area, copier)
	if SMODS.pseudorandom_probability(card, "hpot_chrysanthemum", 1, card.ability.extra.odds ) then
		for i = 1, #G.jokers.highlighted do
			apply_modification(G.jokers.highlighted[i], random_modif("GOOD", card).key)
		end
        play_sound("hpot_tname_reforge")
		unhighlight_hj()
	else
		noping_it(card)
	end
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Chrysanthemum with Ribbon"}, context)
	end
})

SMODS.Consumable({
	key = "chrysanthemum_3",
	pos = {x = 8, y = 2},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
	
	config = {
		extra = {
			high = 1,
			odds = 4,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		local numerator, denominator = SMODS.get_probability_vars(card, 1, hpt.odds, "hpot_chrysanthemum")
		return {
			vars = { hpt.high ,numerator, denominator },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high, true)
	end,
	use = function(self, card, area, copier)
	if SMODS.pseudorandom_probability(card, "hpot_chrysanthemum", 1, card.ability.extra.odds ) then
		for i = 1, #G.jokers.highlighted do
			apply_modification(G.jokers.highlighted[i], random_modif("GOOD", card).key)
		end
        play_sound("hpot_tname_reforge")
		unhighlight_hj()
	else
		noping_it(card)
	end
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Chrysanthemum", "Chrysanthemum_2"}, context)
	end
})

SMODS.Consumable({
	key = "chrysanthemum_4",
	pos = {x = 8, y = 3},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 1,
			odds = 4,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		local numerator, denominator = SMODS.get_probability_vars(card, 1, hpt.odds, "hpot_chrysanthemum")
		return {
			vars = { hpt.high ,numerator, denominator },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high, true)
	end,
	use = function(self, card, area, copier)
	if SMODS.pseudorandom_probability(card, "hpot_chrysanthemum", 1, card.ability.extra.odds ) then
		for i = 1, #G.jokers.highlighted do
			apply_modification(G.jokers.highlighted[i], random_modif("GOOD", card).key)
		end
        play_sound("hpot_tname_reforge")
		unhighlight_hj()
	else
		noping_it(card)
	end
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Chrysanthemum", "Chrysanthemum_2"}, context)
	end
})

-- SUSUKI

SMODS.Consumable({
	key = "susuki_1",
	pos = {x = 7, y = 0},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 3,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				local key = poll_sticker(true, G.jokers.highlighted[i])
				SMODS.Stickers[key]:apply(G.jokers.highlighted[i], true)
			end
		else
			for i = 1, #G.hand.highlighted do
				local key = poll_sticker(true, G.hand.highlighted[i])
				SMODS.Stickers[key]:apply(G.hand.highlighted[i], true)
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Zebra Grass with Moon"}, context)
	end
})

SMODS.Consumable({
	key = "susuki_2",
	pos = {x = 7, y = 1},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 2,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				local key = poll_sticker(true, G.jokers.highlighted[i])
				SMODS.Stickers[key]:apply(G.jokers.highlighted[i], true)
			end
		else
			for i = 1, #G.hand.highlighted do
				local key = poll_sticker(true, G.hand.highlighted[i])
				SMODS.Stickers[key]:apply(G.hand.highlighted[i], true)
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Zebra Grass with Geese"}, context)
	end
})

SMODS.Consumable({
	key = "susuki_3",
	pos = {x = 7, y = 2},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 1,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				local key = poll_sticker(true, G.jokers.highlighted[i])
				SMODS.Stickers[key]:apply(G.jokers.highlighted[i], true)
			end
		else
			for i = 1, #G.hand.highlighted do
				local key = poll_sticker(true, G.hand.highlighted[i])
				SMODS.Stickers[key]:apply(G.hand.highlighted[i], true)
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Zebra Grass", "Zebra Grass_2"}, context)
	end
})

SMODS.Consumable({
	key = "susuki_4",
	pos = {x = 7, y = 3},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 1,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high)
	end,
	use = function(self, card, area, copier)
		if #G.jokers.highlighted > 0 then
			for i = 1, #G.jokers.highlighted do
				local key = poll_sticker(true, G.jokers.highlighted[i])
				SMODS.Stickers[key]:apply(G.jokers.highlighted[i], true)
			end
		else
			for i = 1, #G.hand.highlighted do
				local key = poll_sticker(true, G.hand.highlighted[i])
				SMODS.Stickers[key]:apply(G.hand.highlighted[i], true)
			end
		end
        play_sound('gold_seal', 1.2, 0.4)
		unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Zebra Grass", "Zebra Grass_2"}, context)
	end
})

-- IRIS

SMODS.Consumable({
	key = "iris_1",
	pos = {x = 4, y = 0},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 3,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return false
	end,
	calculate = function(self, card, context)
		local hpt = card.ability.extra
        if context.end_of_round and context.main_eval then
            card.ability.extra_value = (card.ability.extra_value or 0) + hpt.high 
            card:set_cost()
			card_eval_status_text(card, "extra", nil, nil, nil, { message = localize("k_val_up") })
        end
		return joy_hanafuda_score({"Water Iris with Bridge"}, context)
	end,
})

SMODS.Consumable({
	key = "iris_2",
	pos = {x = 4, y = 1},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 2,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return false
	end,
	calculate = function(self, card, context)
		local hpt = card.ability.extra
        if context.end_of_round and context.main_eval then
            card.ability.extra_value = (card.ability.extra_value or 0) + hpt.high 
            card:set_cost()
			card_eval_status_text(card, "extra", nil, nil, nil, { message = localize("k_val_up") })
        end
		return joy_hanafuda_score({"Water Iris with Ribbon"}, context)
	end,
})

SMODS.Consumable({
	key = "iris_3",
	pos = {x = 4, y = 2},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 1,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return false
	end,
	calculate = function(self, card, context)
		local hpt = card.ability.extra
        if context.end_of_round and context.main_eval then
            card.ability.extra_value = (card.ability.extra_value or 0) + hpt.high 
            card:set_cost()
			card_eval_status_text(card, "extra", nil, nil, nil, { message = localize("k_val_up") })
        end
		return joy_hanafuda_score({"Water Iris", "Water Iris_2"}, context)
	end,
})

SMODS.Consumable({
	key = "iris_4",
	pos = {x = 4, y = 3},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 1,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return false
	end,
	calculate = function(self, card, context)
		local hpt = card.ability.extra
		if context.end_of_round and context.main_eval then
			card.ability.extra_value = (card.ability.extra_value or 0) + hpt.high 
			card:set_cost()
			card_eval_status_text(card, "extra", nil, nil, nil, { message = localize("k_val_up") })
		end
		return joy_hanafuda_score({"Water Iris", "Water Iris_2"}, context)
	end,
})

-- WISTERIA

SMODS.Consumable({
	key = "wisteria_1",
	pos = {x = 3, y = 0},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 3,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high, true)
	end,
	use = function(self, card, area, copier)
        local is_activated = false
		for i = 1, #G.jokers.highlighted do
            local modif = get_modification(G.jokers.highlighted[i])
            if modif and HPTN.Modifications[modif].morality == "BAD" then
                is_activated = true
                HPTN.Modifications[modif]:apply(G.jokers.highlighted[i], false)
                G.jokers.highlighted[i]:juice_up()
            end
		end
        if is_activated then
            play_sound("hpot_tname_reforge")
        end
        unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Wisteria with Cuckoo"}, context)
	end
})

SMODS.Consumable({
	key = "wisteria_2",
	pos = {x = 3, y = 1},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 2,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high, true)
	end,
    use = function(self, card, area, copier)
        local is_activated = false
		for i = 1, #G.jokers.highlighted do
            local modif = get_modification(G.jokers.highlighted[i])
            if modif and HPTN.Modifications[modif].morality == "BAD" then
                is_activated = true
                HPTN.Modifications[modif]:apply(G.jokers.highlighted[i], false)
                G.jokers.highlighted[i]:juice_up()
            end
		end
        if is_activated then
            play_sound("hpot_tname_reforge")
        end
        unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Wisteria with Ribbon"}, context)
	end
})

SMODS.Consumable({
	key = "wisteria_3",
	pos = {x = 3, y = 2},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 1,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high, true)
	end,
    use = function(self, card, area, copier)
        local is_activated = false
		for i = 1, #G.jokers.highlighted do
            local modif = get_modification(G.jokers.highlighted[i])
            if modif and HPTN.Modifications[modif].morality == "BAD" then
                is_activated = true
                HPTN.Modifications[modif]:apply(G.jokers.highlighted[i], false)
                G.jokers.highlighted[i]:juice_up()
            end
		end
        if is_activated then
            play_sound("hpot_tname_reforge")
        end
        unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Wisteria", "Wisteria_2"}, context)
	end
})

SMODS.Consumable({
	key = "wisteria_4",
	pos = {x = 3, y = 3},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 1,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return highlight_jokers_hand(hpt.high, true)
	end,
    use = function(self, card, area, copier)
        local is_activated = false
		for i = 1, #G.jokers.highlighted do
            local modif = get_modification(G.jokers.highlighted[i])
            if modif and HPTN.Modifications[modif].morality == "BAD" then
                is_activated = true
                HPTN.Modifications[modif]:apply(G.jokers.highlighted[i], false)
                G.jokers.highlighted[i]:juice_up()
            end
		end
        if is_activated then
            play_sound("hpot_tname_reforge")
        end
        unhighlight_hj()
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Wisteria", "Wisteria_2"}, context)
	end
})

-- BUSH CLOVER

SMODS.Consumable({
	key = "bush_clover_1",
	pos = {x = 6, y = 0},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 3,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return true
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		for i = 1, hpt.high do
			result = SMODS.add_card({
				set = "Hanafuda",
				area = G.consumeables,
				edition = "e_negative",
			})
			if result.config.center_key:find('bush_clover') then
				if tonumber(result.config.center_key:sub(-1)) < tonumber(card.config.center_key:sub(-1)) and tonumber(result.config.center_key:sub(-1)) < 3 then
					check_for_unlock({type = 'whoppers'})
				end
			end
		end
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Clover with Boar"}, context)
	end
})
SMODS.Consumable({
	key = "bush_clover_2",
	pos = {x = 6, y = 1},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 2,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return true
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		for i = 1, hpt.high do
			result = SMODS.add_card({
				set = "Hanafuda",
				area = G.consumeables,
				edition = "e_negative",
			})
			if result.config.center_key:find('bush_clover') then
				if tonumber(result.config.center_key:sub(-1)) < tonumber(card.config.center_key:sub(-1)) and tonumber(result.config.center_key:sub(-1)) < 3 then
					check_for_unlock({type = 'whoppers'})
				end
			end
		end
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Clover with Ribbon"}, context)
	end
})
SMODS.Consumable({
	key = "bush_clover_3",
	pos = {x = 6, y = 2},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 1,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return true
	end,
	use = function(self, card, area, copier)
		local hpt = card.ability.extra
		for i = 1, hpt.high do
			result = SMODS.add_card({
				set = "Hanafuda",
				area = G.consumeables,
				edition = "e_negative",
			})
			if result.config.center_key:find('bush_clover') then
				if tonumber(result.config.center_key:sub(-1)) < tonumber(card.config.center_key:sub(-1)) and tonumber(result.config.center_key:sub(-1)) < 3 then
					check_for_unlock({type = 'whoppers'})
				end
			end
		end
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Clover", "Clover_2"}, context)
	end
})
SMODS.Consumable({
	key = "bush_clover_4",
	pos = {x = 6, y = 3},
	atlas = "tname_hanafuda",
	set = "Hanafuda",
	
	ppu_artist = { "GhostSalt" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },

	config = {
		extra = {
			high = 1,
		},
	},
	loc_vars = function(self, info_queue, card)
		local hpt = card.ability.extra
		return {
			vars = { hpt.high },
		}
	end,
	can_use = function(self, card)
		local hpt = card.ability.extra
		return true
	end,
	use = function(self, card, area, copier)
        local result
		local hpt = card.ability.extra
		for i = 1, hpt.high do
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.4,
                func = function()
                    result = SMODS.add_card({
                        set = "Hanafuda",
                        area = G.consumeables,
                        edition = "e_negative",
                    })
                    if result.config.center_key:find('bush_clover') then
                        if tonumber(result.config.center_key:sub(-1)) < tonumber(card.config.center_key:sub(-1)) and tonumber(result.config.center_key:sub(-1)) < 3 then
                            check_for_unlock({type = 'whoppers'})
                        end
                    end
                    return true
                end,
            }))
		end
    end,
	calculate = function (self, card, context)
		return joy_hanafuda_score({"Clover", "Clover_2"}, context)
	end
})

