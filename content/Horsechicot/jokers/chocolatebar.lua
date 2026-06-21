SMODS.Joker {
    key = "chocolate_bar",
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
    rarity = 1,
    cost = 5,
    atlas = "hc_jokers",
    pos = { x = 0, y = 2 },
    config = { extra = { odds = 6, chips = 120 } },
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'hpot_chocolate_bar')
        return { vars = { card.ability.extra.chips, numerator, denominator } }
    end,
    ppu_artist = {"lord.ruby"},
    ppu_coder = {"Nxkoo"},
    ppu_team = {"Horsechicot"},
    pools = { Food = true },
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            if SMODS.pseudorandom_probability(card, 'vanillamod', 1, card.ability.extra.odds) then
                SMODS.destroy_cards(card, nil, nil, true)
                G.GAME.pool_flags.chocolates = true
                return {
                    message = localize('k_drank_ex')
                }
            else
                return {
                    message = localize('k_safe_ex')
                }
            end
        end
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
    end
}