SMODS.Joker {
    key = "cardstack",
    atlas = "hc_jokers",
    pos = { x = 1, y = 3 },
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    cost = 6,
    config = { extra = { retriggers = 1, numerator = 1, denominator = 3, denom_inc = 3 } },
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, card.ability.extra.numerator, card.ability.extra.denominator, 'hc_cardstack')
        return {
            vars = { card.ability.extra.retriggers, numerator, denominator, card.ability.extra.denom_inc }
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if not next(SMODS.get_enhancements(context.other_card)) and SMODS.pseudorandom_probability(card, 'hc_cardstack', card.ability.extra.numerator, card.ability.extra.denominator) then
                context.other_card.ability.perma_repetitions = (context.other_card.ability.perma_repetitions or 0) + card.ability.extra.retriggers
                card.ability.extra.denominator = card.ability.extra.denominator + card.ability.extra.denom_inc
                return {
                    message = localize('k_upgrade_ex'),
                    card = card
                }
            end
        end
    end,
    ppu_coder = { "Nxkoo" },
    ppu_artist = { "pangaea47" },
    ppu_team = { "Horsechicot" },
}

-- the EXACT same code from Tangents i know