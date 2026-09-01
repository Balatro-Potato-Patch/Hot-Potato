SMODS.Shader({
    key="phantasmic",
    path="phantasmic.fs"
})

SMODS.Edition {
    key="phantasmic",
    shader="phantasmic",
	sound = {
		sound = "multhit1",
		per = 1,
		vol = 0.4,
	},
	config = {
		odds = 4
	},
	dependencies = {
        items = {
          "set_entr_misc"
        }
    },
	extra_cost = 5,
	in_shop = true,
	weight = 0.45,
    badge_color = HEX("4179e7"),
    loc_vars = function (self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, (card.edition or self.config).odds, "hpot_phant")
        return { vars = { numerator, denominator } }
    end,
    calculate = function(self, card, context)
		if (context.edition or context.main_scoring) and not context.phantasmic and SMODS.pseudorandom_probability(card, "hpot_phant", 1, (card.edition or self.config).odds ) then
			local cards = {}
			for i, v in pairs(G.jokers.cards) do if card ~= v then cards[#cards+1] = v; end end
			pseudoshuffle(cards, pseudoseed('phantasmic_cards'))
			local actual = {}
			actual[1] = cards[1]
			for i, v in pairs(actual) do
				context.phantasmic = true
				context.edition = nil
                local jm = context.joker_main
                context.joker_main = true
				local eval, post = eval_card(v, context)
				local effects = {eval}
				if context.main_scoring then 
					eval.chips = v.base.nominal + v.ability.bonus or 0
					SMODS.calculate_context({individual = true, other_card=v, cardarea = v.area})
				end
				for _,v in ipairs(post or {}) do effects[#effects+1] = v end
				if eval.retriggers then
					for rt = 1, #eval.retriggers do
						local rt_eval, rt_post = eval_card(v, context)
						table.insert(effects, {eval.retriggers[rt]})
						table.insert(effects, rt_eval)
						for _, v in ipairs(rt_post) do effects[#effects+1] = v end
						if context.main_scoring then 
							table.insert(effects, {chips = v.base.nominal + v.ability.bonus or 0}) 
							SMODS.calculate_context({individual = true, other_card=v, cardarea = v.area})
						end
					end
				end
                if not card.ability.mused then
                    SMODS.calculate_effect({message = localize("k_again_ex"), card = card})
                end
                SMODS.trigger_effects(effects, v)
				context.phantasmic= nil
                context.joker_main = jm
			end
            card.ability.mused = true
            G.E_MANAGER:add_event(Event{
                trigger = "after",
                blocking = false,
                func = function()
                    card.ability.mused = false
                    return true
                end
            })
		end
	end,
	ppu_coder = { "lord.ruby" },
	ppu_artist = { "lord.ruby" },
	ppu_team = { "Horsechicot" }
}
