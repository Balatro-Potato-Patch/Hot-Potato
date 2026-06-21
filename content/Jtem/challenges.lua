SMODS.Challenge {
	key = 'plinko4ever',
	rules = {
		custom = {
			{ id = 'hpot_plinko_4ever' },
			{ id = 'hpot_plinko_4ever_2' }
		}
	},
	apply = function(self)
		G.GAME.plincoins_per_round = 0
		G.GAME.current_round.plinko_roll_cost = 0
		G.GAME.starting_params.boosters_in_shop = 1
	end,
	restrictions = {
		banned_cards = {
			{ id = "v_hpot_currency_exchange" },
			{ id = "v_hpot_currency_exchange2" }
		},
		banned_tags = {
			{ id = "tag_voucher" },
			{ id = "tag_uncommon" },
			{ id = "tag_rare" },
			{ id = "tag_foil" },
			{ id = "tag_holo" },
			{ id = "tag_polychrome" },
			{ id = "tag_negative" },
			{ id = "tag_hpot_psychedelic_tag" },
			{ id = "tag_hpot_phantasmic" }
		}
	}
}
