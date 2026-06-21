SMODS.Enhancement {
	key = 'oap_lead',
	atlas = 'oap_pb',
	ppu_coder = { "factwixard" },
	ppu_artist = { "factwixard" },
	ppu_team = { "OAP" },
	config = { extra = { xchips_gain = 0.1 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xchips_gain } }
	end,
	calculate = function(self, card, context)
		if context.main_scoring and context.cardarea == G.play then
			card.ability.perma_h_x_chips = card.ability.perma_h_x_chips or 0
			card.ability.perma_h_x_chips = card.ability.perma_h_x_chips + card.ability.extra.xchips_gain
		end
	end
}
