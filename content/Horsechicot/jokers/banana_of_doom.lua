SMODS.Joker {
    key = "banana_of_doom",
    rarity = 1,
    cost = 6,
    config = {
        extra = {
            xmult = 6.66,
            odds = 6666
        }
    },
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
    attributes = { 'xmult', 'chance', 'food', },
    atlas = "hc_jokers",
    pos = {x = 0, y = 0},
    soul_pos = {x = 1, y = 0},
    in_pool = function(self, args)
        return G.GAME.pool_flags.cavendish_extinct
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            if SMODS.pseudorandom_probability(card, 'hpot_doom', 1, card.ability.extra.odds) then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = localize('k_extinct_ex')
                }
            else
                return {
                    message = localize('k_safe_ex')
                }
            end
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end,
    loc_vars = function(self, q, card) 
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'hpot_doom')
        return { vars = { card.ability.extra.xmult, numerator, denominator } }
    end,
    ppu_coder = { "lord.ruby" },
    ppu_artist = { "lord.ruby" },
    ppu_team = { "Horsechicot" },
}